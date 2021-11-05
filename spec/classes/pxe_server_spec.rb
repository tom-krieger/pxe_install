require 'spec_helper'
require 'pp'

describe 'pxe_install' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) do
        os_facts.merge!(
          'samba_version' => '4.3.0',
        )
      end

      it {
        is_expected.to compile

        if ENV['DEBUG']
          pp catalogue.resources
        end

        is_expected.to contain_class('pxe_install::params')

        is_expected.to contain_pxe_install__parent_dirs('create script dir')
          .with(
            'dir_path' => '/export/repos/pub',
          )

        is_expected.to contain_pxe_install__parent_dirs('create kickstart dirs')
          .with(
            'dir_path' => '/export/repos/kickstart',
          )

        is_expected.to contain_pxe_install__parent_dirs('create document root dir')
          .with(
            'dir_path' => '/export/repos/www',
          )

        is_expected.to contain_file('/export')
          .with(
            'ensure'  => 'directory',
          )

        is_expected.to contain_file('/export/repos')
          .with(
            'ensure'  => 'directory',
          )

        is_expected.to contain_file('/export/repos/pub')
          .with(
            'ensure'  => 'directory',
          )

        is_expected.to contain_file('/export/repos/www')
          .with(
            'ensure'  => 'directory',
          )

        is_expected.to contain_file('/export/repos/kickstart')
          .with(
            'ensure'  => 'directory',
          )

        is_expected.to contain_file('/export/repos/pub/debian-post.sh')
          .with(
            'ensure'  => 'file',
            'owner'   => 'root',
            'group'   => 'root',
            'mode'    => '0644',
          )

        is_expected.to contain_file('/export/repos/pub/ubuntu-post.sh')
          .with(
            'ensure'  => 'file',
            'owner'   => 'root',
            'group'   => 'root',
            'mode'    => '0644',
          )

        is_expected.to contain_file('/export/repos/pub/redhat-post.sh')
          .with(
            'ensure'  => 'file',
            'owner'   => 'root',
            'group'   => 'root',
            'mode'    => '0644',
          )

        is_expected.to contain_class('pxe_install::dhcp')
          .with(
            'dhcp' => {
              'interfaces' => ['eth0'],
              'omapiport' => 7911,
              'default_lease_time' => 43_200,
              'max_lease_time' => 86_400,
              'ddns_update_style' => 'none',
              'domain_names' => ['localdomain'],
              'dns_servers' => ['10.0.0.62', '10.0.0.63'],
              'ntp_servers' => ['none'],
              'next_server' => '10.0.0.2',
              'logfacility' => 'local7',
              'option_code150_label' => 'pxegrub',
              'option_code150_value' => 'text',
              'default_filename' => 'pxelinux.0',
              'hosts' => {
                'test' => {
                  'mac' => '00:11:22:33:44:55',
                  'ip' => '10.0.0.99',
                  'max_lease_time' => 86_400,
                },
              },
              'pools' => {
                'internal' => {
                  'network' => '10.0.0.0',
                  'mask' => '255.255.255.0',
                  'range' => ['10.0.0.180 10.0.0.199'],
                  'gateway' => '10.0.0.12',
                },
              },
            },
          )

        is_expected.to contain_class('pxe_install::tftp')
          .with(
            'tftp' => {
              'manage_tftpboot' => true,
              'packages' => ['tftp-server', 'xinetd'],
              'packages_ensure' => 'installed',
              'port' => 69,
              'user' => 'root',
              'group' => 'root',
              'directory' => '/var/lib/tftpboot',
              'pxelinux' => 'pxelinux.cfg',
              'address' => '10.0.0.2',
              'tftpserverbin' => '/usr/sbin/in.tftpd',
              'service' => 'xinetd',
              'service_ensure' => 'running',
              'service_enable' => true
            },
          )

        is_expected.to contain_class('pxe_install::apache')
          .with(
            'kickstart_dir'     => '/export/repos/kickstart',
            'kickstart_url'     => '/kickstart',
            'pub_dir'           => '/export/repos/pub',
            'pub_url'           => '/pub',
            'repos_dir'         => '/var/repos',
            'repos_url'         => '/repos',
            'servername'        => 'repos.localdomain',
            'status_allow_from' => ['10.0.0.108/32', '10.0.0.109/32', '10.0.0.63/32', '10.0.0.62/32', '10.0.8.0/24', '127.0.0.1'],
            'ssl_cert'          => '/etc/pki/httpd/localdomain.de/localdomain.de.cer',
            'ssl_key'           => '/etc/pki/httpd/localdomain.de/localdomain.de.key',
            'ssl_chain'         => '/etc/pki/httpd/localdomain.de/fullchain.cer',
            'ssl_certs_dir'     => '/etc/pki/httpd/localdomain.de/',
            'documentroot'      => '/export/repos/www',
            'create_aliases'    => true,
          )

        is_expected.to contain_file('/etc/pki/httpd')
          .with(
            'ensure' => 'directory',
            'owner'  => 'root',
            'group'  => 'root',
            'mode'   => '0755',
          )

        is_expected.to contain_file('/etc/pki/httpd/repos.localdomain')
          .with(
            'ensure' => 'directory',
            'owner'  => 'root',
            'group'  => 'root',
            'mode'   => '0755',
          )

        is_expected.to contain_apache__vhost('repos.localdomain ssl')
          .with(
            'port'                 => 443,
            'ssl'                  => true,
            'ssl_cipher'           => '"EECDH+ECDSA+AESGCM EECDH+aRSA+AESGCM EECDH+ECDSA+SHA384 EECDH+ECDSA+SHA256 EECDH+aRSA+SHA384 '\
                                      'EECDH+aRSA+SHA256 EECDH+aRSA+RC4 EECDH EDH+aRSA RC4 !aNULL !eNULL !LOW !3DES !MD5 !EXP !PSK !SRP !DSS !RC4"',
            'ssl_protocol'         => 'TLSv1.2',
            'ssl_honorcipherorder' => 'on',
            'ssl_options'          => ['+StdEnvVars'],
            'ssl_cert'             => '/etc/pki/httpd/localdomain.de/localdomain.de.cer',
            'ssl_key'              => '/etc/pki/httpd/localdomain.de/localdomain.de.key',
            'ssl_chain'            => '/etc/pki/httpd/localdomain.de/fullchain.cer',
            'ssl_certs_dir'        => '/etc/pki/httpd/localdomain.de/',
            'docroot'              => '/export/repos/www',
            'servername'           => 'repos.localdomain',
            'access_log_format'    => 'combined',
            'aliases'              => [
              {
                'alias' => '/kickstart',
                'path'  => '/export/repos/kickstart',
              },
              {
                'alias' => '/pub',
                'path'  => '/export/repos/pub',
              },
              {
                'alias' => '/repos',
                'path'  => '/var/repos',
              },
            ],
          )

        is_expected.to contain_apache__vhost('repos.localdomain')
          .with(
            'port'              => 80,
            'docroot'           => '/export/repos/www',
            'servername'        => 'repos.localdomain',
            'access_log_format' => 'combined',
            'aliases'           => [
              {
                'alias' => '/kickstart',
                'path'  => '/export/repos/kickstart',
              },
              {
                'alias' => '/pub',
                'path'  => '/export/repos/pub',
              },
              {
                'alias' => '/repos',
                'path'  => '/var/repos',
              },
            ],
          )

        is_expected.to contain_class('apache')
          .with(
            'default_vhost'    => false,
            'server_tokens'    => 'Prod',
            'server_signature' => 'Off',
            'trace_enable'     => 'Off',
          )

        is_expected.to contain_class('apache::mod::ssl')

        is_expected.to contain_class('apache::mod::status')
          .with(
            'allow_from' => ['10.0.0.108/32', '10.0.0.109/32', '10.0.0.63/32', '10.0.0.62/32', '10.0.8.0/24', '127.0.0.1'],
          )

        is_expected.to contain_class('apache::mod::info')
          .with(
            'allow_from' => ['10.0.0.108/32', '10.0.0.109/32', '10.0.0.63/32', '10.0.0.62/32', '10.0.8.0/24', '127.0.0.1'],
          )

        is_expected.to contain_dhcp__host('ct01')
          .with(
            'mac' => '08:00:27:77:A4:40',
            'ip' => '10.0.0.66',
            'options' => {
              'routers'   => '10.0.0.4',
              'host-name' => 'ct01',
              'filename' => '/tftpboot/test.0',
            },
            'comment' => 'Kickstart dhcp entry for ct01',
          )

        is_expected.to contain_dhcp__host('ct03')
          .with(
            'mac' => '00:11:22:33:44:77',
            'ip' => '10.0.0.32',
            'options' => {
              'routers'   => '10.0.0.4',
              'host-name' => 'ct03',
            },
            'comment' => 'Kickstart dhcp entry for ct03',
          )

        is_expected.to contain_dhcp__host('test')
          .with(
            'mac' => '00:11:22:33:44:55',
            'ip' => '10.0.0.99',
            'max_lease_time' => 86_400,
          )

        is_expected.to contain_dhcp__pool('internal')
          .with(
            'network' => '10.0.0.0',
            'mask' => '255.255.255.0',
            'range' => ['10.0.0.180 10.0.0.199'],
            'gateway' => '10.0.0.12',
          )

        is_expected.to contain_pxe_install__kickstart('ct01')
          .with(
            'data' => {
              'ensure' => 'present',
              'network' => {
                'mac' => '08:00:27:77:A4:40',
                'prefix' => 'centos/7/u9',
                'fixedaddress' => '10.0.0.66',
                'ksdevice' => 'eth0',
                'gateway' => '10.0.0.4',
                'netmask' => '255.255.255.0',
                'dns' => ['10.0.0.62'],
                'filename' => '/tftpboot/test.0',
              },
              'ostype' => 'CentOS',
              'osversion' => '7',
              'keyboard' => 'de-latin1-nodeadkeys',
              'keymap' => 'de',
              'parameter' => {
                'env' => 'production',
                'role' => 'test',
                'dc' => 'test',
                'agent' => 'y',
              },
            },
            'kickstart_dir' => '/export/repos/kickstart',
            'kickstart_url' => '/kickstart',
            'repos_url'     => '/repos',
            'scripturl'     => '/pub',
          )

        is_expected.to contain_pxe_install__kickstart('ct02')
          .with(
            'data'          => {
              'ensure' => 'absent',
              'network' => {
                'mac' => '00:11:22:33:44:66',
                'prefix' => 'ubuntu/18.04/amd64',
                'fixedaddress' => '10.0.0.68',
                'ksdevice' => 'eth0',
                'gateway' => '10.0.0.4',
                'netmask' => '255.255.255.0',
                'dns' => ['10.0.0.62'],
                'uefi' => true,
              },
              'ostype' => 'ubuntu',
              'parameter' => {
                'env' => 'production',
                'role' => 'test',
                'dc' => 'test',
                'agent' => 'n',
              },
            },
            'kickstart_dir' => '/export/repos/kickstart',
            'kickstart_url' => '/kickstart',
            'repos_url'     => '/repos',
            'scripturl'     => '/pub',
          )

        is_expected.to contain_pxe_install__kickstart('ct03')
          .with(
            'data'          => {
              'ensure' => 'present',
              'network' => {
                'mac' => '00:11:22:33:44:77',
                'prefix' => 'ubuntu/18.04/amd64',
                'fixedaddress' => '10.0.0.32',
                'ksdevice' => 'eth0',
                'gateway' => '10.0.0.4',
                'netmask' => '255.255.255.0',
                'dns' => ['10.0.0.62', '10.0.0.63', '10.0.0.25'],
              },
              'ostype' => 'ubuntu',
              'parameter' => {
                'env' => 'production',
                'role' => 'test',
                'dc' => 'test',
                'agent' => 'y',
              },
              'user' => {
                'fullname' => 'Tom test',
                'username' => 'tester',
                'password' => '$5$h....',
              },
            },
            'kickstart_dir' => '/export/repos/kickstart',
            'kickstart_url' => '/kickstart',
            'repos_url'     => '/repos',
            'scripturl'     => '/pub',
          )

        is_expected.to contain_pxe_install__tftp__host('10.0.0.32')
          .with(
            'ensure'     => 'present',
            'ostype'     => 'ubuntu',
            'prefix'     => 'ubuntu/18.04/amd64',
            'path'       => '',
            'ksurl'      => 'http://repos.localdomain/kickstart/ct03',
            'ksdevice'   => 'eth0',
            'puppetenv'  => 'production',
            'puppetrole' => 'test',
            'datacenter' => 'test',
            'locale'     => 'en_US.UTF-8',
            'keymap'     => 'de',
            'loghost'    => '10.0.0.25',
            'logport'    => 514,
            'ks'         => 'ks',
          )

        is_expected.to contain_pxe_install__tftp__host('10.0.0.66')
          .with(
            'ensure'     => 'present',
            'ostype'     => 'CentOS',
            'prefix'     => 'centos/7/u9',
            'path'       => '',
            'ksurl'      => 'http://repos.localdomain/kickstart/ct01',
            'ksdevice'   => 'eth0',
            'puppetenv'  => 'production',
            'puppetrole' => 'test',
            'datacenter' => 'test',
            'locale'     => 'en_US.UTF-8',
            'keymap'     => 'de',
            'loghost'    => '10.0.0.25',
            'logport'    => 514,
            'ks'         => 'ks',
          )

        is_expected.to contain_pxe_install__tftp__host('10.0.0.68')
          .with(
            'ensure'     => 'absent',
            'ostype'     => 'ubuntu',
            'prefix'     => 'ubuntu/18.04/amd64',
            'path'       => '',
            'ksurl'      => 'http://repos.localdomain/kickstart/ct02',
            'ksdevice'   => 'eth0',
            'puppetenv'  => 'production',
            'puppetrole' => 'test',
            'datacenter' => 'test',
            'locale'     => 'en_US.UTF-8',
            'keymap'     => 'de',
            'loghost'    => '10.0.0.25',
            'logport'    => 514,
            'ks'         => 'ks',
          )

        is_expected.to contain_file('/var/lib/tftpboot')
          .with(
            'ensure'       => 'directory',
            'owner'        => 'root',
            'group'        => 'root',
            'mode'         => '0755',
          )

        is_expected.to contain_file('/var/lib/tftpboot/pxelinux.cfg')
          .with(
            'ensure'       => 'directory',
            'owner'        => 'root',
            'group'        => 'root',
            'mode'         => '0755',
            'purge'        => true,
            'recurselimit' => 1,
            'recurse'      => true,
          )

        is_expected.to contain_file('/var/lib/tftpboot/pxelinux.0')
          .with(
            'ensure' => 'file',
            'owner'  => 'root',
            'group'  => 'root',
            'mode'   => '0644',
          )

        is_expected.to contain_file('/var/lib/tftpboot/pxelinux.cfg/0A000020')
          .with(
            'ensure' => 'present',
            'owner'  => 'root',
            'group'  => 'root',
            'mode'   => '0644',
          )
        is_expected.to contain_file('/var/lib/tftpboot/pxelinux.cfg/0A000042')
          .with(
            'ensure' => 'present',
            'owner'  => 'root',
            'group'  => 'root',
            'mode'   => '0644',
          )

        is_expected.to contain_file('/var/lib/tftpboot/pxelinux.cfg/0A000044')
          .with(
            'ensure' => 'absent',
            'owner'  => 'root',
            'group'  => 'root',
            'mode'   => '0644',
          )

        is_expected.to contain_file('/var/lib/tftpboot/pxelinux.cfg/default')
          .with(
            'ensure' => 'file',
            'owner'  => 'root',
            'group'  => 'root',
            'mode'   => '0644',
          )

        # Archive[syslinux-6.03]
        is_expected.to contain_archive('syslinux-6.03.tar.gz')
          .with(
            'path'         => '/opt/pxe_install/syslinux-6.03.tar.gz',
            'source'       => 'https://www.kernel.org/pub/linux/utils/boot/syslinux/syslinux-6.03.tar.gz',
            'extract'      => true,
            'extract_path' => '/opt/pxe_install/',
            'creates'      => '/opt/pxe_install/syslinux-6.03.tar.gz',
            'cleanup'      => true,
          )
        # Class[Pxe_install::Syslinux]
        is_expected.to contain_class('pxe_install::syslinux')
          .with(
            'tftpboot_dir'        => '/var/lib/tftpboot',
            'create_tftpboot_dir' => true,
          )
        # Class[Pxe_install::Winipxe]
        is_expected.to contain_class('pxe_install::winipxe')
          .with(
            'tftpboot_dir'        => '/var/lib/tftpboot',
          )
        # Exec[copying file pxelinux.0-/]
        is_expected.to contain_exec('copying file pxelinux.0-/')
          .with(
            'command' => 'cp /opt/pxe_install/syslinux-6.03/bios/core/pxelinux.0 /var/lib/tftpboot//pxelinux.0',
            'path'    => ['/bin/', '/usr/bin'],
            'unless'  => 'test -f /var/lib/tftpboot//pxelinux.0',
          )
        # Exec[copying file bootx64.efi-/]
        is_expected.to contain_exec('copying file bootx64.efi-/')
          .with(
            'command' => 'cp /opt/pxe_install/syslinux-6.03/efi64/efi/syslinux.efi /var/lib/tftpboot//bootx64.efi',
            'path'    => ['/bin/', '/usr/bin'],
            'unless'  => 'test -f /var/lib/tftpboot//bootx64.efi',
          )
        # Exec[copying file ldlinux.c32-/]
        is_expected.to contain_exec('copying file ldlinux.c32-/')
          .with(
            'command' => 'cp /opt/pxe_install/syslinux-6.03/bios/com32/elflink/ldlinux/ldlinux.c32 /var/lib/tftpboot//ldlinux.c32',
            'path'    => ['/bin/', '/usr/bin'],
            'unless'  => 'test -f /var/lib/tftpboot//ldlinux.c32',
          )
        # Exec[copying file ldlinux.e64-/]
        is_expected.to contain_exec('copying file ldlinux.e64-/')
          .with(
            'command' => 'cp /opt/pxe_install/syslinux-6.03/efi64/com32/elflink/ldlinux/ldlinux.e64 /var/lib/tftpboot//ldlinux.e64',
            'path'    => ['/bin/', '/usr/bin'],
            'unless'  => 'test -f /var/lib/tftpboot//ldlinux.e64',
          )
        # Exec[copying file libcom32.c32-/bios]
        is_expected.to contain_exec('copying file libcom32.c32-/bios')
          .with(
            'command' => 'cp /opt/pxe_install/syslinux-6.03/bios/com32/lib/libcom32.c32 /var/lib/tftpboot/bios/libcom32.c32',
            'path'    => ['/bin/', '/usr/bin'],
            'unless'  => 'test -f /var/lib/tftpboot/bios/libcom32.c32',
          )
        # Exec[copying file libutil.c32-/bios]
        is_expected.to contain_exec('copying file libutil.c32-/bios')
          .with(
            'command' => 'cp /opt/pxe_install/syslinux-6.03/bios/com32/libutil/libutil.c32 /var/lib/tftpboot/bios/libutil.c32',
            'path'    => ['/bin/', '/usr/bin'],
            'unless'  => 'test -f /var/lib/tftpboot/bios/libutil.c32',
          )
        # Exec[copying file linux.c32-/bios]
        is_expected.to contain_exec('copying file linux.c32-/bios')
          .with(
            'command' => 'cp /opt/pxe_install/syslinux-6.03/bios/com32/modules/linux.c32 /var/lib/tftpboot/bios/linux.c32',
            'path'    => ['/bin/', '/usr/bin'],
            'unless'  => 'test -f /var/lib/tftpboot/bios/linux.c32',
          )
        # Exec[copying file vesamenu.c32-/bios]
        is_expected.to contain_exec('copying file vesamenu.c32-/bios')
          .with(
            'command' => 'cp /opt/pxe_install/syslinux-6.03/bios/com32/menu/vesamenu.c32 /var/lib/tftpboot/bios/vesamenu.c32',
            'path'    => ['/bin/', '/usr/bin'],
            'unless'  => 'test -f /var/lib/tftpboot/bios/vesamenu.c32',
          )
        # Exec[copying file libutil.c32-/efi64]
        is_expected.to contain_exec('copying file libutil.c32-/efi64')
          .with(
            'command' => 'cp /opt/pxe_install/syslinux-6.03/efi64/com32/libutil/libutil.c32 /var/lib/tftpboot/efi64/libutil.c32',
            'path'    => ['/bin/', '/usr/bin'],
            'unless'  => 'test -f /var/lib/tftpboot/efi64/libutil.c32',
          )
        # Exec[copying file linux.c32-/efi64]
        is_expected.to contain_exec('copying file linux.c32-/efi64')
          .with(
            'command' => 'cp /opt/pxe_install/syslinux-6.03/efi64/com32/modules/linux.c32 /var/lib/tftpboot/efi64/linux.c32',
            'path'    => ['/bin/', '/usr/bin'],
            'unless'  => 'test -f /var/lib/tftpboot/efi64/linux.c32',
          )
        # Exec[copying file vesamenu.c32-/efi64]
        is_expected.to contain_exec('copying file vesamenu.c32-/efi64')
          .with(
            'command' => 'cp /opt/pxe_install/syslinux-6.03/efi64/com32/menu/vesamenu.c32 /var/lib/tftpboot/efi64/vesamenu.c32',
            'path'    => ['/bin/', '/usr/bin'],
            'unless'  => 'test -f /var/lib/tftpboot/efi64/vesamenu.c32',
          )
        # Exec[copying file libcom32.c32-/efi64]
        is_expected.to contain_exec('copying file libcom32.c32-/efi64')
          .with(
            'command' => 'cp /opt/pxe_install/syslinux-6.03/efi64/com32/lib/libcom32.c32 /var/lib/tftpboot/efi64/libcom32.c32',
            'path'    => ['/bin/', '/usr/bin'],
            'unless'  => 'test -f /var/lib/tftpboot/efi64/libcom32.c32',
          )
        # File[/opt/pxe_install]
        is_expected.to contain_file('/opt/pxe_install')
          .with(
            'ensure' => 'directory',
            'owner'  => 'root',
            'group'  => 'root',
            'mode'   => '0755',
          )
        # File[/var/lib/tftpboot//winpe/wimboot]
        is_expected.to contain_file('/var/lib/tftpboot/winpe/wimboot')
          .with(
            'ensure' => 'file',
            'source' => 'https://github.com/ipxe/wimboot/releases/latest/download/wimboot',
            'owner'  => 'root',
            'group'  => 'root',
            'mode'   => '0755',
          )
        # File[/var/lib/tftpboot/ipexe.efi]
        is_expected.to contain_file('/var/lib/tftpboot/ipexe.efi')
          .with(
            'ensure' => 'file',
            'source' => 'http://boot.ipxe.org/ipxe.efi',
            'owner'  => 'root',
            'group'  => 'root',
            'mode'   => '0755',
          )
        # File[/var/lib/tftpboot/winpw.ipxe]
        is_expected.to contain_file('/var/lib/tftpboot/winpw.ipxe')
          .with(
            'ensure' => 'file',
            'source' => 'puppet:///modules/pxe_install/winpw.ipxe',
            'owner'  => 'root',
            'group'  => 'root',
            'mode'   => '0755',
          )

        is_expected.to contain_pxe_install__partitioning__redhat('ct01')
          .with(
            'hostname'       => 'ct01',
            'partitioning'   => {
              '/boot' => {
                'type' => 'part',
                'fstype' => 'ext3',
                'size' => 1024,
                'primary' => true,
                'ondisk' => 'sda',
              },
              'pv.01' => {
                'type' => 'pvol',
                'size' => 1000,
                'grow' => true,
                'primary' => true,
                'ondisk' => 'sda',
              },
              'vgos' => {
                'type' => 'volgroup',
                'pvol' => 'pv.01',
              },
              '/' => {
                'type' => 'logvol',
                'vgname' => 'vgos',
                'diskname' => 'lvol_root',
                'size' => 2048,
                'fstype' => 'ext4',
              },
              'swap' => {
                'type' => 'logvol',
                'vgname' => 'vgos',
                'diskname' => 'lvol_swap',
                'size' => 4096,
              },
            },
            'kickstart_file' => '/export/repos/kickstart/ct01',
          )

        is_expected.to contain_pxe_install__partitioning__ubuntu('ct02')
          .with(
            'hostname'       => 'ct02',
            'partitioning'   => {
              '/boot' => {
                'min' => 1024,
                'prio' => 1024,
                'max' => 1024,
                'fstype' => 'ext3',
                'primary' => true,
                'bootable' => true,
                'label' => 'boot',
                'method' => 'format',
                'device' => '/dev/sda',
                'order' => 405,
              },
              'vgos' => {
                'min' => 100,
                'prio' => 1000,
                'max' => 1_000_000_000,
                'fstype' => 'ext4',
                'primary' => true,
                'bootable' => false,
                'method' => 'lvm',
                'device' => '/dev/sda',
                'vgname' => 'vgos',
                'order' => 406,
              },
              'swap' => {
                'min' => 4096,
                'prio' => 4096,
                'max' => 4096,
                'fstype' => 'linux-swap',
                'primary' => false,
                'bootable' => false,
                'invg' => 'vgos',
                'method' => 'swap',
                'lvname' => 'lvol_swap',
                'order' => 407,
              },
              '/' => {
                'min' => 4096,
                'prio' => 4096,
                'max' => 4096,
                'fstype' => 'ext4',
                'invg' => 'vgos',
                'lvname' => 'lvol_root',
                'primary' => false,
                'bootable' => false,
                'method' => 'format',
                'label' => 'root',
                'order' => 408,
              },
            },
            'kickstart_file' => '/export/repos/kickstart/ct02',
          )

        is_expected.to contain_pxe_install__partitioning__debian('ct02')
          .with(
            'hostname'       => 'ct02',
            'partitioning'   => {
              '/boot' => {
                'min' => 1024,
                'prio' => 1024,
                'max' => 1024,
                'fstype' => 'ext3',
                'primary' => true,
                'bootable' => true,
                'label' => 'boot',
                'method' => 'format',
                'device' => '/dev/sda',
                'order' => 405,
              },
              'vgos' => {
                'min' => 100,
                'prio' => 1000,
                'max' => 1_000_000_000,
                'fstype' => 'ext4',
                'primary' => true,
                'bootable' => false,
                'method' => 'lvm',
                'device' => '/dev/sda',
                'vgname' => 'vgos',
                'order' => 406,
              },
              'swap' => {
                'min' => 4096,
                'prio' => 4096,
                'max' => 4096,
                'fstype' => 'linux-swap',
                'primary' => false,
                'bootable' => false,
                'invg' => 'vgos',
                'method' => 'swap',
                'lvname' => 'lvol_swap',
                'order' => 407,
              },
              '/' => {
                'min' => 4096,
                'prio' => 4096,
                'max' => 4096,
                'fstype' => 'ext4',
                'invg' => 'vgos',
                'lvname' => 'lvol_root',
                'primary' => false,
                'bootable' => false,
                'method' => 'format',
                'label' => 'root',
                'order' => 408,
              },
            },
            'kickstart_file' => '/export/repos/kickstart/ct02',
            'template_partitioning' => 'pxe_install/ubuntu/partition.epp',
            'template_part_entry' => 'pxe_install/ubuntu/partition_entry.epp',
            'template_part_finish' => 'pxe_install/ubuntu/partition_finish.epp',
          )

        is_expected.to contain_pxe_install__partitioning__ubuntu('ct03')
          .with(
            'hostname'       => 'ct03',
            'partitioning'   => {
              '/boot' => {
                'min' => 1024,
                'prio' => 1024,
                'max' => 1024,
                'fstype' => 'ext3',
                'primary' => true,
                'bootable' => true,
                'label' => 'boot',
                'method' => 'format',
                'device' => '/dev/sda',
                'order' => 405,
              },
              'vgos' => {
                'min' => 100,
                'prio' => 1000,
                'max' => 1_000_000_000,
                'fstype' => 'ext4',
                'primary' => true,
                'bootable' => false,
                'method' => 'lvm',
                'device' => '/dev/sda',
                'vgname' => 'vgos',
                'order' => 406,
              },
              'swap' => {
                'min' => 4096,
                'prio' => 4096,
                'max' => 4096,
                'fstype' => 'linux-swap',
                'primary' => false,
                'bootable' => false,
                'invg' => 'vgos',
                'method' => 'swap',
                'lvname' => 'lvol_swap',
                'order' => 407,
              },
              '/' => {
                'min' => 4096,
                'prio' => 4096,
                'max' => 4096,
                'fstype' => 'ext4',
                'invg' => 'vgos',
                'lvname' => 'lvol_root',
                'primary' => false,
                'bootable' => false,
                'method' => 'format',
                'label' => 'root',
                'order' => 408,
              },
            },
            'kickstart_file' => '/export/repos/kickstart/ct03',
          )

        is_expected.to contain_pxe_install__partitioning__debian('ct03')
          .with(
            'hostname'       => 'ct03',
            'partitioning'   => {
              '/boot' => {
                'min' => 1024,
                'prio' => 1024,
                'max' => 1024,
                'fstype' => 'ext3',
                'primary' => true,
                'bootable' => true,
                'label' => 'boot',
                'method' => 'format',
                'device' => '/dev/sda',
                'order' => 405,
              },
              'vgos' => {
                'min' => 100,
                'prio' => 1000,
                'max' => 1_000_000_000,
                'fstype' => 'ext4',
                'primary' => true,
                'bootable' => false,
                'method' => 'lvm',
                'device' => '/dev/sda',
                'vgname' => 'vgos',
                'order' => 406,
              },
              'swap' => {
                'min' => 4096,
                'prio' => 4096,
                'max' => 4096,
                'fstype' => 'linux-swap',
                'primary' => false,
                'bootable' => false,
                'invg' => 'vgos',
                'method' => 'swap',
                'lvname' => 'lvol_swap',
                'order' => 407,
              },
              '/' => {
                'min' => 4096,
                'prio' => 4096,
                'max' => 4096,
                'fstype' => 'ext4',
                'invg' => 'vgos',
                'lvname' => 'lvol_root',
                'primary' => false,
                'bootable' => false,
                'method' => 'format',
                'label' => 'root',
                'order' => 408,
              },
            },
            'kickstart_file' => '/export/repos/kickstart/ct03',
            'template_partitioning' => 'pxe_install/ubuntu/partition.epp',
            'template_part_entry' => 'pxe_install/ubuntu/partition_entry.epp',
            'template_part_finish' => 'pxe_install/ubuntu/partition_finish.epp',
          )

        is_expected.to contain_concat('/export/repos/kickstart/ct01')
          .with(
            'ensure' => 'present',
            'owner'  => 'root',
            'group'  => 'root',
            'mode'   => '0644',
          )

        is_expected.to contain_concat('/export/repos/kickstart/ct02')
          .with(
            'ensure' => 'absent',
            'owner'  => 'root',
            'group'  => 'root',
            'mode'   => '0644',
          )

        is_expected.to contain_concat('/export/repos/kickstart/ct03')
          .with(
            'ensure' => 'present',
            'owner'  => 'root',
            'group'  => 'root',
            'mode'   => '0644',
          )

        is_expected.to contain_concat__fragment('ct01-/')
          .with(
            'order'   => 500,
            'target'  => '/export/repos/kickstart/ct01',
          )

        is_expected.to contain_concat__fragment('ct01-/boot')
          .with(
            'order'   => 500,
            'target'  => '/export/repos/kickstart/ct01',
          )

        is_expected.to contain_concat__fragment('ct01-finish')
          .with(
            'order'   => 999,
            'target'  => '/export/repos/kickstart/ct01',
          )

        is_expected.to contain_concat__fragment('ct01-pv.01')
          .with(
            'order'   => 500,
            'target'  => '/export/repos/kickstart/ct01',
          )

        is_expected.to contain_concat__fragment('ct01-start')
          .with(
            'order'   => 1,
            'target'  => '/export/repos/kickstart/ct01',
          )

        is_expected.to contain_concat__fragment('ct01-swap')
          .with(
            'order'   => 500,
            'target'  => '/export/repos/kickstart/ct01',
          )

        is_expected.to contain_concat__fragment('ct01-vgos')
          .with(
            'order'   => 500,
            'target'  => '/export/repos/kickstart/ct01',
          )

        is_expected.to contain_concat__fragment('ct02-/')
          .with(
            'order'   => 408,
            'target'  => '/export/repos/kickstart/ct02',
          )

        is_expected.to contain_concat__fragment('ct02-/boot')
          .with(
            'order'   => 405,
            'target'  => '/export/repos/kickstart/ct02',
          )

        is_expected.to contain_concat__fragment('ct02-finish')
          .with(
            'order'   => 999,
            'target'  => '/export/repos/kickstart/ct02',
          )

        is_expected.to contain_concat__fragment('ct02-partioning-finish')
          .with(
            'order'   => 600,
            'target'  => '/export/repos/kickstart/ct02',
          )

        is_expected.to contain_concat__fragment('ct02-partition-start')
          .with(
            'order'   => 400,
            'target'  => '/export/repos/kickstart/ct02',
          )

        is_expected.to contain_concat__fragment('ct02-start')
          .with(
            'order'   => 1,
            'target'  => '/export/repos/kickstart/ct02',
          )

        is_expected.to contain_concat__fragment('ct02-swap')
          .with(
            'order'   => 407,
            'target'  => '/export/repos/kickstart/ct02',
          )

        is_expected.to contain_concat__fragment('ct02-vgos')
          .with(
            'order'   => 406,
            'target'  => '/export/repos/kickstart/ct02',
          )

        is_expected.to contain_concat__fragment('ct03-/')
          .with(
            'order'   => 408,
            'target'  => '/export/repos/kickstart/ct03',
          )

        is_expected.to contain_concat__fragment('ct03-/boot')
          .with(
            'order'   => 405,
            'target'  => '/export/repos/kickstart/ct03',
          )

        is_expected.to contain_concat__fragment('ct03-finish')
          .with(
            'order'   => 999,
            'target'  => '/export/repos/kickstart/ct03',
          )

        is_expected.to contain_concat__fragment('ct03-partioning-finish')
          .with(
            'order'   => 600,
            'target'  => '/export/repos/kickstart/ct03',
          )

        is_expected.to contain_concat__fragment('ct03-partition-start')
          .with(
            'order'   => 400,
            'target'  => '/export/repos/kickstart/ct03',
          )

        is_expected.to contain_concat__fragment('ct03-start')
          .with(
            'order'   => 1,
            'target'  => '/export/repos/kickstart/ct03',
          )

        is_expected.to contain_concat__fragment('ct03-swap')
          .with(
            'order'   => 407,
            'target'  => '/export/repos/kickstart/ct03',
          )

        is_expected.to contain_concat__fragment('ct03-vgos')
          .with(
            'order'   => 406,
            'target'  => '/export/repos/kickstart/ct03',
          )

        is_expected.to contain_file('/export/repos/pub/debian-rc.local')
          .with(
            'ensure' => 'file',
            'owner'  => 'root',
            'group'  => 'root',
            'mode'   => '0644',
          )

        is_expected.to contain_service('xinetd')
          .with(
            'ensure' => 'running',
            'enable' => true,
          )
        is_expected.to contain_package('tftp-server')
          .with(
            'ensure' => 'present',
          )

        is_expected.to contain_package('xinetd')
          .with(
            'ensure' => 'present',
          )

        is_expected.to contain_file('/etc/tftpd.map')
          .with(
            'ensure' => 'file',
            'owner'  => 'root',
            'group'  => 'root',
            'mode'   => '0644',
          )

        if os_facts[:osfamily].casecmp('debian').zero?
          is_expected.to contain_file('/etc/default/tftpd-hpa')
            .with(
              'ensure' => 'file',
              'owner'  => 'root',
              'group'  => 'root',
              'mode'   => '0644',
            )
        else
          is_expected.to contain_file('/etc/xinetd.d/tftp')
            .with(
              'ensure' => 'file',
              'owner'  => 'root',
              'group'  => 'root',
              'mode'   => '0644',
            )
        end
      }
    end
  end
end
