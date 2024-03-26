#!/bin/bash
#disk_log.sh /dev/sda 00005499 "Enhanced Secure Erase" http://RedDev1:8000
DEBUG=$true
DEV=$1
ASSET=$2
ERASE_TYPE=$3
url=$4
SECURE_ERASE=0
ENHANCED_ERASE=0
if [ $DEBUG ]; then echo disk_log.sh checking $DEV; fi
if [[ $DEV == *"sg"* ]]; then
  DISK_KNAME=$DEV
  MAKE=$(smartctl -i $DEV | grep "Vendor:" | awk -F":" '{print $2}' | sed -e 's/^[ <t]*//;s/[ <t]*$//')
  MODEL=$(smartctl -i $DEV | grep "Product:" | awk -F":" '{print $2}' | sed -e 's/ //g' | sed -e 's/^[ <t]*//;s/[ <t]*$//')
  DISK_MODEL="${VENDOR} ${MODEL}"
  DISK_SERIAL=$(smartctl -i $DEV | grep "Serial number:" | awk -F":" '{print $2}' | sed -e 's/^[ <t]*//;s/[ <t]*$//')
  DISK_TYPE=$(smartctl -i $DEV | grep "Transport protocol:" | awk -F":" '{print $2}' | sed -e 's/^[ <t]*//;s/[ <t]*$//')
  DISK_SIZE=$(smartctl -i $DEV | grep "User Capacity:" | awk -F"[" '{print $2}' | sed -e 's/]//')
elif [[ $DEV == *"mmc"* ]]; then
  DISK_KNAME=$DEV
  DEV_NAME=$(echo $DEV | cut -d '/' -f 3)
  if [ $DEBUG ]; then echo check $DEV_NAME; fi
  VENDOR=$(cat /sys/block/$DEV_NAME/device/manfid)
  MODEL=$(cat /sys/block/$DEV_NAME/device/name)
  DISK_MODEL="${VENDOR} ${MODEL}"
  DISK_SERIAL=$(cat /sys/block/$DEV_NAME/device/serial)
  DISK_TYPE=$(cat /sys/block/$DEV_NAME/device/type)
  DISK_SIZE=$(lsblk -nio SIZE,TYPE $DEV | grep disk | awk '{print $1}')
  # blockdev --getsize64 $DEV  gets bytes instead of Gbytes
else
  DISK_KNAME=$(lsblk -io KNAME,TYPE $DEV | grep " disk" | sed -e 's/ .*//') 
  DISK_MODEL=$(lsblk -io MODEL,TYPE $DEV | grep " disk" | sed -e 's/ disk//' | sed -e 's/_/ /g')
  DISK_SIZE=$(lsblk -b -io SIZE,TYPE $DEV | grep " disk" | cut -f 1 -d ' ')
#DISK_TYPE=$(lsblk -io TRAN,TYPE $DEV | grep " disk" | sed -e 's/ disk//' | sed -e 's/ //g')
#not available in Linux 3.19
#DISK_HOTPLUG=$(lsblk -io HOTPLUG,TYPE $DEV | grep " disk" | sed -e 's/ disk//' | sed -e 's/ //g')
#DISK_SERIAL=$(lsblk -io SERIAL,TYPE $DEV | grep " disk" | sed -e 's/ disk//' | sed -e 's/ //g')
  if [[ $DEV == *"nvme"* ]]; then
    DISK_SERIAL=$(nvme list $DEV -o json 2> /dev/null | grep Serial | awk -F":" '{print $2}' | sed -e 's/\"//g' | sed -e 's/,//' | sed -e 's/ //g')
  else
    DISK_SERIAL=$(hdparm -I $DEV | grep -i "Serial Number" | cut -d ":" -f 2)
  fi
fi
SERIAL=$(dmidecode -s system-serial-number)
POST=Asset:$ASSET$'\n'State:Wipe$'\n'Serial:$SERIAL$'\n'DiskModel:$DISK_MODEL$'\n'DiskSerial:$DISK_SERIAL$'\n'DiskSize:$DISK_SIZE$'\n'WipeMethod:$ERASE_TYPE$'\n'DiskDevice:$DISK_KNAME
echo "Posting"
RETURN=$(curl -X Post --data "$POST" $url/ws/log.html 2>/dev/null)
echo "Returned $RETURN"
if [[ $RETURN == Error:* ]]; then
    echo "django returned $RETURN"
    exit
fi


