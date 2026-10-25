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
local function match_str(pattern, field, exact)
    return function(w)
        return w[field] and string.find(w[field], pattern, 1, exact)
    end
end

local function match_title(pattern, exact)
    return match_str(pattern, "title", exact)
end

local function match_class(pattern, exact)
    return match_str(pattern, "class", exact)
end

local function match_tag(tag)
    local starred = tag .. "*"
    return function(w)
        if not w.tags then
            return false
        end
        for _, t in ipairs(w.tags) do
            if t == tag or t == starred then
                return true
            end
        end
        return false
    end
end

local match_bitwarden_class = match_class("Bitwarden", true)
local match_bitwarden_title = match_title("^Extension: %(Bitwarden Password Manager%) %- Bitwarden", false)
local match_bitwarden_chr   = match_class("nngceckbapebfimnlniiiahkandclblb", true)
local match_pip_title       = match_title("^Picture[- ]in[- ][Pp]icture$", false)
local match_tag_60_70       = match_tag("float_60_70")
local match_tag_70_80       = match_tag("float_70_80")
local match_tag_50_60       = match_tag("float_50_60")

local function float_center_actions(win)
    return {
        hl.dsp.window.float({ action = "on", window = win }),
        hl.dsp.window.center({ window = win }),
    }
end

local function pip_move_actions(win)
    return fn.move_actions(win) or {}
end

local function apply_class_rules(win)
    if not win then
        return
    end
    fn.resizer(win, match_bitwarden_class, 20, 54, float_center_actions) -- Native app
    fn.resizer(win, match_bitwarden_chr, 20, 54, float_center_actions)   -- Chromium
end

local function apply_title_rules(win)
    if not win then
        return
    end
    fn.resizer(win, match_bitwarden_title, 20, 54, float_center_actions) -- Firefox
    fn.resizer(win, match_pip_title, 0, 0, pip_move_actions)             -- Picture in picture
end

local function apply_tag_rules(win)
    if not win then
        return
    end
    fn.resizer(win, match_tag_60_70, 60, 70, float_center_actions)
    fn.resizer(win, match_tag_70_80, 70, 80, float_center_actions)
    fn.resizer(win, match_tag_50_60, 50, 60, float_center_actions)
end

local function apply_resizer_rules(win)
    if not win then
        return
    end
    apply_class_rules(win)
    apply_title_rules(win)
    apply_tag_rules(win)
end

hl.on("window.class", apply_class_rules)
hl.on("window.title", apply_title_rules)
hl.on("window.open", apply_resizer_rules)

-- Detect when a window's tags change
local lastTags = {}

local function tag_key(tags)
    if not tags then
        return ""
    end
    local copy = {}
    for _, tag in ipairs(tags) do
        copy[#copy + 1] = tag:gsub("%*$", "")
    end
    table.sort(copy)
    return table.concat(copy, "\0")
end

hl.on("window.update_rules", function(win)
    if not win then
        return
    end
    local id = win.stable_id
    local key = tag_key(win.tags)
    if lastTags[id] == key then
        return
    end
    lastTags[id] = key
    apply_tag_rules(win)
end)

hl.on("window.close", function(win)
    if win then
        lastTags[win.stable_id] = nil
    end
end)
