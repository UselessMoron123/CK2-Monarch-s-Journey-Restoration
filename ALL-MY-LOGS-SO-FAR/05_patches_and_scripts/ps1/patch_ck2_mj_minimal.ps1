# Backup-safe minimal Monarch's Journey patcher for exact May 2020 CK2 3.3.3.
# Applies ONLY the two-byte factory patch. The filename remains "test.dds".
# Usage examples:
#   powershell -ExecutionPolicy Bypass -File .\patch_ck2_mj_minimal.ps1 Verify .\CK2game333.exe
#   powershell -ExecutionPolicy Bypass -File .\patch_ck2_mj_minimal.ps1 Apply  .\CK2game333.exe
#   powershell -ExecutionPolicy Bypass -File .\patch_ck2_mj_minimal.ps1 Revert .\CK2game333.exe

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
$ExpectedOriginalSha256 = '656f4f482ed698958e1108938f7e5baff5b5dd31b3b310a7ea51386faca635d8'
$Patches = @(
    [pscustomobject]@{
        Offset = 0x00d73d02L
        Original = [byte[]](0x74,0x2b)
        Patched = [byte[]](0xeb,0x2b)
        Description = 'force the local/null GameSparks implementation'
    }
)

function Get-Sha256([string]$Path) {
    return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()
}

function Get-Hex([byte[]]$Bytes) {
    return (($Bytes | ForEach-Object { $_.ToString('x2') }) -join ' ')
}

function Test-ByteSequence([byte[]]$Data, [long]$Offset, [byte[]]$Expected) {
    if ($Offset -lt 0 -or ($Offset + $Expected.Length) -gt $Data.LongLength) { return $false }
    for ($i = 0; $i -lt $Expected.Length; $i++) {
        if ($Data[$Offset + $i] -ne $Expected[$i]) { return $false }
    }
    return $true
}

function Get-ByteSequence([byte[]]$Data, [long]$Offset, [int]$Length) {
    $result = New-Object byte[] $Length
    [Array]::Copy($Data, $Offset, $result, 0, $Length)
    return $result
}

function Get-BytesSha256([byte[]]$Data) {
    $sha = [Security.Cryptography.SHA256]::Create()
    try {
        $hash = $sha.ComputeHash($Data)
        return (($hash | ForEach-Object { $_.ToString('x2') }) -join '')
    }
    finally {
        $sha.Dispose()
    }
}

function Get-Classification([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "File not found: $Path"
    }

    $item = Get-Item -LiteralPath $Path
    if ($item.Length -ne $ExpectedSize) {
        throw "Wrong file size: $($item.Length) bytes; expected $ExpectedSize. Refusing to touch this file."
    }

    $actualHash = Get-Sha256 $Path
    if ($actualHash -eq $ExpectedOriginalSha256) {
        return [pscustomobject]@{ State='original'; Sha256=$actualHash }
    }

    $data = [IO.File]::ReadAllBytes($Path)
    foreach ($patch in $Patches) {
        if (-not (Test-ByteSequence $data $patch.Offset $patch.Patched)) {
            $got = Get-ByteSequence $data $patch.Offset $patch.Patched.Length
            throw ("Unknown executable. SHA-256 is {0}; bytes at 0x{1:x8} are {2}, not {3}." -f `
                $actualHash, $patch.Offset, (Get-Hex $got), (Get-Hex $patch.Patched))
        }
        [Array]::Copy($patch.Original, 0, $data, $patch.Offset, $patch.Original.Length)
    }

    $normalizedHash = Get-BytesSha256 $data
    if ($normalizedHash -ne $ExpectedOriginalSha256) {
        throw "Patch bytes are present, but other bytes differ. Normalized SHA-256: $normalizedHash"
    }
    return [pscustomobject]@{ State='patched'; Sha256=$actualHash }
}

function Get-BackupPath([string]$Path) {
    return $Path + '.pre_mj_patch.bak'
}

function Assert-OriginalBackup([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Verified backup not found: $Path"
    }
    $item = Get-Item -LiteralPath $Path
    $hash = Get-Sha256 $Path
    if ($item.Length -ne $ExpectedSize -or $hash -ne $ExpectedOriginalSha256) {
        throw "Existing backup is not the verified original. Size=$($item.Length), SHA-256=$hash"
    }
}

$GameExe = [IO.Path]::GetFullPath($GameExe)
$Backup = Get-BackupPath $GameExe

switch ($Operation) {
    'Verify' {
        $result = Get-Classification $GameExe
        Write-Host "State: $($result.State)"
        Write-Host "Size: $((Get-Item -LiteralPath $GameExe).Length) bytes"
        Write-Host "SHA-256: $($result.Sha256)"
        if ($result.State -eq 'patched') {
            Write-Host 'Full normalized-hash verification: PASS'
        }
    }

    'Apply' {
        $result = Get-Classification $GameExe
        if ($result.State -eq 'patched') {
            Write-Host "Already patched and fully verified. SHA-256: $($result.Sha256)"
            break
        }

        if (Test-Path -LiteralPath $Backup) {
            Assert-OriginalBackup $Backup
            Write-Host "Reusing verified original backup: $Backup"
        }
        else {
            Copy-Item -LiteralPath $GameExe -Destination $Backup
            Assert-OriginalBackup $Backup
            Write-Host "Created and verified backup: $Backup"
        }

        $temp = $GameExe + '.' + [Guid]::NewGuid().ToString('N') + '.tmp'
        try {
            Copy-Item -LiteralPath $GameExe -Destination $temp
            $data = [IO.File]::ReadAllBytes($temp)
            foreach ($patch in $Patches) {
                if (-not (Test-ByteSequence $data $patch.Offset $patch.Original)) {
                    $got = Get-ByteSequence $data $patch.Offset $patch.Original.Length
                    throw ("Pre-write byte check failed at 0x{0:x8}: got {1}" -f $patch.Offset, (Get-Hex $got))
                }
                [Array]::Copy($patch.Patched, 0, $data, $patch.Offset, $patch.Patched.Length)
                Write-Host ("Applied at 0x{0:x8}: {1} -> {2} ({3})" -f `
                    $patch.Offset, (Get-Hex $patch.Original), (Get-Hex $patch.Patched), $patch.Description)
            }
            [IO.File]::WriteAllBytes($temp, $data)
            $tempResult = Get-Classification $temp
            if ($tempResult.State -ne 'patched') { throw 'Internal verification failed.' }
            Copy-Item -LiteralPath $temp -Destination $GameExe -Force
            $finalResult = Get-Classification $GameExe
            if ($finalResult.State -ne 'patched') { throw 'Final verification failed.' }
            Write-Host "Patched file SHA-256: $($finalResult.Sha256)"
            Write-Host 'Full normalized-hash verification: PASS'
            Write-Host 'The hardcoded filename remains test.dds (no unsafe string patch was used).'
        }
        finally {
            if (Test-Path -LiteralPath $temp) { Remove-Item -LiteralPath $temp -Force }
        }
    }

    'Revert' {
        Assert-OriginalBackup $Backup
        Copy-Item -LiteralPath $Backup -Destination $GameExe -Force
        $hash = Get-Sha256 $GameExe
        if ($hash -ne $ExpectedOriginalSha256) { throw 'Restored file failed SHA-256 verification.' }
        Write-Host "Restored verified original from: $Backup"
        Write-Host "SHA-256: $hash"
    }
}
