// hyprland monitor sleep script according to focused monitor

#!/bin/bash

get_focused_monitor() {
  monitor_info=$(hyprctl monitors -j)
  focused_monitor=$(echo "$monitor_info" | jq -r '.[] | select(.focused == true) | .name')
  echo "$focused_monitor"
}

handle_lid_switch() {
  if [ "$1" = "on" ]; then
    if [ "$(get_focused_monitor)" = "eDP-1" ]; then
      loginctl lock-session
      sleep 0.7
      systemctl sleep
    else
      hyprctl keyword monitor "eDP-1, disable"
    fi
  elif [ "$1" = "off" ]; then
    hyprctl keyword monitor "eDP-1, preferred,0x0,1"
  fi
}

handle_lid_switch "$1"