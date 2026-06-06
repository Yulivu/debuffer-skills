#Requires -Version 5.1
<#
.SYNOPSIS
    Minimal GUI manager for debuffer-skills.
#>

[CmdletBinding()]
param(
    [string]$SkillRepo = '',
    [string]$ProjectPath = '',
    [ValidateSet('auto', 'claude', 'codex')]
    [string]$Platform = 'codex',
    [ValidateSet('core-research', 'paper', 'review', 'full', 'full-flat')]
    [string]$Profile = 'full',
    [switch]$ValidateOnly
)

$ErrorActionPreference = 'Stop'
try {
    [Console]::OutputEncoding = New-Object System.Text.UTF8Encoding($false)
    $OutputEncoding = [Console]::OutputEncoding
} catch {}

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

function T {
    param([string]$Value)
    return [System.Text.RegularExpressions.Regex]::Unescape($Value)
}

$Ui = @{
    Title = T '\u6280\u80fd\u5305\u7ba1\u7406\u5668'
    Intro = T '\u5b89\u88c5\u5230\u9879\u76ee\uff0c\u6216\u66f4\u65b0\u5df2\u767b\u8bb0\u9879\u76ee\u3002'
    Project = T '\u9879\u76ee\u76ee\u5f55'
    Choose = T '\u9009\u62e9'
    Scope = T '\u5b89\u88c5\u8303\u56f4'
    Full = T '\u5206\u5c42\u5b8c\u6574\uff08\u9ed8\u8ba4\uff09'
    FullFlat = T '\u5b8c\u6574\u76f4\u8c03\u7248'
    Core = T '\u79d1\u7814\u6838\u5fc3'
    Paper = T '\u8bba\u6587\u5199\u4f5c'
    Review = T '\u8bc4\u5ba1\u5ba1\u8ba1'
    Preview = T '\u53ea\u9884\u89c8\uff0c\u4e0d\u4fee\u6539'
    Registry = T '\u5df2\u767b\u8bb0\u9879\u76ee\uff1a{0}'
    Install = T '\u5b89\u88c5/\u91cd\u8fde'
    Update = T '\u66f4\u65b0\u5168\u90e8'
    UpdateGitHub = T '\u4ece GitHub \u66f4\u65b0'
    Discover = T '\u626b\u63cf\u65e7\u9879\u76ee'
    Open = T '\u6253\u5f00\u9879\u76ee'
    Close = T '\u5173\u95ed'
    Ready = T '\u5c31\u7eea\u3002'
    SkillRepo = T '\u6280\u80fd\u5e93\uff1a{0}'
    DefaultScope = T '\u9ed8\u8ba4\u5b89\u88c5\u8303\u56f4\uff1a\u5206\u5c42\u5b8c\u6574'
    SelectProject = T '\u8bf7\u9009\u62e9\u9879\u76ee\u76ee\u5f55\u3002'
    SelectProjectFolder = T '\u9009\u62e9\u8981\u5b89\u88c5\u6280\u80fd\u7684\u9879\u76ee\u76ee\u5f55'
    SelectScanFolder = T '\u9009\u62e9\u8981\u626b\u63cf\u7684\u4e0a\u7ea7\u76ee\u5f55'
    ProjectSet = T '\u9879\u76ee\u76ee\u5f55\uff1a{0}'
    InvalidRepo = T '\u4e0d\u662f\u6709\u6548\u7684 debuffer-skills \u76ee\u5f55\uff1a{0}'
    RepoMissing = T '\u65e0\u6cd5\u5b9a\u4f4d debuffer-skills \u76ee\u5f55\uff1a{0}'
    MissingTool = T '\u7f3a\u5c11\u5fc5\u8981\u5de5\u5177\uff1a{0}'
    InstallerMissing = T '\u627e\u4e0d\u5230\u5b89\u88c5\u5668\uff1a{0}'
    UpdaterMissing = T '\u627e\u4e0d\u5230\u66f4\u65b0\u5668\uff1a{0}'
    RepoUpdaterMissing = T '\u627e\u4e0d\u5230 GitHub \u66f4\u65b0\u5668\uff1a{0}'
    ScannerMissing = T '\u627e\u4e0d\u5230\u626b\u63cf\u5668\uff1a{0}'
    ProjectMissing = T '\u9879\u76ee\u76ee\u5f55\u4e0d\u5b58\u5728\uff1a{0}'
    ScanMissing = T '\u626b\u63cf\u76ee\u5f55\u4e0d\u5b58\u5728\uff1a{0}'
    SameRepo = T '\u76ee\u6807\u9879\u76ee\u4e0d\u80fd\u662f\u6280\u80fd\u5e93\u672c\u8eab\u3002'
    Running = T '\u6267\u884c\u4e2d...'
    ExitCode = T '\u547d\u4ee4\u5931\u8d25\uff0c\u9000\u51fa\u7801\uff1a{0}'
    InstallDone = T '\u5b89\u88c5/\u91cd\u8fde\u5b8c\u6210\u3002'
    UpdateDone = T '\u66f4\u65b0\u5168\u90e8\u5b8c\u6210\u3002'
    UpdateGitHubDone = T '\u5df2\u4ece GitHub \u66f4\u65b0\u6280\u80fd\u5e93\uff0c\u5e76\u540c\u6b65\u5df2\u767b\u8bb0\u9879\u76ee\u3002'
    PreviewDone = T '\u66f4\u65b0\u9884\u89c8\u5b8c\u6210\u3002'
    UpdateGitHubPreviewDone = T '\u5df2\u9884\u89c8 GitHub \u66f4\u65b0\u4e0e\u9879\u76ee\u540c\u6b65\u3002'
    DiscoverDone = T '\u626b\u63cf\u5b8c\u6210\u3002'
    Failed = T '\u64cd\u4f5c\u5931\u8d25'
    ValidateOk = T '\u56fe\u5f62\u754c\u9762\u6821\u9a8c\u901a\u8fc7\u3002'
    DefaultProfile = T '\u9ed8\u8ba4\u8303\u56f4\uff1afull\uff08\u5206\u5c42\u5b8c\u6574\uff09'
}

