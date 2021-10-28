shared_examples 'os::centos::7' do
  puts 'CentOS 7 tests' if ENV['DEBUG'] == '1'
  include_examples 'common::pxe_install'
end
