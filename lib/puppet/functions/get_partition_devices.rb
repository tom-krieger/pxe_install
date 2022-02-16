# frozen_string_literal: true

# get_partition_devices.rb
# Examin partitioning information of Debian/Ubuntu hosts and get all
# used disk devices
Puppet::Functions.create_function(:get_partition_devices) do
  dispatch :get_partition_devices do
    required_param 'Hash', :partitioning
    return_type 'String'
  end

  def get_partition_devices(partitioning)
    return 'fail' if partitioning.empty?
    return 'nil' if partitioning.nil?

    device_list = []
    partitioning.each do |_part, part_data|
      if part_data.key?('device')
        device_list.push(part_data['device'])
      end
    end
    return 'failed' if device_list.empty?
    return device_list.uniq.join(' ') unless device_list.empty?
  end
end
