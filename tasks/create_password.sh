#!/bin/bash

if puppet config print server | grep -v -q `hostname`; then
  echo "This task can only be run on the PE master!"; 
  exit 1
fi

if [ -z "${PT_password}" ] ; then
    echo "Please give a password to encrypt!"
    exit 1
fi

/usr/bin/openssl passwd -6 ${PT_password}

exit 0
