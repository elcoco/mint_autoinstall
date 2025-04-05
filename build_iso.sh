#!/usr/bin/env bash


MOUNT_DIR=/mnt
TMP_DIR=/tmp/build_iso

MBR_IMAGE_PATHS=( "/usr/lib/ISOLINUX/isohdpfx.bin"          # debian
                  "/usr/lib/syslinux/bios/isohdpfx.bin" )   # archlinux

usage() {
    echo "build_iso.sh -i <INPUT_ISO> -o <OUTPUT_ISO> -p <PRESEED_DIR> -m <MBR_IMG_PATH>"
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
        #rm -r $TMP_DIR
    fi
    if [[ $(findmnt -M "$MOUNT_DIR") ]] ; then
        log "Unmounting ISO..."
        umount -v $MOUNT_DIR
    fi
}

while getopts ":i:o:p:m:h" c; do
    case $c in
        i) 
            ISO_IN="$OPTARG"
            ;;
        o) 
            ISO_OUT="$OPTARG"
            ;;
        p) 
            PRESEED_DIR="$OPTARG"
            ;;
        m) 
            MBR_IMAGE_PATHS=("$OPTARG")
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

SCRIPTS_DIR="$PRESEED_DIR/scripts"
CONFIG_DIR="$PRESEED_DIR/config"
SKEL_DIR="$PRESEED_DIR/skel"
SEED_DIR="$PRESEED_DIR/seed"

# Sanity checks
if [[ $(findmnt -M "$MOUNT_DIR") ]] ; then
    echo "Mountpoint already mounted: $MOUNT_DIR, unmount first!"
    exit 1
fi

[[ "$EUID" -ne 0 ]] && die "Please run this script as root!"
[[ -z "$ISO_IN" ]] && usage && die "Specify input iso: -i <path/to/source.iso>"
[[ -f "$ISO_IN" ]] || die "Input iso not found: $ISO_IN"

[[ -z "$ISO_OUT" ]] && usage && die "Specify output iso path!"
[[ -f "$ISO_OUT" ]] && die "Output iso path already exists at $ISO_OUT, remove first!"

[[ -z "$PRESEED_DIR" ]] && usage && die "Specify path to preseed directory!"
[[ -d "$PRESEED_DIR" ]] || die "Failed to find preseed directory, $PRESEED_DIR"

[[ -d "$SKEL_DIR" ]] || die "Failed to find skel directory, $SKEL_DIR"
[[ -d "$CONFIG_DIR" ]] || die "Failed to find config directory, $CONFIG_DIR"
[[ -d "$SCRIPTS_DIR" ]] || die "Failed to find scripts directory, $SCRIPTS_DIR"
[[ -d "$SEED_DIR" ]] || die "Failed to find seed directory, $SEED_DIR"


[[ $(command -v xorriso 2>&1) ]] || die "Xorriso not found, install first!"

# Find MBR image
for IMG_PATH in "${MBR_IMAGE_PATHS[@]}" ; do
    if [[ -f "$IMG_PATH" ]] ; then
        log "MBR image found in: $IMG_PATH"
        MBR_IMG="$IMG_PATH"
        break
    else
        log "MBR image not found in: $IMG_PATH"
    fi
done

[[ -z $MBR_IMG ]] && die "isohdpfx.bin not found on system, install isolinux or specify path with -m"


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

log "Copying preseed directory"
if (! cp -rv "$PRESEED_DIR" "$TMP_DIR/preseed") ; then
    die "Failed to copy $PRESEED_DIR to $TMP_DIR/preseed"
fi

log "Copying isolinux.cfg"
if (! cp -v "$CONFIG_DIR/isolinux.cfg" "$TMP_DIR/isolinux") ; then
    die "Failed to copy $CONFIG_DIR/isolinux.cfg to $TMP_DIR/isolinux"
fi

log "Copying grub.cfg"
if (! cp -v "$CONFIG_DIR/grub.cfg" "$TMP_DIR/boot/grub") ; then
    die "Failed to copy $CONFIG_DIR/grub.cfg to $TMP_DIR/boot/grub"
fi

log "Making iso..."

# Build the ISO
# NOTE: Order of arguments matter
if (! xorriso -as mkisofs \
    -D -r -l \
     -J -J -joliet-long \
    -cache-inodes \
    -V "custom_mint_v22.1" \
    -isohybrid-mbr "$MBR_IMG" \
    -c isolinux/isolinux.cat \
    -b isolinux/isolinux.bin \
      -no-emul-boot \
      -boot-load-size 4 \
      -boot-info-table \
    -eltorito-alt-boot \
      -e boot/grub/efi.img \
      -no-emul-boot \
      -isohybrid-gpt-basdat \
    -o "$ISO_OUT" \
    "$TMP_DIR" ) ;
then
    die "Failed to build $ISO_OUT from $TMP_DIR"
fi

cleanup
exit 0
