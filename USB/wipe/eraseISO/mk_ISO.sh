#!/bin/bash
xorriso -as mkisofs \
-V 'Splash' \
-o splash.iso \
--modification-date='2022081016214500' \
--grub2-mbr --interval:local_fs:0s-15s:zero_mbrpt,zero_gpt:'ubuntu-22.04.1-desktop-amd64.iso' \
--protective-msdos-label \
-partition_cyl_align off \
-partition_offset 16 \
--mbr-force-bootable \
-append_partition 2 28732ac11ff8d211ba4b00a0c93ec93b --interval:local_fs:7465120d-7473615d::'ubuntu-22.04.1-desktop-amd64.iso' \
-part_like_isohybrid \
-iso_mbr_part_type a2a0d0ebe5b9334487c068b6b72699c7 \
-c '/boot.catalog' \
-b '/boot/grub/i386-pc/eltorito.img' \
-no-emul-boot \
-boot-load-size 4 \
-boot-info-table \
--grub2-boot-info \
-eltorito-alt-boot \
-e '--interval:appended_partition_2_start_1866280s_size_8496d:all::' \
-no-emul-boot \
-boot-load-size 8496 \
-isohybrid-gpt-basdat \
image
