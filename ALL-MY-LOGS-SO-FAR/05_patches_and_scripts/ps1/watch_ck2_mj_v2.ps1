<#
    watch_ck2_mj_v2.ps1 — corrected live observer for the CK2 MJ test install.

    External observer only: it does not inject into CK2, patch it, or touch memory.
    Stop with Ctrl+C.

    Fixes over v1 (which captured 15,526 inventory lines and then nothing at all):

      1. v1 built its watch list ONCE and dropped every folder that did not exist
         at that instant. 'save games', 'cache' and the Paradox 'logs' folder are
         created/populated after launch, so they were dropped permanently - the
         three things worth watching were never watched. v2 re-resolves the paths
         on every pass and starts watching them the moment they appear.

      2. v1 used "$env:USERPROFILE\Documents", which is wrong on machines with a
         redirected, localised or OneDrive-backed Documents folder. v2 asks
         Windows for the real path and probes OneDrive too.

      3. v1 recursively stat'ed ~15,500 game files every second, which is far too
         slow to catch anything. v2 takes a silent baseline of the static game
         tree, then only reports CHANGES there, while polling the small,
         interesting folders closely.

    Usage:
        Set-ExecutionPolicy -Scope Process Bypass
        .\watch_ck2_mj_v2.ps1
        .\watch_ck2_mj_v2.ps1 -GameRoot 'D:\CK2' -Output "$PWD\ck2_observer.log"
#>

param(
    [string]$GameRoot = 'C:\Users\UZWERG\Desktop\SteamCrusader',
    [string]$Output   = "$PWD\ck2_live_observer_v2.log",
    [int]   $Seconds  = 0,
    [int]   $IntervalMs = 700
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'SilentlyContinue'

# ---------------------------------------------------------------- logging
New-Item -ItemType File -Force -Path $Output | Out-Null

function Write-Obs {
    param([string]$Message, [string]$Colour = 'Gray')
    $line = '[{0}] {1}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff'), $Message
    Add-Content -LiteralPath $Output -Value $line -Encoding UTF8
    Write-Host $line -ForegroundColor $Colour
}

# ---------------------------------------------------------------- path resolution
function Get-UserRoot {
    $docs = $null
    try { $docs = [Environment]::GetFolderPath('MyDocuments') } catch { }
    if ([string]::IsNullOrWhiteSpace($docs)) { $docs = Join-Path $env:USERPROFILE 'Documents' }

    $cands = @(
        (Join-Path $docs 'Paradox Interactive\Crusader Kings II'),
        (Join-Path $env:USERPROFILE 'Documents\Paradox Interactive\Crusader Kings II')
    )
    if ($env:OneDrive) {
        $cands += (Join-Path $env:OneDrive 'Documents\Paradox Interactive\Crusader Kings II')
    }
    foreach ($c in ($cands | Select-Object -Unique)) {
        if (Test-Path -LiteralPath $c -PathType Container) { return $c }
    }
    return $null
}

# Folders that matter, re-resolved every pass so late-created ones get picked up.
function Get-HotPaths {
    $hot = New-Object System.Collections.ArrayList
    $userRoot = Get-UserRoot
    if ($userRoot) {
        foreach ($sub in @('save games', 'cache', 'logs')) {
            $p = Join-Path $userRoot $sub
            if (Test-Path -LiteralPath $p -PathType Container) { [void]$hot.Add($p) }
        }
    }
    foreach ($sub in @('save games', 'cache', 'logs', 'gfx')) {
        $p = Join-Path $GameRoot $sub
        if (Test-Path -LiteralPath $p -PathType Container) { [void]$hot.Add($p) }
    }
    return ($hot | Select-Object -Unique)
}

# ---------------------------------------------------------------- startup
Write-Obs "Observer v2 started. GameRoot=$GameRoot" 'Cyan'
$userRoot = Get-UserRoot
if ($userRoot) { Write-Obs "User data root: $userRoot" 'Green' }
else {
    Write-Obs 'WARNING: CK2 user data folder not found yet - will keep retrying.' 'Yellow'
}

# Silent baseline of the big static game tree: we only want CHANGES from it.
Write-Obs 'Taking baseline of the game folder (silent, a few seconds)...' 'DarkGray'
$baseline = @{}
Get-ChildItem -LiteralPath $GameRoot -Recurse -File -ErrorAction SilentlyContinue | ForEach-Object {
    $baseline[$_.FullName] = '{0}:{1}' -f $_.Length, $_.LastWriteTimeUtc.Ticks
}
Write-Obs ("Baseline complete: {0} files. Only changes will be reported from here." -f $baseline.Count) 'DarkGray'

