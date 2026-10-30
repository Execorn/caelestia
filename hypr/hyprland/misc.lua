local scheme = require("scheme.current")

hl.config({
    misc = {
        vrr                          = 0,
        animate_manual_resizes       = false,
        animate_mouse_windowdragging = false,

        disable_hyprland_logo        = true,
        force_default_wallpaper      = 0,

        on_focus_under_fullscreen    = 2,
        allow_session_lock_restore   = true,
        middle_click_paste           = false,
        focus_on_activate            = true,
        session_lock_xray            = true,

        -- Keep DPMS wake-on-input enabled as a fallback, but never configure idle
        -- daemons (Caelestia IdleMonitors or hypridle) to dispatch "dpms off".
        -- Powering down DisplayPort links (D3) causes the VLI USB-C MST hub to drop
        -- its virtual sink IDs (nvidia-modeset displayId 0x4000/0x8000 invalid),
        -- which stalls subsequent atomic KMS wakeup across all monitors (including
        -- eDP-1) and leaves the USB-C hub unresponsive until physically replugged.
        mouse_move_enables_dpms      = true,
        key_press_enables_dpms       = true,

        initial_workspace_tracking   = 0,

        background_color             = "rgb(" .. scheme.surfaceContainer .. ")",
    },

    render = {
        direct_scanout    = 1,
        cm_enabled        = false,
        cm_auto_hdr       = 0,
        send_content_type = false,
    },

    cursor = {
        no_break_fs_vrr = 1,
    },

    debug = {
        error_position = 1
    }
})
