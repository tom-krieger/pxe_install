# @summary Create a partion table for Ubuntu systems using autoinstall
#
# Create the partion entries for presdeed.
#
# @param hostname
#     The hostname.
#
# @param partitioning
#    Hash with partiotioning information
#
# @param kickstart_file
#    Concat file to add partition information
#
# @param template_partitioning
#    The head template
#
# @param template_part_entry
#    The template to use for a partion 
#
# @param template_part_finish
#    The template to finish the partion information
#
# @param boot_architecture
#    Information about the boot scenario
#
# @api private
# @example
#   include pxe_install::partitioning::ubuntu_autoinstall
class pxe_install::partitioning::ubuntu_autoinstall (
  String $hostname,
  Hash $partitioning,
  String $kickstart_file,
  String $boot_architecture,
  String $template_partitioning = 'pxe_install/debian/partition.epp',
  String $template_part_entry   = 'pxe_install/debian/partition_entry.epp',
  String $template_part_finish  = 'pxe_install/debian/partition_finish.epp',
) {
  $nr = 400
  $devices = get_partition_devices($partitioning)

  concat::fragment { "${hostname}-partition-start":
    content => epp($template_partitioning, {
        autopart          => $devices,
        boot_architecture => $boot_architecture,
    }),
    target  => $kickstart_file,
    order   => $nr,
  }

  $partitioning.each |$partition| {
    $nr = $nr + 1
    $order = has_key($partition, 'order') ? {
      true    => $partition['order'],
      default => $nr,
    }

    concat::fragment { "${hostname}-${partition}":
      content => epp($template_part_entry, {
          data => $partition,
      }),
      target  => $kickstart_file,
      order   => $order,
    }
  }
}