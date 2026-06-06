#Requires -Version 5.1
<#
.SYNOPSIS
    Reconcile every project recorded in this debuffer-skills checkout.

.NOTES
    -Apply is required for project changes. -Prune only removes stale registry
    entries when used with -Apply.
#>

[CmdletBinding()]
param(
    [switch]$Apply,
    [switch]$List,
    [switch]$Prune,
    [string[]]$DiscoverRoot = @()
)

$ErrorActionPreference = 'Stop'
$RepoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).ProviderPath
$RegistryPath = if ($env:DEBUFFER_REGISTRY_PATH) {
    $env:DEBUFFER_REGISTRY_PATH
} else {
    Join-Path $RepoRoot '.debuffer_registry\installed-projects.tsv'
}

$registryHelper = Join-Path $PSScriptRoot 'debuffer_registry.ps1'
if (Test-Path -LiteralPath $registryHelper -PathType Leaf) {
    . $registryHelper
}

function Get-ManifestValue {
    param([string]$Path, [string]$Key)
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { return '' }
    foreach ($line in Get-Content -LiteralPath $Path -Encoding UTF8) {
        $parts = $line -split "`t", 2
        if ($parts.Count -eq 2 -and $parts[0] -eq $Key) { return $parts[1] }
    }
    return ''
}

function Get-PlatformFromManifestName {
    param([string]$Path)
    switch ([System.IO.Path]::GetFileName($Path)) {
        'installed-skills-codex.txt' { return 'codex' }
        'installed-skills-copilot.txt' { return 'copilot' }
        'installed-skills.txt' { return 'claude' }
        default { return '' }
    }
}

