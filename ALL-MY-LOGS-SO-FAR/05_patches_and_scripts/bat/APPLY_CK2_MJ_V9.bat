@echo off
setlocal
title Apply CK2 Monarch's Journey V9 Feat-Rehydration Fix

if "%~1"=="" (
  echo.
  echo Drag your current V8 (or V7) CK2game.exe onto this BAT file.
  echo Keep this BAT beside patch_ck2_mj_v9.ps1.
  echo.
  pause
  exit /b 1
)
if not exist "%~dp0patch_ck2_mj_v9.ps1" (
  echo ERROR: patch_ck2_mj_v9.ps1 is not beside this BAT file.
  pause
  exit /b 1
)

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0patch_ck2_mj_v9.ps1" Apply "%~1"
if errorlevel 1 (
  echo.
  echo PATCH FAILED. Nothing else will be changed.
  pause
  exit /b 1
)

echo.
if exist "%~dp1gfx\monarchs" (
  powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "$h=(Get-FileHash -LiteralPath '%~dp1gfx\monarchs' -Algorithm SHA256).Hash.ToLowerInvariant(); Write-Host ('Payload SHA-256: '+$h); if($h -eq 'fc6ec025b782c811636a0efb65a7b3f192f09fffd0ff6ca8051ef8bc6113db4e'){Write-Host 'PAYLOAD RESULT: CORRECT' -ForegroundColor Green}else{Write-Host 'PAYLOAD RESULT: WRONG CONTENT' -ForegroundColor Red; exit 1}"
) else (
  echo ERROR: Payload not found at "%~dp1gfx\monarchs"
  pause
  exit /b 1
)
if errorlevel 1 (
  echo.
  echo The executable was patched, but the existing payload failed its check.
  pause
  exit /b 1
)

echo.
echo ============================================================
echo V9 FEAT-REHYDRATION PATCH COMPLETE
echo Executable: %~f1
echo Expected V9 SHA-256:
echo 61e4345ba1395f09d26f84bf030ae0474fce3f0635a3516edea56b46c486d687
echo.
echo Test: quit completely, relaunch, Load/Continue, check feats.
echo ============================================================
pause
endlocal
