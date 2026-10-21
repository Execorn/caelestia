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
hl.env("QML2_IMPORT_PATH", "/home/execorn/.local/lib/qt6/qml")
hl.env("CAELESTIA_LIB_DIR", "/home/execorn/.local/lib/caelestia")

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
