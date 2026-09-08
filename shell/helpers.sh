#!/usr/bin/env bash
# helpers.sh — ShengOS native Swahili/Sheng shell helper functions
# Milestone 1: CLI & Native Command Mapping Engine
#
# These functions wrap common GNU coreutils so that ShengOS gives
# native Swahili/Sheng feedback (not just translated aliases that
# still leak raw English errors from the underlying binary).

# ---- colour helpers -------------------------------------------------
_sheng_red()    { printf "\033[1;31m%s\033[0m\n" "$1"; }
_sheng_green()  { printf "\033[1;32m%s\033[0m\n" "$1"; }
_sheng_yellow() { printf "\033[1;33m%s\033[0m\n" "$1"; }

# ---- vuka (cd) --------------------------------------------------------
vuka() {
    if [ -z "$1" ]; then
        builtin cd "$HOME" || return 1
        return 0
    fi
    if [ ! -d "$1" ]; then
        _sheng_red "Hitilafu: saraka '$1' haipo."
        return 1
    fi
    builtin cd "$1" || { _sheng_red "Imeshindikana kuingia '$1'."; return 1; }
}
sogea() { vuka "$@"; }

# ---- unda (mkdir) ------------------------------------------------------
unda() {
    if [ -z "$1" ]; then
        _sheng_red "Tumia hivi: unda <jina_la_saraka>"
        return 1
    fi
    if [ -d "$1" ]; then
        _sheng_yellow "Saraka '$1' tayari ipo."
        return 1
    fi
    if command mkdir -p "$1"; then
        _sheng_green "Saraka '$1' imeundwa."
    else
        _sheng_red "Imeshindikana kuunda saraka '$1'."
        return 1
    fi
}
tengeneza() { unda "$@"; }

# ---- dema / futa (rm) ---------------------------------------------------
dema() {
    if [ -z "$1" ]; then
        _sheng_red "Tumia hivi: dema <faili>"
        return 1
    fi
    for target in "$@"; do
        if [ ! -e "$target" ]; then
            _sheng_red "Hitilafu: '$target' haipo."
            continue
        fi
        if command rm -r "$target" 2>/dev/null; then
            _sheng_green "'$target' imefutwa."
        else
            _sheng_red "Imeshindikana kufuta '$target'. Labda unahitaji 'boss'."
        fi
    done
}
futa() { dema "$@"; }

# ---- boss / mkuu (sudo) --------------------------------------------------
boss() {
    if [ -z "$1" ]; then
        _sheng_red "Tumia hivi: boss <amri>"
        return 1
    fi
    _sheng_yellow "Unahitaji ruhusa ya msimamizi (mkuu)..."
    command sudo "$@"
    local status=$?
    if [ $status -ne 0 ]; then
        _sheng_red "Ruhusa imekataliwa au amri imeshindwa."
    fi
    return $status
}
mkuu() { boss "$@"; }

# ---- safi / safisha (clear) ----------------------------------------------
safi() { command clear; }
safisha() { command clear; }

# ---- soma (cat) -----------------------------------------------------------
soma() {
    if [ -z "$1" ]; then
        _sheng_red "Tumia hivi: soma <faili>"
        return 1
    fi
    for f in "$@"; do
        if [ ! -f "$f" ]; then
            _sheng_red "Hitilafu: faili '$f' haipo."
            continue
        fi
        command cat "$f"
    done
}

# ---- cheki / orodha (ls) ---------------------------------------------------
cheki() { command ls --color=auto "$@"; }
orodha() { command ls --color=auto "$@"; }

# ---- tafuta (grep) ------------------------------------------------------
tafuta() {
    if [ -z "$2" ]; then
        _sheng_red "Tumia hivi: tafuta <neno> <faili>"
        return 1
    fi
    command grep --color=auto "$@"
}

# ---- usaidizi (help) — lists every ShengOS command from commands.json -----
usaidizi() {
    local map_file="${SHENGOS_HOME:-$HOME/.shengos}/commands.json"
    if [ ! -f "$map_file" ]; then
        _sheng_red "Faili ya amri (commands.json) haikupatikana: $map_file"
        return 1
    fi
    if command -v jq >/dev/null 2>&1; then
        _sheng_green "== Amri za ShengOS =="
        jq -r '.commands[] | "\(.sheng)/\(.swahili)\t-> \(.original)\t(\(.desc_sw))"' "$map_file" | column -t -s $'\t'
    else
        _sheng_yellow "jq haijasakinishwa — onyesho la msingi tu."
        cat "$map_file"
    fi
}