function Resolve-RepoRoot {
    param([string]$ExplicitRepo)
    if ($ExplicitRepo) {
        $candidate = (Resolve-Path -LiteralPath $ExplicitRepo).ProviderPath
        if (Test-Path -LiteralPath (Join-Path $candidate 'tools\install_debuffer.ps1') -PathType Leaf) {
            return $candidate
        }
        throw ($Ui.InvalidRepo -f $candidate)
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
    throw ($Ui.RepoMissing -f $PSScriptRoot)
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

function Invoke-Tool {
    param(
        [string]$RepoRoot,
        [string[]]$Arguments,
        [System.Windows.Forms.TextBox]$LogBox,
        [string]$DoneText
    )

    Append-Log $LogBox ''
    Append-Log $LogBox $Ui.Running

    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = 'powershell'
    $psi.Arguments = ($Arguments | ForEach-Object { Quote-ProcessArgument $_ }) -join ' '
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
        throw ($Ui.ExitCode -f $process.ExitCode)
    }
    Append-Log $LogBox $DoneText
}

function Get-ProfileValue {
    param([string]$DisplayText)
    if ($DisplayText -eq $Ui.Core) { return 'core-research' }
    if ($DisplayText -eq $Ui.Paper) { return 'paper' }
    if ($DisplayText -eq $Ui.Review) { return 'review' }
    if ($DisplayText -eq $Ui.FullFlat) { return 'full-flat' }
    return 'full'
}

function Get-ProfileDisplay {
    param([string]$Value)
    switch ($Value) {
        'core-research' { return $Ui.Core }
        'paper' { return $Ui.Paper }
        'review' { return $Ui.Review }
        'full-flat' { return $Ui.FullFlat }
        default { return $Ui.Full }
    }
}

function Get-RegistryText {
    param([string]$RepoRoot)
    $path = Join-Path $RepoRoot '.debuffer_registry\installed-projects.tsv'
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        return ($Ui.Registry -f 0)
    }
    $count = 0
    foreach ($line in Get-Content -LiteralPath $path -Encoding UTF8) {
        if (-not $line.StartsWith('#') -and $line.Trim()) { $count++ }
    }
    return ($Ui.Registry -f $count)
}

