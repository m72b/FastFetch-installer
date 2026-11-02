#requires -Version 5.1
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
# The Windows PowerShell 5.1 progress bar slows Invoke-WebRequest downloads dramatically.
$ProgressPreference = 'SilentlyContinue'
$InstallerVersion = '1.1.0'
$UserAgent = "Fastfetch-Windows-Installer/$InstallerVersion"
$InstallDir = Join-Path $env:ProgramData 'fastfetch'
$PublicShortcutPath = Join-Path $env:PUBLIC 'Desktop\PC SPECS.lnk'
$ScriptDir = $PSScriptRoot

trap {
    Write-Host "`n  [!!] FATAL ERROR: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "  Line: $($_.InvocationInfo.ScriptLineNumber)" -ForegroundColor Red
    Read-Host "`n  Press Enter to exit" | Out-Null
    exit 1
}

function Write-Banner {
    Clear-Host
    Write-Host ''
    Write-Host '  +----------------------------------------------+' -ForegroundColor Cyan
    Write-Host ("  |{0,-46}|" -f "      FASTFETCH AUTO-INSTALLER  v$InstallerVersion") -ForegroundColor Cyan
    Write-Host '  +----------------------------------------------+' -ForegroundColor Cyan
    Write-Host ''
}
function Write-Step([string]$Message) { Write-Host '  [>>] ' -ForegroundColor Cyan -NoNewline; Write-Host $Message }
function Write-OK([string]$Message) { Write-Host '  [OK] ' -ForegroundColor Green -NoNewline; Write-Host $Message -ForegroundColor Green }
function Write-Fail([string]$Message) { Write-Host '  [!!] ' -ForegroundColor Red -NoNewline; Write-Host $Message -ForegroundColor Red }
function Wait-ForExit { Read-Host "`n  Press Enter to exit" | Out-Null }

