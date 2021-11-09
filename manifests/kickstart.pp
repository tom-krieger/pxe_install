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
      fail("Unsupported os: ${ostype}. Only Debian, Ubuntu, Redhat, CentOS and Windows are supported.")
    }
  }

  $defaults = $pxe_install::defaults

  if has_key($data, 'partitioning') {
    $partitioning = $data['partitioning']
  } elsif has_key($data, 'partitiontable') and has_key($defaults['partitioning'], $data['partitiontable']) {
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

  unless has_key($network_data, 'fixedaddress') {
    fail("A server needs an ip address. Parameter fixedaddress missing for ${hostname}")
  }

  unless has_key($network_data, 'mac') {
    fail("A server needs a mac address for installation. ${hostname} has none!")
  }

  if ! has_key($data, 'osversion') and $ensure == 'present' and ($ostype.downcase() == 'centos' or $ostype.downcase() == 'windows') {
    fail("Host ${hostname} needs an osversion!")
  }

  if has_key($data, 'user') {
    $user = $data['user']
  } elsif has_key($defaults, 'user') {
    $user = $defaults['user']
  } else {
    $user = {}
  }

  $kickstart_file = "${kickstart_dir}/${hostname}"

  if $ostype.downcase() != 'windows' {
    concat { $kickstart_file:
      ensure => $ensure,
      owner  => 'root',
      group  => 'root',
      mode   => '0644',
    }
  }

  if has_key($data, 'loghost') {
    $loghost = $data['loghost']
  } else {
    $loghost = $defaults['loghost']
  }

  if has_key($data, 'logport') {
    $logport = $data['logport']
  } else {
    $logport = $defaults['logport']
  }

  $bootdevice = has_key($data, 'bootdevice') ? {
    true    => $data['bootdevice'],
    default => 'default',
  }

  $basedir = has_key($pxe_install::tftp::tftp, 'directory') ? {
    true => $pxe_install::tftp::tftp['directory'],
    default => '/var/lib/tftpboot',
  }

  $windows_dir = has_key($pxe_install::tftp::tftp, 'windows_directory') ? {
    true    => $pxe_install::tftp::tftp['windows_directory'],
    default => '/windows',
  }

  $iso = has_key($network_data, 'iso') ? {
    true    => $network_data['iso'],
    default => '',
  }

  $boot_architecture = has_key($network_data, 'boot_architecture') ? {
    true    => $network_data['boot_architecture'],
    default => '',
  }

  unless has_key($defaults, 'boot_scenarios') {
    fail('Boot scenario configuration is missing in defaults configuration.')
  }

  case $boot_architecture {
    'bios': {
      $scenario_data = $defaults['boot_scenarios']['bios']
    }
    'uefi': {
      if $ostype.downcase() == 'windows' {
        $scenario_data = $defaults['boot_scenarios']['ipxe']
      } else {
        $scenario_data = $defaults['boot_scenarios']['efi64']
      }
    }
    default: {
      $scenario_data = {}

      if $ostype.downcase() == 'windows' {
        fail("Host ${hostname} needs a valid boot_architecture for installing Windows! '${boot_architecture}' is not supported.")
      }
    }
  }

  $dns_data = has_key($network_data, 'dns') ? {
    true    => join($network_data['dns'], ','),
    default => join($defaults['dns'], ','),
  }

  case $ostype.downcase() {
    'debian': {
      $template_start = 'pxe_install/debian/kickstart.epp'
      $template_finish = 'pxe_install/debian/kickstart-end.epp'
      $mirror_kost = $pxe_install::mirrors['debian']['mirror_host']
      $mirror_uri = $pxe_install::mirrors['debian']['mirror_uri']
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
      $mirror_host = $pxe_install::mirrors['ubuntu']['mirror_host']
      $mirror_uri = $pxe_install::mirrors['ubuntu']['mirror_uri']
      $ksurl = "http://${pxe_install::repo_server}/kickstart/${hostname}"
      $installserverurl = ''

      pxe_install::partitioning::ubuntu { $hostname:
        hostname       => $hostname,
        partitioning   => $partitioning,
        kickstart_file => $kickstart_file,
      }

    }
    'windows': {
      $mirror_host = $pxe_install::mirrors['windows']['mirror_host']
      $mirror_uri = $pxe_install::mirrors['windows']['mirror_uri']
      $ksurl = ''

      pxe_install::samba::host { $hostname:
        tftpboot_dir      => "${basedir}${windows_dir}",
        osversion         => $data['osversion'],
        iso               => $iso,
        boot_architecture => $scenario_data['boot_architecture'],
        fixedaddress      => $network_data['fixedaddress'],
        macaddress        => $network_data['mac'],
        subnet            => $network_data['netmask'],
        gateway           => $network_data['gateway'],
        dns               => $network_data['dns'],
      }
    }
    default: {
      $template_start = 'pxe_install/redhat/kickstart.epp'
      $template_finish = 'pxe_install/redhat/kickstart-end.epp'

      if has_key($pxe_install::mirrors['centos'], $data['osversion']) {

        $mirror_host = $pxe_install::mirrors['centos'][$data['osversion']]['mirror_host']
        $mirror_uri = $pxe_install::mirrors['centos'][$data['osversion']]['mirror_uri']
        $ksurl = "http://${pxe_install::repo_server}/kickstart/${hostname}"
        $installserverurl = "${mirror_host}${mirror_uri}"

        pxe_install::partitioning::redhat { $hostname:
          hostname       => $hostname,
          partitioning   => $partitioning,
          kickstart_file => $kickstart_file,
        }

      } else {
        fail("No mirror defined for ${hostname} for CentOS ${data['osversion']}")
      }
    }
  }

  $agent = has_key($parameter, 'agent') ? {
    true    => $parameter['agent'],
    default => 'y',
  }

  if has_key($network_data, 'domain') {
    $domain = $network_data['domain']
  } elsif $defaults['domain'] != '' {
    $domain = $defaults['domain']
  } else {
    fail("No domain for ${hostname} given and no default domain available!")
  }

  $rootpw = has_key($data, 'rootpw') ? {
    true    => $data['rootpw'],
    default => $defaults['rootpw']
  }

  $language = has_key($data, 'language') ? {
    true    => $data['language'],
    default => $defaults['language'],
  }

  $country = has_key($data, 'country') ? {
    true    => $data['country'],
    default => $defaults['country'],
  }

  $locale = has_key($data, 'locale') ? {
    true    => $data['locale'],
    default => $defaults['locale'],
  }

  $keyboard = has_key($data, 'keyboard') ? {
    true    => $data['keyboard'],
    default => $defaults['keyboard'],
  }

  $timezone = has_key($data, 'timezone') ? {
    true    => $data['timezone'],
    default => $defaults['timezone'],
  }

  $keymap = has_key($data, 'keymap') ? {
    true    => $data['keymap'],
    default => $defaults['keymap'],
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
        mirror           => $mirror_host,
        mirror_dir       => $mirror_uri,
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
          mirror        => $mirror_host,
          mirror_dir    => $mirror_uri,
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
      options => {
        routers   => $network_data['gateway'],
        host-name => $hostname,
      },
    }

    if has_key($network_data, 'filename') {

      $dhcp_file_data = {
        filename  => $network_data['filename'],
      }

    } elsif has_key($scenario_data, 'filename') {

      $dhcp_file_data = {
        filename => $scenario_data['filename'],
      }

    } else {

      $dhcp_file_data = {}

    }

    $dhcp_ipxe_filename_data = has_key($network_data, 'ipxe_filename') ? {
      true    => {
        ipxe_filename => $network_data['ipxe_filename'],
      },
      default => {},
    }

    $dhcp_ipxe_bootstrap_data = has_key($network_data, 'ipxe_bootstrap') ? {
      true    => {
        ipxe_bootstrap => $network_data['ipxe_bootstrap'],
      },
      default => {},
    }

    $dhcp_host_data = merge($dhcp_base_data, $dhcp_file_data, $dhcp_ipxe_filename_data, $dhcp_ipxe_bootstrap_data)

    dhcp::host { $hostname:
      * => $dhcp_host_data,
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
      $ostype.downcase() == 'redhat' or
      $ostype.downcase() == 'windows'
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

    $prefix = has_key($network_data, 'prefix') ? {
      true    => $network_data['prefix'],
      default => '',
    }

    pxe_install::tftp::host { $network_data['fixedaddress']:
      ensure        => $ensure,
      ostype        => $ostype,
      prefix        => $prefix,
      path          => $path,
      ksurl         => $ksurl,
      ksdevice      => $network_data['ksdevice'],
      puppetenv     => $env,
      puppetrole    => $role,
      datacenter    => $datacenter,
      locale        => $locale,
      keymap        => $keymap,
      loghost       => $loghost,
      logport       => $logport,
      ks            => $ks,
      mirror_host   => $mirror_host,
      mirror_uri    => $mirror_uri,
      scenario_data => $scenario_data,
    }

  }
}
