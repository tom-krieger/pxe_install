# @summary
#    Download syslinux archive
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
#   class { 'pxe_install::syslinux':
#       tftpboot_dir => '/var/lib/tftpboot',
#   }
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
    path         => "/opt/pxe_install/${archive}.tar.gz",
    source       => "${pxe_install::syslinux_url}/${archive}.tar.gz",
    extract      => true,
    extract_path => '/opt/pxe_install/',
    creates      => "/opt/pxe_install/${archive}",
    cleanup      => true,
  }

  $pxe_install::params::syslinux_files.keys.each |$dir| {
    pxe_install::parent_dirs { "create tftpboot dir ${tftpboot_dir}${dir}":
      dir_path => "${tftpboot_dir}${dir}",
    }
  }

  $pxe_install::params::syslinux_files.each |$dir, $files| {
    $files.each |$dst, $src| {
      if $src =~ /^http/ {
        file { "${tftpboot_dir}${dir}/${dst}":
          ensure  => file,
          source  => $src,
          owner   => $owner,
          group   => $group,
          mode    => $mode,
          require => [Archive["${archive}.tar.gz"], File["${tftpboot_dir}${dir}"]],
        }
      } else {
        $cmd = "cp /opt/pxe_install/${archive}${src} ${tftpboot_dir}${dir}/${dst}"
        exec { "copying file ${dst}-${dir}":
          command => $cmd,                                        #lint:ignore:security_class_or_define_parameter_in_exec
          path    => ['/bin/', '/usr/bin'],
          unless  => "test -f ${tftpboot_dir}${dir}/${dst}",
          require => [Archive["${archive}.tar.gz"], File["${tftpboot_dir}${dir}"]],
        }
      }
    }
  }
}
