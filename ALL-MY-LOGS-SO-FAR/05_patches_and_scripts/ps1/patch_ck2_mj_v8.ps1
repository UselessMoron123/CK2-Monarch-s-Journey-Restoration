# Guarded V8 Monarch's Journey patcher for Crusader Kings II 3.3.3 (May 2020).
#
# V8 fixes feat/challenge progress showing 0 after a cold launch -> Load/Continue,
# while the same load worked after an in-session resign. Root cause: the in-game
# feat counter is re-hydrated only by CRulerFeatTracker::UpdateFeatProgress, and
# that call is gated twice by CRulerFeatTracker::IsActiveForPlaythrough():
#
#   1. CGameState::DailyUpdate skips UpdateFeatProgress entirely when
#      IsActiveForPlaythrough() is false   (raw 0x00666546: 74 0d -> 90 90)
#   2. CalcShouldTrackFeatProgress() (called inside UpdateFeatProgress) bails
#      when IsActiveForPlaythrough() is false (raw 0x007b786b: 75 05 -> eb 05)
#
# IsActiveForPlaythrough() reads the current game's featured-ruler key
# ([gameState+0x598]) and requires it to match a ruler in the local payload.
# That match is set by the frontend on a fresh campaign and survives a warm
# resign, but is not re-established after a cold load -> feats stay 0.
#
# Accepts V7 (or V6/V5) and produces the V8 executable. Length-preserving
# edits only; no code injection.
#
# Usage:
#   powershell -ExecutionPolicy Bypass -File .\patch_ck2_mj_v8.ps1 Verify .\CK2game.exe
#   powershell -ExecutionPolicy Bypass -File .\patch_ck2_mj_v8.ps1 Apply  .\CK2game.exe
#   powershell -ExecutionPolicy Bypass -File .\patch_ck2_mj_v8.ps1 Revert .\CK2game.exe

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
$V5Sha = '29556549fb5fc657f2966949b6a5b59c9b89b707f954adca4868cfd3d90b1535'
$V6Sha = 'f5b7dfd6e23b63f6353bb74f89493af0bd3db909e2d09961a543c773668530b0'
$V7Sha = '57b18e4392d03f0a3a67bc2c8c8d643302a9c44a141d90000219051adc521571'
$V8Sha = '94d6fb403b4541a53f846b348722ee81bc832b66ac853f6fd532f08e2e8b7e93'

# V6 patches (applied when upgrading from V5) and V7 patch (from V6), kept so a
# V5/V6 file can be brought all the way to V8 in one run.
$V6Patches = @(
    [pscustomobject]@{ Name = 'allow Featured Ruler save in Continue candidate selection'; Offset = 0x009e4611L; V5 = [byte[]](0x74,0x0f); V6 = [byte[]](0xeb,0x0f) },
    [pscustomobject]@{ Name = 'allow selected Featured Ruler save in first save-list path'; Offset = 0x009e4f1eL; V5 = [byte[]](0x0f,0x84,0x86,0x01,0x00,0x00); V6 = [byte[]](0xe9,0x87,0x01,0x00,0x00,0x90) },
    [pscustomobject]@{ Name = 'allow selected Featured Ruler save in newer-save path'; Offset = 0x009e4fc3L; V5 = [byte[]](0x74,0x0f); V6 = [byte[]](0xeb,0x0f) },
    [pscustomobject]@{ Name = 'allow named Featured Ruler save in load-list path'; Offset = 0x009e5377L; V5 = [byte[]](0x0f,0x84,0x63,0x01,0x00,0x00); V6 = [byte[]](0xe9,0x64,0x01,0x00,0x00,0x90) },
    [pscustomobject]@{ Name = 'allow latest Featured Ruler save in load-list path'; Offset = 0x009e5452L; V5 = [byte[]](0x74,0x0b); V6 = [byte[]](0xeb,0x0b) }
)

$V7Patches = @(
    [pscustomobject]@{ Name = 'bypass retired cloud-sync check on Continue execution'; Offset = 0x009e5b8bL; V6 = [byte[]](0x75,0x2f); V7 = [byte[]](0xeb,0x2f) }
)

