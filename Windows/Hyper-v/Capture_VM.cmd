:: Generate WIM file from Hyper-V VMs
:: 4/5/23 Use 2 mount directories to avoid wait
:: 5/5/23 Remove Are-you-sure
:: 5/5/23 reworded Defender Check
:: 15/5/23 Pause when Defender running
@echo off
set debug=true
:: set debug=
if "%1"=="" (
  echo "Usage %0 tt | min"
  goto EXIT
  )
set im=Win10-x64Pro-%1
::set im=Win10-x64-Pro-%1
powershell /Command Write-Output($(Get-MpComputerStatus).RealTimeProtectionEnabled) > defenderTemp.txt
set /p defender= < defenderTemp.txt
echo Windows Defender is running %defender%
if "%defender%" == "True" (
  echo Stop Defender RealTime Protect to speed up this process
  pause
  )
for /F "tokens=1" %%i in ('date /t') do set today=%%i
time /t
echo on
dism /Mount-Image /ImageFile:VMs\%im%.vhdx /Index:1 /MountDir:mount1 /ReadOnly
dism /capture-Image /imagefile:win10-x64-%1\install.wim /CaptureDir:mount1  /ConfigFile:Capture.ini  /name:"%im%" /Description:"%im% %today%"
@echo off
time /t
dism /Unmount-Image /MountDir:mount1 /Discard
:: call wait 10

:CORE
set im=Win10-x64Core-%1
:: set im=Win10-x64-Core-%1
::echo Check VM is not running 
::powershell /Command Write-Output($(Get-VM -name %im%).State)
echo on
dism /Mount-Image /ImageFile:VMs\%im%.vhdx /Index:1 /MountDir:mount2  /ReadOnly
dism /Append-Image /ImageFile:win10-x64-%1\install.wim /CaptureDir:mount2 /ConfigFile:Capture.ini /name:"%im%" /Description:"%im% %today%"
@echo off
time /t
echo on


dism /Unmount-Image /MountDir:mount2 /Discard
dism /get-imageinfo /imagefile:win10-x64-%1\install.wim
:exit