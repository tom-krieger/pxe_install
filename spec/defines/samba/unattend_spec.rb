# frozen_string_literal: true

require 'spec_helper'

describe 'pxe_install::samba::unattend' do
  let(:title) { 'test' }
  let(:params) do
    {
      'unattend_dir' => '/var/lib/tftpboot/windows/unattend',
      'osversion' => '2019',
      'win_domain' => 'localhost.localdomain',
      'win_locale' => 'en-US',
      'win_input_locale' => 'en-US',
      'boot' => 'bios',
    }
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it {
        is_expected.to compile

        is_expected.to contain_file('/var/lib/tftpboot/windows/unattend/test.xml')
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
