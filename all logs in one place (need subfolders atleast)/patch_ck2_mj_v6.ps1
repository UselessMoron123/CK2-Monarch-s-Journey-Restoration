# Guarded V6 save-selection patch for the exact V5 CK2 3.3.3 executable.
# V6 adds five narrowly scoped Featured Ruler save-selection/Continue fixes.
# It does not modify save files and does not globally fabricate account state.
#
# Usage:
#   powershell -ExecutionPolicy Bypass -File .\patch_ck2_mj_v6.ps1 Verify .\CK2game.exe
#   powershell -ExecutionPolicy Bypass -File .\patch_ck2_mj_v6.ps1 Apply  .\CK2game.exe
#   powershell -ExecutionPolicy Bypass -File .\patch_ck2_mj_v6.ps1 Revert .\CK2game.exe

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

$Patches = @(
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
    throw "Unknown executable SHA-256: $sha. Expected the exact V5 or V6 file. Nothing was changed."
}

function Assert-PatchBytes([byte[]]$Data, [string]$State) {
    foreach ($patch in $Patches) {
        $expected = if ($State -eq 'v5') { $patch.V5 } else { $patch.V6 }
        if (-not (Test-Bytes $Data $patch.Offset $expected)) {
            $got = Get-BytesAt $Data $patch.Offset $expected.Length
            throw ("Unexpected bytes at 0x{0:x8}: got {1}; expected {2}." -f `
                $patch.Offset, (Get-Hex $got), (Get-Hex $expected))
        }
    }
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
            $data = [IO.File]::ReadAllBytes($GameExe)
            Assert-PatchBytes $data $result.State
            Write-Host "State: $($result.State)"
            Write-Host "Size: $((Get-Item -LiteralPath $GameExe).Length) bytes"
            Write-Host "SHA-256: $($result.Sha256)"
            if ($result.State -eq 'v6') {
                Write-Host 'RESULT: CORRECT V6 SAVE-LOADING TEST PATCH' -ForegroundColor Green
            }
            else {
                Write-Host 'RESULT: CORRECT V5; APPLY V6' -ForegroundColor Yellow
            }
        }

        'Apply' {
            $result = Get-State $GameExe
            $data = [IO.File]::ReadAllBytes($GameExe)
            Assert-PatchBytes $data $result.State
            if ($result.State -eq 'v6') {
                Write-Host "Already correctly patched to V6. SHA-256: $V6Sha" -ForegroundColor Green
                break
            }

            $backup = Save-VerifiedBackup $GameExe $V5Sha 'before_mj_v6'
            Write-Host "Saved and verified V5 backup: $backup"

            foreach ($patch in $Patches) {
                Set-Bytes $data $patch.Offset $patch.V6
                Write-Host ("Set 0x{0:x8}: {1} -> {2} ({3})" -f `
                    $patch.Offset, (Get-Hex $patch.V5), (Get-Hex $patch.V6), $patch.Name)
            }

            $memorySha = Get-BytesSha256 $data
            if ($memorySha -ne $V6Sha) {
                throw "Internal V6 hash mismatch: $memorySha"
            }
            Write-VerifiedReplacement $GameExe $data $V6Sha
            $final = Get-State $GameExe
            if ($final.State -ne 'v6') { throw 'Final V6 classification failed.' }

            Write-Host 'RESULT: V6 SAVE-LOADING TEST PATCH APPLIED AND VERIFIED' -ForegroundColor Green
            Write-Host "SHA-256: $V6Sha"
            Write-Host 'No save file was modified.'
        }

        'Revert' {
            $result = Get-State $GameExe
            $data = [IO.File]::ReadAllBytes($GameExe)
            Assert-PatchBytes $data $result.State
            if ($result.State -eq 'v5') {
                Write-Host "Already at the exact V5 state. SHA-256: $V5Sha" -ForegroundColor Green
                break
            }

            $backup = Save-VerifiedBackup $GameExe $V6Sha 'before_v6_revert'
            Write-Host "Saved and verified V6 backup: $backup"
            foreach ($patch in $Patches) {
                Set-Bytes $data $patch.Offset $patch.V5
            }
            $memorySha = Get-BytesSha256 $data
            if ($memorySha -ne $V5Sha) { throw "Internal V5 restore hash mismatch: $memorySha" }
            Write-VerifiedReplacement $GameExe $data $V5Sha
            Write-Host 'Restored exact V5 state.' -ForegroundColor Green
            Write-Host "SHA-256: $V5Sha"
        }
    }
}
catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
