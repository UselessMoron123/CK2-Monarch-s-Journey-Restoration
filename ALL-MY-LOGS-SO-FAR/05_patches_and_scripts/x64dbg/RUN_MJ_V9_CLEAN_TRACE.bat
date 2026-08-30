@echo off
setlocal EnableExtensions DisableDelayedExpansion
title CK2 MJ V9 clean feat trace

rem This helper is diagnostic only. It does not patch CK2game.exe on disk.
rem Optional arguments:
rem   RUN_MJ_V9_CLEAN_TRACE.bat "C:\path\to\CK2game.exe" "C:\path\to\x64dbg.exe"

set "GAME_EXE=C:\Users\UZWERG\Desktop\SteamCrusader\CK2game.exe"
set "X64DBG=C:\Users\UZWERG\Desktop\x64 dbg\release\x64\x64dbg.exe"
if not "%~1"=="" set "GAME_EXE=%~1"
if not "%~2"=="" set "X64DBG=%~2"
set "TRACE_SCRIPT=%~dp0MJ_V9_CLEAN_TRACE.txt"
set "EXPECTED_V9=61e4345ba1395f09d26f84bf030ae0474fce3f0635a3516edea56b46c486d687"

if not exist "%GAME_EXE%" (
  echo ERROR: CK2 executable not found:
  echo   %GAME_EXE%
  echo Edit GAME_EXE at the top of this BAT or pass the path as argument 1.
  pause
  exit /b 2
)
if not exist "%X64DBG%" (
  echo ERROR: x64dbg.exe not found:
  echo   %X64DBG%
  echo Edit X64DBG at the top of this BAT or pass the path as argument 2.
  pause
  exit /b 2
)
if not exist "%TRACE_SCRIPT%" (
  echo ERROR: trace script not found beside this BAT:
  echo   %TRACE_SCRIPT%
  pause
  exit /b 2
)

echo Checking the executable identity. Nothing will be changed.
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "$h=(Get-FileHash -LiteralPath $env:GAME_EXE -Algorithm SHA256).Hash.ToLowerInvariant(); Write-Host ('SHA-256: '+$h); if($h -ne $env:EXPECTED_V9){Write-Host 'ERROR: this is not the confirmed V9 executable. Refusing to attach.' -ForegroundColor Red; exit 3}; Write-Host 'V9 identity: confirmed.' -ForegroundColor Green"
if errorlevel 1 (
  echo.
  echo The clean trace requires the confirmed V9 hash and did not attach.
  pause
  exit /b 3
)

echo.
echo Close any existing x64dbg window before continuing.
echo CK2game.exe must already be running normally at its main menu.
echo.
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "$target=[IO.Path]::GetFullPath($env:GAME_EXE); $rows=@(Get-CimInstance Win32_Process | Where-Object { $_.Name -ieq 'CK2game.exe' -and $_.ExecutablePath -and ([IO.Path]::GetFullPath($_.ExecutablePath) -ieq $target) }); if($rows.Count -eq 0){Write-Host 'ERROR: exact CK2 process is not running.' -ForegroundColor Red; exit 4}; if($rows.Count -gt 1){Write-Host 'ERROR: more than one matching CK2 process is running.' -ForegroundColor Red; exit 5}; Write-Host ('Attaching x64dbg to PID '+$rows[0].ProcessId); Start-Process -FilePath $env:X64DBG -ArgumentList @('-p',[string]$rows[0].ProcessId)"
if errorlevel 1 (
  echo.
  echo Start CK2 normally, wait for the main menu, and run this BAT again.
  pause
  exit /b 4
)

rem Put the exact script command in the clipboard to avoid typing a long path.
echo scriptexec "%TRACE_SCRIPT%"| clip.exe

echo.
echo x64dbg was started in ATTACH mode.
echo The next command is already in the clipboard.
echo.
echo In x64dbg, click the bottom Command box, press Ctrl+V, and press Enter once:
echo   scriptexec "%TRACE_SCRIPT%"
echo.
echo If x64dbg stops before the command runs, press F9 once, then run the command.
echo Do not use F7, F8, or Trace mode.
echo.
pause
endlocal
