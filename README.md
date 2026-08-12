# Fastfetch Windows Installer

A small, interactive Windows installer for [Fastfetch](https://github.com/fastfetch-cli/fastfetch). It downloads the latest official 64-bit Windows release, installs it for all users, creates a **PC SPECS** desktop shortcut, and adds Fastfetch to the system PATH.

## Install

1. Download and extract the release ZIP.
2. Right-click `Install_Fastfetch.bat` and choose **Run as administrator**.
3. Select **1** to install or update Fastfetch.

Internet access is required during installation. Open a new terminal after setup and run `fastfetch`, or open the **PC SPECS** shortcut from the desktop.

## Update and uninstall

Run `Install_Fastfetch.bat` as administrator again:

- Select **1** to download the current official Fastfetch release. Existing `config.jsonc` and `ascii.txt` files are kept so your customizations are not overwritten.
- Select **2** to remove the installation folder, the installer-created public desktop shortcut, and the PATH entry.

## Customize

After installation, edit these files:

- `C:\ProgramData\fastfetch\config.jsonc` — Fastfetch module layout and colors.
- `C:\ProgramData\fastfetch\ascii.txt` — the displayed ASCII art.

See the [Fastfetch configuration documentation](https://github.com/fastfetch-cli/fastfetch/wiki/Configuration) for all available options.

## Requirements

- 64-bit Windows
- Windows PowerShell 5.1 or later
- Administrator privileges
- Internet access to GitHub during install/update

## Security and attribution

This project downloads Fastfetch only from the official `fastfetch-cli/fastfetch` GitHub release endpoint over HTTPS. Fastfetch is a separate project; see its [license](https://github.com/fastfetch-cli/fastfetch/blob/dev/LICENSE) and releases for upstream details.

## License

This installer project is licensed under the MIT License. It does not include Fastfetch itself.
