require 'spec_helper'

describe 'pxe_install::kickstart' do
  let(:title) { 'ct02' }

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:pre_condition) do
        <<-EOF
        class { 'pxe_install':
          installserverip    => '10.0.0.2',
          installserver      => 'localhost',
          repo_server        => 'localhost',
          repo_server_ip     => '127.0.0.1',
          repos_dir          => '/export/repos',
          repos_url          => 'http://localhost/repos',
          scriptdir          => '/export/repos/pub',
          scripturl          => 'http://localhost/pub',
          kickstart_dir      => '/export/repos/kickstart',
          kickstart_url      => 'http://localhost/kickstart',
          puppetmaster       => 'localhost',
          puppetmasterip     => '10.0.0.3',
          pkgrepositoryurls  => {},
          debian_mirror      => 'debian.intergenia.de',
          debian_mirror_dir  => '/debian',
          ubuntu_mirror      => 'ubuntu.intergenia.de',
          ubuntu_mirror_dir  => '/ubuntu',
          services           => {},
          machines           => {},
          status_allow_from  => ['127.0.0.1'],
          enabled            => true,
          ssl_cert           => '/etc/pki/httpd/localdomain.de/localdomain.de.cer',
          ssl_key            => '/etc/pki/httpd/localdomain.de/localdomain.de.key',
          ssl_chain          => '/etc/pki/httpd/localdomain.de/fullchain.cer',
          ssl_certs_dir      => '/etc/pki/httpd/localdomain.de/',
        }

        define pxe_install::tftp::host (
          String $ostype,
          Enum['absent', 'present'] $ensure,
          Optional[String] $prefix     = '',
          Optional[String] $path       = '',
          Optional[String] $ksurl      = '',
          Optional[String] $ksdevice   = '',
          Optional[String] $puppetenv  = 'none',
          Optional[String] $puppetrole = 'none',
          Optional[String] $datacenter = 'none',
          Optional[String] $locale     = 'en_US',
          Optional[String] $keymap     = '',
          Optional[String] $loghost    = '',
          Optional[Integer] $logport   = 0,
          Optional[String] $ks         = '',
        ) {

        }
        EOF
      end

      let(:params) do
        {
          'data' => {
            'ensure' => 'present',
            'network' => {
              'hostname' => 'ct02',
              'domain' => ' localdomain',
              'mac' => '08:00:27:77:A4:41',
              'pxefile' => 'pxelinux.0',
              'prefix' => 'ubuntu-installer/amd64',
              'noprompt' => 'noprompt',
              'fixedaddress' => '10.0.0.67',
              'ksdevice' => 'eth0',
              'gateway' => '10.0.0.1',
              'netmask' => '255.255.255.0',
              'dns' => ['10.0.0.62'],
            },
            'rootpw' => '$1$XlmxMqOR$OvdmPRMDMpB6HCmmTYkY51',
            'timezone' => 'Europe/Berlin',
            'ostype' => 'ubuntu',
            'keyboard' => 'de(Macintosh, no dead keys)',
            'keymap' => 'de',
            'language' => 'de',
            'country' => 'DE',
            'locale' => 'en_US.UTF-8',
            'path' => 'ubuntu-installer/amd64/boot-screens',
            'loghost' => '10.0.0.2',
            'logport' => 514,
            'parameter' => {
              'env' => 'production',
              'role' => 'test',
              'dc' => 'test',
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
                  'format' => true,
                  'label' => 'boot',
                  'method' => 'format',
                  'filesystem' => 'ext3',
                },
              },
            },
          },
          'kickstart_dir' => '/export/repos/kickstart',
          'kickstart_url' => 'http://localhost/kickstart',
          'repos_url' => 'http://localhost/repos',
          'scripturl' => 'http://localhost/pub',
          'pkgrepositoryurls' => {
            'centos8' => 'https://repos.example.com/centos/8/BaseOS/x86_64/os,'
          }
        }
      end

      it {
        is_expected.to compile

        is_expected.to contain_concat('/export/repos/kickstart/ct02')
          .with(
            'ensure' => 'present',
            'owner'  => 'root',
            'group'  => 'root',
            'mode'   => '0644',
          )

        is_expected.to contain_pxe_install__partitioning__ubuntu('ct02')
          .with(
            'hostname'       => 'ct02',
            'partitioning'   => {
              'sda' => {
                '/boot' => {
                  'min' => 1024,
                  'prio' => 1024,
                  'max' => 1024,
                  'fstype' => 'ext3',
                  'primary' => true,
                  'bootable' => true,
                  'format' => true,
                  'label' => 'boot',
                  'method' => 'format',
                  'filesystem' => 'ext3',
                },
              },
            },
            'kickstart_file' => '/export/repos/kickstart/ct02',
          )
      }
    end
  end
end
