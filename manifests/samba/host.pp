# @summary Create a host entry for a Windoes node
#
# Create a host entry for a Windows node on the Samba share
#
# @param tftpboot_dir
#    The directory to write the configuration file
#
# @param maccaddress
#    The mac address of the host
#
# @param osversion
#    The osversion of the host, e. g. 2019
#
# @param boot_architecture
#    The boot architecture to use. Must be defined in the defaults.
#
# @param fixedaddress
#    The IP address of the host
#
# @param subnet 
#    The subnet the host lives in
#
# @param gateway
#    The default gateway to use.
#
# @apram dns
#    An array with dns servers.
#
# @param iso
#    An ISO image to use.
#
# @param owner
#    The file owner.
#
# @param group
#    The group of the file.
#
# @param mode
#     The file permissions.
#
# @example
#   pxe_install::samba::host { 'namevar': }
#
# @api private
define pxe_install::samba::host (
  Stdlib::Absolutepath $tftpboot_dir,
  Stdlib::MAC $macaddress,
  String $osversion,
  String $boot_architecture,
  Stdlib::IP::Address::Nosubnet $fixedaddress,
  Stdlib::IP::Address::Nosubnet $subnet,
  Stdlib::IP::Address::Nosubnet $gateway,
  Array[Stdlib::IP::Address::Nosubnet] $dns,
  Optional[String] $iso                           = '',
  String $owner                                   = 'root',
  String $group                                   = 'root',
  String $mode                                    = '0644',
) {
  $mac_string = join(split($macaddress, '[:]'), '')
  $dns_servers = "\"${join($dns, ',')}\""

  file { "${tftpboot_dir}/${mac_string}.cfg":
    ensure  => file,
    content => epp('pxe_install/windows/bootconfig.epp', {
      osversion         => $osversion,
      hostname          => $title,
      iso               => $iso,
      boot_architecture => $boot_architecture,
      fixedaddress      => $fixedaddress,
      subnet            => $subnet,
      gateway           => $gateway,
      dns_servers       => $dns_servers
    }),
    owner   => $owner,
    group   => $group,
    mode    => $mode,
  }
}