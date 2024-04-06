#!/bin/bash
brand="Syslog Version 1.0"
function getAsset() {
  ASSET=$1
  while [ true ]
  do
    RESULT=$(whiptail --title "$brand" --inputbox "Please enter the asset number (double check your entry):" 8 78 $ASSET --title "$brand" 3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus != 0 ]; then
      sleep 5
      echo dialog error - aborting
      exit
    fi
  
    if [ "$RESULT" != "" ]; then
      # Check RESULT is a number
      if [[ $RESULT == *[[:digit:]]* ]]; then
        RESULT=00000000$RESULT
        RETURN=${RESULT: -8}
        break
      else
          if (whiptail --title "$brand" --yesno " $RESULT must be Numeric\n\n    Do you want to continue?" 20 78); then
            echo OK
            RESULT=""
          else
            echo
            echo "Exiting    ..."
            sleep 2
            exit
          fi
      fi

    fi
  done
}

function checkSerial() {
  url=$1
  SERIAL=$(dmidecode -s system-serial-number)
  # echo checkSerial $SERIAL
  RETURN=$(curl -X Post --data "$SERIAL" $url/ws/asset.html 2>/dev/null)
  if [[ $RETURN == Error:* ]]; then
    whiptail --title "$brand" --msgbox "django returned $RETURN" 8 78 
    exit
  fi
}
