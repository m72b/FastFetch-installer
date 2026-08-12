@echo off
setlocal
title Fastfetch Installer

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0fastfetch_setup.ps1"
set "exitCode=%ERRORLEVEL%"
endlocal & exit /b %exitCode%
