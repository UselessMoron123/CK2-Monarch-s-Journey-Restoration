@echo off
setlocal
if "%~1"=="" (
  echo.
  echo Drag the CK2 executable that you actually launch onto this BAT file.
  echo Do not double-click the BAT by itself.
  echo.
  pause
  exit /b 1
)
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0check_ck2_mj.ps1" -GameExe "%~1"
echo.
echo Take a screenshot of this whole window or copy its text back to the chat.
pause
endlocal
