:: November 2019 philn
:: 4/12/19 Added ping to improve reliability of net use
:: 25/2/21 Added loop
:: 12/11/21 Added target
:: 12/11/21 Added stop ikeext which interferes with net use
:: 22/3/22 remove pause
:: 16/5/22 Added second wait before mounting the share
:: 4/4/22 add dev instructions
:: 22/4/22 Fixed spelling errors
:: 9/5/22 forked for wifi
:: 11/5/22 use install.cmd
:: 16/8/22 forked from startnet.cmd
@echo off
echo "Connect Windows 10 wifi -  version 3.2"
wpeinit
net start wlansvc
::netsh wlan add profile filename=\Murdoch.xml
netsh wlan add profile filename=\TuringTrust-Imaging.xml
set server=192.168.0.1
::set server=192.168.10.54

echo Looking for server...
set /a counter=1
:LOOP1
echo Attempt %counter%
set /a counter+=1
ping %server%
if errorlevel 1 GOTO LOOP1
echo Found server
call wait 3
net stop ikeext
echo Mounting share...
net use Y: \\%server%\sources /user:user1
if errorlevel 0 GOTO NEXT1
echo Failed to mount  \\%server%\sources
goto FINISH

:NEXT1
pause
exit


