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
  Optional[String] $puppetmaster                = '',
  Optional[String] $puppetmasterip              = '',
  Optional[Hash] $services                      = {},
  Optional[Hash] $machines                      = {},
  Optional[Array] $status_allow_from            = ['127.0.0.1'],
  Optional[Boolean] $enabled                    = true,
  Optional[String] $ssl_cert                    = '/etc/pki/httpd/repos.example.com/repos.example.com.cer',
  Optional[String] $ssl_key                     = '/etc/pki/httpd/repos.example.com/repos.example.com.key',
  Optional[String] $ssl_chain                   = '/etc/pki/httpd/repos.example.com/fullchain.cer',
  Optional[String] $ssl_certs_dir               = '/etc/pki/httpd/repos.example.com/',
  Optional[String] $documentroot                = '/var/www/html',
  Optional[Boolean] $create_aliases             = true,
  Optional[Boolean] $add_hosts_entries          = false,
  Optional[Stdlib::HTTPSUrl] $syslinux_url      = $pxe_install::params::syslinux_url,
  Optional[String] $syslinux_name               = $pxe_install::params::syslinux_name,
  Optional[String] $syslinux_version            = $pxe_install::params::syslinux_version,
  Optional[Stdlib::HTTPUrl] $ipxefile           = $pxe_install::params::ipxefile,
  Optional[Boolean] $install_curl               = $pxe_install::params::install_curl,
  Optional[Boolean] $install_unzip              = $pxe_install::params::install_unzip,
  Optional[Hash] $mirrors                       = $pxe_install::params::mirrors,
  Optional[Hash] $defaults                      = $pxe_install::params::defaults,
) inherits pxe_install::params {

  pxe_install::parent_dirs{ 'create script dir':
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
      puppetmaster       => $puppetmaster,
      puppetmasterip     => $puppetmasterip,
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
      puppetmaster       => $puppetmaster,
      puppetmasterip     => $puppetmasterip,
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
      puppetmaster       => $puppetmaster,
      puppetmasterip     => $puppetmasterip,
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
      puppetmaster       => $puppetmaster,
      puppetmasterip     => $puppetmasterip,
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

  if has_key($services, 'dhcpd') {
    $dhcpd = $services['dhcpd']
    class { 'pxe_install::dhcp':
      dhcp => $dhcpd,
    }
  }

  if has_key($services, 'tftpd') {
    $tftpd = $services['tftpd']
    class { 'pxe_install::tftp':
      tftp => $tftpd,
    }
  }

  if has_key($services, 'samba') {
    $samba = $services['samba']
    class { '::samba':
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
  }

  $tftpboot_dir = has_key($tftpd, 'directory') ? {
    true => $tftpd['directory'],
    default => '/var/lib/tftpboot',
  }

  $windows_dir = has_key($tftpd, 'windows_directory') ? {
    true    => $tftpd['windows_directory'],
    default => '/windows',
  }

  $windows_config_dir = has_key($tftpd, 'windows_config_directory') ? {
    true    => $tftpd['windows_config_directory'],
    default => '',
  }

  $windows_domain = has_key($tftpd, 'windows_domain') ? {
    true    => $tftpd['windows_domain'],
    default => '',
  }

  pxe_install::parent_dirs { 'create tftpboot windows scripts dir':
    dir_path => "${tftpboot_dir}${windows_dir}/scripts",
  }

  pxe_install::parent_dirs { 'create tftpboot windows unattend dir':
    dir_path => "${tftpboot_dir}${windows_dir}/unattend",
  }

  $win_locale = has_key($defaults, 'win_locale') ? {
    true  => $defaults['win_locale'],
    false => 'en-US',
  }

  $win_input_locale = has_key($defaults, 'win_input_locale') ? {
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

  $machines.each |$hostname, $data| {

    pxe_install::kickstart { $hostname:
      data               => $data,
      kickstart_dir      => $kickstart_dir,
      kickstart_url      => $kickstart_url,
      repos_url          => $repos_url,
      scripturl          => $scripturl,
      dhcp_entry         => has_key($services, 'dhcpd'),
      tftp_entry         => has_key($services, 'tftpd'),
      puppetmaster       => $puppetmaster,
      challenge_password => $challenge_password,
      tftpboot_dir       => $tftpboot_dir,
      windows_dir        => $windows_dir,
      windows_config_dir => $windows_config_dir,
    }

  }

}
