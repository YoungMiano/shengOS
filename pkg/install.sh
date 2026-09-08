#!/usr/bin/env bash
# install.sh — deploy the `vuta` package manager wrapper system-wide
# Milestone 2: Native Package Manager (vuta CLI Tool)
set -euo pipefail

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="/usr/local/bin"
TARGET="$BIN_DIR/vuta"

if [ "$(id -u)" -ne 0 ]; then
    echo "Tafadhali endesha na sudo: sudo ./install.sh"
    exit 1
fi

install -m 755 "$SRC_DIR/vuta.py" "$TARGET"

# Every Sheng/Swahili command name points at the same script; vuta.py
# looks at argv[0] (the symlink name) to decide what to do.
for alias in sakinisha toa ondoa update upya tafuta orodha usaidizi; do
    ln -sf "$TARGET" "$BIN_DIR/$alias"
done

echo "vuta imesakinishwa. Jaribu: vuta neofetch   au   usaidizi"
