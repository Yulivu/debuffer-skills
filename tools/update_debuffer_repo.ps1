#Requires -Version 5.1
<#
.SYNOPSIS
    Update this debuffer-skills checkout from GitHub with fast-forward pull only.
#>

[CmdletBinding()]
param(
    [string]$RepoRoot = '',
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
if ($RepoRoot) {
    $RepoRoot = (Resolve-Path -LiteralPath $RepoRoot).ProviderPath
} else {
    $RepoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).ProviderPath
}

function Invoke-Step {
    param([string[]]$Command)
    if ($DryRun) {
        Write-Host ('+ ' + ($Command -join ' '))
        return
    }
    & $Command[0] $Command[1..($Command.Count - 1)]
    if ($LASTEXITCODE -ne 0) {
        throw "command failed with exit code ${LASTEXITCODE}: $($Command -join ' ')"
    }
}

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw 'git not found in PATH'
}

& git -C $RepoRoot rev-parse --is-inside-work-tree | Out-Null
if ($LASTEXITCODE -ne 0) {
    throw "not a git checkout: $RepoRoot"
}

$branch = (& git -C $RepoRoot rev-parse --abbrev-ref HEAD).Trim()
if ($LASTEXITCODE -ne 0 -or -not $branch) {
    throw 'failed to detect current branch'
}
if ($branch -eq 'HEAD') {
    throw 'detached HEAD is not supported; switch to a branch first'
}

$status = (& git -C $RepoRoot status --porcelain)
if ($LASTEXITCODE -ne 0) {
    throw 'failed to inspect working tree status'
}
if ($status) {
    throw 'working tree is not clean; commit or stash local changes before GitHub update'
}

$remoteUrl = (& git -C $RepoRoot remote get-url origin 2>$null).Trim()
if ($LASTEXITCODE -ne 0 -or -not $remoteUrl) {
    throw "git remote 'origin' is not configured"
}

Write-Host "Repo: $RepoRoot"
Write-Host "Remote: $remoteUrl"
Write-Host "Branch: $branch"

Invoke-Step @('git', '-C', $RepoRoot, 'fetch', '--prune', 'origin')
Invoke-Step @('git', '-C', $RepoRoot, 'pull', '--ff-only', 'origin', $branch)

if (-not $DryRun) {
    $head = (& git -C $RepoRoot rev-parse --short HEAD).Trim()
    if ($LASTEXITCODE -eq 0 -and $head) {
        Write-Host "Updated to: $head"
    }
}
