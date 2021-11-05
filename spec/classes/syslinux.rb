# frozen_string_literal: true

require 'spec_helper'

describe 'pxe_install::syslinux' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:params) do
        {
          tftpboot_dir: '/var/lib/tftpboot',
          download_url: 'https://www.kernel.org/pub/linux/utils/boot/syslinux'
        }
      end

      it { is_expected.to compile }
    end
  end
end
