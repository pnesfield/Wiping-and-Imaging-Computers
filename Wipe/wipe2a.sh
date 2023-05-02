#!/bin/bash
# Use secure erase or enhanced secure erase to wipe a disk
DEBUG=
DEV=$1
DEV="/dev/sdb"
  echo "Checking $DEV"
  lsblk -io TYPE,VENDOR,MODEL,SERIAL,SIZE $DEV | grep -v part
  HDTEST=`hdparm -I $DEV 2>&1 | grep "SG_IO: bad/missing sense data" | awk '{print $1}'`
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

  LOCK=`hdparm -I $DEV | grep locked | grep -c not`
  if [ $LOCK == 0 ]; then
    echo "disk is locked with a password"
    echo "Unlocking..."
    echo "hdparm --security-disable password --verbose $DEV"
    hdparm --security-disable password --verbose $DEV 
  else
    echo "disk is not Locked"
  fi

  DOIT=True
  while  [ "$DOIT" == "True" ]; do
    FROZEN=`hdparm -I $DEV | grep frozen | grep -c not`
    if [ $FROZEN == 0 ]; then
      echo "disk is frozen, System Sleep required"
      read -p "Continue Y[N]" ANS
      if [ "$ANS" == "Y" ]; then
        echo "sleep"
        rtcwake -u -s 10 -m mem
      else
        DOIT=
      fi
    else
      echo "disk is not frozen"
      DOIT=
    fi
  done
  ENHANCED_ERASE=`hdparm -I $DEV | grep -i enhanced | grep -c not`
  if [ $ENHANCED_ERASE == 0 ]; then
    # Inverse logic
    ERASE_TYPE="Enhanced Secure Erase" 
    ERASE_CMD="security-erase-enhanced"
  else
    ERASE_TYPE="Secure Erase"
    ERASE_CMD="security-erase"
  fi
  echo "disk supports $ERASE_TYPE"
  ERASE_TIME=`hdparm -I $DEV | grep -i "for security erase" | sed -e's/\t/ /g'`
  echo "disk estimated time to erase:"
  echo " $ERASE_TIME"
  if [ $ENHANCED_ERASE == 0 ]; then
    read -p "use enhanced erase Y[N]" ANS
    if [ "$ANS" != "Y" ]; then
      ERASE_TYPE="Secure Erase"
      ERASE_CMD="security-erase"
    fi
  fi

  echo "Setting password..."
  hdparm --security-set-pass password $DEV > /dev/null
  echo "disk Password set to password"
  MYTIMEVAR=`date +'%k:%M:%S'`
  echo "disk $ERASE_TYPE  started at $MYTIMEVAR"
  echo "Standby..."
  hdparm --$ERASE_CMD password $DEV > /dev/null
  if [ $? -eq 0 ]; then
    MYTIMEVAR=`date +'%k:%M:%S'`
    echo "disk $ERASE_TYPE finished at $MYTIMEVAR" 
    echo
  else
    echo  "ER hdparm returned error: $?"
    echo -e "Erase failed. Check log"
  fi

