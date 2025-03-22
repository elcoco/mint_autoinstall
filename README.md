# Method for auto installing linux mint by using a preseed

A preseed is a list of answers to questions that are asked while installing linux mint.  
We can build a new install image that uses this preseed file to do automatic OEM installs.  
For a list of customizations, see below.  

## Building the custom image

We need to start off with a default linux mint install image: [Download](https://linuxmint.com/edition.php?id=319)

In this repository is a [script](build_iso.sh) that automatically builds a custom image from a default linux mint image.  
The script requires mkisofs to be installed:  

    sudo pacman -S cdrtools         # Arch
    sudo apt install mkisofs        # Debian/Mint/Ubuntu

Run the script:

    ./build_iso.sh -i path/to/linuxmint-XX.X-cinnamon-64bit.iso -o out.iso -c path/to/this/repo

## Write image to disk

Find the device file for your usb stick (probably something like /dev/sdx):

    lsblk

Write the new iso file to a usb stick.  
Be carefull, [dd](https://www.man7.org/linux/man-pages/man1/dd.1.html) doesn't ask any questions before writing to a device ;)

    sudo dd if=out.iso of=/path/to/usb_stick bs=8M status=progress

When booting from this USB stick, a new boot menu option becomes available: "Repair cafe preseeded OEM install"
During this OEM install the preseed file is fetched from the master branch in this repo.  
This means that internet access is a requirement.

# Changes from the default install

    - NL apt mirror
    - Automatic partititioning on biggest harddisk
    - Unattended updates


# Credits

(https://github.com/Pauchu/linux-mint-20-preseeding)
