#!/usr/bin/env python3
"""
validate_po.py — lightweight structural sanity check for .po files.

Not a substitute for `msgfmt -c`, but catches the most common mistakes
(unterminated strings, msgid without msgstr, missing header, duplicate
msgids) without requiring the gettext toolchain to be installed.
Milestone 3: Core Desktop Environment Localization.
"""
import glob
import re
import sys


def validate(path):
    errors = []
    with open(path, encoding="utf-8") as f:
        content = f.read()

    # Header must be present (empty msgid "" block with Content-Type etc.)
    if 'msgid ""' not in content:
        errors.append("Missing empty msgid header block")
    if "Content-Type: text/plain; charset=UTF-8" not in content:
        errors.append("Header missing/incorrect Content-Type (must be UTF-8)")
    if 'Language: sw_KE' not in content:
        errors.append("Header missing 'Language: sw_KE'")

    # Every quoted string must have matching quotes on each line.
    for i, line in enumerate(content.splitlines(), 1):
        stripped = line.strip()
        if stripped.startswith('"') or 'msgid "' in stripped or 'msgstr "' in stripped:
            quote_count = stripped.count('"')
            if quote_count % 2 != 0:
                errors.append(f"Line {i}: unbalanced quotes -> {stripped!r}")

    # Collect msgid entries (ignore plural msgid_plural, msgstr[N]) and check
    # each msgid is followed eventually by a msgstr before the next msgid.
    msgids = re.findall(r'^msgid "(.*)"$', content, re.MULTILINE)
    msgstrs = re.findall(r'^msgstr(\[\d+\])? "(.*)"$', content, re.MULTILINE)

    if len(msgids) == 0:
        errors.append("No msgid entries found")

    seen = set()
    dupes = set()
    for m in msgids:
        if m == "":
            continue
        if m in seen:
            dupes.add(m)
        seen.add(m)
    if dupes:
        errors.append(f"Duplicate msgid(s): {sorted(dupes)}")

    # crude msgid/msgstr count check (allowing for plural msgstr[0]/[1] pairs)
    if len(msgstrs) < len(msgids):
        errors.append(
            f"Fewer msgstr entries ({len(msgstrs)}) than msgid entries ({len(msgids)})"
        )

    return errors


def main():
    files = sorted(glob.glob("po/sw_KE/*.po"))
    if not files:
        print("Hakuna faili za .po zilizopatikana kwenye po/sw_KE/")
        return 1

    total_errors = 0
    for path in files:
        errors = validate(path)
        if errors:
            total_errors += len(errors)
            print(f"[HITILAFU] {path}")
            for e in errors:
                print(f"    - {e}")
        else:
            msgid_count = len(re.findall(r'^msgid "', open(path, encoding="utf-8").read(), re.MULTILINE)) - 1
            print(f"[SAWA] {path}  ({msgid_count} tafsiri)")

    print()
    if total_errors:
        print(f"Jumla ya hitilafu: {total_errors}")
        return 1
    print("Faili zote za .po ni sahihi kimuundo (basic structural check).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
