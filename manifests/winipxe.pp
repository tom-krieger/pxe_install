# @summary
#    Install windows ipxe files
#
# Download and install Windows ipxe files
#
# @param tftpboot_dir
#    Directory serving tftp requests
#
# @param winpe_dir
#    Directory serving windows installs within the *tftpboot_dir*
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
#    class { 'pxe_install::winipxe'
#        tftpboot_dir => '/var/lib/tftpboot',
#         winpe_dir   => 'winpe',
#
# @api private
class pxe_install::winipxe (
  Stdlib::Absolutepath $tftpboot_dir,
  String $winpe_dir,
  String $owner                         = 'root',
  String $group                         = 'root',
  String $mode                          = '0755',
) {
  archive { "${tftpboot_dir}/ipxe.efi":
    ensure => present,
    source => $pxe_install::ipxefile,
    user   => $owner,
    group  => $group,
  }

  file { "${tftpboot_dir}/winpe.ipxe":
    ensure  => file,
    content => epp('pxe_install/windows/winpe.ipxe.epp', {
        dir => $winpe_dir,
    }),
    owner   => $owner,
    group   => $group,
    mode    => $mode,
  }
}
