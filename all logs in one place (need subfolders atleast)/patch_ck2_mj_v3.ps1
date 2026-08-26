# Guarded v3 Monarch's Journey patcher for the exact May 2020 Windows CK2 3.3.3 executable.
# It accepts the verified original, the earlier branch-only patch, v2, v3, or a
# combination containing only the seven known edits below. All other files are refused.
# Usage:
#   powershell -ExecutionPolicy Bypass -File .\patch_ck2_mj_v3.ps1 Verify .\CK2game.exe
#   powershell -ExecutionPolicy Bypass -File .\patch_ck2_mj_v3.ps1 Apply  .\CK2game.exe
#   powershell -ExecutionPolicy Bypass -File .\patch_ck2_mj_v3.ps1 Revert .\CK2game.exe

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
$V3Sha = 'e91a5f4693ca3b747d7340fda71ed66b3593e2f98af14c37e6086b0d76fb13ca'

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
    },
    [pscustomobject]@{
        Name = 'enable Play when the local ruler is otherwise ready'
        Offset = 0x007bd64eL
        Original = [byte[]](0x75,0x04)
        Patched = [byte[]](0x90,0x90)
    },
    [pscustomobject]@{
        Name = 'use normal Play tooltip instead of login tooltip'
        Offset = 0x007beacbL
        Original = [byte[]](0x74,0x19)
        Patched = [byte[]](0xeb,0x19)
    },
    [pscustomobject]@{
        Name = 'use normal Continue tooltip instead of login tooltip'
        Offset = 0x007beea2L
        Original = [byte[]](0x74,0x0c)
        Patched = [byte[]](0xeb,0x0c)
    },
    [pscustomobject]@{
        Name = 'use normal Restart path instead of login tooltip'
        Offset = 0x007befafL
        Original = [byte[]](0x74,0x2d)
        Patched = [byte[]](0xeb,0x2d)
    },
    [pscustomobject]@{
        Name = 'show local rewards and hide the login prompt'
        Offset = 0x007c0d18L
        Original = [byte[]](0x74,0x0b)
        Patched = [byte[]](0xeb,0x0b)
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

    # Restoring all seven known edits must reproduce the exact May executable.
    $normalizedSha = Get-BytesSha256 $data
    if ($normalizedSha -ne $OriginalSha) {
        throw "Other executable bytes differ. Normalized SHA-256: $normalizedSha"
    }

    $allOriginal = (@($states | Where-Object { $_ -ne 'original' }).Count -eq 0)
    $allPatched = (@($states | Where-Object { $_ -ne 'patched' }).Count -eq 0)
    $onlyBranch = (($states[0] -eq 'patched') -and (@($states[1..6] | Where-Object { $_ -ne 'original' }).Count -eq 0))
    $onlyV2 = (($states[0] -eq 'patched') -and ($states[1] -eq 'patched') -and (@($states[2..6] | Where-Object { $_ -ne 'original' }).Count -eq 0))

    if ($allOriginal) { $state = 'original' }
    elseif ($onlyBranch) { $state = 'branch-only' }
    elseif ($onlyV2) { $state = 'v2' }
    elseif ($allPatched) { $state = 'v3' }
    else { $state = 'recognized-partial' }

    if ($state -eq 'original' -and $actualSha -ne $OriginalSha) { throw 'Original-state SHA mismatch.' }
    if ($state -eq 'branch-only' -and $actualSha -ne $BranchOnlySha) { throw 'Branch-only SHA mismatch.' }
    if ($state -eq 'v2' -and $actualSha -ne $V2Sha) { throw 'V2 SHA mismatch.' }
    if ($state -eq 'v3' -and $actualSha -ne $V3Sha) { throw 'V3 SHA mismatch.' }

    return [pscustomobject]@{
        State = $state
        Sha256 = $actualSha
        NormalizedData = $data
    }
}

function Write-VerifiedFile([string]$Path, [byte[]]$Data, [string]$ExpectedSha) {
    [IO.File]::WriteAllBytes($Path, $Data)
    $sha = Get-Sha256 $Path
    if ($sha -ne $ExpectedSha) {
        Remove-Item -LiteralPath $Path -Force -ErrorAction SilentlyContinue
        throw "Written file failed verification: $Path (SHA-256 $sha)"
    }
}

