# @summary 
#    Create directories recursivly
#
# Create all missing directories
#
# @param dir_path
#    The directories to be created.
#
# @example
#   pxe_installarent_dirs{ 'create script dir':
#    dir_path => '/var/www/scripts',
#  }
define pxe_install::parent_dirs (
  Stdlib::Unixpath $dir_path
) {
  if $dir_path =~ /\/$/ {
    $_dir_path = "${dir_path}test.conf"
  } else {
    $_dir_path = "${dir_path}/test.conf"
  }

  $dirs = $_dir_path[1,-1].dirname.split('/').reduce([]) |$memo, $subdir| {
    $_dir =  $memo.empty ? {
      true    => "/${subdir}",
      default => "${$memo[-1]}/${subdir}",
    }
    concat($memo, $_dir)
  }

  ensure_resource('file', $dirs, {
      ensure => directory,
  })
}
