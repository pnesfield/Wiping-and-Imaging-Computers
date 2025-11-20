' List Disks 
On Error Resume Next
strComputer = "."

Set objWMIService = GetObject("winmgmts:\\.\root\cimv2")
Set colItems = objWMIService.ExecQuery("Select Name, Model, Size, Partitions, SerialNumber from Win32_DiskDrive")

For Each objItem in colItems
  name = objItem.Name 
  drive = Right(name, 1)
  model = RTrim(objItem.Model)
  if (Instr(model, "USB", 1) == 0) then
    ignore = ""
  else
    ignore = " Ignore"
  end if
  size = Int(objItem.Size /(1073741824)) & " GB"
  parts = objItem.Partitions
  serial = RTrim(objItem.SerialNumber)
  Wscript.Echo "Drive " & drive & " " & model & " " & serial & " " & size & ignore
Next
WSCript.Quit