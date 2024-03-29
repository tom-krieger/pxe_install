# pxe_install

## `Table of Contents`

1. [Description](#description)
2. [Setup](#setup)
    * [What pxe_install affects](#what-pxe_install-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with pxe_install](#beginning-with-pxe_install)
3. [Usage](#usage)
    * [Install server definitions](#install-server-definitions)
    * [Services](services)
    * [TFTP service](#tftp-service)
    * [DHCP servie](#dhcp-service)
    * [SAMBA service](#samba-service)
    * [Node configuration](#node-configuration)
      * [Node network configuration](#node-network-configuration)
      * [Node parameter configuration](#node-parameter-configuration)
      * [Node user configuration](#node-user-configuration)
      * [Node partition configuration](#node-partition-configuration)
    * [Default values](#default-values)
    * [Minimal node configuration examples](#minima-node-configuration-examples)
4. [Tasks](#tasks)
5. [Unit tests](#unit-tests)
6. [Limitations](#limitations)
7. [Contributors](#contributors)
8. [Known issues](*known-issues)

## `Description`

The pxe_install module helps setting up a Linux based install server. It takes care about configuring Apache webserver, DHCP server and TFTP server. It creates all necessary entries from Hiera data including partitioning.

## `Setup`

The module needs definitions for each server to be installed and can use configurable default values. It is highly recommended to have all this data in Hiera configuration files.

### `What pxe_install affects`

This install server modules installs packages to run a dhcp and tftp server. If you have already a dhcp server running, keep in mind that a server is broadcasting during install and you might receive a wrong DHCP answer. As during the install process some files need to be downloaded to the installing server, this module configures an Apache webserver with all needed vhosts.

### `Setup Requirements`

PXE bootstrapping servers need network installers for the opeating systems. This module does not maintain the tftpboot directory to have all needed files available. You must take care about these files yourself. But this module includes a plan to upload and install network boot configurations for Debiam, Ubuntu and CentOS.

This module configures an Apache webserver with http and https access. The needed SSL certifiates have to be installed have to be available on the host.

### `Beginning with pxe_install`

It is highly recommended, to add all configuration into the install server's Hiera node definition file. Here's a short example how you can organize this in your control repository. The example is reduced to the parts regarding the PXE install server.

Your Hiera configuration file `hiera.yaml` can look like this.

```yaml
---
version: 5
defaults:
  datadir: data
  data_hash: yaml_data

hierarchy:
  - name: "Secret data: per-node, common"
    lookup_key: eyaml_lookup_key
    paths:
      - "common.eyaml"
    options:
      pkcs7_private_key: <your private key>
      pkcs7_public_key:  <your public key>

  - name: "PXE install server configurations"
    globs:
      - "pxe/*.yaml"
      - "pxe/nodes/*.yaml"

  - name: "Other YAML hierarchy levels"
    path: "common.yaml"
```

This needs the following lookup configuration in your `common.yaml`file.

```yaml
---
lookup_options:
  '^pxe_install::machines$':
    merge:
      strategy: deep
  '^pxe_install::defaults$':
    merge:
      strategy: deep
  '^pxe_install::services$':
    merge:
      strategy: deep
```

The folder structure of your conreol repository should loo like this to get the above configurations work.

```bash
control-repo/
├── data/                                 # Hiera data directory.
│   ├── nodes/                            # Node-specific data goes here.
│   ├── pxe/                              # Global PXE install data goes here.
│   ├── pxe/nodes/                        # Node configutation for PXE installs goes here.
│   └── common.yaml                       # Common data goes here.
├── manifests/
│   └── site.pp                           # The “main” manifest that contains a default node definition.
├── scripts/
│   ├── code_manager_config_version.rb    # A config_version script for Code Manager.
│   ├── config_version.rb                 # A config_version script for r10k.
│   └── config_version.sh                 # A wrapper that chooses the appropriate config_version script.
├── site-modules/                         # This directory contains site-specific modules and is added to $modulepath.
│   ├── profile/                          # The profile module.
│   └── role/                             # The role module.
├── LICENSE
├── Puppetfile                            # A list of external Puppet modules to deploy with an environment.
├── README.md
├── environment.conf                      # Environment-specific settings. Configures the modulepath and config_version.
└── hiera.yaml
```

## `Usage`

he simpliest way to use this module is to maintain the full configuration in a Hiera file. In this case using this modules is just to

```puppet
include ::pxe_install
```

The module will take care about for each configured node:

* kickstart files for RedHat/CentOS
* preseed files for Debian/Ubuntu
* dhcp entries
* tftp configuration files per node

### `Install server definitions`

The module has several configuration options. Please look into the [REFERENCE.md](https://github.com/tom-krieger/pxe_install/blob/main/REFERENCE.md) file. The data folder contains a `common.yaml` file showing some example configurations.

The install server can provide a DHCP and a TFTP service. These services have their configuration located in the `pxe_install::services` part.

#### Services

The follwong services are only configured when defined in the services configuration section.

```yaml
pxe_install::services:
  samba:
    ...
  tftpd:
    ...
  dhcpd:
    ...
```

##### `TFTP service`

For the tftp service please provide the packages and service name to use. The `group` option is only needed on RedHat/CentOS operating systems.

> If you do not enable this service you have to take care yorself to create the TFTP entries.

Configuration example:

```yaml
  tftpd:
    manage_tftpboot: true
    packages:
      - tftp-server
      - xinetd
    packages_ensure: installed
    port: 69
    user: root
    group: root
    directory: '/var/lib/tftpboot'
    pxelinux: 'pxelinux.cfg'
    address: 10.0.0.2
    tftpserverbin: /usr/sbin/in.tftpd
    service: xinetd
    service_ensure: running
    service_enable: true
```

##### `DHCP service`

The DHCP service can serve as a full DHCP service. This means you can define static DHCP entried for all nodes regardless if these nodes need install services. The dhcp service configuration has a `hosts` part where you can configure all these nodes.

> If you do not enable the DHCP service, you have to take care about the DHCP entries yourself.

Configuration example:

```yaml
dhcpd:
    interfaces:
      - eth0
    omapiport: 7911
    default_lease_time: 43200
    max_lease_time: 86400
    ddns_update_style: none
    domain_names: 
      - localdomain
    dns_servers:
      - 10.0.0.62
      - 10.0.0.63
    ntp_servers: ['none']
    next_server: 10.0.0.2
    logfacility: local7
    option_code150_label: pxegrub
    option_code150_value: text
    default_filename: pxelinux.0
    hosts:
      test:
        mac: 00:11:22:33:44:55
        ip: 10.0.0.99
        max_lease_time: 86400
    pools:
      internal:
        network: 10.0.0.0
        mask: 255.255.255.0
        range:
          - '10.0.0.180 10.0.0.199'
        gateway: 10.0.0.12  
```

##### `SAMBA service`

The SAMBA service is needed to kickstart Windows installation. Windows will download all needed files from here during unattended installation.

> If you do not enable this service please take care to provide a SAMBA share needed for the Windows installation.

Configuration example:

```yaml
samba:
    package_ensure: installed
    os_level: 50
    workgroup: WORKGROUP
    wins_server: 10.0.0.75
    server_string: 'Install server'
    netbios_name: 'wonderbox'
    map_to_guest: 'Bad User'
    syslog: '3'
    firewall_manage: false
    interfaces:
      - eth0
    hosts_allow:
      - '127.'
    hosts_deny: 
      - 'ALL'
    local_master: yes
    preferred_master: no
    shares:
      install:
        comment: 'Windows install media'
        path: /var/lib/tftpboot/windows
        browseable: true
        writable: false
        public: yes
        guest_ok: yes
```

### `Node configuration`

The node configuration includes general settings for a node like the root password, os type, keyboard, language and timezone settings. The following table describes the available configiration options. If a value is available as default value it is marked with *yes* in the *default value* column.

| Section | Config option | Comment | Default value |
|---|---|---|:---:|
| global | ensure | can have the values `present` or `absent` | - |
|                  | rootpw | The sha512 encrypted root password. You can create this password by using a Python one liner. See below the example | yes |
| | timezone | Timezone setting, e. g. Europe/Berlin | yes |
| | ostype | The OS type. Valid values are `debian`, `ubuntu`, `Alma`, `Rocky` and `CentOS` | - |
| | osversion | The `osversion` is necessary for CentOS like only and is the major number of the OS to install, e. g. 8. For Debian OS the osversion is the suite to install like e. g. 'oldstable'or 'stable'.| stable for Debain, no value for other OSes. |
| | keyboard | The keyboard layout to use, e. g. `de(Macintosh, no dead keys)`. Please make sure to use a keyboard layout supported by the OS you install. For Windows you need to set a value consisting of the input locale and the locate e. g. `0409:00000407` which is German keyboard layout and en-US locale. | yes |
| | keymap | The keymap used for `debian` and `ubuntu` | yes |
| | language | The language used for the installer. For CentOS it is set to the language and the flavour, e. g. en_US. For Debian and Ubuntu it is a two character language setting, e. g. en. | yes |
| | locale | The locale setting for Linux e. g. en-US.UTF-8 or for Windows e. g. en-US | yes |
| | path | For Debian until version 10, Ubuntu and Windows nodes, there is a `path` needed which points to the boot screen files within the tftpboot directory. If you do not set this parameter it will be set to `<prefix>/boot-screens` by default. If you do not want to set a path, set it to the string `none`.| - |
| | packages | The packages to additionally install. This parameter has only effect on CentOS, Debian and Fedora installations. Otherwise it is ignored. Please make sure to use a string with blank separated packages for Debian and an array for Fedora or CentOS. | yes |
| | stage2 | Yhe tftpboot stage2 file | - |
| | defaultdesktop | The default desktop to install. | - |
| | startxonboot | Boolean to start X during boot. | - |
| | xconfig | Boolean to control if X is configured. | - |

#### `Node network configuration`

The network configuration describes how the network of a node should be setup. You need to give the mac address, ip address and so on. It is important to specify the correct `ksdevice`. That is the network device the kickstart/preseed will use. Be careful as this device is dependant on the network driver settings in VMWare. The examples in the `examples`folders `common.yaml` file show all possible configurations.

| Section | Config option | Comment | Default value |
|---|---|---|:---:|
| network | mac | The MAC address of the node | - |
| | prefix | The path within the tftpboot directory to find the boot kernel and initial ram disk. | - |
| | filename | The pxefile to load. A full path can be used. For windows `winpe.ipxe` is used as default. | yes |
| | fixedaddress | The IP address the host should use | - |
| | ksdevice | The network device used for kickstart | - |
| | gateway | The default gateway to use | - |
| | netmask | The netmask | - |
| | dns | Array of dns servers to configure | yes |

#### `Node user configuration`

Ubuntu/Debian need a unprivileded user to be able to login and to escalate your privileges to `root`after installation. This user can be defined in the `user` section.

| Section | Config option | Comment | Default value |
|---|---|---|:---:|
| user | fullname | The full name of the user | yes |
| | username | The username, e. g. ppt4711 | yes |
| | password | The password has to be encrypted as the operating system will do, so e. g. MD5 or SHA512 encrypted. See the explanations below on how to create such a password. | yes |

**One liner to create a SHA512 encryped password:**

```python3
python3 -c 'import crypt; print(crypt.crypt("your password here", crypt.mksalt(crypt.METHOD_SHA512)))'
```

#### `Node parameter configuration`

The parameter section nows about 4 parameter. Therse parameter control how the node will be registered in the Puppet master. If needed, Puppet agent installation can be skipped.

| Section | Config option | Comment | Default value |
|---|---|---|:---:|
| parameter | env | The environment configuration for the Puppet agent. | - |
| | role | The role the node will get. This value will be added to the agent certificate as trusted fact `pp_role`. | - |
| | dc | The datacenter the node runs in. This value goes as trusted fact `pp_datacenter` into the node's certificate. | - |
| | agent | This option accepts `y` or `n`. If set to `n` no Puppet agent will be installed. Default value is `y`. | - |
| | orgid | The organization id for Redhat CDN install and subscription manager. | - |
| | actkey | The acvtivation key for Redhat CDN install and subscription manager. | - |
| | rhcdn | Set to `y` if Redhat CDN should be used. Otherwiese the URL would be used. | - |

#### `Node partition configuration`

Ubuntu/Debian use different methods to define partition tables. And for Ubuntu/Debian an `order` is needed as the entries in the preseed file need to be defined in that order. Please see the example `ct03` in the `common.yaml` file in the `examles` folder.

The partion options do not support all possibilites for Debian/Ubuntu or RedHat/CentOS. Only these things I needed have been implemented in the templated for partitioning. These templates can easily be extended to e. g. make software raids possible.

The partitioning information for each node goes into the `partitioning` section. Debian/Ubuntu and RedHat/CentOS need different options for partitioning. These options will be described in the following.

There are thre ways to define partitioning:

* add a partition table directly to the node
* use an operation system default you can have in the `defaults` part of the install server. In this case you just omit the partitioning information in the node definitions.
* create a partition table and use it with the `partitiontable` reference instead of `partitioning` in a node definition and define this partition table for multi use in the install server defaults.

##### `RedHat/CentOS`

Here're some small examples:

```yaml
    partitioning:
      "/boot":
        type: part
        fstype: ext3
        size: 2048
        primary: true
        ondisk: sda
      "pv.01":
        type: pvol
        size: 1000
        grow: true
        primary: true
        ondisk: sda
      "vgos":
        type: volgroup
        pvol: pv.01  
      "/usr":
        type: logvol
        vgname: vgos
        diskname: lvol_usr
        size: 8192
        fstype: ext4 
```

The available options:

* `title`: The mountpoint, physical or logival volume or the volume group.
* `type`: The type of the partition. Currently it accepts the following values:
  * part: physical partition
  * pvol: physical volume
  * volgroup: volume group
  * logvol: logical volume
* `fstype`: the filesystem type, e. g. ext4
* `size`: The size of the partition in **megabytes**.
* `primary`: If set to true, the partition will be a rimary partition. If this option is not given, `false` will be the default.
* `ondisk`: the disk device to put the partition on. This is mandatory for physical partitions and physical volumes.
* `grow`: If set to `true` the partition will be grown to the maximal possible size. The size value is the minimal size in that case. Default is `false`.
* `diskname`: The label for the disk, e. g. `lvol_var`

##### `Ubuntu/Debian`

A difference is that an `order` is needed for the concat fragments. Otherwirse the partition table will not work during preseed. If you have more than one disk in your partitioning infrmation, the partitioning is scanned before to create a `partman/auto-disk` entry with all availabe disk devices.

Here're some small examples:

```yaml
    partitioning:
      "/boot":
        min: 1024
        prio: 1024
        max: 1024
        fstype: ext3
        primary: true
        bootable: true
        label: boot
        method: format
        device: /dev/sda
        order: 405
      "vgos":
        min: 100
        prio: 1000
        max: 1000000000
        fstype: ext4
        primary: true
        bootable: false
        method: lvm
        device: /dev/sda
        vgname: vgos
        order: 406
```

The available options:

* `title`: The mountpoint, physical or logival volume ot the volume group.
* `min`: is the minimal allowed size of the partition in
megabytes.  It is rounded to cylinder size, so if you make `minimal
size` to be 20 MB and the cylinder size is 12MB, then it is possible
for the partition to be only 12MB.  These sizes may also be given as
a percentage, which makes the size be that percentage of the system's
total RAM, or (as of partman-auto 87) as a number plus a percentage
(e.g. "2000+50%"), which makes the size be that number plus that
percentage of the system's total RAM.
* `prio`: is some size usually between `minimal size` and `maximal
size`.  It determines the priority of this partition in the contest
with the other partitions for size.  Notice that if `priority` is too
small (relative to the priority of the other partitions) then this
partition will have size close to `minimal size`.  That's why it is
recommended to give small partitions a `priority` larger than their
`maximal size`.
* `max`: is the maximal size for the partition, i.e. a limit
size such that there is no sense to make this partition larger.
The special value "-1" is used to indicate unlimited partition size.
* `fstype`:  the filesystem type, e. g. ext4
* `primary`: accepts `true` or `false` and makes a partition a primary partitio
* `bootable`: accepts `true` or `false` and makes a partition bootable
* `defaultignore`: Used to void a partition definition so that it is ignored in the default case. That is to say it will be valid in the LVM case.
* `method`: how to deal with the partition. Can have the following values:
  * format: format the partiotn
  * lvm: for volume groups
  * swap: for swap partitions
* `invg`: the volume group the logical volume will be created in
* `format`: accepts `true` or `false`. If true the partition will be formatted during installation.
* `label`: a label for the partition e. g. `boot`.
* `device`: the disk device to use
* `vgname`: the name of the volume group
* `lvname`: the name of the logival volume e. g. `lvol_boot`.
* `order`: the order in the concatenated preseed file. Should be ascending and contain no duplicates. Starting value for the first entry should be `405`.

###### Ubuntu 22

Starting with Ubuntu 22 `autoinstall` is used for installing Ubuntu servers. You need the server iso file. Ubuntu 22 autoinstall brings a huge change to paritioning. You can use all the settings available from the Ubuntu autoinstall. All key/value pairs are passed directly from the yaml file to the autoinstall file. The `order` field will be removed and is used for content::fragment ordering. So please make sure to have no duplicates in your partitioning.

Below there's a short example how partitioning can look like.

```yaml
partitioning:
  - path: /dev/sda
    id: sda
    ptable: msdos
    wipe: superblock-recursive
    preserve: false
    name: main_disk
    type: disk
    grub_device: true
    order: 405
  - device: sda
    size: 2G
    flag: bios_grub
    preserve: false
    id: sda1
    grub_device: false
    type: partition
    number: 1
    order: 406
  - device: sda
    size: -1
    wipe: superblock
    preserve: false
    grub_device: false
    number: 2
    type: partition
    id: sda2
    order: 408
  - name: vgos
    devices:
    - sda2
    preserve: false
    type: lvm_volgroup
    id: lvm_volgroup-vgos
    order: 409
  - name: lvol_root
    volgroup: lvm_volgroup-vgos
    size: 4G
    wipe: superblock
    preserve: false
    type: lvm_partition
    id: lvm_partition-0
    order: 410
```

### Default values

To simplify configuration of nodes, there are several default values that are avaiable in the `params.pp` class. You can overwrite these defaults in your Hiera configuration.

The following default values are available:

| Section               | Value         |
|-----------------------|---------------|
| Global configuration  | rootpw        |
|                       | tmezone       |
|                       | keymap        |
|                       | language      |
|                       | country       |
|                       | locale        |
|                       | loghost       |
|                       | logport       |
|                       | domain        |
| Network configuration | pxefile       |
| User configuration    | fullname      |
|                       | username      |
|                       | password      |
| Disk partitioning     | bootable      |
|                       | primary       |
| Partition tables      | partitioning  |
|                       | partitiontable |

Default partition tables are available for Debian like and Redhat like operation systems. You can define your own default partition tables. This is useful if you want to create e. g. a three node cluster and all three nodes should have an identcal configuration.

### Minimal node configuration examples

The following example uses all available default values and the node definition only contains the necessary definitions. The example makes use of a defined partition table in the install server defaults.

```yaml
  example:
    ensure: present
    ostype: ubuntu
    network:
      mac: 00:11:22:33:44:55
      prefix: ubuntu/18.04/amd64      
      fixedaddress: 10.0.0.132
      ksdevice: eth0
      gateway: 10.0.0.1
      netmask: 255.255.255.0
    parameter:
      env: production
      role: ubuntu
      dc: home
      agent: y
    partitiontable: example
```

If you want to split your configuration into multiple files and keep all install server related stuff in a dedicated folder in your Hiera data folder, you can refer to the following configuration examples. Please keep in mind that you need to configute the Hiera merge options in the `common.yaml` file as described above.

A node definition `tomtest.yaml`

```yaml
---
pxe_install::machines:
  tomtest:
    ensure: present
    ostype: ubuntu
    network:
      mac: 00:50:56:91:ba:68
      prefix: ubuntu/18.04/amd64
      fixedaddress: 10.0.0.132
      ksdevice: eth0
      gateway: 10.0.0.4
      netmask: 255.255.255.0
    parameter:
      env: production
      role: ubuntu
      dc: home
      agent: y
    partitiontable: tomtest2

```

The partition table definition `default_partitioning.yaml`

```yaml
---
pxe_install::defaults:
  partitioning:
    tomtest2:
      "/boot":
        min: 2048
        prio: 2048
        max: 2048
        fstype: ext3
        primary: true
        bootable: true
        label: boot
        method: format
        device: /dev/sda
        order: 405
      "vgos":
        min: 100
        prio: 1000
        max: 1000000000
        fstype: ext4
        primary: true
        method: lvm
        device: /dev/sda
        vgname: vgos
        order: 406
      "swap":
        min: 4096
        prio: 4096
        max: 4096
        fstype: linux-swap
        invg: vgos
        method: swap
        lvname: lvol_swap
        order: 407
      "/":
        min: 8192
        prio: 8192
        max: 8192
        fstype: ext4
        invg: vgos
        lvname: lvol_root
        method: format
        label: root
        order: 408
```

You can find more examples in the `spec/fixtures/hiera/hiera_data/pxe` folder.

## Tasks

`maintain_netinstaller`:
This task can be called directly nd it will download the needed net installer image and install the files into the tftpboot directory. Here's an example for an CentOS 8 netinstaller URL: [http://centos.intergenia.de/8-stream/isos/x86_64/CentOS-Stream-8-x86_64-latest-boot.iso](http://centos.intergenia.de/8-stream/isos/x86_64/CentOS-Stream-8-x86_64-latest-boot.iso)

`create_password`:
This task helps you to create SHA512 encrypted passwords. It uses the above mentioned Python code. This task has to run on the Puppet primary server.

## Unit tests

Unit tests are mainly covered by the main `pxe_install_spec.rb` file.

## Limitations

This module was initially written for my private install server. Therefore it is limited to what I needed. Especially paritioning is currentlylimited to partitions and logical LVM volumes.

## Contributors

Special thanks to my collegue Kevin for his support with Windows PXE installation.

## Known issues

The `tftp-hpa` package on Debian and Ubuntu servers causes failures during installation if the `/tmp` directory has the `noexec` flag set. The installation works regardless. The next puppet run will finish without problems and the tftp server works. If you want to avoid this issue it is possible to remove the `noexec` flag from the `/tmp` directory and add it again after the puppet run has finished.
