#!/bin/bash
export usb=""
while [ "$usb" == "" ] 
do
  sleep 2 
  export usb=`lsblk -nio NAME,TRAN | grep -i USB | cut -f1 -d' '`
  echo "Check for USB $usb"
done
part=1
mkdir /media/grub
echo mount /dev/$usb$part /media/grub
mount /dev/$usb$part /media/grub
cp /media/grub/wipe/*.sh .
cp /media/grub/wipe/*.iso .
umount /media/grub

./menu.sh
