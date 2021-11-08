# @summary Setup DHCP server
#
# Configure DHCP server and add static DHCP entries, create pools
#
# @param dhcp
#    A hash with al dhcp entries
#
# @example
#   include pxe_install::dhcp
#
# @api private
class pxe_install::dhcp (
  Hash $dhcp
){
  if has_key($dhcp, 'default_filename') {
    $pxefilename = $dhcp['default_filename']
  } elsif $pxe_install::defaults['pxefile'] != '' {
    $pxefilename = $pxe_install::defaults['pxefile']
  } else {
    # Default 
    $pxefilename = 'pxelinux.0'
  }

  if has_key($dhcp, 'ipxe_bootstrap') and has_key($dhcp, 'ipxe_filename') {
    $ipxe_config = {
      ipxe_bootstrap => $dhcp['ipxe_bootstrap'],
      ipxe_filename => $dhcp['ipxe_filename'],
    }
  } else {
    $ipxe_config = {}
  }

  if has_key($dhcp, 'globaloptions') {
    $_globaloptions = $dhcp['globaloptions']
  } else {
    $_globaloptions = []
  }

  $dhcp_global_options = {
    service_ensure       => running,
    interfaces           => $dhcp['interfaces'],
    nameservers          => $dhcp['dns_servers'],
    ntpservers           => $dhcp['ntp_servers'],
    pxeserver            => $dhcp['next_server'],
    dnsdomain            => $dhcp['domain_names'],
    pxefilename          => $pxefilename,
    omapi_port           => $dhcp['omapiport'],
    ddns_update_style    => $dhcp['ddns_update_style'],
    max_lease_time       => $dhcp['max_lease_time'],
    default_lease_time   => $dhcp['default_lease_time'],
    logfacility          => $dhcp['logfacility'],
    option_code150_label => $dhcp['option_code_50_label'],
    option_code150_value => $dhcp['option_code150_value'],
    globaloptions        => $_globaloptions,
  }

  $_dhcp_global_options = merge($dhcp_global_options, $ipxe_config)

  class { 'dhcp':
    * => $_dhcp_global_options,
  }

  # loop over subnets
  if has_key($dhcp, 'pools') {
    $dhcp['pools'].each |$pool_name, $pool_data| {
      dhcp::pool { $pool_name:
        * => $pool_data,
      }
    }
  }

  # loop over dhcp entried for dynamic ips
  if has_key($dhcp, 'hosts') {
    $dhcp['hosts'].each |$host_name, $host_data| {
      dhcp::host { $host_name:
        *       => $host_data,
        comment => "dynamic ip entry for ${host_name}",
      }
    }
  }
}
