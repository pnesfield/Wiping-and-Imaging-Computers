# Create directory of drivers missing in winre boot image
# Version 1.0 25/7/22
# 17/8/22 Only copy signed drivers
$win10Inf =  "C:\Windows\INF\*.inf"
$win10Drivers = "C:\Windows\System32\DriverStore\FileRepository\"
$winreInfDir = "temp\Windows\INF" 
$drivers = "Drivers"
$files = Get-ChildItem $win10Inf
$numb = 0
$numb_new = 0
foreach ($f in $files){
    $outfile = $f.FullName
    foreach($line in Get-Content $f.FullName) {
      if($line -match "Class .*= Net$"){
        $winreInf = Split-Path $outfile -Leaf
        $winreInfFile = $winreInfDir + "\" + $winreInf
        if (-not (Test-Path $winreInfFile -PathType Leaf)) {
          $numb = $numb +1
          $winDriverName = (Get-Item $outfile ).Basename
          Write-Output("$numb $winDriverName  New Driver")
          # Copy-Item $f.FullName -Destination $drivers
          $driverDirs = $win10Drivers + $winDriverName + "*"
          if (-not (Test-Path $driverDirs -PathType Container)) {
            Write-Output("Error Cannot Find $driverDirs")dir dir 
            }
          else {
            $fullPath = Resolve-Path $driverDirs
            # Write-Output("Full path $fullPath")
            # Search for the dir with signed drivers
            foreach($driverDir in $fullPath) {
              $driverFiles = Get-ChildItem $driverDir  
              if (Test-Path -Path $driverDir\*.cat -PathType Leaf) {
                $numb_new = $numb_new + 1
                Write-Output("dir          $driverDir")
                foreach ($d in $driverFiles) {
                  Write-Output("Driver Files $d")
                  Copy-Item $d.FullName -Destination $drivers
                }
              }
              else {
                Write-Output("Not this one $driverDir")
              }
            }
            # break
          }
        }
      }
    }
    # if ($numb -gt 2) {Break}
}
Write-Output("Found $numb_new")
     
