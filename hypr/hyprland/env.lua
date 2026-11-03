local vars = require("variables")

-- Themes
hl.env("QT_QPA_PLATFORMTHEME", "qtengine")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
hl.env("XCURSOR_THEME", vars.cursorTheme)
hl.env("XCURSOR_SIZE", tostring(vars.cursorSize))

-- PATH
hl.env("PATH", os.getenv("HOME") .. "/.local/bin:" .. (os.getenv("PATH") or ""))

-- Toolkit backends
hl.env("GDK_BACKEND", "wayland,x11")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("SDL_VIDEODRIVER", "wayland,x11,windows")
hl.env("CLUTTER_BACKEND", "wayland")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")

-- XDG specifications
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

-- Others
hl.env("_JAVA_AWT_WM_NONREPARENTING", "1")
hl.env("MOZ_ENABLE_WAYLAND", "1")

local home = os.getenv("HOME") or ""
local function dir_exists(path)
    if not path or path == "" then return false end
    local f = io.open(path .. "/.", "r")
    if f then
        f:close()
        return true
    end
    return false
end

if not os.getenv("QML2_IMPORT_PATH") then
    local candidate_qml = {
        home .. "/.local/lib/qt6/qml",
        home .. "/ricing/shell/build/qml",
        home .. "/programming/projects/shell/build/qml",
    }
    for _, path in ipairs(candidate_qml) do
        if dir_exists(path) then
            hl.env("QML2_IMPORT_PATH", path)
            break
        end
    end
end

if not os.getenv("CAELESTIA_LIB_DIR") then
    local candidate_lib = {
        home .. "/.local/lib/caelestia",
        home .. "/ricing/shell/build/lib",
        home .. "/programming/projects/shell/build/lib",
    }
    for _, path in ipairs(candidate_lib) do
        if dir_exists(path) then
            hl.env("CAELESTIA_LIB_DIR", path)
            break
        end
    end
end

-- In Discrete-Only NVIDIA mode (single DRM render node), prevent libglvnd from
-- probing 50_mesa.json, which faults in ~98 MiB of libLLVM + libgallium per process.
local f_r129 = io.open("/dev/dri/renderD129", "r")
if f_r129 then
    f_r129:close()
else
    local f_nv = io.open("/usr/share/glvnd/egl_vendor.d/10_nvidia.json", "r")
    if f_nv then
        f_nv:close()
        hl.env("__EGL_VENDOR_LIBRARY_FILENAMES", "/usr/share/glvnd/egl_vendor.d/10_nvidia.json")
        hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
    end
end
