require 'pp'

Puppet::Functions.create_function(:get_partition_devices) do
  dispatch :get_partition_devices do
    required_param 'Hash', :partitioning
    return_type 'String'
  end

  def get_partition_devices(partitioning)
    scope = closure_scope
    return 'fail' if partitioning.empty? 
    return 'nil' if partitioning.nil?

    device_list = []
    partitioning.each do |part, part_data| 
      if part_data.key?('device')
        device_list.push(part_data['device'])
      end
    end
    return 'failed' if device_list.empty?
    return device_list.join(' ') if ! device_list.empty?
  end
end