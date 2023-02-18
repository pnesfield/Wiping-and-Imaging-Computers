#!/bin/bash
echo Move aside
mkdir aside
sudo mv chroot/var/lib/dpkg/ aside/dpkg
sudo mv chroot/var/lib/apt/ aside/apt
sudo mv chroot/var/cache/ aside/cache
sudo mv chroot/usr/share/doc/ aside/doc
sudo mv chroot/usr/share/man/ aside/man
sudo mv chroot/usr/src/ aside/src
sudo mv chroot/usr/lib/modules/5.4.0-26-generic/kernel/sound aside/sound
sudo mv chroot/usr/lib/modules/5.4.0-26-generic/kernel/net/wireless aside/wireless

cd chroot
sudo find . -print0 | sudo cpio --null -ov --format=newc | gzip -9 > /var/server/wipe/initrd
cd ..
sudo mv aside/dpkg chroot/var/lib/
sudo mv aside/apt chroot/var/lib/
sudo mv aside/cache chroot/var/
sudo mv aside/doc chroot/usr/share/
sudo mv aside/man chroot/usr/share/
sudo mv aside/src chroot/usr/
sudo mv aside/sound chroot/usr/lib/modules/5.4.0-26-generic/kernel/
sudo mv aside/wireless chroot/usr/lib/modules/5.4.0-26-generic/kernel/net/
du -h /var/server/wipe/initrd


