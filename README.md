# Method for auto installing linux mint by using a preseed
NOTE: I tested with the latest (v22.1) cinnamon linux mint iso on a virtual machine.  
      This still needs proper testing on real hardware.  

A preseed file is a list of answers to questions that are asked by the linux mint installer.  
It's the native way of doing automatic installs on debian like distro's.  

It's easy to set things like localization, apt sources, extra users or run custom scripts.  
For this to work we have to build a new install image.  

## Changes from the default install

    - NL apt mirror
    - Automatic partititioning on biggest harddisk
    - Unattended updates (/etc/system/systemd/timers.targets.wants/mintupdate-automation-upgrade.timer)

## Creating install medium
### Building the custom image
We need to start off with a default linux mint install image: [download](https://linuxmint.com/edition.php?id=319)

In this repository you can find a [script](/build_iso.sh) that automatically builds a custom image from a default linux mint image.  

    git clone https://github.com/elcoco/mint_autoinstall

The script requires mkisofs to be installed:  

    sudo pacman -S cdrtools         # Arch
    sudo apt install mkisofs        # Debian/Mint/Ubuntu

Run the script:

    ./build_iso.sh -i path/to/linuxmint-XX.X-cinnamon-64bit.iso -o out.iso -p path/to/this/repo/preseed

### Write image to disk
Find the device file for your usb stick (probably something like /dev/sdx):

    lsblk

Write the new iso file to a usb stick.  
Be carefull, [dd](https://www.man7.org/linux/man-pages/man1/dd.1.html) doesn't ask any questions before writing to a device ;)

    sudo dd if=out.iso of=/path/to/usb_stick bs=8M status=progress

The linuxmint_custom.seed file is copied to the image.  
When booting from this USB stick, a new boot menu option becomes available: "Repair cafe preseeded OEM install".  
During this OEM install the preseed file is read and the install should be completely silent.  

## Debugging
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
https://github.com/Pauchu/linux-mint-20-preseeding  
Example debian preseed config [options](https://www.debian.org/releases/bookworm/example-preseed.txt)   
https://gitlab.com/morph027/preseed-cinnamon-ubuntu  
https://linuxconfig.org/how-to-perform-unattedended-debian-installations-with-preseed  
https://wiki.ubuntu.com/UbiquityAutomation  
https://wiki.ubuntu.com/DebuggingUbiquity  