function Run-Installer {
    param(
        [string]$RepoRoot,
        [string]$TargetProject,
        [string]$SelectedProfile,
        [bool]$PreviewOnly,
        [System.Windows.Forms.TextBox]$LogBox
    )

    $installer = Join-Path $RepoRoot 'tools\install_debuffer.ps1'
    if (-not (Test-Path -LiteralPath $installer -PathType Leaf)) {
        throw ($Ui.InstallerMissing -f $installer)
    }
    if ([string]::IsNullOrWhiteSpace($TargetProject)) {
        throw $Ui.SelectProject
    }
    if (-not (Test-Path -LiteralPath $TargetProject -PathType Container)) {
        throw ($Ui.ProjectMissing -f $TargetProject)
    }
    if (Same-Path $RepoRoot $TargetProject) {
        throw $Ui.SameRepo
    }

    $args = @(
        '-NoProfile',
        '-ExecutionPolicy', 'Bypass',
        '-File', $installer,
        $TargetProject,
        '-Platform', $Platform,
        '-Repo', $RepoRoot,
        '-Profile', $SelectedProfile
    )
    if ($PreviewOnly) { $args += '-DryRun' }
    Invoke-Tool -RepoRoot $RepoRoot -Arguments $args -LogBox $LogBox -DoneText $Ui.InstallDone
}

function Run-RegistryUpdate {
    param(
        [string]$RepoRoot,
        [bool]$PreviewOnly,
        [System.Windows.Forms.TextBox]$LogBox
    )

    $updater = Join-Path $RepoRoot 'tools\reconcile_debuffer_installs.ps1'
    if (-not (Test-Path -LiteralPath $updater -PathType Leaf)) {
        throw ($Ui.UpdaterMissing -f $updater)
    }
    $args = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $updater)
    if (-not $PreviewOnly) { $args += '-Apply' }
    $done = if ($PreviewOnly) { $Ui.PreviewDone } else { $Ui.UpdateDone }
    Invoke-Tool -RepoRoot $RepoRoot -Arguments $args -LogBox $LogBox -DoneText $done
}

function Run-GitHubUpdate {
    param(
        [string]$RepoRoot,
        [bool]$PreviewOnly,
        [System.Windows.Forms.TextBox]$LogBox
    )

    $repoUpdater = Join-Path $RepoRoot 'tools\update_debuffer_repo.ps1'
    if (-not (Test-Path -LiteralPath $repoUpdater -PathType Leaf)) {
        throw ($Ui.RepoUpdaterMissing -f $repoUpdater)
    }
    $args = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $repoUpdater)
    if ($PreviewOnly) { $args += '-DryRun' }
    Invoke-Tool -RepoRoot $RepoRoot -Arguments $args -LogBox $LogBox -DoneText ''
    Run-RegistryUpdate -RepoRoot $RepoRoot -PreviewOnly $PreviewOnly -LogBox $LogBox
}

function Run-RegistryDiscover {
    param(
        [string]$RepoRoot,
        [string]$DiscoverRoot,
        [System.Windows.Forms.TextBox]$LogBox
    )

    $updater = Join-Path $RepoRoot 'tools\reconcile_debuffer_installs.ps1'
    if (-not (Test-Path -LiteralPath $updater -PathType Leaf)) {
        throw ($Ui.ScannerMissing -f $updater)
    }
    if (-not (Test-Path -LiteralPath $DiscoverRoot -PathType Container)) {
        throw ($Ui.ScanMissing -f $DiscoverRoot)
    }
    $args = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $updater, '-DiscoverRoot', $DiscoverRoot, '-List')
    Invoke-Tool -RepoRoot $RepoRoot -Arguments $args -LogBox $LogBox -DoneText $Ui.DiscoverDone
}

