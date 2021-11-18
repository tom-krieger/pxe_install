#!/bin/bash

set -e

basedir=$PT_tftp_basedir
os=$PT_os
osvers=$PT_os_version
arch_name=`basename $archive`
arch_dir=`dirname $archive`
filename=`basename $archive`
archive="/tmp/${flename}"


curl -kSsL -o "${archive}" "$PT_archive"
if [ $? != 0 ] ; then
    echo "Download of net installer archive failed!"
    exit 1
fi

rm -rf /tmp/installer

if [[ $arch_name =~ \.tar.gz$ ]] ; then
    mkdir /tmp/installer
    tar xfz $archive -C /tmp/installer
elif [[ $arch_name =~ \.zip$ ]] ; then
    unzip $archive -d /tmp/installer
else
    echo "unknown type of archive: $arch_name"
    exit 1
fi

if [ $os = 'ubuntu' ] ; then

    if [ ! -d "/tmp/installer/ubuntu-installer/amd64" ] ; then
        echo "seems not a valid ubuntu netinstaller"
        exit 3
    fi

    src="/tmp/installer/ubuntu-installer/amd64"

elif [ $os = 'debian' ] ; then

    if [ ! -d "/tmp/installer/debian-installer/amd64" ] ; then
        echo "seems not a valid debian netinstaller"
        exit 3
    fi

    src="/tmp/installer/debian-installer/amd64"  
    
else
    echo "not yet implemented os: $os"
    exit 2
fi

mkdir -p "${basedir}/${os}/${osvers}"
cp -r $src "${basedir}/${os}/${osvers}/"
rm -f $archive

exit 0
