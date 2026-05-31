#Requires -Version 5.1
<#
.SYNOPSIS
    Portable project bootstrap for debuffer-skills.

.DESCRIPTION
    Copy this file into a project repo and run it from there. The script treats
    its own directory as the target project unless -ProjectPath is provided.
    It discovers a central debuffer-skills clone without hard-coded local paths,
    then delegates to tools/install_debuffer.ps1.
#>

[CmdletBinding()]
param(
    [string]$ProjectPath = '',

    [Alias('Repo')]
    [string]$SkillRepo = '',

    [ValidateSet('auto', 'claude', 'codex')]
    [string]$Platform = 'codex',

    [ValidateSet('core-research', 'paper', 'review', 'full')]
    [string]$Profile = 'core-research',

    [switch]$Reconcile,
    [switch]$DryRun,
    [switch]$CloneIfMissing,
    [string]$RepoUrl = 'https://github.com/Yulivu/debuffer-skills.git',
    [string]$RepoDestination = '',
    [switch]$Help
)

$ErrorActionPreference = 'Stop'

function Show-Help {
    Write-Host @"
Portable debuffer-skills project bootstrap.

Common use after copying this script into a project root:
  powershell -ExecutionPolicy Bypass -File .\use_debuffer_skills.ps1

With an explicit central skill repo:
  powershell -ExecutionPolicy Bypass -File .\use_debuffer_skills.ps1 -Repo C:\path\to\debuffer-skills

Install a different profile:
  powershell -ExecutionPolicy Bypass -File .\use_debuffer_skills.ps1 -Profile paper

Discovery order:
  1. -Repo / -SkillRepo
  2. DEBUFFER_SKILLS_REPO or SKILL_REPO
  3. The script's ancestor directories and sibling debuffer-skills folders
  4. Common user locations such as Desktop/debuffer-skills and .codex/debuffer-skills
  5. -CloneIfMissing into .codex/debuffer-skills, or -RepoDestination if provided
"@
}

if ($Help) {
    Show-Help
    exit 0
}

