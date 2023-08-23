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
# @param puppetmaster
#    The hostname of the puppet master.
#
# @param dhcp_entry
#    Flag to configure DHCP
#
# @param tftp_entry
#    Flag to manage TFTP
#
# @param challenge_password
#    The password for autosining agent CSRs.
#
# @param tftpboot_dir
#    Tftpboot directory
#
# @param windows_dir
#    Windows directory to use.
#
# @param windows_config_dir
#    Directory to write windows nodes configuration
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
  String $puppetmaster,
  Boolean $dhcp_entry,
  Boolean $tftp_entry,
  Sensitive[String] $challenge_password,
  Stdlib::Absolutepath $tftpboot_dir,
  String $windows_dir,
  String $windows_config_dir,
) {
  $hostname     = $title
  $parameter    = $data['parameter']
  $ensure       = $data['ensure']

  if pxe_install::hash_key($data, 'ostype') {
    $ostype       = $data['ostype']
  } else {
    fail("Host ${hostname} has no ostype given!")
  }

  case $ostype.downcase() {
    'debian': {
      $lookupkey = 'debian'
    }
    'ubuntu': {
      $_vers = pxe_install::hash_key($data, 'osversion') ? {
        false => '',
        true  => split($data['osversion'], '[.]')[0]
      }
      $lookupkey = empty($_vers) ? {
        true  => 'debian',
        false => "ubuntu${_vers})",
      }
    }
    'redhat', 'centos', 'alma', 'rocky': {
      $lookupkey = 'redhat'
    }
    'windows': {
      $lookupkey = 'windows'
    }
    'fedora': {
      $lookupkey = 'fedora'
    }
    default: {
      fail("Unsupported os: ${ostype}. Only Debian, Ubuntu, Redhat, CentOS, Alma, Rocky, Fedora and Windows are supported.")
    }
  }

  $defaults = $pxe_install::defaults

  if pxe_install::hash_key($data, 'partitioning') {
    $partitioning = $data['partitioning']
  } elsif pxe_install::hash_key($data, 'partitiontable') and pxe_install::hash_key($defaults['partitioning'], $data['partitiontable']) {
    $partitioning = $defaults['partitioning'][$data['partitiontable']]
  } else {
    $partitioning = $defaults['partitioning'][$lookupkey]
  }

  if $ensure != 'present' and $ensure != 'absent' {
    fail("Host ${hostname} contains an invalid value for ensure: ${ensure}")
  }

  if pxe_install::hash_key($data, 'network') {
    $network_data = $data['network']
  } else {
    fail("Host ${hostname} has no network configuration!")
  }

  if empty($partitioning) and $ostype.downcase != 'windows' {
    fail("Host ${hostname} has no or no valid partitioning information.")
  }

  unless pxe_install::hash_key($network_data, 'fixedaddress') {
    fail("A server needs an ip address. Parameter fixedaddress missing for ${hostname}")
  }

  unless pxe_install::hash_key($network_data, 'mac') {
    fail("A server needs a mac address for installation. ${hostname} has none!")
  }

  if  ! pxe_install::hash_key($data, 'osversion') and $ensure == 'present' and
  ($ostype.downcase() == 'alma' or $ostype.downcase() == 'rocky' or
  $ostype.downcase() == 'centos' or $ostype.downcase() == 'windows') {
    fail("Host ${hostname} needs an osversion!")
  }

  if ($ostype.downcase() == 'debian') and ($ensure == 'present') {
    $suite = pxe_install::hash_key($data, 'osversion') ? {
      true  => $data['osversion'],
      false => 'stable',
    }
  } else {
    $suite = ''
  }

  if pxe_install::hash_key($data, 'user') {
    $user = $data['user']
  } elsif pxe_install::hash_key($defaults, 'user') {
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

  if pxe_install::hash_key($data, 'loghost') {
    $loghost = $data['loghost']
  } else {
    $loghost = $defaults['loghost']
  }

  if pxe_install::hash_key($data, 'logport') {
    $logport = $data['logport']
  } else {
    $logport = $defaults['logport']
  }

  $bootdevice = pxe_install::hash_key($data, 'bootdevice') ? {
    true    => $data['bootdevice'],
    default => 'default',
  }

  $boot_architecture = pxe_install::hash_key($network_data, 'boot_architecture') ? {
    true    => $network_data['boot_architecture'],
    default => '',
  }

  unless pxe_install::hash_key($defaults, 'boot_scenarios') {
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

  $dns_data = pxe_install::hash_key($network_data, 'dns') ? {
    true    => join($network_data['dns'], ','),
    default => join($defaults['dns'], ','),
  }

  $dnslist = pxe_install::hash_key($network_data, 'dns') ? {
    true  => $network_data['dns'],
    false => $defaults['dns'],
  }

  if pxe_install::hash_key($network_data, 'domain') {
    $domain = $network_data['domain']
  } elsif $defaults['domain'] != '' {
    $domain = $defaults['domain']
  } else {
    fail("No domain for ${hostname} given and no default domain available!")
  }

  $locale = pxe_install::hash_key($data, 'locale') ? {
    true    => $data['locale'],
    default => $defaults['locale'],
  }

  $keyboard = pxe_install::hash_key($data, 'keyboard') ? {
    true    => $data['keyboard'],
    default => $defaults['keyboard'],
  }

  case $ostype.downcase() {
    'debian': {
      $template_start = 'pxe_install/debian/kickstart.epp'
      $template_finish = 'pxe_install/debian/kickstart-end.epp'
      $mirror_host = $pxe_install::mirrors['debian']['mirror_host']
      $mirror_uri = $pxe_install::mirrors['debian']['mirror_uri']
      $ksurl = "http://${pxe_install::repo_server}/kickstart/${hostname}"
      $installserverurl = ''

      pxe_install::partitioning::debian { $hostname:
        hostname          => $hostname,
        partitioning      => $partitioning,
        kickstart_file    => $kickstart_file,
        boot_architecture => $boot_architecture,
      }
    }
    'ubuntu': {
      $major = $data['osversion'] ? {
        undef   => '',
        default => split($data['osversion'], '[.]')[0],
      }

      if $major >= '22' {
        $template_start = 'pxe_install/ubuntu/22/kickstart.epp'
        $template_partitioning = 'pxe_install/22/ubuntu/kickstart-partitioning.epp'
        $template_finish = 'pxe_install/ubuntu/22/kickstart-end.epp'
        $mirror_host = $pxe_install::mirrors['ubuntu22']['mirror_host']
        $mirror_uri = $pxe_install::mirrors['ubuntu22']['mirror_uri']
        $mirror_ports_host = $pxe_install::mirrors['ubuntu22']['mirror_ports_host']
        $mirror_ports_uri = $pxe_install::mirrors['ubuntu22']['mirror_ports_uri']
      } else {
        $template_start = 'pxe_install/ubuntu/kickstart.epp'
        $template_partitioning = 'pxe_install/ubuntu/kickstart-partitioning.epp'
        $template_finish = 'pxe_install/ubuntu/kickstart-end.epp'
        $mirror_host = $pxe_install::mirrors['ubuntu']['mirror_host']
        $mirror_uri = $pxe_install::mirrors['ubuntu']['mirror_uri']
        $mirror_ports_host = ''
        $mirror_ports_uri = ''
      }
      $ksurl = "http://${pxe_install::repo_server}/kickstart/${hostname}"
      $installserverurl = ''

      pxe_install::partitioning::ubuntu { $hostname:
        hostname          => $hostname,
        partitioning      => $partitioning,
        kickstart_file    => $kickstart_file,
        boot_architecture => $boot_architecture,
        major             => $major,
      }
    }
    'fedora': {
      $template_start = 'pxe_install/fedora/kickstart.epp'
      $template_finish = 'pxe_install/fedora/kickstart-end.epp'

      if pxe_install::hash_key($pxe_install::mirrors['fedora'], $data['osversion']) {
        $mirror_host = $pxe_install::mirrors['fedora'][$data['osversion']]['mirror_host']
        $mirror_uri = $pxe_install::mirrors['fedora'][$data['osversion']]['mirror_uri']
        $ksurl = "http://${pxe_install::repo_server}/kickstart/${hostname}"
        $installserverurl = "${mirror_host}${mirror_uri}"

        pxe_install::partitioning::redhat { $hostname:
          hostname          => $hostname,
          partitioning      => $partitioning,
          kickstart_file    => $kickstart_file,
          boot_architecture => $boot_architecture,
        }
      } else {
        fail("No mirror defined for ${hostname} for Fedora ${data['osversion']}")
      }
    }
    'windows': {
      $mirror_host = $pxe_install::mirrors['windows']['mirror_host']
      $mirror_uri = $pxe_install::mirrors['windows']['mirror_uri']
      $ksurl = ''

      if pxe_install::hash_key($network_data, 'iso') {
        $iso = $network_data['iso']
      } elsif pxe_install::hash_key($defaults, 'isos') {
        $isos = $defaults['isos']

        if
        pxe_install::hash_key($isos, $ostype.downcase()) and
        pxe_install::hash_key($isos[$ostype.downcase()], $data['osversion']) {
          $iso = $isos[$ostype.downcase()][$data['osversion']]
        } else {
          $iso = ''
        }
      } else {
        $iso = ''
      }

      pxe_install::samba::host { $hostname:
        tftpboot_dir       => "${tftpboot_dir}${windows_dir}${windows_config_dir}",
        osversion          => $data['osversion'],
        iso                => $iso,
        boot_architecture  => $scenario_data['boot_architecture'],
        fixedaddress       => $network_data['fixedaddress'],
        macaddress         => $network_data['mac'],
        subnet             => $network_data['netmask'],
        gateway            => $network_data['gateway'],
        dns                => $network_data['dns'],
        puppetmaster       => $puppetmaster,
        puppetenv          => $parameter['env'],
        puppetrole         => $parameter['role'],
        datacenter         => $parameter['dc'],
        agent              => $parameter['agent'],
        challenge_password => $challenge_password,
      }

      pxe_install::samba::unattend { $hostname:
        boot             => $scenario_data['boot_architecture'],
        unattend_dir     => "${tftpboot_dir}${windows_dir}/unattend",
        osversion        => $data['osversion'],
        win_domain       => $domain,
        win_locale       => $locale,
        win_input_locale => $keyboard,
      }
    }
    'alma': {
      $template_start = 'pxe_install/redhat/kickstart.epp'
      $template_finish = 'pxe_install/redhat/kickstart-end.epp'

      if pxe_install::hash_key($pxe_install::mirrors['alma'], $data['osversion']) {
        $mirror_host = $pxe_install::mirrors['alma'][$data['osversion']]['mirror_host']
        $mirror_uri = $pxe_install::mirrors['alma'][$data['osversion']]['mirror_uri']
        $ksurl = "http://${pxe_install::repo_server}/kickstart/${hostname}"
        $installserverurl = "${mirror_host}${mirror_uri}"

        pxe_install::partitioning::redhat { $hostname:
          hostname          => $hostname,
          partitioning      => $partitioning,
          kickstart_file    => $kickstart_file,
          boot_architecture => $boot_architecture,
        }
      } else {
        fail("No mirror defined for ${hostname} for Alma Linux ${data['osversion']}")
      }
    }
    'rocky': {
      $template_start = 'pxe_install/redhat/kickstart.epp'
      $template_finish = 'pxe_install/redhat/kickstart-end.epp'

      if pxe_install::hash_key($pxe_install::mirrors['rocky'], $data['osversion']) {
        $mirror_host = $pxe_install::mirrors['rocky'][$data['osversion']]['mirror_host']
        $mirror_uri = $pxe_install::mirrors['rocky'][$data['osversion']]['mirror_uri']
        $ksurl = "http://${pxe_install::repo_server}/kickstart/${hostname}"
        $installserverurl = "${mirror_host}${mirror_uri}"

        pxe_install::partitioning::redhat { $hostname:
          hostname          => $hostname,
          partitioning      => $partitioning,
          kickstart_file    => $kickstart_file,
          boot_architecture => $boot_architecture,
        }
      } else {
        fail("No mirror defined for ${hostname} for CRocky LinuxentOS ${data['osversion']}")
      }
    }
    default: {
      $template_start = 'pxe_install/redhat/kickstart.epp'
      $template_finish = 'pxe_install/redhat/kickstart-end.epp'

      if pxe_install::hash_key($pxe_install::mirrors[$ostype.downcase()], $data['osversion']) {
        $mirror_host = $pxe_install::mirrors[$ostype.downcase()][$data['osversion']]['mirror_host']
        $mirror_uri = $pxe_install::mirrors[$ostype.downcase()][$data['osversion']]['mirror_uri']
        $ksurl = "http://${pxe_install::repo_server}/kickstart/${hostname}"
        $installserverurl = "${mirror_host}${mirror_uri}"

        pxe_install::partitioning::redhat { $hostname:
          hostname          => $hostname,
          partitioning      => $partitioning,
          kickstart_file    => $kickstart_file,
          boot_architecture => $boot_architecture,
        }
      } else {
        fail("No mirror defined for ${hostname} for ${$ostype} ${data['osversion']}")
      }
    }
  }

  $agent = pxe_install::hash_key($parameter, 'agent') ? {
    true    => $parameter['agent'],
    default => 'y',
  }

  $rootpw = pxe_install::hash_key($data, 'rootpw') ? {
    true    => $data['rootpw'],
    default => $defaults['rootpw']
  }

  $language = pxe_install::hash_key($data, 'language') ? {
    true    => $data['language'],
    default => $defaults['language'],
  }

  $country = pxe_install::hash_key($data, 'country') ? {
    true    => $data['country'],
    default => $defaults['country'],
  }

  $timezone = pxe_install::hash_key($data, 'timezone') ? {
    true    => $data['timezone'],
    default => $defaults['timezone'],
  }

  $keymap = pxe_install::hash_key($data, 'keymap') ? {
    true    => $data['keymap'],
    default => $defaults['keymap'],
  }

  $xconfig = pxe_install::hash_key($data, 'xconfig') ? {
    true  => 'xconfig',
    false => 'skipx',
  }

  $defaultdesktop = pxe_install::hash_key($data, 'defaultdesktop') ? {
    true  => $data['defaultdesktop'],
    false => 'GNOME',
  }

  $startxonboot = pxe_install::hash_key($data, 'startxonboot') ? {
    true  => true,
    false => false,
  }

  $rhcdn = pxe_install::hash_key($parameter, 'rhcdn') ? {
    true    => $parameter['rhcdn'],
    default => 'n',
  }

  $actkey = pxe_install::hash_key($parameter, 'actkey') ? {
    true  => $parameter['actkey'],
    false => '',
  }

  $orgid = pxe_install::hash_key($parameter, 'orgid') ? {
    true  => $parameter['orgid'],
    false => '',
  }

  $ks_fqdn = "${hostname}.${domain}"

  $bootproto = pxe_install::hash_key($network_data, 'bootproto') ? {
    true  => $network_data['bootproto'],
    false => 'dhcp',
  }

  $bootiso = pxe_install::hash_key($data, 'bootiso') ? {
    true  => $data['bootiso'],
    false => '',
  }

  if pxe_install::hash_key($data, 'packages') {
    $_packages = $data['packages']
  } else {
    $default_packages = pxe_install::hash_key($defaults, 'packages') ? {
      false => {},
      true  => $defaults['packages'],
    }

    $_packages = pxe_install::hash_key($default_packages, $ostype.downcase) ? {
      false => [],
      true  => $default_packages[$ostype.downcase],
    }
  }

  $packages = $ostype.downcase ? {
    'debian' => join($_packages, ' '),
    default => $_packages,
  }

  if $ostype.downcase != 'windows' {
    $_osversion = pxe_install::hash_key($data, 'osversion') ? {
      true   => $data['osversion'],
      false  => '',
    }

    concat::fragment { "${hostname}-start":
      order   => '01',
      content => epp($template_start, {
          puppetenv         => $parameter['env'],
          puppetrole        => $parameter['role'],
          datacenter        => $parameter['dc'],
          language          => $language,
          country           => $country,
          locale            => $locale,
          keyboard          => $keyboard,
          ip                => $network_data['fixedaddress'],
          netmask           => $network_data['netmask'],
          gateway           => $network_data['gateway'],
          bootproto         => $network_data['bootproto'],
          dnsservers        => $dns_data,
          dnslist           => $dnslist,
          hostname          => $hostname,
          rootpw            => $rootpw,
          timezone          => $timezone,
          mirror            => $mirror_host,
          mirror_dir        => $mirror_uri,
          mirror_ports      => $mirror_ports_host,
          mirror_ports_dir  => $mirror_ports_uri,
          loghost           => $loghost,
          ksdevice          => $network_data['ksdevice'],
          fqdn              => $ks_fqdn,
          lang              => $language,
          installserverurl  => $installserverurl,
          reposerver        => $pxe_install::repo_server,
          agent             => $agent,
          kickstart_url     => $kickstart_url,
          repos_url         => $repos_url,
          scripturl         => $scripturl,
          user              => $user,
          osversion         => $_osversion,
          xconfig           => $xconfig,
          defaultdesktop    => $defaultdesktop,
          startxonboot      => $startxonboot,
          packages          => $packages,
          rhcdn             => $rhcdn,
          orgid             => $orgid,
          actkey            => $actkey,
          boot_architecture => $boot_architecture,
          ostype            => $ostype.downcase(),
      }),
      target  => $kickstart_file,
    }

    if($template_finish != '') {
      concat::fragment { "${hostname}-finish":
        order   => 999,
        content => epp($template_finish, {
            ip                => $network_data['fixedaddress'],
            fqdn              => "${title}.${domain}",
            hostname          => $title,
            reposerver        => $pxe_install::repo_server,
            reposerverip      => $pxe_install::repo_server_ip,
            agent             => $agent,
            kickstart_url     => $kickstart_url,
            repos_url         => $repos_url,
            scripturl         => $scripturl,
            country           => $country,
            mirror            => $mirror_host,
            mirror_dir        => $mirror_uri,
            osversion         => $data['osversion'],
            bootdevice        => $bootdevice,
            packages          => $packages,
            boot_architecture => $boot_architecture,
            suite             => $suite,
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

    $dhcp_ipxe_filename_data = pxe_install::hash_key($network_data, 'ipxe_filename') ? {
      true    => {
        ipxe_filename => $network_data['ipxe_filename'],
      },
      default => {},
    }

    $dhcp_ipxe_bootstrap_data = pxe_install::hash_key($network_data, 'ipxe_bootstrap') ? {
      true    => {
        ipxe_bootstrap => $network_data['ipxe_bootstrap'],
      },
      default => {},
    }

    if pxe_install::hash_key($network_data, 'ipxe_bootstrap') and pxe_install::hash_key($network_data, 'ipxe_bootstrap') {
      $dhcp_file_data = {}
    } else {
      if pxe_install::hash_key($network_data, 'filename') {
        $dhcp_file_data = {
          filename  => $network_data['filename'],
        }
      } elsif pxe_install::hash_key($scenario_data, 'filename') {
        $dhcp_file_data = {
          filename => $scenario_data['filename'],
        }
      } else {
        $dhcp_file_data = {}
      }
    }

    $dhcp_host_data = merge($dhcp_base_data, $dhcp_file_data, $dhcp_ipxe_filename_data, $dhcp_ipxe_bootstrap_data)

    dhcp::host { $hostname:
      * => $dhcp_host_data,
    }
  }

  $path = pxe_install::hash_key($data, 'path') ? {
    true    => $data['path'],
    default => '',
  }

  $env = pxe_install::hash_key($parameter, 'env') ? {
    true    => $parameter['env'],
    default => '',
  }

  $role = pxe_install::hash_key($parameter, 'role') ? {
    true    => $parameter['role'],
    default => '',
  }

  $datacenter = pxe_install::hash_key($parameter, 'dc') ? {
    true    => $parameter['dc'],
    default => '',
  }

  $stage2 = pxe_install::hash_key($data, 'stage2') ? {
    true  => $data['stage2'],
    false => "${mirror_host}${mirror_uri}"
  }

  if $ostype.downcase() == 'centos' or
  $ostype.downcase() == 'redhat' or
  $ostype.downcase() == 'alma' or
  $ostype.downcase() == 'rocky' or
  $ostype.downcase() == 'fedora' or
  $ostype.downcase() == 'windows' {
    $osvers = pxe_install::hash_key($data, 'osversion') ? {
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
    $prefix = pxe_install::hash_key($network_data, 'prefix') ? {
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
      stage2        => $stage2,
      orgid         => $orgid,
      actkey        => $actkey,
      osversion     => $data['osversion'],
      bootiso       => $bootiso,
    }
  }
}
