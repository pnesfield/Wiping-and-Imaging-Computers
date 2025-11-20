
' Read license from ACPI in Bios
Set objLocator = CreateObject("WbemScripting.SWbemLocator")
Set objService = objLocator.ConnectServer(".", "root\cimv2")
objService.Security_.ImpersonationLevel = 3
' wmic path softwareLicensingService get *
Set Result = objService.ExecQuery("SELECT * FROM softwareLicensingService")
For Each objItem in Result
    Wscript.Echo "OEM Key from ACPI: " & objItem.OA3xOriginalProductKey
    Wscript.Echo "Edition: " & MyReplace(MyReplace(MyReplace(objItem.OA3xOriginalProductKeyDescription, "\[.*\] ", ""), " .*:.*", ""), "Core", "Home")
Next

' Read License from Registry
Dim objShell,strValue
Set objShell = WScript.CreateObject("WScript.Shell")
WScript.Echo "Key from Registry: " & objShell.RegRead("HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform\BackupProductKeyDefault") 
WScript.Echo "Edition: " & objShell.RegRead("HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\EditionID") 


' wmic path softwareLicensingProduct where "PartialProductKey <> null" get *
Set Result = objService.ExecQuery("SELECT * FROM softwareLicensingProduct WHERE PartialProductKey <> null")
For Each objItem in Result
    Wscript.Echo "Activation Key:    XXXXX-XXXXX-XXXXX-XXXXX-" & objItem.PartialProductKey
    Wscript.Echo "Edition: " & objItem.LicenseFamily
    ls = objItem.LicenseStatus
    Select Case ls
    Case 0
      Wscript.Echo "License State: Not Activated"
    Case 1
      Wscript.Echo "License State: Activated"
    Case Else
      Wscript.Echo "License State: Unknown"
    End Select    
Next

'  WScript.echo  myReplace("1.2 miZZZ", "\d\.\d mi", "mi")
Public Function myReplace(expression, findPattern, replace)
  'reference to Microsoft VBScript Regular Expressions
  'Dim re As RegExp
  Set re = New RegExp  'Create the RegExp object
  re.Pattern = findPattern
  re.IgnoreCase = True
  re.Global = True
  myReplace = re.replace(expression, replace)
End Function