function Test-Administrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]::new($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Get-ReleaseArchitecture {
    # PROCESSOR_ARCHITEW6432 is set when running as an emulated/32-bit process on a 64-bit OS.
    $arch = if ($env:PROCESSOR_ARCHITEW6432) { $env:PROCESSOR_ARCHITEW6432 } else { $env:PROCESSOR_ARCHITECTURE }
    try { $arch = [System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture.ToString() } catch { }
    if ($arch -match 'arm64') { return 'aarch64' }
    return 'amd64'
}

function Get-InstalledVersion {
    $exe = Join-Path $InstallDir 'fastfetch.exe'
    if (-not (Test-Path -LiteralPath $exe)) { return $null }
    try { return ((& $exe --version 2>$null) | Select-Object -First 1) } catch { return $null }
}

function Update-MachinePath([bool]$AddInstallDirectory) {
    $current = [Environment]::GetEnvironmentVariable('Path', 'Machine')
    $parts = @($current -split ';' | Where-Object { $_ -and $_.Trim() -ne '' })
    $parts = @($parts | Where-Object { -not $_.Trim().Equals($InstallDir, [StringComparison]::OrdinalIgnoreCase) })
    if ($AddInstallDirectory) { $parts += $InstallDir }
    [Environment]::SetEnvironmentVariable('Path', ($parts -join ';'), 'Machine')

    $signature = @'
[DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
public static extern IntPtr SendMessageTimeout(IntPtr hWnd, uint Msg, UIntPtr wParam,
    string lParam, uint fuFlags, uint uTimeout, out UIntPtr lpdwResult);
'@
    if (-not ('FastfetchInstaller.NativeMethods' -as [type])) { Add-Type -MemberDefinition $signature -Name NativeMethods -Namespace FastfetchInstaller }
    $result = [UIntPtr]::Zero
    [void][FastfetchInstaller.NativeMethods]::SendMessageTimeout([IntPtr]0xffff, 0x001A, [UIntPtr]::Zero, 'Environment', 2, 5000, [ref]$result)
}

function Remove-Fastfetch {
    Write-Banner
    Write-Host '  Uninstalling Fastfetch...' -ForegroundColor Yellow
    Write-Host ''
    Write-Step "Removing install directory ($InstallDir)..."
    if (Test-Path -LiteralPath $InstallDir) { Remove-Item -LiteralPath $InstallDir -Recurse -Force; Write-OK "Removed $InstallDir" }
    else { Write-OK 'Install directory was already absent.' }

    Write-Step 'Removing installer-created Desktop shortcut...'
    if (Test-Path -LiteralPath $PublicShortcutPath) { Remove-Item -LiteralPath $PublicShortcutPath -Force; Write-OK 'Removed PC SPECS shortcut.' }
    else { Write-OK 'Public Desktop shortcut was already absent.' }

    Write-Step 'Removing from the system PATH...'
    Update-MachinePath -AddInstallDirectory $false
    Write-OK 'PATH updated.'
    Write-Host "`n  Uninstall complete." -ForegroundColor Yellow
}

function Install-Fastfetch {
    foreach ($assetName in 'config.jsonc', 'ascii.txt') {
        if (-not (Test-Path -LiteralPath (Join-Path $ScriptDir $assetName))) { throw "$assetName is missing next to the installer." }
    }
    # Add TLS 1.2 without disabling newer protocols the OS may already allow.
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
    $arch = Get-ReleaseArchitecture
    $tempRoot = Join-Path ([IO.Path]::GetTempPath()) ("fastfetch-installer-" + [Guid]::NewGuid())
    try {
        Write-Step "Creating install directory: $InstallDir"
        New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
        Write-OK 'Directory ready.'

        Write-Step 'Fetching the latest Fastfetch release...'
        $release = Invoke-RestMethod -Uri 'https://api.github.com/repos/fastfetch-cli/fastfetch/releases/latest' -Headers @{ 'User-Agent' = $UserAgent; 'Accept' = 'application/vnd.github+json' } -UseBasicParsing
        $asset = @($release.assets | Where-Object { $_.name -eq "fastfetch-windows-$arch.zip" }) | Select-Object -First 1
        if (-not $asset) { throw "The latest Fastfetch release does not contain a Windows $arch ZIP asset." }
        $installed = Get-InstalledVersion
        if ($installed) { Write-OK "Currently installed: $installed" }
        Write-OK "Found Fastfetch $($release.tag_name) ($arch)."

        New-Item -ItemType Directory -Path $tempRoot | Out-Null
        $zipPath = Join-Path $tempRoot $asset.name
        Write-Step 'Downloading Fastfetch...'
        Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $zipPath -Headers @{ 'User-Agent' = $UserAgent } -UseBasicParsing
        Write-OK 'Download complete.'

        if ($asset.digest -match '^sha256:(?<hash>[0-9a-fA-F]{64})$') {
            Write-Step 'Verifying SHA-256 checksum...'
            $actual = (Get-FileHash -LiteralPath $zipPath -Algorithm SHA256).Hash
            if (-not $actual.Equals($Matches.hash, [StringComparison]::OrdinalIgnoreCase)) { throw "Checksum mismatch for $($asset.name). Expected $($Matches.hash), got $actual." }
            Write-OK 'Checksum verified.'
        } else {
            Write-Host '  [--] GitHub did not publish a checksum for this asset; skipping verification.' -ForegroundColor DarkYellow
        }

        Write-Step 'Extracting fastfetch.exe...'
        $extractDir = Join-Path $tempRoot 'extract'
        Expand-Archive -LiteralPath $zipPath -DestinationPath $extractDir -Force
        $exe = Get-ChildItem -LiteralPath $extractDir -Recurse -File -Filter 'fastfetch.exe' | Select-Object -First 1
        if (-not $exe) { throw 'fastfetch.exe was not found in the downloaded archive.' }
        Copy-Item -LiteralPath $exe.FullName -Destination (Join-Path $InstallDir 'fastfetch.exe') -Force
        Write-OK 'fastfetch.exe installed.'

        foreach ($assetName in 'config.jsonc', 'ascii.txt', 'icon.ico') {
            $source = Join-Path $ScriptDir $assetName
            $destination = Join-Path $InstallDir $assetName
            if ($assetName -eq 'icon.ico' -and -not (Test-Path -LiteralPath $source)) { continue }
            if ((Test-Path -LiteralPath $destination) -and $assetName -in 'config.jsonc', 'ascii.txt') {
                Write-OK "$assetName already exists; preserving your custom version."
            } else {
                Copy-Item -LiteralPath $source -Destination $destination -Force
                Write-OK "$assetName copied."
            }
        }

        Write-Step 'Creating launcher...'
        $launcherPath = Join-Path $InstallDir 'PC_SPECS_launcher.bat'
        $launcher = "@echo off`r`n`"%~dp0fastfetch.exe`" --config `"%~dp0config.jsonc`"`r`npause`r`n"
        [IO.File]::WriteAllText($launcherPath, $launcher, [Text.Encoding]::ASCII)
        Write-OK 'Launcher created.'

        Write-Step "Creating 'PC SPECS' shortcut on the Public Desktop..."
        $shell = New-Object -ComObject WScript.Shell
        $shortcut = $shell.CreateShortcut($PublicShortcutPath)
        $shortcut.TargetPath = $launcherPath
        $shortcut.WorkingDirectory = $InstallDir
        $shortcut.Description = 'Show PC specs with Fastfetch'
        if (Test-Path -LiteralPath (Join-Path $InstallDir 'icon.ico')) { $shortcut.IconLocation = (Join-Path $InstallDir 'icon.ico') }
        $shortcut.Save()
        Write-OK 'PC SPECS shortcut created.'

        Write-Step "Adding $InstallDir to the system PATH..."
        Update-MachinePath -AddInstallDirectory $true
        Write-OK "PATH updated. Open a new terminal and run 'fastfetch'."
    } finally {
        if (Test-Path -LiteralPath $tempRoot) { Remove-Item -LiteralPath $tempRoot -Recurse -Force -ErrorAction SilentlyContinue }
    }
}

if (-not [Environment]::Is64BitOperatingSystem) {
    Write-Fail 'This installer supports 64-bit Windows only.'
    Wait-ForExit
    exit 1
}
if (-not (Test-Administrator)) {
    Write-Fail 'Run Install_Fastfetch.bat as Administrator, then try again.'
    Wait-ForExit
    exit 1
}

Write-Banner
Write-Host '  [1] Install or update Fastfetch' -ForegroundColor Cyan
Write-Host '  [2] Uninstall Fastfetch' -ForegroundColor Yellow
$choice = Read-Host "`n  Enter 1 or 2"
switch ($choice) {
    '1' { Install-Fastfetch; Write-Host "`n  Installation complete." -ForegroundColor Green }
    '2' { Remove-Fastfetch }
    default { Write-Fail 'Invalid choice.'; Wait-ForExit; exit 1 }
}
Wait-ForExit
