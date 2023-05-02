#! /bin/bash
# Switch current install.wim to a new one (without breaking anything)
# version-tt.txt has the current production version 1 or 2
# 16/2/23 Using version-tt.txt
# 13/4/23 using deploy family


if (($# < 1)) ; then
  echo usage deploy family where family is tt or min
  exit
fi
if [ ! -e version-$1.txt ]; then
  echo cannot find family version-$1.txt 
  exit
fi
dir=`cat version-$1.txt | tr -d '[:space:]'` 
version=`cat version-$1.txt | tr -d '[:space:]' | tail -c 1`
if [ -z "$version" ]; then
  echo "Error: Empty or bad image name. Must be of form xx-yy-tt1"
  exit
fi
# echo Current Version $version
if [ $version == 1 ]; then 
  new_version=2
elif [ $version == 2 ]; then 
  new_version=1
else
  echo Error image name suffix $version must be a 1 or a 2 
fi
# echo Next Version $new_version

new_dir=${dir::-1}$new_version
echo "Do you want to replace"
ls -l $dir/install.wim
echo "With"
ls -l $new_dir/install.wim
read -p "Are you sure? " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi
$new_dir > version-tt.txt

