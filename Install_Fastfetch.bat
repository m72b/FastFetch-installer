@echo off
setlocal
title Fastfetch Installer

:: The PowerShell script performs the administrator check and all install work.
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0fastfetch_setup.ps1"
set "exitCode=%ERRORLEVEL%"
endlocal & exit /b %exitCode%
