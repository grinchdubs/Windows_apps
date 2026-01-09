# ============================================
# Windows App Installer
# A GUI tool to install common apps using winget or direct downloads
# ============================================

# EDIT THIS SECTION TO ADD/REMOVE APPS
#
# For WINGET apps:
#   @{Name="App Name"; Type="winget"; ID="winget.package.id"; Description="Short description"}
#
# For DIRECT DOWNLOAD apps:
#   @{Name="App Name"; Type="direct"; DownloadURL="https://..."; InstallerType="exe"; SilentArgs="/S"; Description="Short description"}
#   InstallerType can be: exe, msi, zip
#   SilentArgs: /S, /SILENT, /VERYSILENT (for exe) or /quiet, /qn (for msi)
#
# For COMMAND apps (runs PowerShell commands):
#   @{Name="App Name"; Type="command"; Command="your-command --flags"; Description="Short description"}
#
$AppList = @(
    @{Name="TouchDesigner"; Type="direct"; DownloadURL="https://download.derivative.ca/TouchDesigner.2023.12480.exe"; InstallerType="exe"; SilentArgs="/SILENT"; Description="Visual development platform"},
    @{Name="Inkscape"; Type="winget"; ID="Inkscape.Inkscape"; Description="Vector graphics editor"},
    @{Name="Blender"; Type="winget"; ID="BlenderFoundation.Blender"; Description="3D creation suite"},
    @{Name="Affinity"; Type="winget"; ID="Canva.Affinity"; Description="Graphic design, photo-editing and publishing suite"},
    @{Name="Visual Studio Code"; Type="winget"; ID="Microsoft.VisualStudioCode"; Description="Code editor"},
    @{Name="Sublime Text"; Type="winget"; ID="SublimeHQ.SublimeText.4"; Description="Text editor"},
    @{Name="Notion"; Type="winget"; ID="Notion.Notion"; Description="Productivity and notes"},
    @{Name="Firefox"; Type="winget"; ID="Mozilla.Firefox"; Description="Web browser"},
    @{Name="Discord"; Type="winget"; ID="Discord.Discord"; Description="Chat platform"},
    @{Name="Telegram"; Type="winget"; ID="Telegram.TelegramDesktop"; Description="Messaging app"},
    @{Name="Tailscale"; Type="winget"; ID="tailscale.tailscale"; Description="VPN mesh network"},
    @{Name="VLC Media Player"; Type="winget"; ID="VideoLAN.VLC"; Description="Media player"},
    @{Name="FFmpeg"; Type="winget"; ID="Gyan.FFmpeg"; Description="Multimedia framework"},
    @{Name="HandBrake"; Type="winget"; ID="HandBrake.HandBrake"; Description="Video transcoder"},
    @{Name="Upscayl"; Type="winget"; ID="Upscayl.Upscayl"; Description="AI image upscaler"},
    @{Name="H.264 Encoder"; Type="direct"; DownloadURL="https://file1.softsea.com/get.php?file=h264encoder_setup.exe"; InstallerType="exe"; SilentArgs="/S"; Description="Video encoder to H.264 format"},

    # Development Tools
    @{Name="Git"; Type="winget"; ID="Git.Git"; Description="Version control system"},
    @{Name="GitHub Desktop"; Type="winget"; ID="GitHub.GitHubDesktop"; Description="Git GUI client"},
    @{Name="Python 3.13"; Type="winget"; ID="Python.Python.3.13"; Description="Python programming language"},
    @{Name="Arduino IDE"; Type="winget"; ID="ArduinoSA.IDE.stable"; Description="Arduino development environment"},

    # System Tools
    @{Name="HWiNFO"; Type="winget"; ID="REALiX.HWiNFO"; Description="Hardware information and monitoring"},
    @{Name="WSL"; Type="command"; Command="wsl --install --no-distribution"; Description="Windows Subsystem for Linux (no distro)"},

    # Remote Access
    @{Name="AnyDesk"; Type="winget"; ID="AnyDesk.AnyDesk"; Description="Remote desktop software"},

    # Audio Production
    @{Name="Voicemeeter"; Type="winget"; ID="VB-Audio.Voicemeeter"; Description="Virtual audio mixer"},
    @{Name="ASIO4ALL"; Type="winget"; ID="MichaelTippach.ASIO4ALL"; Description="Universal ASIO driver"},
    @{Name="foobar2000"; Type="winget"; ID="PeterPawlowski.foobar2000"; Description="Advanced audio player"},
    @{Name="Expert Sleepers ES-9 Driver"; Type="direct"; DownloadURL="https://www.expert-sleepers.co.uk/downloads/drivers/ExpertSleepers_USBAudio_v5.72.0_2024-11-13_setup.exe"; InstallerType="exe"; SilentArgs="/SILENT"; Description="ES-9 USB audio interface driver"},

    # Networking & File Sharing
    @{Name="Angry IP Scanner"; Type="winget"; ID="angryziber.AngryIPScanner"; Description="Network scanner"},
    @{Name="LocalSend"; Type="winget"; ID="LocalSend.LocalSend"; Description="Local network file sharing"},

    # Hardware & Drivers
    @{Name="Azure Kinect SDK"; Type="direct"; DownloadURL="https://download.microsoft.com/download/3/d/6/3d6d9e99-a251-4cf3-8c6a-8e108e960b4b/Azure%20Kinect%20SDK%201.4.1.exe"; InstallerType="exe"; SilentArgs="/SILENT"; Description="Azure Kinect sensor drivers and SDK"}

    # Ableton Live - Requires manual download from Ableton account
    # To add Ableton: Download installer from https://www.ableton.com/account/ then uncomment and update the line below:
    # @{Name="Ableton Live"; Type="direct"; DownloadURL="PATH_TO_YOUR_DOWNLOADED_INSTALLER.exe"; InstallerType="exe"; SilentArgs="/SILENT"; Description="Digital audio workstation"}

    # Add more apps here following the format above
    # Note: Some installers may need different silent args. Try /S, /SILENT, or /VERYSILENT if installation fails
)

