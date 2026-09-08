#!/usr/bin/env bash
# test-vuta.sh — verify Milestone 2 vuta dispatch logic (no real apt calls)
# Milestone 6: Documentation, Testing & Installation Guide
set -uo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VUTA="$ROOT_DIR/pkg/vuta.py"

PASS=0
FAIL=0
ok()  { echo "  [SAWA]     $1"; PASS=$((PASS + 1)); }
bad() { echo "  [IMESHINDWA] $1"; FAIL=$((FAIL + 1)); }

echo "== Jaribio la vuta (Milestone 2) =="

if [ ! -f "$VUTA" ]; then
    bad "pkg/vuta.py haipatikani kwenye $VUTA"
    exit 1
fi

python3 -m py_compile "$VUTA" 2>/tmp/shengos_vuta_err
if [ $? -eq 0 ]; then
    ok "vuta.py inakusanywa bila hitilafu za kisintaksia"
else
    bad "vuta.py ina hitilafu za kisintaksia: $(cat /tmp/shengos_vuta_err)"
fi

# usaidizi with no args should exit 0 and mention every known command
OUT="$(python3 "$VUTA" usaidizi 2>&1)"
if echo "$OUT" | grep -q "sakinisha" && echo "$OUT" | grep -q "tafuta"; then
    ok "usaidizi: inaonyesha amri zote"
else
    bad "usaidizi: haikuonyesha amri zote"
fi

# vuta with no package should fail with exit code 1 and a Swahili message
OUT="$(python3 "$VUTA" vuta 2>&1)"; CODE=$?
if [ "$CODE" -eq 1 ] && echo "$OUT" | grep -q "Tumia hivi"; then
    ok "vuta (bila pakiti): inakataa kwa usahihi"
else
    bad "vuta (bila pakiti): tabia si sahihi (exit=$CODE)"
fi

# unknown command should fail with exit code 1
OUT="$(python3 "$VUTA" haijulikani 2>&1)"; CODE=$?
if [ "$CODE" -eq 1 ] && echo "$OUT" | grep -q "haijulikani"; then
    ok "amri isiyojulikana: inakataliwa kwa usahihi"
else
    bad "amri isiyojulikana: tabia si sahihi (exit=$CODE)"
fi

rm -f /tmp/shengos_vuta_err

echo ""
echo "Matokeo: $PASS sawa, $FAIL imeshindwa."
[ "$FAIL" -eq 0 ]