function New-Button {
    param([string]$Text, [int]$Width)
    $button = New-Object System.Windows.Forms.Button
    $button.Text = $Text
    $button.Width = $Width
    $button.Height = 32
    $button.Margin = New-Object System.Windows.Forms.Padding(6, 2, 0, 2)
    $button.FlatStyle = 'Flat'
    $button.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(205, 210, 218)
    $button.BackColor = [System.Drawing.Color]::FromArgb(246, 247, 249)
    $button.ForeColor = [System.Drawing.Color]::FromArgb(30, 35, 42)
    $button.UseVisualStyleBackColor = $false
    return $button
}

$repoRoot = Resolve-RepoRoot -ExplicitRepo $SkillRepo

if ($ValidateOnly) {
    foreach ($required in @('tools\install_debuffer.ps1', 'tools\reconcile_debuffer_installs.ps1', 'tools\update_debuffer_repo.ps1')) {
        $path = Join-Path $repoRoot $required
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
            throw ($Ui.MissingTool -f $path)
        }
    }
    Write-Host $Ui.ValidateOk
    Write-Host ($Ui.SkillRepo -f $repoRoot)
    Write-Host $Ui.DefaultProfile
    exit 0
}

$form = New-Object System.Windows.Forms.Form
$form.Text = $Ui.Title
$form.StartPosition = 'CenterScreen'
$form.Size = New-Object System.Drawing.Size(680, 430)
$form.MinimumSize = New-Object System.Drawing.Size(640, 400)
$form.Font = New-Object System.Drawing.Font('Microsoft YaHei UI', 9)
$form.BackColor = [System.Drawing.Color]::White

$main = New-Object System.Windows.Forms.TableLayoutPanel
$main.Dock = 'Fill'
$main.Padding = New-Object System.Windows.Forms.Padding(14)
$main.ColumnCount = 1
$main.RowCount = 5
$main.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent, 100))) | Out-Null
foreach ($height in @(50, 36, 36, 40, 0)) {
    if ($height -eq 0) {
        $main.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent, 100))) | Out-Null
    } else {
        $main.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute, $height))) | Out-Null
    }
}
$form.Controls.Add($main)

$titlePanel = New-Object System.Windows.Forms.Panel
$titlePanel.Dock = 'Fill'
$titleLabel = New-Object System.Windows.Forms.Label
$titleLabel.Text = $Ui.Title
$titleLabel.Font = New-Object System.Drawing.Font('Microsoft YaHei UI', 15, [System.Drawing.FontStyle]::Bold)
$titleLabel.AutoSize = $true
$titleLabel.Location = New-Object System.Drawing.Point(0, 0)
$introLabel = New-Object System.Windows.Forms.Label
$introLabel.Text = $Ui.Intro
$introLabel.AutoSize = $true
$introLabel.ForeColor = [System.Drawing.Color]::FromArgb(88, 88, 88)
$introLabel.Location = New-Object System.Drawing.Point(2, 30)
$titlePanel.Controls.Add($titleLabel)
$titlePanel.Controls.Add($introLabel)
$main.Controls.Add($titlePanel, 0, 0)

$projectPanel = New-Object System.Windows.Forms.TableLayoutPanel
$projectPanel.Dock = 'Fill'
$projectPanel.ColumnCount = 3
$projectPanel.RowCount = 1
$projectPanel.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Absolute, 72))) | Out-Null
$projectPanel.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent, 100))) | Out-Null
$projectPanel.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Absolute, 78))) | Out-Null
$projectLabel = New-Object System.Windows.Forms.Label
$projectLabel.Text = $Ui.Project
$projectLabel.TextAlign = 'MiddleLeft'
$projectText = New-Object System.Windows.Forms.TextBox
$projectText.Text = $ProjectPath
$projectText.Dock = 'Fill'
$projectText.BorderStyle = 'FixedSingle'
$projectButton = New-Button -Text $Ui.Choose -Width 70
$projectButton.Dock = 'Fill'
$projectPanel.Controls.Add($projectLabel, 0, 0)
$projectPanel.Controls.Add($projectText, 1, 0)
$projectPanel.Controls.Add($projectButton, 2, 0)
$main.Controls.Add($projectPanel, 0, 1)

