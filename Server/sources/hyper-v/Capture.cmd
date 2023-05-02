:: Generate WIM file from Hyper-V VMs
@echo off
::goto COPY
if "%1"=="" (
  echo "Usage %0 tt | min"
  goto EXIT
  )
set im=win10-x64Pro-%1
for /F "tokens=1" %%i in ('date /t') do set today=%%i
time /t
echo on
dism /Mount-Image /ImageFile:VMs\%im%.vhdx /Index:1 /MountDir:mount /ReadOnly
dism /capture-Image /imagefile:install.wim /CaptureDir:mount  /ConfigFile:Capture.ini  /name:"%im%" /Description:"%im% %today%"
@echo off
time /t
dism /Unmount-Image /MountDir:mount /Discard

:CORE
dism /get-imageinfo /imagefile:install.wim
dir "install.wim" | find "install.wim"
set /P "image_ok=Is this the image you want to append to Y/[N] "
if "%image_ok%"=="" goto EXIT
if /I not "%image_ok%"=="Y" goto EXIT
set im=Win10-x64Core-%1
dism /Mount-Image /ImageFile:VMs\%im%.vhdx /Index:1 /MountDir:mount  /ReadOnly
echo on
dism /Append-Image /ImageFile:install.wim /CaptureDir:mount /ConfigFile:Capture.ini /name:"%im%" /Description:"%im% %today%"
@echo off
time /t
dism /Unmount-Image /MountDir:mount /Discard
dism /get-imageinfo /imagefile:install.wim

:COPY
net use Y: /del
net use Y: \\192.168.0.1\sources /user:user1
for /F "tokens=1" %%i in (Y:\version-%1.txt) do set dir=%%i
:: echo Current Version %version%
SET version=%dir:~-1%
if %version% == 1 (
    SET new_version=2
) else if %version% == 2 (
    SET new_version=1
) else (
    echo Error image name suffix %version% must be a 1 or a 2   
)
SET new_dir=%dir:~0,-1%%new_version%
echo Copy install.wim to Y:\%new_dir%
set /P "image_ok=Are you sure Y/[N] "
if "%image_ok%"=="" goto EXIT
if /I not "%image_ok%"=="Y" goto EXIT
echo OK
robocopy . Y:\%new_dir% install.wim
:EXIT
net use Y: /del