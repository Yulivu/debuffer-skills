@echo off
setlocal
set "SCRIPT_DIR=%~dp0"
start "" powershell.exe -NoProfile -ExecutionPolicy Bypass -STA -WindowStyle Hidden -File "%SCRIPT_DIR%tools\install_debuffer_gui.ps1"
exit /b 0
