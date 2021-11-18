#!/bin/bash

basedir=$PT_tftp_basedir
os=$PT_os
osvers=$PT_os_version
ossubvers=$PT_os_subversion
arch_name=`basename $archive`
arch_dir=`dirname $archive`
filename=`basename $archive`
archive="/tmp/${flename}"

curl -kSsL -o "${archive}" "$PT_archive"
if [ $? != 0 ] ; then
    echo "Download of net installer archive failed!"
    exit 1
fi

if [[ $archive =~ \.iso$ ]] ; then
    mnt=$(mount | grep "/tmp/installer")
    if [ ! -z "$mnt" ] ; then
        umount /tmp/installer
    fi
    rm -rf /tmp/installer
    mkdir -p /tmp/installer
    mount -o loop $archive /tmp/installer
else
    echo "Only iso files are accepted!"
    exit 1
fi

if [ ! -d /tmp/installer/isolinux ] ; then
    echo "seems not a valid netinstaller iso"
    exit 2
fi

cd /tmp/installer/isolinux
mkdir -p "${basedir}/${os}/${osvers}/${ossubvers}"
for f in boot.msg initrd.img isolinux.bin isolinux.cfg vmlinuz splash.png ; do
    cp $f "${basedir}/${os}/${osvers}/${ossubvers}/"
done

cd /tmp
umount /tmp/installer
rm -f $archive

exit 0
