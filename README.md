# Windows App Installer

A simple GUI tool to quickly install common applications on a fresh Windows 11 installation using Windows Package Manager (winget) or direct downloads.

## Features

- **GUI Interface**: Easy-to-use graphical interface with checkboxes
- **Dual Installation Methods**: Supports both winget and direct download installers
- **Batch Installation**: Install all apps at once or select specific ones
- **Error Handling**: Continues installation even if one app fails
- **Logging**: All installation attempts are logged for troubleshooting
- **Portable**: Single PowerShell script - run from USB or any location
- **Auto-detect**: Checks for winget and offers to install it if missing
- **Flexible**: Easily add apps not available in winget via direct downloads

## Requirements

- Windows 11 (or Windows 10 with App Installer)
- Internet connection
- Administrator privileges (may be required for some apps)

## How to Use

### Method 1: Quick Start

1. Copy `AppInstaller.ps1` to your new Windows installation (USB, download, etc.)
2. Right-click on `AppInstaller.ps1`
3. Select **"Run with PowerShell"**
4. If prompted about execution policy, choose **"Yes"** or **"Run Anyway"**
5. The GUI will open - select your apps and click **"Install Selected"** or **"Install All"**

### Method 2: Run from PowerShell

1. Open PowerShell (right-click Start → Windows PowerShell)
2. Navigate to the script location:
   ```powershell
   cd "path\to\script"
   ```
3. Run the script:
   ```powershell
   .\AppInstaller.ps1
   ```

### If You Get Execution Policy Errors

If PowerShell blocks the script, run PowerShell as Administrator and execute:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

Then run the script again.

## Adding More Apps

You can easily add more apps by editing the script. Open `AppInstaller.ps1` in any text editor (Notepad, VS Code, etc.) and find the `$AppList` section at the top (around line 16).

The script supports two types of installations:

---

### Method 1: Winget Apps (Recommended - Easiest)

**Use this when:** The app is available in the Microsoft winget repository (most popular apps are).

#### Step-by-Step:

1. **Search for the app** in PowerShell:
   ```powershell
   winget search "app name"
   ```
   Example output:
   ```
   Name     Id              Version
   --------------------------------
   7-Zip    7zip.7zip       24.08
   ```

2. **Copy the ID** from the results (e.g., `7zip.7zip`)

3. **Open `AppInstaller.ps1`** in a text editor

4. **Add the app to `$AppList`** (before the closing `)`):
   ```powershell
   @{Name="7-Zip"; Type="winget"; ID="7zip.7zip"; Description="File archiver"},
   ```

   **Important:** Add a comma at the end!

5. **Save the file**

#### Real Example - Adding OBS Studio:
```powershell
# Search first
winget search "OBS Studio"
# Result: OBSProject.OBSStudio

# Add to script
@{Name="OBS Studio"; Type="winget"; ID="OBSProject.OBSStudio"; Description="Streaming software"},
```

---

### Method 2: Direct Download Apps (For Apps NOT in Winget)

**Use this when:** The app isn't available in winget (like TouchDesigner, H.264 Encoder, etc.)

#### Step-by-Step:

1. **Find the direct download URL**
   - Go to the software's official website
   - Find the download button/link
   - Right-click → "Copy link address"
   - You want a URL ending in `.exe`, `.msi`, or `.zip`

2. **Determine the installer type**
   - `.exe` files: Most common (setup.exe)
   - `.msi` files: Windows Installer packages
   - `.zip` files: Portable apps (will be extracted, not installed)

3. **Find the silent install arguments** (trickiest part!)

   **Try these methods:**

   a. **Check the installer's help:**
   ```powershell
   installer.exe /?
   installer.exe /help
   installer.exe --help
   ```

   b. **Try common arguments:**
   - NSIS Installers: `/S` (capital S)
   - Inno Setup: `/VERYSILENT /SUPPRESSMSGBOXES`
   - MSI files: `/quiet /qn /norestart`
   - InstallShield: `/s /v"/qn"`

   c. **Google it:**
   Search for: `"app name" silent install` or `"installer.exe" unattended install`

   d. **Test manually:**
   Download the installer and try: `installer.exe /S`

4. **Add to `AppInstaller.ps1`:**
   ```powershell
   @{Name="App Name"; Type="direct"; DownloadURL="https://example.com/installer.exe"; InstallerType="exe"; SilentArgs="/S"; Description="Short description"},
   ```

5. **Save and test** - Try installing just that app first!

#### Real Example - Adding Blender:

