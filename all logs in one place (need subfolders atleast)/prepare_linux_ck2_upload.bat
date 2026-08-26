@echo off
setlocal EnableExtensions
title Prepare Linux CK2 executable for text-only upload

if "%~1"=="" (
    echo.
    echo Drag the Linux file named ck2 from the downloaded Linux depot
    echo onto this BAT file, then release it.
    echo.
    echo Nothing will be changed in the CK2 depot.
    pause
    exit /b 1
)

set "CK2_INPUT=%~f1"
set "CK2_OUTPUT=%~dp0ck2_linux_upload_chunks"

if not exist "%CK2_INPUT%" (
    echo ERROR: Input file not found:
    echo %CK2_INPUT%
    pause
    exit /b 1
)

if not exist "%CK2_OUTPUT%" mkdir "%CK2_OUTPUT%"
del /q "%CK2_OUTPUT%\ck2_may333_linux.base64.part*.txt" 2>nul
del /q "%CK2_OUTPUT%\ck2_may333_linux.manifest.txt" 2>nul

echo Reading and encoding:
echo %CK2_INPUT%
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ^
  "$ErrorActionPreference='Stop';" ^
  "$p=$env:CK2_INPUT; $out=$env:CK2_OUTPUT;" ^
  "$bytes=[IO.File]::ReadAllBytes($p);" ^
  "$b64=[Convert]::ToBase64String($bytes);" ^
  "$chunkSize=8MB; $count=[Math]::Ceiling($b64.Length/[double]$chunkSize);" ^
  "for($i=0;$i -lt $count;$i++){ $start=$i*$chunkSize; $length=[Math]::Min($chunkSize,$b64.Length-$start); $name=('ck2_may333_linux.base64.part{0:D3}.txt' -f ($i+1)); [IO.File]::WriteAllText((Join-Path $out $name),$b64.Substring($start,$length),[Text.Encoding]::ASCII) };" ^
  "$hash=(Get-FileHash -LiteralPath $p -Algorithm SHA256).Hash;" ^
  "$manifest=@('Original file: '+[IO.Path]::GetFileName($p),'Original size: '+$bytes.Length+' bytes','SHA256: '+$hash,'Base64 characters: '+$b64.Length,'Parts: '+$count,'Part order: part001, part002, part003, and so on');" ^
  "[IO.File]::WriteAllLines((Join-Path $out 'ck2_may333_linux.manifest.txt'),$manifest,[Text.Encoding]::ASCII);" ^
  "Write-Host ('Created '+$count+' text parts.'); Write-Host ('SHA256: '+$hash);"

if errorlevel 1 (
    echo.
    echo Encoding failed. No CK2 files were modified.
    pause
    exit /b 1
)

echo.
echo Finished. Upload every TXT file from:
echo %CK2_OUTPUT%
echo.
explorer.exe "%CK2_OUTPUT%"
pause
