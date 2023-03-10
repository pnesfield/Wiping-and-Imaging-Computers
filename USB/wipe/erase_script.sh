#!/bin/bash
# Use secure erase or enhanced secure erase to wipe a disk
DEBUG=
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
  whiptail --title "$brand" --msgbox "No drives detected. Select Ok to exit." 22 78 12
  echo
  echo "Exiting........."
  sleep 2
  exit
else
  # Allow selection of drives to wipe
  drives_selected=$(whiptail --title "$brand" --checklist --separate-output "\n$drives_count drives are connected. \
The selected drives will be wiped in parallel." 22 78 12 $drives_available 3>&1 1>&2 2>&3)

  exitstatus=$?
  if [[ ( $exitstatus != 0 ) || ( -z $drives_selected ) ]]; then
    whiptail --title "$brand" --msgbox "No drives selected. Select Ok to exit." 8 78
    echo "Exiting........."
    exit
  fi
  echo "drives selected:"
  echo "$drives_selected"
fi

SLEEP=False
for drive in $drives_selected; do
  echo "Checking $drive"
  lsblk -io TYPE,VENDOR,MODEL,SERIAL,SIZE $drive | grep -v part
  HDTEST=`hdparm -I $drive 2>&1 | grep "SG_IO: bad/missing sense data" | awk '{print $1}'`
  if [ $HDTEST ]; then
    echo "Checking $DEV"
    echo "disk does not support secure erase"
    echo ""
    echo "- might be a RAID volume"
    echo "- might be an old disc"
    echo "- might be broken"
    sleep 2
    exit
  fi

  LOCK=`hdparm -I $drive | grep locked | grep -c not`
  if [ $LOCK == 0 ]; then
    echo "disk is locked with a password"
    echo "Unlocking..."
    echo "hdparm --security-disable password --verbose $DEV"
    hdparm --security-disable password --verbose $DEV 
  else
    echo "disk is not Locked"
  fi

  FROZEN=`hdparm -I $drive | grep frozen | grep -c not`
  if [ $FROZEN == 0 ]; then
    echo "disk is frozen, System Sleep required"
    SLEEP=True
  fi
done

if [ "$SLEEP" == "True" ]; then
  echo "Sleeping .."
  rtcwake -u -s 10 -m mem
fi

for drive in $drives_selected; do
  ENHANCED_ERASE=`hdparm -I $drive| grep -i enhanced | grep -c not`
  if [ $ENHANCED_ERASE == 0 ]; then
    # Inverse logic
    ERASE_TYPE="Enhanced Secure Erase" 
    ERASE_CMD="security-erase-enhanced"
  else
    ERASE_TYPE="Secure Erase"
    ERASE_CMD="security-erase"
  fi
  
  echo ""
  ERASE_TIME=`hdparm -I $drive | grep -i "for security erase" | sed -e's/\t/ /g'`
  echo "disk estimated time to erase:"
  echo " $ERASE_TIME"
  if [ $ENHANCED_ERASE == 0 ]; then
    MESS=`lsblk -nio TYPE,TRAN,SIZE,MODEL $drive  | grep -v part`
    if (whiptail --title "$brand" --yesno "$drive $MESS\ndisk supports $ERASE_TYPE\n
disk estimated time to erase:\n$ERASE_TIME\n\ndo you want to use $ERASE_TYPE" 20 78); then
      echo $ERASE_TYPE
    else
      ERASE_TYPE="Secure Erase"
      ERASE_CMD="security-erase"
    fi
  fi
  (./wipe_drive.sh $drive $ERASE_CMD &)
done

while true; do
  FINISHED=0
  clear
  for drive in $drives_selected; do
    CHECK=`ps -ef | grep -c "wipe_drive.sh $drive $ERASE_CMD"`  
    if [ $CHECK -ne 1 ]; then
      FINISHED=1
    fi
    logfile=`echo $drive | cut -f3 -d/`
    tail $logfile.log
    echo ""
  done
  if [ $FINISHED == 0 ]; then
      break
  fi
  sleep 2
done
read -p "Continue ?" ANS
echo "Finished"
