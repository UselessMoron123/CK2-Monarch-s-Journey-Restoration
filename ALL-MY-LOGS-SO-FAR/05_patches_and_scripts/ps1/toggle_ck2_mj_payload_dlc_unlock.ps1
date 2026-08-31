# Guarded DLC-declaration toggle for the CK2 Monarch's Journey local payload.
# This does NOT unlock or install official DLC. It removes only the four
# required_dlcs declarations which grey the MJ Play button before campaign setup.
param(
    [Parameter(Mandatory=$true, Position=0)]
    [ValidateSet('Verify','Apply','Revert')]
    [string]$Operation,

    [Parameter(Mandatory=$true, Position=1)]
    [string]$Payload
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$StockSize = 101949L
$UnlockedSize = 101761L
$StockSha = 'fc6ec025b782c811636a0efb65a7b3f192f09fffd0ff6ca8051ef8bc6113db4e'
$UnlockedSha = '1216a9eda59e35779171a616e489d6b1f823e6d4b62909a4924fafe8330e982b'

function Get-Sha256([string]$Path) {
    return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()
}

function Get-State([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { throw "Payload not found: $Path" }
    $item = Get-Item -LiteralPath $Path
    $sha = Get-Sha256 $Path
    if ($item.Length -eq $StockSize -and $sha -eq $StockSha) {
        return [pscustomobject]@{ State='stock-requirements'; Sha256=$sha; Size=$item.Length }
    }
    if ($item.Length -eq $UnlockedSize -and $sha -eq $UnlockedSha) {
        return [pscustomobject]@{ State='dlc-declarations-removed'; Sha256=$sha; Size=$item.Length }
    }
    throw "Unknown payload: $($item.Length) bytes, SHA-256 $sha. Expected the canonical V9 payload or its DLC-test variant. Nothing was changed."
}

function Save-VerifiedBackup([string]$Path, [string]$ExpectedSha, [string]$Label) {
    $stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
    $backup = $Path + '.' + $Label + '_' + $stamp + '.bak'
    $counter = 1
    while (Test-Path -LiteralPath $backup) {
        $backup = $Path + '.' + $Label + '_' + $stamp + '_' + $counter + '.bak'
        $counter++
    }
    Copy-Item -LiteralPath $Path -Destination $backup
    if ((Get-Sha256 $backup) -ne $ExpectedSha) {
        Remove-Item -LiteralPath $backup -Force -ErrorAction SilentlyContinue
        throw 'Backup verification failed.'
    }
    return $backup
}

function Write-Verified([string]$Path, [string]$Text, [string]$ExpectedSha) {
    $temp = $Path + '.' + [Guid]::NewGuid().ToString('N') + '.tmp'
    try {
        [IO.File]::WriteAllText($temp, $Text, (New-Object Text.UTF8Encoding($false)))
        $actual = Get-Sha256 $temp
        if ($actual -ne $ExpectedSha) { throw "Generated payload hash mismatch: $actual" }
        Copy-Item -LiteralPath $temp -Destination $Path -Force
        if ((Get-Sha256 $Path) -ne $ExpectedSha) { throw 'Final payload verification failed.' }
    }
    finally { Remove-Item -LiteralPath $temp -Force -ErrorAction SilentlyContinue }
}

$Payload = [IO.Path]::GetFullPath($Payload)
$utf8 = New-Object Text.UTF8Encoding($false, $true)
$blocks = @(
    "`t`t`t`t`"required_dlcs`": [`r`n`t`t`t`t`t`"dlc007`"`r`n`t`t`t`t],`r`n",
    "`t`t`t`t`"required_dlcs`": [`r`n`t`t`t`t`t`"dlc024`"`r`n`t`t`t`t],`r`n"
)

try {
    $state = Get-State $Payload
    if ($Operation -eq 'Verify') {
        Write-Host "State: $($state.State)"
        Write-Host "Size: $($state.Size) bytes"
        Write-Host "SHA-256: $($state.Sha256)"
        if ($state.State -eq 'dlc-declarations-removed') {
            Write-Host 'RESULT: DLC TEST PAYLOAD INSTALLED' -ForegroundColor Green
        } else {
            Write-Host 'RESULT: CANONICAL PAYLOAD; FOUR RULERS STILL DECLARE DLC REQUIREMENTS' -ForegroundColor Yellow
        }
        exit 0
    }

    $text = [IO.File]::ReadAllText($Payload, $utf8)

    if ($Operation -eq 'Apply') {
        if ($state.State -eq 'dlc-declarations-removed') {
            Write-Host "Already unlocked for testing. SHA-256: $UnlockedSha" -ForegroundColor Green
            exit 0
        }
        $backup = Save-VerifiedBackup $Payload $StockSha 'before_dlc_test_unlock'
        if (([regex]::Matches($text, [regex]::Escape($blocks[0]))).Count -ne 3) { throw 'Expected three dlc007 declarations.' }
        if (([regex]::Matches($text, [regex]::Escape($blocks[1]))).Count -ne 1) { throw 'Expected one dlc024 declaration.' }
        $text = $text.Replace($blocks[0], '').Replace($blocks[1], '')
        Write-Verified $Payload $text $UnlockedSha
        Write-Host "Saved and verified backup: $backup"
        Write-Host 'Removed payload DLC declarations for Mordechai, Louise, Shajar, and Arwa.'
        Write-Host 'RESULT: DLC TEST PAYLOAD APPLIED AND VERIFIED' -ForegroundColor Green
        Write-Host "SHA-256: $UnlockedSha"
        Write-Host 'This does not install DLC; campaign setup may still reject or reduce unavailable mechanics.'
        exit 0
    }

    if ($state.State -eq 'stock-requirements') {
        Write-Host "Already reverted to the canonical payload. SHA-256: $StockSha" -ForegroundColor Green
        exit 0
    }
    $backup = Save-VerifiedBackup $Payload $UnlockedSha 'before_dlc_test_revert'
    # Reinsert each declaration immediately after its unique dynasty_id line.
    $insertions = @(
        @("`t`t`t`t`"dynasty_id`": 1059023,`r`n", "`t`t`t`t`"dynasty_id`": 1059023,`r`n" + $blocks[0]),
        @("`t`t`t`t`"dynasty_id`": 25061,`r`n", "`t`t`t`t`"dynasty_id`": 25061,`r`n" + $blocks[1]),
        @("`t`t`t`t`"dynasty_id`": 762,`r`n", "`t`t`t`t`"dynasty_id`": 762,`r`n" + $blocks[0]),
        @("`t`t`t`t`"dynasty_id`": 590,`r`n", "`t`t`t`t`"dynasty_id`": 590,`r`n" + $blocks[0])
    )
    foreach ($pair in $insertions) {
        if (([regex]::Matches($text, [regex]::Escape($pair[0]))).Count -ne 1) { throw "Unique reinsertion anchor missing: $($pair[0])" }
        $text = $text.Replace($pair[0], $pair[1])
    }
    Write-Verified $Payload $text $StockSha
    Write-Host "Saved and verified backup: $backup"
    Write-Host 'RESULT: RESTORED EXACT CANONICAL PAYLOAD' -ForegroundColor Green
    Write-Host "SHA-256: $StockSha"
}
catch {
    Write-Host ''
    Write-Host ("ERROR: " + $_.Exception.Message) -ForegroundColor Red
    exit 1
}
