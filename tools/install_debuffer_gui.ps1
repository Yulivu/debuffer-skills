#Requires -Version 5.1
<#
.SYNOPSIS
    GUI installer for project-local debuffer-skills.

.DESCRIPTION
    Launch from the debuffer-skills repo, choose a target project folder, then
    install project-local Codex skills through tools/install_debuffer.ps1.
#>

[CmdletBinding()]
param(
    [string]$SkillRepo = '',
    [string]$ProjectPath = '',
    [ValidateSet('auto', 'claude', 'codex')]
    [string]$Platform = 'codex',
    [ValidateSet('core-research', 'paper', 'review', 'full')]
    [string]$Profile = 'core-research',
    [switch]$ValidateOnly
)

$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

function Resolve-RepoRoot {
    param([string]$ExplicitRepo)
    if ($ExplicitRepo) {
        $candidate = (Resolve-Path -LiteralPath $ExplicitRepo).ProviderPath
        if (Test-Path -LiteralPath (Join-Path $candidate 'tools\install_debuffer.ps1') -PathType Leaf) {
            return $candidate
        }
        throw "Invalid debuffer-skills repo: $candidate"
    }

    $dir = (Resolve-Path -LiteralPath $PSScriptRoot).ProviderPath
    while ($dir) {
        if (
            (Test-Path -LiteralPath (Join-Path $dir 'skills') -PathType Container) -and
            (Test-Path -LiteralPath (Join-Path $dir 'skills\skills-codex') -PathType Container) -and
            (Test-Path -LiteralPath (Join-Path $dir 'tools\install_debuffer.ps1') -PathType Leaf)
        ) {
            return $dir
        }
        $parent = Split-Path -Parent $dir
        if ([string]::IsNullOrWhiteSpace($parent) -or $parent -eq $dir) { break }
        $dir = $parent
    }
    throw "Cannot locate debuffer-skills repo from $PSScriptRoot"
}

function Same-Path {
    param([string]$Left, [string]$Right)
    if (-not $Left -or -not $Right) { return $false }
    $leftFull = ([System.IO.Path]::GetFullPath($Left)).TrimEnd([char[]]@('\', '/'))
    $rightFull = ([System.IO.Path]::GetFullPath($Right)).TrimEnd([char[]]@('\', '/'))
    return [System.StringComparer]::OrdinalIgnoreCase.Equals($leftFull, $rightFull)
}

function Append-Log {
    param([System.Windows.Forms.TextBox]$TextBox, [string]$Text)
    if ($null -eq $Text) { return }
    $TextBox.AppendText($Text.Replace("`r`n", "`n").Replace("`n", [Environment]::NewLine))
    if (-not $Text.EndsWith("`n")) {
        $TextBox.AppendText([Environment]::NewLine)
    }
}

function Quote-ProcessArgument {
    param([string]$Value)
    if ($null -eq $Value) { return '""' }
    if ($Value -notmatch '[\s"]') { return $Value }
    $escaped = $Value -replace '(\\*)"', '$1$1\"'
    $escaped = $escaped -replace '(\\+)$', '$1$1'
    return '"' + $escaped + '"'
}

function Select-Folder {
    param([string]$Description, [string]$InitialPath)
    $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $dialog.Description = $Description
    $dialog.ShowNewFolderButton = $false
    if ($InitialPath -and (Test-Path -LiteralPath $InitialPath -PathType Container)) {
        $dialog.SelectedPath = $InitialPath
    }
    if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        return $dialog.SelectedPath
    }
    return $null
}

function Run-Installer {
    param(
        [string]$RepoRoot,
        [string]$TargetProject,
        [string]$SelectedPlatform,
        [string]$SelectedProfile,
        [bool]$Reconcile,
        [bool]$DryRun,
        [System.Windows.Forms.TextBox]$LogBox
    )

    $installer = Join-Path $RepoRoot 'tools\install_debuffer.ps1'
    if (-not (Test-Path -LiteralPath $installer -PathType Leaf)) {
        throw "Installer not found: $installer"
    }
    if (-not (Test-Path -LiteralPath $TargetProject -PathType Container)) {
        throw "Target project folder does not exist: $TargetProject"
    }
    if (Same-Path $RepoRoot $TargetProject) {
        throw "Target project cannot be the debuffer-skills repo itself."
    }

    $args = @(
        '-NoProfile',
        '-ExecutionPolicy', 'Bypass',
        '-File', $installer,
        $TargetProject,
        '-Platform', $SelectedPlatform,
        '-Repo', $RepoRoot,
        '-Profile', $SelectedProfile
    )
    if ($Reconcile) { $args += '-Reconcile' }
    if ($DryRun) { $args += '-DryRun' }

    Append-Log $LogBox "Running installer..."
    Append-Log $LogBox ("powershell " + ($args -join ' '))

    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = 'powershell'
    $psi.Arguments = (($args | ForEach-Object { Quote-ProcessArgument $_ }) -join ' ')
    $psi.WorkingDirectory = $RepoRoot
    $psi.UseShellExecute = $false
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.CreateNoWindow = $true

    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $psi
    [void]$process.Start()
    $stdout = $process.StandardOutput.ReadToEnd()
    $stderr = $process.StandardError.ReadToEnd()
    $process.WaitForExit()

    if ($stdout) { Append-Log $LogBox $stdout }
    if ($stderr) { Append-Log $LogBox $stderr }

    if ($process.ExitCode -ne 0) {
        throw "Installer exited with code $($process.ExitCode)."
    }
    Append-Log $LogBox "Install completed."
}

$repoRoot = Resolve-RepoRoot -ExplicitRepo $SkillRepo

if ($ValidateOnly) {
    Write-Host "GUI installer validation ok."
    Write-Host "Skill repo: $repoRoot"
    exit 0
}

$form = New-Object System.Windows.Forms.Form
$form.Text = 'Install debuffer-skills'
$form.StartPosition = 'CenterScreen'
$form.Size = New-Object System.Drawing.Size(780, 560)
$form.MinimumSize = New-Object System.Drawing.Size(720, 500)
$form.Font = New-Object System.Drawing.Font('Segoe UI', 9)

$main = New-Object System.Windows.Forms.TableLayoutPanel
$main.Dock = 'Fill'
$main.Padding = New-Object System.Windows.Forms.Padding(12)
$main.ColumnCount = 3
$main.RowCount = 8
$main.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Absolute, 120))) | Out-Null
$main.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent, 100))) | Out-Null
$main.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Absolute, 110))) | Out-Null
foreach ($height in @(34, 34, 34, 34, 34, 42, 0, 44)) {
    if ($height -eq 0) {
        $main.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent, 100))) | Out-Null
    } else {
        $main.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute, $height))) | Out-Null
    }
}
$form.Controls.Add($main)

