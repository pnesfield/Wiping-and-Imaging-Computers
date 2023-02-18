#!/bin/bash
# Update splash screen iso
drive=$1
logfile=$1.log
touch $logfile
TYPE=$2
# NVME Format ses 1
# Enhanced Secure Erase
# Secure Erase
# ttttttttttttttttttttt 
TYPE="$TYPE                      ."
STYPE=${TYPE:0:21}

echo Erase type 21 chars  >> $logfile
echo " 123456789012345678901" >> $logfile
echo ">$STYPE<" >> $logfile 
DATE=`date +%d/%m/%Y`
echo Date $DATE >> $logfile
perl -pi -e "s#xxxx-xx-xx#$DATE#" splash.iso
perl -pi -e "s/ttttttttttttttttttttt/$STYPE/" splash.iso
echo "dd if=splash.iso of=/dev/$drive" >> $logfile
dd if=splash.iso of=/dev/$drive >> $logfile  2>&1

