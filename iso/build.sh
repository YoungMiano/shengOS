#!/usr/bin/env bash
# build.sh — ShengOS Live-Build ISO pipeline
# Milestone 5: Live-Build ISO Pipeline Configuration
#
# Stages the outputs of Milestones 1-4 (shell/, pkg/, l10n/, branding/)
# into config/includes.chroot/, configures debian-live-build, and runs
# `lb build` to produce a bootable ShengOS .iso.
#
# Scope note: this build targets a LIVE-ONLY image (--debian-installer
# none). Install-to-disk is not yet implemented — that would be a
# natural Milestone 7 (e.g. calamares) if the project continues past
# the 6 milestones originally scoped.
set -euo pipefail

# shengos/ repo root (this script lives in shengos/iso/)
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ISO_DIR="$ROOT_DIR/iso"
WORK_DIR="$ISO_DIR/build"

if [ "$(id -u)" -ne 0 ]; then
    echo "Tafadhali endesha na sudo: sudo ./build.sh"
    exit 1
fi

if ! command -v lb >/dev/null 2>&1; then
    echo "Hitilafu: 'live-build' haijasakinishwa."
    echo "    sudo apt-get install live-build"
    exit 1
fi

echo "== Hatua 1: Kusafisha build ya awali (kama ipo) =="
rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

echo "== Hatua 2: lb config =="
lb config \
    --distribution bookworm \
    --architectures amd64 \
    --archive-areas "main contrib non-free non-free-firmware" \
    --debian-installer none \
    --iso-application "ShengOS" \
    --iso-volume "ShengOS" \
    --iso-publisher "ShengOS Project" \
    --bootappend-live "boot=live components username=mtumiaji hostname=shengos locales=sw_KE.UTF-8 keyboard-layouts=us"

echo "== Hatua 3: Kuweka orodha ya pakiti =="
mkdir -p config/package-lists
cp "$ISO_DIR/config/package-lists/shengos.list.chroot" config/package-lists/

echo "== Hatua 4: Kuandaa config/includes.chroot kutoka Milestone 1-4 =="
INCLUDES="config/includes.chroot"

# Start from the static files already tracked in iso/config/includes.chroot
# (lightdm configs, xfce4-desktop default) ...
cp -r "$ISO_DIR/config/includes.chroot/." "$INCLUDES/"

# ...then layer in the actual deliverables from each earlier milestone.
mkdir -p "$INCLUDES/etc/skel/.shengos"
cp "$ROOT_DIR/shell/.shengrc" "$INCLUDES/etc/skel/.shengos/.shengrc"
cp "$ROOT_DIR/shell/helpers.sh" "$INCLUDES/etc/skel/.shengos/helpers.sh"
cp "$ROOT_DIR/shell/commands.json" "$INCLUDES/etc/skel/.shengos/commands.json"

mkdir -p "$INCLUDES/usr/local/bin"
cp "$ROOT_DIR/pkg/vuta.py" "$INCLUDES/usr/local/bin/vuta"

mkdir -p "$INCLUDES/usr/share/shengos/l10n/po/sw_KE"
cp "$ROOT_DIR/l10n/po/sw_KE/"*.po "$INCLUDES/usr/share/shengos/l10n/po/sw_KE/"

mkdir -p "$INCLUDES/usr/share/backgrounds/shengos" "$INCLUDES/usr/share/applications"
cp "$ROOT_DIR/branding/wallpapers/shengos-default.svg" "$INCLUDES/usr/share/backgrounds/shengos/"
cp "$ROOT_DIR/branding/desktop-shortcuts/"*.desktop "$INCLUDES/usr/share/applications/"

echo "== Hatua 5: Kuweka hook za chroot =="
mkdir -p config/hooks/normal
cp "$ISO_DIR/config/hooks/normal/"*.hook.chroot config/hooks/normal/
chmod +x config/hooks/normal/*.hook.chroot

echo "== Hatua 6: lb build (hii inaweza kuchukua dakika 30-60+) =="
lb build 2>&1 | tee "$WORK_DIR/build.log"

ISO_FILE=$(find "$WORK_DIR" -maxdepth 1 -name "*.iso" | head -1)
if [ -n "$ISO_FILE" ]; then
    echo ""
    echo "Umefanikiwa! ISO ya ShengOS iko hapa: $ISO_FILE"
    echo "Jaribu kwenye VirtualBox/QEMU kabla ya kuandika kwenye USB."
else
    echo ""
    echo "Hitilafu: hakuna .iso iliyotengenezwa. Angalia $WORK_DIR/build.log kwa maelezo."
    exit 1
fi
