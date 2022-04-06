# Changelog

All notable changes to this project will be documented in this file.

## 0.3.6

* Added unattended install configurations for Windows 2019 Server
* Added Windows install script template
* Create directory structure within tftpboot directory
* configurable windows locale and input locale settings

## 0.3.5

_install_ is deprecated for redhat 8 kickstarts and will no longer included into Redhat 8 kickstarts.

## 0.3.4

not published

## 0.3.3

Enable Debian and Ubuntu preseeds with more than one disk. Introduced defaultignore flag 
for DEbain und Ubunto preseeds.

## 0.3.2

* fixed a proplem with Debian preseed files

## 0.3.1

* broken, not published

## v0.3.0

* added Samba support to enable PXE installation of Windows
* added Windows PXE installation support, create dhcp entries and tftp entries
* added support for uefi and bios installations
* manage tftpboot directory, download syslinux and wimboot

## v0.2.4

* fixed an issue with creating necessary directories

## v0.2.3

* added support for Debian 10

## v0.2.2

* added unit test hiera configuration
* removed old unused files

## v0.2.1

* make filename for DHCP pxe boot configurable

## v0.2.0

* Added support for Ubuntu/Debian
* removed some ununsed or unnecessary code
* make node config much easier as using same options for Redhat like and Debian like nodes

## v0.1.0

Initial release, never published
