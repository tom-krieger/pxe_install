# frozen_string_literal: true

require 'spec_helper'

describe 'pxe_install::parent_dirs' do
  let(:title) { 'create dir' }
  let(:params) do
    {
      'dir_path' => '/var/www/html/test',
    }
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it {
        is_expected.to compile
        is_expected.to contain_file('/var')
          .with(
            'ensure' => 'directory',
          )
        is_expected.to contain_file('/var/www')
          .with(
            'ensure' => 'directory',
          )
        is_expected.to contain_file('/var/www/html')
          .with(
            'ensure' => 'directory',
          )
        is_expected.to contain_file('/var/www/html/test')
          .with(
            'ensure' => 'directory',
          )
      }
    end
  end
end
