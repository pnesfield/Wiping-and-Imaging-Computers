:: Deploy WIM file to Red Server
if "%1"=="" (
  echo "Usage %0 tt | min"
  goto EXIT
  )
net use Y: /del
:: Mint 21 version
net use Y: \\192.168.0.1\sources /user:user1
:: net use Y: \\192.168.0.1\os\development /user:turing Ghana2009
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
echo Copy win10-x64-%1\install.wim to Y:\%new_dir%
set /P "image_ok=Are you sure Y/[N] "
if "%image_ok%"=="" goto EXIT
if /I not "%image_ok%"=="Y" goto EXIT
echo OK
robocopy win10-x64-%1 Y:\%new_dir% install.wim
:EXIT
net use Y: /del