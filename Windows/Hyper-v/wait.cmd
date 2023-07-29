:: Alternative to pings which wait 1 second but tie up network
:: wait n
:: Wait for n seconds
:: November 2021 philn

@echo off
set sec=%time:~6,2%
:: set /A considers 09 as a bad Octal number, so remove leading 0s
::echo %sec~0,1% 
if "%sec:~0,1%" EQU "0" (set /A sec=%sec:~1,1%) else (set /A sec=%sec%)
set /A esec=sec + %1
::echo %sec%  now %esec%
set /A esec=esec%%60
::echo %esec% modulo
:wait
::echo now %sec%  end %esec% 
set sec=%time:~6,2%
if "%sec:~0,1%" EQU "0" (set /A sec=%sec:~1,1%) else (set /A sec=%sec%)
if %sec% neq %esec% goto wait