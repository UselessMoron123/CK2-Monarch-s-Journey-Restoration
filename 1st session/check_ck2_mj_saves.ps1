# Read-only CK2 save diagnostic. It does not edit, rename, load, or delete saves.
$ErrorActionPreference = 'Stop'

$documents = [Environment]::GetFolderPath('MyDocuments')
$saveDir = Join-Path $documents 'Paradox Interactive\Crusader Kings II\save games'
$desktop = [Environment]::GetFolderPath('Desktop')
$reportPath = Join-Path $desktop 'CK2_MJ_SAVE_REPORT.txt'
$lines = New-Object System.Collections.Generic.List[string]
$utf8Bom = New-Object System.Text.UTF8Encoding($true)

function Add-Line([string]$s = '') { $script:lines.Add($s) }
function Hex-Bytes([byte[]]$bytes, [int]$count) {
    $n = [Math]::Min($count, $bytes.Length)
    if ($n -le 0) { return '(empty)' }
    return (($bytes[0..($n - 1)] | ForEach-Object { $_.ToString('x2') }) -join ' ')
}
function Read-Prefix([string]$path, [int]$limit) {
    $stream = [IO.File]::Open($path, [IO.FileMode]::Open, [IO.FileAccess]::Read, [IO.FileShare]::ReadWrite)
    try {
        $count = [int][Math]::Min([int64]$limit, $stream.Length)
        $buffer = New-Object byte[] $count
        $read = $stream.Read($buffer, 0, $count)
        if ($read -eq $count) { return $buffer }
        $result = New-Object byte[] $read
        if ($read -gt 0) { [Array]::Copy($buffer, $result, $read) }
        return $result
    }
    finally { $stream.Dispose() }
}
function Report-TextMarkers([byte[]]$bytes, [string]$label) {
    if ($bytes.Length -eq 0) { return }
    $text = [Text.Encoding]::GetEncoding(1252).GetString($bytes)
    $patterns = @(
        '(?im)^\s*version\s*=.*$',
        '(?im)^\s*date\s*=.*$',
        '(?im)^\s*player\s*=.*$',
        '(?im)^\s*game_type\s*=.*$',
        '(?im)^\s*ironman\s*=.*$',
        '(?im)^\s*featured_ruler\s*=.*$',
        '(?im)^\s*bronzeman\s*=.*$',
        '(?im)^\s*checksum\s*=.*$'
    )
    $found = New-Object System.Collections.Generic.List[string]
    foreach ($pattern in $patterns) {
        foreach ($m in [regex]::Matches($text, $pattern)) {
            $value = ($m.Value -replace '[\r\n]+', ' ').Trim()
            if ($value.Length -gt 180) { $value = $value.Substring(0, 180) + '...' }
            if (-not $found.Contains($value)) { $found.Add($value) }
            if ($found.Count -ge 20) { break }
        }
        if ($found.Count -ge 20) { break }
    }
    Add-Line "$label markers:"
    if ($found.Count -eq 0) { Add-Line '  (none found in inspected prefix)' }
    else { foreach ($value in $found) { Add-Line "  $value" } }
}

