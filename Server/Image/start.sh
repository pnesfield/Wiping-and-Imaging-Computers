#!/bin/bash
atftp --get --remote-file wipe/copy_files.sh --local-file copy_files.sh 192.168.0.1
chmod 755 copy_files.sh
echo copy_files
./copy_files.sh
chmod 755 *.sh
echo menu
./menu.sh
