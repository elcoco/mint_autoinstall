#!/usr/bin/env bash


MOUNT_DIR=/mnt
TMP_DIR=/tmp/build_iso

usage() {
    echo "build_iso.sh -i <INPUT_ISO> -o <OUTPUT_ISO> -c <ASSETS_DIR>"
}

die() {
    echo "ERROR: $1"
    cleanup
    exit 1
}

log() {
    echo "[$( date '+%Y-%m-%d %H:%M:%S')] $1"
}

cleanup() {
    if [[ -d "$TMP_DIR" ]] ; then
        log "Removing tmp directory: $TMP_DIR..."
        rm -r $TMP_DIR
    fi
    if [[ $(findmnt -M "$MOUNT_DIR") ]] ; then
        log "Unmounting ISO..."
        umount -v $MOUNT_DIR
    fi
}

while getopts ":i:o:a:h" c; do
    case $c in
        i) 
            ISO_IN="$OPTARG"
            ;;
        o) 
            ISO_OUT="$OPTARG"
            ;;
        a) 
            ASSETS_DIR="$OPTARG"
            ;;
        :)
            usage
            die "option -$OPTARG requires an argument";
            ;;
         
        h | *)
            usage
            ;;
    esac
done

# Sanity checks
if [[ $(findmnt -M "$MOUNT_DIR") ]] ; then
    echo "Mountpoint already mounted: $MOUNT_DIR, unmount first!"
    exit 1
fi

[[ "$EUID" -ne 0 ]] && die "Please run this script as root!"
[[ -z "$ISO_IN" ]] && usage && die "Specify source iso: -i <path/to/source.iso>"
[[ -f "$ISO_IN" ]] || die "Source iso not found: $ISO_IN"

[[ -z "$ISO_OUT" ]] && usage && die "Specify iso destination path!"
[[ -f "$ISO_OUT" ]] && die "Iso destination path already exists at $ISO_OUT, remove first!"

[[ -z "$ASSETS_DIR" ]] && usage && die "Specify path to assets directory!"
[[ -d "$ASSETS_DIR" ]] || die "Failed to find assets directory, $ASSETS_DIR"

[[ $(command -v mkisofs 2>&1) ]] || die "mkisofs not found, install first!"


if [[ -d "$TMP_DIR" ]] ; then
    log "Removing tmp directory: $TMP_DIR..."
    rm -r "$TMP_DIR"
fi

if (! mount -v -o loop "$ISO_IN" "$MOUNT_DIR") ; then
    die "Failed to mount $ISO_IN on $MOUNT_DIR"
fi

log "Copying files to tmp dir"
if (! cp -rp "$MOUNT_DIR" "$TMP_DIR") ; then
    die "Failed to copy $MOUNT_DIR to $TMP_DIR"
fi

log "Copying assets directory"
if (! cp -rpv "$ASSETS_DIR" "$TMP_DIR/assets") ; then
    die "Failed to copy $ASSETS_DIR to $TMP_DIR/assets"
fi

log "Copying isolinux.cfg"
if (! cp -v "$ASSETS_DIR/isolinux.cfg" "$TMP_DIR/isolinux") ; then
    die "Failed to copy $ASSETS_DIR/isolinux.cfg to $TMP_DIR/isolinux"
fi

#log "Copying custom preseed"
#mkdir -p "$TMP_DIR/preseed"
#if (! cp -v "$ASSETS_DIR/linuxmint_custom.seed" "$TMP_DIR/preseed/linuxmint_custom.seed") ; then
#    die "Failed to copy $ASSETS_DIR/linuxmint_custom.seed to $TMP_DIR/preseed/linuxmint_custom.seed"
#fi

#log "Copying grub.cfg"
#if (! cp -v $ASSETS_DIR/grub.cfg $TMP_DIR/boot/grub) ; then
#    die "Failed to copy $ASSETS_DIR/grub.cfg to $TMP_DIR/boot/grub"
#fi

# mkisofs -o output.iso -b isolinux.bin -c boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -J -R -V "Ubuntu Custom ISO Preseed" .
log "Making iso"
if (! mkisofs -o "$ISO_OUT" -b isolinux/isolinux.bin -c isolinux/isolinux.cat -no-emul-boot -boot-info-table -J -R -V "Custom LinuxMint" $TMP_DIR) ; then
    die "Failed to build $ISO_OUT from $TMP_DIR"
fi

cleanup
exit 0
