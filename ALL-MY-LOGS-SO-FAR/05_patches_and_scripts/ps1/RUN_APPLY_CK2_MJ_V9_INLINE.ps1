# RUN_APPLY_CK2_MJ_V9_INLINE.ps1 — reconstructed 2026-08-30.
#
# PROVENANCE: the V9 session (arena/01a0534b) told the user "I've also saved this same
# command to ALL-MY-LOGS-SO-FAR/05_patches_and_scripts/ps1/RUN_APPLY_CK2_MJ_V9_INLINE.ps1
# in the workspace, so it's not lost if you want to copy it from there later."
# No such file was ever written. It has been reconstructed VERBATIM from the chat text
# at `last log/last log (for now).txt` lines 6297-6353 (the two occurrences in that log,
# at 6206-6257 and 6297-6353, are identical apart from blank-line spacing).
#
# WHAT THIS IS: a single self-contained paste-into-PowerShell command. It exists because
# the .bat wrappers were still untrusted after the cmd.exe parenthesis bug
# (see 03_analysis/RAWLOG_NETNEW_EXTRACTS.md section 11.4). The user is non-technical,
# so this is the drag-free route: open PowerShell, paste, Enter.
#
# HOW TO USE IT (non-technical):
#   1. Close Crusader Kings II completely.
#   2. Press the Start button, type powershell, press Enter.
#   3. Copy EVERYTHING from the "function Invoke-MJV9 {" line down to the
#      "Invoke-MJV9 '...'" line at the bottom, paste it into that window
#      (right-click pastes), and press Enter.
#   4. Wait for "RESULT: V9 PATCH APPLIED AND VERIFIED".
#
# SAFETY: accepts only V7 (57b18e43...) or V8 (94d6fb40...); refuses any other
# executable; makes a verified timestamped backup; pre-checks all three patch sites;
# verifies the in-memory hash before writing, the temp file after writing, and the
# final file after replacing. Never injects code; all edits are length-preserving.
#
# Companion files: patch_ck2_mj_v9.ps1 (full guarded patcher with Verify/Apply/Revert),
# APPLY_/CHECK_/REVERT_*V9*.bat, 04_test_guides_and_reports/CK2_MJ_V9_TEST_GUIDE.md.
#
# ---- verbatim chat text begins below this line ----

function Invoke-MJV9 {
    param([string]$Path)
    $ErrorActionPreference = 'Stop'
    $v7 = '57b18e4392d03f0a3a67bc2c8c8d643302a9c44a141d90000219051adc521571'
    $v8 = '94d6fb403b4541a53f846b348722ee81bc832b66ac853f6fd532f08e2e8b7e93'
    $v9 = '61e4345ba1395f09d26f84bf030ae0474fce3f0635a3516edea56b46c486d687'
    function Sha([string]$p) { (Get-FileHash -LiteralPath $p -Algorithm SHA256).Hash.ToLowerInvariant() }
    function ShaB([byte[]]$d) { $sha=[Security.Cryptography.SHA256]::Create(); try { (($sha.ComputeHash($d) | ForEach-Object { $_.ToString('x2') }) -join '') } finally { $sha.Dispose() } }

    if (-not (Test-Path -LiteralPath $Path)) { Write-Host "NOT FOUND: $Path" -ForegroundColor Red; return }
    $item = Get-Item -LiteralPath $Path
    if ($item.Length -ne 24753368) { Write-Host "WRONG SIZE: $($item.Length) bytes (expected 24753368). Is this the May-2020 3.3.3 game?" -ForegroundColor Red; return }
    $s = Sha $Path
    if ($s -eq $v9) { Write-Host 'Already V9. Nothing to do.' -ForegroundColor Green; return }
    if ($s -eq $v7) { $state = 'V7' } elseif ($s -eq $v8) { $state = 'V8' } else { Write-Host "UNKNOWN EXE: $s" -ForegroundColor Red; return }
    Write-Host "Current state: $state. Applying V9..."

    $bak = "$Path.before_v9_" + (Get-Date -Format 'yyyyMMdd_HHmmss') + '.bak'
    Copy-Item -LiteralPath $Path -Destination $bak
    if ((Sha $bak) -ne $s) { Write-Host 'BACKUP VERIFICATION FAILED' -ForegroundColor Red; return }
    Write-Host "Backup saved and verified: $bak"

    $d = [IO.File]::ReadAllBytes($Path)
    if ($state -eq 'V7') {
        if ($d[0x00666546] -ne 0x74 -or $d[0x00666547] -ne 0x0d) { Write-Host 'Pre-check failed at 0x00666546' -ForegroundColor Red; return }
        $d[0x00666546] = 0x90; $d[0x00666547] = 0x90
        if ($d[0x007b786b] -ne 0x75 -or $d[0x007b786c] -ne 0x05) { Write-Host 'Pre-check failed at 0x007b786b' -ForegroundColor Red; return }
        $d[0x007b786b] = 0xeb; $d[0x007b786c] = 0x05
        Write-Host 'V8 bypasses applied.'
    }
    if ($d[0x007b7906] -ne 0xe8 -or $d[0x007b7907] -ne 0x85 -or $d[0x007b7908] -ne 0x71 -or $d[0x007b7909] -ne 0x8f -or $d[0x007b790a] -ne 0xff) { Write-Host 'Pre-check failed at 0x007b7906 (V9 site)' -ForegroundColor Red; return }
    $d[0x007b7906] = 0xb0; $d[0x007b7907] = 0x01; $d[0x007b7908] = 0x90; $d[0x007b7909] = 0x90; $d[0x007b790a] = 0x90

    $msha = ShaB $d
    if ($msha -ne $v9) { Write-Host "INTERNAL HASH MISMATCH: $msha" -ForegroundColor Red; return }
    $tmp = "$Path.tmp"
    [IO.File]::WriteAllBytes($tmp, $d)
    if ((Sha $tmp) -ne $v9) { Write-Host 'TEMP FILE VERIFY FAILED' -ForegroundColor Red; Remove-Item -LiteralPath $tmp -Force; return }
    Copy-Item -LiteralPath $tmp -Destination $Path -Force
    Remove-Item -LiteralPath $tmp -Force
    if ((Sha $Path) -ne $v9) { Write-Host 'FINAL FILE VERIFY FAILED' -ForegroundColor Red; return }

    Write-Host ''
    Write-Host 'RESULT: V9 PATCH APPLIED AND VERIFIED' -ForegroundColor Green
    Write-Host "SHA-256: $v9"
    $gfx = Join-Path (Split-Path $Path -Parent) 'gfx\monarchs'
    if (Test-Path -LiteralPath $gfx) {
        $ph = Sha $gfx
        Write-Host "Payload SHA-256: $ph"
        if ($ph -eq 'fc6ec025b782c811636a0efb65a7b3f192f09fffd0ff6ca8051ef8bc6113db4e') { Write-Host 'PAYLOAD: CORRECT' -ForegroundColor Green } else { Write-Host 'PAYLOAD: WRONG CONTENT' -ForegroundColor Red }
    } else {
        Write-Host 'PAYLOAD: gfx\monarchs not found next to the exe' -ForegroundColor Yellow
    }
    Write-Host ''
    Write-Host 'Test now: quit CK2 completely, relaunch, Load/Continue, check feats.'
}
Invoke-MJV9 'C:\Users\UZWERG\Desktop\SteamCrusader\CK2game.exe'
