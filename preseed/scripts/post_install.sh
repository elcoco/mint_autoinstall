#!/usr/bin/env bash

# NOTE: Script will be run at end of install inside a chroot
#

#BOOT_DEVS=("/dev/sda" "/dev/nvme0n1" "/dev/hda")
#
## Install bootloader to first device
#for BOOT_DEV in "${BOOT_DEVS[@]}" ; do
#    if [[ -e "$BOOT_DEV" ]] ; then
#        echo "Installing bootloader on: $BOOT_DEV"
#        grub-install --force "$BOOT_DEV"
#        parted $BOOT_DEV set 1 boot on
#        break
#    fi
#done
#
#[[ -z $BOOT_DEV ]] && echo "Failed to install bootloader, couldn't find destination device"


# Backup default sources.list
if [[ -f /etc/apt/sources.list.d/official-package-repositories.list ]] ; then
    mv /etc/apt/sources.list.d/official-package-repositories.list /etc/apt/sources.list.d/official-package-repositories.list.bak
fi

# NOTE: A side effect of changing the mirrors without an internet connection to immediately update them
#       is that the graphical update manager will show an error saying that the APT configuration is corrupt.
#       This is easily fixed by pressing the "Refresh" button or by doing a manual "apt update".
#       If there is an internet connection available (which is recommended anyway for installing
#       some extra packages), the repos will be updated by this script.
cat << EOF > /etc/apt/sources.list.d/official-package-repositories.list
# Preseeded sources.list
deb https://ftp.nluug.nl/os/Linux/distr/linuxmint/packages xia main upstream import backport

deb http://ftp.snt.utwente.nl/pub/os/linux/ubuntu noble main restricted universe multiverse
deb http://ftp.snt.utwente.nl/pub/os/linux/ubuntu noble-updates main restricted universe multiverse
deb http://ftp.snt.utwente.nl/pub/os/linux/ubuntu noble-backports main restricted universe multiverse

deb http://security.ubuntu.com/ubuntu/ noble-security main restricted universe multiverse
EOF

apt update
apt install -y mint-meta-codecs

# Set automatic updates
mintupdate-automation upgrade enable

# Setup firewall
ufw enable
ufw default deny incoming

# Next boot will show OEM user configuration
oem-config-prepare
