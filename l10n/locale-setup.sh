#!/usr/bin/env bash
# locale-setup.sh — generate sw_KE.UTF-8 and configure graceful fallback
# Milestone 3: Core Desktop Environment Localization (gettext)
#
# Swahili is not fully translated for every app yet, so we rely on
# gettext's built-in fallback chain: the LANGUAGE variable (unlike LANG
# or LC_ALL) accepts a colon-separated priority list. If a msgid has no
# sw_KE translation in a given .mo, gettext automatically falls through
# to the next entry (en_US), and finally to the untranslated source
# string, rather than crashing or showing a blank label.
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
    echo "Tafadhali endesha na sudo: sudo ./locale-setup.sh"
    exit 1
fi

LOCALE_GEN="/etc/locale.gen"
ENV_FILE="/etc/environment"
LOCALE_CONF="/etc/default/locale"

# 1. Ensure sw_KE.UTF-8 (and en_US.UTF-8 as the fallback target) are enabled
#    in /etc/locale.gen, then generate them.
for entry in "sw_KE.UTF-8 UTF-8" "en_US.UTF-8 UTF-8"; do
    if grep -qE "^#?\s*${entry}" "$LOCALE_GEN" 2>/dev/null; then
        sed -i "s/^#\s*${entry}/${entry}/" "$LOCALE_GEN"
    else
        echo "$entry" >> "$LOCALE_GEN"
    fi
done

echo "Inatengeneza locale (hii inaweza kuchukua muda)..."
locale-gen

# 2. Set system-wide defaults with an explicit fallback chain.
#    LANGUAGE=sw_KE:en_US.UTF-8 -> try Swahili first, fall back to English
#    for any msgid that has no sw_KE translation yet.
{
    echo "LANG=sw_KE.UTF-8"
    echo "LC_ALL=sw_KE.UTF-8"
    echo "LANGUAGE=sw_KE:en_US.UTF-8"
} > "$LOCALE_CONF"

# 3. Also export LANGUAGE in /etc/environment so it applies to every
#    session (desktop, ssh, tty), not just interactive login shells.
if ! grep -q '^LANGUAGE=' "$ENV_FILE" 2>/dev/null; then
    echo 'LANGUAGE=sw_KE:en_US.UTF-8' >> "$ENV_FILE"
fi

echo ""
echo "Locale ya sw_KE.UTF-8 imewekwa kikamilifu."
echo "Mfumo huu sasa utaonyesha Kiswahili, na kurudi kwa Kiingereza"
echo "pale ambapo tafsiri ya Kiswahili haijakamilika bado."
echo "Ingia upya (log out/in) ili mabadiliko yatumike kikamilifu."