function Normalize-PathString {
    param([string]$Path)
    return ([System.IO.Path]::GetFullPath($Path)).TrimEnd([char[]]@('\', '/'))
}

function Same-Path {
    param([string]$Left, [string]$Right)
    return [System.StringComparer]::OrdinalIgnoreCase.Equals((Normalize-PathString $Left), (Normalize-PathString $Right))
}

function Test-PathInside {
    param([string]$Path, [string]$Root)
    $normalizedPath = Normalize-PathString $Path
    $normalizedRoot = Normalize-PathString $Root
    if ([System.StringComparer]::OrdinalIgnoreCase.Equals($normalizedPath, $normalizedRoot)) {
        return $true
    }
    $prefix = $normalizedRoot + [System.IO.Path]::DirectorySeparatorChar
    return $normalizedPath.StartsWith($prefix, [System.StringComparison]::OrdinalIgnoreCase)
}

function Test-DebufferRepo {
    param([string]$Path)
    if ([string]::IsNullOrWhiteSpace($Path)) { return $false }
    if (-not (Test-Path -LiteralPath $Path -PathType Container)) { return $false }
    $root = (Resolve-Path -LiteralPath $Path).ProviderPath
    return (
        (Test-Path -LiteralPath (Join-Path $root 'skills') -PathType Container) -and
        (Test-Path -LiteralPath (Join-Path $root 'skills\skills-codex') -PathType Container) -and
        (Test-Path -LiteralPath (Join-Path $root 'tools\install_debuffer.ps1') -PathType Leaf)
    )
}

function Add-Candidate {
    param(
        [System.Collections.Generic.List[string]]$Candidates,
        [string]$Path
    )
    if ([string]::IsNullOrWhiteSpace($Path)) { return }
    try {
        $full = [System.IO.Path]::GetFullPath($Path)
    } catch {
        return
    }
    foreach ($existing in $Candidates) {
        if (Same-Path $existing $full) { return }
    }
    $Candidates.Add($full) | Out-Null
}

function Add-TreeCandidates {
    param(
        [System.Collections.Generic.List[string]]$Candidates,
        [string]$StartPath
    )
    if ([string]::IsNullOrWhiteSpace($StartPath)) { return }
    if (-not (Test-Path -LiteralPath $StartPath)) { return }

    $item = Get-Item -LiteralPath $StartPath
    $dir = if ($item.PSIsContainer) { $item.FullName } else { $item.DirectoryName }
    while ($dir) {
        Add-Candidate $Candidates $dir
        Add-Candidate $Candidates (Join-Path $dir 'debuffer-skills')
        $parent = Split-Path -Parent $dir
        if ([string]::IsNullOrWhiteSpace($parent) -or (Same-Path $parent $dir)) { break }
        Add-Candidate $Candidates (Join-Path $parent 'debuffer-skills')
        $dir = $parent
    }
}

function Resolve-DebufferRepo {
    param([string]$ExplicitRepo, [string]$ProjectRoot)

    $candidates = [System.Collections.Generic.List[string]]::new()
    Add-Candidate $candidates $ExplicitRepo

    foreach ($envName in @('DEBUFFER_SKILLS_REPO', 'SKILL_REPO', 'ARIS_REPO')) {
        $value = [Environment]::GetEnvironmentVariable($envName)
        Add-Candidate $candidates $value
    }

    Add-TreeCandidates $candidates $PSScriptRoot
    Add-TreeCandidates $candidates (Get-Location).Path
    Add-TreeCandidates $candidates $ProjectRoot

    $userHome = [Environment]::GetFolderPath('UserProfile')
    Add-Candidate $candidates (Join-Path $userHome 'debuffer-skills')
    Add-Candidate $candidates (Join-Path $userHome 'Desktop\debuffer-skills')
    Add-Candidate $candidates (Join-Path $userHome '.codex\debuffer-skills')
    Add-Candidate $candidates (Join-Path $userHome '.claude\debuffer-skills')

    foreach ($candidate in $candidates) {
        if (Test-DebufferRepo $candidate) {
            return (Resolve-Path -LiteralPath $candidate).ProviderPath
        }
    }

    if ($CloneIfMissing) {
        $destination = $RepoDestination
        if ([string]::IsNullOrWhiteSpace($destination)) {
            $destination = Join-Path $userHome '.codex\debuffer-skills'
        }
        if (-not (Test-Path -LiteralPath $destination)) {
            $parent = Split-Path -Parent $destination
            if ($parent) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
            git clone $RepoUrl $destination
        }
        if (Test-DebufferRepo $destination) {
            return (Resolve-Path -LiteralPath $destination).ProviderPath
        }
    }

    throw @"
Cannot find a debuffer-skills repo.

Use one of:
  - Pass -Repo C:\path\to\debuffer-skills
  - Set DEBUFFER_SKILLS_REPO or SKILL_REPO
  - Put a clone at a sibling/user path named debuffer-skills
  - Rerun with -CloneIfMissing [-RepoUrl <git-url>]
"@
}

function Resolve-ProjectRoot {
    if (-not [string]::IsNullOrWhiteSpace($ProjectPath)) {
        if (-not (Test-Path -LiteralPath $ProjectPath -PathType Container)) {
            throw "Project path does not exist: $ProjectPath"
        }
        return (Resolve-Path -LiteralPath $ProjectPath).ProviderPath
    }

    $scriptDir = (Resolve-Path -LiteralPath $PSScriptRoot).ProviderPath
    $repoNearScript = $null
    try {
        $repoNearScript = Resolve-DebufferRepo -ExplicitRepo '' -ProjectRoot $scriptDir
    } catch {
        $repoNearScript = $null
    }

    if ($repoNearScript -and (Test-PathInside $scriptDir $repoNearScript)) {
        return (Resolve-Path -LiteralPath (Get-Location).Path).ProviderPath
    }

    return $scriptDir
}

$projectRoot = Resolve-ProjectRoot
$repoRoot = Resolve-DebufferRepo -ExplicitRepo $SkillRepo -ProjectRoot $projectRoot

if (Same-Path $projectRoot $repoRoot) {
    throw "Target project is the debuffer-skills repo itself. Copy this script into a target project or pass -ProjectPath."
}

$installer = Join-Path $repoRoot 'tools\install_debuffer.ps1'
if (-not (Test-Path -LiteralPath $installer -PathType Leaf)) {
    throw "Installer not found: $installer"
}

$installArgs = @(
    $projectRoot,
    '-Platform', $Platform,
    '-Repo', $repoRoot,
    '-Profile', $Profile
)
if ($Reconcile) { $installArgs += '-Reconcile' }
if ($DryRun) { $installArgs += '-DryRun' }

Write-Host ''
Write-Host 'debuffer-skills project bootstrap'
Write-Host "  Project: $projectRoot"
Write-Host "  Repo:    $repoRoot"
Write-Host "  Profile: $Profile"
Write-Host "  Platform: $Platform"
Write-Host ''

& powershell -NoProfile -ExecutionPolicy Bypass -File $installer @installArgs
exit $LASTEXITCODE
