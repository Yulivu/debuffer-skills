#Requires -Version 5.1
<#
.SYNOPSIS
    GUI manager for project-local debuffer-skills installs.

.DESCRIPTION
    Launch from the debuffer-skills repo. The window can install skills into a
    selected project, discover older installs, or update every registered
    project from the local registry.
#>

[CmdletBinding()]
param(
    [string]$SkillRepo = '',
    [string]$ProjectPath = '',
    [ValidateSet('auto', 'claude', 'codex')]
    [string]$Platform = 'codex',
    [ValidateSet('core-research', 'paper', 'review', 'full')]
    [string]$Profile = 'full',
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

function Invoke-PowerShellTool {
    param(
        [string]$RepoRoot,
        [string[]]$Arguments,
        [System.Windows.Forms.TextBox]$LogBox,
        [string]$DoneText
    )

    $displayArgs = ($Arguments | ForEach-Object { Quote-ProcessArgument $_ }) -join ' '
    Append-Log $LogBox ''
    Append-Log $LogBox "PS> powershell $displayArgs"

    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = 'powershell'
    $psi.Arguments = $displayArgs
    $psi.WorkingDirectory = $RepoRoot
    $psi.UseShellExecute = $false
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.CreateNoWindow = $true

    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $psi
    [void]$process.Start()
    $stdoutTask = $process.StandardOutput.ReadToEndAsync()
    $stderrTask = $process.StandardError.ReadToEndAsync()
    $process.WaitForExit()
    $stdout = $stdoutTask.Result
    $stderr = $stderrTask.Result

    if ($stdout) { Append-Log $LogBox $stdout }
    if ($stderr) { Append-Log $LogBox $stderr }
    if ($process.ExitCode -ne 0) {
        throw "Command exited with code $($process.ExitCode)."
    }
    Append-Log $LogBox $DoneText
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

    Invoke-PowerShellTool -RepoRoot $RepoRoot -Arguments $args -LogBox $LogBox -DoneText 'Install command completed.'
}

function Run-RegistryUpdate {
    param(
        [string]$RepoRoot,
        [bool]$Apply,
        [bool]$Prune,
        [System.Windows.Forms.TextBox]$LogBox
    )

    $updater = Join-Path $RepoRoot 'tools\reconcile_debuffer_installs.ps1'
    if (-not (Test-Path -LiteralPath $updater -PathType Leaf)) {
        throw "Updater not found: $updater"
    }
    $args = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $updater)
    if ($Apply) { $args += '-Apply' }
    if ($Prune) { $args += '-Prune' }
    $done = $(if ($Apply) { 'Update command completed.' } else { 'Update preview completed.' })
    Invoke-PowerShellTool -RepoRoot $RepoRoot -Arguments $args -LogBox $LogBox -DoneText $done
}

function Run-RegistryDiscover {
    param(
        [string]$RepoRoot,
        [string]$DiscoverRoot,
        [System.Windows.Forms.TextBox]$LogBox
    )

    $updater = Join-Path $RepoRoot 'tools\reconcile_debuffer_installs.ps1'
    if (-not (Test-Path -LiteralPath $updater -PathType Leaf)) {
        throw "Updater not found: $updater"
    }
    if (-not (Test-Path -LiteralPath $DiscoverRoot -PathType Container)) {
        throw "Discovery root does not exist: $DiscoverRoot"
    }
    $args = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $updater, '-DiscoverRoot', $DiscoverRoot, '-List')
    Invoke-PowerShellTool -RepoRoot $RepoRoot -Arguments $args -LogBox $LogBox -DoneText 'Discovery completed.'
}

function Get-RegistryText {
    param([string]$RepoRoot)
    $path = Join-Path $RepoRoot '.debuffer_registry\installed-projects.tsv'
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        return 'Registry: none yet'
    }
    $count = 0
    foreach ($line in Get-Content -LiteralPath $path -Encoding UTF8) {
        if (-not $line.StartsWith('#') -and $line.Trim()) { $count++ }
    }
    return "Registry: $count project(s)"
}

function New-UiButton {
    param([string]$Text, [int]$Width = 128)
    $button = New-Object System.Windows.Forms.Button
    $button.Text = $Text
    $button.Width = $Width
    $button.Height = 32
    $button.Margin = New-Object System.Windows.Forms.Padding(6, 4, 0, 4)
    $button.UseVisualStyleBackColor = $true
    return $button
}

$repoRoot = Resolve-RepoRoot -ExplicitRepo $SkillRepo

