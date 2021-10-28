require 'spec_helper'

describe 'pxe_install::tftp' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:params) do
        {
          'tftp' => {
            'packages' => ['tftp-server', 'xinetd'],
            'packages_ensure' => 'installed',
            'port' => 69,
            'user' => 'root',
            'group' => 'root',
            'directory' => '/var/lib/tftpboot',
            'pxelinux' => 'pxelinux.cfg',
            'address' => '10.0.0.35',
            'tftpserverbin' => '/usr/sbin/in.tftpd',
            'service' => 'xinetd',
            'service_ensure' => 'running',
            'service_enable' => true,
          },
        }
      end

      it {
        is_expected.to compile

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

        if os_facts[:osfamily].casecmp('redhat').zero?
          is_expected.to contain_file('/etc/xinetd.d/tftp')
            .with(
              'ensure'  => 'file',
              'owner'   => 'root',
              'group'   => 'root',
              'mode'    => '0644',
            )
            .that_notifies('Service[xinetd]')

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
        end

        is_expected.to contain_file('/var/lib/tftpboot/pxelinux.cfg/default')
          .with(
            'ensure' => 'file',
            'owner'  => 'root',
            'group'  => 'root',
            'mode'   => '0644',
            'source' => 'puppet:///modules/pxe_install/tftp-default',
          )

        is_expected.to contain_file('/var/lib/tftpboot/pxelinux.cfg')
          .with(
            'ensure'       => 'directory',
            'purge'        => true,
            'recurselimit' => 1,
            'recurse'      => true,
            'owner'        => 'root',
            'group'        => 'root',
            'mode'         => '0755',
          )

        is_expected.to contain_file('/var/lib/tftpboot')
          .with(
            'ensure' => 'directory',
            'owner'  => 'root',
            'group'  => 'root',
            'mode'   => '0755',
          )
      }
    end
  end
end
