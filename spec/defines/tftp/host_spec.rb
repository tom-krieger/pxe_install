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

        is_expected.to contain_file('/tftpboot/pxelinux.0')
          .with(
          'ensure' => 'file',
          'owner'  => 'root',
          'group'  => 'root',
          'mode'   => '0644',
        )

        is_expected.to contain_file('/tftpboot/pxelinux.cfg/default')
          .with(
            'ensure' => 'file',
            'owner'  => 'root',
            'group'  => 'root',
            'mode'   => '0644',
          )

        is_expected.to contain_file('/tftpboot/pxelinux.cfg')
          .with(
            'ensure'       => 'directory',
            'purge'        => true,
            'recurselimit' => 1,
            'recurse'      => true,
            'owner'        => 'root',
            'group'        => 'root',
            'mode'         => '0755',
          )

        is_expected.to contain_file('/tftpboot')
          .with(
            'ensure' => 'directory',
            'owner'  => 'root',
            'group'  => 'root',
            'mode'   => '0755',
          )

        is_expected.to contain_package('tftp')
          .with(
            'ensure' => 'present',
          )

        is_expected.to contain_service('tftpd')
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
