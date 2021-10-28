#!/bin/bash

if puppet config print server | grep -v -q `hostname`; then
  echo "This task can only be run on the PE master!"; 
  exit 1
fi

if [ -z "${PT_password}" ] ; then
    echo "Please give a password to encrypt!"
    exit 1
fi

python3 -c 'import crypt; print(crypt.crypt("${PT_PASSWORD}", crypt.mksalt(crypt.METHOD_SHA512)))'

exit 0
