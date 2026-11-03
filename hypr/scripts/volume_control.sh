#!/bin/bash

# Target default sink by default
TARGET="@DEFAULT_AUDIO_SINK@"

# If a virtual sink (EasyEffects or Equalizer) is active, find the physical sink driving it
if pactl get-default-sink 2>/dev/null | grep -qxE "riced_equalizer_sink|easyeffects_sink"; then
    SINK_LIST=$(pactl -f json list sinks | jq -r '.[] | select(.name != "riced_equalizer_sink" and .name != "easyeffects_sink" and (.properties["node.virtual"] != "true") and (.name | ascii_downcase | contains("loopback") | not) and (.description | ascii_downcase | contains("loopback") | not) and (.name | ascii_downcase | contains("microphone") | not) and (.name | ascii_downcase | contains("mic") | not) and (.description | ascii_downcase | contains("microphone") | not) and (.description | ascii_downcase | contains("mic") | not)) | .name' 2>/dev/null)
    
    BEST_SINK=""
    for s in $SINK_LIST; do
        if [[ "$s" == bluez_output* ]]; then
            BEST_SINK="$s"
            break
        fi
    done
    if [ -z "$BEST_SINK" ]; then
        for s in $SINK_LIST; do
            if [[ "$s" == *usb* ]]; then
                BEST_SINK="$s"
                break
            fi
        done
    fi
    if [ -z "$BEST_SINK" ]; then
        for s in $SINK_LIST; do
            if [[ "$s" != *analog-stereo* ]]; then
                BEST_SINK="$s"
                break
            fi
        done
    fi
    if [ -z "$BEST_SINK" ]; then
        BEST_SINK=$(echo "$SINK_LIST" | head -n 1)
    fi
    
    if [ -n "$BEST_SINK" ]; then
        RESOLVED_ID=$(pw-dump | jq --arg name "$BEST_SINK" '.[] | select(.info?.props?."node.name" == $name) | .id' 2>/dev/null)
        if [ -n "$RESOLVED_ID" ]; then
            TARGET="$RESOLVED_ID"
        fi
    fi
fi

ACTION="$1"
STEP=""

# Try to parse from caelestia settings
CONFIG_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/caelestia/shell.json"
if [ -f "$CONFIG_FILE" ]; then
    JSON_STEP=$(jq -r '((.services.audioIncrement // 0.05) * 100) | round' "$CONFIG_FILE" 2>/dev/null)
    if [ -n "$JSON_STEP" ] && [ "$JSON_STEP" != "null" ]; then
        STEP="$JSON_STEP"
    fi
fi

# Override with argument if explicitly provided
if [ -n "$2" ]; then
    STEP="$2"
fi

# Fallback to default of 5 if still empty
if [ -z "$STEP" ]; then
    STEP=5
fi

case "$ACTION" in
    up)
        wpctl set-mute "$TARGET" 0
        wpctl set-volume -l 1 "$TARGET" "${STEP}%+"
        ;;
    down)
        wpctl set-mute "$TARGET" 0
        wpctl set-volume "$TARGET" "${STEP}%-"
        ;;
    mute)
        wpctl set-mute "$TARGET" toggle
        ;;
    *)
        echo "Usage: $0 {up|down|mute} [step_percentage]"
        exit 1
        ;;
esac

# Notify quickshell of the volume change
VOLUME_INFO=$(wpctl get-volume "$TARGET")
VOL=$(echo "$VOLUME_INFO" | awk '{print $2}')
MUTED="false"
if echo "$VOLUME_INFO" | grep -q "MUTED"; then
    MUTED="true"
fi

quickshell -c caelestia ipc call audio updateVolume "$VOL" "$MUTED" >/dev/null 2>&1 &
