@echo off
setlocal
title Revert CK2 Monarch's Journey V9 to V8
if "%~1"=="" (
  echo Drag the V9 CK2game.exe onto this BAT file to restore the exact V8 state.
  pause
  exit /b 1
)
if not exist "%~dp0patch_ck2_mj_v9.ps1" (
  echo ERROR: patch_ck2_mj_v9.ps1 is not beside this BAT file.
  pause
  exit /b 1
)
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0patch_ck2_mj_v9.ps1" Revert "%~1"
if errorlevel 1 (
  echo REVERT FAILED. Stop and send a screenshot.
  pause
  exit /b 1
)
echo.
echo Restored exact V8 SHA-256:
echo 94d6fb403b4541a53f846b348722ee81bc832b66ac853f6fd532f08e2e8b7e93
pause
endlocal
