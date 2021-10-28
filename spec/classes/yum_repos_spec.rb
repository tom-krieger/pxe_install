# frozen_string_literal: true

require 'spec_helper'

describe 'pxe_install::yum_repos' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:params) do
        {
          'reposerver_uri' => 'https://example.com/repos',
          'install_dir' => '/export/test',
        }
      end

      it {
        is_expected.to compile

        is_expected.to contain_file('/export/test')
          .with(
            'ensure' => 'directory',
            'owner'  => 'root',
            'group'  => 'root',
            'mode'   => '0755',
          )

        is_expected.to contain_file('/export/test/7')
          .with(
            'ensure' => 'directory',
            'owner'  => 'root',
            'group'  => 'root',
            'mode'   => '0755',
          )

        is_expected.to contain_file('/export/test/7/CentOS-Base.repo')
          .with(
            'ensure'  => 'file',
            'owner'   => 'root',
            'group'   => 'root',
            'mode'    => '0644',
          )

        is_expected.to contain_file('/export/test/7/CentOS-Debuginfo.repo')
          .with(
            'ensure'  => 'file',
            'owner'   => 'root',
            'group'   => 'root',
            'mode'    => '0644',
          )

        is_expected.to contain_file('/export/test/7/CentOS-fasttrack.repo')
          .with(
            'ensure'  => 'file',
            'owner'   => 'root',
            'group'   => 'root',
            'mode'    => '0644',
          )

        is_expected.to contain_file('/export/test/7/tom.repo')
          .with(
            'ensure'  => 'file',
            'owner'   => 'root',
            'group'   => 'root',
            'mode'    => '0644',
          )

        is_expected.to contain_file('/export/test/7/epel.repo')
          .with(
            'ensure'  => 'file',
            'owner'   => 'root',
            'group'   => 'root',
            'mode'    => '0644',
          )
      }
    end
  end
end
