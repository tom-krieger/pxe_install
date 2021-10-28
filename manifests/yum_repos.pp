# @summary 
#    Create yum repo files
#
# Create yum repo files from templates and configute them to internal package repositories.
#
# @param reposerver_uri
#    URI of the repo server to use
#
# @param install_dir
#    The directory to create the files
#
# @example
#   include pxe_install::yum_repos
#
# @api private
class pxe_install::yum_repos (
  String $reposerver_uri,
  String $install_dir,
) {
  file { $install_dir:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755'
  }

  file { "${install_dir}/7":
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755'
  }

  file { "${install_dir}/7/CentOS-Base.repo":
    ensure  => file,
    content => epp('pxe_install/yum_repos/7/CentOS-Base.repo.epp', {
      reposerver_uri => $reposerver_uri,
    }),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  file { "${install_dir}/7/CentOS-Debuginfo.repo":
    ensure  => file,
    content => epp('pxe_install/yum_repos/7/CentOS-Debuginfo.repo.epp', {
      reposerver_uri => $reposerver_uri,
    }),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  file { "${install_dir}/7/CentOS-fasttrack.repo":
    ensure  => file,
    content => epp('pxe_install/yum_repos/7/CentOS-fasttrack.repo.epp', {
      reposerver_uri => $reposerver_uri,
    }),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  file { "${install_dir}/7/epel.repo":
    ensure  => file,
    content => epp('pxe_install/yum_repos/7/epel.repo.epp', {
      reposerver_uri => $reposerver_uri,
    }),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }
}
