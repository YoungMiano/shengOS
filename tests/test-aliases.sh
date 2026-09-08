#!/usr/bin/env bash
# test-aliases.sh — verify Milestone 1 command aliases execute correctly
# Milestone 6: Documentation, Testing & Installation Guide
#
# Run from the repo root: bash tests/test-aliases.sh
set -uo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HELPERS="$ROOT_DIR/shell/helpers.sh"

PASS=0
FAIL=0

ok()   { echo "  [SAWA]     $1"; PASS=$((PASS + 1)); }
bad()  { echo "  [IMESHINDWA] $1"; FAIL=$((FAIL + 1)); }

echo "== Jaribio la amri za sheng-sh (Milestone 1) =="

if [ ! -f "$HELPERS" ]; then
    bad "shell/helpers.sh haipatikani kwenye $HELPERS"
    exit 1
fi
source "$HELPERS"

# 1. Functions must exist after sourcing helpers.sh
for fn in vuka sogea unda tengeneza dema futa boss mkuu safi safisha soma cheki orodha tafuta usaidizi; do
    if declare -F "$fn" >/dev/null 2>&1; then
        ok "kazi '$fn' ipo"
    else
        bad "kazi '$fn' haipo"
    fi
done

# 2. Functional round-trip: unda -> cheki -> dema
TMP_BASE="$(mktemp -d)"
TARGET="$TMP_BASE/jaribio_shengos_test"

unda "$TARGET" >/tmp/shengos_test_out 2>&1
if [ -d "$TARGET" ]; then
    ok "unda: saraka imeundwa kwa ukweli"
else
    bad "unda: saraka haikuundwa"
fi

if cheki "$TMP_BASE" 2>/dev/null | grep -q "jaribio_shengos_test"; then
    ok "cheki: inaonyesha saraka iliyoundwa"
else
    bad "cheki: haikuonyesha saraka iliyoundwa"
fi

dema "$TARGET" >/tmp/shengos_test_out 2>&1
if [ ! -d "$TARGET" ]; then
    ok "dema: saraka imefutwa kwa ukweli"
else
    bad "dema: saraka haikufutwa"
fi

# 3. Native Swahili error message on a missing file (not a raw English one)
#    (helpers.sh prints via `printf` to STDOUT, so capture both streams)
soma "$TMP_BASE/haipo_kabisa_xyz" >/tmp/shengos_test_out 2>&1
if grep -q "Hitilafu" /tmp/shengos_test_out; then
    ok "soma: ujumbe wa hitilafu uko kwa Kiswahili"
else
    bad "soma: ujumbe wa hitilafu haukuonekana kwa Kiswahili"
fi

# 4. vuka refuses a nonexistent directory with a Swahili message, doesn't crash the shell
vuka "$TMP_BASE/saraka_hii_haipo" >/tmp/shengos_test_out 2>&1
if grep -q "Hitilafu" /tmp/shengos_test_out; then
    ok "vuka: inakataa saraka isiyokuwepo kwa usahihi"
else
    bad "vuka: haikutoa ujumbe sahihi kwa saraka isiyokuwepo"
fi

rm -rf "$TMP_BASE" /tmp/shengos_test_out

echo ""
echo "Matokeo: $PASS sawa, $FAIL imeshindwa."
[ "$FAIL" -eq 0 ]
