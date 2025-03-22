# Method for auto installing linux mint by using a preseed

Copy preseed files to installation medium

    # mount installation medium on: /mnt
    sudo mount -o loop linuxmint-XX.X-cinnamon-64bit.iso /mnt

    sudo cp -p preseed_*.cfg /mnt/preseed

    # for BIOS:
    sudo cp isolinux.cfg /mnt/isolinux

    # for UEFI
    sudo cp grub.cfg /mnt/boot/grub/grub.cfg


# Credits

[https://github.com/Pauchu/linux-mint-20-preseeding]
