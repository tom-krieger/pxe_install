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
# @param debian_mirror
#    The Debian mirror host
#
# @param debian_mirror_dir
#    The uri to use on the Debain mirror.
#
# @param ubuntu_mirror
#    The Ubuntu mirror host
#
# @param ubuntu_mirror_dir
#    The uri to use on the Ubuntu mirror.
#
# @param centos_mirrors
#    hash with CentOS mirror hosts and directories
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
#    Document root for the webserver
#
# @param create_aliases
#    Create webserver aliases
#
# @param configure_repos
#    Configure repositories on install server
#
# @param sync_repos
#    hash containing all repos to be synced to the internal package repositories.
#
# @param configure_sync_scripts
#    If repository sync scripts should be installed and configured.
#
# @param challenge_password
#    Sensitive challenge password for auto signing cert requests.
#
# @param add_hosts_entries
#    Add install server and puppet server to /etc/hosts file.
#
# @param install_resolv_conf
#    Install a prepared resolv.conf file on the fresh installed system.
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
  Optional[String] $puppetmaster              = '',
  Optional[String] $puppetmasterip            = '',
  Optional[String] $debian_mirror             = '',
  Optional[String] $debian_mirror_dir         = '/debian',
  Optional[String] $ubuntu_mirror             = '',
  Optional[String] $ubuntu_mirror_dir         = '/ubuntu',
  Optional[Hash] $centos_mirrors              = {},
  Optional[Hash] $services                    = {},
  Optional[Hash] $machines                    = {},
  Optional[Array] $status_allow_from          = ['127.0.0.1'],
  Optional[Boolean] $enabled                  = true,
  Optional[String] $ssl_cert                  = '/etc/pki/httpd/repos.example.com/repos.example.com.cer',
  Optional[String] $ssl_key                   = '/etc/pki/httpd/repos.example.com/repos.example.com.key',
  Optional[String] $ssl_chain                 = '/etc/pki/httpd/repos.example.com/fullchain.cer',
  Optional[String] $ssl_certs_dir             = '/etc/pki/httpd/repos.example.com/',
  Optional[String] $documentroot              = '/var/www/html',
  Optional[Boolean] $create_aliases           = true,
  Optional[Boolean] $configure_repos          = true,
  Optional[Boolean] $configure_sync_scripts   = false,
  Optional[Boolean] $add_hosts_entries        = false,
  Optional[Boolean] $install_resolv_conf      = false,
  Optional[Hash] $sync_repos                  = {
    centos7 => true,
    centos8 => true,
    epel7   => true,
    epel8   => true,
  },
  Optional[Hash] $defaults                    = $pxe_install::params::defaults,
) inherits pxe_install::params {

  pxe_install::parent_dirs{ 'create script dir':
    dir_path => dirname($scriptdir),
  }

  pxe_install::parent_dirs { 'create kickstart dirs':
    dir_path => $kickstart_dir,
  }

  pxe_install::parent_dirs { 'create document root dir':
    dir_path => $documentroot,
  }

  file { $scriptdir:
    ensure       => directory,
    source       => 'puppet:///modules/pxe_install/install',
    recurse      => true,
    recurselimit => 3,
    purge        => true,
    owner        => 'root',
    group        => 'root',
    mode         => '0644',
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
      installserver       => $installserver,
      installserverip     => $installserverip,
      puppetmaster        => $puppetmaster,
      puppetmasterip      => $puppetmasterip,
      kickstart_url       => $kickstart_url,
      repos_url           => $repos_url,
      scripturl           => $scripturl,
      reposerver          => $repo_server,
      reposerverip        => $repo_server_ip,
      challenge_password  => $challenge_password,
      add_hosts_entries   => $add_hosts_entries,
      install_resolv_conf => $install_resolv_conf,
      configure_repos     => $configure_repos,
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

  $machines.each |$hostname, $data| {

    pxe_install::kickstart { $hostname:
      data          => $data,
      kickstart_dir => $kickstart_dir,
      kickstart_url => $kickstart_url,
      repos_url     => $repos_url,
      scripturl     => $scripturl,
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

  if $configure_repos {

    $reposerver_uri = "https://${repo_server}/centos"
    class { 'pxe_install::yum_repos':
      reposerver_uri => $reposerver_uri,
      install_dir    => "${scriptdir}/yum-repos",
    }

  }

  if $configure_sync_scripts {

    $repodir = "${repos_dir}/centos"
    file { '/usr/local/sbin/sync_epel_7':
      ensure  => file,
      content => epp('pxe_install/scripts/adsEpelSync7.epp', {
        repodir => $repodir,
      }),
      owner   => 'root',
      group   => 'root',
      mode    => '0700',
    }

    file { '/usr/local/sbin/sync_epel_8':
      ensure  => file,
      content => epp('pxe_install/scripts/adsEpelSync8.epp', {
        repodir => $repodir,
      }),
      owner   => 'root',
      group   => 'root',
      mode    => '0700',
    }

    file { '/usr/local/sbin/sync_centos_7':
      ensure  => file,
      content => epp('pxe_install/scripts/adsRepoSyncCentos7.epp', {
        repodir => $repodir,
      }),
      owner   => 'root',
      group   => 'root',
      mode    => '0700',
    }

    file { '/usr/local/sbin/sync_centos_8':
      ensure  => file,
      content => epp('pxe_install/scripts/adsRepoSyncCentos8.epp', {
        repodir => $repodir,
      }),
      owner   => 'root',
      group   => 'root',
      mode    => '0700',
    }

    ensure_resource('file', '/root/cron', {
      ensure => directory,
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
    })

    file { '/root/cron/reposync':
      ensure  => file,
      content => epp('pxe_install/scripts/reposync.epp', {
        sync_repos => $sync_repos,
      }),
      owner   => 'root',
      group   => 'root',
      mode    => '0700',
    }

    file { '/etc/cron.d/reposync.cron':
      ensure  => file,
      content => epp('pxe_install/scripts/reposync.cron.epp', {}),
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
    }
  }
}
