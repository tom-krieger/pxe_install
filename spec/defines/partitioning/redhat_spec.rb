require 'spec_helper'

describe 'pxe_install::partitioning::redhat' do
  let(:title) { 'sda' }
  let(:params) do
    {
      'hostname' => 'test',
      'partitioning' => {
        '/boot' => {
          'type' => 'part',
          'fstype' => 'ext3',
          'primary' => true,
          'size' => 1024,
          'ondisk' => 'sda',
        },
      },
      'kickstart_file' => 'test',
    }
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it {
        is_expected.to compile

        is_expected.to contain_concat__fragment('test-/boot')
          .with(
            'order'   => 500,
            'target'  => 'test',
          )
      }
    end
  end
end
