# Get System Info for drivers
# April 2022 philn
$debug = $false
$Host.UI.RawUI.WindowTitle = "Get System Info"
#$Host.UI.RawUI.MaxWindowSize 
Write-Output ""
Write-Output "System Info for drivers"
Write-Output ""
$serial = (Get-CIMInstance win32_bios).SerialNumber.Trim()
Set-Clipboard -Value $serial
$installDate = (Get-CIMInstance win32_OperatingSystem).LastBootupTime.ToString('yyyyMMddHHmmss') + '.000000+000'
$make = (Get-CIMInstance win32_computersystem).Manufacturer
$model = (Get-CIMInstance win32_computersystem).Model
$memory = (Get-CIMInstance win32_computersystem).TotalPhysicalMemory
$os = (Get-CIMInstance win32_OperatingSystem).Caption
$osVersion = (Get-CIMInstance win32_OperatingSystem).Version
$cpu = (Get-CIMInstance win32_processor).Name
$systemType = (Get-CIMInstance win32_systemenclosure).ChassisTypes
Write-Output "Computer Make $make`t`tModel $model`t`tSerial Number $serial"
Write-Output ""
$disks = (Get-CIMInstance win32_logicaldisk).DeviceID
foreach( $disk in $disks)
{
  if (Test-Path -Path $disk\RACHEL) {
    $rachel = 'Yes'
  }
}
$disks = (Get-CIMInstance win32_diskdrive)
foreach( $disk in $disks)
{
  $model = $disk.Model
  $serial = $disk.SerialNumber
  $health = $disk.Status
  $size = $disk.Size
  $interface = $disk.InterfaceType
  $diskContent = "Disk $model `t`tserial $serial `t`tcapacity $size `t`thealth $health `t`tinterface $interface"
  
  Write-Output $diskContent
}
Write-Output ""
Write-Output ""
Write-Output ""
READ-HOST "Press enter to continue . . ."
