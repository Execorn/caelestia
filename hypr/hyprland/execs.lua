local vars = require("variables")
local fn   = require("utils.functions")

hl.on("hyprland.start", function()
    -- Dbus activation environment
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP HYPRLAND_INSTANCE_SIGNATURE XDG_SESSION_ID QT_QPA_PLATFORM")

    -- Keyring and auth (run polkit agent inside user slice in case ananicy-cpp moved Hyprland to root cgroup)
    hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")
    hl.exec_cmd("systemd-run --user --quiet --collect /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")

    -- Clipboard history
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")

    -- Auto delete trash 30 days old (non-interactive so it never blocks on stdin)
    hl.exec_cmd("trash-empty -f 30")

    -- Cursors
    hl.exec_cmd("hyprctl setcursor " .. vars.cursorTheme .. " " .. vars.cursorSize)
    hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-theme " .. vars.cursorTheme)
    hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-size " .. vars.cursorSize)

    -- Media commands (Bluetooth UI is handled natively by Caelestia)
    hl.exec_cmd("mpris-proxy")

    -- Wallpaper daemon
    hl.exec_cmd("wwald")

    -- Start shell (window resizing is handled by Lua hooks below)
    hl.exec_cmd("caelestia shell -d")
end)

-- Resizer listeners
local function float_center_actions(win)
    return {
        hl.dsp.window.float({ action = "on", window = win }),
        hl.dsp.window.center({ window = win }),
    }
end

local function pip_move_actions(win)
    return fn.move_actions(win) or {}
end

local function apply_resizer_rules(win)
    if not win then
        return
    end

    -- Bitwarden
    fn.resizer(win, "Bitwarden", 20, 54, float_center_actions, true, "class")                                       -- Native app
    fn.resizer(win, "^Extension: %(Bitwarden Password Manager%) %- Bitwarden", 20, 54, float_center_actions, false) -- Firefox
    fn.resizer(win, "nngceckbapebfimnlniiiahkandclblb", 20, 54, float_center_actions, true, "class")                -- Chromium

    -- Picture in picture
    fn.resizer(win, "Picture[- ]in[- ][Pp]icture", 0, 0, pip_move_actions, false)
end

hl.on("window.title", apply_resizer_rules)
hl.on("window.open", apply_resizer_rules)