# ============================================
# Script Configuration
# ============================================
$LogFile = Join-Path $env:TEMP "AppInstaller_Log.txt"
$DownloadFolder = Join-Path $env:TEMP "AppInstallerDownloads"
$ErrorActionPreference = "Continue"

# Create download folder if it doesn't exist
if (-not (Test-Path $DownloadFolder)) {
    New-Item -ItemType Directory -Path $DownloadFolder -Force | Out-Null
}

# ============================================
# Functions
# ============================================

function Write-Log {
    param($Message, $Type = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Type] $Message"
    Add-Content -Path $LogFile -Value $logMessage
    Write-Host $logMessage
}

function Test-WingetInstalled {
    try {
        $winget = Get-Command winget -ErrorAction Stop
        return $true
    }
    catch {
        return $false
    }
}

function Install-Winget {
    Write-Log "Winget not found. Attempting to install..." "WARN"

    try {
        # Try to install App Installer from Microsoft Store
        $progressPreference = 'silentlyContinue'
        Write-Log "Installing App Installer (winget)..."

        # Download and install the latest App Installer
        $releases = "https://api.github.com/repos/microsoft/winget-cli/releases/latest"
        $downloadUrl = ((Invoke-RestMethod -Uri $releases).assets | Where-Object { $_.name -like "*.msixbundle" }).browser_download_url

        if ($downloadUrl) {
            $downloadPath = Join-Path $env:TEMP "Microsoft.DesktopAppInstaller.msixbundle"
            Invoke-WebRequest -Uri $downloadUrl -OutFile $downloadPath
            Add-AppxPackage -Path $downloadPath
            Write-Log "Winget installed successfully!" "SUCCESS"
            return $true
        }
        else {
            Write-Log "Could not find winget download URL" "ERROR"
            return $false
        }
    }
    catch {
        Write-Log "Failed to install winget: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Install-AppViaWinget {
    param($App, $StatusLabel, $LogBox)

    $appName = $App.Name
    $appID = $App.ID

    Write-Log "Starting winget installation: $appName ($appID)"

    try {
        # Run winget install
        $process = Start-Process -FilePath "winget" -ArgumentList "install --id $appID --source winget --exact --silent --disable-interactivity --accept-package-agreements --accept-source-agreements" -Wait -NoNewWindow -PassThru

        if ($process.ExitCode -eq 0) {
            Write-Log "$appName installed successfully" "SUCCESS"
            $LogBox.AppendText("[OK] $appName installed successfully`r`n")
            $LogBox.SelectionStart = $LogBox.Text.Length
            $LogBox.ScrollToCaret()
            return $true
        }
        else {
            Write-Log "$appName installation failed with exit code: $($process.ExitCode)" "ERROR"
            $LogBox.AppendText("[FAIL] $appName failed (Exit Code: $($process.ExitCode))`r`n")
            $LogBox.SelectionStart = $LogBox.Text.Length
            $LogBox.ScrollToCaret()
            return $false
        }
    }
    catch {
        Write-Log "$appName installation error: $($_.Exception.Message)" "ERROR"
        $LogBox.AppendText("[ERROR] $appName error: $($_.Exception.Message)`r`n")
        $LogBox.SelectionStart = $LogBox.Text.Length
        $LogBox.ScrollToCaret()
        return $false
    }
}

function Install-AppViaDirect {
    param($App, $StatusLabel, $LogBox)

    $appName = $App.Name
    $downloadURL = $App.DownloadURL
    $installerType = $App.InstallerType
    $silentArgs = $App.SilentArgs

    Write-Log "Starting direct download installation: $appName"
    Write-Log "Download URL: $downloadURL"

    try {
        # Determine file extension
        $extension = switch ($installerType.ToLower()) {
            "exe" { ".exe" }
            "msi" { ".msi" }
            "zip" { ".zip" }
            default { ".exe" }
        }

        $downloadPath = Join-Path $DownloadFolder "$appName$extension"

        # Download the installer
        $LogBox.AppendText("Downloading $appName...`r`n")
        $LogBox.SelectionStart = $LogBox.Text.Length
        $LogBox.ScrollToCaret()
        [System.Windows.Forms.Application]::DoEvents()

        Write-Log "Downloading from: $downloadURL to $downloadPath"

        $webClient = New-Object System.Net.WebClient
        $webClient.DownloadFile($downloadURL, $downloadPath)

        if (-not (Test-Path $downloadPath)) {
            throw "Download failed - file not found at $downloadPath"
        }

        Write-Log "Download complete. File size: $((Get-Item $downloadPath).Length) bytes"
        $LogBox.AppendText("Download complete. Installing...`r`n")
        $LogBox.SelectionStart = $LogBox.Text.Length
        $LogBox.ScrollToCaret()
        [System.Windows.Forms.Application]::DoEvents()

        # Install based on type
        if ($installerType -eq "exe") {
            Write-Log "Running EXE installer: $downloadPath $silentArgs"
            $process = Start-Process -FilePath $downloadPath -ArgumentList $silentArgs -Wait -PassThru

            if ($process.ExitCode -eq 0) {
                Write-Log "$appName installed successfully" "SUCCESS"
                $LogBox.AppendText("[OK] $appName installed successfully`r`n")
                $LogBox.SelectionStart = $LogBox.Text.Length
                $LogBox.ScrollToCaret()
                return $true
            }
            else {
                Write-Log "$appName installation failed with exit code: $($process.ExitCode)" "ERROR"
                $LogBox.AppendText("[FAIL] $appName failed (Exit Code: $($process.ExitCode))`r`n")
                $LogBox.SelectionStart = $LogBox.Text.Length
                $LogBox.ScrollToCaret()
                return $false
            }
        }
        elseif ($installerType -eq "msi") {
            Write-Log "Running MSI installer: msiexec /i `"$downloadPath`" $silentArgs"
            $process = Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$downloadPath`" $silentArgs" -Wait -PassThru

            if ($process.ExitCode -eq 0) {
                Write-Log "$appName installed successfully" "SUCCESS"
                $LogBox.AppendText("[OK] $appName installed successfully`r`n")
                $LogBox.SelectionStart = $LogBox.Text.Length
                $LogBox.ScrollToCaret()
                return $true
            }
            else {
                Write-Log "$appName installation failed with exit code: $($process.ExitCode)" "ERROR"
                $LogBox.AppendText("[FAIL] $appName failed (Exit Code: $($process.ExitCode))`r`n")
                $LogBox.SelectionStart = $LogBox.Text.Length
                $LogBox.ScrollToCaret()
                return $false
            }
        }
        elseif ($installerType -eq "zip") {
            # For ZIP files, just extract them
            $extractPath = Join-Path $env:ProgramFiles $appName
            Write-Log "Extracting ZIP to: $extractPath"
            Expand-Archive -Path $downloadPath -DestinationPath $extractPath -Force
            Write-Log "$appName extracted successfully" "SUCCESS"
            $LogBox.AppendText("[OK] $appName extracted to $extractPath`r`n")
            $LogBox.SelectionStart = $LogBox.Text.Length
            $LogBox.ScrollToCaret()
            return $true
        }
        else {
            Write-Log "Unknown installer type: $installerType" "ERROR"
            $LogBox.AppendText("[ERROR] Unknown installer type: $installerType`r`n")
            return $false
        }
    }
    catch {
        Write-Log "$appName installation error: $($_.Exception.Message)" "ERROR"
        $LogBox.AppendText("[ERROR] $appName error: $($_.Exception.Message)`r`n")
        $LogBox.SelectionStart = $LogBox.Text.Length
        $LogBox.ScrollToCaret()
        return $false
    }
}

function Install-AppViaCommand {
    param($App, $StatusLabel, $LogBox)

    $appName = $App.Name
    $command = $App.Command

    Write-Log "Starting command installation: $appName"
    Write-Log "Command: $command"

    try {
        $LogBox.AppendText("Running command...`r`n")
        $LogBox.SelectionStart = $LogBox.Text.Length
        $LogBox.ScrollToCaret()
        [System.Windows.Forms.Application]::DoEvents()

        # Execute the command
        $process = Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile", "-Command", $command -Wait -NoNewWindow -PassThru

        if ($process.ExitCode -eq 0) {
            Write-Log "$appName installed successfully" "SUCCESS"
            $LogBox.AppendText("[OK] $appName installed successfully`r`n")
            $LogBox.SelectionStart = $LogBox.Text.Length
            $LogBox.ScrollToCaret()
            return $true
        }
        else {
            Write-Log "$appName installation failed with exit code: $($process.ExitCode)" "ERROR"
            $LogBox.AppendText("[FAIL] $appName failed (Exit Code: $($process.ExitCode))`r`n")
            $LogBox.SelectionStart = $LogBox.Text.Length
            $LogBox.ScrollToCaret()
            return $false
        }
    }
    catch {
        Write-Log "$appName installation error: $($_.Exception.Message)" "ERROR"
        $LogBox.AppendText("[ERROR] $appName error: $($_.Exception.Message)`r`n")
        $LogBox.SelectionStart = $LogBox.Text.Length
        $LogBox.ScrollToCaret()
        return $false
    }
}

function Install-App {
    param($App, $StatusLabel, $ProgressBar, $LogBox)

    $appName = $App.Name
    $appType = $App.Type

    # Update UI
    $StatusLabel.Text = "Installing: $appName"
    $LogBox.AppendText("`r`n========================================`r`n")
    $LogBox.AppendText("Installing $appName...`r`n")
    $LogBox.SelectionStart = $LogBox.Text.Length
    $LogBox.ScrollToCaret()
    [System.Windows.Forms.Application]::DoEvents()

    if ($appType -eq "winget") {
        return Install-AppViaWinget -App $App -StatusLabel $StatusLabel -LogBox $LogBox
    }
    elseif ($appType -eq "direct") {
        return Install-AppViaDirect -App $App -StatusLabel $StatusLabel -LogBox $LogBox
    }
    elseif ($appType -eq "command") {
        return Install-AppViaCommand -App $App -StatusLabel $StatusLabel -LogBox $LogBox
    }
    else {
        Write-Log "Unknown app type: $appType" "ERROR"
        $LogBox.AppendText("[ERROR] Unknown app type: $appType`r`n")
        return $false
    }
}

# ============================================
# Main Script
# ============================================

# Initialize log
Write-Log "========================================"
Write-Log "App Installer Started"
Write-Log "Log file: $LogFile"
Write-Log "Download folder: $DownloadFolder"
Write-Log "========================================"

# Check if any winget apps exist in the list
$hasWingetApps = $AppList | Where-Object { $_.Type -eq "winget" }

# Check for winget only if we have winget apps
if ($hasWingetApps -and -not (Test-WingetInstalled)) {
    Add-Type -AssemblyName System.Windows.Forms
    $result = [System.Windows.Forms.MessageBox]::Show(
        "Winget is not installed but some apps require it. Would you like to install it now?",
        "Winget Required",
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Question
    )

    if ($result -eq [System.Windows.Forms.DialogResult]::Yes) {
        if (-not (Install-Winget)) {
            [System.Windows.Forms.MessageBox]::Show(
                "Failed to install winget. Winget apps will be skipped.`n`nLog file: $LogFile",
                "Installation Warning",
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Warning
            )
        }
    }
}

# Load Windows Forms
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Create main form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Windows App Installer"
$form.Size = New-Object System.Drawing.Size(600, 700)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false

# Title Label
$titleLabel = New-Object System.Windows.Forms.Label
$titleLabel.Location = New-Object System.Drawing.Point(10, 10)
$titleLabel.Size = New-Object System.Drawing.Size(560, 30)
$titleLabel.Text = "Select apps to install:"
$titleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($titleLabel)

# Create checkbox list panel
$checkboxPanel = New-Object System.Windows.Forms.Panel
$checkboxPanel.Location = New-Object System.Drawing.Point(10, 50)
$checkboxPanel.Size = New-Object System.Drawing.Size(560, 250)
$checkboxPanel.AutoScroll = $true
$checkboxPanel.BorderStyle = "FixedSingle"
$form.Controls.Add($checkboxPanel)

# Create checkboxes for each app
$checkboxes = @()
$yPos = 5
foreach ($app in $AppList) {
    $checkbox = New-Object System.Windows.Forms.CheckBox
    $checkbox.Location = New-Object System.Drawing.Point(10, $yPos)
    $checkbox.Size = New-Object System.Drawing.Size(520, 25)

    # Add type indicator to checkbox text
    $typeIndicator = switch ($app.Type) {
        "direct" { "[Direct DL]" }
        "command" { "[Command]" }
        default { "[Winget]" }
    }
    $checkbox.Text = "$typeIndicator $($app.Name) - $($app.Description)"

    $checkbox.Tag = $app
    $checkbox.Checked = $false
    $checkboxPanel.Controls.Add($checkbox)
    $checkboxes += $checkbox
    $yPos += 30
}

# Select/Deselect All buttons
$selectAllBtn = New-Object System.Windows.Forms.Button
$selectAllBtn.Location = New-Object System.Drawing.Point(10, 310)
$selectAllBtn.Size = New-Object System.Drawing.Size(120, 30)
$selectAllBtn.Text = "Select All"
$selectAllBtn.Add_Click({
    foreach ($cb in $checkboxes) {
        $cb.Checked = $true
    }
})
$form.Controls.Add($selectAllBtn)

$deselectAllBtn = New-Object System.Windows.Forms.Button
$deselectAllBtn.Location = New-Object System.Drawing.Point(140, 310)
$deselectAllBtn.Size = New-Object System.Drawing.Size(120, 30)
$deselectAllBtn.Text = "Deselect All"
$deselectAllBtn.Add_Click({
    foreach ($cb in $checkboxes) {
        $cb.Checked = $false
    }
})
$form.Controls.Add($deselectAllBtn)

# Progress bar
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(10, 350)
$progressBar.Size = New-Object System.Drawing.Size(560, 20)
$form.Controls.Add($progressBar)

# Status label
$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Location = New-Object System.Drawing.Point(10, 375)
$statusLabel.Size = New-Object System.Drawing.Size(560, 20)
$statusLabel.Text = "Ready"
$form.Controls.Add($statusLabel)

# Log output box
$logBox = New-Object System.Windows.Forms.TextBox
$logBox.Location = New-Object System.Drawing.Point(10, 400)
$logBox.Size = New-Object System.Drawing.Size(560, 200)
$logBox.Multiline = $true
$logBox.ScrollBars = "Vertical"
$logBox.ReadOnly = $true
$logBox.Font = New-Object System.Drawing.Font("Consolas", 9)
$logBox.Text = "Log output will appear here...`r`n`r`nLog file: $LogFile`r`nDownload folder: $DownloadFolder"
$form.Controls.Add($logBox)

# Install Selected button
$installSelectedBtn = New-Object System.Windows.Forms.Button
$installSelectedBtn.Location = New-Object System.Drawing.Point(10, 610)
$installSelectedBtn.Size = New-Object System.Drawing.Size(270, 40)
$installSelectedBtn.Text = "Install Selected"
$installSelectedBtn.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$installSelectedBtn.BackColor = [System.Drawing.Color]::LightGreen
$installSelectedBtn.Add_Click({
    $selectedApps = $checkboxes | Where-Object { $_.Checked } | ForEach-Object { $_.Tag }

    if ($selectedApps.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("Please select at least one app to install.", "No Selection", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
        return
    }

    # Disable buttons during installation
    $installSelectedBtn.Enabled = $false
    $installAllBtn.Enabled = $false
    $selectAllBtn.Enabled = $false
    $deselectAllBtn.Enabled = $false

    $logBox.Clear()
    $logBox.AppendText("Starting installation of $($selectedApps.Count) app(s)...`r`n")

    $progressBar.Maximum = $selectedApps.Count
    $progressBar.Value = 0

    $successCount = 0
    $failCount = 0

    foreach ($app in $selectedApps) {
        $result = Install-App -App $app -StatusLabel $statusLabel -ProgressBar $progressBar -LogBox $logBox
        if ($result) { $successCount++ } else { $failCount++ }
        $progressBar.Value++
        [System.Windows.Forms.Application]::DoEvents()
    }

    $statusLabel.Text = "Complete! Success: $successCount | Failed: $failCount"
    $logBox.AppendText("`r`n========================================`r`n")
    $logBox.AppendText("Installation Complete!`r`n")
    $logBox.AppendText("Successful: $successCount`r`n")
    $logBox.AppendText("Failed: $failCount`r`n")
    $logBox.AppendText("========================================`r`n")

    # Re-enable buttons
    $installSelectedBtn.Enabled = $true
    $installAllBtn.Enabled = $true
    $selectAllBtn.Enabled = $true
    $deselectAllBtn.Enabled = $true

    [System.Windows.Forms.MessageBox]::Show(
        "Installation complete!`n`nSuccessful: $successCount`nFailed: $failCount`n`nCheck the log for details: $LogFile",
        "Installation Complete",
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Information
    )
})
$form.Controls.Add($installSelectedBtn)

# Install All button
$installAllBtn = New-Object System.Windows.Forms.Button
$installAllBtn.Location = New-Object System.Drawing.Point(300, 610)
$installAllBtn.Size = New-Object System.Drawing.Size(270, 40)
$installAllBtn.Text = "Install All"
$installAllBtn.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$installAllBtn.BackColor = [System.Drawing.Color]::LightBlue
$installAllBtn.Add_Click({
    $result = [System.Windows.Forms.MessageBox]::Show(
        "This will install ALL $($AppList.Count) apps. Continue?",
        "Confirm Install All",
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Question
    )

    if ($result -ne [System.Windows.Forms.DialogResult]::Yes) {
        return
    }

    # Select all and trigger install
    foreach ($cb in $checkboxes) {
        $cb.Checked = $true
    }

    $installSelectedBtn.PerformClick()
})
$form.Controls.Add($installAllBtn)

# Show form
Write-Log "GUI displayed"
$form.ShowDialog() | Out-Null

Write-Log "App Installer closed"
