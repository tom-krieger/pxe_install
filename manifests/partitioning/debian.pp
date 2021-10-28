# @summary Create a partion table for Debian systems
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
# @example
#   include pxe_install::partitioning::debian
#
# @api private
define pxe_install::partitioning::debian (
  String $hostname,
  Hash $partitioning,
  String $kickstart_file,
  Optional[String] $template_partitioning = 'pxe_install/debian/partition.epp',
  Optional[String] $template_part_entry   = 'pxe_install/debian/partition_entry.epp',
  Optional[String] $template_part_finish  = 'pxe_install/debian/partition_finish.epp',
) {

  $nr = 400

  concat::fragment { "${hostname}-partition-start":
    content => epp($template_partitioning, {
    }),
    target  => $kickstart_file,
    order   => $nr,
  }

  $partitioning.each |$partition, $partition_data| {

    $min = has_key($partition_data, 'min') ? {
      true    => $partition_data['min'],
      default => 0,
    }

    $prio = has_key($partition_data, 'prio') ? {
      true    => $partition_data['prio'],
      default => 0,
    }

    $max = has_key($partition_data, 'max') ? {
      true    => $partition_data['max'],
      default => 0,
    }

    $fstype = has_key($partition_data, 'fstype') ? {
      true     => $partition_data['fstype'],
      default  => '',
    }

    $primary = has_key($partition_data, 'primary') ? {
      true    => $partition_data['primary'],
      default => $pxe_install::defaults['primary'],
    }

    $format = has_key($partition_data, 'format') ? {
      true    => $partition_data['format'],
      default => '',
    }

    $bootable = has_key($partition_data, 'bootable') ? {
      true    => $partition_data['bootable'],
      default => $pxe_install::defaults['bootable'],
    }

    $method = has_key($partition_data, 'method') ? {
      true    => $partition_data['method'],
      default => '',
    }

    $filesystem =  $method ? {
      'swap'  => '',
      'lvm'   => '',
      default => $fstype,
    }

    $label = has_key($partition_data, 'label') ? {
      true    => $partition_data['label'],
      default => '',
    }

    $mountpoint = has_key($partition_data, 'mountpoint') ? {
      true    => $partition_data['mountpoint'],
      default => $partition,
    }

    $device = has_key($partition_data, 'device') ?  {
      true    => $partition_data['device'],
      default => '',
    }

    $vgname = has_key($partition_data, 'vgname') ? {
      true    => $partition_data['vgname'],
      default => '',
    }

    $lvname = has_key($partition_data, 'lvname') ? {
      true    => $partition_data['lvname'],
      default => '',
    }

    $invg = has_key($partition_data, 'invg') ? {
      true    => $partition_data['invg'],
      default => '',
    }

    $nr = $nr + 1

    $order = has_key($partition_data, 'order') ? {
      true => $partition_data['order'],
      default => $nr,
    }

    concat::fragment { "${hostname}-${partition}":
      content => epp($template_part_entry, {
        min        => $min,
        prio       => $prio,
        max        => $max,
        fstype     => $fstype,
        primary    => $primary,
        bootable   => $bootable,
        format     => $format,
        method     => $method,
        filesystem => $filesystem,
        label      => $label,
        mountpoint => $mountpoint,
        device     => $device,
        vgname     => $vgname,
        lvname     => $lvname,
        invg       => $invg,
      }),
      target  => $kickstart_file,
      order   => $order,
    }
  }

  if $template_part_finish != '' {
    concat::fragment { "${hostname}-partioning-finish":
      content => epp($template_part_finish, {}),
      target  => $kickstart_file,
      order   => 600,
    }
  }
}
