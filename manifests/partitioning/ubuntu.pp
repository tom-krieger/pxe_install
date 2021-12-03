# @summary Create a partion table for Ubuntu systems
#
#  Create the partion entries for presdeed.
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
# @example
#   include pxe_install::partitioning::ubuntu
#
# @api private
define pxe_install::partitioning::ubuntu (
  String $hostname,
  Hash $partitioning,
  String $kickstart_file,
) {
  $template_partitioning = 'pxe_install/ubuntu/partition.epp'
  $template_part_entry = 'pxe_install/ubuntu/partition_entry.epp'
  $template_part_finish = 'pxe_install/ubuntu/partition_finish.epp'

  pxe_install::partitioning::debian { $hostname:
    hostname              => $hostname,
    partitioning          => $partitioning,
    kickstart_file        => $kickstart_file,
    template_partitioning => $template_partitioning,
    template_part_entry   => $template_part_entry,
    template_part_finish  => $template_part_finish,
  }
}
