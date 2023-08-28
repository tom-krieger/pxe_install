# @summary
#    Check if a hash contains a particular key
#
# @param hash
#    The hash to search
#
# @param key
#    The key to search
#
# @return ret
#    Boolean return value which is true if the hash contans the key. Otherwise false is returned.
#
# @api private
function pxe_install::hash_key(Hash $hash, String $key) >> Boolean {
  if $key in $hash {
    $ret = true
  } else {
    $ret = false
  }

  $ret
}
