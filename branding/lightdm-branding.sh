#!/usr/bin/env bash
# lightdm-branding.sh — brand the LightDM login screen for ShengOS
# Milestone 4: OS Customization & Branding Scripts
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
    echo "Tafadhali endesha na sudo: sudo ./lightdm-branding.sh"
    exit 1
fi

GREETER_CONF="/etc/lightdm/lightdm-gtk-greeter.conf"
LIGHTDM_CONF_DIR="/etc/lightdm/lightdm.conf.d"
LIGHTDM_CONF="$LIGHTDM_CONF_DIR/50-shengos.conf"
BG_TARGET="/usr/share/backgrounds/shengos/shengos-default.png"

if ! command -v lightdm >/dev/null 2>&1 && [ ! -d "/etc/lightdm" ]; then
    echo "Hitilafu: LightDM haionekani kusakinishwa kwenye mfumo huu."
    exit 1
fi

mkdir -p "$(dirname "$GREETER_CONF")" "$LIGHTDM_CONF_DIR"

echo "Inarekebisha LightDM greeter..."

# lightdm-gtk-greeter: background, theme, and a Swahili welcome message
# rendered as the greeter's clock/notice label via GTK theme string.
cat > "$GREETER_CONF" <<EOF
[greeter]
background = $BG_TARGET
theme-name = Adwaita-dark
icon-theme-name = Papirus-Dark
font-name = Noto Sans 10
indicators = ~host;~spacer;~clock;~spacer;~session;~language;~power
clock-format = %H:%M — Karibu ShengOS
EOF

# System-wide LightDM behavior: show the ShengOS name, don't hide the
# manual-login option (useful while the distro is new and accounts vary).
cat > "$LIGHTDM_CONF" <<EOF
[Seat:*]
greeter-session=lightdm-gtk-greeter
greeter-show-manual-login=true
greeter-hide-users=false
EOF

if [ -f "$BG_TARGET" ]; then
    echo "  [SAWA] Picha ya nyuma ya kuingia imewekwa: $BG_TARGET"
else
    echo "  [ONYO] $BG_TARGET haipo bado — endesha branding-install.sh kwanza."
fi

echo "LightDM imebadilishwa. Anzisha upya huduma ili kuona mabadiliko:"
echo "    sudo systemctl restart lightdm"
