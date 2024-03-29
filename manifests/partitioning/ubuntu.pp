# @summary Create a partion table for Ubuntu systems
#
# Create the partion entries for presdeed.
#
# @param hostname
#    The hostname.
#
# @param partitioning
#    Hash with partiion information
#
# @param kickstart_file
#    Concat file to add partition information
#
# @param boot_architecture
#    Information about the boot scenario
#
# @param major
#    Ubuntu major version
#
# @example
#   include pxe_install::partitioning::ubuntu
#
# @api private
define pxe_install::partitioning::ubuntu (
  String $hostname,
  Variant[Hash, Array] $partitioning,
  String $kickstart_file,
  String $boot_architecture,
  String $major = '20',
) {
  if $major < '22' {
    $template_partitioning = 'pxe_install/ubuntu/partition.epp'
    $template_part_entry = 'pxe_install/ubuntu/partition_entry.epp'
    $template_part_finish = 'pxe_install/ubuntu/partition_finish.epp'
    $class =

    pxe_install::partitioning::debian { $hostname:
      hostname              => $hostname,
      partitioning          => $partitioning,
      kickstart_file        => $kickstart_file,
      template_partitioning => $template_partitioning,
      template_part_entry   => $template_part_entry,
      template_part_finish  => $template_part_finish,
      boot_architecture     => $boot_architecture,
    }
  } else {
    $template_partitioning = 'pxe_install/ubuntu/22/partition.epp'
    $template_part_entry = 'pxe_install/ubuntu/22/partition_entry.epp'
    $template_part_finish = 'pxe_install/ubuntu/22/partition_finish.epp'

    pxe_install::partitioning::ubuntu_autoinstall { $hostname:
      hostname              => $hostname,
      partitioning          => $partitioning,
      kickstart_file        => $kickstart_file,
      template_partitioning => $template_partitioning,
      template_part_entry   => $template_part_entry,
      template_part_finish  => $template_part_finish,
      boot_architecture     => $boot_architecture,
    }
  }
}
