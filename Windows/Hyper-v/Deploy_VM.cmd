:: Deploy WIM file on Red Server
:: 5/5/23 remove copy to Red server
@echo off
if "%1"=="" (
  echo "Usage %0 tt | min"
  goto EXIT
  )
net use Y: /del
net use Y: \\192.168.0.1\sources /user:user1
Y:
for /F "tokens=1" %%i in (version-%1.txt) do set dir=%%i
SET version=%dir:~-1%
echo Current Version %version%
if %version% == 1 (
    SET new_version=2
) else if %version% == 2 (
    SET new_version=1
) else (
    echo Error image name suffix %version% must be a 1 or a 2   
)
SET new_dir=%dir:~0,-1%%new_version%
:: echo Next Version %new_version%
echo Do you want to replace
dir %dir%\install.wim
echo with
echo.
dir %new_dir%\install.wim
set /P "image_ok=Are you sure Y/[N] "
if "%image_ok%"=="" goto EXIT
if /I not "%image_ok%"=="Y" goto EXIT
echo OK
echo directory %new_dir% written to version-%~1.txt
echo %new_dir% > version-%~1.txt

:EXIT
c:
net use Y: /del