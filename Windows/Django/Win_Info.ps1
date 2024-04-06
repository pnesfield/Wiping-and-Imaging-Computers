$debug = $false
$url = "S1809:8000"
$url = "RedDev1:8000"
$ProgressPreference = "SilentlyContinue"
$ok = $false
$asset = ""
$note = ""
$serial = (Get-CIMInstance win32_bios).SerialNumber.Trim()
Write-Output "Looking up asset number for system Serial Number $serial"
try {
    $response = Invoke-WebRequest -Uri "http://$url/ws/asset.html" -Method POST -Body $serial -ContentType "application/text"
} catch {
    Write-Host "Error Occured"
    Write-Host $_.ErrorDetails
}
if ($debug){ Write-Output $response }
if ($response.Length -eq $false) {
    [System.Windows.Forms.MessageBox]::Show("Error null response from Server. `n Check Django is running", 'Error') 
    Read-Host "Press Enter to Exit"
    exit
}
elseif ($Response.StatusCode -eq "200") {  
    $asset = $response.Content
}
else {
    Write-Output $response.Content
    [System.Windows.Forms.MessageBox]::Show("Error response from Server. " + $response.Content, 'Error') 
    Read-Host "Press Enter to Exit"
    exit
}
do {
  $ans = Read-Host "Enter Asset ID: [$asset]"
  if ($debug){ Write-Output "Asset $ans"}
  if ($ans -eq '') {
    $ans = $asset
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
$post = "Asset:" + $asset + "`n" + "State:Image`n" + "Serial:" + $serial +"`n"
$more = Get-ComputerInfo -Property CsManufacturer,CsModel,CsName,CsProcessors,CsPCSystemType,CsTotalPhysicalMemory,BiosManufacturer,`
  BiosName,OSName,OSVersion,OsInstallDate | Format-List | Out-String
$more = $more.trim()
$more = $more.Replace("CsManufacturer","Make").Replace("CsTotalPhysicalMemory","Memory").Replace("Cs","")
$post = $post + $more
$more = Get-WMIObject -class Win32_PhysicalMemory | Format-List -Property Manufacturer,PartNumber,Capacity,DeviceLocator | Out-String
$more = $more.Replace("Manufacturer", "MemMake").Replace("DeviceLocator","MemSlot").Replace("PartNumber","MemPartNumber").Replace("Capacity","MemSize")
$post = $post + $more
$more = Get-PhysicalDisk | Format-List -Property Model,SerialNumber,AllocatedSize,BusType,FirmwareVersion,MediaTyp,eHealthStatus  | Out-String
$more = $more.Replace("Model", "DiskModel").Replace("SerialNumber","DiskSerial").Replace("AllocatedSize","DiskCapacity").`
  Replace("BusType","DiskBusType").Replace("FirmwareVersion","DiskFirmwareVersion")
$post = $post + $more
$more = Get-WmiObject -class Win32_Battery | Format-List -Property Status | Out-String
if ($more.Contains("Status")) {
    $more = $more.Replace("Status", "BattStatus")
    }
else{
    $more = "BattStatus:Absent`n"
    }
$post = $post + $more
if ($debug){ Write-Host $post }
Write-Host "Posting"
try {
    $response = Invoke-WebRequest -Uri "http://$url/ws/log.html" -Method POST -Body $post -ContentType "application/text"
} catch {
    Write-Host "Error Occured"
}
if ($debug){ Write-Output $response }
if ($response.Length -eq $false) {
    [System.Windows.Forms.MessageBox]::Show("Error null response from Server. `n Check Django is running", 'Error') 
    Read-Host "Press Enter to Exit"
    exit
}
elseif ($Response.Content -eq "OK") {
    Write-Host $response.Content
}
else {
    Write-Output $response.Content
    [System.Windows.Forms.MessageBox]::Show("Error response from Server. " + $response.Content, 'Error') 
    Read-Host "Press Enter to Exit"
    exit
}