$repoLabel = New-Object System.Windows.Forms.Label
$repoLabel.Text = 'Skill repo'
$repoLabel.TextAlign = 'MiddleLeft'
$repoText = New-Object System.Windows.Forms.TextBox
$repoText.Text = $repoRoot
$repoText.ReadOnly = $true
$repoText.Dock = 'Fill'
$repoButton = New-Object System.Windows.Forms.Button
$repoButton.Text = 'Change...'
$repoButton.Dock = 'Fill'

$projectLabel = New-Object System.Windows.Forms.Label
$projectLabel.Text = 'Target repo'
$projectLabel.TextAlign = 'MiddleLeft'
$projectText = New-Object System.Windows.Forms.TextBox
$projectText.Text = $ProjectPath
$projectText.Dock = 'Fill'
$projectButton = New-Object System.Windows.Forms.Button
$projectButton.Text = 'Choose...'
$projectButton.Dock = 'Fill'

$profileLabel = New-Object System.Windows.Forms.Label
$profileLabel.Text = 'Profile'
$profileLabel.TextAlign = 'MiddleLeft'
$profileCombo = New-Object System.Windows.Forms.ComboBox
$profileCombo.DropDownStyle = 'DropDownList'
[void]$profileCombo.Items.AddRange(@('core-research', 'paper', 'review', 'full'))
$profileCombo.SelectedItem = $Profile
$profileCombo.Dock = 'Left'
$profileCombo.Width = 180

$platformLabel = New-Object System.Windows.Forms.Label
$platformLabel.Text = 'Platform'
$platformLabel.TextAlign = 'MiddleLeft'
$platformCombo = New-Object System.Windows.Forms.ComboBox
$platformCombo.DropDownStyle = 'DropDownList'
[void]$platformCombo.Items.AddRange(@('codex', 'claude', 'auto'))
$platformCombo.SelectedItem = $Platform
$platformCombo.Dock = 'Left'
$platformCombo.Width = 180

$optionLabel = New-Object System.Windows.Forms.Label
$optionLabel.Text = 'Options'
$optionLabel.TextAlign = 'MiddleLeft'
$optionPanel = New-Object System.Windows.Forms.FlowLayoutPanel
$optionPanel.Dock = 'Fill'
$optionPanel.FlowDirection = 'LeftToRight'
$optionPanel.WrapContents = $false
$reconcileCheck = New-Object System.Windows.Forms.CheckBox
$reconcileCheck.Text = 'Reconcile existing install'
$reconcileCheck.AutoSize = $true
$dryRunCheck = New-Object System.Windows.Forms.CheckBox
$dryRunCheck.Text = 'Dry run'
$dryRunCheck.AutoSize = $true
$optionPanel.Controls.Add($reconcileCheck)
$optionPanel.Controls.Add($dryRunCheck)

