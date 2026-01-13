# Create directory of drivers missing in winre boot image
# # Version 1.0 25/7/22
#$win10Inf =  "C:\Windows\INF\*.inf"
$win10Drivers = "C:\Windows\System32\DriverStore\FileRepository\"
$winreInfDir = "C:\users\user1\Desktop\temp\Windows\INF"
$drivers = "Drivers"
$files = Get-ChildItem $win10Inf
$numb = 0
foreach ($f in $files){
    $outfile = $f.FullName
    foreach($line in Get-Content $f.FullName) {
      if($line -match "Class .*= Net$"){
        $winreInf = Split-Path $outfile -Leaf
        $winreInfFile = $winreInfDir + "\" + $winreInf
        if (-not (Test-Path $winreInfFile -PathType Leaf)) {
          $numb = $numb +1
          $winDriverName = (Get-Item $outfile ).Basename
          Write-Output("$numb  $f.Name  $line $winDriverName  New Driver")
          Copy-Item $f.FullName -Destination $drivers
          $driverFiles = $win10Drivers + $winDriverName + "*"
          if (-not (Test-Path $driverFiles -PathType Container)) {
            Write-Output("Error Cannot Find $driverFiles")
            }
          else {
            $fullPath = Resolve-Path $driverFiles
            Write-Output("Full path $fullPath")
            $fullPath = Resolve-Path $driverFiles
            $driverFiles = Get-ChildItem $fullPath
            $cat = ""
            foreach ($d in $driverFiles) {
              Write-Output("Driver Files $d")
              Copy-Item $d.FullName -Destination $drivers
              }
            }
          }
        break 
      }
    }
    # if ($numb -gt 2) {Break}
}
     
