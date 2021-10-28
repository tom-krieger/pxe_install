# @summary Create a tftp server entry for a host.
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
#     The path where the boot-screens for Debian and Ubuntu are found, relative
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
# @example
#   pxe_install::tftp::host { 'namevar': }
#
# @api private
define pxe_install::tftp::host (
  String $ostype,
  Enum['absent', 'present'] $ensure,
  Optional[String] $prefix     = '',
  Optional[String] $path       = '',
  Optional[String] $ksurl      = '',
  Optional[String] $ksdevice   = '',
  Optional[String] $puppetenv  = 'none',
  Optional[String] $puppetrole = 'none',
  Optional[String] $datacenter = 'none',
  Optional[String] $locale     = 'en_US',
  Optional[String] $keymap     = '',
  Optional[String] $loghost    = '',
  Optional[Integer] $logport   = 0,
  Optional[String] $ks         = '',
) {

  $octets = split($title, /\./)
  $hex = sprintf('%<a>02x%<b>02x%<c>02x%<d>02x', {
    'a' => $octets[0],
    'b' => $octets[1],
    'c' => $octets[2],
    'd' => $octets[3],
  }).upcase()

  $basedir = has_key($pxe_install::tftp::tftp, 'directory') ? {
    true => $pxe_install::tftp::tftp['directory'],
    default => '/var/lib/tftpboot',
  }

  $pxedir = has_key( $pxe_install::tftp::tftp, 'pxelinux') ? {
    true =>  $pxe_install::tftp::tftp['pxelinux'],
    default => 'pxelinux.cfg',
  }

  $filename = "${basedir}/${pxedir}/${hex}"
  $file_data = {
    'ensure' => $ensure,
    'owner'  => 'root',
    'group'  => 'root',
    'mode'   => '0644',
  }

  $_path = $path ? {
    '' =>  "${prefix}/boot-screens",
    default => $path,
  }

  case $ostype.downcase() {
    'debian': {
      if ($loghost == '' or $logport == 0) {
        fail('Debian and Ubuntu kickstart require a log host and a log port!')
      }
      file { $filename:
        content => epp('pxe_install/debian/tftp-entry.epp', {
          path       => $_path,
          prefix     => $prefix,
          ksurl      => $ksurl,
          locale     => $locale,
          keymap     => $keymap,
          loghost    => $loghost,
          logport    => $logport,
          ksdevice   => $ksdevice,
          puppetenv  => $puppetenv,
          puppetrole => $puppetrole,
          datacenter => $datacenter,
        }),
        *       => $file_data,
      }
    }
    'ubuntu': {
      if ($loghost == '' or $logport == 0) {
        fail('Debian and Ubuntu kickstart require a log host and a log port!')
      }
      file { $filename:
        content => epp('pxe_install/ubuntu/tftp-entry.epp', {
          path       => $_path,
          prefix     => $prefix,
          ksurl      => $ksurl,
          locale     => $locale,
          keymap     => $keymap,
          loghost    => $loghost,
          logport    => $logport,
          ksdevice   => $ksdevice,
          puppetenv  => $puppetenv,
          puppetrole => $puppetrole,
          datacenter => $datacenter,
        }),
        *       => $file_data,
      }
    }
    default: {
      # RedHat/CentOS
      file { $filename:
        content => epp('pxe_install/redhat/tftp-entry.epp', {
          prefix     => $prefix,
          ksurl      => $ksurl,
          ksdevice   => $ksdevice,
          puppetenv  => $puppetenv,
          puppetrole => $puppetrole,
          datacenter => $datacenter,
          ks         => $ks,
        }),
        *       => $file_data,
      }
    }
  }

}
