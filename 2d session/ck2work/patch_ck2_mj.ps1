<#
.SYNOPSIS
  Backup-safe patcher for CK2 3.3.3 (May 2020) Windows - Monarch's Journey local mode.

.DESCRIPTION
  Patches a COPY of CK2game333.exe to force the offline "null" GameSparks stub
  and rename its local-cache file so the static monarchs_journey payload is
  read from the user's Documents folder. For personal restoration of the
  retired Monarch's Journey interface only; does not redistribute a binary.

  Expected ORIGINAL SHA-256 (May 2020 build):
    656f4f482ed698958e1108938f7e5baff5b5dd31b3b310a7ea51386faca635d8

.PARAMETER Action
  apply, revert, or verify.

.PARAMETER Path
  Path to CK2game333.exe (or your copy).

.EXAMPLE
  .\patch_ck2_mj.ps1 apply  .\CK2game333.exe
  .\patch_ck2_mj.ps1 verify .\CK2game333.exe
  .\patch_ck2_mj.ps1 revert .\CK2game333.exe
#>
param(
    [Parameter(Mandatory=$true)][ValidateSet('apply','revert','verify')]
    [string]$Action,
    [Parameter(Mandatory=$true)][string]$Path
)

$ErrorActionPreference = 'Stop'

$OrigSha  = '656f4f482ed698958e1108938f7e5baff5b5dd31b3b310a7ea51386faca635d8'
$OrigSize = 24753368

# Each patch: offset, original bytes, patched bytes, description.
$Patches = @(
    [pscustomobject]@{ Off=0x00d73d02; Orig=[byte[]](0x74,0x2b); New=[byte[]](0xeb,0x2b);
                       Desc='factory: je -> jmp (always select local/null GameSparks stub)' },
    [pscustomobject]@{ Off=0x010d55d8; Orig=[byte[]](0x74,0x65,0x73,0x74,0x2e,0x64,0x64,0x73,0x00);
                                            New =[byte[]](0x6d,0x6f,0x6e,0x61,0x72,0x63,0x68,0x73,0x2e,0x00);
                       Desc='rename local cache file test.dds -> monarchs.' }
)

function Get-Sha256([string]$p) {
    $h = [System.Security.Cryptography.SHA256]::Create()
    try {
        $fs = [System.IO.File]::OpenRead($p)
        try { ([BitConverter]::ToString($h.ComputeHash($fs))).Replace('-','').ToLowerInvariant() }
        finally { $fs.Close() }
    } finally { $h.Dispose() }
}

function Read-Bytes([string]$p,[long]$off,[int]$n) {
    $fs = [System.IO.File]::Open($p,[System.IO.FileMode]::Open,[System.IO.FileAccess]::Read)
    try { $fs.Seek($off,[System.IO.SeekOrigin]::Begin) | Out-Null; $b=New-Object byte[] $n; $fs.Read($b,0,$n)|Out-Null; $b }
    finally { $fs.Close() }
}

function Write-Bytes([string]$p,[long]$off,[byte[]]$b) {
    $fs = [System.IO.File]::Open($p,[System.IO.FileMode]::Open,[System.IO.FileAccess]::ReadWrite)
    try { $fs.Seek($off,[System.IO.SeekOrigin]::Begin)|Out-Null; $fs.Write($b,0,$b.Length) }
    finally { $fs.Close() }
}

function Test-Identity([string]$p) {
    if (-not (Test-Path -LiteralPath $p)) { throw "file not found: $p" }
    $fi = Get-Item -LiteralPath $p
    if ($fi.Length -ne $OrigSize) {
        throw "size mismatch: got $($fi.Length), expected $OrigSize. Only the exact May 2020 CK2game333.exe is supported."
    }
    $d = Get-Sha256 $p
    if ($d -ne $OrigSha) {
        throw "SHA-256 mismatch:`n  got      $d`n  expected $OrigSha`nRefusing to patch an unknown binary."
    }
    return $d
}

function Same([byte[]]$a,[byte[]]$b) {
    if ($a.Length -ne $b.Length) { return $false }
    for ($i=0;$i -lt $a.Length;$i++){ if ($a[$i] -ne $b[$i]){ return $false } }
    return $true
}

switch ($Action) {
    'apply' {
        $d = Test-Identity $Path
        foreach ($pt in $Patches) {
            $got = Read-Bytes $Path $pt.Off $pt.Orig.Length
            if (-not (Same $got $pt.Orig)) {
                throw ("unexpected bytes at 0x{0:x}: got {1}, expected {2}`n  ({3})" -f `
                       $pt.Off,([BitConverter]::ToString($got)).Replace('-',''),([BitConverter]::ToString($pt.Orig)).Replace('-',''),$pt.Desc)
            }
        }
        $bak = "$Path.bak"
        if (Test-Path -LiteralPath $bak) { throw "backup already exists: $bak (remove it manually to re-patch)" }
        Copy-Item -LiteralPath $Path -Destination $bak
        Write-Host "backup created: $bak"
        foreach ($pt in $Patches) {
            Write-Bytes $Path $pt.Off $pt.New
            Write-Host ("  patched 0x{0:x8}: {1} -> {2}  ({3})" -f `
                   $pt.Off,([BitConverter]::ToString($pt.Orig)).Replace('-',''),([BitConverter]::ToString($pt.New)).Replace('-',''),$pt.Desc)
        }
        $new = Get-Sha256 $Path
        Write-Host ""
        Write-Host "patch applied."
        Write-Host "  original SHA-256: $d"
        Write-Host "  patched  SHA-256: $new"
        Write-Host ""
        Write-Host "Now place the JSON payload (the Linux monarchs.txt content) at:"
        Write-Host '  %USERPROFILE%\Documents\Paradox Interactive\Crusader Kings II\monarchs.'
        Write-Host "Use event_time_end = 1893499200 (2030-01-01), NOT 2147483647."
    }
    'revert' {
        $bak = "$Path.bak"
        if (-not (Test-Path -LiteralPath $bak)) { throw "backup not found: $bak" }
        $d = Get-Sha256 $bak
        if ($d -ne $OrigSha) { throw "backup SHA-256 does not match the known original; refusing to restore:`n  $d" }
        Copy-Item -LiteralPath $bak -Destination $Path -Force
        Write-Host "reverted $Path from backup."
        Write-Host ("  SHA-256: " + (Get-Sha256 $Path))
    }
    'verify' {
        if (-not (Test-Path -LiteralPath $Path)) { throw "file not found: $Path" }
        $fi = Get-Item -LiteralPath $Path
        $d = Get-Sha256 $Path
        Write-Host "file:   $Path"
        Write-Host "size:   $($fi.Length)"
        Write-Host "sha256: $d"
        if ($d -eq $OrigSha) { Write-Host "status: ORIGINAL (unpatched May 2020 build)"; return }
        $all = $true
        foreach ($pt in $Patches) {
            $got = Read-Bytes $Path $pt.Off $pt.New.Length
            if (Same $got $pt.New) {
                Write-Host ("  [PATCHED] 0x{0:x8}: {1}  ({2})" -f $pt.Off,([BitConverter]::ToString($pt.New)).Replace('-',''),$pt.Desc)
            } else {
                $all = $false
                Write-Host ("  [UNKNOWN] 0x{0:x8}: got {1}  ({2})" -f $pt.Off,([BitConverter]::ToString($got)).Replace('-',''),$pt.Desc)
            }
        }
        if ($all) { Write-Host "status: PATCHED (Monarch's Journey local mode)" }
        else      { Write-Host "status: UNKNOWN (not the original and not a clean patch)" }
    }
}
