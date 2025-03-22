# Method for auto installing linux mint by using a preseed


Use script to build a custom iso that uses the preseed from this repo.

    ./build_iso.sh -i path/to/linuxmint-XX.X-cinnamon-64bit.iso -o out.iso -c path/to/this/repo

Write the new iso file to a usb stick

    dd if=out.iso of=/path/to/blockdevice bs=8M status=progress

When booting from this USB stick, two new boot menu options are available.  

During the OEM install the preseed files are fetched from this repo.  
So the latest version will always be used from the master branch.  


# Credits

[https://github.com/Pauchu/linux-mint-20-preseeding]
