# frozen_string_literal: true

require 'spec_helper'

describe 'pxe_install::winipxe' do
  let(:pre_condition) do
    <<-EOF
    require pxe_install
    EOF
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:params) do
        {
          tftpboot_dir: '/var/lib/tftpboot',
          winpe_dir: 'winpe'
        }
      end

      it { 
        is_expected.to compile
      
        is_expected.tp contain_archive("/var/lib/tftpboot/ipxe.efi")
          .with(
            'ensure' => 'present',
            'source' => 'http://boot.ipxe.org/ipxe.efi',
            'user'   => 'root',
            'group'  => 'root',
          )
      
        is_expected.to contain_file("/var/lib/tftpboot/winpe.ipxe")
          .with(
            'ensure'  => 'file',
            'owner'   => 'root',
            'group'   => 'root',
            'mode'    => '0755',
          )
      
      }
    end
  end
end
