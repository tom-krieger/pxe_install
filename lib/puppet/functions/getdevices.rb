require 'pp'

Puppet::Functions.create_function(:getdevices) do
  dispatch :getdevices do
    required_param 'Hash', :partitioning
    return_type 'String'
  end

  def getdevices(partitioning)
    device_list = []
    return 'fail' if partitioning.empty? 
    partitioning.each do |part, part_data| 
      if part_data.key?('device')
        device_list.push($part_data['device'])
      end
    end
    return 'failed' if device_list.empty?
    return device_list.join(' ') if ! device_list.empty?
  end
end