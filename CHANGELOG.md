# Changelog

All notable changes to this project are documented here.

## 1.1.1 — 2026-11-03

- Redesigned `config.jsonc`: open-ended section boxes (Hardware, Software, Desktop, System) whose borders always line up, consistent `│` prefixes, and aligned values.
- Shows the motherboard instead of the host model, which is blank on most custom-built PCs.
- Labels each disk by drive letter and hides virtual display adapters from the GPU list.
- Replaced the DE module, which is not supported on Windows, with the window manager, and restored the login manager module.
- Moved displays into the Desktop section.

## 1.1.0 — 2026-11-03

- Added native ARM64 (Windows on ARM) support; the installer now picks the matching `windows-aarch64` or `windows-amd64` build automatically.
- Downloads are now verified against the SHA-256 digest GitHub publishes for each release asset.
- Fixed downloads failing on systems without the Internet Explorer engine by using `-UseBasicParsing`.
- Greatly sped up downloads by disabling the Windows PowerShell progress bar.
- TLS 1.2 is now added to the allowed protocols instead of replacing them, so TLS 1.3 keeps working.
- Shows the currently installed Fastfetch version before updating.
- `config.jsonc`: removed the invalid `dedicated` GPU option so the config validates against the current Fastfetch schema.
- CI: updated `actions/checkout` to v7.

## 1.0.0 — 2026-08-12

- First GitHub-ready release of the Fastfetch Windows installer.
- Downloads the latest official Fastfetch Windows AMD64 ZIP at install time.
- Provides install, update, and uninstall options with safe PATH handling.
- Preserves customized `config.jsonc` and `ascii.txt` files when updating.
- Adds release documentation, MIT licensing, and GitHub Actions validation.
