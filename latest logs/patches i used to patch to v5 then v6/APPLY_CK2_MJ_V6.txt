@echo off
setlocal
title Apply CK2 Monarch's Journey V6 save-loading test

if "%~1"=="" (
  echo.
  echo Drag your current V5 CK2game.exe onto this BAT file.
  echo Keep this BAT beside patch_ck2_mj_v6.ps1.
  echo.
  pause
  exit /b 1
)
if not exist "%~dp0patch_ck2_mj_v6.ps1" (
  echo ERROR: patch_ck2_mj_v6.ps1 is not beside this BAT file.
  pause
  exit /b 1
)

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0patch_ck2_mj_v6.ps1" Apply "%~1"
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
echo V6 SAVE-LOADING TEST PATCH COMPLETE
echo Executable: %~f1
echo Expected V6 SHA-256:
echo f5b7dfd6e23b63f6353bb74f89493af0bd3db909e2d09961a543c773668530b0
echo.
echo Start this exact executable directly.
echo ============================================================
pause
endlocal
