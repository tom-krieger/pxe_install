require 'spec_helper'

describe 'pxe_install::dhcp' do
  let(:pre_condition) do
    <<-EOF
    class { 'pxe_install':
      installserverip    => '10.0.0.2',
      installserver      => 'localhost',
      repo_server        => 'localhost',
      repo_server_ip     => '10.0.0.3',
      repos_dir          => '/export/repos',
      repos_url          => '/',
      scriptdir          => '/export/repos/pub',
      scripturl          => '/pub',
      kickstart_dir      => '/export/repos/www/kickstart',
      kickstart_url      => '/kickstart',
      puppetmaster       => 'localhost',
      puppetmasterip     => '10.0.0.4',
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
    EOF
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:params) do
        {
          'dhcp' => {
            'service_ensure' => 'running',
            'interfaces' => ['ens192'],
            'dns_servers' => ['127.0.0.1'],
            'ntp_servers' => ['127.0.0.1'],
            'next_server' => '127.0.0.1',
            'domain_names' => ['localdomain'],
            'pxefilename' => 'pxelinux.0',
            'ddns_update_style' => 'omapiport',
            'max_lease_time' => 86_400,
            'default_lease_time' => 86_400,
            'logfacility' => 'local7',
            'option_code_50_label' => 'pxegrub',
            'option_code150_value' => 'text',
            'omapiport' => 1234,
            'pools' => {
              'internal' => {
                'network' => '10.0.0.0',
                'mask' => '255.255.255.0',
                'range' => ['10.0.0.180 10.0.0.190'],
                'gateway' => '10.0.0.1',
              },
            },
            'hosts' => {
              'mg5250' => {
                'mac' => '00:1E:8F:A2:B8:DD',
                'ip' => '10.0.0.99',
              },
            },
          },
        }
      end

      it {
        is_expected.to compile

        is_expected.to contain_class('dhcp')
          .with(
            'service_ensure'       => 'running',
            'interfaces'           => ['ens192'],
            'nameservers'          => ['127.0.0.1'],
            'ntpservers'           => ['127.0.0.1'],
            'pxeserver'            => '127.0.0.1',
            'dnsdomain'            => ['localdomain'],
            'pxefilename'          => 'pxelinux.0',
            'omapi_port'           => 1234,
            'ddns_update_style'    => 'omapiport',
            'max_lease_time'       => 86_400,
            'default_lease_time'   => 86_400,
            'logfacility'          => 'local7',
            'option_code150_label' => 'pxegrub',
            'option_code150_value' => 'text',
          )

        is_expected.to contain_dhcp__pool('internal')

        is_expected.to contain_dhcp__host('mg5250')
      }
    end
  end
end
