Option Explicit

Dim shell
Dim fso
Dim scriptDir
Dim ps1
Dim command

Set shell = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")

scriptDir = fso.GetParentFolderName(WScript.ScriptFullName)
ps1 = fso.BuildPath(scriptDir, "tools\install_debuffer_gui.ps1")
command = "powershell.exe -NoProfile -ExecutionPolicy Bypass -STA -WindowStyle Hidden -File " & Chr(34) & ps1 & Chr(34)

shell.Run command, 0, False
