# Post Install Script
# April 2022 philn
# 21/04/22 added licencewhere slmgr
# 12/5/22 removed /c assoc
# 1/6/22 Self destruct on Desktop
# 2/6/22 Put windowsdefenderlast. Messes up focus
# 28/6/22 Added Windows_Info
# 30/6/22 catch 404 error for asset number
# 1/7/22 handle multiple lines in ser file
# 7/7/22 Start Rachel at index page
# 14/7/22 Correct install Date
# 22/7/22 Fixed asset is an array fault
# 13/10/22 Trim $serial for ASUS Notebook
# 08/12/22 Add pnputil
# 18/3/23 Check asset number for 4 or  more characters
# 21/3/23 Move delete to end of process
# 1/5/23 Added Computer Rename
$debug = $false
$Host.UI.RawUI.WindowTitle = "Asset Info / Test Script"
#$Host.UI.RawUI.MaxWindowSize 
Write-Output ""
Write-Output "Windows 10 Asset Info and Installation Check v2.3"
Write-Output ""
if ($debug){ Write-Output "home $ENV:HOMEDRIVE\$ENV:HOMEPATH" }
Set-Location -Path $ENV:HOMEDRIVE\$ENV:HOMEPATH

$serial = (Get-CIMInstance win32_bios).SerialNumber.Trim()
Write-Output "Looking up asset number for system Serial Number $serial"
try {
$asset = (C:\Windows\System32\cmd /c curl -s -output asset.txt http://redserver/sources/Assets/Serial/$serial.ser)
} catch {
  Write-Output "Error: cannot contact http://192.168.0.1 or server not responding"
  Read-Host "Press Enter to Exit"
  exit
}
if ($debug){ Write-Output "Raw Asset $asset" }
if ($debug){ Write-Output ("Length:"+ $asset.Length) }
if ($asset -like "Alert*") {
  Write-Output "Error:"
  Write-Output ($asset -join "`n")
  $asset1 = ""
}
elseif ($asset -like "<html>*") {
  Write-Output "Error: $serial.ser Not Found"
  $asset1 = ""
}
elseif ($asset -is [array]) {
  if ($debug){ Write-Output ("its an array ") }
  $asset1 = $asset[0]
  $asset1 = $asset1.Trim()
  For ($i = 1; $i -lt $asset.Length; $i++) {
    if ($asset1 -eq '') {
      $asset1 = $asset[$i].Trim()
    }
    elseif ($asset1 -ne $asset[$i].Trim() -and $asset[$i] -ne '') {
      Write-Output ("Error: Ambiguous Asset Numbers " + $asset1 + ":" + $asset[$i])
      $asset1 = $asset[$i].Trim()
      # Guessing that last asset number in the file is the right one. First was a mistake.
    }
  }
}
else {
  if ($debug){ Write-Output "its a string " + $asset1 }
  $asset1 = $asset.Substring(0, 8)
}

$ok = $false
do {
  $ans = Read-Host "Enter Asset ID: [$asset1]"
  if ($debug){ Write-Output "Asset $ans"}
  if ($ans -eq '') {
    $ans = $asset1
  }
  if ($ans -match '^\d+$') {
    if ($ans.Length -eq 8) {
      if ($debug){ Write-Output "Asset is good $ans"}
      $ok = $true
    }
    elseif ($ans.Length -lt 4) {
      Write-Output "Error: Asset ID  $ans must be 4 or more characters"
    }
    elseif ($ans.Length -lt 8) {
      $n = $ans.Length
      $zero = '00000000'
      $ans = -join($zero.Substring(0, 8 - $n),$ans)
      if ($debug){ Write-Output "Asset is good $ans"}
      $ok = $true
      
    }
  }
  else {
    Write-Output "Error: Asset ID  $ans must be numeric characters"
  }
} until ($ok -eq $true)
$ok = $false
$asset = $ans
$installDate = (Get-CIMInstance win32_OperatingSystem).LastBootupTime.ToString('yyyyMMddHHmmss') + '.000000+000'
$make = (Get-CIMInstance win32_computersystem).Manufacturer
$model = (Get-CIMInstance win32_computersystem).Model
$memory = (Get-WMIObject -class Win32_PhysicalMemory | Measure-Object -Property capacity -Sum).Sum 
$os = (Get-CIMInstance win32_OperatingSystem).Caption
$osVersion = (Get-CIMInstance win32_OperatingSystem).Version
$cpu = (Get-CIMInstance win32_processor).Name
$systemType = (Get-CIMInstance win32_systemenclosure).ChassisTypes

$disks = (Get-CIMInstance win32_logicaldisk).DeviceID
$content = '{ "assetid":"' + $asset + '","installDate":"' + $installDate + '","memoryTotal":"' +
  $memory + '","os":"' + $os + '","osVersion":"' + $osVersion + '","systemModel":"' + $model + '","systemManufacturer":"' + 
  $make + '","systemSerial":"' + $serial + '","systemType":"' + $systemType + '","status":"Imaged",' +
  '"cpuSockets":[{ "model":"' + $cpu + '"} ], '
$disks = (Get-CIMInstance win32_diskdrive)
$diskContent = '"diskInfo": ['
foreach( $disk in $disks)
{
  $model = $disk.Model
  $serial = $disk.SerialNumber
  $health = $disk.Status
  $size = $disk.Size
  $interface = $disk.InterfaceType
  $diskContent = $diskContent + ' { "vendor":"", "model":"' + $model + '", "serial":"' + $serial + '", "capacity":"' + $size +
    '", "health":"' + $health + '", "interface":"' + $interface + '"},'
}
$diskContent = $diskContent.Substring(0, $diskContent.Length -1) + ']}'
$content = $content + $diskContent
if ($debug){ Write-Output $content }
Out-File -FilePath $env:temp\post_data.json -Encoding ASCII -InputObject $content
Write-Output 'Posting data to server'
[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms') > $env:temp\txt
try {
  C:\Windows\System32\cmd /c 'curl -s -X POST http://192.168.0.1:8000/ws/record.html -# -d @%temp%\post_data.json > %temp%\post_data.log'
} catch {
  Write-Output "Caught Error" + $_.ErrorDetails
  [System.Windows.Forms.MessageBox]::Show('Error: ' + $_.ErrorDetails + '. `n Check Django is running', 'Error')
  Read-Host "Press Enter to Exit"
  exit
}
#Write-Output $env:temp\post_data.log
$ok = Get-Content $env:temp\post_data.log
if ($ok.Length -eq 0) {
  [System.Windows.Forms.MessageBox]::Show("Error null response from Server. `n Check Django is running", 'Error') 
  Read-Host "Press Enter to Exit"
  
  exit
}
elseif ($ok -eq "OK") {
   Write-Output $ok
}
else {
  Write-Output $ok
  [System.Windows.Forms.MessageBox]::Show("Error response from Server. " + $ok, 'Error') 
  Read-Host "Press Enter to Exit"  
  exit
}

#[System.Windows.Forms.MessageBox]::Show('Error Message','WARNING')
Write-Output "Sanitize the system"
#Clear-RecycleBin -Force
#Start-Process -Verb RunAs cmd.exe -Args '/c', 'assoc .ps1=txtfile'
#Remove-Item $env:temp\post_data.*

# Remove Xbox - needs admin rights
#Get-ProvisionedAppxPackage -Online | `Where-Object { $_.PackageName -match "xbox" } | `
#ForEach-Object { 
#  Remove-ProvisionedAppxPackage -Online -PackageName $_.PackageName 
#}

$computerName = "S" + $asset.TrimStart("0")
if ($env:ComputerName -ne $computername) {
  Write-Output("Change Computer Name from $env:ComputerName to $computername")
  $process = Start-Process powershell -Verb runAs -ArgumentList "Rename-Computer -NewName $computerName" -Wait -PassThru -WindowStyle Minimized
  if ($($process.ExitCode) -ne 0) {
    Write-Output("Error rename-computer returned error $($process.ExitCode)")
  }
}
Write-Output "Check Windows is Permanently Activated "
Start-Process -Wait "C:\Windows\System32\slmgr.vbs" /xpr

# 
$ret = pnputil /enum-devices /problem 
if ($ret -match "(?s)Problem") 
{
  Write-Output "Checking Divers has found a Problem"
  Write-Output " "
  Write-Output $ret
  READ-HOST "Press enter to continue . . ."
}
Write-Output "Check Security Dashboard is copasetic"
Start-Process  -WindowStyle "Maximized" WindowsDefender:
if ( test-path C:\users\user1\Desktop\Win_Info.ps1.lnk) {
  Write-Output "Script will auto delete on completion, to run it again goto \\RedServer\sources\Assets"
  Remove-Item C:\users\user1\Desktop\Win_Info.ps1.lnk  -Force
  Remove-Item C:\temp\Win_Info.ps1 -Force
}
exit



