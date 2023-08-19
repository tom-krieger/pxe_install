# @summary
#    Create a tftp server entry for a host.
#
# Create a tft server entry from template.
#
# @param ostype
#    The OS type like redHat, CentOS, Debian, Ubuntu
#
# @param ensure
#    TFTP entry should be present or absent
#
# @param prefix
#     The path within the tftp directory, relative to that directory.
#     Example: centos/7/u9
#
# @param path
#     The path where the boot-screens for Debian, Ubuntu and Windows are found, relative
#     to the tftboot dirctory, e. g. ubuntu/18.04/amd64/boot-screens
#     path is not needed with RedHat and CentOS.
#
# @param ksurl
#    The URL where to download the kickstart/preseed file
#
# @param ksdevice
#    The network device to use for kickstarting, e. g. eth0
#
# @param puppetenv
#    The Puppet environment tro configure the agent into.
#
# @param puppetrole
#   The role for the server. Will be put into trusted facts.
#
# @param datacenter
#    The datacenter the host runs in. Will be put into trusted facts for 
#    later datacenter specific configurations within Hiera.
#
# @param locale
#    The locate setting for the installer. Needed only for Debian and Ubuntu.
#
# @param keymap
#    The keyboard mapping to use, e. g. de. Used for install.
#
# @param loghost
#    Log syslog messages during install to that host.
#
# @param logport
#    The port the syslog server is listening on.
#
# @param ks
#    CentOS/RedHat  7 and 8 have different ways to give kickstart informsation. 
#
# @param mirror_host
#    The mirror host.
#
# @param mirror_uri
#    The URI to use.
#
# @param scenario_data
#    Data describing the install scenario.
#
# @param stage2
#    Stage 2 parameter for Fedora installations used in TFTP boot configuration.
#
# @param orgid
#    Redhat organization id.
#
# @param actkey
#    Redhat activationkey.
#
# @param osversion
#    Version of the operatimg system
#
# @example
#   pxe_install::tftp::host { 'namevar': }
#
# @api private
define pxe_install::tftp::host (
  String $ostype,
  Enum['absent', 'present'] $ensure,
  Optional[String] $prefix      = undef,
  Optional[String] $path        = undef,
  Optional[String] $ksurl       = undef,
  Optional[String] $ksdevice    = undef,
  String $puppetenv             = 'none',
  String $puppetrole            = 'none',
  String $datacenter            = 'none',
  String $locale                = 'en_US',
  Optional[String] $keymap      = undef,
  Optional[String] $loghost     = undef,
  Integer $logport              = 0,
  Optional[String] $ks          = undef,
  Optional[String] $mirror_host = undef,
  Optional[String] $mirror_uri  = undef,
  Optional[Hash] $scenario_data = undef,
  Optional[String] $stage2      = undef,
  Optional[String] $orgid       = undef,
  Optional[String] $actkey      = undef,
  Optional[String] $osversion   = undef,
) {
  $_mirror_host = $mirror_host ? {
    undef   => '',
    default => $mirror_host,
  }

  $_mirror_uri = $mirror_uri ? {
    undef   => '',
    default => $mirror_uri,
  }

  $_scenario_data = $scenario_data ? {
    undef   => {},
    default => $scenario_data,
  }

  if  $ostype.downcase() == 'windows' and
  ($_mirror_host == '' or $_mirror_uri == '') {
    fail('A Windows node needs a mirror_host and a mirror_uri to create a TFTP entry!')
  }

  $octets = split($title, /\./)
  $hex = sprintf('%<a>02x%<b>02x%<c>02x%<d>02x', {
      'a' => $octets[0],
      'b' => $octets[1],
      'c' => $octets[2],
      'd' => $octets[3],
  }).upcase()

  $basedir = pxe_install::hash_key($pxe_install::tftp::tftp, 'directory') ? {
    true => $pxe_install::tftp::tftp['directory'],
    default => '/var/lib/tftpboot',
  }

  $pxedir = pxe_install::hash_key( $pxe_install::tftp::tftp, 'pxelinux') ? {
    true => $pxe_install::tftp::tftp['pxelinux'],
    default => 'pxelinux.cfg',
  }

  $filename = "${basedir}/${pxedir}/${hex}"
  $uefi_filename = "${basedir}/grub/${title}"
  $file_data = {
    'ensure' => $ensure,
    'owner'  => 'root',
    'group'  => 'root',
    'mode'   => '0644',
  }

  $_prefix = $prefix ? {
    undef   => '',
    default => $prefix,
  }

  $_path = $path ? {
    '' => "${_prefix}/boot-screens",
    'none'=> '',
    default => $path,
  }

  $_ksurl = $ksurl ? {
    undef   => '',
    default => $ksurl,
  }

  $_ksdevice = $ksdevice ? {
    undef   => '',
    default => $ksdevice,
  }

  $_keymap = $keymap ? {
    undef   => '',
    default => $keymap,
  }

  $_loghost = $loghost ? {
    undef   => '',
    default => $loghost,
  }

  $_ks = $ks ? {
    undef   => '',
    default => $ks,
  }

  $_stage2 = $stage2 ? {
    undef   => '',
    default => $stage2,
  }

  $_orgid = $orgid ? {
    undef   => '',
    default => $orgid,
  }

  $_actkey = $actkey ? {
    undef   => '',
    default => $actkey,
  }

  $_osversion = $osversion ? {
    undef   => '',
    default => $osversion,
  }

  case $ostype.downcase() {
    'debian': {
      if ($_loghost == '' or $logport == 0) {
        fail('Debian and Ubuntu kickstart require a log host and a log port!')
      }

      if $_scenario_data['boot_architecture'] == 'uefi' {
        $template = 'pxe_install/debian/tftp-uefi-entry.epp'
        $_filename = $uefi_filename
      } else {
        $template = 'pxe_install/debian/tftp-entry.epp'
        $_filename = $filename
      }

      file { $_filename:
        content => epp($template, {
            path        => $_path,
            prefix      => $_prefix,
            ksurl       => $_ksurl,
            locale      => $locale,
            keymap      => $_keymap,
            loghost     => $_loghost,
            logport     => $logport,
            ksdevice    => $_ksdevice,
            puppetenv   => $puppetenv,
            puppetrole  => $puppetrole,
            datacenter  => $datacenter,
            mirror_host => $_mirror_host,
            mirror_uri  => $_mirror_uri,
        }),
        *       => $file_data,
      }
    }
    'ubuntu': {
      if ($_loghost == '' or $logport == 0) {
        fail('Debian and Ubuntu kickstart require a log host and a log port!')
      }

      $major = $osversion ? {
        undef   => '20',
        default => split($osversion, '[.]')[0]
      }

      $_part = $major >= '22' ? {
        true  => 'pxe_install/ubuntu/22',
        false => 'pxe_install/ubuntu',
      }

      if $_scenario_data['boot_architecture'] == 'uefi' {
        $template = "${_part}/tftp-uefi-entry.epp"
        $_filename = $uefi_filename
      } else {
        $template = "${_part}/tftp-entry.epp"
        $_filename = $filename
      }

      file { $_filename:
        content => epp($template, {
            path        => $_path,
            prefix      => $_prefix,
            ksurl       => $_ksurl,
            locale      => $locale,
            keymap      => $_keymap,
            loghost     => $_loghost,
            logport     => $logport,
            ksdevice    => $_ksdevice,
            puppetenv   => $puppetenv,
            puppetrole  => $puppetrole,
            datacenter  => $datacenter,
            mirror_host => $_mirror_host,
            mirror_uri  => $_mirror_uri,
        }),
        *       => $file_data,
      }
    }
    'windows': {
      file { $filename:
        content => epp('pxe_install/windows/tftp-entry.epp', {
            path        => $_path,
            mirror_host => $_mirror_host,
            mirror_uri  => $_mirror_uri,
        }),
        *       => $file_data,
      }
    }
    'fedora': {
      #Fedora
      file { $filename:
        content => epp('pxe_install/fedora/tftp-entry.epp', {
            prefix      => $_prefix,
            ksurl       => $_ksurl,
            ksdevice    => $_ksdevice,
            puppetenv   => $puppetenv,
            puppetrole  => $puppetrole,
            datacenter  => $datacenter,
            ks          => $_ks,
            mirror_host => $_mirror_host,
            mirror_uri  => $_mirror_uri,
            stage2      => $_stage2,
        }),
        *       => $file_data,
      }
    }
    default: {
      # RedHat/CentOS

      if $_scenario_data['boot_architecture'] == 'uefi' {
        $template = 'pxe_install/redhat/tftp-uefi-entry.epp'
        $_filename = $uefi_filename
      } else {
        $template = 'pxe_install/redhat/tftp-entry.epp'
        $_filename = $filename
      }

      file { $_filename:
        content => epp($template, {
            prefix      => $_prefix,
            ksurl       => $_ksurl,
            ksdevice    => $_ksdevice,
            puppetenv   => $puppetenv,
            puppetrole  => $puppetrole,
            datacenter  => $datacenter,
            ks          => $_ks,
            mirror_host => $_mirror_host,
            mirror_uri  => $_mirror_uri,
            orgid       => $_orgid,
            actkey      => $_actkey,
            osversion   => $_osversion,
            ostype      => $ostype,
            stage2      => $_stage2,
        }),
        *       => $file_data,
      }
    }
  }
}
