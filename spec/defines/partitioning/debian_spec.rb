require 'spec_helper'

describe 'pxe_install::partitioning::debian' do
  let(:title) { 'sda' }
  let(:params) do
    {
      'hostname' => 'test',
      'partitioning' => {
        '/boot' => {
          'min' => 1024,
          'prio' => 1024,
          'max' => 1024,
          'fstype' => 'ext3',
          'primary' => true,
          'bootable' => true,
          'format' => true,
          'label' => 'boot',
          'method' => 'format',
          'filesystem' => 'ext3',
        },
      },
      'kickstart_file' => 'test',
    }
  end

  let(:pre_condition) do
    <<-EOF
    class { 'pxe_install':
      installserverip => '10.0.0.47',
      installserver => 'inst.example.com',
      repo_server => 'repo.example.com',
      repo_server_ip => '10.0.0.48',
      repos_dir => '/export/www',
      repos_url => '/repos',
      script_dir => /export/www/pub',
      script_url => '/pub',
      kickstart_dir => '/export/www/kickstart',
      kickstart_url => '/kickstart',
      challenge_password => 'ENC[PKCS7,MIIBeQYJKoZI]',
      defaults => {
        primary => false,
        bootable => false,
      },
    }
    EOF
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it {
        is_expected.to compile

        is_expected.to contain_concat__fragment('test-partition-start')
          .with(
            'target' => 'test',
            'order' => 400,
          )

        is_expected.to contain_concat__fragment('test-/boot')
          .with(
            'target'  => 'test',
            'order'   => 402,
          )

        is_expected.to contain_concat__fragment('test-partioning-finish')
          .with(
            'target'  => 'test',
            'order'   => 600,
          )
      }
    end
  end
end