function Save-CurrentBackup([string]$Path, [string]$CurrentSha) {
    $stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
    $backup = $Path + '.before_mj_v3_' + $stamp + '.bak'
    $counter = 1
    while (Test-Path -LiteralPath $backup) {
        $backup = $Path + '.before_mj_v3_' + $stamp + '_' + $counter + '.bak'
        $counter++
    }
    Copy-Item -LiteralPath $Path -Destination $backup
    $backupSha = Get-Sha256 $backup
    if ($backupSha -ne $CurrentSha) {
        Remove-Item -LiteralPath $backup -Force -ErrorAction SilentlyContinue
        throw 'Current-state backup failed SHA-256 verification.'
    }
    $null = Get-Classification $backup
    return $backup
}

$GameExe = [IO.Path]::GetFullPath($GameExe)

switch ($Operation) {
    'Verify' {
        $result = Get-Classification $GameExe
        Write-Host "State: $($result.State)"
        Write-Host "Size: $((Get-Item -LiteralPath $GameExe).Length) bytes"
        Write-Host "SHA-256: $($result.Sha256)"
        if ($result.State -eq 'v3') {
            Write-Host 'RESULT: CORRECT V3 PATCH' -ForegroundColor Green
            Write-Host 'Payload location: <game folder>\gfx\monarchs'
        }
        elseif ($result.State -eq 'v2') {
            Write-Host 'RESULT: CORRECT V2; APPLY V3 FOR THE OFFLINE UI GATE' -ForegroundColor Yellow
        }
        else {
            Write-Host 'RESULT: VERIFIED INPUT; APPLY V3' -ForegroundColor Yellow
        }
    }

    'Apply' {
        $result = Get-Classification $GameExe
        if ($result.State -eq 'v3') {
            Write-Host "Already correctly patched to v3. SHA-256: $V3Sha" -ForegroundColor Green
            break
        }

        $currentBackup = Save-CurrentBackup $GameExe $result.Sha256
        Write-Host "Saved and verified current-state backup: $currentBackup"

        # Preserve a fixed, exact original backup as well.
        $originalBackup = $GameExe + '.verified_may333_original.bak'
        if (Test-Path -LiteralPath $originalBackup) {
            $sha = Get-Sha256 $originalBackup
            if ($sha -ne $OriginalSha) { throw "Existing original backup is invalid: $originalBackup" }
            Write-Host "Reusing hash-verified original backup: $originalBackup"
        }
        else {
            Write-VerifiedFile $originalBackup $result.NormalizedData $OriginalSha
            Write-Host "Created exact hash-verified original backup: $originalBackup"
        }

        $newData = [byte[]]$result.NormalizedData.Clone()
        foreach ($patch in $Patches) {
            Set-Bytes $newData $patch.Offset $patch.Patched
            Write-Host ("Set 0x{0:x8}: {1} -> {2} ({3})" -f $patch.Offset, `
                (Get-Hex $patch.Original), (Get-Hex $patch.Patched), $patch.Name)
        }

        $newSha = Get-BytesSha256 $newData
        if ($newSha -ne $V3Sha) { throw "Internal v3 hash mismatch: $newSha" }

        $temp = $GameExe + '.' + [Guid]::NewGuid().ToString('N') + '.tmp'
        try {
            Write-VerifiedFile $temp $newData $V3Sha
            Copy-Item -LiteralPath $temp -Destination $GameExe -Force
            $final = Get-Classification $GameExe
            if ($final.State -ne 'v3') { throw 'Final v3 verification failed.' }
        }
        finally {
            Remove-Item -LiteralPath $temp -Force -ErrorAction SilentlyContinue
        }

        Write-Host 'RESULT: V3 PATCH APPLIED AND FULLY VERIFIED' -ForegroundColor Green
        Write-Host "SHA-256: $V3Sha"
        Write-Host 'Required payload: <game folder>\gfx\monarchs'
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
            Write-VerifiedFile $GameExe $result.NormalizedData $OriginalSha
        }
        $sha = Get-Sha256 $GameExe
        if ($sha -ne $OriginalSha) { throw 'Restored executable failed verification.' }
        Write-Host 'Restored exact verified May 2020 original.' -ForegroundColor Green
        Write-Host "SHA-256: $sha"
        Write-Host 'The inert gfx\monarchs payload may be left in place or deleted manually.'
    }
}
