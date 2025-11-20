@echo off
echo list vol > x:\pp.txt
echo On Computer
diskpart /s x:\pp.txt | findstr Volume
echo:
call :vers C: \Windows\System32\config\SOFTWARE
call :vers D: \Windows\System32\config\SOFTWARE
call :vers E: \Windows\System32\config\SOFTWARE
call :vers F: \Windows\System32\config\SOFTWARE
exit /B
:vers
if EXIST %~1%~2 (
reg load HKLM\temp %~1%~2 > NUL
reg query "HKLM\temp\Microsoft\Windows NT\CurrentVersion" /v ProductName | findstr ProductName > X:\pp.txt.
reg unload HKLM\temp > NUL
for /F "tokens=3*" %%i In (X:\pp.txt) Do (
 set Product=%%i
 set fam=%%j
)
echo On Drive %~1 Product %Product% %fam%
) else (
  rem echo %~1 Not a Windows System Disk
)