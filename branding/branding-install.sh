#!/usr/bin/env bash
# branding-install.sh — master installer for Milestone 4 (OS Customization & Branding)
#
# Order of operations:
#   1. Rasterize the SVG wallpaper to PNG (needed by desktop, GRUB, LightDM)
#   2. Install wallpaper + desktop shortcuts system-wide
#   3. Set sw_KE.UTF-8 as the system default (delegates to Milestone 3's
#      l10n/locale-setup.sh so locale logic lives in exactly one place)
#   4. Brand GRUB and LightDM
#
# Run individual scripts (set-theme.sh, grub-branding.sh, lightdm-branding.sh)
# on their own later if you only need to redo one piece.
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
    echo "Tafadhali endesha na sudo: sudo ./branding-install.sh"
    exit 1
fi

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BG_DIR="/usr/share/backgrounds/shengos"
APPS_DIR="/usr/share/applications"
SVG_SRC="$SRC_DIR/wallpapers/shengos-default.svg"

mkdir -p "$BG_DIR"

echo "== Hatua 1: Kutengeneza picha ya mandhari (SVG -> PNG) =="
# NOTE: ImageMagick's `convert` delegates SVG rendering to rsvg-convert
# internally, so it is NOT an independent fallback from librsvg2-bin —
# installing librsvg2-bin fixes both paths at once. inkscape is the one
# genuinely independent alternative (it ships its own SVG renderer).
if command -v rsvg-convert >/dev/null 2>&1; then
    rsvg-convert -w 1920 -h 1080 "$SVG_SRC" -o "$BG_DIR/shengos-default.png"
elif command -v inkscape >/dev/null 2>&1; then
    inkscape "$SVG_SRC" --export-type=png --export-filename="$BG_DIR/shengos-default.png" -w 1920 -h 1080
elif command -v convert >/dev/null 2>&1; then
    # Will only succeed if librsvg2-bin happens to be present already.
    convert -background none -resize 1920x1080 "$SVG_SRC" "$BG_DIR/shengos-default.png" 2>/dev/null || true
fi

if [ ! -f "$BG_DIR/shengos-default.png" ]; then
    echo "  [ONYO] Hakuna zana ya kubadilisha SVG kuwa PNG iliyofanikiwa."
    echo "         Sakinisha: sudo apt-get install librsvg2-bin"
    echo "         Mandhari itabaki kama SVG pekee kwa sasa: $SVG_SRC"
fi

if [ -f "$BG_DIR/shengos-default.png" ]; then
    cp "$BG_DIR/shengos-default.png" "$BG_DIR/shengos-grub.png"
    echo "  [SAWA] Picha zimewekwa kwenye $BG_DIR"
fi

echo ""
echo "== Hatua 2: Kusakinisha njia za mkato za dawati (Kiswahili) =="
for f in "$SRC_DIR"/desktop-shortcuts/*.desktop; do
    cp "$f" "$APPS_DIR/"
    echo "  [SAWA] $(basename "$f") imesakinishwa"
done

echo ""
echo "== Hatua 3: Kuweka sw_KE.UTF-8 kama lugha chaguomsingi ya mfumo =="
L10N_SCRIPT="$SRC_DIR/../l10n/locale-setup.sh"
if [ -x "$L10N_SCRIPT" ] || [ -f "$L10N_SCRIPT" ]; then
    bash "$L10N_SCRIPT"
else
    echo "  [ONYO] $L10N_SCRIPT haikupatikana. Ruka hatua hii; endesha Milestone 3's locale-setup.sh mwenyewe."
fi

echo ""
echo "== Hatua 4: Kubadilisha GRUB na LightDM =="
bash "$SRC_DIR/grub-branding.sh" || echo "  [ONYO] Urekebishaji wa GRUB umerukwa/umeshindikana (angalia juu)."
bash "$SRC_DIR/lightdm-branding.sh" || echo "  [ONYO] Urekebishaji wa LightDM umerukwa/umeshindikana (angalia juu)."

echo ""
echo "Usakinishaji wa chapa ya ShengOS umekamilika."
echo "Mtumiaji anaweza sasa kuendesha set-theme.sh (bila sudo) kuweka mandhari yake binafsi."
