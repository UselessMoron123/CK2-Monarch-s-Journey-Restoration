@echo off
setlocal
if "%~1"=="" (
  echo.
  echo Drag the patched CK2 executable onto this BAT file to restore the exact May 2020 original.
  echo Keep REVERT_CK2_MJ_V4.bat beside patch_ck2_mj_v4.ps1.
  echo.
  pause
  exit /b 1
)
if not exist "%~dp0patch_ck2_mj_v4.ps1" (
  echo ERROR: patch_ck2_mj_v4.ps1 is not beside this BAT file.
  pause
  exit /b 1
)

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0patch_ck2_mj_v4.ps1" Revert "%~1"
if errorlevel 1 (
  echo.
  echo REVERT FAILED. The selected file was not changed.
  pause
  exit /b 1
)

echo.
echo ============================================================
echo RESTORE COMPLETE
echo Exact original SHA-256:
echo 656f4f482ed698958e1108938f7e5baff5b5dd31b3b310a7ea51386faca635d8
echo The gfx\monarchs file is harmless and may be left in place.
echo ============================================================
pause
endlocal
