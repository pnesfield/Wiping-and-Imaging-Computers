#!/bin/bash
export HOME=/root
export LC_ALL=C 
# This is done to use the simplest locale
echo "wiper"  > /etc/hostname
passwd -d root
# To reduce the amount of things installed by apt
cat >> /etc/apt/apt.conf << EOF
APT::Install-Recommends "0"; 
APT::Install-Suggests "0";
APT::Get::Assume-Yes "1";
APT::Get::AllowUnauthenticated "1";
EOF

sed -i -e 's/$/ restricted universe multiverse/' /etc/apt/sources.list
apt-get update
cat /etc/apt/sources.list

apt-get install apt-utils
apt-get install linux-generic
apt-get install whiptail
apt-get install hdparm
apt-get install systemd
apt-get install init
apt-get install udev

sed -i -e 's/--noclear /--noclear --autologin root /' /lib/systemd/system/getty@.service

echo "./start.sh" >> /root/.bashrc