Add-Line 'CK2 MONARCHS JOURNEY SAVE REPORT (READ ONLY)'
Add-Line ("Created: {0}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'))
Add-Line ("Documents: {0}" -f $documents)
Add-Line ("Save directory: {0}" -f $saveDir)
Add-Line

if (-not (Test-Path -LiteralPath $saveDir -PathType Container)) {
    Add-Line 'RESULT: SAVE DIRECTORY NOT FOUND.'
    Add-Line 'No files were changed.'
    [IO.File]::WriteAllLines($reportPath, $lines, $utf8Bom)
    Write-Host "Report created: $reportPath" -ForegroundColor Yellow
    exit 0
}

$allSaves = @(Get-ChildItem -LiteralPath $saveDir -File -Filter '*.ck2' | Sort-Object LastWriteTime -Descending)
Add-Line ("CK2 files found: {0}" -f $allSaves.Count)
foreach ($f in $allSaves) {
    Add-Line ("  {0} | {1} bytes | {2}" -f $f.Name, $f.Length, $f.LastWriteTime.ToString('yyyy-MM-dd HH:mm:ss'))
}
Add-Line

$targets = @($allSaves | Where-Object { $_.Name -match '(?i)bronzeman|bosnia|mj_v4' })
if ($targets.Count -eq 0) { $targets = @($allSaves | Select-Object -First 3) }

Add-Type -AssemblyName System.IO.Compression.FileSystem
foreach ($f in $targets) {
    Add-Line ('=' * 72)
    Add-Line ("FILE: {0}" -f $f.FullName)
    Add-Line ("Size: {0} bytes" -f $f.Length)
    Add-Line ("Modified: {0}" -f $f.LastWriteTime.ToString('yyyy-MM-dd HH:mm:ss'))
    try { Add-Line ("SHA-256: {0}" -f (Get-FileHash -LiteralPath $f.FullName -Algorithm SHA256).Hash.ToLowerInvariant()) }
    catch { Add-Line ("SHA-256 ERROR: {0}" -f $_.Exception.Message) }

    try {
        $prefix = Read-Prefix $f.FullName 2097152
        Add-Line ("First 64 bytes: {0}" -f (Hex-Bytes $prefix 64))
        if ($prefix.Length -eq 0) { $kind = 'EMPTY FILE' }
        elseif ($prefix.Length -ge 2 -and $prefix[0] -eq 0x50 -and $prefix[1] -eq 0x4b) { $kind = 'ZIP/COMPRESSED (PK)' }
        elseif ($prefix.Length -ge 6 -and [Text.Encoding]::ASCII.GetString($prefix,0,6) -eq 'CK2txt') { $kind = 'CK2 TEXT' }
        elseif ($prefix.Length -ge 6 -and [Text.Encoding]::ASCII.GetString($prefix,0,6) -eq 'CK2bin') { $kind = 'CK2 BINARY' }
        else { $kind = 'UNKNOWN OR HEADERLESS' }
        Add-Line ("Detected type: {0}" -f $kind)

        if ($kind -eq 'ZIP/COMPRESSED (PK)') {
            try {
                $zip = [IO.Compression.ZipFile]::OpenRead($f.FullName)
                try {
                    Add-Line 'ZIP entries:'
                    foreach ($entry in $zip.Entries) { Add-Line ("  {0} | {1} bytes" -f $entry.FullName, $entry.Length) }
                    $entry = $zip.Entries | Where-Object { $_.FullName -match '(?i)gamestate|meta' } | Select-Object -First 1
                    if ($null -eq $entry) { $entry = $zip.Entries | Select-Object -First 1 }
                    if ($null -ne $entry) {
                        $s = $entry.Open()
                        try {
                            $n = [int][Math]::Min([int64]2097152, $entry.Length)
                            $inner = New-Object byte[] $n
                            $got = $s.Read($inner, 0, $n)
                            if ($got -lt $n) {
                                $trimmed = New-Object byte[] $got
                                if ($got -gt 0) { [Array]::Copy($inner, $trimmed, $got) }
                                $inner = $trimmed
                            }
                            Add-Line ("Inspected ZIP entry: {0}" -f $entry.FullName)
                            Add-Line ("Entry first 64 bytes: {0}" -f (Hex-Bytes $inner 64))
                            Report-TextMarkers $inner 'Entry'
                        }
                        finally { $s.Dispose() }
                    }
                }
                finally { $zip.Dispose() }
            }
            catch { Add-Line ("ZIP READ ERROR: {0}" -f $_.Exception.Message) }
        }
        else { Report-TextMarkers $prefix 'File' }
    }
    catch { Add-Line ("READ ERROR: {0}" -f $_.Exception.Message) }
    Add-Line
}

Add-Line ('=' * 72)
Add-Line 'No save files were changed.'
[IO.File]::WriteAllLines($reportPath, $lines, $utf8Bom)
Write-Host
Write-Host 'READ-ONLY SAVE CHECK COMPLETE' -ForegroundColor Green
Write-Host "Report created: $reportPath"
Write-Host 'No save files were changed.'
