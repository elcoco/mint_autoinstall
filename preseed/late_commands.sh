#!/usr/bin/env bash

# NOTE: Script will be run at end of install inside a chroot
#
echo "Running late_commands.sh script"
echo "Starting late_commands.sh" > /tmp/install.log

[[ -d /etc/apt ]] || mkdir -v /etc/apt

cat << EOF > /etc/apt/source.list
deb https://mintlinux.mirror.wearetripple.com/packages xia main upstream import backport
deb http://ftp.tudelft.nl/archive.ubuntu.com noble main restricted universe multiverse
deb http://ftp.tudelft.nl/archive.ubuntu.com noble-updates main restricted universe multiverse
deb http://ftp.tudelft.nl/archive.ubuntu.com noble-backports main restricted universe multiverse
deb http://security.ubuntu.com/ubuntu/ noble-security main restricted universe multiverse
EOF

apt update
apt install -y nmap

# Set automatic updates
mintupdate-automation upgrade enable

echo "Ending late_commands.sh" >> /tmp/install.log
