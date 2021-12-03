require 'pp'

Puppet::Functions.create_function(:getdevices) do
  dispatch :devices do
    required_param 'Hash', :partitioning
    return_type 'String'
  end

  def devices(partitioning)
    device_list = []
    pp partitioning
    if partitioning.nil? || partitioning.empty? 
      'fail'
    else
    #partitioning.each do |part, part_data| 
    #  pp part_data
   #   if part_data.key?('device')
    #    device_list.push($part_data['device'])
    #  end
    #end
    #device_list.join(' ')
      'ok'
    end
  end
end