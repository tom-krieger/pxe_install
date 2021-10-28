require 'spec_helper'
require 'pp'

describe 'pxe_install' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:pre_condition) do
        <<-EOF
#{'        '}
        EOF
      end
      let(:facts) { os_facts }
      let(:params) do
        {
          'installserverip' => '10.0.0.1',
          'installserver' => 'install.local',
          'repo_server'   => 'repo.local',
          'repo_server_ip' => '10.0.0.2',
          'repos_dir' => '/export/repos/www',
          'repos_url' => '/',
          'scriptdir' => '/export/repos/www/pub',
          'scripturl' => '/pub',
          'kickstart_dir' => '/export/repos/www/kickstart',
          'kickstart_url' => '/kickstart',
          'documentroot' => '/export/repos/www',
          'create_aliases' => true,
          'ssl_cert' => '/etc/pki/httpd/cert.pem',
          'ssl_key' => '/etc/pki/httpd/key.pem',
          'ssl_chain' => '/etc/pki/httpd/chain.pem',
          'status_allow_from' => ['127.0.0.1'],
          'debian_mirror' => 'debian.intergenia.de',
          'debian_mirror_dir' => '/debian',
          'ubuntu_mirror' => 'archive.ubuntu.com',
          'ubuntu_mirror_dir' => '/ubuntu',
          'configure_repos' => false,
          'configure_sync_scripts' => false,
          'challenge_password' => 'ENC[PKCS7,MIIBeQYJKoZIhv]',
          'services' => {
            'tftpd' => {
              'packages' => ['tftp-server', 'xinetd'],
              'packages_ensure' => 'installed',
              'port' => 69,
              'user' => 'root',
              'group' => 'root',
              'directory' => '/var/lib/tftpboot',
              'pxelinux' => 'pxelinux.cfg',
              'address' => '10.0.0.25',
              'tftpserverbin' => '/usr/sbin/in.tftpd',
              'service' => 'xinetd',
              'service_ensure' => 'running',
              'service_enable' => true,
            },
            'dhcpd' => {
              'interfaces' => ['ens192'],
              'omapiport' => 7911,
              'default_lease_time' => 43_200,
              'max_lease_time' => 86_400,
              'ddns_update_style' => 'none',
              'domain_names' => ['example.com'],
              'dns_servers' => ['10.0.0.62', '10.0.0.63', '10.0.0.25'],
              'ntp_servers' => ['none'],
              'next_server' => '10.0.0.25',
              'logfacility' => 'local7',
              'option_code150_label' => 'pxegrub',
              'option_code150_value' => 'text',
              'default_filename' => 'pxelinux.0',
              'hosts' => {
                'wintest' => {
                  'mac' => '00:50:56:91:72:8d',
                  'ip' => '10.0.0.141',
                  'max_lease_time' => 86_400,
                },
              },
            },
          },
          'machines' => {
            'tk14' => {
              'ensure' => 'present',
              'rootpw' => '$6$pzoDeF7......Z/',
              'timezone' => 'Europe/Berlin',
              'ostype' => 'ubuntu',
              'keyboard' => 'de(Macintosh, no dead keys)',
              'keymap' => 'de',
              'language' => 'en',
              'country' => 'DE',
              'locale' => 'en_US.UTF-8',
              'path' => 'ubuntu/18.04/amd64/boot-screens',
              'network' => {
                'mac' => '00:50:56:91:ba:67',
                'prefix' => 'ubuntu/18.04/amd64',
                'fixedaddress' => '10.0.0.32',
                'ksdevice' => 'eth0',
                'gateway' => '10.0.0.4',
                'netmask' => '255.255.255.0',
                'dns' => ['10.0.0.62', '10.0.0.63', '10.0.0.25'],
              },
              'parameter' => {
                'env' => 'production',
                'role' => 'ubuntu',
                'dc' => 'home',
                'agent' => 'y',
              },
              'user' => {
                'fullname' => 'Tom Test',
                'username' => 'testtom',
                'password' => '$5$hEda......D',
              },
              'partitioning' => {
                'sda' => {
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
                  '/home' => {
                    'min' => 2048,
                    'prio' => 2048,
                    'max' => 2048,
                    'fstype' => 'ext4',
                    'invg' => 'vgos',
                    'lvname' => 'lvol_home',
                    'primary' => false,
                    'bootable' => false,
                    'method' => 'format',
                    'label' => 'home',
                    'order' => 409,
                  },
                },
              },
            },
          },
        }
      end

      it { is_expected.to compile.with_all_deps }

      it do
        if ENV['DEBUG']
          pp catalogue.resources
        end

        is_expected.to contain_pxe_install__parent_dirs('create script dir')
          .with(
            'dir_path' => '/export/repos/www',
          )

        is_expected.to contain_pxe_install__parent_dirs('create kickstart dirs')
          .with(
            'dir_path' => '/export/repos/www/kickstart',
          )

        is_expected.to contain_pxe_install__parent_dirs('create document root dir')
          .with(
            'dir_path' => '/export/repos/www',
          )

        is_expected.to contain_file('/export')
          .with

        is_expected.to contain_file('/export/repos')
          .with

        is_expected.to contain_file('/export/repos/www')
          .with

        is_expected.to contain_file('/export/repos/www/kickstart')
          .with

        is_expected.to contain_file('/export/repos/www/pub')
          .with(
            'ensure'       => 'directory',
            'source'       => 'puppet:///modules/pxe_install/install',
            'recurse'      => true,
            'recurselimit' => 3,
            'purge'        => true,
            'owner'        => 'root',
            'group'        => 'root',
            'mode'         => '0644',
          )

        is_expected.to contain_file('/export/repos/www/pub/debian-post.sh')
          .with(
            'ensure'  => 'file',
            'owner'   => 'root',
            'group'   => 'root',
            'mode'    => '0644',
          )

        is_expected.to contain_file('/export/repos/www/pub/ubuntu-post.sh')
          .with(
            'ensure'  => 'file',
            'owner'   => 'root',
            'group'   => 'root',
            'mode'    => '0644',
          )

        is_expected.to contain_file('/export/repos/www/pub/redhat-post.sh')
          .with(
            'ensure'  => 'file',
            'owner'   => 'root',
            'group'   => 'root',
            'mode'    => '0644',
          )

        is_expected.to contain_class('pxe_install::dhcp')
          .with

        is_expected.to contain_class('pxe_install::tftp')
          .with

        is_expected.to contain_class('pxe_install::apache')
          .with

        is_expected.to contain_apache__vhost('repo.local ssl')
          .with

        is_expected.to contain_apache__vhost('repo.local')
          .with

        is_expected.to contain_concat__fragment('tk14-/')
          .with

        is_expected.to contain_concat__fragment('tk14-/boot')
          .with

        is_expected.to contain_concat__fragment('tk14-/home')
          .with

        is_expected.to contain_concat__fragment('tk14-finish')
          .with

        is_expected.to contain_concat__fragment('tk14-partioning-finish')
          .with

        is_expected.to contain_concat__fragment('tk14-partition-start')
          .with

        is_expected.to contain_concat__fragment('tk14-start')
          .with

        is_expected.to contain_concat__fragment('tk14-swap')
          .with

        is_expected.to contain_concat__fragment('tk14-vgos')
          .with

        is_expected.to contain_concat('/export/repos/www/kickstart/tk14')
          .with

        is_expected.to contain_dhcp__host('tk14')
          .with

        is_expected.to contain_dhcp__host('wintest')
          .with(
            'mac' => '00:50:56:91:72:8d',
            'ip' => '10.0.0.141',
            'max_lease_time' => 86_400,
          )

        is_expected.to contain_file('/etc/pki/httpd/repo.local')
          .with

        is_expected.to contain_file('/etc/pki/httpd')
          .with

        is_expected.to contain_file('/export/repos/www/pub/debian-rc.local')
          .with

        is_expected.to contain_file('/export/repos/www')
          .with

        is_expected.to contain_file('/export/repos')
          .with

        is_expected.to contain_file('/export')
          .with

        is_expected.to contain_file('/var/lib/tftpboot/pxelinux.cfg/0A000020')
          .with

        is_expected.to contain_file('/var/lib/tftpboot/pxelinux.cfg/default')
          .with

        is_expected.to contain_file('/var/lib/tftpboot/pxelinux.cfg')
          .with

        is_expected.to contain_file('/var/lib/tftpboot')
          .with

        is_expected.to contain_pxe_install__kickstart('tk14')
          .with

        is_expected.to contain_pxe_install__partitioning__debian('tk14')
          .with

        is_expected.to contain_pxe_install__partitioning__ubuntu('tk14')
          .with

        is_expected.to contain_pxe_install__tftp__host('10.0.0.32')
          .with

        is_expected.to contain_package('tftp-server')
          .with(
          'ensure' => 'present',
        )

        is_expected.to contain_package('xinetd')
          .with(
            'ensure' => 'present',
          )

        is_expected.to contain_service('xinetd')
          .with(
            'ensure' => 'running',
            'enable' => true,
          )

        is_expected.to contain_file('/etc/tftpd.map')
          .with(
            'ensure' => 'file',
            'owner'  => 'root',
            'group'  => 'root',
            'mode'   => '0644',
          )

        if os_facts[:operatingsystem].casecmp('ubuntu').zero?
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

        # is_expected.to contain_class('pxe_install::yum_repos')
        #   .with(
        #     'kickstart_dir'     => '/export/repos/www/kickstart',
        #     'kickstart_url'     => '/kickstart',
        #     'pub_dir'           => '/export/repos/www/pub',
        #     'pub_url'           => '/pub',
        #     'repos_dir'         => '/export/repos/www',
        #     'repos_url'         => '/',
        #     'servername'        => 'repo.local',
        #     'status_allow_from' => ['127.0.0.1'],
        #     'ssl_cert'          => '/etc/pki/httpd/cert.pem',
        #     'ssl_key'           => '/etc/pki/httpd/key.pem',
        #     'ssl_chain'         => '/etc/pki/httpd/chain.pem',
        #     'documentroot'      => '/export/repos/www',
        #     'create_aliases'    => true,
        #   )
      end
    end
  end
end
