# @summary
#    Create a host entry for a Windows node
#
# Create a host entry for a Windows node on the Samba share
#
# @param tftpboot_dir
#    The directory to write the configuration file
#
# @param macaddress
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
# @param dns
#    An array with dns servers.
#
# @param puppetmaster
#    The hostname of the puppet master.
#
# @param puppetenv
#    The environment the puppet agant uses.
#
# @param puppetrole
#    The role the node should get.
#
# @param datacenter
#    The datacenter the host is located in.
#
# @param agent
#    Accepts 'y' or 'n' and controls if the puppet agant is installed.
#
# @param [String] foreman
#    Accepts 'y' or 'n' and controls if Foreman is used as master.
#
# @param challenge_password
#    The challenge password (eyaml encrypted) for auto signing the CSR.
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
  String $puppetmaster,
  String $puppetenv,
  String $puppetrole,
  String $datacenter,
  String $agent,
  String $foreman,
  Optional[Sensitive[String]] $challenge_password = undef,
  Optional[String] $iso                           = undef,
  String $owner                                   = 'root',
  String $group                                   = 'root',
  String $mode                                    = '0644',
) {
  $mac_string = join(split($macaddress, '[:]'), '').upcase
  $dns_servers = "\"${join($dns, '","')}\""

  $_iso = $iso ? {
    undef   => '',
    default => $iso,
  }

  file { "${tftpboot_dir}/${mac_string}.cfg":
    ensure  => file,
    content => epp('pxe_install/windows/bootconfig.epp', {
        osversion          => $osversion,
        hostname           => $title,
        iso                => $_iso,
        boot_architecture  => $boot_architecture,
        fixedaddress       => $fixedaddress,
        subnet             => $subnet,
        gateway            => $gateway,
        dns_servers        => $dns_servers,
        puppetmaster       => $puppetmaster,
        agent              => $agent,
        foreman            => $foreman,
        puppetenv          => $puppetenv,
        datacenter         => $datacenter,
        puppetrole         => $puppetrole,
        challenge_password => $challenge_password,
    }),
    owner   => $owner,
    group   => $group,
    mode    => $mode,
  }
}
