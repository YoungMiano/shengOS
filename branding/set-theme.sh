#!/usr/bin/env bash
# set-theme.sh — apply ShengOS desktop theme, wallpaper, and fonts
# Milestone 4: OS Customization & Branding Scripts
#
# Runs as the logged-in user (NOT root) since xfconf-query writes to the
# current user's XFCE session settings.
set -euo pipefail

if [ "$(id -u)" -eq 0 ]; then
    echo "Usiendeshe hii kama root. Endesha kama mtumiaji wa kawaida ndani ya XFCE."
    exit 1
fi

if ! command -v xfconf-query >/dev/null 2>&1; then
    echo "Hitilafu: xfconf-query haipo. Hakikisha unatumia XFCE."
    exit 1
fi

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WALLPAPER_SVG="$SRC_DIR/wallpapers/shengos-default.svg"
WALLPAPER_INSTALLED="/usr/share/backgrounds/shengos/shengos-default.png"

echo "Inaweka mandhari ya ShengOS..."

# Wallpaper — apply to every monitor/workspace property xfdesktop exposes.
if [ -f "$WALLPAPER_INSTALLED" ]; then
    for prop in $(xfconf-query -c xfce4-desktop -l | grep last-image); do
        xfconf-query -c xfce4-desktop -p "$prop" -s "$WALLPAPER_INSTALLED"
    done
    echo "  [SAWA] Mandhari ya dawati imewekwa: $WALLPAPER_INSTALLED"
else
    echo "  [ONYO] $WALLPAPER_INSTALLED haipo bado. Endesha branding-install.sh (kama root) kwanza ili kubadilisha SVG kuwa PNG."
fi

# GTK / window manager theme — dark, high-contrast, matches the wallpaper palette.
xfconf-query -c xsettings -p /Net/ThemeName -s "Adwaita-dark" --create -t string
xfconf-query -c xfwm4 -p /general/theme -s "Default" --create -t string
xfconf-query -c xsettings -p /Net/IconThemeName -s "Papirus-Dark" --create -t string 2>/dev/null || true

# Default system font — good Latin/Swahili glyph coverage.
xfconf-query -c xsettings -p /Gtk/FontName -s "Noto Sans 10" --create -t string
xfconf-query -c xfwm4 -p /general/title_font -s "Noto Sans Bold 10" --create -t string

# Cursor theme
xfconf-query -c xsettings -p /Gtk/CursorThemeName -s "Adwaita" --create -t string

echo "Mandhari ya ShengOS imewekwa. Ingia upya ili kuona mabadiliko yote."
