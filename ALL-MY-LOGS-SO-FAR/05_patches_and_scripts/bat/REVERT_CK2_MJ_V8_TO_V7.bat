@echo off
setlocal
title Revert CK2 Monarch's Journey V8 to V7
if "%~1"=="" (
  echo Drag the V8 CK2game.exe onto this BAT file to restore the exact V7 state.
  pause
  exit /b 1
)
if not exist "%~dp0patch_ck2_mj_v8.ps1" (
  echo ERROR: patch_ck2_mj_v8.ps1 is not beside this BAT file.
  pause
  exit /b 1
)
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0patch_ck2_mj_v8.ps1" Revert "%~1"
if errorlevel 1 (
  echo REVERT FAILED. Stop and send a screenshot.
  pause
  exit /b 1
)
echo.
echo Restored exact V7 SHA-256:
echo 57b18e4392d03f0a3a67bc2c8c8d643302a9c44a141d90000219051adc521571
pause
endlocal
