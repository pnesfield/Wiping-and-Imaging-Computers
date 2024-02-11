#!/bin/bash
# secure erase a drive
drive=$1
logfile=$drive.log
ERASE_CMD=$2
echo "wipe_drive version 2.0" > $logfile
if [[ $drive == *"nvme"* ]]; then
  echo "NVME drive /dev/$drive"  >> $logfile
  SECURE_ERASE_SETTING=1
  ERASE_TYPE="NVME format -ses $SECURE_ERASE_SETTING"
  SIZE=`lsblk -nio SIZE,TYPE /dev/$drive | grep disk | awk '{print $1}'`
  SERIAL=`lsblk -io SERIAL,TYPE /dev/$drive | grep " disk" | sed -e 's/ disk//' | sed -e 's/ //g'`
  MODEL=`lsblk -nio MODEL,TYPE /dev/$drive  | grep " disk" `
  MYTIMEVAR=`date +'%k:%M:%S'`
  echo "Format started at $MYTIMEVAR"  >> $logfile
  echo "Model $MODEL Size $SIZE Serial $SERIAL"  >> $logfile
  echo "Standby..."  >> $logfile
  echo nvme format /dev/$drive -ses $SECURE_ERASE_SETTING >> $logfile
  ./nvme format /dev/$drive -ses $SECURE_ERASE_SETTING >> $logfile  2>&1  3>&1
  ok=$?
  if [[ $ok == 0 ]]; then
    echo "Success"  >> $logfile
    #source ./disk_log.sh /dev/$drive $FILE "NVME Format ses $SECURE_ERASE_SETTING"
    #source ./disk_splash.sh /dev/$drive "NVME Format ses $SECURE_ERASE_SETTING"
  else
    echo  "ERROR: nvme returned error: $ok"  >> $logfile
    echo "Erase failed. Check log $logfile"  >> $logfile
    ./fail.sh  >> $logfile
  fi
  MYTIMEVAR=`date +'%k:%M:%S'`
  echo "      finished at $MYTIMEVAR"  >> $logfile 

elif [[ $drive == *"mmc"* ]]; then
  MYTIMEVAR=`date +'%k:%M:%S'`
  SIZE=`lsblk -nio SIZE,TYPE /dev/$drive | grep disk | awk '{print $1}'`
  SERIAL=`lsblk -nio SERIAL /dev/$drive | awk '{print $1}'`
  #SERIAL=`udevadm info -a -n /dev/$drive | grep serial  | awk -F"=" '{print $3}' | sed -e 's/"//g'`
  # This returns blanks
  #MODEL=`lsblk -nio MODEL /dev/$drive | awk '{print $1}'`
  MODEL=`udevadm info -a -n /dev/$drive | grep name  | awk -F"=" '{print $3}' | sed -e 's/"//g'`
  echo "MMC secure-erase started at $MYTIMEVAR"  >> $logfile
  echo "Model $MODEL Size $SIZE Serial $SERIAL"  >> $logfile
  HEXTYPE=`./mmc extcsd read /dev/$drive | grep "REMOVAL_TYPE" | awk -F":" '{print $2}'`
  SECTORS=`blockdev --getsz /dev/$drive`
  LAST=$(($SECTORS - 1))
  ERASE_TYPE="secure-erase"
  echo mmc erase $ERASE_TYPE 0 $LAST /dev/$drive >> $logfile
  ./mmc erase $ERASE_TYPE 0 $LAST /dev/$drive >> $logfile 2>&1 3>&1
  ok=$?
  if [ $ok == 0 ]; then
    echo "Success"  >> $logfile
    #source ./disk_log.sh $drive $FILE "$ERASE_TYPE"
    #source ./disk_splash.sh $drive $ERASE_TYPE
  elif [ $ok == 1 ]; then
    echo "Failed: $ERASE_TYPE operation not supported"  >> $logfile
    ./fail.sh
  elif [ $ok == 127 ]; then
    echo "Failed: $ERASE_TYPE operation not supported"  >> $logfile
    ERASE_TYPE="legacy"
    echo mmc erase $ERASE_TYPE 0 $LAST /dev/$drive >> $logfile 2>&1 3>&1
    ./mmc erase $ERASE_TYPE 0 $LAST /dev/$drive >> $logfile 2>&1 3>&1
    ok=$?
    if [ $ok == 0 ]; then
      echo "Success"  >> $logfile
      #source ./disk_log.sh $drive $FILE "$ERASE_TYPE"
      #source ./disk_splash.sh $drive $ERASE_TYPE
    else
      echo "Failed: $ok"  >> $logfile
      ./fail.sh   >> $logfile
    fi
  else
    echo "Failed: $ok"  >> $logfile
    ./fail.sh   >> $logfile
  fi
  MYTIMEVAR=`date +'%k:%M:%S'`
  echo "      finished at $MYTIMEVAR"  >> $logfile

else
  lsblk -io TYPE,VENDOR,MODEL,SERIAL,SIZE /dev/$drive | grep -v part >> $logfile
  echo "estimated time to erase:" >> $logfile
  hdparm -I /dev/$drive | grep -i "for security erase" | sed -e's/\t/ /g' >> $logfile
  ERASE_TYPE=`echo $ERASE_CMD | tr a-z A-Z` 
  echo "Setting password..."  >> $logfile
  hdparm --security-set-pass password /dev/$drive > /dev/null
  echo "disk Password set to password"  >> $logfile
  MYTIMEVAR=`date +'%k:%M:%S'`
  echo "disk $drive $ERASE_TYPE  started at $MYTIMEVAR"  >> $logfile
  echo "Standby..."  >> $logfile
  hdparm --$ERASE_CMD password /dev/$drive > /dev/null
  ok=$?
  sleep 10
  if [ $ok -eq 0 ]; then
    MYTIMEVAR=`date +'%k:%M:%S'`
    echo "disk $drive $ERASE_TYPE finished at $MYTIMEVAR"  >> $logfile
    # ./disk_splash.sh $drive $ERASE_CMD
  else
    echo  "ER hdparm returned error: $?" >> $logfile
    echo -e "Erase failed." >> $logfile
    ./fail.sh   >> $logfile
  fi
fi

