#!/bin/bash
DEBUG=$false
url=$1
url="http://RedDev1:8000"
source wipelib.sh
SERIAL=$(dmidecode -s system-serial-number)
checkSerial  $url
if [ $DEBUG ]; then echo checkSerial Return $RETURN; fi
ASSET=$RETURN
getAsset $ASSET
ASSET=$RETURN
if [ $DEBUG ]; then echo getAsset return $RETURN; fi
MAKE=$(dmidecode -s system-manufacturer)
MODEL=$(dmidecode -s system-product-name)
NAME=$(uname -n)
#CPU=`lshw -short | grep -m1 processor | awk '{for (i=3; i<NF; i++) printf $i " "; if (NF >= 4) print $NF; }'`
CPU=$(dmidecode -s processor-version)
TYPE=$(dmidecode -s chassis-type)
BIOSMAKE=$(dmidecode -s bios-vendor)
BIOSNAME=$(dmidecode -s bios-version)
MEMSIZE=$(grep MemTotal /proc/meminfo | cut -f 2 -d :)
lshw > lshw.txt
i=0
MEM=""
while [ $i -le 5 ]
do
  MEMMAKE=$(cat lshw.txt | grep -A 6 bank:$i | grep vendor | cut -f 2 -d :)
  MEMMODEL=$(cat lshw.txt | grep -A 6 bank:$i | grep product | cut -f 2 -d :)
  MEMMODSIZE=$(cat lshw.txt | grep -A 8 bank:$i | grep size | cut -f 2 -d :)
  SLOT=$(cat lshw.txt | grep -A 6 bank:$i | grep slot | cut -f 2 -d :)
  if [ "$SLOT" == "" ]; then
    break
  fi
  MEM=$MEM$'\n'MemSlot:$SLOT$'\n'MemMake:$MEMMAKE$'\n'MemModel:$MEMMODEL$'\n'MemModSize:$MEMMODSIZE
  ((i++))
done
BATTERYCAP=$(sudo dmidecode | grep -A6 '^Portable Battery' | grep "Capacity" | awk -F":" '{print $2}' | sed -e 's/^[ <t]*//;s/[ <t]*$//' | head -n 1)
if [ "$BATTERYCAP" == "" ]; then
   BATTERY=""
else
   BATTERY="OK"
fi

POST=Asset:$ASSET$'\n'State:Wipe$'\n'Serial:$SERIAL$'\n'Make:$MAKE$'\n'Model:$MODEL$'\n'Name:$NAME$'\n'Processors:$CPU$'\n'PCSystemType:$TYPE$'\n'BiosManufacturer:$BIOSMAKE$'\n'BiosName:$BIOSNAME$'\n'MemSize:$MEMSIZE$'\n'$MEM$'\n'BatteryStatus:$BATTERY$'\n'BatteryCapacity:$BATTERYCAP
echo "Posting"
if [ $DEBUG ]; then echo $POST; fi
RETURN=$(curl -X Post --data "$POST" $url/ws/log.html 2>/dev/null)
echo "Returned $RETURN"
if [[ $RETURN == Error:* ]]; then
    whiptail --title "$brand" --msgbox "django returned $RETURN" 8 78 
    exit
fi
