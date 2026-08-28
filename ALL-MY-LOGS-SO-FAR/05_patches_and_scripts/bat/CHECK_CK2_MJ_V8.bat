@echo off
setlocal
title Check CK2 Monarch's Journey V8
if "%~1"=="" (
  echo Drag the CK2game.exe you want to check onto this BAT file.
  pause
  exit /b 1
)
if not exist "%~dp0patch_ck2_mj_v8.ps1" (
  echo ERROR: patch_ck2_mj_v8.ps1 is not beside this BAT file.
  pause
  exit /b 1
)
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0patch_ck2_mj_v8.ps1" Verify "%~1"
echo.
echo This checker changed nothing.
pause
endlocal
