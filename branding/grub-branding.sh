#!/usr/bin/env bash
# grub-branding.sh — customize GRUB bootloader branding for ShengOS
# Milestone 4: OS Customization & Branding Scripts
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
    echo "Tafadhali endesha na sudo: sudo ./grub-branding.sh"
    exit 1
fi

GRUB_DEFAULT_FILE="/etc/default/grub"
GRUB_BG_TARGET="/usr/share/backgrounds/shengos/shengos-grub.png"

if [ ! -f "$GRUB_DEFAULT_FILE" ]; then
    echo "Hitilafu: $GRUB_DEFAULT_FILE haipo. Hii inaonekana si mfumo wenye GRUB."
    exit 1
fi

set_grub_var() {
    local key="$1" value="$2"
    if grep -q "^${key}=" "$GRUB_DEFAULT_FILE"; then
        sed -i "s|^${key}=.*|${key}=\"${value}\"|" "$GRUB_DEFAULT_FILE"
    elif grep -q "^#${key}=" "$GRUB_DEFAULT_FILE"; then
        sed -i "s|^#${key}=.*|${key}=\"${value}\"|" "$GRUB_DEFAULT_FILE"
    else
        echo "${key}=\"${value}\"" >> "$GRUB_DEFAULT_FILE"
    fi
}

echo "Inarekebisha jina na muonekano wa GRUB..."

set_grub_var "GRUB_DISTRIBUTOR" "ShengOS"
set_grub_var "GRUB_TIMEOUT" "5"
set_grub_var "GRUB_TIMEOUT_STYLE" "menu"

if [ -f "$GRUB_BG_TARGET" ]; then
    set_grub_var "GRUB_BACKGROUND" "$GRUB_BG_TARGET"
    echo "  [SAWA] Picha ya mandhari ya GRUB imewekwa: $GRUB_BG_TARGET"
else
    echo "  [ONYO] $GRUB_BG_TARGET haipo bado — endesha branding-install.sh kwanza ili kutengeneza picha."
fi

if command -v update-grub >/dev/null 2>&1; then
    echo "Inasasisha grub.cfg..."
    update-grub
    echo "GRUB imesasishwa. Anzisha upya kompyuta kuona mabadiliko."
elif command -v grub-mkconfig >/dev/null 2>&1; then
    echo "Inasasisha grub.cfg..."
    grub-mkconfig -o /boot/grub/grub.cfg
    echo "GRUB imesasishwa. Anzisha upya kompyuta kuona mabadiliko."
else
    echo "  [ONYO] Haikuweza kupata update-grub/grub-mkconfig. Sasisha grub.cfg mwenyewe."
fi
