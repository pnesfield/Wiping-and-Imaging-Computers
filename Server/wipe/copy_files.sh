#!/bin/bash
atftp --get --remote-file wipe/disk_splash.sh --local-file disk_splash.sh 192.168.0.1
atftp --get --remote-file wipe/erase_script.sh --local-file erase_script.sh 192.168.0.1
atftp --get --remote-file wipe/finish.sh --local-file finish.sh 192.168.0.1
atftp --get --remote-file wipe/menu.sh --local-file menu.sh 192.168.0.1
atftp --get --remote-file wipe/splash.iso --local-file splash.iso 192.168.0.1
atftp --get --remote-file wipe/wipe_drive.sh --local-file wipe_drive.sh 192.168.0.1