# Root-level executables get hashed once so the ACTUAL launched binary is known.
foreach ($exe in @(Get-ChildItem -LiteralPath $GameRoot -Filter 'CK2game*.exe' -File -ErrorAction SilentlyContinue)) {
    $sha = (Get-FileHash -LiteralPath $exe.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
    $tag = switch ($sha) {
        'f5b7dfd6e23b63f6353bb74f89493af0bd3db909e2d09961a543c773668530b0' { 'V6 baseline (good)' }
        '29556549fb5fc657f2966949b6a5b59c9b89b707f954adca4868cfd3d90b1535' { 'V5' }
        '656f4f482ed698958e1108938f7e5baff5b5dd31b3b310a7ea51386faca635d8' { 'STOCK unpatched' }
        'a6cb92b8eda36c775751eb2af8c27a2509c5b9cee84872ef9e5fd6afd3cb18ff' { 'BANNED trampoline' }
        default { 'unknown build' }
    }
    Write-Obs ("EXE {0}  sha256={1}  [{2}]" -f $exe.Name, $sha, $tag) 'Cyan'
}

$known    = @{}
$hotSeen  = @{}
$procSeen = $null
$started  = Get-Date
$logTails = @{}

# ---------------------------------------------------------------- main loop
while ($true) {

    # --- process watch -------------------------------------------------
    $proc = Get-Process -Name 'CK2game' -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($proc) {
        if ($null -eq $procSeen) {
            $procSeen = $proc.Id
            $path = ''
            try { $path = $proc.Path } catch { }
            Write-Obs "PROCESS START pid=$($proc.Id) path=$path" 'Green'
        }
    } elseif ($null -ne $procSeen) {
        Write-Obs "PROCESS EXIT pid=$procSeen" 'Yellow'
        $procSeen = $null
    }

    # --- hot folders: saves, cache, logs -------------------------------
    foreach ($root in (Get-HotPaths)) {
        if (-not $hotSeen.ContainsKey($root)) {
            $hotSeen[$root] = $true
            Write-Obs "NOW WATCHING: $root" 'Cyan'
        }
        foreach ($f in @(Get-ChildItem -LiteralPath $root -Recurse -File -ErrorAction SilentlyContinue)) {
            $key = $f.FullName
            $sig = '{0}:{1}' -f $f.Length, $f.LastWriteTimeUtc.Ticks
            if (-not $known.ContainsKey($key)) {
                $known[$key] = $sig
                Write-Obs ("FILE NEW      size={0,-9} {1}" -f $f.Length, $key) 'Green'
            } elseif ($known[$key] -ne $sig) {
                $known[$key] = $sig
                Write-Obs ("FILE CHANGED  size={0,-9} {1}" -f $f.Length, $key) 'Green'
            } else {
                continue
            }

            # Feat cache: dump the counters that are not zero.
            $head = ''
            try { $head = (Get-Content -LiteralPath $key -TotalCount 3 -ErrorAction Stop) -join ' ' } catch { }
            if ($head -match 'key=|user_id=') {
                $nz = @()
                foreach ($line in (Get-Content -LiteralPath $key -ErrorAction SilentlyContinue)) {
                    $m = [regex]::Match($line, '^\s*([a-z0-9_]+)\s*=\s*(-?\d+)\s*$')
                    if ($m.Success) {
                        $n = $m.Groups[1].Value; $v = [int64]$m.Groups[2].Value
                        if ($v -ne 0 -and $n -notin @('key','id','user','user_id','category')) { $nz += "$n=$v" }
                    }
                }
                if ($nz.Count -gt 0) { Write-Obs ('    FEATS: ' + ($nz -join ', ')) 'Magenta' }
                else                 { Write-Obs '    FEATS: all zero' 'Yellow' }
            }
        }
    }

    # --- paradox logs: stream new lines --------------------------------
    $ur = Get-UserRoot
    if ($ur) {
        $logDir = Join-Path $ur 'logs'
        foreach ($name in @('game.log', 'error.log', 'message.log')) {
            $lp = Join-Path $logDir $name
            if (Test-Path -LiteralPath $lp -PathType Leaf) {
                $lines = @(Get-Content -LiteralPath $lp -ErrorAction SilentlyContinue)
                $prev  = 0
                if ($logTails.ContainsKey($lp)) { $prev = [int]$logTails[$lp] }
                if ($lines.Count -gt $prev) {
                    foreach ($l in $lines[$prev..($lines.Count - 1)]) {
                        if ($l -and $l.Trim()) {
                            $col = 'Gray'
                            if ($l -match 'Congratulations|rank of|challenge|Bronze|feat') { $col = 'Magenta' }
                            Write-Obs ("  {0}: {1}" -f $name, $l.TrimEnd()) $col
                        }
                    }
                }
                $logTails[$lp] = $lines.Count
            }
        }
    }

    # --- static game tree: changes only --------------------------------
    foreach ($f in @(Get-ChildItem -LiteralPath $GameRoot -File -ErrorAction SilentlyContinue)) {
        $key = $f.FullName
        $sig = '{0}:{1}' -f $f.Length, $f.LastWriteTimeUtc.Ticks
        if ($baseline.ContainsKey($key)) {
            if ($baseline[$key] -ne $sig) {
                $baseline[$key] = $sig
                Write-Obs ("GAMEFILE CHANGED  {0}" -f $key) 'Yellow'
            }
        } else {
            $baseline[$key] = $sig
            Write-Obs ("GAMEFILE NEW      {0}" -f $key) 'Yellow'
        }
    }

    if ($Seconds -gt 0 -and ((Get-Date) - $started).TotalSeconds -ge $Seconds) { break }
    Start-Sleep -Milliseconds $IntervalMs
}

Write-Obs 'Observer stopped.' 'Cyan'
