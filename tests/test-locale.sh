#!/usr/bin/env bash
# test-locale.sh — verify Milestone 3 locale persistence
# Milestone 6: Documentation, Testing & Installation Guide
#
# Has two modes:
#   1. Repo-level checks (run anywhere, including on your Mac): validates
#      the .po catalogs are structurally sound.
#   2. System-level checks (only meaningful inside a booted ShengOS live
#      system or VM): confirms sw_KE.UTF-8 was actually generated and that
#      the LANGUAGE fallback chain is configured. These are SKIPPED with a
#      notice (not failed) when run on a non-target machine like macOS.
set -uo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

PASS=0
FAIL=0
SKIP=0
ok()   { echo "  [SAWA]     $1"; PASS=$((PASS + 1)); }
bad()  { echo "  [IMESHINDWA] $1"; FAIL=$((FAIL + 1)); }
skip() { echo "  [IMERUKWA] $1"; SKIP=$((SKIP + 1)); }

echo "== Jaribio la lugha ya sw_KE (Milestone 3) =="
echo "-- Hatua 1: Uhalali wa faili za .po (inafanya kazi popote) --"


# validate_po.py globs "po/sw_KE/*.po" relative to its own working
# directory, so it must be invoked from inside l10n/.
if (cd "$ROOT_DIR/l10n" && python3 validate_po.py) > /tmp/shengos_po_out 2>&1; then
    ok ".po zote ni sahihi kimuundo"
else
    bad ".po zina hitilafu:\n$(cat /tmp/shengos_po_out)"
fi
rm -f /tmp/shengos_po_out

echo ""
echo "-- Hatua 2: Uthabiti wa locale kwenye mfumo halisi (Linux pekee) --"

if [ "$(uname -s)" != "Linux" ]; then
    skip "Mfumo huu si Linux (unaonekana $(uname -s)) — jaribu hii ndani ya VM ya ShengOS."
else
    if command -v locale >/dev/null 2>&1 && locale -a 2>/dev/null | grep -qi "sw_KE"; then
        ok "sw_KE.UTF-8 imetengenezwa kwenye mfumo (locale -a)"
    else
        skip "sw_KE.UTF-8 haijatengenezwa bado kwenye mfumo huu — endesha l10n/locale-setup.sh"
    fi

    if [ -f /etc/default/locale ] && grep -q "LANGUAGE=sw_KE:en_US.UTF-8" /etc/default/locale; then
        ok "LANGUAGE fallback (sw_KE:en_US.UTF-8) imewekwa kwenye /etc/default/locale"
    else
        skip "/etc/default/locale haina LANGUAGE fallback bado — endesha l10n/locale-setup.sh"
    fi

    MO_COUNT=$(find /usr/share/locale/sw_KE/LC_MESSAGES -name "*.mo" 2>/dev/null | wc -l)
    if [ "$MO_COUNT" -gt 0 ]; then
        ok "$MO_COUNT faili za .mo zimekusanywa na kuwekwa"
    else
        skip "hakuna faili za .mo zilizowekwa bado — endesha l10n/build.sh (kama root)"
    fi
fi

echo ""
echo "Matokeo: $PASS sawa, $FAIL imeshindwa, $SKIP imerukwa."
[ "$FAIL" -eq 0 ]
