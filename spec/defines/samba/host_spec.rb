# frozen_string_literal: true

require 'spec_helper'

describe 'pxe_install::samba::host' do
  let(:title) { 'test' }
  let(:params) do
    {
      'tftpboot_dir' => '/var/lib/tftpboot/windows',
      'osversion' => '2019',
      'macaddress' => '00:11:22:33:44:55',
      'boot_architecture' => 'uefi',
      'fixedaddress' => '10.0.0.77',
      'subnet' => '255.255.255.0',
      'gateway' => '10.0.0.1',
      'dns' => ['10.0.0.65'],
      'puppetmaster' => 'puppetmaster.localdomain',
      'puppetrole' => 'test',
      'datacenter' => 'testdc',
      'puppetenv' => 'production',
      'agent' => 'y',
    }
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it {
        is_expected.to compile

        is_expected.to contain_file('/var/lib/tftpboot/windows/001122334455.cfg')
          .with(
            'ensure' => 'file',
            'owner' => 'root',
            'group' => 'root',
            'mode' => '0644',
          )
      }
    end
  end
end
