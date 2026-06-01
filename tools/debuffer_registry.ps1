# Local registry helpers for project installs managed by this skill repo.

$script:DebufferRegistryUtf8 = New-Object System.Text.UTF8Encoding($false)

function Get-DebufferRegistryPath {
    param([string]$RepoRoot)
    if ($env:DEBUFFER_REGISTRY_PATH) {
        return $env:DEBUFFER_REGISTRY_PATH
    }
    return (Join-Path $RepoRoot '.debuffer_registry\installed-projects.tsv')
}

function Test-DebufferRegistryUnsafeValue {
    param([string]$Value)
    return $Value -match "[`t`r`n]"
}

function New-DebufferRegistryHeader {
    return @(
        '# debuffer managed installs registry v1',
        '# project_root<TAB>platform<TAB>manifest<TAB>profile<TAB>repo_root<TAB>last_seen_utc'
    )
}

function Write-DebufferRegistryLines {
    param([string]$Path, [string[]]$Lines)
    $dir = Split-Path -Parent $Path
    if ($dir) {
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
    }
    $tmp = "$Path.tmp.$PID"
    [System.IO.File]::WriteAllText($tmp, (($Lines -join "`n") + "`n"), $script:DebufferRegistryUtf8)
    Move-Item -LiteralPath $tmp -Destination $Path -Force
}

function Update-DebufferInstallRegistry {
    param(
        [string]$RepoRoot,
        [string]$ProjectRoot,
        [string]$Platform,
        [string]$ManifestRel,
        [string]$Profile
    )
    if ($env:DEBUFFER_REGISTRY_DISABLE -eq '1') { return }
    foreach ($value in @($RepoRoot, $ProjectRoot, $Platform, $ManifestRel, $Profile)) {
        if (Test-DebufferRegistryUnsafeValue $value) {
            Write-Warning 'skipping install registry update; path contains a tab or newline'
            return
        }
    }
    $registry = Get-DebufferRegistryPath $RepoRoot
    $lines = New-Object System.Collections.Generic.List[string]
    foreach ($line in (New-DebufferRegistryHeader)) { $lines.Add($line) }
    if (Test-Path -LiteralPath $registry -PathType Leaf) {
        foreach ($line in Get-Content -LiteralPath $registry -Encoding UTF8) {
            if ($line.StartsWith('#') -or -not $line.Trim()) { continue }
            $parts = $line -split "`t"
            if ($parts.Count -lt 6) { continue }
            if ($parts[0] -eq $ProjectRoot -and $parts[1] -eq $Platform -and $parts[2] -eq $ManifestRel) { continue }
            $lines.Add($line)
        }
    }
    $now = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
    $lines.Add(($ProjectRoot, $Platform, $ManifestRel, $Profile, $RepoRoot, $now) -join "`t")
    Write-DebufferRegistryLines -Path $registry -Lines ($lines.ToArray())
}

function Remove-DebufferInstallRegistry {
    param(
        [string]$RepoRoot,
        [string]$ProjectRoot,
        [string]$Platform,
        [string]$ManifestRel
    )
    if ($env:DEBUFFER_REGISTRY_DISABLE -eq '1') { return }
    $registry = Get-DebufferRegistryPath $RepoRoot
    if (-not (Test-Path -LiteralPath $registry -PathType Leaf)) { return }
    $lines = New-Object System.Collections.Generic.List[string]
    foreach ($line in (New-DebufferRegistryHeader)) { $lines.Add($line) }
    foreach ($line in Get-Content -LiteralPath $registry -Encoding UTF8) {
        if ($line.StartsWith('#') -or -not $line.Trim()) { continue }
        $parts = $line -split "`t"
        if ($parts.Count -lt 6) { continue }
        if ($parts[0] -eq $ProjectRoot -and $parts[1] -eq $Platform -and $parts[2] -eq $ManifestRel) { continue }
        $lines.Add($line)
    }
    Write-DebufferRegistryLines -Path $registry -Lines ($lines.ToArray())
}
