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

        is_expected.to contain_pxe_install__parent_dirs('create tftpboot windows scripts dir')
          .with(
            'dir_path' => '/var/lib/tftpboot/windows/winpe/scripts',
          )

        is_expected.to contain_pxe_install__parent_dirs('create tftpboot windows unattend dir')
          .with(
            'dir_path' => '/var/lib/tftpboot/windows/winpe/unattend',
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

        is_expected.to contain_file('/var/lib/tftpboot/windows/winpe/scripts')
          .with(
            'ensure' => 'directory',
          )

        is_expected.to contain_file('/var/lib/tftpboot/windows/winpe/unattend')
          .with(
            'ensure' => 'directory',
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

        is_expected.to contain_file('/export/repos/pub/fedora-post.sh')
          .with(
              'ensure'  => 'file',
              'owner'   => 'root',
              'group'   => 'root',
              'mode'    => '0644',
            )

        is_expected.to contain_file('/var/lib/tftpboot/windows/winpe/scripts/install.ps1')
          .with(
            'ensure'  => 'file',
            'owner'   => 'root',
            'group'   => 'root',
            'mode'    => '0755',
          )

        is_expected.to contain_file('/var/lib/tftpboot/windows/winpe/unattend/2019_bios.xml')
          .with(
            'ensure'  => 'file',
            'owner'   => 'root',
            'group'   => 'root',
            'mode'    => '0755',
          )

        is_expected.to contain_file('/var/lib/tftpboot/windows/winpe/unattend/2019_uefi.xml')
          .with(
            'ensure'  => 'file',
            'owner'   => 'root',
            'group'   => 'root',
            'mode'    => '0755',
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
              'ipxe_bootstrap' => 'winpe.ipxe',
              'ipxe_filename' => 'ipxe.efi',
              'globaloptions' => ['space ipxe', 'ipxe-encap-opts code 175 = encapsulate ipxe', 'ipxe.priority code 1 = signed integer 8',
                                  'ipxe.keep-san code 8 = unsigned integer 8', 'ipxe.skip-san-boot code 9 = unsigned integer 8',
                                  'ipxe.syslogs code 85 = string', 'ipxe.cert code 91 = string', 'ipxe.privkey code 92 = string',
                                  'ipxe.crosscert code 93 = string', 'ipxe.no-pxedhcp code 176 = unsigned integer 8',
                                  'ipxe.bus-id code 177 = string', 'ipxe.san-filename code 188 = string',
                                  'ipxe.bios-drive code 189 = unsigned integer 8', 'ipxe.username code 190 = string',
                                  'ipxe.password code 191 = string', 'ipxe.reverse-username code 192 = string',
                                  'ipxe.reverse-password code 193 = string', 'ipxe.version code 235 = string',
                                  'iscsi-initiator-iqn code 203 = string', 'ipxe.pxeext code 16 = unsigned integer 8',
                                  'ipxe.iscsi code 17 = unsigned integer 8', 'ipxe.aoe code 18 = unsigned integer 8',
                                  'ipxe.http code 19 = unsigned integer 8', 'ipxe.https code 20 = unsigned integer 8',
                                  'ipxe.tftp code 21 = unsigned integer 8', 'ipxe.ftp code 22 = unsigned integer 8',
                                  'ipxe.dns code 23 = unsigned integer 8', 'ipxe.bzimage code 24 = unsigned integer 8',
                                  'ipxe.multiboot code 25 = unsigned integer 8', 'ipxe.slam code 26 = unsigned integer 8',
                                  'ipxe.srp code 27 = unsigned integer 8', 'ipxe.nbi code 32 = unsigned integer 8',
                                  'ipxe.pxe code 33 = unsigned integer 8', 'ipxe.elf code 34 = unsigned integer 8',
                                  'ipxe.comboot code 35 = unsigned integer 8', 'ipxe.efi code 36 = unsigned integer 8',
                                  'ipxe.fcoe code 37 = unsigned integer 8', 'ipxe.vlan code 38 = unsigned integer 8',
                                  'ipxe.menu code 39 = unsigned integer 8', 'ipxe.sdi code 40 = unsigned integer 8',
                                  'ipxe.nfs code 41 = unsigned integer 8'],
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
              'winpe_dir' => 'winpe',
              'packages' => ['tftp-server', 'xinetd'],
              'packages_ensure' => 'installed',
              'port' => 69,
              'user' => 'root',
              'group' => 'root',
              'directory' => '/var/lib/tftpboot',
              'windows_directory' => '/windows/winpe',
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
            },
            'filename' => '/tftpboot/test.0',
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
            'filename' => 'lpxelinux.0',
            'comment' => 'Kickstart dhcp entry for ct03',
          )

        is_expected.to contain_dhcp__host('ct04')
          .with(
            'mac' => '00:11:22:33:44:88',
            'ip' => '10.0.0.132',
            'options' => {
              'routers'   => '10.0.0.4',
              'host-name' => 'ct04',
            },
            'filename' => 'ipxe_winpe.efi',
            'comment' => 'Kickstart dhcp entry for ct04',
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
                'boot_architecture' => 'bios',
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
                'boot_architecture' => 'bios',
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
                'boot_architecture' => 'bios',
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

        is_expected.to contain_pxe_install__kickstart('ct04')
          .with(
            'data'          => {
              'ensure' => 'present',
              'network' => {
                'mac' => '00:11:22:33:44:88',
                'fixedaddress' => '10.0.0.132',
                'ksdevice' => 'eth0',
                'gateway' => '10.0.0.4',
                'netmask' => '255.255.255.0',
                'dns' => ['10.0.0.62', '10.0.0.63', '10.0.0.25'],
                'boot_architecture' => 'uefi',
              },
              'ostype' => 'windows',
              'osversion' => '2019',
              'locale' => 'en-US',
              'keyboard' => 'en-US',
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

        is_expected.to contain_pxe_install__tftp__host('10.0.0.132')
          .with(
            'ensure'     => 'present',
            'ostype'     => 'windows',
            'prefix'     => '',
            'path'       => '',
            'ksurl'      => '',
            'ksdevice'   => 'eth0',
            'puppetenv'  => 'production',
            'puppetrole' => 'test',
            'datacenter' => 'test',
            'locale'     => 'en-US',
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

        is_expected.to contain_pxe_install__samba__host('ct04')
          .with(
            'tftpboot_dir'      => '/var/lib/tftpboot/windows/winpe',
            'osversion'         => '2019',
            'iso'               => '',
            'boot_architecture' => 'uefi',
            'fixedaddress'      => '10.0.0.132',
            'macaddress'        => '00:11:22:33:44:88',
            'subnet'            => '255.255.255.0',
            'gateway'           => '10.0.0.4',
            'dns'               => ['10.0.0.62', '10.0.0.63', '10.0.0.25'],
            'puppetmaster'      => 'pmaster.localdomain',
          )

        is_expected.to contain_pxe_install__samba__unattend('ct04')
          .with(
            'boot'              => 'uefi',
            'unattend_dir'      => '/var/lib/tftpboot/windows/winpe/unattend',
            'osversion'         => '2019',
            'win_domain'        => 'example.com',
            'win_locale'        => 'en-US',
            'win_input_locale'  => 'en-US',
          )

        is_expected.to contain_file('/var/lib/tftpboot')
          .with(
            'ensure'       => 'directory',
            'owner'        => 'root',
            'group'        => 'root',
            'mode'         => '0755',
          )

        is_expected.to contain_file('/var/lib/tftpboot/windows/winpe')
          .with(
            'ensure' => 'directory',
          )

        # is_expected.to contain_file('/tftpboot/windows')
        #   .with(
        #     'ensure' => 'directory',
        #   )

        is_expected.to contain_file('/var/lib/tftpboot/grub/grub.cfg')
          .with(
            'ensure' => 'file',
            'source' => 'puppet:///modules/pxe_install/grub.cfg',
            'owner'  => 'root',
            'group'  => 'root',
            'mode'   => '0644',
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

        is_expected.to contain_file('/var/lib/tftpboot/pxelinux.cfg/0A000084')
          .with(
            'ensure' => 'present',
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

        is_expected.to contain_file('/var/lib/tftpboot/windows/winpe/001122334488.cfg')
          .with(
            'ensure' => 'file',
            'owner'  => 'root',
            'group'  => 'root',
            'mode'   => '0644',
          )

        is_expected.to contain_file('/var/lib/tftpboot/windows/winpe/unattend/ct04.xml')
          .with(
            'ensure' => 'file',
            'owner' => 'root',
            'group' => 'root',
            'mode' => '0644',
          )

        is_expected.to contain_archive('syslinux-6.03.tar.gz')
          .with(
            'path'         => '/opt/pxe_install/syslinux-6.03.tar.gz',
            'source'       => 'https://www.kernel.org/pub/linux/utils/boot/syslinux/syslinux-6.03.tar.gz',
            'extract'      => true,
            'extract_path' => '/opt/pxe_install/',
            'creates'      => '/opt/pxe_install/syslinux-6.03',
            'cleanup'      => true,
          )

        is_expected.to contain_class('pxe_install::syslinux')
          .with(
            'tftpboot_dir'        => '/var/lib/tftpboot',
            'create_tftpboot_dir' => true,
          )

        is_expected.to contain_class('pxe_install::winipxe')
          .with(
            'tftpboot_dir'        => '/var/lib/tftpboot',
          )

        is_expected.to contain_pxe_install__parent_dirs('create tftpboot dir /var/lib/tftpboot/')
          .with(
            'dir_path' => '/var/lib/tftpboot/',
          )

        is_expected.to contain_pxe_install__parent_dirs('create tftpboot dir /var/lib/tftpboot/bios')
          .with(
            'dir_path' => '/var/lib/tftpboot/bios',
          )

        is_expected.to contain_pxe_install__parent_dirs('create tftpboot dir /var/lib/tftpboot/efi64')
          .with(
            'dir_path' => '/var/lib/tftpboot/efi64',
          )

        is_expected.to contain_pxe_install__parent_dirs('create tftpboot dir /var/lib/tftpboot/winpe')
          .with(
            'dir_path' => '/var/lib/tftpboot/winpe',
          )

        is_expected.to contain_pxe_install__parent_dirs('create tftpboot grub dir')
          .with(
            'dir_path' => '/var/lib/tftpboot/grub',
          )

        is_expected.to contain_file('/var/lib/tftpboot/bios')
          .with(
            'ensure' => 'directory',
          )
        is_expected.to contain_file('/var/lib/tftpboot/grub')
          .with(
            'ensure' => 'directory',
          )
        is_expected.to contain_file('/var/lib/tftpboot/efi64')
          .with(
            'ensure' => 'directory',
          )
        is_expected.to contain_file('/var/lib/tftpboot/winpe')
          .with(
            'ensure' => 'directory',
          )
        is_expected.to contain_file('/var/lib')
          .with(
            'ensure' => 'directory',
          )

        is_expected.to contain_exec('copying file pxelinux.0-/')
          .with(
            'command' => 'cp /opt/pxe_install/syslinux-6.03/bios/core/pxelinux.0 /var/lib/tftpboot//pxelinux.0',
            'path'    => ['/bin/', '/usr/bin'],
            'unless'  => 'test -f /var/lib/tftpboot//pxelinux.0',
          )

        is_expected.to contain_exec('copying file lpxelinux.0-/')
          .with(
            'command' => 'cp /opt/pxe_install/syslinux-6.03/bios/core/lpxelinux.0 /var/lib/tftpboot//lpxelinux.0',
            'path'    => ['/bin/', '/usr/bin'],
            'unless'  => 'test -f /var/lib/tftpboot//lpxelinux.0',
          )

        is_expected.to contain_exec('copying file bootx64.efi-/')
          .with(
            'command' => 'cp /opt/pxe_install/syslinux-6.03/efi64/efi/syslinux.efi /var/lib/tftpboot//bootx64.efi',
            'path'    => ['/bin/', '/usr/bin'],
            'unless'  => 'test -f /var/lib/tftpboot//bootx64.efi',
          )

        is_expected.to contain_exec('copying file ldlinux.c32-/')
          .with(
            'command' => 'cp /opt/pxe_install/syslinux-6.03/bios/com32/elflink/ldlinux/ldlinux.c32 /var/lib/tftpboot//ldlinux.c32',
            'path'    => ['/bin/', '/usr/bin'],
            'unless'  => 'test -f /var/lib/tftpboot//ldlinux.c32',
          )

        is_expected.to contain_exec('copying file ldlinux.e64-/')
          .with(
            'command' => 'cp /opt/pxe_install/syslinux-6.03/efi64/com32/elflink/ldlinux/ldlinux.e64 /var/lib/tftpboot//ldlinux.e64',
            'path'    => ['/bin/', '/usr/bin'],
            'unless'  => 'test -f /var/lib/tftpboot//ldlinux.e64',
          )

        is_expected.to contain_exec('copying file libcom32.c32-/bios')
          .with(
            'command' => 'cp /opt/pxe_install/syslinux-6.03/bios/com32/lib/libcom32.c32 /var/lib/tftpboot/bios/libcom32.c32',
            'path'    => ['/bin/', '/usr/bin'],
            'unless'  => 'test -f /var/lib/tftpboot/bios/libcom32.c32',
          )

        is_expected.to contain_exec('copying file libutil.c32-/bios')
          .with(
            'command' => 'cp /opt/pxe_install/syslinux-6.03/bios/com32/libutil/libutil.c32 /var/lib/tftpboot/bios/libutil.c32',
            'path'    => ['/bin/', '/usr/bin'],
            'unless'  => 'test -f /var/lib/tftpboot/bios/libutil.c32',
          )

        is_expected.to contain_exec('copying file linux.c32-/bios')
          .with(
            'command' => 'cp /opt/pxe_install/syslinux-6.03/bios/com32/modules/linux.c32 /var/lib/tftpboot/bios/linux.c32',
            'path'    => ['/bin/', '/usr/bin'],
            'unless'  => 'test -f /var/lib/tftpboot/bios/linux.c32',
          )

        is_expected.to contain_exec('copying file vesamenu.c32-/bios')
          .with(
            'command' => 'cp /opt/pxe_install/syslinux-6.03/bios/com32/menu/vesamenu.c32 /var/lib/tftpboot/bios/vesamenu.c32',
            'path'    => ['/bin/', '/usr/bin'],
            'unless'  => 'test -f /var/lib/tftpboot/bios/vesamenu.c32',
          )

        is_expected.to contain_exec('copying file libutil.c32-/efi64')
          .with(
            'command' => 'cp /opt/pxe_install/syslinux-6.03/efi64/com32/libutil/libutil.c32 /var/lib/tftpboot/efi64/libutil.c32',
            'path'    => ['/bin/', '/usr/bin'],
            'unless'  => 'test -f /var/lib/tftpboot/efi64/libutil.c32',
          )

        is_expected.to contain_exec('copying file linux.c32-/efi64')
          .with(
            'command' => 'cp /opt/pxe_install/syslinux-6.03/efi64/com32/modules/linux.c32 /var/lib/tftpboot/efi64/linux.c32',
            'path'    => ['/bin/', '/usr/bin'],
            'unless'  => 'test -f /var/lib/tftpboot/efi64/linux.c32',
          )

        is_expected.to contain_exec('copying file vesamenu.c32-/efi64')
          .with(
            'command' => 'cp /opt/pxe_install/syslinux-6.03/efi64/com32/menu/vesamenu.c32 /var/lib/tftpboot/efi64/vesamenu.c32',
            'path'    => ['/bin/', '/usr/bin'],
            'unless'  => 'test -f /var/lib/tftpboot/efi64/vesamenu.c32',
          )

        is_expected.to contain_exec('copying file libcom32.c32-/efi64')
          .with(
            'command' => 'cp /opt/pxe_install/syslinux-6.03/efi64/com32/lib/libcom32.c32 /var/lib/tftpboot/efi64/libcom32.c32',
            'path'    => ['/bin/', '/usr/bin'],
            'unless'  => 'test -f /var/lib/tftpboot/efi64/libcom32.c32',
          )

        is_expected.to contain_file('/opt/pxe_install')
          .with(
            'ensure' => 'directory',
            'owner'  => 'root',
            'group'  => 'root',
            'mode'   => '0755',
          )

        is_expected.to contain_file('/var/lib/tftpboot/winpe/wimboot')
          .with(
            'ensure' => 'file',
            'source' => 'https://github.com/ipxe/wimboot/releases/latest/download/wimboot',
            'owner'  => 'root',
            'group'  => 'root',
            'mode'   => '0755',
          )

        is_expected.to contain_archive('/var/lib/tftpboot/ipxe.efi')
          .with(
            'ensure' => 'present',
            'source' => 'http://boot.ipxe.org/ipxe.efi',
            'user'   => 'root',
            'group'  => 'root',
          )

        is_expected.to contain_file('/var/lib/tftpboot/winpe.ipxe')
          .with(
            'ensure' => 'file',
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
            'order'   => '01',
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
            'order'   => '01',
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
            'order'   => '01',
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
