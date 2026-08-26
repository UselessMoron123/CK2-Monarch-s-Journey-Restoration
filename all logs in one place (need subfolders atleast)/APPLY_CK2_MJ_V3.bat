@echo off
setlocal
if "%~1"=="" (
  echo.
  echo Drag the May 2020 CK2 executable you want to patch onto this BAT file.
  echo Keep these three files together:
  echo   APPLY_CK2_MJ_V3.bat
  echo   patch_ck2_mj_v3.ps1
  echo   monarchs
  echo.
  pause
  exit /b 1
)
if not exist "%~dp0patch_ck2_mj_v3.ps1" (
  echo ERROR: patch_ck2_mj_v3.ps1 is not beside this BAT file.
  pause
  exit /b 1
)
if not exist "%~dp0monarchs" (
  echo ERROR: the extensionless payload file named monarchs is not beside this BAT file.
  pause
  exit /b 1
)

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0patch_ck2_mj_v3.ps1" Apply "%~1"
if errorlevel 1 (
  echo.
  echo PATCH FAILED. The patcher refused the file or could not finish.
  pause
  exit /b 1
)

if not exist "%~dp1gfx\" (
  echo ERROR: no gfx folder exists beside the executable. Payload was not copied.
  pause
  exit /b 1
)
copy /y "%~dp0monarchs" "%~dp1gfx\monarchs" >nul
if errorlevel 1 (
  echo ERROR: could not copy the payload to "%~dp1gfx\monarchs"
  pause
  exit /b 1
)

powershell.exe -NoLogo -NoProfile -Command "$h=(Get-FileHash -LiteralPath '%~dp1gfx\monarchs' -Algorithm SHA256).Hash.ToLowerInvariant(); Write-Host ('Payload SHA-256: '+$h); if($h -ne 'fc6ec025b782c811636a0efb65a7b3f192f09fffd0ff6ca8051ef8bc6113db4e'){exit 1}"
if errorlevel 1 (
  echo ERROR: copied payload failed SHA-256 verification.
  pause
  exit /b 1
)

echo.
echo ============================================================
echo V3 PATCH AND PAYLOAD INSTALLATION COMPLETE
echo Executable: %~f1
echo Payload:    %~dp1gfx\monarchs
echo Start this exact executable directly.
echo Expected EXE SHA-256:
echo e91a5f4693ca3b747d7340fda71ed66b3593e2f98af14c37e6086b0d76fb13ca
echo ============================================================
pause
endlocal
