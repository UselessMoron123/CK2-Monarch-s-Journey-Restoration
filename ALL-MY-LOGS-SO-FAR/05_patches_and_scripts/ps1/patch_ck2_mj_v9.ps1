# Guarded V9 Monarch's Journey patcher for Crusader Kings II 3.3.3 (May 2020).
#
# V9 fixes the remaining cold-launch feat bug: after a full quit -> relaunch ->
# Load/Continue, feats still showed 0 even with V8 applied, while the same load
# after an in-session resign rehydrated them fine.
#
# Root cause (found by disassembling the stock exe and by the V8 clean trace):
#   CalcShouldTrackFeatProgress() (raw 0x007b7850) is called at the top of
#   CRulerFeatTracker::UpdateFeatProgress (raw 0x007b8281). On a cold load every
#   earlier gate passes (ruler-info non-null, date not expired, game-mode bytes
#   set, singleton flags [+0x60]==0 and [+0x65]!=0), but the final call
#       raw 0x007b7906: call 0x1400af690
#   (the "all linked feature entries visible/available" eligibility check, which
#   walks the global feature list through 0x14072c6c0/0x14072d010 and ANDs each
#   entry's +0x58/+0x59 flag byte) returns 0 on a cold load because the feature
#   entries' availability flags are not populated yet at that moment. The warm
#   session has them set, so the same call returns 1.
#
# V9 patch (length-preserving, no injection):
#   raw 0x007b7906: e8 85 71 8f ff  (call 0x1400af690) -> b0 01 90 90 90
#                    (mov al,1; nop; nop; nop)
#   i.e. CalcShouldTrackFeatProgress() now reports "yes, track progress" at the
#   exact point the cold trace proved it was rejected. All V8 behavior is kept.
#
# Accepts V7 or V8 and produces the V9 executable. Length-preserving edits only.
#
# Usage:
#   powershell -ExecutionPolicy Bypass -File .\patch_ck2_mj_v9.ps1 Verify .\CK2game.exe
#   powershell -ExecutionPolicy Bypass -File .\patch_ck2_mj_v9.ps1 Apply  .\CK2game.exe
#   powershell -ExecutionPolicy Bypass -File .\patch_ck2_mj_v9.ps1 Revert .\CK2game.exe

