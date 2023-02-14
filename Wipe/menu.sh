#!/bin/bash
version=V1.0
title="Disk Wipe Utility $version"
export NEWT_COLORS='
window=white,black
border=white.black
textbox=white,black
button=white,red
'

while true; do

  selection=$(whiptail --title "$title" --menu "\nPlease select an option:\n " 22 78 12 \
  "Erase" "Run the Secure Erase script."\
  "Shell" "Run a bash shell." \
  "Shutdown" "Shutdown the machine." \
  "Reboot" "Reboot the machine." \
  "About" "Info about the wipe script" \
    3>&1 1>&2 2>&3);
  #"Wipe Advanced" "Run the wipe sript with advanced options."
    if [ "$selection" == "Erase" ]; then
      bash -c "./erase_script.sh"   
    elif [ "$selection" == "Shell" ]; then
        clear
        echo
        echo
        echo "Type exit to return to this menu."
        sleep 2
        bash --norc --noprofile
    elif [ "$selection" == "Shutdown" ]; then
        echo
        echo "Shutting down..."
        sleep 2
        shutdown -h 0
        exit
    elif [ "$selection" == "Reboot" ]; then
          echo
          echo "Rebooting..."
          sleep 2
          shutdown -r 0
          exit
    elif [ "$selection" == "About" ]; then        
      whiptail --title "Info" --msgbox "`cat about.txt`" 25 78 --scrolltext


    else
        echo "Selection " $selection
    sleep 2
    fi
done
