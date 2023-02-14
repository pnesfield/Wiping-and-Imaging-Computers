#!/bin/bash
# secure erase a drive
drive=$1
logfile=`echo $drive | cut -f3 -d/`
ERASE_CMD=$2
echo "wipe_drive version 1.0" > $logfile.log
lsblk -io TYPE,VENDOR,MODEL,SERIAL,SIZE /dev/$drive | grep -v part >> $logfile.log
echo "estimated time to erase:" >> $logfile.log
hdparm -I /dev/$drive | grep -i "for security erase" | sed -e's/\t/ /g' >> $logfile.log
ERASE_TYPE=`echo $ERASE_CMD | tr a-z A-Z` 
echo "Setting password..."  >> $logfile.log
hdparm --security-set-pass password /dev/$drive > /dev/null
echo "disk Password set to password"  >> $logfile.log
MYTIMEVAR=`date +'%k:%M:%S'`
echo "disk $drive $ERASE_TYPE  started at $MYTIMEVAR"  >> $logfile.log
echo "Standby..."  >> $logfile.log
hdparm --$ERASE_CMD password /dev/$drive > /dev/null
ok=$?
sleep 10
if [ $ok -eq 0 ]; then
  MYTIMEVAR=`date +'%k:%M:%S'`
  echo "disk $drive $ERASE_TYPE finished at $MYTIMEVAR"  >> $logfile.log
  ./disk_splash.sh $drive $ERASE_CMD
else
  echo  "ER hdparm returned error: $?" >> $logfile.log
  echo -e "Erase failed." >> $logfile.log
fi

