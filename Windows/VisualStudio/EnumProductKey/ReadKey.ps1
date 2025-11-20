
Write-Host "OEM Key from ACPI:"(Get-WmiObject -Query "select * from softwareLicensingService").OA3xOriginalProductKey
$Edition = (Get-WmiObject -Query "select * from softwareLicensingService").OA3xOriginalProductKeyDescription
$Edition = $Edition -replace "\[.*\] ", "" -replace " .*:.*", "" -replace "Core", "Home"
Write-Host "Edition:" $Edition

Write-Host "Key from Registry:" (Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform" -Name BackupProductKeyDefault)
Write-Host "Edition:" (Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name EditionID)

Write-Host "Activation Key:   XXXXX-XXXXX-XXXXX-XXXXX-"(Get-WmiObject -Query "select * from softwareLicensingProduct where PartialProductKey <> null").PartialProductKey
Write-Host "Edition:" (Get-WmiObject -Query "select * from softwareLicensingProduct where PartialProductKey <> null").LicenseFamily
