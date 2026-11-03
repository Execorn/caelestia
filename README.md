# caelestia

[![License: GPL-3.0](https://img.shields.io/badge/License-GPL%203.0-blue.svg)](LICENSE)
[![Hyprland](https://img.shields.io/badge/Hyprland-0.56%2B%20Lua-00c8ff.svg)](https://wiki.hypr.land/configuring/core/advanced-configuration/lua-utilities/)
[![Daemon: wwald](https://img.shields.io/badge/Daemon-wwald%20%28Execorn%2Fwwal%29-ff69b4.svg)](https://github.com/Execorn/wwal)
[![Shell: Quickshell](https://img.shields.io/badge/Shell-Quickshell-8a2be2.svg)](https://github.com/caelestia-dots/shell)
[![OS: Arch Linux](https://img.shields.io/badge/OS-Arch%20Linux-1793d1.svg)](https://archlinux.org)

## Execorn's Fork of Caelestia Dotfiles

This fork of [caelestia-dots/caelestia](https://github.com/caelestia-dots/caelestia) provides the Lua configuration for Hyprland `0.56+` and desktop application configs paired with [Execorn/shell](https://github.com/Execorn/shell).

### Key Enhancements

- **Native Hyprland `0.56+` Lua Architecture & AwesomeWM Workspace Group Emulation**:
  - Migrated all monitor layouts, workspace groups, window rules, and dynamic resizer hooks to `hypr/hyprland.lua` and modular Lua files under `hypr/hyprland/`.
  - Re-mapped workspaces to emulate AwesomeWM's independent workspace/tag system per monitor using native Lua dispatchers (`fn.wsaction` in `hypr/utils/functions.lua`) leveraging `hl.get_active_workspace()` and `hl.dispatch()` for zero-latency switching.
  - Partitions workspaces 1–30 into 3 distinct screen groups (Left monitor, Middle monitor, Laptop screen).
  - Pre-allocates window matcher closures and dispatches title, class, and tag rules separately so terminal and browser title updates allocate zero Lua tables.
- **Discrete NVIDIA 3-Monitor & Rendering Optimizations**:
  - Configured for a 3-monitor layout (`DP-4` 1920×1080@144Hz, `DP-3` 2560×1440@100Hz, `eDP-1` 1920×1080@165Hz) with dedicated workspace pinning.
  - Isolates `__EGL_VENDOR_LIBRARY_FILENAMES` to NVIDIA when the Intel iGPU has no connected outputs, preventing Mesa/LLVM from loading into Wayland processes.
  - Enables Variable Frame Rate (`vfr = true`), fullscreen direct scanout (`direct_scanout = 1`), and SDR color-management bypass (`cm_enabled = false`).
  - Retains background Kawase blur for terminal emulators (`Alacritty`, `foot`, `kitty`, `wezterm`, `ghostty`) while bypassing blur and alpha compositing behind opaque media and creative apps (`mpv`, `vlc`, `gimp`, `krita`, `blender`).
- **Session & Wallpaper Integration**:
  - Autostarts the [`wwald`](https://github.com/Execorn/wwal) C23 Wayland wallpaper daemon (`hl.exec_cmd("wwald")`) on Hyprland startup.
  - Launches `polkit-gnome-authentication-agent-1` inside the user's systemd slice (`user@1000.service`) so Polkit and `systemd-logind` work reliably even when `ananicy-cpp` moves Hyprland to the root cgroup.
  - Configured EasyEffects daemon autostart on Hyprland boot via native Lua DSL: `hl.exec_cmd("easyeffects --gapplication-service")`.
  - Disabled Hyprland's `initial_workspace_tracking` to ensure applications launched open on the active workspace.
- **In-Repo Portable Audio Increment Sync**:
  - Structured a portable `hypr/scripts/volume_control.sh` wrapper script supporting `${XDG_CONFIG_HOME:-$HOME/.config}` that automatically synchronizes audio volume changes with Quickshell and matches the volume increment step defined in `shell.json`.
- **Screenshot Overlay Freeze & Shell Globals**:
  - Created a seamless screenshot region capture using `Print` and `Super+Shift+S` mapped to area freeze captures (`caelestia:screenshotFreeze`).
  - Integrated shortcuts for Antigravity (`Super + A`), GitHub Desktop (`Super + Shift + G`), Telegram (`Super + Shift_R`), Calcurse (`Super + Shift + P`), Nemo (`Super + Alt + E`), and Qps (`Ctrl + Alt + Escape`).
  - Native global shell triggers: Cheatsheet overlay (`Super + S`), Window overview (`Super + Tab`), OCR tool (`Super + Shift + T`), Nexus settings (`Super + Shift + W`), and Newsfeed panel (`Super + N`).

---
This is the main repo of the Caelestia dotfiles and contains user configs for
various apps.

> [!IMPORTANT]
> The legacy `install.fish` script in this repo has been removed in favour
> of the [CLI][cli-repo]'s install command.
>
> If you have an existing installation with the legacy script, please update
> the CLI and run the install command to complete the migration.

> [!IMPORTANT]
> We have switched to using Lua for the Hyprland config!
> For everyone with a custom `~/.config/caelestia/hypr-user.conf`
> or `~/.config/caelestia/hypr-vars.conf`, please convert it to Lua
> either manually or using one of the available converters online.
>
> For more information on using these files, see the [Configuring](#configuring) section.

## Installation (Arch Linux)

Install the CLI from the AUR, then run `caelestia install`.

For example:

```sh
paru -S caelestia-cli
caelestia install
```

### Manual installation

Clone this repo, then go through [the manifest](manifest.toml) and install all packages from the
components that you want to enable, then copy all the entries from those components.

e.g. for the hyprland component:

```sh
git clone https://github.com/caelestia-dots/caelestia.git
cd caelestia
sudo pacman -S --needed hyprland xdg-desktop-portal-hyprland xdg-desktop-portal-gtk ttf-jetbrains-mono-nerd
mkdir -p $XDG_CONFIG_HOME/hypr
cp -r hypr/. $XDG_CONFIG_HOME/hypr/
```

## Updating

Use `caelestia update` to perform a full system update and update the dots.

## Usage

> [!NOTE]
> These dots do not contain a login manager (for now), so you must install a
> login manager yourself unless you want to log in from a TTY. I recommend
> [`greetd`](https://sr.ht/~kennylevinsen/greetd) with
> [`tuigreet`](https://github.com/apognu/tuigreet); however, you can use
> any login manager you want.

## Configuring

> [!CAUTION]
> You should never modify any files inside `~/.config/hypr/`, as this will cause conflicts during updates to the dots.
>
> Any personal changes should be made in `~/.config/caelestia/hypr-user.lua` or `hypr-vars.lua`, as
> the installation/update workflows never modify these files. Writing your own changes to files in `~/.config/hypr/`
> will prevent new updates from being applied, and you will have to reconcile conflicts every time you update manually.

### hypr-vars.lua

Most default Hyprland values can be modified by overriding variables in `~/.config/caelestia/hypr-vars.lua`. You can use this file to set
default apps, keybinds, mouse cursor, window decorations, and much more.
Use the [`variables.lua`](hypr/variables.lua) file as a reference for all available variables and their default values.

Example usage for `hypr-vars.lua`:

```lua
return {
  -- Changing default apps:
  browser          = "zen-browser",    -- Change default browser to Zen
  editor           = "code",           -- Change default editor to Code

  -- Changing window/decoration properties:
  blurEnabled      = false,            -- Disable window blur
  windowBorderSize = 3,                -- Increase window border size (default: 1)

  -- Changing keybinds:
  kbTerminal       = "SUPER + Return", -- Change the keybind for opening terminal
}
```

### hypr-user.lua

You can put any custom Hyprland configuration in `~/.config/caelestia/hypr-user.lua`. This file is loaded at the end of the Hyprland
loading sequence. This allows you to customise the behavior of Hyprland outside of the premade configs, including monitor layout, additional
keybinds, and window rules. It is preferable to use `hypr-vars.lua` for changes to options that the dots already manage
(e.g. keybinds, window borders, etc.). Still, for configuration that isn't covered by dots or needs to be managed outside variables,
any changes should be made in `hypr-user.lua`.
You can read more about configuring Hyprland on their [wiki](https://wiki.hypr.land/configuring/) and the official [Lua utilities documentation](https://wiki.hypr.land/configuring/core/advanced-configuration/lua-utilities/).

### Additional configuration

Caelestia is a multifaceted ecosystem comprising the dotfiles (this repo), the [shell][shell-repo], and the [CLI][cli-repo].
The shell’s configuration is managed by `~/.config/caelestia/shell.json`, which modifies the shell’s behavior.
The CLI config file (`~/.config/caelestia/cli.json`) lets you adjust the CLI’s theming and handling of special workspaces.
You can find more information on configuring the shell and the CLI in their respective repos.

## Default keybinds

> [!TIP]
> All keybinds can be customised by overriding their corresponding variables in `hypr-vars.lua` (excluding the shell restart/kill binds).
> See [Configuring](#configuring) for more information.

### Launcher

| Keybind                   | Action        |
| ------------------------- | ------------- |
| `Super` (press & release) | Open launcher |

---

### Workspaces

| Keybind                                                                                | Action                                   |
| -------------------------------------------------------------------------------------- | ---------------------------------------- |
| `Super + 1~9, 0`                                                                       | Go to workspace 1~10                     |
| `Super + Shift + 1~9, 0`                                                               | Move window to workspace 1~10            |
| `Super + Alt + 1~9, 0`                                                                 | Move window to workspace 1~10 (silently) |
| `Ctrl + Super + 1~9, 0`                                                                | Go to workspace group (×10)              |
| `Ctrl + Super + Alt + 1~9, 0`                                                          | Move window to workspace group           |
| `Super + Alt + S`, `Ctrl + Super + Shift + Up`                                         | Move window to special workspace         |
| `Ctrl + Super + Shift + Down`                                                          | Move window out of special workspace     |
| `Super + Alt + Scroll Down`, `Super + Alt + Page_Down`, `Ctrl + Super + Shift + Right` | Move window to next workspace            |
| `Super + Alt + Scroll Up`, `Super + Alt + Page_Up`, `Ctrl + Super + Shift + Left`      | Move window to previous workspace        |
| `Super + Right`, `Super + Scroll Down`, `Super + Page_Down`                            | Go to next workspace                     |
| `Super + Left`, `Super + Scroll Up`, `Super + Page_Up`                                 | Go to previous workspace                 |
| `Ctrl + Super + Scroll Down`                                                           | Go to next workspace group               |
| `Ctrl + Super + Scroll Up`                                                             | Go to previous workspace group           |
| `Super + Caps_Lock`                                                                    | Go to previous workspace                 |

---

### Window groups

| Keybind                    | Action                         |
| -------------------------- | ------------------------------ |
| `Alt + Tab`                | Go to next window in group     |
| `Shift + Alt + Tab`        | Go to previous window in group |
| `Ctrl + Alt + Tab`         | Go to next group               |
| `Ctrl + Shift + Alt + Tab` | Go to previous group           |
| `Super + U`                | Move window out of group       |
| `Super + Comma`            | Toggle group                   |
| `Super + Shift + Comma`    | Lock active group              |

---

### Window actions

| Keybind                                       | Action                                       |
| --------------------------------------------- | -------------------------------------------- |
| `Super + Minus`, `Super + Alt + Left`         | Move window split left / decrease width      |
| `Super + Equal`, `Super + Alt + Right`        | Move window split right / increase width     |
| `Super + Shift + Minus`, `Super + Alt + Up`   | Move window split up / decrease height       |
| `Super + Shift + Equal`, `Super + Alt + Down` | Move window split down / increase height     |
| `Super + Left/Right/Up/Down`                  | Focus window in direction                    |
| `Super + Shift + Left/Right/Up/Down`          | Move window in direction                     |
| `Super + LMB drag`, `Super + Z + LMB`         | Move window (drag)                           |
| `Super + RMB drag`, `Super + X + LMB`         | Resize window (drag)                         |
| `Ctrl + Super + Backslash`                    | Center window                                |
| `Ctrl + Super + Alt + Backslash`              | Resize window to 55×70% of screen and center |
| `Super + Alt + Backslash`                     | Picture-in-picture mode                      |
| `Super + P`                                   | Pin window                                   |
| `Super + F`                                   | Fullscreen window                            |
| `Super + Alt + F`                             | Fullscreen window (bordered)                 |
| `Super + G`                                   | Toggle floating for window                   |
| `Super + Q`                                   | Close window                                 |

---

### Special workspace toggles

| Keybind                 | Action                          |
| ----------------------- | ------------------------------- |
| `Super + Alt + S`       | Toggle special workspace        |
| `Ctrl + Shift + Escape` | Toggle system monitor workspace |
| `Super + Alt + M`       | Toggle music workspace          |
| `Super + Alt + D`       | Toggle communication workspace  |
| `Super + Alt + R`       | Toggle todo workspace           |

---

### Applications

| Keybind                | Action                                                        |
| ---------------------- | ------------------------------------------------------------- |
| `Super + Return`       | Terminal (default: alacritty, resets keyboard layout)         |
| `Super + B`            | Browser (default: firefox)                                    |
| `Super + C`            | Editor (default: code)                                        |
| `Super + A`            | Antigravity AI IDE / agent workspace                          |
| `Super + E`            | Primary file explorer (default: thunar)                       |
| `Super + Alt + E`      | Secondary file explorer (nemo)                                |
| `Super + Shift + G`    | GitHub Desktop                                                |
| `Super + Shift_R`      | Telegram Messenger                                            |
| `Super + Shift + P`    | Calcurse interactive terminal calendar                        |
| `Ctrl + Alt + Escape`  | Task manager (qps)                                            |
| `Ctrl + Alt + V`       | Audio settings (default: pwvucontrol)                         |

---

### Shell Globals & Overlays

| Keybind             | Action                                          |
| ------------------- | ----------------------------------------------- |
| `Super + S`         | Caelestia cheatsheet keybinding overlay         |
| `Super + Tab`       | Window overview modal                           |
| `Super + Shift + T` | Optical character recognition (OCR) area tool   |
| `Super + Shift + W` | Nexus settings quick toggle                     |
| `Super + N`         | Live newsfeed panel                             |

---

### Utilities

| Keybind                   | Action                             |
| ------------------------- | ---------------------------------- |
| `Print`                   | Screenshot freeze overlay          |
| `Super + Shift + S`       | Screenshot freeze overlay          |
| `Super + Shift + Alt + S` | Screenshot region capture          |
| `Ctrl + Alt + R`          | Record fullscreen                  |
| `Super + Alt + R`         | Record with sound                  |
| `Super + Shift + Alt + R` | Record region                      |
| `Super + Shift + C`       | Color picker (`hyprpicker -a`)     |

---

### Media

| Keybind                              | Action                                  |
| ------------------------------------ | --------------------------------------- |
| `Ctrl + Super + Space`               | Play/pause                              |
| `Ctrl + Super + Equal`               | Next track                              |
| `Ctrl + Super + Minus`               | Previous track                          |
| `Ctrl + Super + Backspace`           | Stop playback                           |
| `Super + Shift + M`, `XF86AudioMute` | Mute volume                             |
| `XF86AudioRaiseVolume`               | Raise volume (`volume_control.sh up`)   |
| `XF86AudioLowerVolume`               | Lower volume (`volume_control.sh down`) |
| `XF86AudioMicMute`                   | Toggle microphone mute (`wpctl`)        |

---

### Miscellaneous

| Keybind               | Action                          |
| --------------------- | ------------------------------- |
| `Super + Shift + E`   | Open shell session menu         |
| `Super + Shift + N`   | Toggle shell sidebar            |
| `Super + Shift + W`   | Toggle Nexus settings           |
| `Ctrl + Alt + C`      | Clear shell notifications       |
| `Super + Alt + K`     | Show all shell panels           |
| `Super + Shift + O`   | Lock screen                     |
| `Super + Alt + O`     | Restore shell lockscreen        |
| `Super + Shift + L`   | Run sleep command               |

---

### Clipboard / Emoji

| Keybind                  | Action                               |
| ------------------------ | ------------------------------------ |
| `Super + V`              | Open clipboard history               |
| `Super + Alt + V`        | Open clipboard history (delete mode) |
| `Ctrl + Shift + Alt + V` | Paste latest clipboard entry         |
| `Super + Period`         | Open emoji picker                    |

---

### Shell

| Keybind                    | Action        |
| -------------------------- | ------------- |
| `Ctrl + Super + Alt + R`   | Restart shell |
| `Ctrl + Super + Shift + R` | Kill shell    |

[shell-repo]: https://github.com/caelestia-dots/shell
[cli-repo]: https://github.com/caelestia-dots/cli
