<div align="center">

<img src="assets/ff-icon.svg" alt="Fastfetch Windows Installer logo" width="128" height="128">

# Fastfetch Windows Installer

**A one-click installer that sets up [Fastfetch](https://github.com/fastfetch-cli/fastfetch) on Windows — always using the latest official release.**

[![Validate](https://github.com/m72b/FastFetch-installer/actions/workflows/validate.yml/badge.svg)](https://github.com/m72b/FastFetch-installer/actions/workflows/validate.yml)
[![Latest release](https://img.shields.io/github/v/release/m72b/FastFetch-installer?label=release)](https://github.com/m72b/FastFetch-installer/releases/latest)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
![Platform](https://img.shields.io/badge/platform-Windows%2010%20%7C%2011-0078D6?logo=windows)
![Architecture](https://img.shields.io/badge/arch-x64%20%7C%20ARM64-lightgrey)

</div>

---

## Overview

Fastfetch is a fast, highly customizable system information tool. This project wraps its Windows release in a small, transparent PowerShell installer so you can go from download to a styled **PC SPECS** readout in under a minute — no package manager, no manual PATH editing.

## Features

| | |
|---|---|
| **Always current** | Fetches the latest release directly from the official Fastfetch GitHub repository at install time. |
| **Verified downloads** | Checks every download against the SHA-256 digest published by GitHub before installing. |
| **x64 and ARM64** | Detects your CPU architecture and installs the matching native build. |
| **System-wide setup** | Installs to `C:\ProgramData\fastfetch` and adds it to the system `PATH`, so `fastfetch` works in any terminal. |
| **Desktop shortcut** | Creates a **PC SPECS** shortcut on the Public Desktop for a one-click system overview. |
| **Custom-friendly updates** | Re-running the installer updates Fastfetch while preserving your edited `config.jsonc` and `ascii.txt`. |
| **Clean uninstall** | Removes the install folder, shortcut, and `PATH` entry — nothing left behind. |

## Requirements

- Windows 10 or Windows 11 (64-bit, x64 or ARM64)
- Windows PowerShell 5.1 or later (included with Windows)
- Administrator privileges
- Internet access to `github.com` and `api.github.com`

## Installation

1. Download the latest ZIP from the [Releases](https://github.com/m72b/FastFetch-installer/releases/latest) page and extract it.
2. Right-click **`Install_Fastfetch.bat`** and select **Run as administrator**.
3. Press **`1`** to install.

When setup finishes, open a **new** terminal and run:

```powershell
fastfetch
```

Or double-click the **PC SPECS** shortcut on your desktop.

## Updating

Run `Install_Fastfetch.bat` as administrator again and press **`1`**. The installer shows your current version, downloads the newest release, and replaces `fastfetch.exe`. Your `config.jsonc` and `ascii.txt` are left untouched.

> To reset to the default look, delete `config.jsonc` and/or `ascii.txt` from `C:\ProgramData\fastfetch` before updating.

## Uninstalling

Run `Install_Fastfetch.bat` as administrator and press **`2`**. This removes:

- `C:\ProgramData\fastfetch` and everything in it
- The **PC SPECS** shortcut from the Public Desktop
- The install directory from the system `PATH`

## Customization

| File | Purpose |
|---|---|
| `C:\ProgramData\fastfetch\config.jsonc` | Module layout, labels, and colors |
| `C:\ProgramData\fastfetch\ascii.txt` | ASCII art logo displayed beside the output |

The bundled config groups information into **Hardware**, **Software**, and **Desktop** sections, followed by uptime, display, audio, TPM, and a color palette. For every available module and option, see the official [Fastfetch configuration guide](https://github.com/fastfetch-cli/fastfetch/wiki/Configuration). The config references the official JSON schema, so editors such as VS Code provide autocomplete and validation.

## Troubleshooting

| Problem | Solution |
|---|---|
| *"Run Install_Fastfetch.bat as Administrator"* | Right-click the `.bat` file and choose **Run as administrator**. |
| `fastfetch` is not recognized | Close and reopen your terminal so it picks up the updated `PATH`. |
| Download or API request fails | Check your internet connection, proxy, or firewall. GitHub's anonymous API limit is 60 requests per hour — wait and retry if you hit it. |
| Checksum mismatch | The download was corrupted or altered. Run the installer again; if it persists, open an issue. |
| Boxes or symbols render incorrectly | Use [Windows Terminal](https://aka.ms/terminal) with a font that supports box-drawing characters (e.g. Cascadia Code). |

## Project structure

```text
├── Install_Fastfetch.bat    # Entry point — launches the PowerShell installer
├── fastfetch_setup.ps1      # Install / update / uninstall logic
├── config.jsonc             # Default Fastfetch configuration
├── ascii.txt                # Default ASCII art logo
├── icon.ico                 # Icon for the PC SPECS shortcut
└── .github/workflows/       # CI: validates required files, script syntax, and config
```

## Security

- Fastfetch binaries are downloaded **only** from the official [fastfetch-cli/fastfetch](https://github.com/fastfetch-cli/fastfetch) releases over HTTPS.
- Each download is verified against GitHub's published SHA-256 digest before it is installed.
- The installer is plain, readable PowerShell — review [`fastfetch_setup.ps1`](fastfetch_setup.ps1) before running it.
- Administrator rights are needed only to write to `C:\ProgramData`, the Public Desktop, and the system `PATH`.

## Contributing

Issues and pull requests are welcome. Please keep changes compatible with Windows PowerShell 5.1 and confirm the CI workflow passes. See the [changelog](CHANGELOG.md) for release history.

## License

This installer is released under the [MIT License](LICENSE).

Fastfetch itself is a separate project by its respective authors and is **not** bundled in this repository. See the [Fastfetch license](https://github.com/fastfetch-cli/fastfetch/blob/dev/LICENSE) for details.
