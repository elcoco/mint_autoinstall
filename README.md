# Method for auto installing linux mint by using a preseed

    NOTE0: I tested with the latest (v22.1) cinnamon linux mint iso on a virtual machine.  
           This still needs proper testing on real hardware.  
    NOTE1: EFI booting is broken atm. The EFI image on the mint iso can not be used.
           more info is here:
           - https://unix.stackexchange.com/questions/710180/boot-on-a-modified-iso-image
           - https://unix.stackexchange.com/questions/283994/why-is-grub2-ignoring-kernel-options-when-boot-from-el-torito-on-cd

A preseed file is a list of answers to questions that are asked by the linux mint installer.  
It's the native way of doing automatic installs on debian like distro's.  

It's easy to set things like localization, apt sources, extra users or run custom scripts.  
For this to work we have to build a new install image.  

## Changes from the default install

    - NL apt mirror
    - Automatic partititioning on biggest harddisk
    - Unattended updates (/etc/system/systemd/timers.targets.wants/mintupdate-automation-upgrade.timer)
    - Install mint-meta-codecs

## Creating install medium
### Building the custom image
We need to start off with a default linux mint install image: [download](https://linuxmint.com/edition.php?id=319)

In this repository you can find a [script](/build_iso.sh) that automatically builds a custom image from a default linux mint image.  

    # Install git if it isn't already installed
    sudo apt install git

    # Clone the git repository
    git clone https://github.com/elcoco/mint_autoinstall

The script requires xorriso and isolinux to be installed:  

    sudo pacman -S libisoburn               # Arch
    sudo apt install xorriso isolinux       # Debian/Mint/Ubuntu

Run the script:

    sudo ./build_iso.sh -i path/to/linuxmint-XX.X-cinnamon-64bit.iso -o out.iso -p path/to/this/repo/preseed

### Write image to disk
Find the device file for your usb stick (probably something like /dev/sdx)  
In my case this is */dev/sdb*.  

    $ lsblk                                                                                                             20:18:16
    NAME         MAJ:MIN RM   SIZE RO TYPE  MOUNTPOINTS
    sda            8:0    0 931,5G  0 disk
    ├─sda1         8:1    0   511M  0 part  /boot
    └─sda2         8:2    0   931G  0 part
    └─cryptlvm 254:0    0   931G  0 crypt /
    sdb            8:16   1  28,7G  0 disk
    ├─sdb1         8:17   1   2,8G  0 part
    ├─sdb2         8:18   1   2,2M  0 part
    └─sdb3         8:19   1  25,9G  0 part
    sdc            8:32   1     0B  0 disk
    sdd            8:48   1     0B  0 disk
    zram0        253:0    0     4G  0 disk  [SWAP]

Write the new iso file to an unmounted USB stick.  
Be very carefull, [dd](https://www.man7.org/linux/man-pages/man1/dd.1.html) doesn't ask any questions before writing to a device.  
It will write over your system disk without any problems ;)  

    # NOTE: Replace <DEVICE> with the path to your USB stick's device file
    sudo dd if=out.iso of=/dev/<DEVICE> bs=8M status=progress

The linuxmint_custom.seed file is copied to the image.  
When booting from this USB stick, a new boot menu option becomes available: "Repair cafe preseeded OEM install".  
During this OEM install the preseed file is read and the install should be completely silent.  


## Debugging  
### Log files  
Installation log files can be found on the freshly installed computer at: /var/log/installer

### Mount virtualbox .VDI files with fuse

    # Create mountpoints
    mkdir -p mnt/expanded
    mkdir -p mnt/vol2

    # Find UUID of image
    vboximg-mount --list

    # Mount expanded volumes inside image
    vboximg-mount --image 95cbca92-5161-4be3-ad9f-24f3311b6e3a -o allow_other mnt/expanded

    # Mount volume
    sudo mount mnt/expanded/vol2 mnt/vol2



## Credits
https://wiki.syslinux.org/wiki/index.php?title=Isohybrid
https://github.com/Pauchu/linux-mint-20-preseeding  
Example debian preseed config [options](https://www.debian.org/releases/bookworm/example-preseed.txt)   
https://gitlab.com/morph027/preseed-cinnamon-ubuntu  
https://linuxconfig.org/how-to-perform-unattedended-debian-installations-with-preseed  
https://wiki.ubuntu.com/UbiquityAutomation  


https://wiki.ubuntu.com/DebuggingUbiquity  
