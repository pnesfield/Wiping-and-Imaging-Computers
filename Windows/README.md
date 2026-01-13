Wiping and Imaging Computers
============================
##Django
Send wiped / imaged data to a inventory management system (Part 48, 49, 50 and 51)

[Part48 Using Django to log wiping and imaging events. Setup in Windows](https://www.youtube.com/watch?v=L8bw1bGpYzo)

[Part49 Sending Imaging Events to Django from Windows using Powershell](https://youtu.be/HKzFlarJirY)

[Part50 Using Django to log Wiping and Imaging Events. Setup in Linux](https://www.youtube.com/watch?v=HKCnrqdqvbc)

[Part49 Sending Imaging Events to Django from Windows using Powershell](https://youtu.be/HKzFlarJirY)

##Hyper-V 
Create reference Windows 10/11 images on hyper-V, capture and deploy them (Part 31, 33 and 36), deploy to USBs (Part 39)

[Part31 hyper-V Reference Images. Create PXE bootable VM in hyper-V](https://youtu.be/VaGyNHbEq2s)

[Part33 Create Virtual Machines as Reference machines, capture wim file with DISM from vhdx file](https://youtu.be/Hv3zRsTkaIg)

##Preview

Display information concerning the computer such Vendor, Model Memory, Disk License in BIOS, some BIOS settings etc

##VisualStudio

###DiskRead
Check if a disk has been wiped or encrypted by reading track 0 (Part 42, 43 and 44)). Used in Preview
[Part42 Checking that disk is wiped or encrypted](https://www.youtube.com/watch?v=XMRejThjHZY)

[Part43 Deploying C++ to Winpe and testing DiskRead](https://www.youtube.com/watch?v=P0zMOjdWzE0)

[Part44 Checking in WinPE that disks are wiped / erased prior to Imaging](https://youtu.be/oJ7Qo91fvi8)

###EnumProductKey
Used in Preview

###WindowsVersion
Find version of the OS on a computer's disk. Looks for a well known Windows file ntoskrnl.exe, gets version and prints result.

### GetDrivers.ps1

Powershell scripts to get drivers in the Windows environment to load into WinPE. GetDrivers2.ps1 only gets signed drivers, since unsigned drivers cause problems.

[Part5 Add Drivers to WinPE boot.wim using DISM](https://www.youtube.com/watch?v=bGDtoFNLBFU)
