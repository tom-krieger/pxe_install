# @summary Setup ftp server
#
# Configure the tftp server
#
# @param tftp 
#    All tftp entries
#
# @example
#   include pxe_install::tftp
#
# @api private
class pxe_install::tftp (
  Hash $tftp,
) {
  $mapfile = '/etc/tftpd.map'

  unless pxe_install::hash_key($tftp, 'service') {
    fail('A tftp service is needed!')
  }

  $tftp_packages = pxe_install::hash_key($tftp, 'packages') ? {
    true => $tftp['packages'],
    default => 'tftpd'
  }

  $tftp_ensure = pxe_install::hash_key($tftp, 'packages_ensure') ? {
    true => $tftp['packages_ensure'],
    default => 'present'
  }

  ensure_packages($tftp_packages, {
      ensure => $tftp_ensure,
  })

  $srv_ensure = pxe_install::hash_key($tftp, 'service_ensure') ? {
    true    => $tftp['service_ensure'],
    default => 'stopped',
  }

  $srv_enable = pxe_install::hash_key($tftp, 'service_enable') ? {
    true    => $tftp['service_enable'],
    default => 'disable',
  }

  if pxe_install::hash_key($tftp, 'address') {
    $address = $tftp['address']
  } elsif fact('network4') != undef {
    $address = fact('network4')
  } elsif fact('ipaddress') != undef {
    $address = fact('ipaddress')
  } else {
    fail('No ip for tftp server given and no ip can be determined!')
  }

  unless pxe_install::hash_key($tftp, 'directory') {
    fail('No tftpboot directory given!')
  }

  $windows_dir = pxe_install::hash_key($tftp, 'windows_directory') ? {
    true    => $tftp['windows_directory'],
    default => '/windows',
  }

  pxe_install::parent_dirs { 'create windows directory':
    dir_path => "${tftp['directory']}${windows_dir}",
  }

  ensure_resource('service', [$tftp['service']], {
      ensure => $srv_ensure,
      enable => $srv_enable,
  })

  if $mapfile != '' {
    file { $mapfile:
      ensure => file,
      owner  => 'root',
      group  => 'root',
      mode   => '0644',
    }
  }

  case $facts['os']['family'].downcase() {
    'redhat': {
      $tftpfile = '/etc/xinetd.d/tftp'
      $template = 'tftp.epp'
    }
    'debian': {
      $tftpfile = '/etc/default/tftpd-hpa'
      $template = 'tftp.ubuntu.epp'
    }
    default: {
      $tftpfile = ''
    }
  }

  if ! empty($tftpfile) {
    file { $tftpfile:
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => epp("pxe_install/xinetd/${template}", {
          port          => $tftp['port'],
          user          => $tftp['user'],
          group         => $tftp['group'],
          tftpserverbin => $tftp['tftpserverbin'],
          tftpdirectory => $tftp['directory'],
          address       => $address,
          mapfile       => $mapfile,
      }),
      notify  => Service[$tftp['service']],
    }
  }

  $basedir = pxe_install::hash_key($tftp, 'directory') ? {
    true => $tftp['directory'],
    default => '/var/lib/tftpboot',
  }

  $pxedir = pxe_install::hash_key( $tftp, 'pxelinux') ? {
    true => $tftp['pxelinux'],
    default => 'pxelinux.cfg',
  }

  ensure_resource('file', [$basedir], {
      ensure => directory,
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
  })

  ensure_resource('file', ["${basedir}/${pxedir}"], {
      ensure       => directory,
      purge        => true,
      recurselimit => 1,
      recurse      => true,
      owner        => 'root',
      group        => 'root',
      mode         => '0755',
  })

  file { "${basedir}/${pxedir}/default":
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/pxe_install/tftp-default',
  }

  $manage_tftpboot = pxe_install::hash_key($tftp, 'manage_tftpboot') ? {
    true    => $tftp['manage_tftpboot'],
    default => false,
  }

  $winpe_dir = pxe_install::hash_key($tftp, 'winpe_dir') ? {
    true    => $tftp['winpe_dir'],
    default => 'winpe',
  }

  if $manage_tftpboot {
    class { 'pxe_install::syslinux':
      tftpboot_dir        => $basedir,
      create_tftpboot_dir => true,
    }

    class { 'pxe_install::winipxe':
      tftpboot_dir => $basedir,
      winpe_dir    => $winpe_dir,
    }
  }
}