$optionPanel = New-Object System.Windows.Forms.FlowLayoutPanel
$optionPanel.Dock = 'Fill'
$optionPanel.FlowDirection = 'LeftToRight'
$optionPanel.WrapContents = $false
$scopeLabel = New-Object System.Windows.Forms.Label
$scopeLabel.Text = $Ui.Scope
$scopeLabel.TextAlign = 'MiddleLeft'
$scopeLabel.Width = 72
$profileCombo = New-Object System.Windows.Forms.ComboBox
$profileCombo.DropDownStyle = 'DropDownList'
[void]$profileCombo.Items.AddRange([object[]]@($Ui.Full, $Ui.Core, $Ui.Paper, $Ui.Review, $Ui.FullFlat))
$profileCombo.SelectedItem = Get-ProfileDisplay $Profile
if (-not $profileCombo.SelectedItem) { $profileCombo.SelectedIndex = 0 }
$profileCombo.Width = 160
$previewCheck = New-Object System.Windows.Forms.CheckBox
$previewCheck.Text = $Ui.Preview
$previewCheck.AutoSize = $true
$previewCheck.Margin = New-Object System.Windows.Forms.Padding(16, 7, 0, 0)
$registryLabel = New-Object System.Windows.Forms.Label
$registryLabel.Text = Get-RegistryText $repoRoot
$registryLabel.AutoSize = $true
$registryLabel.Margin = New-Object System.Windows.Forms.Padding(18, 8, 0, 0)
$optionPanel.Controls.Add($scopeLabel)
$optionPanel.Controls.Add($profileCombo)
$optionPanel.Controls.Add($previewCheck)
$optionPanel.Controls.Add($registryLabel)
$main.Controls.Add($optionPanel, 0, 2)

$buttonPanel = New-Object System.Windows.Forms.FlowLayoutPanel
$buttonPanel.Dock = 'Fill'
$buttonPanel.FlowDirection = 'LeftToRight'
$buttonPanel.WrapContents = $false
$installButton = New-Button -Text $Ui.Install -Width 96
$updateButton = New-Button -Text $Ui.Update -Width 96
$updateGitHubButton = New-Button -Text $Ui.UpdateGitHub -Width 116
$discoverButton = New-Button -Text $Ui.Discover -Width 104
$openButton = New-Button -Text $Ui.Open -Width 88
$closeButton = New-Button -Text $Ui.Close -Width 72
$buttonPanel.Controls.Add($installButton)
$buttonPanel.Controls.Add($updateButton)
$buttonPanel.Controls.Add($updateGitHubButton)
$buttonPanel.Controls.Add($discoverButton)
$buttonPanel.Controls.Add($openButton)
$buttonPanel.Controls.Add($closeButton)
$main.Controls.Add($buttonPanel, 0, 3)
$installButton.BackColor = [System.Drawing.Color]::FromArgb(36, 99, 235)
$installButton.ForeColor = [System.Drawing.Color]::White
$installButton.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(36, 99, 235)

$logBox = New-Object System.Windows.Forms.TextBox
$logBox.Multiline = $true
$logBox.ScrollBars = 'Both'
$logBox.ReadOnly = $true
$logBox.WordWrap = $false
$logBox.Dock = 'Fill'
$logBox.Font = New-Object System.Drawing.Font('Consolas', 9)
$logBox.BackColor = [System.Drawing.Color]::FromArgb(250, 250, 250)
$main.Controls.Add($logBox, 0, 4)

