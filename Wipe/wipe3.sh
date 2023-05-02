#!/bin/bash
# Use secure erase or enhanced secure erase to wipe a disk
# Use whiptail to select disks
DEBUG=
DEV=$1
DEV="/dev/sdb"
version="1.3"
brand="Secure Erase $version"

drives=`lsblk -nio NAME,TYPE,TRAN,SIZE,MODEL | grep disk | grep -v usb | cut -f1 -d' '`
drives_count=0
echo "drives detected:"
for drive in $drives; do
  drives_count=$((drives_count+1))
  # MAKE=`lsblk -nio VENDOR /dev/$drive | awk '{print $1}'`
  MODEL=`lsblk -nio MODEL /dev/$drive | awk '{print $1}'`
  SIZE=`lsblk -nio SIZE,TYPE /dev/$drive | grep disk | awk '{print $1}'`
  # SERIAL=`lsblk -nio SERIAL /dev/$drive | awk '{print $1}'`
  drives_available+="/dev/$drive $MODEL,size_$SIZE    on "
  echo /dev/$drive
done
echo "number of drives $drives_count"
if [ $drives_count == 0 ]; then
  # No drives detected
  whiptail --title "$brand" --msgbox "No drives detected. Select Ok to exit." 8 78
  echo
  echo "Exiting........."
  sleep 2
  exit
else
  # Allow selection of drives to wipe
  drives_selected=$(whiptail --title "$brand" --checklist --separate-output "\n$drives_count drives are connected. \
The selected drives will be wiped in parallel." 22 90 12 $drives_available 3>&1 1>&2 2>&3)

  exitstatus=$?
  if [[ ( $exitstatus != 0 ) || ( -z $drives_selected ) ]]; then
    whiptail --title "$brand" --msgbox "No drives selected. Select Ok to exit." 8 78
    echo "Exiting........."
    exit
  fi
  echo "drives selected:"
  echo "$drives_selected"
fi
echo "Finished"