```powershell
# 1. Find download URL: https://www.blender.org/download/release/Blender4.2/blender-4.2.1-windows-x64.msi
# 2. Installer type: msi
# 3. Silent args for MSI: /quiet /qn
# 4. Add to script:

@{Name="Blender"; Type="direct"; DownloadURL="https://www.blender.org/download/release/Blender4.2/blender-4.2.1-windows-x64.msi"; InstallerType="msi"; SilentArgs="/quiet /qn"; Description="3D creation suite"},
```

---

### Quick Reference: Common Silent Install Arguments

| Installer Type | Silent Args | Example |
|----------------|-------------|---------|
| **NSIS** | `/S` | Most setup.exe files |
| **Inno Setup** | `/VERYSILENT /SUPPRESSMSGBOXES` | Many indie apps |
| **MSI** | `/quiet /qn /norestart` | Official Microsoft format |
| **InstallShield** | `/s /v"/qn"` | Enterprise software |
| **Nullsoft** | `/S /D=C:\Path` | Winamp-style |

---

### Complete Example - Your Script Should Look Like This:

```powershell
$AppList = @(
    # Direct Download Apps
    @{Name="TouchDesigner"; Type="direct"; DownloadURL="https://download.derivative.ca/TouchDesigner.2023.12480.exe"; InstallerType="exe"; SilentArgs="/SILENT"; Description="Visual development platform"},
    @{Name="H.264 Encoder"; Type="direct"; DownloadURL="https://file1.softsea.com/get.php?file=h264encoder_setup.exe"; InstallerType="exe"; SilentArgs="/S"; Description="Video encoder to H.264 format"},

    # Winget Apps
    @{Name="Inkscape"; Type="winget"; ID="Inkscape.Inkscape"; Description="Vector graphics editor"},
    @{Name="Visual Studio Code"; Type="winget"; ID="Microsoft.VisualStudioCode"; Description="Code editor"},
    @{Name="7-Zip"; Type="winget"; ID="7zip.7zip"; Description="File archiver"},
    @{Name="Firefox"; Type="winget"; ID="Mozilla.Firefox"; Description="Web browser"}
    # Add more apps here - don't forget the comma!
)
```

---

### Tips & Tricks

✅ **Always add a comma** at the end of each line (except the last one)
✅ **Test one app at a time** when adding new ones
✅ **Check the log file** if something fails: `%TEMP%\AppInstaller_Log.txt`
✅ **Direct downloads** stay in `%TEMP%\AppInstallerDownloads\` for manual testing
❌ **Don't use** URLs that redirect or require clicking buttons
❌ **Don't forget** to specify `Type="winget"` or `Type="direct"`

## Current App List

The script currently includes:

- **Development**: TouchDesigner (Direct DL), Visual Studio Code, Sublime Text
- **Creative**: Inkscape
- **Productivity**: Notion
- **Browsers**: Firefox
- **Communication**: Discord, Telegram
- **Networking**: Tailscale
- **Media**: VLC, FFmpeg, HandBrake, Upscayl, H.264 Encoder (Direct DL)

## Log Files and Downloads

### Installation Log
Installation logs are saved to:
```
%TEMP%\AppInstaller_Log.txt
```

Typically located at:
```
C:\Users\[YourUsername]\AppData\Local\Temp\AppInstaller_Log.txt
```

The log shows:
- Which apps were installed successfully
- Any errors that occurred
- Exit codes from failed installations
- Download URLs for direct install apps

### Downloaded Installers
Direct download installers are saved to:
```
%TEMP%\AppInstallerDownloads\
```

These files are kept after installation in case you need to reinstall manually.

## Troubleshooting

### Script won't run
- Right-click and select "Run with PowerShell"
- Or adjust execution policy (see above)

### Winget not found
- The script will offer to install it automatically
- Or manually install "App Installer" from Microsoft Store

### App installation fails
- Check the log file for specific errors
- Some apps may require manual intervention
- For winget apps: Verify the app ID is correct using `winget search`
- For direct download apps:
  - Check if the download URL is still valid
  - Verify the silent install arguments are correct
  - Try running the installer manually from `%TEMP%\AppInstallerDownloads\`

### Need administrator rights
- Right-click PowerShell and select "Run as Administrator"
- Then run the script

## Notes

- **Installation time**: Depends on your internet speed and number of apps (typically 2-5 minutes per app)
- **Silent installation**: Apps install in the background with minimal prompts
- **Already installed apps**: Winget will skip or update apps that are already installed
- Some apps may require a restart after installation

## Uninstalling Apps

To uninstall an app installed with this script:

```powershell
winget uninstall "App Name"
```

Or use Windows Settings → Apps → Installed Apps

## License

Free to use and modify as needed.
