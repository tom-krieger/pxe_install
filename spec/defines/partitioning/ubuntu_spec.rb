require 'spec_helper'

describe 'pxe_install::partitioning::ubuntu' do
  let(:title) { 'sda' }
  let(:params) do
    {
      'hostname' => 'test',
      'partitioning' => {
        'sda' => {
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
      },
      'kickstart_file' => 'test',
    }
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it {
        is_expected.to compile

        is_expected.to contain_pxe_install__partitioning__debian('test')
          .with(
            'hostname'              => 'test',
            'partitioning'          => {
              'sda' => {
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
            },
            'kickstart_file'        => 'test',
            'template_partitioning' => 'pxe_install/ubuntu/partition.epp',
            'template_part_entry'   => 'pxe_install/ubuntu/partition_entry.epp',
            'template_part_finish'  => 'pxe_install/ubuntu/partition_finish.epp',
          )

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
