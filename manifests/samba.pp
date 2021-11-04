# @summary 
#    Set up Samba server for Windows PXE installation
#
# Install and configure a Samba server and a share for Windows unattended installations.
#
# @example
#   include pxe_install::samba
class pxe_install::samba (
  Hash $samba = {},
) {
  if has_key($samba, 'realm') {
    $realm = $samba['realm']
  } else {
    fail('No realm given!')
  }

  if has_key($samba, 'domain') {
    $domain = $samba['domain']
  } else {
    fail('No domain given!')
  }

  if has_key($samba, 'smbname') {
    $smbname = $samba['smbname']
  } else {
    fail('No smbname given!')
  }

  $join_domain = has_key($samba, 'join_domain') ? {
    true    => $samba['join_domain'],
    default => false,
  }

  $adminuser = has_key($samba, 'adminuser') ? {
    true    => $samba['adminuser'],
    default => 'administrator',
  }

  $adminpassword = has_key($samba, 'adminpassword') ? {
    true    => $samba['adminpassword'],
    default => undef,
  }

  $sambaloglevel = has_key($samba, 'sambaloglevel') ? {
    true    => $samba['sambaloglevel'],
    default => 3,
  }

  $logtosyslog = has_key($samba, 'logtosyslog') ? {
    true    => $samba['logtosyslog'],
    default => true,
  }

  $krbconf = has_key($samba, 'krbconf') ? {
    true    => $samba['krbconf'],
    default => false,
  }

  $sambaclassloglevel = has_key($samba, 'sambaclassloglevel') ? {
    true    => $samba['sambaclassloglevel'],
    default => {
      'printdrivers' => 1,
      'idmap'        => 5,
      'winbind'      => 3,
    },
  }

  $security = has_key($samba, 'security') ? {
    true    => $samba['security'],
    default => 'ADS',
  }

  $nsswitch = has_key($samba, 'nsswitch') ? {
    true    => $samba['nsswitch'],
    default => false,
  }

  $shares = has_key($samba, 'shares') ? {
    true    => $samba['shares'],
    default => {},
  }

  if $adminpassword == undef {
    $samba_data = {
      domain             => $domain,
      realm              => $realm,
      smbname            => $smbname,
      logtosyslog        => $logtosyslog,
      sambaloglevel      => $sambaloglevel,
      sambaclassloglevel => $sambaclassloglevel,
      security           => $security,
      nsswitch           => $nsswitch,
    }
  } else {
    $samba_data = {
      domain             => $domain,
      realm              => $realm,
      smbname            => $smbname,
      logtosyslog        => $logtosyslog,
      sambaloglevel      => $sambaloglevel,
      sambaclassloglevel => $sambaclassloglevel,
      adminuser          => $adminuser,
      adminpassword      => unwrap($adminpassword),
      security           => $security,
      nsswitch           => $nsswitch,
    }
  }

  class { 'samba::params':
    sernetpkgs => false,
  }

  class { 'samba::classic':
    * => $samba_data,
  }

  $shares.each |$share, $data| {

    ::samba::share { $share:
      * => $data,
    }
  }
}
