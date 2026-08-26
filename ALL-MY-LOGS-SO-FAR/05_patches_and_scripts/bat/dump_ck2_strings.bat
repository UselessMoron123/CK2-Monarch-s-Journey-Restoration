@echo off
setlocal EnableExtensions
title CK2 executable string dumper

rem Put this BAT file in the same folder as strings64.exe (or strings.exe).
rem Then drag CK2game.exe onto this BAT file.
rem If CK2game.exe is beside this BAT, double-clicking also works.

set "BIN=%~1"
if not defined BIN set "BIN=%~dp0CK2game.exe"

set "STR=%~dp0strings64.exe"
if not exist "%STR%" set "STR=%~dp0strings.exe"

if not exist "%STR%" (
    echo ERROR: Could not find strings64.exe or strings.exe beside this BAT file.
    echo.
    echo Put the Sysinternals Strings executable and this BAT in the same folder.
    echo Then drag CK2game.exe onto this BAT file.
    echo.
    pause
    exit /b 2
)

if not exist "%BIN%" (
    echo ERROR: Could not find the input executable:
    echo "%BIN%"
    echo.
    echo Drag CK2game.exe onto this BAT file and try again.
    echo.
    pause
    exit /b 3
)

for %%F in ("%BIN%") do set "BASE=%%~nF"
set "OUT=%USERPROFILE%\Desktop\%BASE%_strings.txt"
set "ERR=%USERPROFILE%\Desktop\%BASE%_strings_errors.txt"
set "FILTERED=%USERPROFILE%\Desktop\%BASE%_monarchs_filtered.txt"

echo Strings tool: "%STR%"
echo Input file:  "%BIN%"
echo Full output: "%OUT%"
echo Error log:  "%ERR%"
echo.

"%STR%" -accepteula -n 5 "%BIN%" > "%OUT%" 2> "%ERR%"
set "RC=%ERRORLEVEL%"

if exist "%OUT%" (
    for %%F in ("%OUT%") do echo Full output size: %%~zF bytes
) else (
    echo Full output file was not created.
)
if exist "%ERR%" (
    for %%F in ("%ERR%") do echo Error log size: %%~zF bytes
)
echo Strings exit code: %RC%

if %RC% EQU 0 if exist "%OUT%" (
    findstr /i /c:"monarch" /c:"monarchs_journey" /c:"scheduled_rulers" /c:"can_see_highlighted_rulers" /c:"highlighted_ruler" /c:"featured_ruler" /c:"bronzeman" /c:"mainmenu_rtt" /c:"pdx_online" /c:"pops" /c:"paradox" "%OUT%" > "%FILTERED%"
    for %%F in ("%FILTERED%") do echo Filtered output size: %%~zF bytes
)

echo.
if not %RC% EQU 0 (
    echo The Strings command failed. Open this file to see why:
    echo "%ERR%"
) else (
    echo Finished. Please upload these files from your Desktop:
    echo "%FILTERED%"
    echo "%ERR%"
    echo.
    echo If the filtered file is empty, also upload:
    echo "%OUT%"
)
echo.
pause
endlocal
