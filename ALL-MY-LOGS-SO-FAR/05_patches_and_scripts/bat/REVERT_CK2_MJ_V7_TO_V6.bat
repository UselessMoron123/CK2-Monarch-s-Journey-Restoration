@echo off
setlocal
title Revert CK2 Monarch's Journey V7 to V6
if "%~1"=="" (
  echo Drag the V7 CK2game.exe onto this BAT file to restore the exact V6 state.
  pause
  exit /b 1
)
if not exist "%~dp0patch_ck2_mj_v7.ps1" (
  echo ERROR: patch_ck2_mj_v7.ps1 is not beside this BAT file.
  pause
  exit /b 1
)
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0patch_ck2_mj_v7.ps1" Revert "%~1"
if errorlevel 1 (
  echo REVERT FAILED. Stop and send a screenshot.
  pause
  exit /b 1
)
echo.
echo Restored exact V6 SHA-256:
echo f5b7dfd6e23b63f6353bb74f89493af0bd3db909e2d09961a543c773668530b0
pause
endlocal
