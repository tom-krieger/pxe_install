require 'spec_helper_acceptance'
require 'pp'

ppc = <<-PUPPETCODE
include pxe_install
PUPPETCODE

puts 'applying manifests' if ENV['DEBUG'] == '1'
# hiera_config_path = File.expand_path(File.join(__FILE__, '../../..', 'data/acceptance/hiera.yaml'))
hiera_config_path = '/etc/puppetlabs/code/environments/production/modules/pxe_install/data/acceptance/hiera.yaml'
# puts "hiera config #{hiera_config_path}"
ret = apply_manifest(ppc, hiera_config: hiera_config_path)
puts "retcode 1 = #{ret['exit_code']}" if ENV['DEBUG'] == '1'
# puts "#{ret['stderr']}\n"

ret = apply_manifest(ppc, hiera_config: hiera_config_path, catch_changes: false)
puts "retcode 2 = #{ret['exit_code']}" if ENV['DEBUG'] == '1'
# puts "#{ret['stderr']}\n"

ret = apply_manifest(ppc, hiera_config: hiera_config_path, catch_changes: false)
puts "retcode 3 = #{ret['exit_code']}" if ENV['DEBUG'] == '1'
# puts "#{ret['stderr']}\n"

osfamily = os[:family].downcase
release = os[:release].to_s.split('.')[0]

puts "#{os[:family]} #{os[:release]} #{release}" if ENV['DEBUG'] == '1'

case osfamily
when 'centos' || 'redhat'
  case release
  when '6'
    describe 'Install server CentOS 6' do
      include_examples 'os::centos::6'
    end
  when '7'
    describe 'Install server CentOS 7' do
      include_examples 'os::centos::7'
    end
  when '8'
    describe 'Install Server CentOS 8' do
      include_examples 'os::centos::8'
    end
  else
    puts "unknown os: #{osfamily}-#{release}"
  end
end
