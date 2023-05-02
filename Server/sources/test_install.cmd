:: Test Install Undeployed image
echo off
if "%~1" == ""  (
  echo usage deploy family where family is tt or min
  goto exit
)

if not exist version-%~1.txt (
  echo family %~1% not found
  goto exit
)
@echo off
for /F "tokens=1" %%i in (version-%~1.txt) do set dir=%%i
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
echo Test install Version %new_dir%
set /P "image_ok=Are you sure Y/[N] "
if "%image_ok%"=="" goto EXIT
if /I not "%image_ok%"=="Y" goto EXIT
echo OK
echo on
cd %new_dir%
pause
setup
:EXIT
cd ..

