:: Menu for USB UEFI 
:: August 2022 philn
:: 17/8/22 Added Connect
:: 18/8/22 Use robocopy
:: 16/9/22 Added install log review
:: 26/9/22 forked for Msoft USB
:: 9/5/23 Test for Y: Continue download
@echo off
:MENU
echo.
echo ..................................
echo PXE USB Imaging Menu V1.2
echo ..................................
set M=""
echo.
echo 1 - Install Win10-x64-TT from USB
echo 2 - Install from network
echo 3 - Check for Updated Win10-x64-TT
echo 4 - Copy Updated Win10-x64-TT to USB
echo 5 - Exit to DOS
echo.
SET /P M=Type 1, 2, 3, 4 or 5 then press ENTER:  
if "%M%"=="" Goto G5
IF Not %M%==1 GOTO G2
echo Win10-x64-TT - Install
cd images\win10-x64-tt
setup
cd \
goto MENU

:G2
if not %M%==2 goto G3
if not exist Y: (
  start /wait connect.cmd
)
Y:
menu
goto G5

:G3
if not %M%==3 goto G4
if not exist Y: (
start /wait connect.cmd
)
echo USB Type
wmic path CIM_USBDevice  get Name
echo Network Speed
wmic nic where netEnabled=true get name,speed,status
echo Copy if speed is 1000000000 and USB 3.0
for /F "tokens=1" %%i in (Y:\version-tt.txt) do set dir=%%i
echo Latest install timestamp
echo **************************************************
:: WinPE has no findstr
dir Y:\%dir%\install.wim
echo This install timestamp
echo **************************************************
dir images\win10-x64-tt\install.wim
set /P "ans=Continue with download Y/[N] "
if "%ans%"=="" goto menu
if /I not "%ans%"=="Y" goto MENU

:G4
if not %M%==4 goto G5
if not exist Y: (
  start /wait connect.cmd
)
for /F "tokens=1" %%i in (Y:\version-tt.txt) do set dir=%%i
echo time now %time%
del sources\win10-x64-tt\install.wim
robocopy Y:\%dir% images\win10-x64-tt install.wim
goto MENU

:G5
if not %M%==5 goto MENU
echo Exit to DOS. To return to menu type MENU at DOS prompt
:EXIT