if ($ValidateOnly) {
    foreach ($required in @('tools\install_debuffer.ps1', 'tools\reconcile_debuffer_installs.ps1')) {
        $path = Join-Path $repoRoot $required
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
            throw "Required tool not found: $path"
        }
    }
    Write-Host 'GUI manager validation ok.'
    Write-Host "Skill repo: $repoRoot"
    Write-Host "Default profile: $Profile"
    exit 0
}

$form = New-Object System.Windows.Forms.Form
$form.Text = 'Debuffer Skills Manager'
$form.StartPosition = 'CenterScreen'
$form.Size = New-Object System.Drawing.Size(900, 680)
$form.MinimumSize = New-Object System.Drawing.Size(820, 600)
$form.Font = New-Object System.Drawing.Font('Segoe UI', 9)
$form.BackColor = [System.Drawing.Color]::FromArgb(247, 248, 250)

$main = New-Object System.Windows.Forms.TableLayoutPanel
$main.Dock = 'Fill'
$main.Padding = New-Object System.Windows.Forms.Padding(14)
$main.ColumnCount = 1
$main.RowCount = 5
$main.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent, 100))) | Out-Null
foreach ($height in @(78, 178, 104, 0, 46)) {
    if ($height -eq 0) {
        $main.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent, 100))) | Out-Null
    } else {
        $main.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute, $height))) | Out-Null
    }
}
$form.Controls.Add($main)

$header = New-Object System.Windows.Forms.Panel
$header.Dock = 'Fill'
$title = New-Object System.Windows.Forms.Label
$title.Text = 'debuffer-skills'
$title.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 18)
$title.AutoSize = $true
$title.Location = New-Object System.Drawing.Point(2, 2)
$subtitle = New-Object System.Windows.Forms.Label
$subtitle.Text = 'Install project-local skills, then update every registered project from one place.'
$subtitle.Font = New-Object System.Drawing.Font('Segoe UI', 10)
$subtitle.ForeColor = [System.Drawing.Color]::FromArgb(80, 86, 96)
$subtitle.AutoSize = $true
$subtitle.Location = New-Object System.Drawing.Point(4, 42)
$header.Controls.Add($title)
$header.Controls.Add($subtitle)
$main.Controls.Add($header, 0, 0)

$installGroup = New-Object System.Windows.Forms.GroupBox
$installGroup.Text = 'Install or reconcile one project'
$installGroup.Dock = 'Fill'
$installGroup.Padding = New-Object System.Windows.Forms.Padding(12)
$installLayout = New-Object System.Windows.Forms.TableLayoutPanel
$installLayout.Dock = 'Fill'
$installLayout.ColumnCount = 3
$installLayout.RowCount = 4
$installLayout.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Absolute, 92))) | Out-Null
$installLayout.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent, 100))) | Out-Null
$installLayout.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Absolute, 118))) | Out-Null
foreach ($height in @(34, 34, 34, 42)) {
    $installLayout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute, $height))) | Out-Null
}
$installGroup.Controls.Add($installLayout)
$main.Controls.Add($installGroup, 0, 1)

$repoLabel = New-Object System.Windows.Forms.Label
$repoLabel.Text = 'Skill repo'
$repoLabel.TextAlign = 'MiddleLeft'
$repoText = New-Object System.Windows.Forms.TextBox
$repoText.Text = $repoRoot
$repoText.ReadOnly = $true
$repoText.Dock = 'Fill'
$repoButton = New-UiButton -Text 'Change...'
$repoButton.Dock = 'Fill'

$projectLabel = New-Object System.Windows.Forms.Label
$projectLabel.Text = 'Target repo'
$projectLabel.TextAlign = 'MiddleLeft'
$projectText = New-Object System.Windows.Forms.TextBox
$projectText.Text = $ProjectPath
$projectText.Dock = 'Fill'
$projectButton = New-UiButton -Text 'Choose...'
$projectButton.Dock = 'Fill'

