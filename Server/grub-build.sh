#!/bin/bash
sudo grub-mkimage -O i386-pc-pxe \
    --output /var/server/grub/i386-pc/core.0 \
    --prefix=grub \
    -c grub-build.conf \
    -d /usr/lib/grub/i386-pc/  \
  boot priority_queue datetime bufio net tftp pxe


