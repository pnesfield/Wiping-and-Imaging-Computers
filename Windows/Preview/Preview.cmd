:: Preview System Details
:: August 2024 philn
:: 12/9/24 slow initialise of WinPE registry
:: 18/9/24 set logdir for WinPE
:: 28/9/24 added bitlocker
:: 18/10/24 added DiskRead
:: 11/12/24 Added CPUid
:: 6/4/25 Added Serial Number
:: 29/4/25 No TPM update
:: 6/5/25 Handle " in disk
@echo off
setlocal enabledelayedexpansion
set logdir=
set regtree=SOFTWARE
if %SystemDrive%==X: (
  set logdir=X:\
  set regtree=temp
)
echo Preview Log > %logdir%Preview.log
call :wmiget "path win32_computersystem get Manufacturer" 
set manufacturer=%val%
call :wmiget "path win32_computersystem get Model" 
set model=%val%
call :wmiget "bios get serialnumber"
set serialnumber=%val%
echo Manufacturer: %manufacturer% Model: %model% Serial Number: %serialnumber%
echo Manufacturer: %manufacturer% Model: %model% Serial Number: %serialnumber%   >> %logdir%Preview.log
echo ============ Memory ============
echo ============ Memory ============  >> %logdir%Preview.log
:: wmic path Win32_OperatingSystem get TotalVisibleMemorySize | Findstr /r /v "^$"
call :wmiget "path win32_computersystem get totalphysicalmemory" 
echo %val% > %logdir%pp.txt
type %logdir%pp.txt >> %logdir%Preview.log
for /F "tokens=1 USEBACKQ  delims= " %%i In (%logdir%pp.txt) Do set memorycapacity=%%i
set "memorycapacityMB=%memorycapacity:~,-6%"
set /A memorycapacity=%memorycapacityMB% + 0
if %memorycapacityMB% GTR 8192  (
  echo Memory size: %memorycapacityMB% MB  ****Larger than necessary *****
) else (
  echo Memory size: %memorycapacityMB% MB
)
call :wmiget "path win32_physicalmemory get memorytype"
set /A memorytype=%val% + 0
set type=%memorytype%
if %memorytype% EQU 20 ( set type=DDR )
if %memorytype% EQU 21 ( set type=DDR2 )
if %memorytype% EQU 22 ( set type=DDR2-FB-DIMM )
if %memorytype% EQU 24 ( set type=DDR3 )
if %memorytype% EQU 25 ( set type=FBD2 )
if %memorytype% EQU 26 ( set type=DDR4 )
call :wmiget "path win32_physicalmemory get formfactor"
set /A formfactor=%val% + 0
set form=%formfactor%
if %formfactor% EQU 7 ( set form=SIMM )
if %formfactor% EQU 8 ( set form=DIMM )
if %formfactor% EQU 12 ( set form=SODIMM )
if %formfactor% EQU 14 ( set form=SMD )
echo Memory Type: %type% Form Factor: %form%
wmic path win32_physicalmemory get devicelocator,manufacturer,partnumber,capacity | Findstr /r /v "^$"
echo ============ Disk ============
echo ============ Disk ============ >> %logdir%Preview.log
wmic diskdrive get deviceID,mediatype,model,size,status /format:csv | Findstr "PHYSICALDRIVE" > %logdir%pp.txt
type %logdir%pp.txt   >> %logdir%Preview.log
for /F "tokens=*" %%i In (%logdir%pp.txt) Do (
  set line=%%i
  call :checkDisk %line%
  set line=
)
echo ============ Partitions ===========
echo ============ Partitions =========== >> %logdir%Preview.log
echo list vol > %logdir%pp.txt
diskpart /s %logdir%pp.txt | findstr Volume > %logdir%pp2.txt
type %logdir%pp2.txt
for /F "tokens=*" %%a In (%logdir%pp2.txt) Do (
  set line=%%a
  call :checkPart %line%
)
EnumProductkey.exe | Findstr Active
echo ============ BIOS ===========
echo ============ BIOS ===========  >> %logdir%Preview.log
set valpw=Unknown
call :wmiget "path win32_computersystem get Manufacturer" 
set manufacturer=%val%
echo "%manufacturer%" | findstr /V /C:"HP" 1>nul
:: Apparently root\hp takes 90 secs to be ready
::echo on
if errorlevel 1 (
  wmic /namespace:\\root\hp\InstrumentedBIOS path HP_BIOSSetting where Name="Setup Password" Get /value  > NUL 2>&1
  if errorlevel 0 (
    wmic /namespace:\\root\hp\InstrumentedBIOS path HP_BIOSSetting where Name="Setup Password" Get /value | findstr IsSet > %logdir%pp.txt
    call :biospasswd %logdir%pp.txt 
  ) 
)
echo "%manufacturer%" | findstr /V /I /C:"DELL" 1>nul
if errorlevel 1 (
  wmic /namespace:\\root\dcim\sysman\wmisecurity path PasswordObject Get /value > NUL 2>&1
  if errorlevel 0 (
    wmic /namespace:\\root\dcim\sysman\wmisecurity path PasswordObject Get /value | findstr IsPasswordSet > %logdir%pp.txt    
call :biospasswd %logdir%pp.txt 
  )
)
echo "%manufacturer%" | findstr /V /I /C:"Lenovo" 1>nul
if errorlevel 1 (
  wmic /namespace:\\root\wmi path lenovo_biosPasswordSettings get /value > NUL 2>&1
  if errorlevel 0 (
    wmic /namespace:\\root\wmi path lenovo_biosPasswordSettings get /value | findstr PasswordState > %logdir%pp.txt   
    call :biospasswd %logdir%pp.txt 
  )
)
wmic /namespace:\\root\CIMV2\Security\MicrosoftTpm path Win32_Tpm get IsEnabled_InitialValue,SpecVersion | Findstr /r /v "^$" > %logdir%pp.txt
type %logdir%pp.txt >> %logdir%Preview.log 
for /f "tokens=1* delims= " %%i in (%logdir%pp.txt) DO (
  SET Enabled=%%i
  set Version=%%j
)
if "%Enabled%"=="" set Enabled=No 
if "%Version%"=="" set Version2=N/A
if "%firmware_type%"=="UEFI" ( 
  echo Boot mode: %firmware_type%   TPM Enabled: %Enabled% Version: %Version% Bios locked: %valpw%
) else (
  echo Boot mode: %firmware_type%   TPM Status not available Bios locked: %valpw%
)
echo ============ Processor ============  >> %logdir%Preview.log
wmic path win32_processor get Manufacturer,Name | Findstr /r /v "^$"  > %logdir%pp.txt
type %logdir%pp.txt >> %logdir%Preview.log 
for /f "tokens=1* delims= " %%i in (%logdir%pp.txt) DO (
  set Ven=%%i
  set Name=%%j
)
wmic path win32_processor get NumberOfEnabledCore,NumberOfLogicalProcessors | Findstr /r /v "^$"  > %logdir%pp.txt
type %logdir%pp.txt >> %logdir%Preview.log 
for /f "tokens=1-2 delims= " %%i in (%logdir%pp.txt) DO (
  set Cores=%%i
  set logicalcores=%%j
)
echo %Name% Enabled Cores %Cores% Logical Cores %logicalcores%
CPUid.exe
CPUid.exe -v >>  %logdir%Preview.log
pause
exit 

:: ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
:biospasswd
echo biospasswd %~1 >> %logdir%Preview.log 
type %~1  >> %logdir%Preview.log
set valpw=Unknown
for /F "tokens=2 USEBACKQ  delims==" %%i In (%~1) Do set password=%%i
if %password%==0 ( set valpw=No )
if %password%==1 ( set valpw=Yes )
:: echo Bios password %password% is %valpw%
exit /b

:: ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
:wmiget
wmic %~1 > %logdir%pp.txt
type %logdir%pp.txt  >> %logdir%Preview.log
:: Convert to UTF8
type %logdir%pp.txt >> %logdir%pp2.txt
for /F "tokens=* USEBACKQ  delims=<\n>" %%i In (%logdir%pp2.txt) Do set val=%%i
exit /b %val%

:: ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
:checkDisk 
rem echo %line%
set line2=%line:"=%
if "%line2%"=="" ( exit /b )
for /f "tokens=1-6 delims=," %%i in ("%line2%") DO (
  SET node=%%i
  SET Device=%%j
  set type=%%k
  set model=%%l
  set size=%%m
  set status=%%n
)
echo Drive %Device% %type% %model% size: %size% SMART Status %status%
diskread %Device% 0
exit /b

:: ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
:checkPart 
set vol=%line:~7,1%
set ltr=%line:~13,1%
set type=%line:~37,4%
echo Volume %vol% letter %ltr% type %type% >> %logdir%Preview.log
if "%type%"=="Part" if "%ltr%"==" " (
    echo Found unassigned drive letter for partition on volume %vol%
    echo select volume %vol% > %logdir%pp.txt
    echo assign >> %logdir%pp.txt
    echo list vol >> %logdir%pp.txt
    diskpart /s %logdir%pp.txt >> %logdir%Preview.log
) else (
  echo drive letter AOK %ltr%  %vol% >> %logdir%Preview.log
)
if "%type%"=="Part" call :enumpart %ltr%: \Windows\System32\config\SOFTWARE
exit /b

:: ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
:enumpart
wmic /namespace:\\root\CIMV2\Security\MicrosoftVolumeEncryption path Win32_EncryptableVolume get DriveLetter,EncryptionMethod,ProtectionStatus /format:csv 2>NUL | findstr %~1  > %logdir%pp.txt
type %logdir%pp.txt >> %logdir%Preview.log 
for /f "tokens=3,4 delims=," %%i in (%logdir%pp.txt) DO (
  SET Method=%%i
  set Status=%%j
)
if "%Status%"=="" (
  echo "Bitlocker test failed on %~1" >> %logdir%Preview.log
  goto nexte
)
if %Status% NEQ 0 ( 
  echo  Drive Letter %~1 is encrypted with bitlocker 
  exit /b
)
:nexte
if EXIST %~1%~2 (
  reg load HKLM\temp %~1%~2 >> %logdir%Preview.log  2> NUL
  if errorlevel 1 ( echo reg load not OK on %~1%~2 >> %logdir%Preview.log )
  reg query "HKLM\%regtree%\Microsoft\Windows NT\CurrentVersion" /v ProductName | findstr ProductName > %logdir%pp.txt
  type %logdir%pp.txt >> %logdir%Preview.log
  for /f "tokens=2* delims= " %%i in (%logdir%pp.txt) DO SET prod=%%j
  echo Drive Letter %~1 
  echo Installed Product: !prod!
  if EXIST %~1\temp\image.txt (
    echo   | set /p dummyName="Imaged with: "
    type %~1\temp\image.txt	
  )
  echo reg query "HKLM\%regtree%\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform"^
   /v BackupProductKeyDefault >> %logdir%Preview.log
  reg query "HKLM\%regtree%\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform"^
   /v BackupProductKeyDefault | findstr BackupProductKeyDefault > %logdir%pp.txt
  if errorlevel 1 (
    echo No such Key BackupProductKeyDefault >> %logdir%Preview.log
    set defaultkey=None
    type %logdir%pp.txt >> %logdir%Preview.log
  )
  type %logdir%pp.txt >> %logdir%Preview.log
  for /f "tokens=2* delims= " %%i in (%logdir%pp.txt) DO SET defaultkey=%%j
  if !defaultkey!==NF6HC-QH89W-F8WYV-WWXV4-WFG6P set desc=OEM 3.0 Generic Windows 10 Pro
  if !defaultkey!==37GNV-YCQVD-38XP9-T848R-FC2HD set desc=OEM 3.0 Generic Windows 10 Home
  if !defaultkey!==VK7JG-NPHTM-C97JM-9MPGT-3V66T set desc=Retail Windows 10 Pro
  if !defaultkey!==YTMG3-N6DKC-DKB77-7M9GH-8HVX7 set desc=Retail Windows 10 Home
  if !defaultkey!==RHGJR-N7FVY-Q3B8F-KBQ6V-46YP4 set desc=Generic Windows 10 Pro
  if !defaultkey!==46J3N-RY6B3-BJFDY-VBFT9-V22HG set desc=Generic Windows 10 Home
  echo Default Key:    !defaultkey!  !desc!
  REM reg unload HKLM\temp  > NUL 2>&1
) else (
  echo %~1 Not a Windows System Disk >> %logdir%Preview.log
)
exit /b