$profileLabel = New-Object System.Windows.Forms.Label
$profileLabel.Text = 'Profile'
$profileLabel.TextAlign = 'MiddleLeft'
$profilePanel = New-Object System.Windows.Forms.FlowLayoutPanel
$profilePanel.Dock = 'Fill'
$profilePanel.FlowDirection = 'LeftToRight'
$profilePanel.WrapContents = $false
$profileCombo = New-Object System.Windows.Forms.ComboBox
$profileCombo.DropDownStyle = 'DropDownList'
[void]$profileCombo.Items.AddRange(@('full', 'core-research', 'paper', 'review'))
$profileCombo.SelectedItem = $Profile
if (-not $profileCombo.SelectedItem) { $profileCombo.SelectedItem = 'full' }
$profileCombo.Width = 180
$platformCombo = New-Object System.Windows.Forms.ComboBox
$platformCombo.DropDownStyle = 'DropDownList'
[void]$platformCombo.Items.AddRange(@('codex', 'claude', 'auto'))
$platformCombo.SelectedItem = $Platform
if (-not $platformCombo.SelectedItem) { $platformCombo.SelectedItem = 'codex' }
$platformCombo.Width = 130
$platformLabelSmall = New-Object System.Windows.Forms.Label
$platformLabelSmall.Text = 'Platform'
$platformLabelSmall.TextAlign = 'MiddleLeft'
$platformLabelSmall.Width = 58
$profilePanel.Controls.Add($profileCombo)
$profilePanel.Controls.Add($platformLabelSmall)
$profilePanel.Controls.Add($platformCombo)

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
$dryRunCheck.Text = 'Preview only'
$dryRunCheck.AutoSize = $true
$optionPanel.Controls.Add($reconcileCheck)
$optionPanel.Controls.Add($dryRunCheck)
$installButton = New-UiButton -Text 'Install' -Width 112
$installButton.Dock = 'Right'

$installLayout.Controls.Add($repoLabel, 0, 0)
$installLayout.Controls.Add($repoText, 1, 0)
$installLayout.Controls.Add($repoButton, 2, 0)
$installLayout.Controls.Add($projectLabel, 0, 1)
$installLayout.Controls.Add($projectText, 1, 1)
$installLayout.Controls.Add($projectButton, 2, 1)
$installLayout.Controls.Add($profileLabel, 0, 2)
$installLayout.Controls.Add($profilePanel, 1, 2)
$installLayout.SetColumnSpan($profilePanel, 2)
$installLayout.Controls.Add($optionLabel, 0, 3)
$installLayout.Controls.Add($optionPanel, 1, 3)
$installLayout.Controls.Add($installButton, 2, 3)

$updateGroup = New-Object System.Windows.Forms.GroupBox
$updateGroup.Text = 'Update registered projects'
$updateGroup.Dock = 'Fill'
$updateGroup.Padding = New-Object System.Windows.Forms.Padding(12)
$updateLayout = New-Object System.Windows.Forms.TableLayoutPanel
$updateLayout.Dock = 'Fill'
$updateLayout.ColumnCount = 2
$updateLayout.RowCount = 2
$updateLayout.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent, 100))) | Out-Null
$updateLayout.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Absolute, 452))) | Out-Null
$updateLayout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute, 34))) | Out-Null
$updateLayout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute, 38))) | Out-Null
$updateGroup.Controls.Add($updateLayout)
$main.Controls.Add($updateGroup, 0, 2)

$registryLabel = New-Object System.Windows.Forms.Label
$registryLabel.Text = Get-RegistryText $repoRoot
$registryLabel.TextAlign = 'MiddleLeft'
$registryLabel.Dock = 'Fill'
$pruneCheck = New-Object System.Windows.Forms.CheckBox
$pruneCheck.Text = 'Prune missing entries on update'
$pruneCheck.AutoSize = $true
$pruneCheck.Dock = 'Left'
$updateButtons = New-Object System.Windows.Forms.FlowLayoutPanel
$updateButtons.Dock = 'Fill'
$updateButtons.FlowDirection = 'RightToLeft'
$updateButtons.WrapContents = $false
$updateButton = New-UiButton -Text 'Update' -Width 112
$previewUpdateButton = New-UiButton -Text 'Preview' -Width 112
$discoverButton = New-UiButton -Text 'Discover...' -Width 112
$updateButtons.Controls.Add($updateButton)
$updateButtons.Controls.Add($previewUpdateButton)
$updateButtons.Controls.Add($discoverButton)
$updateLayout.Controls.Add($registryLabel, 0, 0)
$updateLayout.Controls.Add($pruneCheck, 1, 0)
$updateLayout.Controls.Add($updateButtons, 0, 1)
$updateLayout.SetColumnSpan($updateButtons, 2)

