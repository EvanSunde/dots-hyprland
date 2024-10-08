#!/usr/bin/env sh

scrDir=$(dirname "$(realpath "$0")")
source "$scrDir/globalcontrol.sh"

function print_error {
    cat << "EOF"
Usage: ./brightnesscontrol.sh <action> [contrast]
...valid actions are...
    i -- <i>ncrease brightness [+5%]
    d -- <d>ecrease brightness [-5%]
    ci -- <c>ontrast increase [+5%]
    cd -- <c>ontrast decrease [-5%]
EOF
}

function send_notification {
    brightness=$(brightnessctl info | grep -oP "(?<=\()\d+(?=%)" | cat)
    brightinfo=$(brightnessctl info | awk -F "'" '/Device/ {print $2}')
    angle="$(((($brightness + 2) / 5) * 5))"
    ico="$HOME/.config/dunst/icons/vol/vol-${angle}.svg"
    bar=$(seq -s "." $((brightness / 15)) | sed 's/[0-9]//g')
    notify-send -a "t2" -r 91190 -t 800 -i "$ico" "${brightness}${bar}" "${brightinfo}"
}

function get_brightness {
    brightnessctl -m | grep -o '[0-9]\+%' | head -c-2
}

function get_focused_monitor {
    monitor_info=$(hyprctl monitors -j)
    focused_monitor=$(echo "$monitor_info" | jq -r '.[] | select(.focused == true) | .name')
    echo "$focused_monitor"
}

function set_brightness_ddc {
    monitor_id=$1
    case $2 in
        i)
            ddcutil setvcp 10 + 5 ;;  # Brightness
        d)
            ddcutil setvcp 10 - 5 ;;  # Brightness
        ci)
            ddcutil setvcp 12 + 5 ;;  # Contrast
        cd)
            ddcutil setvcp 12 - 5 ;;  # Contrast
    esac
}

case $1 in
    i|d)
        focused_monitor=$(get_focused_monitor)

        if [ "$focused_monitor" = "eDP-1" ]; then
            # Use brightnessctl for internal monitor (eDP-1)
            if [[ $1 == "i" ]]; then
                if [[ $(get_brightness) -lt 10 ]]; then
                    brightnessctl set +1%
                else
                    brightnessctl set +5%
                fi
            elif [[ $1 == "d" ]]; then
                if [[ $(get_brightness) -le 1 ]]; then
                    brightnessctl set 1%
                elif [[ $(get_brightness) -le 10 ]]; then
                    brightnessctl set 1%-
                else
                    brightnessctl set 5%-
                fi
            fi
        else
            # Use ddcutil for external monitors
            set_brightness_ddc "$focused_monitor" "$1"
        fi

        # Send notification regardless of method
        send_notification
        ;;
    ci|cd)
        focused_monitor=$(get_focused_monitor)

        if [ "$focused_monitor" != "eDP-1" ]; then
            # Use ddcutil for external monitors
            set_brightness_ddc "$focused_monitor" "$1"
            # Send notification after contrast adjustment (not implemented for ddcutil)
            notify-send "Contrast Adjusted" "Action $1 on $focused_monitor"
        else
            echo "Contrast adjustment is not applicable for internal monitor (eDP-1)."
        fi
        ;;
    *)
        # Print error
        print_error
        ;;
esac
