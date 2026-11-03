# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- **Portable Volume Control Integration**: Added in-tree `hypr/scripts/volume_control.sh` wrapper script honoring `${XDG_CONFIG_HOME:-$HOME/.config}` and dynamically bound in `hypr/hyprland/keybinds.lua`.
- **wwald Wallpaper Daemon Autostart**: Integrated seamless autostart for the `wwald` wallpaper daemon (`Execorn/wwal`) on Hyprland startup.
- **Continuous Integration (`.github/workflows/ci.yml`)**: Added automated syntax validation for Lua (`luac -p`), Fish (`fish -n`), Bash (`bash -n`), and `manifest.toml`.
- **Explicit GNU General Public License v3.0**: Added root `LICENSE` file.

### Changed
- **Hyprland 0.56+ Lua Migration**: Completed migration from legacy `.conf` flat syntax to Hyprland's native Lua DSL (`hl.config`, `hl.window_rule`, `hl.bind`, `hl.dispatch`, `hl.on`).
- **Native Lua Workspace Management**: Emulated AwesomeWM-style workspace group partitioning (30 workspaces across 3 physical displays) purely via native Lua `fn.wsaction(...)` in `hypr/utils/functions.lua`, eliminating subshell latency.
- **Portability Hardening**: Guarded developer QML and library paths in `hypr/hyprland/env.lua` with dynamic directory existence checks.
- **Documentation Synchronization**: Synchronized all README keybinding tables with `variables.lua` and `keybinds.lua`, corrected upstream 404 links, and added repository badges.

### Removed
- **Legacy Fish Configuration Scripts**: Retired obsolete `hypr/scripts/configs.fish`.
