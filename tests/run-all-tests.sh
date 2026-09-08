#!/usr/bin/env bash
# run-all-tests.sh — run the full ShengOS test suite
# Milestone 6: Documentation, Testing & Installation Guide
set -uo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OVERALL=0

echo "############################################"
echo "#   ShengOS — Jaribio Kamili la Mfumo       #"
echo "############################################"
echo ""

for test_script in test-aliases.sh test-vuta.sh test-locale.sh; do
    echo "--------------------------------------------"
    bash "$ROOT_DIR/$test_script"
    status=$?
    echo "--------------------------------------------"
    echo ""
    if [ "$status" -ne 0 ]; then
        OVERALL=1
    fi
done

if [ "$OVERALL" -eq 0 ]; then
    echo "MATOKEO YA JUMLA: Majaribio yote ya lazima yamefaulu."
else
    echo "MATOKEO YA JUMLA: Baadhi ya majaribio yameshindwa. Angalia juu."
fi

exit $OVERALL
