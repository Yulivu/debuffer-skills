@echo off
setlocal
set "SCRIPT_DIR=%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -STA -File "%SCRIPT_DIR%tools\install_debuffer_gui.ps1"
if errorlevel 1 pause
