<#
    preflight_ck2_mj.ps1 — one-shot state report for the CK2 Monarch's Journey test install.

    Read-only. Does not patch, inject, launch, or modify anything.

    It answers, in one run:
      * which CK2game*.exe files exist and EXACTLY which patch level each one is
      * whether the gfx\monarchs payload is present and correct
      * where the REAL Documents\Paradox Interactive\Crusader Kings II tree is
      * which saves exist, with their bronzeman / special_event / date metadata
      * what the local feat-progress cache currently contains

    Usage:
        powershell -ExecutionPolicy Bypass -File .\preflight_ck2_mj.ps1
        powershell -ExecutionPolicy Bypass -File .\preflight_ck2_mj.ps1 -GameRoot 'D:\CK2'
#>

param(
    [string]$GameRoot = 'C:\Users\UZWERG\Desktop\SteamCrusader'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Continue'

# ---------------------------------------------------------------- known hashes
# From 03_analysis/MASTER_ARTIFACT_TABLE.md and BANNED_ARTIFACTS.md.
$KnownExe = @{
    '656f4f482ed698958e1108938f7e5baff5b5dd31b3b310a7ea51386faca635d8' = 'STOCK May-2020 3.3.3 (unpatched)'
    '854853207ac46aafa6dec82160d66ab69b1097e67199a861cd547a732483370c' = 'V1 branch-only experiment (superseded)'
    '1a481a4adabf2bc1091cffcb19691e919e4c49a8157dad5d259081d8cbca9175' = 'V2 loader redirect (superseded)'
    'e91a5f4693ca3b747d7340fda71ed66b3593e2f98af14c37e6086b0d76fb13ca' = 'V3 UI gates (superseded)'
    'f2967f6f2c5b8b7d49dec2f7066139ace321cca19480f5c57d3ca8d576259b30' = 'V4 offline challenges (superseded)'
    '29556549fb5fc657f2966949b6a5b59c9b89b707f954adca4868cfd3d90b1535' = 'V5 save validator + tooltip (safe rollback target)'
    'f5b7dfd6e23b63f6353bb74f89493af0bd3db909e2d09961a543c773668530b0' = 'V6 CURRENT BASELINE (runtime-proven)'
    'a6cb92b8eda36c775751eb2af8c27a2509c5b9cee84872ef9e5fd6afd3cb18ff' = 'BANNED "V6" trampoline - corrupts saves, DO NOT RUN'
    '0074af707665bb152d3592d8ba9320ea81e79e6f58edc218e22aa069b353aeb8' = 'Abandoned "V7" feat-update candidate (premise disproven)'
}
$GoodExe     = 'f5b7dfd6e23b63f6353bb74f89493af0bd3db909e2d09961a543c773668530b0'
$BannedExe   = @(
    'a6cb92b8eda36c775751eb2af8c27a2509c5b9cee84872ef9e5fd6afd3cb18ff'
)
$GoodPayload = 'fc6ec025b782c811636a0efb65a7b3f192f09fffd0ff6ca8051ef8bc6113db4e'

# ---------------------------------------------------------------- helpers
function Write-Head([string]$Text) {
    Write-Host ''
    Write-Host ('=' * 74) -ForegroundColor DarkGray
    Write-Host $Text -ForegroundColor Cyan
    Write-Host ('=' * 74) -ForegroundColor DarkGray
}

function Get-Sha([string]$Path) {
    try { return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant() }
    catch { return $null }
}

$script:Problems = New-Object System.Collections.ArrayList
function Add-Problem([string]$Text) { [void]$script:Problems.Add($Text) }

# ---------------------------------------------------------------- 1. game root
Write-Head '1. GAME ROOT'
if (-not (Test-Path -LiteralPath $GameRoot -PathType Container)) {
    Write-Host "NOT FOUND: $GameRoot" -ForegroundColor Red
    Write-Host 'Re-run with -GameRoot pointing at your CK2 folder.' -ForegroundColor Yellow
    return
}
Write-Host "Path: $GameRoot" -ForegroundColor Green

# ---------------------------------------------------------------- 2. executables
Write-Head '2. EXECUTABLES  (all patch states are 24,753,368 bytes - only the hash tells them apart)'
$exes = @(Get-ChildItem -LiteralPath $GameRoot -Filter 'CK2game*.exe' -File -ErrorAction SilentlyContinue)
if ($exes.Count -eq 0) {
    Write-Host 'No CK2game*.exe found.' -ForegroundColor Red
    Add-Problem 'No CK2game*.exe in the game root.'
}
foreach ($exe in $exes) {
    $sha = Get-Sha $exe.FullName
    $isLaunched = ($exe.Name -eq 'CK2game.exe')
    $label = if ($null -ne $sha -and $KnownExe.ContainsKey($sha)) { $KnownExe[$sha] } else { 'UNKNOWN / not in the registry' }

    Write-Host ''
    Write-Host ("  {0}{1}" -f $exe.Name, $(if ($isLaunched) { '   <-- this is the one Windows launches by default' } else { '' }))
    Write-Host ("    size    : {0:N0} bytes" -f $exe.Length)
    Write-Host  "    sha256  : $sha"

    $colour = 'Yellow'
    if ($sha -eq $GoodExe)        { $colour = 'Green' }
    elseif ($BannedExe -contains $sha) { $colour = 'Red' }
    Write-Host  "    state   : $label" -ForegroundColor $colour

    if ($isLaunched -and $sha -ne $GoodExe) {
        Add-Problem ("CK2game.exe is NOT the V6 baseline - it is: $label")
    }
    if ($BannedExe -contains $sha) {
        Add-Problem ("$($exe.Name) is a BANNED build. Do not run it.")
    }
}
if ($exes.Count -gt 1) {
    Write-Host ''
    Write-Host '  NOTE: more than one CK2game*.exe is present. Windows runs CK2game.exe;' -ForegroundColor Yellow
    Write-Host '        a patched copy sitting beside it under another name is NOT used.' -ForegroundColor Yellow
}

# ---------------------------------------------------------------- 3. payload
Write-Head '3. MONARCH PAYLOAD'
$payload = Join-Path $GameRoot 'gfx\monarchs'
if (Test-Path -LiteralPath $payload -PathType Leaf) {
    $sha = Get-Sha $payload
    $item = Get-Item -LiteralPath $payload
    Write-Host ("  gfx\monarchs : {0:N0} bytes" -f $item.Length)
    Write-Host "  sha256       : $sha"
    if ($sha -eq $GoodPayload) {
        Write-Host '  RESULT       : CORRECT (11 rulers / 33 challenges, 2030 expiry)' -ForegroundColor Green
    } else {
        Write-Host '  RESULT       : WRONG CONTENT' -ForegroundColor Red
        Add-Problem 'gfx\monarchs payload hash does not match the known-good payload.'
    }
} else {
    Write-Host '  gfx\monarchs : MISSING' -ForegroundColor Red
    Add-Problem 'gfx\monarchs payload is missing - Monarch''s Journey cannot load rulers.'
}

# ---------------------------------------------------------------- 4. user data
Write-Head '4. USER DATA TREE  (saves / logs / feat cache live here, NOT in the game folder)'

# Resolve the real Documents folder even when redirected, localised, or on OneDrive.
$docs = $null
try {
    $docs = [Environment]::GetFolderPath('MyDocuments')
} catch { }
if ([string]::IsNullOrWhiteSpace($docs)) { $docs = Join-Path $env:USERPROFILE 'Documents' }

$candidates = New-Object System.Collections.ArrayList
[void]$candidates.Add((Join-Path $docs 'Paradox Interactive\Crusader Kings II'))
[void]$candidates.Add((Join-Path $env:USERPROFILE 'Documents\Paradox Interactive\Crusader Kings II'))
if ($env:OneDrive) {
    [void]$candidates.Add((Join-Path $env:OneDrive 'Documents\Paradox Interactive\Crusader Kings II'))
}
[void]$candidates.Add((Join-Path $GameRoot 'save games'))

$userRoot = $null
foreach ($c in ($candidates | Select-Object -Unique)) {
    if (Test-Path -LiteralPath $c -PathType Container) { $userRoot = $c; break }
}

Write-Host "  Documents resolves to : $docs"
if ($userRoot) {
    Write-Host "  CK2 user folder       : $userRoot" -ForegroundColor Green
} else {
    Write-Host '  CK2 user folder       : NOT FOUND' -ForegroundColor Red
    Write-Host '  Searched:' -ForegroundColor DarkGray
    foreach ($c in ($candidates | Select-Object -Unique)) { Write-Host "    $c" -ForegroundColor DarkGray }
    Add-Problem 'Could not locate the CK2 user data folder - saves and feat cache cannot be checked.'
}

# ---------------------------------------------------------------- 5. saves
if ($userRoot) {
    Write-Head '5. SAVES'
    $saveDir = Join-Path $userRoot 'save games'
    if (-not (Test-Path -LiteralPath $saveDir -PathType Container)) { $saveDir = Join-Path $GameRoot 'save games' }

    if (Test-Path -LiteralPath $saveDir -PathType Container) {
        Write-Host "  Folder: $saveDir"
        $saves = @(Get-ChildItem -LiteralPath $saveDir -Filter '*.ck2' -File -ErrorAction SilentlyContinue |
                   Sort-Object LastWriteTime -Descending)
        if ($saves.Count -eq 0) { Write-Host '  (no .ck2 saves)' -ForegroundColor Yellow }

        foreach ($s in ($saves | Select-Object -First 12)) {
            Write-Host ''
            Write-Host ("  {0}" -f $s.Name) -ForegroundColor White
            Write-Host ("    modified : {0}   size: {1:N0} bytes" -f $s.LastWriteTime, $s.Length)

            # .ck2 saves are ZIP archives; the 'meta' entry is plain text.
            $meta = $null
            try {
                Add-Type -AssemblyName System.IO.Compression.FileSystem -ErrorAction SilentlyContinue
                $zip = [System.IO.Compression.ZipFile]::OpenRead($s.FullName)
                try {
                    $entry = $zip.Entries | Where-Object { $_.Name -eq 'meta' } | Select-Object -First 1
                    if ($entry) {
                        $reader = New-Object System.IO.StreamReader($entry.Open())
                        try { $meta = $reader.ReadToEnd() } finally { $reader.Dispose() }
                    }
                } finally { $zip.Dispose() }
            } catch { }

            if ($meta) {
                foreach ($key in @('date', 'bronzeman', 'ironman', 'special_event', 'player_name', 'version')) {
                    $m = [regex]::Match($meta, ('(?m)^\s*{0}\s*=\s*"?([^"\r\n]+)"?' -f [regex]::Escape($key)))
                    if ($m.Success) {
                        $val = $m.Groups[1].Value.Trim()
                        $col = 'Gray'
                        if ($key -eq 'bronzeman' -and $val -eq 'yes')     { $col = 'Green' }
                        if ($key -eq 'special_event' -and $val)           { $col = 'Green' }
                        Write-Host ("    {0,-14}: {1}" -f $key, $val) -ForegroundColor $col
                    }
                }
            } else {
                Write-Host '    (meta not readable - may be an uncompressed/text save)' -ForegroundColor DarkGray
            }
        }
    } else {
        Write-Host '  No save folder found.' -ForegroundColor Yellow
    }

    # ------------------------------------------------------------ 6. feat cache
    Write-Head '6. LOCAL FEAT-PROGRESS CACHE  (this is where peak challenge progress lives)'
    $cacheDir = Join-Path $userRoot 'cache'
    $found = $false
    foreach ($dir in @($cacheDir, (Join-Path $GameRoot 'cache'))) {
        if (Test-Path -LiteralPath $dir -PathType Container) {
            $files = @(Get-ChildItem -LiteralPath $dir -File -ErrorAction SilentlyContinue)
            foreach ($f in $files) {
                $head = ''
                try { $head = (Get-Content -LiteralPath $f.FullName -TotalCount 3 -ErrorAction Stop) -join ' ' } catch { }
                if ($head -match 'key=|user_id=') {
                    $found = $true
                    Write-Host ''
                    Write-Host ("  {0}   ({1})" -f $f.FullName, $f.LastWriteTime) -ForegroundColor Green
                    $nonZero = @()
                    foreach ($line in (Get-Content -LiteralPath $f.FullName -ErrorAction SilentlyContinue)) {
                        $mm = [regex]::Match($line, '^\s*([a-z0-9_]+)\s*=\s*(-?\d+)\s*$')
                        if ($mm.Success) {
                            $name = $mm.Groups[1].Value
                            $val  = [int64]$mm.Groups[2].Value
                            if ($val -ne 0 -and $name -notin @('key','id','user','user_id','category')) {
                                $nonZero += ('{0}={1}' -f $name, $val)
                            }
                        }
                    }
                    if ($nonZero.Count -gt 0) {
                        Write-Host ('    NON-ZERO FEATS: ' + ($nonZero -join ', ')) -ForegroundColor Green
                    } else {
                        Write-Host '    All feat counters are 0.' -ForegroundColor Yellow
                    }
                }
            }
        }
    }
    if (-not $found) {
        Write-Host '  No feat cache file found yet (it appears after challenge progress is made).' -ForegroundColor Yellow
    }
}

# ---------------------------------------------------------------- 7. verdict
Write-Head '7. VERDICT'
if ($script:Problems.Count -eq 0) {
    Write-Host '  No blocking problems detected.' -ForegroundColor Green
    Write-Host '  If feats still read 0, the loaded SAVE is the suspect: a save that was ever' -ForegroundColor Gray
    Write-Host '  played while challenges were disabled can never earn feats again.' -ForegroundColor Gray
    Write-Host '  Test with ONE FRESH Bronzeman campaign before drawing conclusions.' -ForegroundColor Gray
} else {
    foreach ($p in $script:Problems) { Write-Host "  [!] $p" -ForegroundColor Red }
}
Write-Host ''
Write-Host '  Reminder: never run wipe_feats. Keep the game offline for these tests.' -ForegroundColor DarkGray
Write-Host ''