function Refresh-RegistryLabel {
    $registryLabel.Text = Get-RegistryText $repoRoot
}

function Set-Busy {
    param([bool]$Busy)
    foreach ($button in @($installButton, $updateButton, $updateGitHubButton, $discoverButton, $projectButton, $openButton, $closeButton)) {
        $button.Enabled = -not $Busy
    }
    $form.Cursor = if ($Busy) { [System.Windows.Forms.Cursors]::WaitCursor } else { [System.Windows.Forms.Cursors]::Default }
}

function Show-Failure {
    param([string]$Message)
    Append-Log $logBox $Message
    [System.Windows.Forms.MessageBox]::Show($Message, $Ui.Failed, [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error) | Out-Null
}

$projectButton.Add_Click({
    $selected = Select-Folder -Description $Ui.SelectProjectFolder -InitialPath $projectText.Text
    if ($selected) {
        $projectText.Text = $selected
        Append-Log $logBox ($Ui.ProjectSet -f $selected)
    }
})

$installButton.Add_Click({
    Set-Busy $true
    try {
        Run-Installer `
            -RepoRoot $repoRoot `
            -TargetProject $projectText.Text `
            -SelectedProfile (Get-ProfileValue ([string]$profileCombo.SelectedItem)) `
            -PreviewOnly $previewCheck.Checked `
            -LogBox $logBox
        Refresh-RegistryLabel
        [System.Windows.Forms.MessageBox]::Show($Ui.InstallDone, $Ui.Title, [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information) | Out-Null
    } catch {
        Show-Failure $_.Exception.Message
    } finally {
        Set-Busy $false
    }
})

$updateButton.Add_Click({
    Set-Busy $true
    try {
        Run-RegistryUpdate -RepoRoot $repoRoot -PreviewOnly $previewCheck.Checked -LogBox $logBox
        Refresh-RegistryLabel
        if (-not $previewCheck.Checked) {
            [System.Windows.Forms.MessageBox]::Show($Ui.UpdateDone, $Ui.Title, [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information) | Out-Null
        }
    } catch {
        Show-Failure $_.Exception.Message
    } finally {
        Set-Busy $false
    }
})

$updateGitHubButton.Add_Click({
    Set-Busy $true
    try {
        Run-GitHubUpdate -RepoRoot $repoRoot -PreviewOnly $previewCheck.Checked -LogBox $logBox
        Refresh-RegistryLabel
        $doneText = if ($previewCheck.Checked) { $Ui.UpdateGitHubPreviewDone } else { $Ui.UpdateGitHubDone }
        [System.Windows.Forms.MessageBox]::Show($doneText, $Ui.Title, [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information) | Out-Null
    } catch {
        Show-Failure $_.Exception.Message
    } finally {
        Set-Busy $false
    }
})

$discoverButton.Add_Click({
    $selected = Select-Folder -Description $Ui.SelectScanFolder -InitialPath ([Environment]::GetFolderPath('Desktop'))
    if (-not $selected) { return }
    Set-Busy $true
    try {
        Run-RegistryDiscover -RepoRoot $repoRoot -DiscoverRoot $selected -LogBox $logBox
        Refresh-RegistryLabel
        [System.Windows.Forms.MessageBox]::Show($Ui.DiscoverDone, $Ui.Title, [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information) | Out-Null
    } catch {
        Show-Failure $_.Exception.Message
    } finally {
        Set-Busy $false
    }
})

$openButton.Add_Click({
    if ($projectText.Text -and (Test-Path -LiteralPath $projectText.Text -PathType Container)) {
        Start-Process explorer.exe -ArgumentList @("`"$($projectText.Text)`"")
    }
})

$closeButton.Add_Click({ $form.Close() })

Append-Log $logBox $Ui.Ready
Append-Log $logBox ($Ui.SkillRepo -f $repoRoot)
Append-Log $logBox $Ui.DefaultScope

[void]$form.ShowDialog()
