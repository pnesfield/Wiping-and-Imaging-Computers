# Deploy install.wim to USBs
# Set-ExecutionPolicy -ExecutionPolicy Unrestricted
$debug = $false
Write-Output("Deploy_USB version 1.1")
if ($args.Count -lt 1 ) {
  Write-Output("Usage Deploy_USB tt|min")
  READ-HOST "Press enter to finish . . ."
  exit
}
$source_dir = "win10-x64-" + $args[0]
$source = $source_dir + "\install.wim"
$source_date = (Get-Item $source).LastWriteTime
Write-Output("From       $source updated on $source_date")
foreach($drive in (Get-PSDrive -PSProvider FileSystem).Root ) {
  $dir1 = $drive + "Images\win10-x64-" + $args[0]
  $dir2 = $drive + "Sources\win10-x64-" + $args[0]
  if ($debug) { write-Output("Looking for $dir2") }
  if (Test-Path -Path $dir1) {
    $target = $dir1 +"\install.wim"
    $target_date = (Get-Item $target).LastWriteTime
    Write-Output("To $target updated on $target_date")
    if ($source_date -lt $target_date) {
      Write-Output("install.wim is older")
    } else {
      Write-Output("Copy $source to $dir1")
      #Copy-Item $source -Destination $dir1 -Confirm
      start-process robocopy "$source_dir $dir1 install.wim" 
    }
  } 
  elseif (Test-Path -Path $dir2) {
    $target = $dir2 +"\install.wim"
    $target_date = (Get-Item $target).LastWriteTime
    Write-Output("To $target updated on $target_date")
    if ($source_date -lt $target_date) {
      Write-Output("install.wim is older")
    } else {
      Write-Output("Copy $source to $dir2")
      #Copy-Item $source -Destination $dir2 -Confirm
      start-process robocopy "$source_dir $dir2 install.wim" 
    }
  } 
}
READ-HOST "Press enter to finish . . ."