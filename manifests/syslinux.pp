# @summary Download syslinux archive
#
# Download syslinux archive and distribute files into tftpboot 
#
# @param tftpboot_dir
#    Directory serving tftp requests
#
# @param create_tftpboot_dir
#    Create needed sub directory in the tftpboot directory.
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
#   include pxe_install::syslinux
#
# @api private
class pxe_install::syslinux (
  Stdlib::Absolutepath $tftpboot_dir,
  Boolean $create_tftpboot_dir          = false,
  String $owner                         = 'root',
  String $group                         = 'root',
  String $mode                          = '0755',
) {
  if $create_tftpboot_dir {

    ensure_resource('file', $tftpboot_dir, {
      ensure => directory,
      owner  => $owner,
      group  => $group,
      mode   => $mode,
    })

  }

  if $pxe_install::install_unzip {
    ensure_packages(['unzip'], {
      ensure => present,
    })
  }

  if $pxe_install::install_curl {
    ensure_packages(['curl'], {
      ensure => present,
    })
  }

  file { '/opt/pxe_install':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  $archive = "${pxe_install::syslinux_name}-${pxe_install::syslinux_version}"

  archive { "${archive}.tar.gz":
    path         => '/opt/pxe_install',
    source       => $pxe_install::syslinux_url,
    extract      => true,
    extract_path => '/opt/pxe_install/',
    creates      => "/opt/pxe_install/${archive}.tar.gz",
    cleanup      => true,
  }

  $pxe_install::syslinux_files.each |$dir, $files| {

    $files.each |$dst, $src| {

      if $src =~ /^http/ {

        file { "${tftpboot_dir}${dir}/${dst}":
          ensure => file,
          source => $src,
          owner  => $owner,
          group  => $group,
          mode   => $mode,
        }

      } else {

        exec { "copying file ${dst}-${dir}":
          command => "cp /tmp/${archive}${src} ${tftpboot_dir}${dir}/${dst}",
          path    => ['/bin/', '/usr/bin'],
          unless  => "$(test -f ${tftpboot_dir}${dir}/${dst})",
        }

      }
    }
  }
}
