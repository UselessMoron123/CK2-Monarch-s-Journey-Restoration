# Guarded V7 Monarch's Journey patcher for Crusader Kings II 3.3.3.
# V7 fixes the Continue button execution by bypassing the retired cloud-sync
# gate at 0x1409E678B, allowing saved Featured Ruler / Monarch's Journey
# Bronzeman campaigns to load directly without triggering the "Continue failed" popup.
#
# Accepts V6 (or V5) and produces the verified V7 executable.
#
# Usage:
#   powershell -ExecutionPolicy Bypass -File .\patch_ck2_mj_v7.ps1 Verify .\CK2game.exe
#   powershell -ExecutionPolicy Bypass -File .\patch_ck2_mj_v7.ps1 Apply  .\CK2game.exe
#   powershell -ExecutionPolicy Bypass -File .\patch_ck2_mj_v7.ps1 Revert .\CK2game.exe

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

$V6Patches = @(
    [pscustomobject]@{
        Name = 'allow Featured Ruler save in Continue candidate selection'
        Offset = 0x009e4611L
        V5 = [byte[]](0x74,0x0f)
        V6 = [byte[]](0xeb,0x0f)
    },
    [pscustomobject]@{
        Name = 'allow selected Featured Ruler save in first save-list path'
        Offset = 0x009e4f1eL
        V5 = [byte[]](0x0f,0x84,0x86,0x01,0x00,0x00)
        V6 = [byte[]](0xe9,0x87,0x01,0x00,0x00,0x90)
    },
    [pscustomobject]@{
        Name = 'allow selected Featured Ruler save in newer-save path'
        Offset = 0x009e4fc3L
        V5 = [byte[]](0x74,0x0f)
        V6 = [byte[]](0xeb,0x0f)
    },
    [pscustomobject]@{
        Name = 'allow named Featured Ruler save in load-list path'
        Offset = 0x009e5377L
        V5 = [byte[]](0x0f,0x84,0x63,0x01,0x00,0x00)
        V6 = [byte[]](0xe9,0x64,0x01,0x00,0x00,0x90)
    },
    [pscustomobject]@{
        Name = 'allow latest Featured Ruler save in load-list path'
        Offset = 0x009e5452L
        V5 = [byte[]](0x74,0x0b)
        V6 = [byte[]](0xeb,0x0b)
    }
)

$V7Patches = @(
    [pscustomobject]@{
        Name = 'bypass retired cloud-sync check on Continue execution to load save directly'
        Offset = 0x009e5b8bL
        V6 = [byte[]](0x75,0x2f)
        V7 = [byte[]](0xeb,0x2f)
    }
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

function Get-BytesAt([byte[]]$Data, [long]$Offset, [int]$Length) {
    $result = New-Object byte[] $Length
    [Array]::Copy($Data, $Offset, $result, 0, $Length)
    return $result
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
    throw "Unknown executable SHA-256: $sha. Expected V5, V6, or V7 file. Nothing was changed."
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
            if ($result.State -eq 'v7') {
                Write-Host 'RESULT: CORRECT V7 CONTINUE-WORKING PATCH' -ForegroundColor Green
            }
            elseif ($result.State -eq 'v6') {
                Write-Host 'RESULT: V6 BASELINE DETECTED; READY TO APPLY V7' -ForegroundColor Yellow
            }
            else {
                Write-Host 'RESULT: V5 BASELINE DETECTED; READY TO APPLY V7' -ForegroundColor Yellow
            }
        }

        'Apply' {
            $result = Get-State $GameExe
            if ($result.State -eq 'v7') {
                Write-Host "Already correctly patched to V7. SHA-256: $V7Sha" -ForegroundColor Green
                break
            }

            $backup = Save-VerifiedBackup $GameExe $result.Sha256 "before_mj_v7_from_$($result.State)"
            Write-Host "Saved and verified backup: $backup"

            $data = [IO.File]::ReadAllBytes($GameExe)

            if ($result.State -eq 'v5') {
                foreach ($patch in $V6Patches) {
                    Set-Bytes $data $patch.Offset $patch.V6
                }
            }

            foreach ($patch in $V7Patches) {
                Set-Bytes $data $patch.Offset $patch.V7
                Write-Host ("Set 0x{0:x8}: {1} -> {2} ({3})" -f `
                    $patch.Offset, (Get-Hex $patch.V6), (Get-Hex $patch.V7), $patch.Name)
            }

            $memorySha = Get-BytesSha256 $data
            if ($memorySha -ne $V7Sha) {
                throw "Internal V7 hash mismatch: $memorySha"
            }
            Write-VerifiedReplacement $GameExe $data $V7Sha
            $final = Get-State $GameExe
            if ($final.State -ne 'v7') { throw 'Final V7 classification failed.' }

            Write-Host 'RESULT: V7 CONTINUE FIX PATCH APPLIED AND VERIFIED' -ForegroundColor Green
            Write-Host "SHA-256: $V7Sha"
            Write-Host 'The Continue button now loads directly into the game without the popup error.'
        }

        'Revert' {
            $result = Get-State $GameExe
            if ($result.State -ne 'v7') {
                Write-Host "Current state is $($result.State). Only V7 can be reverted by this script." -ForegroundColor Yellow
                break
            }

            $backup = Save-VerifiedBackup $GameExe $V7Sha 'before_v7_revert'
            Write-Host "Saved and verified V7 backup: $backup"

            $data = [IO.File]::ReadAllBytes($GameExe)
            foreach ($patch in $V7Patches) {
                Set-Bytes $data $patch.Offset $patch.V6
            }
            $memorySha = Get-BytesSha256 $data
            if ($memorySha -ne $V6Sha) { throw "Internal V6 restore hash mismatch: $memorySha" }
            Write-VerifiedReplacement $GameExe $data $V6Sha
            Write-Host 'Restored exact V6 state.' -ForegroundColor Green
            Write-Host "SHA-256: $V6Sha"
        }
    }
}
catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
