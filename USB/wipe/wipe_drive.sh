#!/bin/bash
# secure erase a drive
drive=$1
logfile=`echo $drive | cut -f3 -d/`
ERASE_CMD=$2
echo "wipe_drive version 1.0" > $logfile.log
lsblk -io TYPE,VENDOR,MODEL,SERIAL,SIZE $drive | grep -v part >> $logfile.log
echo "estimated time to erase:" >> $logfile.log
hdparm -I $drive | grep -i "for security erase" | sed -e's/\t/ /g' >> $logfile.log
ERASE_TYPE=`echo $ERASE_CMD | tr a-z A-Z` 
echo "Setting password..."  >> $logfile.log
hdparm --security-set-pass password $drive > /dev/null
echo "disk Password set to password"  >> $logfile.log
MYTIMEVAR=`date +'%k:%M:%S'`
echo "disk $ERASE_TYPE  started at $MYTIMEVAR"  >> $logfile.log
echo "Standby..."  >> $logfile.log
hdparm --$ERASE_CMD password $drive > /dev/null
sleep 10
if [ $? -eq 0 ]; then
  MYTIMEVAR=`date +'%k:%M:%S'`
  echo "disk $ERASE_TYPE finished at $MYTIMEVAR"  >> $logfile.log
else
  echo  "ER hdparm returned error: $?" >> $logfile.log
  echo -e "Erase failed." >> $logfile.log
fi

