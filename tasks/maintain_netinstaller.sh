#!/bin/sh

# Puppet Task Name: maintain_netinstaller

set -e

function download_installer() {
    echo "downloading $1 to $2"
    curl -kSsL -o "${1}" "${2}"
    if [ $? != 0 ] ; then
        echo "Download of net installer archive failed!"
        exit 1
    fi
}

function install_debian_ubuntu() {

    arch_name=$1
    archive=$2
    basedir=$3
    os=$4
    osvers=$5

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
        echo "not yet implemented OS: $os"
        exit 2
    fi

    mkdir -p "${basedir}/${os}/${osvers}"
    echo "copying recursively $src ${basedir}/${os}/${osvers}/"
    cp -r $src "${basedir}/${os}/${osvers}/"
    rm -f $archive
}

function install_centos() {

    archive=$1
    basedir=$2
    os=$3
    osvers=$4
    ossubves=$5

    if [[ $archive =~ \.iso$ ]] ; then
        mnt=$(mount | grep "/tmp/installer")
        if [ ! -z "$mnt" ] ; then
            umount /tmp/installer
        fi
        rm -rf /tmp/installer
        mkdir -p /tmp/installer
        mount -o loop $archive /tmp/installer
    else
        echo "Only iso files are accepted for CentOS!"
        exit 2
    fi

    if [ ! -d /tmp/installer/isolinux ] ; then
        echo "Seems not to be a valid netinstaller iso!"
        exit 2
    fi

    cd /tmp/installer/isolinux
    mkdir -p "${basedir}/${os}/${osvers}/${ossubvers}"
    for f in boot.msg initrd.img isolinux.bin isolinux.cfg vmlinuz splash.png ; do
        echo "copying $f ${basedir}/${os}/${osvers}/${ossubvers}/"
        cp $f "${basedir}/${os}/${osvers}/${ossubvers}/"
    done

    cd /tmp
    umount /tmp/installer
    rm -f $archive
}

basedir=$PT_tftp_basedir
os=$PT_os
osvers=$PT_os_version
ossubvers=$PT_os_subversion
arch_name=`basename $PT_archive_url`
arch_dir=`dirname $PT_archive_url`
filename=`basename $PT_archive_url`
archive="/tmp/${filename}"

case $os in
    'centos')
        if [ "${osvers}" != "7" -a "${osvers}" != "8" ] ; then
            echo "CentOS support version 7 and 8 only!"
            exit 2
        fi

        if [ -z "${ossubvers}" ] ; then
            echo "CentOS needs a subversion too!"
            exit 2
        fi

        download_installer "${archive}" "${PT_archive_url}"
        install_centos "${archive}" "${basedir}" "${os}" "${osvers}" "${ossubvers}"
        ;;

    'ubuntu')
        if [ "${osvers}" != '18.04' -a "${osvers}" != '20.04' ] ; then
            echo "Only Ubuntu 18.04 and 20.04 are supported!"
            exit 2
        fi

        download_installer "${archive}" "${PT_archive_url}"
        install_debian_ubuntu "${arch_name}" "${archive}" "${basedir}" "${os}" "${osvers}"
        ;;

    'debian')
        if [ "${osvers}" != '9' -a "${osvers}" != '10' ] ; then
            echo "Only Debian 9 and 10 are supported!"
            exit 2
        fi

        download_installer "${archive}" "${PT_archive_url}"
        install_debian_ubuntu "${arch_name}" "${archive}" "${basedir}" "${os}" "${osvers}"
        ;;
    *)
        echo "unsupported OS ${os}!"
        exit 3
        ;;

esac

exit 0
