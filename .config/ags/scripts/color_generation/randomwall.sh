#!/usr/bin/env bash
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
CONFIG_DIR="$XDG_CONFIG_HOME/ags"

# Check if a directory was provided as an argument
if [ $# -ne 1 ]; then
    echo "Usage: $0 /path/to/wallpapers"
    exit 1
fi

WALLPAPER_DIR="$1"

# Check if the specified directory exists
if [ ! -d "$WALLPAPER_DIR" ]; then
    echo "Error: Directory '$WALLPAPER_DIR' does not exist."
    exit 1
fi

# Find a random wallpaper from the specified directory
RANDOM_WALLPAPER="$(fd . "$WALLPAPER_DIR" -e .png -e .jpg -e .svg | xargs shuf -n1 -e)"

# Check if any wallpaper was found
if [ -z "$RANDOM_WALLPAPER" ]; then
    echo "No wallpapers found in '$WALLPAPER_DIR'."
    exit 1
fi

# Call the switchwall script with the selected wallpaper
$CONFIG_DIR/scripts/color_generation/switchwall.sh "$RANDOM_WALLPAPER"
