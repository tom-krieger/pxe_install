# @summary
#    Convert a ip from digits into hex.
#
# @param ip
#    The ip to convert, e. g. 10.0.0.1
#
# @return IP in hey format
#
function pxe_install::hex_ip(String $ip) >> String {
  $octs = $ip.split(/\./)
  $a = sprintf('%<a>X', {'a' => $octs[0]})
  if($a.length < 2) {
    $part1 = "0${a}"
  } else {
    $part1 = $a
  }
  $b = sprintf('%<a>X', {'a' => $octs[1]})
  if($b.length < 2) {
    $part2 = "0${b}"
  } else {
    $part2 = $b
  }
  $c = sprintf('%<a>X', {'a' => $octs[2]})
  if($c.length < 2) {
    $part3 = "0${c}"
  } else {
    $part3 = $c
  }
  $d = sprintf('%<a>X', {'a' => $octs[3]})
  if($d.length < 2) {
    $part4 = "0${d}"
  } else {
    $part4 = $d
  }
  $iphex = "${part1}${part2}${part3}${part4}"
  $iphex
}
