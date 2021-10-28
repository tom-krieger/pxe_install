# @summary Default parameters
#
# A description of what this class does
#
# @example
#   include pxe_install::params
#
#@api private
class pxe_install::params {

  $defaults = {
    'rootpw' => '$6$pzoDeF70$KIpccvU4EZhii.Pb88xDawv.MBeNZhICVFnw7RahRl2OlZKbI8rcc0VGVVrsVejoyShgIhSz/Da6z36K6U.CZ/',
    'timezone' => 'Europe/Berlin',
    'keymap' => 'de',
    'language' => 'en',
    'country' => 'DE',
    'locale' => 'en_US.UTF-8',
    'loghost' => '127.0.0.1',
    'logport' => 514,
    'domain' => 'example.com',
    'pxefile' => 'pxelinux.0',
    'bootable' => false,
    'primary' => false,
    'dns' => ['127.0.0.1'],
    'user' => {
      'fullname' => 'Install user',
      'username' => 'instuser',
      'password' => '$5$hEdaHTTg$Txw0iJqo1yDLuY6AryedpMM4XlN1k94b1a8U4WwBvyD',
    },
    'partitioning' => {
      'debian' => {
        '/boot' => {
          'min'      => 1024,
          'prio'     => 1024,
          'max'      => 1024,
          'fstype'   => 'ext3',
          'primary'  => true,
          'bootable' => true,
          'label'    => 'boot',
          'method'   => 'format',
          'device'   => '/dev/sda',
          'order'    => 405,
        },
        'vgos' => {
          'min'      => 100,
          'prio'     => 1000,
          'max'      => 1000000000,
          'fstype'   => 'ext4',
          'primary'  => true,
          'bootable' => false,
          'method'   => 'lvm',
          'device'   => '/dev/sda',
          'vgname'   => 'vgos',
          'order'    => 406,
        },
        'swap' => {
          'min'      => 4096,
          'prio'     => 4096,
          'max'      => 4096,
          'fstype'   => 'linux-swap',
          'primary'  => false,
          'bootable' => false,
          'invg'     => 'vgos',
          'method'   => 'swap',
          'lvname'   => 'lvol_swap',
          'order'    => 407,
        },
        '/' => {
          'min'      => 4096,
          'prio'     => 4096,
          'max'      => 4096,
          'fstype'   => 'ext4',
          'invg'     => 'vgos',
          'lvname'   => 'lvol_root',
          'primary'  => false,
          'bootable' => false,
          'method'   => 'format',
          'label'    => 'root',
          'order'    => 408,
        },
        '/home' => {
          'min'      => 2048,
          'prio'     => 2048,
          'max'      => 2048,
          'fstype'   => 'ext4',
          'invg'     => 'vgos',
          'lvname'   => 'lvol_home',
          'primary'  => false,
          'bootable' => false,
          'method'   => 'format',
          'label'    => 'home',
          'order'    => 409,
        },
        '/var' => {
          'min'      => 10240,
          'prio'     => 10240,
          'max'      => 10240,
          'fstype'   => 'ext4',
          'invg'     => 'vgos',
          'lvname'   => 'lvol_var',
          'primary'  => false,
          'bootable' => false,
          'method'   => 'format',
          'label'    => 'var',
          'order'    => 410,
        },
        '/var/log' => {
          'min'      => 10240,
          'prio'     => 10240,
          'max'      => 10240,
          'fstype'   => 'ext4',
          'invg'     => 'vgos',
          'lvname'   => 'lvol_var_log',
          'primary'  => false,
          'bootable' => false,
          'method'   => 'format',
          'label'    => 'log',
          'order'    => 411,
        },
        '/var/log/audit' => {
          'min'      => 10240,
          'prio'     => 10240,
          'max'      => 10240,
          'fstype'   => 'ext4',
          'invg'     => 'vgos',
          'lvname'   => 'lvol_var_log_audit',
          'primary'  => false,
          'bootable' => false,
          'method'   => 'format',
          'label'    => 'audit',
          'order'    => 412,
        },
        '/usr' => {
          'min'      => 8192,
          'prio'     => 8192,
          'max'      => 8192,
          'fstype'   => 'ext4',
          'invg'     => 'vgos',
          'lvname'   => 'lvol_usr',
          'primary'  => false,
          'bootable' => false,
          'method'   => 'format',
          'label'    => 'usr',
          'order'    => 413,
        },
        '/tmp' => {
          'min'      => 2048,
          'prio'     => 2048,
          'max'      => 2048,
          'fstype'   => 'ext4',
          'invg'     => 'vgos',
          'lvname'   => 'lvol_tmp',
          'primary'  => false,
          'bootable' => false,
          'method'   => 'format',
          'label'    => 'tmp',
          'order'    => 414,
        },
        '/var/tmp' => {
          'min'      => 2048,
          'prio'     => 2048,
          'max'      => 2048,
          'fstype'   => 'ext4',
          'invg'     => 'vgos',
          'lvname'   => 'lvol_var_tmp',
          'primary'  => false,
          'bootable' => false,
          'method'   => 'format',
          'label'    => 'vartmp',
          'order'    => 415,
        },
      },
      'redhat' => {
        '/boot' => {
          'type'      => 'part',
          'fstype'    => 'ext3',
          'size'      => 1024,
          'primary'   => true,
          'ondisk'    => 'sda',
        },
        'pv.01' => {
          'type'      => 'pvol',
          'size'      => 1000,
          'grow'      => true,
          'primary'   => true,
          'ondisk'    => 'sda',
        },
        'vgos' => {
          'type'      => 'volgroup',
          'pvol'      => 'pv.01',
        },
        '/' => {
          'type'      => 'logvol',
          'vgname'    => 'vgos',
          'diskname'  => 'lvol_root',
          'size'      => 2048,
          'fstype'    => 'ext4',
        },
        '/tmp' => {
          'type'      => 'logvol',
          'vgname'    => 'vgos',
          'diskname'  => 'lvol_tmp',
          'size'      => 2048,
          'fstype'    => 'ext4',
        },
        '/var' => {
          'type'      => 'logvol',
          'vgname'    => 'vgos',
          'diskname'  => 'lvol_var',
          'size'      => 10240,
          'fstype'    => 'ext4',
        },
        '/var/log' => {
          'type'      => 'logvol',
          'vgname'    => 'vgos',
          'diskname'  => 'lvol_var_log',
          'size'      => 10240,
          'fstype'    => 'ext4',
        },
        '/var/log/audit' => {
          'type'      => 'logvol',
          'vgname'    => 'vgos',
          'diskname'  => 'lvol_var_log_audit',
          'size'      => 10240,
          'fstype'    => 'ext4',
        },
        '/var/tmp' => {
          'type'      => 'logvol',
          'vgname'    => 'vgos',
          'diskname'  => 'lvol_var_tmp',
          'size'      => 2048,
          'fstype'    => 'ext4',
        },
        '/usr' => {
          'type'      => 'logvol',
          'vgname'    => 'vgos',
          'diskname'  => 'lvol_usr',
          'size'      => 8192,
          'fstype'    => 'ext4',
        },
        '/home' => {
          'type'      => 'logvol',
          'vgname'    => 'vgos',
          'diskname'  => 'lvol_home',
          'size'      => 2048,
          'fstype'    => 'ext4',
        },
        'swap' => {
          'type'      => 'logvol',
          'vgname'    => 'vgos',
          'diskname'  => 'lvol_swap',
          'size'      => 4096,
        },
      },
    }
  }
}
