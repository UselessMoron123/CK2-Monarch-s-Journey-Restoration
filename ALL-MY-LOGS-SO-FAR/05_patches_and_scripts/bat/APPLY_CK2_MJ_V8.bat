@echo off
setlocal
title Apply CK2 Monarch's Journey V8 Feat-Rehydration Fix

if "%~1"=="" (
  echo.
  echo Drag your current V7 (or V6/V5) CK2game.exe onto this BAT file.
  echo Keep this BAT beside patch_ck2_mj_v8.ps1.
  echo.
  pause
  exit /b 1
)
if not exist "%~dp0patch_ck2_mj_v8.ps1" (
  echo ERROR: patch_ck2_mj_v8.ps1 is not beside this BAT file.
  pause
  exit /b 1
)

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0patch_ck2_mj_v8.ps1" Apply "%~1"
if errorlevel 1 (
  echo.
  echo PATCH FAILED. Nothing else will be changed.
  pause
  exit /b 1
)

echo.
if exist "%~dp1gfx\monarchs" (
  powershell.exe -NoLogo -NoProfile -Command "$h=(Get-FileHash -LiteralPath '%~dp1gfx\monarchs' -Algorithm SHA256).Hash.ToLowerInvariant(); Write-Host ('Payload SHA-256: '+$h); if($h -eq 'fc6ec025b782c811636a0efb65a7b3f192f09fffd0ff6ca8051ef8bc6113db4e'){Write-Host 'PAYLOAD RESULT: CORRECT' -ForegroundColor Green}else{Write-Host 'PAYLOAD RESULT: WRONG CONTENT' -ForegroundColor Red; exit 1}"
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
echo V8 FEAT-REHYDRATION PATCH COMPLETE
echo Executable: %~f1
echo Expected V8 SHA-256:
echo 94d6fb403b4541a53f846b348722ee81bc832b66ac853f6fd532f08e2e8b7e93
echo.
echo Test: quit completely, relaunch, Load/Continue, check feats.
echo ============================================================
pause
endlocal
