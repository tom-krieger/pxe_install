# frozen_string_literal: true

require 'spec_helper'

describe 'pxe_install::samba' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) do
        os_facts.merge!(
          'samba_version' => '4.3.0',
        )
      end
      let(:params) do
        {
          'samba' => {
            'domain' => 'test',
            'realm' => 'test.example.com',
            'smbname' => 'smbtest',
            'security' => 'auto',
            'nsswitch' => false,
            'logtosyslog' => false,
            'krbconf' => false,
          },
        }
      end

      it {
        is_expected.to compile
      }
    end
  end
end
