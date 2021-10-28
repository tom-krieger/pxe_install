require 'spec_helper'

describe 'pxe_install::tftp::host' do
  let(:title) { '10.0.0.1' }
  let(:params) do
    {
      'ostype'     => 'ubuntu',
      'ensure'     => 'present',
      'prefix'     => '',
      'path'       => '',
      'ksurl'      => '',
      'ksdevice'   => '',
      'puppetenv'  => 'none',
      'puppetrole' => 'none',
      'datacenter' => 'none',
      'locale'     => 'en_US',
      'keymap'     => '',
      'loghost'    => '127.0.0.1',
      'logport'    => 514,
    }
  end
  let(:pre_condition) do
    <<-EOF
    class { 'pxe_install::tftp':
      tftp => {
        packages => ['tftp'],
        packages_ensure => 'installed',
        service => 'tftpd',
        service_ensure => 'running',
        service_enable => true,
        port => 67,
        user => 'tftpd',
        group => 'tftpd',
        tftpserverbin => '/sbin/tftpd',
        directory => '/tftpboot',
        addfress => '0.0.0.0',
      },
    }
    EOF
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it {
        is_expected.to compile

        is_expected.to contain_file('/tftpboot/pxelinux.cfg/0A000001')
          .with(
            'ensure' => 'present',
            'owner'  => 'root',
            'group'  => 'root',
            'mode'   => '0644',
          )
      }
    end
  end
end