$logBox = New-Object System.Windows.Forms.TextBox
$logBox.Multiline = $true
$logBox.ScrollBars = 'Both'
$logBox.ReadOnly = $true
$logBox.WordWrap = $false
$logBox.Dock = 'Fill'
$logBox.Font = New-Object System.Drawing.Font('Consolas', 9)
$logBox.BackColor = [System.Drawing.Color]::FromArgb(255, 255, 255)
$main.Controls.Add($logBox, 0, 3)

$bottomPanel = New-Object System.Windows.Forms.FlowLayoutPanel
$bottomPanel.Dock = 'Fill'
$bottomPanel.FlowDirection = 'RightToLeft'
$closeButton = New-UiButton -Text 'Close' -Width 104
$openButton = New-UiButton -Text 'Open Target' -Width 116
$bottomPanel.Controls.Add($closeButton)
$bottomPanel.Controls.Add($openButton)
$main.Controls.Add($bottomPanel, 0, 4)

function Set-Busy {
    param([bool]$Busy)
    foreach ($button in @($installButton, $updateButton, $previewUpdateButton, $discoverButton, $repoButton, $projectButton, $openButton)) {
        $button.Enabled = -not $Busy
    }
    $form.Cursor = $(if ($Busy) { [System.Windows.Forms.Cursors]::WaitCursor } else { [System.Windows.Forms.Cursors]::Default })
}

$repoButton.Add_Click({
    $selected = Select-Folder -Description 'Choose debuffer-skills repo' -InitialPath $repoText.Text
    if ($selected) {
        try {
            $resolved = Resolve-RepoRoot -ExplicitRepo $selected
            $repoText.Text = $resolved
            $registryLabel.Text = Get-RegistryText $resolved
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
    Set-Busy $true
    try {
        Run-Installer `
            -RepoRoot $repoText.Text `
            -TargetProject $projectText.Text `
            -SelectedPlatform ([string]$platformCombo.SelectedItem) `
            -SelectedProfile ([string]$profileCombo.SelectedItem) `
            -Reconcile $reconcileCheck.Checked `
            -DryRun $dryRunCheck.Checked `
            -LogBox $logBox
        $registryLabel.Text = Get-RegistryText $repoText.Text
        [System.Windows.Forms.MessageBox]::Show('Install command completed.', 'debuffer-skills', 'OK', 'Information') | Out-Null
    } catch {
        Append-Log $logBox $_.Exception.Message
        [System.Windows.Forms.MessageBox]::Show($_.Exception.Message, 'Install failed', 'OK', 'Error') | Out-Null
    } finally {
        Set-Busy $false
    }
})

$previewUpdateButton.Add_Click({
    Set-Busy $true
    try {
        Run-RegistryUpdate -RepoRoot $repoText.Text -Apply $false -Prune $false -LogBox $logBox
        $registryLabel.Text = Get-RegistryText $repoText.Text
    } catch {
        Append-Log $logBox $_.Exception.Message
        [System.Windows.Forms.MessageBox]::Show($_.Exception.Message, 'Update preview failed', 'OK', 'Error') | Out-Null
    } finally {
        Set-Busy $false
    }
})

$updateButton.Add_Click({
    Set-Busy $true
    try {
        Run-RegistryUpdate -RepoRoot $repoText.Text -Apply $true -Prune $pruneCheck.Checked -LogBox $logBox
        $registryLabel.Text = Get-RegistryText $repoText.Text
        [System.Windows.Forms.MessageBox]::Show('Update command completed.', 'debuffer-skills', 'OK', 'Information') | Out-Null
    } catch {
        Append-Log $logBox $_.Exception.Message
        [System.Windows.Forms.MessageBox]::Show($_.Exception.Message, 'Update failed', 'OK', 'Error') | Out-Null
    } finally {
        Set-Busy $false
    }
})

$discoverButton.Add_Click({
    $selected = Select-Folder -Description 'Scan for existing debuffer installs under this folder' -InitialPath ([Environment]::GetFolderPath('Desktop'))
    if (-not $selected) { return }
    Set-Busy $true
    try {
        Run-RegistryDiscover -RepoRoot $repoText.Text -DiscoverRoot $selected -LogBox $logBox
        $registryLabel.Text = Get-RegistryText $repoText.Text
    } catch {
        Append-Log $logBox $_.Exception.Message
        [System.Windows.Forms.MessageBox]::Show($_.Exception.Message, 'Discovery failed', 'OK', 'Error') | Out-Null
    } finally {
        Set-Busy $false
    }
})

Append-Log $logBox 'Ready.'
Append-Log $logBox "Skill repo: $repoRoot"
Append-Log $logBox 'Default profile: full'

[void]$form.ShowDialog()
