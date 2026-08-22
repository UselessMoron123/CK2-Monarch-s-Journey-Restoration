@echo off
setlocal EnableExtensions
title Prepare CK2 Monarch's Journey V5 executable for analysis

if "%~1"=="" (
  echo.
  echo Drag the exact CK2game.exe that you tested with V5 onto this BAT file.
  echo.
  echo This tool only reads the executable. It does not run, patch, move,
  echo rename, or otherwise change it.
  echo.
  pause
  exit /b 1
)

set "CK2_INPUT=%~f1"
set "CK2_OUTPUT=%~dp0CK2_MJ_V5_EXE_UPLOAD"
set "EXPECTED_SIZE=24753368"
set "EXPECTED_SHA=29556549fb5fc657f2966949b6a5b59c9b89b707f954adca4868cfd3d90b1535"

if not exist "%CK2_INPUT%" (
  echo ERROR: Input file not found:
  echo %CK2_INPUT%
  pause
  exit /b 1
)

if not exist "%CK2_OUTPUT%" mkdir "%CK2_OUTPUT%"
del /q "%CK2_OUTPUT%\CK2game_v5.base64.part*.txt" 2>nul
del /q "%CK2_OUTPUT%\CK2game_v5.manifest.txt" 2>nul

echo Checking and encoding this file:
echo %CK2_INPUT%
echo.

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -Command ^
  "$ErrorActionPreference='Stop';" ^
  "$p=$env:CK2_INPUT; $out=$env:CK2_OUTPUT;" ^
  "$expectedSize=[Int64]$env:EXPECTED_SIZE; $expectedSha=$env:EXPECTED_SHA.ToLowerInvariant();" ^
  "$item=Get-Item -LiteralPath $p; $hash=(Get-FileHash -LiteralPath $p -Algorithm SHA256).Hash.ToLowerInvariant();" ^
  "if($item.Length -ne $expectedSize){throw ('Wrong file size: '+$item.Length+'; expected '+$expectedSize+'. This is not the accepted May executable.')};" ^
  "if($hash -ne $expectedSha){throw ('Wrong SHA-256: '+$hash+'. Expected the V5 hash '+$expectedSha)};" ^
  "$bytes=[IO.File]::ReadAllBytes($p); $b64=[Convert]::ToBase64String($bytes);" ^
  "$chunkSize=8MB; $count=[Math]::Ceiling($b64.Length/[double]$chunkSize);" ^
  "for($i=0;$i -lt $count;$i++){ $start=$i*$chunkSize; $length=[Math]::Min($chunkSize,$b64.Length-$start); $name=('CK2game_v5.base64.part{0:D3}.txt' -f ($i+1)); [IO.File]::WriteAllText((Join-Path $out $name),$b64.Substring($start,$length),[Text.Encoding]::ASCII) };" ^
  "$manifest=@('Original path: '+$p,'Original size: '+$bytes.Length+' bytes','SHA-256: '+$hash,'Expected state: CK2 3.3.3 Monarchs Journey V5','Base64 characters: '+$b64.Length,'Parts: '+$count,'Part order: part001, part002, part003, and so on');" ^
  "[IO.File]::WriteAllLines((Join-Path $out 'CK2game_v5.manifest.txt'),$manifest,[Text.Encoding]::ASCII);" ^
  "Write-Host ('Verified V5 executable. SHA-256: '+$hash) -ForegroundColor Green; Write-Host ('Created '+$count+' text parts.');"

if errorlevel 1 (
  echo.
  echo PREPARATION FAILED. Nothing was changed.
  pause
  exit /b 1
)

echo.
echo ============================================================
echo PREPARATION COMPLETE
echo Upload the manifest and every numbered TXT part from:
echo %CK2_OUTPUT%
echo ============================================================
explorer.exe "%CK2_OUTPUT%"
pause
endlocal
