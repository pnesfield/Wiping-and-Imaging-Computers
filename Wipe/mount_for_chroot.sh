#!/bin/bash
# This script does the chroot mounts required before doing Linux level updates to the environment
# It should be run from the ramdisk directory
# 4/10/20 philn add pts (pseudo terminals)
mount -v -t proc proc chroot/proc
mount -v -t sysfs sys chroot/sys
mount -v -o bind /dev chroot/dev
mount -v -o bind /dev/pts chroot/dev/pts
