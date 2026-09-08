#!/usr/bin/env bash
# build.sh — compile ShengOS .po catalogs into .mo and install them
# Milestone 3: Core Desktop Environment Localization (gettext)
set -euo pipefail

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PO_DIR="$SRC_DIR/po/sw_KE"
LOCALE_ROOT="/usr/share/locale/sw_KE/LC_MESSAGES"

if ! command -v msgfmt >/dev/null 2>&1; then
    echo "Hitilafu: 'msgfmt' haijasakinishwa. Sakinisha kifurushi cha 'gettext' kwanza:"
    echo "    sudo apt-get install gettext"
    exit 1
fi

if [ "$(id -u)" -ne 0 ]; then
    echo "Tafadhali endesha na sudo: sudo ./build.sh"
    exit 1
fi

mkdir -p "$LOCALE_ROOT"

# Each .po file is named after its gettext textdomain, which is how the
# application looks up its own translations at runtime.
count=0
for po_file in "$PO_DIR"/*.po; do
    domain="$(basename "$po_file" .po)"
    mo_file="$LOCALE_ROOT/$domain.mo"

    echo "Inatengeneza: $domain.po -> $domain.mo"
    if msgfmt -c -o "$mo_file" "$po_file"; then
        echo "  [SAWA] imewekwa kwenye $mo_file"
        count=$((count + 1))
    else
        echo "  [HITILAFU] $domain.po ina makosa ya kisintaksia (angalia juu)"
        exit 1
    fi
done

echo ""
echo "Kamili: $count kati ya vitomeo vimetengenezwa na kuwekwa kwenye $LOCALE_ROOT"
echo "Anzisha upya programu husika (au ingia upya) ili kuona tafsiri."
