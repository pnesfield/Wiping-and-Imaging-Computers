Wiping and Imaging Computers
============================
This series of youtube videos show how to 
1. Wipe disks using the hardware erase functions to erase or wipe a disk
2. Create reference Windows 10/11 images on hyper-V, capture and deploy them
3. Setup an infrastructure in Linux (ISC dhcp, tftp, nginx, samba) to network boot into Windows Pre-Execution Environment using PXELinux, Grub and iPXE
4. Setup a Boot system with Proxy DHCP using DNSMASQ - usable on the office LAN
5. Setup the boot server to provide internet service to the install environment for Windows Update and Drivers
6. Extract a boot.wim file for WinPE from the Recovery Environment
7. Use Wifi in WinPE
8. Modify boot.wim startnet.cmd to display a menu in WinPE
9. Adding Drivers, Powershell to boot.wim
10. Create USBs with Diskpart to boot into PXE using PXELinux and Grub
11. Use Network Share (Samba) to install reference images
12. Check if a disk has been wiped by reading track 0
13. Write a Splash screen to a disc after a wipe
14. Send wiped / imaged data to a inventory management system

Files that are used and described in:
YouTube [Channel]( https://www.youtube.com/playlist?list=PLva258t-0AhzxRBGW-IaGmlmDIgnmjdft) 

[Subscribe](http://youtube.com/@pnesfield?sub_confirmation=1) to the YouTube Channel

[Part1 Overview and Capture of a Master Windows 10 Image using DISM](https://www.youtube.com/watch?v=B0wdLjlHvmw)

[Part2 Install Master Image and Add Drivers](https://www.youtube.com/watch?v=ZGvF3Bj-0Mc)

[Part3 Install Drivers](https://www.youtube.com/watch?v=0X0ZbmlqskE)

[Part4 Add Drivers to WinPE](https://www.youtube.com/watch?v=Kl07CuJaeMM)

[Part5 Add Drivers to WinPE boot.wim using DISM](https://www.youtube.com/watch?v=bGDtoFNLBFU)

[Part6 Create a bootable USB with Diskpart](https://www.youtube.com/watch?v=MxRU0CJUDAg)

Part7 Connect to Share in WinPE with Ethernet cable and wifi

[Part8 Create bootable USB (BIOS and UEFI) using Grub](https://www.youtube.com/watch?v=oqeh-BnGe9o)

Part9 Grub bootable USB, add WinPE to menu for BIOS and UEFI modes

Part10 Grub bootable USB, add themes https://www.youtube.com/watch?v=awbK-9QFBr4

Part11 Secure Boot with Grub and Microsoft USBs https://www.youtube.com/watch?v=0bwWrugnuyI

Part12 Making a disk unreadable, Encryption is the best solution. https://www.youtube.com/watch?v=g48iExObiGI

Part13 WinPE checking if the computer's disks are encrypted https://www.youtube.com/watch?v=Z0HSpfs8XL8

Part14 Imaging encrypted disks https://www.youtube.com/watch?v=pE35_PPaNuM

Part15 Wiping with hdparm on Linux https://www.youtube.com/watch?v=4i3i_kzAM-g

Part16 Wiping using a bash script with hdparm

Part17 Wiping using an enhanced bash script using whiptail dialogs

Part18 Create a Linux PXE bootable image using debootstrap and chroot

Part19 Configure chroot to run wipe scripts and boot from the USB

Part20 Modifying a bootable .ISO file using xorriso

Part21 Update Wipe script, writing a Splash Screen to an erased disk

Part22 Setup a dhcp network boot server - dhcp configuration https://www.youtube.com/watch?v=Dn9y70VUNRU

Part23 Setup a tftp network boot server - tftp configuration https://www.youtube.com/watch?v=i2OPOmaabbQ 

Part23 bis Setup a bootp server using DNSMASQ with proxy DHCP https://www.youtube.com/watch?v=fWyyQ5SKQAE

Part24 Legacy/BIOS and UEFI network booting Grub

Part25 Create a network bootable Linux PXE image to run wipe scripts

Part26 Using http to Speed up booting in Grub by 4Xhttps://www.youtube.com/watch?v=DwdUAAq9GGc

Part27 Booting WinPE in UEFI with iPXE https://www.youtube.com/watch?v=LvUHBL3KFpw

Part28 Install Windows in PXE from a Share

Part29 Configure Routing with NAT for Linux Server

Part30 Booting WinPE in Legacy BIOS with iPXE

Part31 hyper-V Reference Images. Create PXE bootable VM in hyper-V https://youtu.be/VaGyNHbEq2s

Part32 Reference Images. Create linux based Hyper-V boot server with DHCP and TFTP

Part33 Create Virtual Machines as Reference machines, capture wim file with DISM from vhdx file

Part34 Sanitizing the System after Imaging

Part35 Weirdness and Gotchas

Part36 Deploy new image

Part37 Legacy/BIOS Booting Network with PXELinux

Part38 Modifying startnet.cmd in boot.wim https://youtu.be/iTahQpIFiuQ

Part39 Deploy New Image to USBs

Part40 Two ways to boot USB to WInPE with Grub https://youtu.be/8I4jPYtftyM

Part41 Boot USB to WinPE with Ventoy https://www.youtube.com/watch?v=wBFgagpiW2k

Part42 Checking that disk is wiped or encrypted https://www.youtube.com/watch?v=XMRejThjHZY

Part43 Deploying C++ to Winpe and testing DiskRead https://www.youtube.com/watch?v=P0zMOjdWzE0

Part44 Checking in WinPE that disks are wiped / erased prior to Imaging

Part45 Wiping / Erasing eMMC disks with Wipe Script

Part46 Wiping / Erasing NVME disks with Wipe Script

Part47 Using iSCSI as a High Speed Shared Data Source 

Part48 Using Django to log wiping and imaging events. Setup in Windows https://www.youtube.com/watch?v=L8bw1bGpYzo

Part50 Using Django to log Wiping and Imaging Events. Setup in Linux https://www.youtube.com/watch?v=HKCnrqdqvbc

Part49 Sending Imaging Events to Django from Windows using Powershell https://youtu.be/HKzFlarJirY

Part51 Sending Wiping Events to Django from Linux using Bash https://youtu.be/WmDMEX0Oc3Q

Part52 Using Windows Recovery winRE to boot to a command prompt in Windows Pre-execution Environment https://www.youtube.com/watch?v=pFfTytDX1w0

Part53 Adding Powershell to winRE https://www.youtube.com/watch?v=XuvnDemFRk0
