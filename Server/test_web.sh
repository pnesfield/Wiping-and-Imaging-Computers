#!/bin/bash
echo tftp
time atftp --get --remote-file wipe/initrd --local-file initrd 192.168.0.1
rm initrd
sudo service nginx stop
sudo service apache2 start
echo apache2
time wget http://192.168.0.1/wipe/initrd
rm initrd
sudo service apache2 stop
echo nginx
sudo service nginx start
time wget http://192.168.0.1/wipe/initrd
rm initrd
