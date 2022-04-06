# @summary create unattended boot file
#
# Create a configuration file according to host configuration.
#
# @param boot
#    The boot method
#
# @param osversion
#    The Windows version, e. g. 2019
#
# @param win_domain
#    The domain of the Windows server
#
# @param win_locale
#    The locale settings
#
# @param win_input_locale
#    The settings for input locales
#
# @param unattend_dir
#    Te directory where to write the file
#
# @api private
define pxe_install::samba::unattend (
  Enum['bios', 'uefi'] $boot,
  String $osversion,
  String $win_domain,
  String $win_locale,
  String $win_input_locale,
  Stdlib::Absolutepath $unattend_dir,
) {

  file { "${unattend_dir}/${title}.xml":
    ensure  => file,
    content => epp("pxe_install/windows/${osversion}_${boot}.xml.epp", {
      domain           => $win_domain,
      win_locale       => $win_locale,
      win_input_locale => $win_input_locale,
    }),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }
}
