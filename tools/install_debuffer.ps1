#Requires -Version 5.1
<#
.SYNOPSIS
    Public Windows installer entry for debuffer-skills.
#>

[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$ProjectPath = (Get-Location).Path,

    [ValidateSet('auto', 'claude', 'codex')]
    [string]$Platform = 'auto',

    [ValidateSet('core-research', 'paper', 'review', 'full', 'full-flat')]
    [string]$Profile = 'full',

    [Alias('Repo', 'ArisRepo')]
    [string]$SkillRepo = '',

    [switch]$DryRun,
    [switch]$NoDoc,
    [switch]$Reconcile,
    [switch]$Uninstall,
    [string[]]$ReplaceLink = @(),
    [switch]$FromOld,
    [ValidateSet('', 'keep-user', 'prefer-upstream')]
    [string]$MigrateCopy = '',
    [switch]$ClearStaleLock,

    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$ExtraArgs = @()
)

$forward = @(
    $ProjectPath,
    '-Platform', $Platform,
    '-Profile', $Profile
)
if ($SkillRepo) { $forward += @('-ArisRepo', $SkillRepo) }
if ($DryRun) { $forward += '-DryRun' }
if ($NoDoc) { $forward += '-NoDoc' }
if ($Reconcile) { $forward += '-Reconcile' }
if ($Uninstall) { $forward += '-Uninstall' }
foreach ($name in $ReplaceLink) { $forward += @('-ReplaceLink', $name) }
if ($FromOld) { $forward += '-FromOld' }
if ($MigrateCopy) { $forward += @('-MigrateCopy', $MigrateCopy) }
if ($ClearStaleLock) { $forward += '-ClearStaleLock' }
if ($ExtraArgs) { $forward += $ExtraArgs }

& powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot 'install_aris.ps1') @forward
exit $LASTEXITCODE
