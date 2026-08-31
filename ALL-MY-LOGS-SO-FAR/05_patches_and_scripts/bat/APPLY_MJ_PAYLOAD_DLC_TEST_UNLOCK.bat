@echo off
setlocal
title Apply CK2 MJ Payload DLC Test Unlock

if "%~1"=="" (
  echo.
  echo Drag the game's extensionless gfx\monarchs payload onto this BAT file.
  echo This only removes MJ payload DLC declarations. It does not install DLC.
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

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT%" Apply "%~f1"
if errorlevel 1 (
  echo.
  echo UNLOCK FAILED. An unknown payload is never modified.
  pause
  exit /b 1
)

echo.
echo Test these four rulers: Mordechai, Louise, Shajar, and Arwa.
echo Keep CK2 offline and launch the V9 CK2game.exe directly.
echo.
pause
endlocal
