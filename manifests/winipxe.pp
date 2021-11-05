# @summary Install windows ipxe files
#
# Download and install Windows ipxe files
#
# @param tftpboot_dir
#    Directory serving tftp requests
#
# @param owner
#    The file/directory owner.
#
# @param group
#    The file/directory group.
#
# @param mode
#    The file/directory permissions.
#
# @example
#   include pxe_install::winipxe
#
# @api private
class pxe_install::winipxe (
  Stdlib::Absolutepath $tftpboot_dir,
  String $owner                         = 'root',
  String $group                         = 'root',
  String $mode                          = '0755',
) {
  file { "${tftpboot_dir}/ipexe.efi":
    ensure => file,
    source => $pxe_install::ipxefile,
    owner  => $owner,
    group  => $group,
    mode   => $mode,
  }

  file { "${tftpboot_dir}/winpw.ipxe":
    ensure => file,
    source => 'puppet:///modules/pxe_install/winpw.ipxe',
    owner  => $owner,
    group  => $group,
    mode   => $mode,
  }
}