function Register-Manifest {
    param([string]$Manifest)
    $projectRoot = Get-ManifestValue $Manifest 'project_root'
    if (-not $projectRoot) {
        $projectRoot = (Resolve-Path -LiteralPath (Join-Path (Split-Path -Parent $Manifest) '..')).ProviderPath
    }
    $profile = Get-ManifestValue $Manifest 'profile'
    if (-not $profile) { $profile = 'full' }
    $platform = Get-ManifestValue $Manifest 'platform'
    if (-not $platform) { $platform = Get-PlatformFromManifestName $Manifest }
    if (-not $platform) { return }
    if (Get-Command Update-DebufferInstallRegistry -ErrorAction SilentlyContinue) {
        Update-DebufferInstallRegistry `
            -RepoRoot $RepoRoot `
            -ProjectRoot $projectRoot `
            -Platform $platform `
            -ManifestRel ".debuffer_skills/$([System.IO.Path]::GetFileName($Manifest))" `
            -Profile $profile
    }
}

foreach ($root in $DiscoverRoot) {
    if (-not (Test-Path -LiteralPath $root -PathType Container)) {
        throw "-DiscoverRoot does not exist: $root"
    }
    Get-ChildItem -LiteralPath $root -Recurse -Force -File -Filter 'installed-skills*.txt' -ErrorAction SilentlyContinue |
        Where-Object { $_ } |
        Where-Object { $_.Directory.Name -eq '.debuffer_skills' } |
        ForEach-Object { Register-Manifest $_.FullName }
}

if (-not (Test-Path -LiteralPath $RegistryPath -PathType Leaf)) {
    Write-Host "No install registry found:"
    Write-Host "  $RegistryPath"
    Write-Host ''
    Write-Host 'Future installs will register automatically. For older installs, run:'
    Write-Host '  powershell -ExecutionPolicy Bypass -File tools\reconcile_debuffer_installs.ps1 -DiscoverRoot C:\path\to\projects'
    exit 0
}

$entries = New-Object System.Collections.Generic.List[object]
foreach ($line in Get-Content -LiteralPath $RegistryPath -Encoding UTF8) {
    if ($line.StartsWith('#') -or -not $line.Trim()) { continue }
    $parts = $line -split "`t"
    if ($parts.Count -lt 6) { continue }
    $entries.Add([pscustomobject]@{
        ProjectRoot = $parts[0]
        Platform = $parts[1]
        ManifestRel = $parts[2]
        Profile = $parts[3]
        RepoRoot = $parts[4]
        LastSeen = $parts[5]
        OriginalLine = $line
    })
}

if ($entries.Count -eq 0) {
    Write-Host "Install registry is empty: $RegistryPath"
    exit 0
}

Write-Host "Registry: $RegistryPath"
Write-Host ("Mode: " + $(if ($Apply) { 'apply' } else { 'preview' }))
Write-Host ''

$keptLines = New-Object System.Collections.Generic.List[string]
$seen = 0
$skipped = 0
$failed = 0

foreach ($entry in $entries) {
    $manifest = Join-Path $entry.ProjectRoot $entry.ManifestRel
    $cmd = $null
    switch ($entry.Platform) {
        'codex' {
            $cmd = @(
                '-NoProfile', '-ExecutionPolicy', 'Bypass',
                '-File', (Join-Path $RepoRoot 'tools\install_debuffer.ps1'),
                $entry.ProjectRoot,
                '-Platform', 'codex',
                '-Repo', $RepoRoot,
                '-Profile', $entry.Profile,
                '-Reconcile'
            )
        }
        'claude' {
            $cmd = @(
                '-NoProfile', '-ExecutionPolicy', 'Bypass',
                '-File', (Join-Path $RepoRoot 'tools\install_debuffer.ps1'),
                $entry.ProjectRoot,
                '-Platform', 'claude',
                '-Repo', $RepoRoot,
                '-Profile', $entry.Profile,
                '-Reconcile'
            )
        }
        'copilot' {
            $cmd = @(
                'bash',
                (Join-Path $RepoRoot 'tools/install_aris_copilot.sh'),
                $entry.ProjectRoot,
                '--repo', $RepoRoot,
                '--profile', $entry.Profile,
                '--reconcile',
                '--quiet'
            )
        }
        default {
            Write-Warning "unknown platform '$($entry.Platform)' for $($entry.ProjectRoot)"
            $skipped++
            continue
        }
    }

    if (-not (Test-Path -LiteralPath $entry.ProjectRoot -PathType Container) -or
        -not (Test-Path -LiteralPath $manifest -PathType Leaf)) {
        Write-Warning "missing project or manifest: $($entry.ProjectRoot) ($($entry.ManifestRel))"
        $skipped++
        if ($Prune -and $Apply -and (Get-Command Remove-DebufferInstallRegistry -ErrorAction SilentlyContinue)) {
            Remove-DebufferInstallRegistry `
                -RepoRoot $RepoRoot `
                -ProjectRoot $entry.ProjectRoot `
                -Platform $entry.Platform `
                -ManifestRel $entry.ManifestRel
        } elseif (-not $Prune) {
            $keptLines.Add($entry.OriginalLine)
        }
        continue
    }

    Write-Host "$($entry.ProjectRoot) [$($entry.Platform), $($entry.Profile)]"
    if ($List -or -not $Apply) {
        Write-Host ("  powershell " + ($cmd -join ' '))
        $keptLines.Add($entry.OriginalLine)
        $seen++
        continue
    }

        if ($entry.Platform -eq 'copilot') {
            & $cmd[0] $cmd[1..($cmd.Count - 1)]
        } else {
            & powershell @cmd
        }
    if ($LASTEXITCODE -eq 0) {
        $seen++
    } else {
        $failed++
        $keptLines.Add($entry.OriginalLine)
    }
}

Write-Host ''
Write-Host "Done. Seen: $seen, skipped: $skipped, failed: $failed"
if (-not $Apply -and -not $List) {
    Write-Host 'Preview only. Re-run with -Apply to reconcile all listed projects.'
}

exit $(if ($failed -eq 0) { 0 } else { 1 })
