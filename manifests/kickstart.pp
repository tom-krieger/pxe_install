# @summary 
#    Create kickstart file
#
# Create a kickstart/preseed file with partitioning information, tftpboot entry and dhcp entry
#
# @param data
#    Hash with all kickstart data
#
# @param kickstart_dir
#    Directory where to store the kickstart files.
#
# @param kickstart_url
#    URL where to download the kickstart files.
#
# @param repos_url
#    URL where to download the packages
#
# @param scripturl
#    The URL where to download scripts
#
# @param dhcp_entry
#    Flag to configure DHCP
#
# @param tftp_entry
#    Flag to manage TFTP
#
# @example
#   pxe_install::kickstart { 'namevar': }
#
# @api private
define pxe_install::kickstart (
  Hash $data,
  String $kickstart_dir,
  String $kickstart_url,
  String $repos_url,
  String $scripturl,
  Boolean $dhcp_entry,
  Boolean $tftp_entry,
) {
  $hostname     = $title
  $parameter    = $data['parameter']
  $ensure       = $data['ensure']

  if has_key($data, 'ostype') {
    $ostype       = $data['ostype']
  } else {
    fail("Host ${hostname} has no ostype given!")
  }

  case $ostype.downcase() {
    'debian', 'ubuntu': {
      $lookupkey = 'debian'
    }
    'redhat', 'centos': {
      $lookupkey = 'redhat'
    }
    'windows': {
      $lookupkey = 'windows'
    }
    default: {
      fail("Unsupported os: ${ostype}. Only Debian, Ubuntu, redhat, CentOS and Windows are supported.")
    }
  }

  $defaults = $pxe_install::defaults

  if has_key($data, 'partitioning') {
    $partitioning = $data['partitioning']
  } elsif has_key($data, 'partitiontable') and has_key($pxe_install::defaults['partitioning'], $data['partitiontable']) {
    $partitioning = $defaults['partitioning'][$data['partitiontable']]
  } else {
    $partitioning = $defaults['partitioning'][$lookupkey]
  }

  if $ensure != 'present' and $ensure != 'absent' {
    fail("Host ${hostname} contains an invalid value for ensure: ${ensure}")
  }

  if has_key($data, 'network') {
    $network_data = $data['network']
  } else {
    fail("Host ${hostname} has no network configuration!")
  }

  if empty($partitioning) and $ostype.downcase != 'windows' {
    fail("Host ${hostname} has no or no valid partitioning information.")
  }

  if ! has_key($network_data, 'fixedaddress') {
    fail("A server needs an ip address. Parameter fixedaddress missing for ${hostname}")
  }

  if ! has_key($network_data, 'mac') {
    fail("A server needs a mac address for installation. ${hostname} has none!")
  }

  if ! has_key($data, 'osversion') and $ensure == 'present' and $ostype.downcase() == 'centos' {
    fail("Host ${hostname} needs an osversion!")
  }

  if has_key($data, 'user') {
    $user = $data['user']
  } elsif has_key($pxe_install::defaults, 'user') {
    $user = $pxe_install::defaults['user']
  } else {
    $user = {}
  }

  $kickstart_file = "${kickstart_dir}/${hostname}"

  concat { $kickstart_file:
    ensure => $ensure,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
  }

  if has_key($data, 'loghost') {
    $loghost = $data['loghost']
  } else {
    $loghost = $pxe_install::defaults['loghost']
  }

  if has_key($data, 'logport') {
    $logport = $data['logport']
  } else {
    $logport = $pxe_install::defaults['logport']
  }

  $bootdevice = has_key($data, 'bootdevice') ? {
    true    => $data['bootdevice'],
    default => 'default',
  }

  case $ostype.downcase() {
    'debian': {
      $template_start = 'pxe_install/debian/kickstart.epp'
      $template_finish = 'pxe_install/debian/kickstart-end.epp'
      $mirror = $pxe_install::debian_mirror
      $mirror_dir = $pxe_install::debian_mirror_dir
      $ksurl = "http://${pxe_install::repo_server}/kickstart/${hostname}"
      $installserverurl = ''

      pxe_install::partitioning::debian { $hostname:
        hostname       => $hostname,
        partitioning   => $partitioning,
        kickstart_file => $kickstart_file,
      }

    }
    'ubuntu': {
      $template_start = 'pxe_install/ubuntu/kickstart.epp'
      $template_partitioning = 'pxe_install/ubuntu/kickstart-partitioning.epp'
      $template_finish = 'pxe_install/ubuntu/kickstart-end.epp'
      $mirror = $pxe_install::ubuntu_mirror
      $mirror_dir = $pxe_install::ubuntu_mirror_dir
      $ksurl = "http://${pxe_install::repo_server}/kickstart/${hostname}"
      $installserverurl = ''

      pxe_install::partitioning::ubuntu { $hostname:
        hostname       => $hostname,
        partitioning   => $partitioning,
        kickstart_file => $kickstart_file,
      }

    }
    'windows': {
      # nothing to do yet
    }
    default: {
      $template_start = 'pxe_install/redhat/kickstart.epp'
      $template_finish = 'pxe_install/redhat/kickstart-end.epp'

      if has_key($pxe_install::centos_mirrors, $data['osversion']) {

        $mirror_data = $pxe_install::centos_mirrors[$data['osversion']]
        $mirror = $mirror_data['mirror']
        $mirror_dir = $mirror_data['mirror_dir']
        $ksurl = "http://${pxe_install::repo_server}/kickstart/${hostname}"
        $installserverurl = "${mirror}${mirror_dir}"

        pxe_install::partitioning::redhat { $hostname:
          hostname       => $hostname,
          partitioning   => $partitioning,
          kickstart_file => $kickstart_file,
        }

      } else {

      }
    }
  }

  $agent = has_key($parameter, 'agent') ? {
    true    => $parameter['agent'],
    default => 'y',
  }

  if has_key($network_data, 'domain') {
    $domain = $network_data['domain']
  } elsif $pxe_install::defaults['domain'] != '' {
    $domain = $pxe_install::defaults['domain']
  } else {
    fail("No domain for ${hostname} given and no default domain available!")
  }

  $rootpw = has_key($data, 'rootpw') ? {
    true    => $data['rootpw'],
    default => $pxe_install::defaults['rootpw']
  }

  $language = has_key($data, 'language') ? {
    true    => $data['language'],
    default => $pxe_install::defaults['language'],
  }

  $country = has_key($data, 'country') ? {
    true    => $data['country'],
    default => $pxe_install::defaults['country'],
  }

  $locale = has_key($data, 'locale') ? {
    true    => $data['locale'],
    default => $pxe_install::defaults['locale'],
  }

  $keyboard = has_key($data, 'keyboard') ? {
    true    => $data['keyboard'],
    default => $pxe_install::defaults['keyboard'],
  }

  $timezone = has_key($data, 'timezone') ? {
    true    => $data['timezone'],
    default => $pxe_install::defaults['timezone'],
  }

  $keymap = has_key($data, 'keymap') ? {
    true    => $data['keymap'],
    default => $pxe_install::defaults['keymap'],
  }

  $dns_data = has_key($network_data, 'dns') ? {
    true    => join($network_data['dns'], ','),
    default => join($pxe_install::defaults['dns'], ','),
  }

  $ks_fqdn = "${hostname}.${domain}"

  if $ostype.downcase != 'windows' {

    concat::fragment { "${hostname}-start":
      order   => 01,
      content => epp($template_start, {
        puppetenv        => $parameter['env'],
        puppetrole       => $parameter['role'],
        datacenter       => $parameter['dc'],
        language         => $language,
        country          => $country,
        locale           => $locale,
        keyboard         => $keyboard,
        ip               => $network_data['fixedaddress'],
        netmask          => $network_data['netmask'],
        gateway          => $network_data['gateway'],
        dnsservers       => $dns_data,
        hostname         => $hostname,
        rootpw           => $rootpw,
        timezone         => $timezone,
        mirror           => $mirror,
        mirror_dir       => $mirror_dir,
        loghost          => $loghost,
        ksdevice         => $network_data['ksdevice'],
        fqdn             => $ks_fqdn,
        lang             => $language,
        installserverurl => $installserverurl,
        reposerver       => $pxe_install::repo_server,
        agent            => $agent,
        kickstart_url    => $kickstart_url,
        repos_url        => $repos_url,
        scripturl        => $scripturl,
        user             => $user,
        osversion        => $data['osversion'],
      }),
      target  => $kickstart_file,
    }

    if($template_finish != '') {
      concat::fragment {"${hostname}-finish":
        order   => 999,
        content => epp($template_finish, {
          ip            => $network_data['fixedaddress'],
          fqdn          => "${title}.${domain}",
          hostname      => $title,
          reposerver    => $pxe_install::repo_server,
          reposerverip  => $pxe_install::repo_server_ip,
          agent         => $agent,
          kickstart_url => $kickstart_url,
          repos_url     => $repos_url,
          scripturl     => $scripturl,
          country       => $country,
          mirror        => $mirror,
          mirror_dir    => $mirror_dir,
          osversion     => $data['osversion'],
          bootdevice    => $bootdevice,
        }),
        target  => $kickstart_file,
      }
    }
  }

  if $ensure == 'present' and $dhcp_entry {
    $dhcp_base_data = {
      mac     => $network_data['mac'],
      ip      => $network_data['fixedaddress'],
      comment => "Kickstart dhcp entry for ${hostname}",
    }

    if has_key($network_data, 'filename') {

      $dhcp_file_data = {
        options => {
          'routers'   => $network_data['gateway'],
          'host-name' => $hostname,
          'filename'  => $network_data['filename'],
        },
      }

    } else {

      if $ostype.downcase() == 'windows' {

        $dhcp_file_data = {
          options => {
            'routers'   => $network_data['gateway'],
            'host-name' => $hostname,
            'filename'  => 'winpe.ipxe',
          },
        }

      } else {

        $dhcp_file_data = {
          options => {
            'routers'   => $network_data['gateway'],
            'host-name' => $hostname,
          },
        }

      }

    }

    $dhcp_data = merge($dhcp_base_data, $dhcp_file_data)

    dhcp::host { $hostname:
      * => $dhcp_data,
    }
  }

  $path = has_key($data, 'path') ? {
    true    => $data['path'],
    default => '',
  }

  $env = has_key($parameter, 'env') ? {
    true    => $parameter['env'],
    default =>'',
  }

  $role = has_key($parameter, 'role') ? {
    true    => $parameter['role'],
    default => '',
  }

  $datacenter = has_key($parameter, 'dc') ? {
    true    => $parameter['dc'],
    default => '',
  }

  if  $ostype.downcase() == 'centos' or
      $ostype.downcase() == 'redhat'
  {
    $osvers = has_key($data, 'osversion') ? {
      true  => $data['osversion'],
      false => '',
    }

    $ks = $osvers >= '8' ? {
      true  => 'inst.ks',
      false => 'ks',
    }

  } else {
    $ks = 'ks'
  }

  if $tftp_entry {

    pxe_install::tftp::host { $network_data['fixedaddress']:
      ensure     => $ensure,
      ostype     => $data['ostype'],
      prefix     => $network_data['prefix'],
      path       => $path,
      ksurl      => $ksurl,
      ksdevice   => $network_data['ksdevice'],
      puppetenv  => $env,
      puppetrole => $role,
      datacenter => $datacenter,
      locale     => $locale,
      keymap     => $keymap,
      loghost    => $loghost,
      logport    => $logport,
      ks         => $ks,
    }

  }
}
