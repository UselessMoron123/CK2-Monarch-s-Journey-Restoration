@echo off
setlocal
title Revert CK2 Monarch's Journey V6 to V5
if "%~1"=="" (
  echo Drag the V6 CK2game.exe onto this BAT file to restore the exact V5 state.
  pause
  exit /b 1
)
if not exist "%~dp0patch_ck2_mj_v6.ps1" (
  echo ERROR: patch_ck2_mj_v6.ps1 is not beside this BAT file.
  pause
  exit /b 1
)
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0patch_ck2_mj_v6.ps1" Revert "%~1"
if errorlevel 1 (
  echo REVERT FAILED. Stop and send a screenshot.
  pause
  exit /b 1
)
echo.
echo Restored exact V5 SHA-256:
echo 29556549fb5fc657f2966949b6a5b59c9b89b707f954adca4868cfd3d90b1535
pause
endlocal
