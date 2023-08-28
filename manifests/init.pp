# @summary PXE Install server
#
# Set up an PXE install server with dhcp, tftp and webserver for serving files
#
# @param installserverip
#    The ip of the install server
#
# @param installserver
#    Hostname of the install server
#
# @param repo_server
#    Hostname of the server hosting the package repositories
#
# @param repo_server_ip
#    IP of the server hosting the package repositories
#
# @param repos_dir
#    Directory location of the package repositories
#
# @param repos_url
#    URI where the pacjaqges can be found on the repo server
#
# @param scriptdir
#    Directory location where to cfreate scripts and prepared files
#
# @param scripturl
#    URL where to find the scripts
# 
# @param kickstart_dir
#    Directory location for the kickstart/preseed files
#
# @param kickstart_url
#    Url where to download the kickstart/preseed files
#
# @param puppetmaster
#    The hostname of the Puppet master server
#
# @param puppetmasterip
#    The ip of the Puppet master server
#
# @param services
#    Hash with services to configure. Valid are dhcp and tftp. Each service is a hash of how to configure
#    that service.
#
# @param machines
#    Hash with all machines to get installed. Each entry i a whole description of a machine with ips, 
#    partitions and so on.
#
# @param status_allow_from
#    Allow Apache status URLs from these ips
#
# @param enabled
#    Installserver is enbaled or not
#
# @param ssl_cert
#    Location of the SSL certificate for the webserver to use. he file has to exist on the install server.
#
# @param ssl_key
#    Location of the SSL key for the webserver to use. he file has to exist on the install server.
#
# @param ssl_chain
#    Location of the SSL certificate chain for the webserver to use. he file has to exist on the install server.
#
# @param ssl_certs_dir
#    Directory where all files for the cdertificates reside.
#
# @param documentroot
#    Document root for the webserver.
#
# @param create_aliases
#    Create webserver aliases
#
# @param challenge_password
#    Sensitive challenge password for auto signing cert requests.
#
# @param add_hosts_entries
#    Add install server and puppet server to /etc/hosts file.
#
# @param install_curl
#    Install curl package
#
# @param install_unzip
#    Install unzip package
#
# @param syslinux_url
#    The url where to download the syslinux archive.
#
# @param syslinux_name
#    Ther name of the archive.
#
# @param syslinux_version
#    The version of the archive.
#
# @param ipxefile
#    The url to download the ipxe file.
#
# @param mirrors
#    Hash with mirror definitions.
#
# @param defaults
#    Default values.
#
# @param purge_apache_configs 
#    Boolean to indicate that all Apache configurations not maintained by the Apache Puppet module should be deleted.
#
# @author Thomas Krieger
#
# @example
#   include pxe_install
class pxe_install (
  String $installserverip,
  String $installserver,
  String $repo_server,
  String $repo_server_ip,
  Stdlib::Unixpath $repos_dir,
  String $repos_url,
  Stdlib::Unixpath $scriptdir,
  String $scripturl,
  Stdlib::Unixpath $kickstart_dir,
  String $kickstart_url,
  Sensitive[String] $challenge_password,
  Optional[String] $puppetmaster          = undef,
  Optional[String] $puppetmasterip        = undef,
  Optional[Hash] $services                = undef,
  Optional[Hash] $machines                = undef,
  Array $status_allow_from                = ['127.0.0.1'],
  Boolean $enabled                        = true,
  String $ssl_cert                        = '/etc/pki/httpd/repos.example.com/repos.example.com.cer',
  String $ssl_key                         = '/etc/pki/httpd/repos.example.com/repos.example.com.key',
  String $ssl_chain                       = '/etc/pki/httpd/repos.example.com/fullchain.cer',
  String $ssl_certs_dir                   = '/etc/pki/httpd/repos.example.com/',
  String $documentroot                    = '/var/www/html',
  Boolean $create_aliases                 = true,
  Boolean $add_hosts_entries              = false,
  Stdlib::HTTPSUrl $syslinux_url          = $pxe_install::params::syslinux_url,
  String $syslinux_name                   = $pxe_install::params::syslinux_name,
  String $syslinux_version                = $pxe_install::params::syslinux_version,
  Stdlib::HTTPUrl $ipxefile               = $pxe_install::params::ipxefile,
  Boolean $install_curl                   = $pxe_install::params::install_curl,
  Boolean $install_unzip                  = $pxe_install::params::install_unzip,
  Hash $mirrors                           = $pxe_install::params::mirrors,
  Hash $defaults                          = $pxe_install::params::defaults,
  Boolean $purge_apache_configs           = false,
) inherits pxe_install::params {
  $_puppetmaster = $puppetmaster ? {
    undef   => '',
    default => $puppetmaster,
  }

  $_puppetmasterip = $puppetmasterip ? {
    undef   => '',
    default => $puppetmasterip
  }

  $_services = $services ? {
    undef   => {},
    default => $services,
  }

  $_machines = $machines ? {
    undef   => '',
    default => $machines,
  }

  pxe_install::parent_dirs { 'create script dir':
    dir_path => $scriptdir,
  }

  pxe_install::parent_dirs { 'create kickstart dirs':
    dir_path => $kickstart_dir,
  }

  pxe_install::parent_dirs { 'create document root dir':
    dir_path => $documentroot,
  }

  file { "${scriptdir}/debian-post.sh":
    ensure  => file,
    content => epp('pxe_install/scripts/debian-post.sh.epp', {
        installserver      => $installserver,
        installserverip    => $installserverip,
        puppetmaster       => $_puppetmaster,
        puppetmasterip     => $_puppetmasterip,
        kickstart_url      => $kickstart_url,
        repos_url          => $repos_url,
        scripturl          => $scripturl,
        challenge_password => $challenge_password,
        add_hosts_entries  => $add_hosts_entries,
    }),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  file { "${scriptdir}/debian-rc.local":
    ensure  => file,
    content => epp('pxe_install/scripts/debian.rc.local.epp', {}),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  file { "${scriptdir}/ubuntu-post.sh":
    ensure  => file,
    content => epp('pxe_install/scripts/ubuntu-post.sh.epp', {
        installserver      => $installserver,
        installserverip    => $installserverip,
        puppetmaster       => $_puppetmaster,
        puppetmasterip     => $_puppetmasterip,
        kickstart_url      => $kickstart_url,
        repos_url          => $repos_url,
        scripturl          => $scripturl,
        challenge_password => $challenge_password,
        add_hosts_entries  => $add_hosts_entries,
    }),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  file { "${scriptdir}/redhat-post.sh":
    ensure  => file,
    content => epp('pxe_install/scripts/redhat-post.sh.epp', {
        installserver      => $installserver,
        installserverip    => $installserverip,
        puppetmaster       => $_puppetmaster,
        puppetmasterip     => $_puppetmasterip,
        kickstart_url      => $kickstart_url,
        repos_url          => $repos_url,
        scripturl          => $scripturl,
        reposerver         => $repo_server,
        reposerverip       => $repo_server_ip,
        challenge_password => $challenge_password,
        add_hosts_entries  => $add_hosts_entries,
    }),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  file { "${scriptdir}/fedora-post.sh":
    ensure  => file,
    content => epp('pxe_install/scripts/fedora-post.sh.epp', {
        installserver      => $installserver,
        installserverip    => $installserverip,
        puppetmaster       => $_puppetmaster,
        puppetmasterip     => $_puppetmasterip,
        kickstart_url      => $kickstart_url,
        repos_url          => $repos_url,
        scripturl          => $scripturl,
        reposerver         => $repo_server,
        reposerverip       => $repo_server_ip,
        challenge_password => $challenge_password,
        add_hosts_entries  => $add_hosts_entries,
    }),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  if pxe_install::hash_key($_services, 'dhcpd') {
    $dhcpd = $_services['dhcpd']
    class { 'pxe_install::dhcp':
      dhcp => $dhcpd,
    }
  }

  if pxe_install::hash_key($_services, 'tftpd') {
    $tftpd = $_services['tftpd']
    class { 'pxe_install::tftp':
      tftp => $tftpd,
    }
  }

  if pxe_install::hash_key($_services, 'samba') {
    $samba = $_services['samba']
    class { 'samba':
      * => $samba,
    }
  }

  class { 'pxe_install::apache':
    kickstart_dir     => $kickstart_dir,
    kickstart_url     => $kickstart_url,
    pub_dir           => $scriptdir,
    pub_url           => $scripturl,
    repos_dir         => $repos_dir,
    repos_url         => $repos_url,
    servername        => $repo_server,
    status_allow_from => $status_allow_from,
    ssl_cert          => $ssl_cert,
    ssl_key           => $ssl_key,
    ssl_chain         => $ssl_chain,
    ssl_certs_dir     => $ssl_certs_dir,
    documentroot      => $documentroot,
    create_aliases    => $create_aliases,
    purge_configs     => $purge_apache_configs,
  }

  $tftpboot_dir = pxe_install::hash_key($tftpd, 'directory') ? {
    true => $tftpd['directory'],
    default => '/var/lib/tftpboot',
  }

  $windows_dir = pxe_install::hash_key($tftpd, 'windows_directory') ? {
    true    => $tftpd['windows_directory'],
    default => '/windows',
  }

  $windows_config_dir = pxe_install::hash_key($tftpd, 'windows_config_directory') ? {
    true    => $tftpd['windows_config_directory'],
    default => '',
  }

  $windows_domain = pxe_install::hash_key($tftpd, 'windows_domain') ? {
    true    => $tftpd['windows_domain'],
    default => '',
  }

  pxe_install::parent_dirs { 'create tftpboot windows scripts dir':
    dir_path => "${tftpboot_dir}${windows_dir}/scripts",
  }

  pxe_install::parent_dirs { 'create tftpboot windows unattend dir':
    dir_path => "${tftpboot_dir}${windows_dir}/unattend",
  }

  pxe_install::parent_dirs { 'create tftpboot grub dir':
    dir_path => "${tftpboot_dir}/grub",
  }

  $win_locale = pxe_install::hash_key($defaults, 'win_locale') ? {
    true  => $defaults['win_locale'],
    false => 'en-US',
  }

  $win_input_locale = pxe_install::hash_key($defaults, 'win_input_locale') ? {
    true  => $defaults['win_input_locale'],
    false => 'en-US',
  }

  file { "${tftpboot_dir}${windows_dir}/scripts/install.ps1":
    ensure  => file,
    content => epp('pxe_install/windows/install.ps1.epp', {
        domain => $windows_domain,
    }),
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
  }

  file { "${tftpboot_dir}${windows_dir}/unattend/2019_bios.xml":
    ensure  => file,
    content => epp('pxe_install/windows/2019_bios.xml.epp', {
        domain           => $windows_domain,
        win_locale       => $win_locale,
        win_input_locale => $win_input_locale,
    }),
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
  }

  file { "${tftpboot_dir}${windows_dir}/unattend/2019_uefi.xml":
    ensure  => file,
    content => epp('pxe_install/windows/2019_uefi.xml.epp', {
        domain           => $windows_domain,
        win_locale       => $win_locale,
        win_input_locale => $win_input_locale,
    }),
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
  }

  ensure_resource('file', ["${tftpboot_dir}/grub"], {
      ensure       => directory,
      purge        => true,
      recurselimit => 1,
      recurse      => true,
      owner        => 'root',
      group        => 'root',
      mode         => '0755',
  })

  file { "${tftpboot_dir}/grub/grub.cfg":
    ensure => file,
    source => 'puppet:///modules/pxe_install/grub.cfg',
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
  }

  $_machines.each |$hostname, $data| {
    pxe_install::kickstart { $hostname:
      data               => $data,
      kickstart_dir      => $kickstart_dir,
      kickstart_url      => $kickstart_url,
      repos_url          => $repos_url,
      scripturl          => $scripturl,
      dhcp_entry         => pxe_install::hash_key($_services, 'dhcpd'),
      tftp_entry         => pxe_install::hash_key($_services, 'tftpd'),
      puppetmaster       => $_puppetmaster,
      challenge_password => $challenge_password,
      tftpboot_dir       => $tftpboot_dir,
      windows_dir        => $windows_dir,
      windows_config_dir => $windows_config_dir,
    }
  }
}
