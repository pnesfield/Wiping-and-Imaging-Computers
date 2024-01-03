#!/bin/bash
# secure erase a drive
drive=$1
logfile=$drive.log
ERASE_CMD=$2
echo "wipe_drive version 2.0" > $logfile
if [[ $drive == *"nvme"* ]]; then
  echo "NVME drive /dev/$drive"  >> $logfile
  ERASE_TYPE="NVME format -ses 1"
  # STR_SERIAL=`lsblk -io SERIAL,TYPE /dev/$drive | grep " disk" | sed -e 's/ disk//' | sed -e 's/ //g'`
  STR_SERIAL=`nvme list /dev/$drive -o json 2> /dev/null | grep Serial | awk -F":" '{print $2}' | sed -e 's/\"//g' | sed -e 's/,//'`
  echo "SN $STR_SERIAL"  >> $logfile
  echo "ET Unknown"  >> $logfile
  echo "SE NVME Format"  >> $logfile
  echo ""  >> $logfile
  MYTIMEVAR=`date +'%k:%M:%S'`
  echo "Format started at $MYTIMEVAR"  >> $logfile
  echo "Standby..."  >> $logfile
  RESULT=`nvme format /dev/$drive -ses $SECURE_ERASE_SETTING` 2>&1 > /dev/null
  if [[ $RESULT == *Success* ]]; then
    echo $RESULT
    source ./disk_log.sh /dev/$drive $FILE "NVME Format ses $SECURE_ERASE_SETTING"
    #source ./disk_splash.sh /dev/$drive "NVME Format ses $SECURE_ERASE_SETTING"
    MYTIMEVAR=`date +'%k:%M:%S'`
    echo "      finished at $MYTIMEVAR"  >> $logfile
  else
    echo  "ER nvme returned error:"  >> $logfile
    echo $RESULT  >> $logfile
    echo -e "Erase failed. Check log $logfile"  >> $logfile
  fi  

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
  SECTORS=`blockdev --getsz /dev/$drive`
  LAST=$(($SECTORS - 1))
  echo mmc erase secure-erase 0 $LAST /dev/$drive  2>&1 3>&1 >> $logfile
  mmc erase secure-erase 0 $LAST /dev/$drive  2>&1 3>&1 >> $logfile
  ok=$?
  if [ $ok == 0 ]; then
    echo "Success"  >> $logfile
    ERASE_TYPE="mmc secure-erase" 
    #source ./disk_log.sh $drive $FILE "$ERASE_TYPE"
    #source ./disk_splash.sh $drive $ERASE_TYPE
  elif [ $ok == 1 ]; then
    echo "Failed: Secure Erase operation not supported"  >> $logfile
    echo "Use nwipe."  >> $logfile
  else
    echo "Failed: $ok"  >> $logfile
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
  fi
fi