param(
    [Parameter(Mandatory=$true, Position=0)]
    [ValidateSet('Verify','Apply','Revert')]
    [string]$Operation,

    [Parameter(Mandatory=$true, Position=1)]
    [string]$GameExe
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ExpectedSize = 24753368L
$V7Sha = '57b18e4392d03f0a3a67bc2c8c8d643302a9c44a141d90000219051adc521571'
$V8Sha = '94d6fb403b4541a53f846b348722ee81bc832b66ac853f6fd532f08e2e8b7e93'
$V9Sha = '61e4345ba1395f09d26f84bf030ae0474fce3f0635a3516edea56b46c486d687'

$V8Patches = @(
    [pscustomobject]@{ Name = 'always re-hydrate feats in the daily update (skip IsActiveForPlaythrough gate)'; Offset = 0x00666546L; V7 = [byte[]](0x74,0x0d); V8 = [byte[]](0x90,0x90) },
    [pscustomobject]@{ Name = 'always re-hydrate feats inside UpdateFeatProgress (skip IsActiveForPlaythrough gate)'; Offset = 0x007b786bL; V7 = [byte[]](0x75,0x05); V8 = [byte[]](0xeb,0x05) }
)

$V9Patches = @(
    [pscustomobject]@{ Name = 'force the final feature-eligibility gate inside CalcShouldTrackFeatProgress (feats rehydrate after cold load)'; Offset = 0x007b7906L; V8 = [byte[]](0xe8,0x85,0x71,0x8f,0xff); V9 = [byte[]](0xb0,0x01,0x90,0x90,0x90) }
)

function Get-Sha256([string]$Path) {
    return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()
}

function Get-BytesSha256([byte[]]$Data) {
    $sha = [Security.Cryptography.SHA256]::Create()
    try {
        $hash = $sha.ComputeHash($Data)
        return (($hash | ForEach-Object { $_.ToString('x2') }) -join '')
    }
    finally { $sha.Dispose() }
}

function Get-Hex([byte[]]$Bytes) {
    return (($Bytes | ForEach-Object { $_.ToString('x2') }) -join ' ')
}

function Test-Bytes([byte[]]$Data, [long]$Offset, [byte[]]$Expected) {
    if ($Offset -lt 0 -or ($Offset + $Expected.Length) -gt $Data.LongLength) { return $false }
    for ($i=0; $i -lt $Expected.Length; $i++) {
        if ($Data[$Offset + $i] -ne $Expected[$i]) { return $false }
    }
    return $true
}

function Set-Bytes([byte[]]$Data, [long]$Offset, [byte[]]$Value) {
    [Array]::Copy($Value, 0, $Data, $Offset, $Value.Length)
}

function Get-State([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "File not found: $Path"
    }
    $item = Get-Item -LiteralPath $Path
    if ($item.Length -ne $ExpectedSize) {
        throw "Wrong size: $($item.Length) bytes; expected $ExpectedSize. Refusing this file."
    }
    $sha = Get-Sha256 $Path
    if ($sha -eq $V7Sha) { return [pscustomobject]@{State='v7'; Sha256=$sha} }
    if ($sha -eq $V8Sha) { return [pscustomobject]@{State='v8'; Sha256=$sha} }
    if ($sha -eq $V9Sha) { return [pscustomobject]@{State='v9'; Sha256=$sha} }
    throw "Unknown executable SHA-256: $sha. Expected a V7, V8, or V9 file. Nothing was changed."
}

function Save-VerifiedBackup([string]$Path, [string]$ExpectedSha, [string]$Label) {
    $stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
    $backup = $Path + '.' + $Label + '_' + $stamp + '.bak'
    $counter = 1
    while (Test-Path -LiteralPath $backup) {
        $backup = $Path + '.' + $Label + '_' + $stamp + '_' + $counter + '.bak'
        $counter++
    }
    Copy-Item -LiteralPath $Path -Destination $backup
    $backupSha = Get-Sha256 $backup
    if ($backupSha -ne $ExpectedSha) {
        Remove-Item -LiteralPath $backup -Force -ErrorAction SilentlyContinue
        throw "Backup verification failed."
    }
    return $backup
}

function Write-VerifiedReplacement([string]$Path, [byte[]]$Data, [string]$ExpectedSha) {
    $temp = $Path + '.' + [Guid]::NewGuid().ToString('N') + '.tmp'
    try {
        [IO.File]::WriteAllBytes($temp, $Data)
        $tempSha = Get-Sha256 $temp
        if ($tempSha -ne $ExpectedSha) {
            throw "Temporary result failed SHA-256 verification: $tempSha"
        }
        Copy-Item -LiteralPath $temp -Destination $Path -Force
        $finalSha = Get-Sha256 $Path
        if ($finalSha -ne $ExpectedSha) {
            throw "Final file failed SHA-256 verification: $finalSha"
        }
    }
    finally {
        Remove-Item -LiteralPath $temp -Force -ErrorAction SilentlyContinue
    }
}

$GameExe = [IO.Path]::GetFullPath($GameExe)

try {
    switch ($Operation) {
        'Verify' {
            $result = Get-State $GameExe
            Write-Host "State: $($result.State)"
            Write-Host "Size: $((Get-Item -LiteralPath $GameExe).Length) bytes"
            Write-Host "SHA-256: $($result.Sha256)"
            switch ($result.State) {
                'v9' { Write-Host 'RESULT: CORRECT V9 FEAT-REHYDRATION PATCH' -ForegroundColor Green }
                'v8' { Write-Host 'RESULT: V8 BASELINE DETECTED; READY TO APPLY V9' -ForegroundColor Yellow }
                'v7' { Write-Host 'RESULT: V7 BASELINE DETECTED; READY TO APPLY V9' -ForegroundColor Yellow }
            }
        }

        'Apply' {
            $result = Get-State $GameExe
            if ($result.State -eq 'v9') {
                Write-Host "Already correctly patched to V9. SHA-256: $V9Sha" -ForegroundColor Green
                break
            }

            $backup = Save-VerifiedBackup $GameExe $result.Sha256 "before_mj_v9_from_$($result.State)"
            Write-Host "Saved and verified backup: $backup"

            $data = [IO.File]::ReadAllBytes($GameExe)

            if ($result.State -eq 'v7') {
                foreach ($patch in $V8Patches) {
                    if (-not (Test-Bytes $data $patch.Offset $patch.V7)) {
                        throw ("Pre-write byte check failed at 0x{0:x8}. Refusing to patch." -f $patch.Offset)
                    }
                    Set-Bytes $data $patch.Offset $patch.V8
                    Write-Host ("Set 0x{0:x8}: {1} -> {2} ({3})" -f `
                        $patch.Offset, (Get-Hex $patch.V7), (Get-Hex $patch.V8), $patch.Name)
                }
            }

            foreach ($patch in $V9Patches) {
                if (-not (Test-Bytes $data $patch.Offset $patch.V8)) {
                    throw ("Pre-write byte check failed at 0x{0:x8}. Refusing to patch." -f $patch.Offset)
                }
                Set-Bytes $data $patch.Offset $patch.V9
                Write-Host ("Set 0x{0:x8}: {1} -> {2} ({3})" -f `
                    $patch.Offset, (Get-Hex $patch.V8), (Get-Hex $patch.V9), $patch.Name)
            }

            $memorySha = Get-BytesSha256 $data
            if ($memorySha -ne $V9Sha) {
                throw "Internal V9 hash mismatch: $memorySha"
            }
            Write-VerifiedReplacement $GameExe $data $V9Sha
            $final = Get-State $GameExe
            if ($final.State -ne 'v9') { throw 'Final V9 classification failed.' }

            Write-Host 'RESULT: V9 FEAT-REHYDRATION PATCH APPLIED AND VERIFIED' -ForegroundColor Green
            Write-Host "SHA-256: $V9Sha"
            Write-Host 'Feats should now rehydrate after a cold launch -> Load/Continue.'
        }

        'Revert' {
            $result = Get-State $GameExe
            if ($result.State -ne 'v9') {
                Write-Host "Current state is $($result.State). Only V9 can be reverted by this script." -ForegroundColor Yellow
                break
            }
            $backup = Save-VerifiedBackup $GameExe $result.Sha256 'before_mj_v9_revert'
            Write-Host "Saved and verified backup: $backup"

            $data = [IO.File]::ReadAllBytes($GameExe)
            foreach ($patch in $V9Patches) {
                if (-not (Test-Bytes $data $patch.Offset $patch.V9)) {
                    throw ("Pre-revert byte check failed at 0x{0:x8}." -f $patch.Offset)
                }
                Set-Bytes $data $patch.Offset $patch.V8
                Write-Host ("Restored 0x{0:x8}: {1} -> {2} ({3})" -f `
                    $patch.Offset, (Get-Hex $patch.V9), (Get-Hex $patch.V8), $patch.Name)
            }

            $memorySha = Get-BytesSha256 $data
            if ($memorySha -ne $V8Sha) {
                throw "Internal V8 hash mismatch on revert: $memorySha"
            }
            Write-VerifiedReplacement $GameExe $data $V8Sha
            $final = Get-State $GameExe
            if ($final.State -ne 'v8') { throw 'Final V8 classification failed.' }

            Write-Host 'RESULT: REVERTED TO EXACT V8' -ForegroundColor Green
            Write-Host "SHA-256: $V8Sha"
        }
    }
}
catch {
    Write-Host ''
    Write-Host ("ERROR: " + $_.Exception.Message) -ForegroundColor Red
    exit 1
}
