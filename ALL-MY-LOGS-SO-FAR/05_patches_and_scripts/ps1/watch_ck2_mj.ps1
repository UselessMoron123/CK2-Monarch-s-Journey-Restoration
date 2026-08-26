param(
    [string]$GameRoot = "C:\Users\UZWERG\Desktop\SteamCrusader",
    [string]$Output = "$PSScriptRoot\ck2_live_observer.log",
    [int]$Seconds = 0
)

# External observer only: this does not inject into CK2 or modify memory.
# Stop with Ctrl+C. -Seconds 0 means run until stopped.
$ErrorActionPreference = 'SilentlyContinue'
$logRoot = Join-Path $env:USERPROFILE 'Documents\Paradox Interactive\Crusader Kings II\logs'
$saveRoot = Join-Path $GameRoot 'save games'
$cacheRoot = Join-Path $GameRoot 'cache'
$paths = @($GameRoot, $logRoot, $saveRoot, $cacheRoot) | Where-Object { $_ -and (Test-Path $_) } | Select-Object -Unique

function Write-Obs([string]$Message) {
    $line = "[{0}] {1}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff'), $Message
    Add-Content -LiteralPath $Output -Value $line -Encoding UTF8
    Write-Host $line
}

New-Item -ItemType File -Force -Path $Output | Out-Null
Write-Obs "Observer started. GameRoot=$GameRoot"
Write-Obs "Watching: $($paths -join '; ')"
$known = @{}
$lastGameLog = ''
$started = Get-Date

while ($true) {
    $proc = Get-Process -Name 'CK2game' -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($proc) {
        if (-not $known.ContainsKey('_process')) {
            $known['_process'] = $proc.Id
            try { Write-Obs "PROCESS START pid=$($proc.Id) path=$($proc.Path)" } catch { Write-Obs "PROCESS START pid=$($proc.Id)" }
        }
    } elseif ($known.ContainsKey('_process')) {
        Write-Obs "PROCESS EXIT pid=$($known['_process'])"
        $known.Remove('_process')
    }

    foreach ($root in $paths) {
        Get-ChildItem -LiteralPath $root -Recurse -File -ErrorAction SilentlyContinue | ForEach-Object {
            $key = $_.FullName
            $sig = "$($_.Length):$($_.LastWriteTimeUtc.Ticks)"
            if (-not $known.ContainsKey($key)) {
                $known[$key] = $sig
                Write-Obs "FILE NEW size=$($_.Length) $key"
            } elseif ($known[$key] -ne $sig) {
                $old = $known[$key]
                $known[$key] = $sig
                Write-Obs "FILE CHANGED old=$old new=$sig $key"
                if ($_.Name -match 'game.*\.log$|error.*\.log$') {
                    try {
                        $tail = Get-Content -LiteralPath $_.FullName -Tail 8 -ErrorAction Stop
                        foreach ($l in $tail) { Write-Obs "LOG $($_.Name): $l" }
                    } catch {}
                }
            }
        }
    }
    if ($Seconds -gt 0 -and ((Get-Date) - $started).TotalSeconds -ge $Seconds) { break }
    Start-Sleep -Milliseconds 1000
}
Write-Obs 'Observer stopped.'
