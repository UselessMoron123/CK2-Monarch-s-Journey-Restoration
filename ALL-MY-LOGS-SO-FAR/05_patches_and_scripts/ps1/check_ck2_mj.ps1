param(
    [Parameter(Mandatory=$true)]
    [string]$GameExe
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ExpectedSize = 24753368L
$OriginalSha = '656f4f482ed698958e1108938f7e5baff5b5dd31b3b310a7ea51386faca635d8'
$BranchOnlySha = '854853207ac46aafa6dec82160d66ab69b1097e67199a861cd547a732483370c'
$V2Sha = '1a481a4adabf2bc1091cffcb19691e919e4c49a8157dad5d259081d8cbca9175'
$ExpectedPayload = 'fc6ec025b782c811636a0efb65a7b3f192f09fffd0ff6ca8051ef8bc6113db4e'

$Patches = @(
    [pscustomobject]@{ Offset=0x00d73d02L; Original=[byte[]](0x74,0x2b); Patched=[byte[]](0xeb,0x2b) },
    [pscustomobject]@{ Offset=0x00d73e1aL; Original=[byte[]](0xba,0x23,0x36,0x00); Patched=[byte[]](0x21,0xfc,0x32,0x00) }
)

function Get-BytesSha256([byte[]]$Data) {
    $sha = [Security.Cryptography.SHA256]::Create()
    try {
        $hash = $sha.ComputeHash($Data)
        return (($hash | ForEach-Object { $_.ToString('x2') }) -join '')
    }
    finally { $sha.Dispose() }
}

function Test-Bytes([byte[]]$Data, [long]$Offset, [byte[]]$Expected) {
    for ($i=0; $i -lt $Expected.Length; $i++) {
        if ($Data[$Offset+$i] -ne $Expected[$i]) { return $false }
    }
    return $true
}

function Show-FileCheck([string]$Label, [string]$Path, [string]$ExpectedSha) {
    Write-Host ''
    Write-Host $Label
    Write-Host "  Path: $Path"
    if (Test-Path -LiteralPath $Path -PathType Leaf) {
        $item = Get-Item -LiteralPath $Path
        $sha = (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()
        Write-Host '  Found: YES'
        Write-Host "  Size: $($item.Length) bytes"
        Write-Host "  SHA-256: $sha"
        if ($sha -eq $ExpectedSha) {
            Write-Host '  RESULT: CORRECT' -ForegroundColor Green
        }
        else {
            Write-Host '  RESULT: WRONG CONTENT' -ForegroundColor Red
        }
    }
    else {
        Write-Host '  Found: NO' -ForegroundColor Yellow
        $parent = Split-Path -Parent $Path
        if (Test-Path -LiteralPath $parent -PathType Container) {
            $leaf = Split-Path -Leaf $Path
            $similar = @(Get-ChildItem -LiteralPath $parent -Filter ($leaf + '*') -File -ErrorAction SilentlyContinue)
            foreach ($file in $similar) {
                Write-Host "  Similar filename found: $($file.Name)" -ForegroundColor Yellow
            }
        }
    }
}

try {
    $GameExe = [IO.Path]::GetFullPath($GameExe)
    if (-not (Test-Path -LiteralPath $GameExe -PathType Leaf)) { throw "File not found: $GameExe" }
    $item = Get-Item -LiteralPath $GameExe
    $actualSha = (Get-FileHash -LiteralPath $GameExe -Algorithm SHA256).Hash.ToLowerInvariant()
    $version = [Diagnostics.FileVersionInfo]::GetVersionInfo($GameExe)

    Write-Host '============================================================'
    Write-Host " CK2 MONARCH'S JOURNEY - V2 READ-ONLY CHECK"
    Write-Host '============================================================'
    Write-Host "Executable: $GameExe"
    Write-Host "File version: $($version.FileVersion)"
    Write-Host "Size: $($item.Length) bytes"
    Write-Host "SHA-256: $actualSha"
    Write-Host ''

    $state = 'UNKNOWN'
    if ($item.Length -ne $ExpectedSize) {
        $state = 'WRONG BUILD'
        Write-Host 'EXE RESULT: WRONG BUILD/SIZE' -ForegroundColor Red
    }
    else {
        $data = [IO.File]::ReadAllBytes($GameExe)
        $which = @()
        foreach ($patch in $Patches) {
            if (Test-Bytes $data $patch.Offset $patch.Original) {
                $which += 'original'
            }
            elseif (Test-Bytes $data $patch.Offset $patch.Patched) {
                $which += 'patched'
                [Array]::Copy($patch.Original, 0, $data, $patch.Offset, $patch.Original.Length)
            }
            else {
                throw ("Unrecognized bytes at 0x{0:x8}" -f $patch.Offset)
            }
        }
        $normalized = Get-BytesSha256 $data
        if ($normalized -ne $OriginalSha) { throw "Other bytes differ; normalized SHA-256: $normalized" }

        if ($which[0] -eq 'original' -and $which[1] -eq 'original' -and $actualSha -eq $OriginalSha) {
            $state = 'ORIGINAL - NOT PATCHED'
            Write-Host 'EXE RESULT: EXACT MAY ORIGINAL; V2 NOT APPLIED' -ForegroundColor Yellow
        }
        elseif ($which[0] -eq 'patched' -and $which[1] -eq 'original' -and $actualSha -eq $BranchOnlySha) {
            $state = 'EARLIER INCOMPLETE PATCH'
            Write-Host 'EXE RESULT: EARLIER BRANCH-ONLY PATCH; APPLY V2' -ForegroundColor Yellow
        }
        elseif ($which[0] -eq 'patched' -and $which[1] -eq 'patched' -and $actualSha -eq $V2Sha) {
            $state = 'CORRECT V2 PATCH'
            Write-Host 'EXE RESULT: CORRECT V2 PATCH' -ForegroundColor Green
        }
        else {
            $state = 'VALID PARTIAL STATE'
            Write-Host 'EXE RESULT: VALID BUT INCOMPLETE PATCH COMBINATION; APPLY V2' -ForegroundColor Yellow
        }
    }

    $gameFolder = Split-Path -Parent $GameExe
    $v2Payload = Join-Path $gameFolder 'gfx\monarchs'
    Show-FileCheck 'V2 PAYLOAD CHECK' $v2Payload $ExpectedPayload

    $oldGamePayload = Join-Path $gameFolder 'common\monarchs_journey\test.dds'
    if (Test-Path -LiteralPath $oldGamePayload -PathType Leaf) {
        Write-Host ''
        Write-Host "Old test payload still exists at: $oldGamePayload"
        Write-Host 'That location is not read by the Windows local loader.' -ForegroundColor Yellow
    }

    Write-Host ''
    Write-Host '============================================================'
    Write-Host "SUMMARY: $state"
    if ($state -eq 'CORRECT V2 PATCH') {
        Write-Host 'Required payload: <game folder>\gfx\monarchs'
    }
    Write-Host 'This checker changed nothing.'
    Write-Host '============================================================'
}
catch {
    Write-Host "CHECK FAILED: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
