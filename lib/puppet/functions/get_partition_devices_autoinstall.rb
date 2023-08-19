# frozen_string_literal: true

# get_partition_devices_autoinstall.rb
# Examin partitioning information of Debian/Ubuntu hosts and get all
# used disk devices
Puppet::Functions.create_function(:get_partition_devices_autoinstall) do
    dispatch :get_partition_devices_autoinstall do
      required_param 'Array', :partitioning
      return_type 'Array'
    end
  
    def get_partition_devices_autoinstall(partitioning)
      return 'fail' if partitioning.empty?
      return 'nil' if partitioning.nil?
  
      device_list = []
      partitioning.each do |part_data|
        if part_data.key?('device')
          device_list.push(part_data['device'])
        end
      end
      return 'failed' if device_list.empty?
      device_list.uniq unless device_list.empty?
    end
  end
  