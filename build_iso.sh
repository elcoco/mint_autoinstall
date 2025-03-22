#!/usr/bin/env bash


MOUNT_DIR=/mnt
GRUB_CFG=$(pwd)/grub.cfg
TMP_DIR=/tmp/build_iso

usage() {
    echo "build_iso.sh -i <INPUT_ISO> -o <OUTPUT_ISO> -c <REPO_DIR>"
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
    if [[ -d $TMP_DIR ]] ; then
        log "Removing tmp directory: $TMP_DIR..."
        rm -r $TMP_DIR
    fi
    if [[ $(findmnt -M "$MOUNT_DIR") ]] ; then
        log "Unmounting ISO..."
        umount -v $MOUNT_DIR
    fi
}

while getopts ":i:o:c:h" c; do
    case $c in
        i) 
            ISO_IN="$OPTARG"
            ;;
        o) 
            ISO_OUT="$OPTARG"
            ;;
        c) 
            CFG_DIR="$OPTARG"
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
[[ -z $ISO_IN ]] && usage && die "Specify source iso: -i <path/to/source.iso>"
[[ -f $ISO_IN ]] || die "Source iso not found: $ISO_IN"

[[ -z $ISO_OUT ]] && usage && die "Specify iso destination path!"
[[ -f $ISO_OUT ]] && die "Iso destination path already exists at $ISO_OUT, remove first!"

[[ -z $CFG_DIR ]] && usage && die "Specify path to config directory!"
[[ -d $CFG_DIR ]] || die "Failed to find config directory, $CFG_DIR"

[[ $(command -v mkisofs 2>&1) ]] || die "mkisofs not found, install first!"


if [[ -d $TMP_DIR ]] ; then
    log "Removing tmp directory: $TMP_DIR..."
    rm -r $TMP_DIR
fi

if (! mount -v -o loop $ISO_IN $MOUNT_DIR) ; then
    die "Failed to mount $ISO_IN on $MOUNT_DIR"
fi

log "Copying files to tmp dir"
if (! cp -rp $MOUNT_DIR $TMP_DIR) ; then
    die "Failed to copy $MOUNT_DIR to $TMP_DIR"
fi

log "Copying grub.cfg"
if (! cp -v $CFG_DIR/grub.cfg $TMP_DIR/boot/grub) ; then
    die "Failed to copy $GRUB_CFG to $TMP_DIR/boot/grub"
fi

log "Making iso"
if (! mkisofs -o $ISO_OUT $TMP_DIR) ; then
    die "Failed to build $ISO_OUT from $TMP_DIR"
fi

cleanup
exit 0
