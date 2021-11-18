# @summary
#    Add a new of to tftpboot directory
#
# Upload a net installer source and distribute the files into the tftpboot directory.
#
# @param nodes
#    The target nodes
#
# @param os
#    The os to work on
#
# @param os_version
#    The os version
#
# @param netinstaller_url
#    The URL to donload the netinstaller file.
#
# @param tftp_basedir
#    The base directory on the tftp server to install to
#
# @param os_subversion
#    This parameter in needed for CentOS and Redhat. You can give a subversion line "u3".
#
plan pxe_install::add_new_os_netboot (
  TargetSpec $nodes,
  Enum['ubuntu', 'debian', 'centos'] $os,
  String $os_version,
  Stdlib::HTTPUrl $netinstaller_url,
  Stdlib::Absolutepath $tftp_basedir          = '/var/lib/tftpboot',
  Optional[String] $os_subversion             = '',
) {
  $ubuntu_vesions = ['18.04', '20.04', '22.04']
  $debian_versions = ['9', '10']
  $centos_versions = ['7', '8']

  case $os {
    'ubuntu': {
      unless $os_version in $ubuntu_vesions {
        fail('Ubuntu version not supported!')
      }
    }
    'debian': {
      unless $os_version in $debian_versions {
        fail('Debian version not supported')
      }
    }
    'centos': {
      unless $os_version in $centos_versions {
        fail('CentOS version not supported')
      }
    }
    default: {
      fail("unknown os ${os}!")
    }
  }

  get_targets($nodes).each |$target| {
    $target.apply_prep()
    $myfacts = facts($target)

    case $os {
      'debian', 'ubuntu': {
        $res = run_task('pxe_install::maintain_ubuntu_debian_netinstaller', $nodes,
                        '_catch_errors' => true,
                        'tftp_basedir' => $tftp_basedir,
                        'archive' => $netinstaller_url,
                        'os' => $os,
                        'os_version' => $os_version)
      }
      'centos': {
        $res = run_task('pxe_install::maintain_centos_netinstaller', $nodes,
                        '_catch_errors' => true,
                        'tftp_basedir' => $tftp_basedir,
                        'archive' => $netinstaller_url,
                        'os' => $os,
                        'os_version' => $os_version,
                        'os_subversion' => $os_subversion)
      }
      default: {
        fail("unknown os ${os}!")
      }
    }

    out::message($res)
  }
}
