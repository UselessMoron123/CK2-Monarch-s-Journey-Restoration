@echo off
setlocal
title Revert CK2 MJ Payload DLC Test Unlock

if "%~1"=="" (
  echo.
  echo Drag the game's extensionless gfx\monarchs payload onto this BAT file.
  echo.
  pause
  exit /b 1
)

set "SCRIPT=%~dp0..\ps1\toggle_ck2_mj_payload_dlc_unlock.ps1"
if not exist "%SCRIPT%" (
  echo ERROR: Could not find "%SCRIPT%"
  pause
  exit /b 1
)

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT%" Revert "%~f1"
if errorlevel 1 (
  echo.
  echo REVERT FAILED. An unknown payload is never modified.
  pause
  exit /b 1
)

echo.
echo Exact canonical payload restored and verified.
echo.
pause
endlocal
