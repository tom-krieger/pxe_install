# @summary ACreate partitioning for redhat/CentOPS systems
#
# Create the partion entries for the kickstart file.
#
# @param hostname
#    The hostname
#
# @param partitioning
#    Hash with partition information
#
# @param kickstart_file
#    Concat file to add partition information
#
# @example
#   include pxe_install::partitioning::redhat
#
# @api private
define pxe_install::partitioning::redhat (
  String $hostname,
  Hash $partitioning,
  String $kickstart_file,
) {
  $template_partitioning = 'pxe_install/redhat/partition_entry.epp'

  $partitioning.each |$partition, $partition_data| {
    $type = has_key($partition_data, 'type') ? {
      true    => $partition_data['type'],
      default => '',
    }

    $vgname = has_key($partition_data, 'vgname') ? {
      true    => $partition_data['vgname'],
      default => ''
    }

    $fstype = has_key($partition_data, 'fstype') ? {
      true    => $partition_data['fstype'],
      default => '',
    }

    $size = has_key($partition_data, 'size') ? {
      true    => $partition_data['size'],
      default => 0,
    }

    $primary = has_key($partition_data, 'primary') ? {
      true    => $partition_data['primary'],
      default => $pxe_install::defaults['primary'],
    }

    $grow = has_key($partition_data, 'grow') ? {
      true    => $partition_data['grow'],
      default => '',
    }

    $ondisk = has_key($partition_data, 'ondisk') ? {
      true    => $partition_data['ondisk'],
      default => '',
    }

    $pvol = has_key($partition_data, 'pvol') ? {
      true    => $partition_data['pvol'],
      default => '',
    }

    $diskname = has_key($partition_data, 'diskname') ? {
      true    => $partition_data['diskname'],
      default => '',
    }

    $level = has_key($partition_data, 'level') ? {
      true    => $partition_data['level'],
      default => '',
    }

    $part_disks = has_key($partition_data, 'disks')  ? {
      true    => join($partition_data['disks'], ' '),
      default => '',
    }

    $disk_device = has_key($partition_data, 'disk_device') ? {
      true    => $partition_data['disk_device'],
      default => '',
    }

    $real_type = $type ? {
      'pvol'   => 'part',
      default  => $type,
    }

    concat::fragment { "${hostname}-${partition}":
      content => epp($template_partitioning, {
          partname    => $partition,
          type        => $real_type,
          vgname      => $vgname,
          fstype      => $fstype,
          size        => $size,
          primary     => $primary,
          grow        => $grow,
          ondisk      => $ondisk,
          pvol        => $pvol,
          diskname    => $diskname,
          level       => $level,
          part_disks  => $part_disks,
          disk_device => $disk_device,
      }),
      order   => 500,
      target  => $kickstart_file,
    }
  }
}
