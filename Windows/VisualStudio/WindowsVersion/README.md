## WindowsVersion winver

Win PE Find version of the OS on a computer's disk. Looks for a well known Windows file ntoskrnl.exe, gets version and prints result.

Designed for use during computer recycling, assumes the OS is licensed and that a reinstall would activate properly. So boot straight to Win PE, check OS and then proceed with wipe / installation.

Designed to run in Win PXE this involves statically linked libraries, setup in VS project properties.


F:>WindowsVersion

C: Not Found

E: Windows 10 Version: 6.2.19041.4780 

X: Windows 10 Version: 6.2.18362.418 

F:>

This shows that the hard disk (E:) has a windows 10 installation, X: is the Win PXE OS. Notice the Version 6.2 indicates Windows 8. See [Windows Version](https://en.wikipedia.org/wiki/List_of_Microsoft_Windows_versions) so the Version is identified from the build number - see code. There are various explanations of this, even Windows 11 reports the version of ntoskrnl as Version 10. Ver (not available in WinPE) probably gets the version from the registry

