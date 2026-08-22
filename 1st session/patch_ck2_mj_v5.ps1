# Guarded v5 Monarch's Journey patcher for the exact May 2020 Windows CK2 3.3.3 executable.
# V5 extends the proven v4 campaign patch with a narrowly scoped offline fix for
# loading and continuing valid Featured Ruler saves. It accepts the verified
# original, branch-only patch, v2, v3, v4, v5, or a combination containing only
# recognized edits below. Every other executable is refused.
#
# Usage:
#   powershell -ExecutionPolicy Bypass -File .\patch_ck2_mj_v5.ps1 Verify .\CK2game.exe
#   powershell -ExecutionPolicy Bypass -File .\patch_ck2_mj_v5.ps1 Apply  .\CK2game.exe
#   powershell -ExecutionPolicy Bypass -File .\patch_ck2_mj_v5.ps1 Revert .\CK2game.exe

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
$V4Sha = 'f2967f6f2c5b8b7d49dec2f7066139ace321cca19480f5c57d3ca8d576259b30'
$V5Sha = '29556549fb5fc657f2966949b6a5b59c9b89b707f954adca4868cfd3d90b1535'

# Original is always the exact May byte sequence. V5 is the desired sequence.
# Legacy is an optional v3-only sequence accepted solely so v3 can be upgraded.
$Patches = @(
    [pscustomobject]@{
        Name = 'force local/null implementation'
        Offset = 0x00d73d02L
        Original = [byte[]](0x74,0x2b)
        V5 = [byte[]](0xeb,0x2b)
        Legacy = $null
    },
    [pscustomobject]@{
        Name = 'redirect only the local loader from gfx/test.dds to gfx/monarchs'
        Offset = 0x00d73e1aL
        Original = [byte[]](0xba,0x23,0x36,0x00)
        V5 = [byte[]](0x21,0xfc,0x32,0x00)
        Legacy = $null
    },
    [pscustomobject]@{
        Name = 'enable Play when the local ruler is otherwise ready'
        Offset = 0x007bd64eL
        Original = [byte[]](0x75,0x04)
        V5 = [byte[]](0x90,0x90)
        Legacy = $null
    },
    [pscustomobject]@{
        Name = 'use normal Play tooltip instead of login tooltip'
        Offset = 0x007beacbL
        Original = [byte[]](0x74,0x19)
        V5 = [byte[]](0xeb,0x19)
        Legacy = $null
    },
    [pscustomobject]@{
        Name = 'use normal Continue tooltip instead of login tooltip'
        Offset = 0x007beea2L
        Original = [byte[]](0x74,0x0c)
        V5 = [byte[]](0xeb,0x0c)
        Legacy = $null
    },
    [pscustomobject]@{
        Name = 'use normal Restart path instead of login tooltip'
        Offset = 0x007befafL
        Original = [byte[]](0x74,0x2d)
        V5 = [byte[]](0xeb,0x2d)
        Legacy = $null
    },
    [pscustomobject]@{
        Name = 'keep the offline reward-container branch (undo v3 empty-reward exposure)'
        Offset = 0x007c0d18L
        Original = [byte[]](0x74,0x0b)
        V5 = [byte[]](0x74,0x0b)
        Legacy = [byte[]](0xeb,0x0b)
    },
    [pscustomobject]@{
        Name = 'hide both the unpopulated reward container and obsolete login text offline'
        Offset = 0x007c0d23L
        Original = [byte[]](0xeb,0x5c)
        V5 = [byte[]](0x90,0x90)
        Legacy = $null
    },
    [pscustomobject]@{
        Name = 'ignore the stock-checksum prerequisite only while Steam is inactive'
        Offset = 0x000aeb83L
        Original = [byte[]](0x80,0x7f,0x61,0x00,0x74,0x0c,0x80,0x7f,0x63,0x00,0x74,0x06,0x80,0x7f,0x62,0x00,0x74,0x02,0x33,0xf6,0x40,0x0f,0xb6,0xc6)
        V5 = [byte[]](0x31,0xc0,0x66,0x83,0x7f,0x61,0x01,0x75,0x0f,0x80,0x7f,0x63,0x00,0x75,0x06,0x80,0x7f,0x65,0x00,0x75,0x03,0xff,0xc0,0x90)
        Legacy = $null
    },
    [pscustomobject]@{
        Name = 'bypass retired Steam-active gate for challenge-mode Start button'
        Offset = 0x00732b03L
        Original = [byte[]](0x74,0x16)
        V5 = [byte[]](0x90,0x90)
        Legacy = $null
    },
    [pscustomobject]@{
        Name = 'bypass retired Steam-active gate in challenge-enabled predicate'
        Offset = 0x007336b0L
        Original = [byte[]](0x74,0x1d)
        V5 = [byte[]](0x90,0x90)
        Legacy = $null
    },
    [pscustomobject]@{
        Name = 'bypass retired Steam-active gate in Start warning predicate'
        Offset = 0x007337e1L
        Original = [byte[]](0x74,0x1d)
        V5 = [byte[]](0x90,0x90)
        Legacy = $null
    },
    [pscustomobject]@{
        Name = 'bypass retired Steam-active gate in challenge tooltip heading'
        Offset = 0x00737262L
        Original = [byte[]](0x74,0x1b)
        V5 = [byte[]](0x90,0x90)
        Legacy = $null
    },
    [pscustomobject]@{
        Name = 'bypass retired Steam-active gate in in-game feat tracking'
        Offset = 0x007b78ebL
        Original = [byte[]](0x75,0x0c)
        V5 = [byte[]](0xeb,0x0c)
        Legacy = $null
    },
    [pscustomobject]@{
        Name = 'allow otherwise-valid Featured Ruler saves through shared Load and Continue validation'
        Offset = 0x009e3d4cL
        Original = [byte[]](0x74,0x0b)
        V5 = [byte[]](0xeb,0x0b)
        Legacy = $null
    },
    [pscustomobject]@{
        Name = 'use normal save tooltip instead of retired Monarch login requirement'
        Offset = 0x009e1c2dL
        Original = [byte[]](0x74,0x49)
        V5 = [byte[]](0xeb,0x49)
        Legacy = $null
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

    foreach ($patch in $Patches) {
        if (Test-Bytes $data $patch.Offset $patch.Original) {
            continue
        }
        elseif (Test-Bytes $data $patch.Offset $patch.V5) {
            Set-Bytes $data $patch.Offset $patch.Original
        }
        elseif (($null -ne $patch.Legacy) -and (Test-Bytes $data $patch.Offset $patch.Legacy)) {
            Set-Bytes $data $patch.Offset $patch.Original
        }
        else {
            $length = $patch.Original.Length
            $got = New-Object byte[] $length
            [Array]::Copy([IO.File]::ReadAllBytes($Path), $patch.Offset, $got, 0, $length)
            throw ("Unrecognized bytes at 0x{0:x8}: {1}" -f $patch.Offset, (Get-Hex $got))
        }
    }

    # Restoring every recognized edit must reproduce the exact May executable.
    $normalizedSha = Get-BytesSha256 $data
    if ($normalizedSha -ne $OriginalSha) {
        throw "Other executable bytes differ. Normalized SHA-256: $normalizedSha"
    }

    if ($actualSha -eq $OriginalSha) { $state = 'original' }
    elseif ($actualSha -eq $BranchOnlySha) { $state = 'branch-only' }
    elseif ($actualSha -eq $V2Sha) { $state = 'v2' }
    elseif ($actualSha -eq $V3Sha) { $state = 'v3' }
    elseif ($actualSha -eq $V4Sha) { $state = 'v4' }
    elseif ($actualSha -eq $V5Sha) { $state = 'v5' }
    else { $state = 'recognized-partial' }

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
    $backup = $Path + '.before_mj_v5_' + $stamp + '.bak'
    $counter = 1
    while (Test-Path -LiteralPath $backup) {
        $backup = $Path + '.before_mj_v5_' + $stamp + '_' + $counter + '.bak'
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
        if ($result.State -eq 'v5') {
            Write-Host 'RESULT: CORRECT V5 OFFLINE LOAD PATCH' -ForegroundColor Green
            Write-Host 'Payload location: <game folder>\gfx\monarchs'
        }
        elseif ($result.State -eq 'v3') {
            Write-Host 'RESULT: CORRECT V3; APPLY V5 FOR OFFLINE CHALLENGES AND SAVE LOADING' -ForegroundColor Yellow
        }
        else {
            Write-Host 'RESULT: VERIFIED INPUT; APPLY V5' -ForegroundColor Yellow
        }
    }

    'Apply' {
        $result = Get-Classification $GameExe
        if ($result.State -eq 'v5') {
            Write-Host "Already correctly patched to v5. SHA-256: $V5Sha" -ForegroundColor Green
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
            Set-Bytes $newData $patch.Offset $patch.V5
            Write-Host ("Set 0x{0:x8}: {1} -> {2} ({3})" -f $patch.Offset, `
                (Get-Hex $patch.Original), (Get-Hex $patch.V5), $patch.Name)
        }

        $newSha = Get-BytesSha256 $newData
        if ($newSha -ne $V5Sha) { throw "Internal v5 hash mismatch: $newSha" }

        $temp = $GameExe + '.' + [Guid]::NewGuid().ToString('N') + '.tmp'
        try {
            Write-VerifiedFile $temp $newData $V5Sha
            Copy-Item -LiteralPath $temp -Destination $GameExe -Force
            $final = Get-Classification $GameExe
            if ($final.State -ne 'v5') { throw 'Final v5 verification failed.' }
        }
        finally {
            Remove-Item -LiteralPath $temp -Force -ErrorAction SilentlyContinue
        }

        Write-Host 'RESULT: V5 OFFLINE LOAD PATCH APPLIED AND FULLY VERIFIED' -ForegroundColor Green
        Write-Host "SHA-256: $V5Sha"
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
