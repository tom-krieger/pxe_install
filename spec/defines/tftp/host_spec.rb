require 'spec_helper'
require 'pp'

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
        windows_directory => '/windows',
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

        content = catalogue.resource('file', '/tftpboot/pxelinux.cfg/0A000001').send(:parameters)[:content]
        expected_lines = [
          'path /boot-screens',
          'prompt 0',
          'timeout 0',
          'default ks',
          '',
          'label ks',
          '        menu label ^ks',
          '        menu default',
          '        kernel /linux',
          '        append noprompt url= priority=critical vga=788 initrd=/initrd.gz interface= auto=true log_host=127.0.0.1 log_port=514 puppetenv=none role=none dc=none ---',
        ]
        expect(content.split("\n")).to match_array(expected_lines)

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

        is_expected.to contain_file('/tftpboot/windows')
          .with(
            'ensure' => 'directory',
          )

        is_expected.to contain_pxe_install__parent_dirs('create windows directory')
          .with(
            'dir_path' => '/tftpboot/windows',
          )

        if os_facts[:osfamily].casecmp('debian').zero?
          is_expected.to contain_file('/etc/default/tftpd-hpa')
            .with(
              'ensure' => 'file',
              'owner'  => 'root',
              'group'  => 'root',
              'mode'   => '0644',
            )
          content = catalogue.resource('file', '/etc/default/tftpd-hpa').send(:parameters)[:content]
          expected_lines = [
            '# /etc/default/tftpd-hpa',
            '',
            'TFTP_USERNAME="tftpd"',
            'TFTP_DIRECTORY="/tftpboot"',
            'TFTP_ADDRESS="172.16.254.254:67"',
            'TFTP_OPTIONS="--secure -4 -v -v -v -v -m /etc/tftpd.map"',
          ]
          expect(content.split("\n")).to match_array(expected_lines)
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
