#!/usr/bin/env bash

# NOTE: Script will be run at end of install inside a chroot

# Backup default sources.list
if [[ -f /etc/apt/sources.list.d/official-package-repositories.list ]] ; then
    mv /etc/apt/sources.list.d/official-package-repositories.list /etc/apt/sources.list.d/official-package-repositories.list.bak
fi

cat << EOF > /etc/apt/sources.list.d/official-package-repositories.list
# Preseeded sources.list
deb https://ftp.nluug.nl/os/Linux/distr/linuxmint/packages xia main upstream import backport

deb http://ftp.snt.utwente.nl/pub/os/linux/ubuntu noble main restricted universe multiverse
deb http://ftp.snt.utwente.nl/pub/os/linux/ubuntu noble-updates main restricted universe multiverse
deb http://ftp.snt.utwente.nl/pub/os/linux/ubuntu noble-backports main restricted universe multiverse

deb http://security.ubuntu.com/ubuntu/ noble-security main restricted universe multiverse
EOF

# Setup firewall
#ufw enable
#ufw default deny incoming

apt update
apt install -y mint-meta-codecs

# Set automatic updates
mintupdate-automation upgrade enable

# Next boot will show OEM user configuration
oem-config-prepare

echo "SUCCESS!" >> /tmp/install.log
