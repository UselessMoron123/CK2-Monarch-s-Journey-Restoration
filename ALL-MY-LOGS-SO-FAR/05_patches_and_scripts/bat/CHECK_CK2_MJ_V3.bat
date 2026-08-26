@echo off
setlocal
if "%~1"=="" (
  echo.
  echo Drag the CK2 executable you want to check onto this BAT file.
  echo Keep CHECK_CK2_MJ_V3.bat beside patch_ck2_mj_v3.ps1.
  echo This checker changes nothing.
  echo.
  pause
  exit /b 1
)
if not exist "%~dp0patch_ck2_mj_v3.ps1" (
  echo ERROR: patch_ck2_mj_v3.ps1 is not beside this BAT file.
  pause
  exit /b 1
)

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0patch_ck2_mj_v3.ps1" Verify "%~1"
if errorlevel 1 (
  echo.
  echo CHECK FAILED. The selected executable is not an accepted exact May build/state.
  pause
  exit /b 1
)

echo.
if exist "%~dp1gfx\monarchs" (
  powershell.exe -NoLogo -NoProfile -Command "$h=(Get-FileHash -LiteralPath '%~dp1gfx\monarchs' -Algorithm SHA256).Hash.ToLowerInvariant(); Write-Host ('Payload: %~dp1gfx\monarchs'); Write-Host ('Payload SHA-256: '+$h); if($h -eq 'fc6ec025b782c811636a0efb65a7b3f192f09fffd0ff6ca8051ef8bc6113db4e'){Write-Host 'PAYLOAD RESULT: CORRECT' -ForegroundColor Green}else{Write-Host 'PAYLOAD RESULT: WRONG CONTENT' -ForegroundColor Red; exit 1}"
) else (
  echo PAYLOAD RESULT: NOT FOUND at "%~dp1gfx\monarchs"
)
if errorlevel 1 (
  echo.
  echo CHECK FAILED because the payload content is wrong.
  pause
  exit /b 1
)

echo.
echo This checker changed nothing.
pause
endlocal
