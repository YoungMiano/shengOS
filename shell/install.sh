#!/usr/bin/env bash
# install.sh — deploy the ShengOS shell environment for the current user
# Milestone 1: CLI & Native Command Mapping Engine
set -euo pipefail

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="$HOME/.shengos"

mkdir -p "$TARGET_DIR"
cp "$SRC_DIR/.shengrc" "$TARGET_DIR/.shengrc"
cp "$SRC_DIR/helpers.sh" "$TARGET_DIR/helpers.sh"
cp "$SRC_DIR/commands.json" "$TARGET_DIR/commands.json"

HOOK_LINE='source "$HOME/.shengos/.shengrc"'
if ! grep -qF "$HOOK_LINE" "$HOME/.bashrc" 2>/dev/null; then
    {
        echo ""
        echo "# ShengOS native Swahili/Sheng shell"
        echo "$HOOK_LINE"
    } >> "$HOME/.bashrc"
    echo "Imewekwa: .shengrc imeongezwa kwenye ~/.bashrc"
else
    echo "Tayari imewekwa: ~/.bashrc tayari ina ShengOS."
fi

echo "Sakinisho limekamilika. Fungua terminal mpya au endesha: source ~/.bashrc"