$hint = New-Object System.Windows.Forms.Label
$hint.Text = 'Choose the research project repo to receive project-local skills. The central skill repo is only linked, not copied.'
$hint.TextAlign = 'MiddleLeft'
$hint.Dock = 'Fill'

$logBox = New-Object System.Windows.Forms.TextBox
$logBox.Multiline = $true
$logBox.ScrollBars = 'Both'
$logBox.ReadOnly = $true
$logBox.WordWrap = $false
$logBox.Dock = 'Fill'
$logBox.Font = New-Object System.Drawing.Font('Consolas', 9)

$buttonPanel = New-Object System.Windows.Forms.FlowLayoutPanel
$buttonPanel.Dock = 'Fill'
$buttonPanel.FlowDirection = 'RightToLeft'
$installButton = New-Object System.Windows.Forms.Button
$installButton.Text = 'Install'
$installButton.Width = 100
$installButton.Height = 30
$closeButton = New-Object System.Windows.Forms.Button
$closeButton.Text = 'Close'
$closeButton.Width = 100
$closeButton.Height = 30
$openButton = New-Object System.Windows.Forms.Button
$openButton.Text = 'Open Target'
$openButton.Width = 110
$openButton.Height = 30
$buttonPanel.Controls.Add($closeButton)
$buttonPanel.Controls.Add($installButton)
$buttonPanel.Controls.Add($openButton)

$main.Controls.Add($repoLabel, 0, 0)
$main.Controls.Add($repoText, 1, 0)
$main.Controls.Add($repoButton, 2, 0)
$main.Controls.Add($projectLabel, 0, 1)
$main.Controls.Add($projectText, 1, 1)
$main.Controls.Add($projectButton, 2, 1)
$main.Controls.Add($profileLabel, 0, 2)
$main.Controls.Add($profileCombo, 1, 2)
$main.SetColumnSpan($profileCombo, 2)
$main.Controls.Add($platformLabel, 0, 3)
$main.Controls.Add($platformCombo, 1, 3)
$main.SetColumnSpan($platformCombo, 2)
$main.Controls.Add($optionLabel, 0, 4)
$main.Controls.Add($optionPanel, 1, 4)
$main.SetColumnSpan($optionPanel, 2)
$main.Controls.Add($hint, 0, 5)
$main.SetColumnSpan($hint, 3)
$main.Controls.Add($logBox, 0, 6)
$main.SetColumnSpan($logBox, 3)
$main.Controls.Add($buttonPanel, 0, 7)
$main.SetColumnSpan($buttonPanel, 3)

$repoButton.Add_Click({
    $selected = Select-Folder -Description 'Choose debuffer-skills repo' -InitialPath $repoText.Text
    if ($selected) {
        try {
            $resolved = Resolve-RepoRoot -ExplicitRepo $selected
            $repoText.Text = $resolved
            Append-Log $logBox "Skill repo set to: $resolved"
        } catch {
            [System.Windows.Forms.MessageBox]::Show($_.Exception.Message, 'Invalid skill repo', 'OK', 'Error') | Out-Null
        }
    }
})

$projectButton.Add_Click({
    $selected = Select-Folder -Description 'Choose target research project repo' -InitialPath $projectText.Text
    if ($selected) {
        $projectText.Text = $selected
        Append-Log $logBox "Target repo set to: $selected"
    }
})

$openButton.Add_Click({
    if ($projectText.Text -and (Test-Path -LiteralPath $projectText.Text -PathType Container)) {
        Start-Process explorer.exe $projectText.Text
    }
})

$closeButton.Add_Click({ $form.Close() })

$installButton.Add_Click({
    $installButton.Enabled = $false
    $form.Cursor = [System.Windows.Forms.Cursors]::WaitCursor
    try {
        Run-Installer `
            -RepoRoot $repoText.Text `
            -TargetProject $projectText.Text `
            -SelectedPlatform ([string]$platformCombo.SelectedItem) `
            -SelectedProfile ([string]$profileCombo.SelectedItem) `
            -Reconcile $reconcileCheck.Checked `
            -DryRun $dryRunCheck.Checked `
            -LogBox $logBox
        [System.Windows.Forms.MessageBox]::Show('Install completed.', 'debuffer-skills', 'OK', 'Information') | Out-Null
    } catch {
        Append-Log $logBox $_.Exception.Message
        [System.Windows.Forms.MessageBox]::Show($_.Exception.Message, 'Install failed', 'OK', 'Error') | Out-Null
    } finally {
        $form.Cursor = [System.Windows.Forms.Cursors]::Default
        $installButton.Enabled = $true
    }
})

Append-Log $logBox "Ready."
Append-Log $logBox "Skill repo: $repoRoot"
Append-Log $logBox "Choose a target repo, then click Install."

[void]$form.ShowDialog()
