# Corrected v2 Monarch's Journey patcher for the exact May 2020 Windows CK2 3.3.3 executable.
# It accepts the verified original, the earlier branch-only patch, or the finished v2 patch.
# Usage:
#   powershell -ExecutionPolicy Bypass -File .\patch_ck2_mj_v2.ps1 Verify .\CK2game_MJ.exe
#   powershell -ExecutionPolicy Bypass -File .\patch_ck2_mj_v2.ps1 Apply  .\CK2game_MJ.exe
#   powershell -ExecutionPolicy Bypass -File .\patch_ck2_mj_v2.ps1 Revert .\CK2game_MJ.exe

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
$OriginalSha = '656f4f482ed698958e1108938f7e5baff5b5dd31b3b310a7ea51386faca635d8'
$BranchOnlySha = '854853207ac46aafa6dec82160d66ab69b1097e67199a861cd547a732483370c'
$V2Sha = '1a481a4adabf2bc1091cffcb19691e919e4c49a8157dad5d259081d8cbca9175'

$Patches = @(
    [pscustomobject]@{
        Name = 'force local/null implementation'
        Offset = 0x00d73d02L
        Original = [byte[]](0x74,0x2b)
        Patched = [byte[]](0xeb,0x2b)
    },
    [pscustomobject]@{
        Name = 'redirect only the local loader from gfx/test.dds to gfx/monarchs'
        Offset = 0x00d73e1aL
        Original = [byte[]](0xba,0x23,0x36,0x00)
        Patched = [byte[]](0x21,0xfc,0x32,0x00)
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

function Test-Bytes([byte[]]$Data, [long]$Offset, [byte[]]$Expected) {
    if (($Offset + $Expected.Length) -gt $Data.LongLength) { return $false }
    for ($i=0; $i -lt $Expected.Length; $i++) {
        if ($Data[$Offset + $i] -ne $Expected[$i]) { return $false }
    }
    return $true
}

function Set-Bytes([byte[]]$Data, [long]$Offset, [byte[]]$Value) {
    [Array]::Copy($Value, 0, $Data, $Offset, $Value.Length)
}

function Get-Classification([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { throw "File not found: $Path" }
    $item = Get-Item -LiteralPath $Path
    if ($item.Length -ne $ExpectedSize) {
        throw "Wrong size: $($item.Length) bytes; expected $ExpectedSize. Refusing this file."
    }

    $actualSha = Get-Sha256 $Path
    $data = [IO.File]::ReadAllBytes($Path)
    $states = @()
    foreach ($patch in $Patches) {
        if (Test-Bytes $data $patch.Offset $patch.Original) {
            $states += 'original'
        }
        elseif (Test-Bytes $data $patch.Offset $patch.Patched) {
            $states += 'patched'
            Set-Bytes $data $patch.Offset $patch.Original
        }
        else {
            $length = $patch.Original.Length
            $got = New-Object byte[] $length
            [Array]::Copy($data, $patch.Offset, $got, 0, $length)
            throw ("Unrecognized bytes at 0x{0:x8}: {1}" -f $patch.Offset, (Get-Hex $got))
        }
    }

    $normalizedSha = Get-BytesSha256 $data
    if ($normalizedSha -ne $OriginalSha) {
        throw "Other executable bytes differ. Normalized SHA-256: $normalizedSha"
    }

    if ($states[0] -eq 'original' -and $states[1] -eq 'original') { $state = 'original' }
    elseif ($states[0] -eq 'patched' -and $states[1] -eq 'original') { $state = 'branch-only' }
    elseif ($states[0] -eq 'patched' -and $states[1] -eq 'patched') { $state = 'v2' }
    else { $state = 'redirect-only' }

    if ($state -eq 'original' -and $actualSha -ne $OriginalSha) { throw 'Original-state SHA mismatch.' }
    if ($state -eq 'branch-only' -and $actualSha -ne $BranchOnlySha) { throw 'Branch-only SHA mismatch.' }
    if ($state -eq 'v2' -and $actualSha -ne $V2Sha) { throw 'V2 SHA mismatch.' }

    return [pscustomobject]@{ State=$state; Sha256=$actualSha; NormalizedData=$data }
}

function Write-VerifiedFile([string]$Path, [byte[]]$Data, [string]$ExpectedSha) {
    [IO.File]::WriteAllBytes($Path, $Data)
    $sha = Get-Sha256 $Path
    if ($sha -ne $ExpectedSha) {
        Remove-Item -LiteralPath $Path -Force -ErrorAction SilentlyContinue
        throw "Written file failed verification: $Path (SHA-256 $sha)"
    }
}

$GameExe = [IO.Path]::GetFullPath($GameExe)

switch ($Operation) {
    'Verify' {
        $result = Get-Classification $GameExe
        Write-Host "State: $($result.State)"
        Write-Host "Size: $((Get-Item -LiteralPath $GameExe).Length) bytes"
        Write-Host "SHA-256: $($result.Sha256)"
        if ($result.State -eq 'v2') {
            Write-Host 'RESULT: CORRECT V2 PATCH' -ForegroundColor Green
            Write-Host 'Payload location: <game folder>\gfx\monarchs'
        }
        elseif ($result.State -eq 'branch-only') {
            Write-Host 'RESULT: EARLIER INCOMPLETE PATCH; APPLY V2' -ForegroundColor Yellow
        }
        elseif ($result.State -eq 'original') {
            Write-Host 'RESULT: VERIFIED ORIGINAL; APPLY V2' -ForegroundColor Yellow
        }
    }

    'Apply' {
        $result = Get-Classification $GameExe
        if ($result.State -eq 'v2') {
            Write-Host "Already correctly patched to v2. SHA-256: $V2Sha" -ForegroundColor Green
            break
        }

        $currentBackup = $GameExe + '.before_mj_v2.bak'
        if (-not (Test-Path -LiteralPath $currentBackup)) {
            Copy-Item -LiteralPath $GameExe -Destination $currentBackup
            $null = Get-Classification $currentBackup
            Write-Host "Saved verified current-state backup: $currentBackup"
        }
        else {
            $null = Get-Classification $currentBackup
            Write-Host "Reusing verified current-state backup: $currentBackup"
        }

        # The normalized in-memory data is byte-for-byte the verified May original.
        $originalBackup = $GameExe + '.verified_may333_original.bak'
        if (Test-Path -LiteralPath $originalBackup) {
            $sha = Get-Sha256 $originalBackup
            if ($sha -ne $OriginalSha) { throw "Existing original backup is invalid: $originalBackup" }
        }
        else {
            Write-VerifiedFile $originalBackup $result.NormalizedData $OriginalSha
            Write-Host "Created reconstructed, hash-verified original backup: $originalBackup"
        }

        $newData = [byte[]]$result.NormalizedData.Clone()
        foreach ($patch in $Patches) {
            Set-Bytes $newData $patch.Offset $patch.Patched
            Write-Host ("Set 0x{0:x8}: {1} -> {2} ({3})" -f $patch.Offset, `
                (Get-Hex $patch.Original), (Get-Hex $patch.Patched), $patch.Name)
        }

        $newSha = Get-BytesSha256 $newData
        if ($newSha -ne $V2Sha) { throw "Internal v2 hash mismatch: $newSha" }

        $temp = $GameExe + '.' + [Guid]::NewGuid().ToString('N') + '.tmp'
        try {
            Write-VerifiedFile $temp $newData $V2Sha
            Copy-Item -LiteralPath $temp -Destination $GameExe -Force
            $final = Get-Classification $GameExe
            if ($final.State -ne 'v2') { throw 'Final v2 verification failed.' }
        }
        finally {
            Remove-Item -LiteralPath $temp -Force -ErrorAction SilentlyContinue
        }

        Write-Host 'RESULT: V2 PATCH APPLIED AND FULLY VERIFIED' -ForegroundColor Green
        Write-Host "SHA-256: $V2Sha"
        Write-Host 'Put the JSON payload at: <game folder>\gfx\monarchs'
    }

    'Revert' {
        $result = Get-Classification $GameExe
        $originalBackup = $GameExe + '.verified_may333_original.bak'
        if (Test-Path -LiteralPath $originalBackup) {
            $sha = Get-Sha256 $originalBackup
            if ($sha -ne $OriginalSha) { throw 'Original backup failed SHA-256 verification.' }
            Copy-Item -LiteralPath $originalBackup -Destination $GameExe -Force
        }
        else {
            [IO.File]::WriteAllBytes($GameExe, $result.NormalizedData)
        }
        $sha = Get-Sha256 $GameExe
        if ($sha -ne $OriginalSha) { throw 'Restored executable failed verification.' }
        Write-Host 'Restored exact verified May 2020 original.' -ForegroundColor Green
        Write-Host "SHA-256: $sha"
    }
}
