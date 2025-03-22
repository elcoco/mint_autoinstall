# Method for auto installing linux mint by using a preseed

Copy custom grub.cfg file to installation medium

    MOUNT_DIR=/mnt
    REPO_DIR=~/mint_autoinstall
    SOURCE_ISO_FILE=~/linuxmint-XX.X-cinnamon-64bit.iso
    DEST_ISO_FILE=~/custom_mint.iso
    TMP_DIR=~/tmp_iso

    # install package containing mkisofs:
    sudo pacman -S cdrtools         # Arch
    sudo apt install mkisofs        # Debian/Mint/Ubuntu

    # mount installation medium on: /mnt
    sudo mount -o loop $SOURCE_ISO_FILE $MOUNT_DIR

    # copy all files to temporary directory
    sudo cp -rp $MOUNT_DIR $TMP_DIR

    # copy grub.cfg to temporary directory
    sudo cp $REPO_DIR/grub.cfg $TMP_DIR/boot/grub

    # rebuild iso file
    mkisofs -o $DEST_ISO_FILE $TMP_DIR

During the OEM install the preseed files are fetched from this repo.  
So the latest version will be used from the master branch.  


# Credits

[https://github.com/Pauchu/linux-mint-20-preseeding]