$V8Patches = @(
    [pscustomobject]@{ Name = 'always re-hydrate feats in the daily update (skip IsActiveForPlaythrough gate)'; Offset = 0x00666546L; V7 = [byte[]](0x74,0x0d); V8 = [byte[]](0x90,0x90) },
    [pscustomobject]@{ Name = 'always re-hydrate feats inside UpdateFeatProgress (skip IsActiveForPlaythrough gate)'; Offset = 0x007b786bL; V7 = [byte[]](0x75,0x05); V8 = [byte[]](0xeb,0x05) }
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
    if ($sha -eq $V5Sha) { return [pscustomobject]@{State='v5'; Sha256=$sha} }
    if ($sha -eq $V6Sha) { return [pscustomobject]@{State='v6'; Sha256=$sha} }
    if ($sha -eq $V7Sha) { return [pscustomobject]@{State='v7'; Sha256=$sha} }
    if ($sha -eq $V8Sha) { return [pscustomobject]@{State='v8'; Sha256=$sha} }
    throw "Unknown executable SHA-256: $sha. Expected V5, V6, V7, or V8 file. Nothing was changed."
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
                'v8' { Write-Host 'RESULT: CORRECT V8 FEAT-REHYDRATION PATCH' -ForegroundColor Green }
                'v7' { Write-Host 'RESULT: V7 BASELINE DETECTED; READY TO APPLY V8' -ForegroundColor Yellow }
                'v6' { Write-Host 'RESULT: V6 BASELINE DETECTED; READY TO APPLY V8' -ForegroundColor Yellow }
                'v5' { Write-Host 'RESULT: V5 BASELINE DETECTED; READY TO APPLY V8' -ForegroundColor Yellow }
            }
        }

        'Apply' {
            $result = Get-State $GameExe
            if ($result.State -eq 'v8') {
                Write-Host "Already correctly patched to V8. SHA-256: $V8Sha" -ForegroundColor Green
                break
            }

            $backup = Save-VerifiedBackup $GameExe $result.Sha256 "before_mj_v8_from_$($result.State)"
            Write-Host "Saved and verified backup: $backup"

            $data = [IO.File]::ReadAllBytes($GameExe)

            if ($result.State -eq 'v5') {
                foreach ($patch in $V6Patches) {
                    Set-Bytes $data $patch.Offset $patch.V6
                }
            }
            if ($result.State -eq 'v5' -or $result.State -eq 'v6') {
                foreach ($patch in $V7Patches) {
                    Set-Bytes $data $patch.Offset $patch.V7
                }
            }

            foreach ($patch in $V8Patches) {
                if (-not (Test-Bytes $data $patch.Offset $patch.V7)) {
                    throw ("Pre-write byte check failed at 0x{0:x8}. Refusing to patch." -f $patch.Offset)
                }
                Set-Bytes $data $patch.Offset $patch.V8
                Write-Host ("Set 0x{0:x8}: {1} -> {2} ({3})" -f `
                    $patch.Offset, (Get-Hex $patch.V7), (Get-Hex $patch.V8), $patch.Name)
            }

            $memorySha = Get-BytesSha256 $data
            if ($memorySha -ne $V8Sha) {
                throw "Internal V8 hash mismatch: $memorySha"
            }
            Write-VerifiedReplacement $GameExe $data $V8Sha
            $final = Get-State $GameExe
            if ($final.State -ne 'v8') { throw 'Final V8 classification failed.' }

            Write-Host 'RESULT: V8 FEAT-REHYDRATION PATCH APPLIED AND VERIFIED' -ForegroundColor Green
            Write-Host "SHA-256: $V8Sha"
            Write-Host 'Feats should now repopulate from the save after a cold launch -> Load/Continue.'
        }

        'Revert' {
            $result = Get-State $GameExe
            if ($result.State -ne 'v8') {
                Write-Host "Current state is $($result.State). Only V8 can be reverted by this script." -ForegroundColor Yellow
                break
            }
            $backup = Save-VerifiedBackup $GameExe $result.Sha256 'before_mj_v8_revert'
            Write-Host "Saved and verified backup: $backup"

            $data = [IO.File]::ReadAllBytes($GameExe)
            foreach ($patch in $V8Patches) {
                if (-not (Test-Bytes $data $patch.Offset $patch.V8)) {
                    throw ("Pre-revert byte check failed at 0x{0:x8}." -f $patch.Offset)
                }
                Set-Bytes $data $patch.Offset $patch.V7
                Write-Host ("Restored 0x{0:x8}: {1} -> {2} ({3})" -f `
                    $patch.Offset, (Get-Hex $patch.V8), (Get-Hex $patch.V7), $patch.Name)
            }

            $memorySha = Get-BytesSha256 $data
            if ($memorySha -ne $V7Sha) {
                throw "Internal V7 hash mismatch on revert: $memorySha"
            }
            Write-VerifiedReplacement $GameExe $data $V7Sha
            $final = Get-State $GameExe
            if ($final.State -ne 'v7') { throw 'Final V7 classification failed.' }

            Write-Host 'RESULT: REVERTED TO EXACT V7' -ForegroundColor Green
            Write-Host "SHA-256: $V7Sha"
        }
    }
}
catch {
    Write-Host ''
    Write-Host ("ERROR: " + $_.Exception.Message) -ForegroundColor Red
    exit 1
}
