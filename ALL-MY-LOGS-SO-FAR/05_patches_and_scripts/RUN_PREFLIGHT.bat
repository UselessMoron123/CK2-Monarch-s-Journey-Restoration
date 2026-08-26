@echo off
setlocal
title CK2 Monarch's Journey - preflight check

rem ---------------------------------------------------------------------------
rem  Double-click this file. It is READ-ONLY: it does not patch, launch, or
rem  modify anything. It just reports what state the install is in.
rem
rem  Keep it in the same folder as ps1\preflight_ck2_mj.ps1, or beside
rem  preflight_ck2_mj.ps1 directly.
rem
rem  Optional: drag your CK2 game FOLDER onto this .bat to check a different
rem  install. Otherwise the default path below is used.
rem ---------------------------------------------------------------------------

set "DEFAULT_ROOT=C:\Users\UZWERG\Desktop\SteamCrusader"

rem Locate the PowerShell script: ps1\ subfolder first, then same folder.
set "PS1=%~dp0ps1\preflight_ck2_mj.ps1"
if not exist "%PS1%" set "PS1=%~dp0preflight_ck2_mj.ps1"

if not exist "%PS1%" (
  echo.
  echo ERROR: could not find preflight_ck2_mj.ps1
  echo Looked in:
  echo    %~dp0ps1\preflight_ck2_mj.ps1
  echo    %~dp0preflight_ck2_mj.ps1
  echo.
  echo Keep this .bat next to the ps1 folder ^(or next to the .ps1 itself^).
  echo.
  pause
  exit /b 1
)

rem A folder dragged onto the .bat overrides the default.
if "%~1"=="" (
  set "ROOT=%DEFAULT_ROOT%"
) else (
  set "ROOT=%~1"
)

echo.
echo ============================================================
echo  CK2 Monarch's Journey - preflight
echo  Game folder: %ROOT%
echo  This check is READ-ONLY. Nothing will be modified.
echo ============================================================
echo.

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%PS1%" -GameRoot "%ROOT%"

if errorlevel 1 (
  echo.
  echo The check reported an error above.
)

echo.
pause
endlocal
