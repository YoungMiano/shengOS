#!/usr/bin/env python3
"""
vuta — ShengOS native package manager wrapper (Milestone 2)

Wraps apt/apt-get so that installing, removing, updating and searching
for software on ShengOS happens in Sheng/Swahili, with native
Swahili-language feedback (not translated after the fact).

Usage:
    vuta <pkg> [<pkg> ...]        sakinisha <pkg>   -> apt install
    toa <pkg> [<pkg> ...]         ondoa <pkg>        -> apt remove
    update | upya                                    -> apt update && apt upgrade
    tafuta <neno>                                     -> apt search
    orodha                                            -> apt list --installed
    usaidizi | -h | --help                            -> show help

This single script is installed under multiple command names via
symlinks (see install.sh), and it dispatches behaviour based on
os.path.basename(sys.argv[0]) OR an explicit first argument, so it
works whether invoked as `vuta firefox` or `sakinisha firefox`.
"""

import os
import subprocess
import sys

# ---- colour helpers --------------------------------------------------
RED = "\033[1;31m"
GREEN = "\033[1;32m"
YELLOW = "\033[1;33m"
CYAN = "\033[1;36m"
RESET = "\033[0m"


def red(msg):
    print(f"{RED}{msg}{RESET}")


def green(msg):
    print(f"{GREEN}{msg}{RESET}")


def yellow(msg):
    print(f"{YELLOW}{msg}{RESET}")


def cyan(msg):
    print(f"{CYAN}{msg}{RESET}")


# ---- privilege check --------------------------------------------------
def hakikisha_mkuu():
    """Ensure we have root; re-exec under sudo with a Swahili prompt if not."""
    if os.geteuid() != 0:
        yellow("Hii amri inahitaji ruhusa ya msimamizi (mkuu). Tafadhali weka nenosiri lako:")
        os.execvp("sudo", ["sudo", sys.executable, os.path.abspath(__file__), *sys.argv[1:]])


# ---- core actions -------------------------------------------------------
def sakinisha(pakiti):
    """vuta / sakinisha <pkg> -> apt install"""
    if not pakiti:
        red("Tumia hivi: vuta <pakiti> [<pakiti> ...]")
        return 1
    hakikisha_mkuu()
    cyan(f"Inasakinisha: {', '.join(pakiti)} ...")
    result = subprocess.run(["apt-get", "install", "-y", *pakiti])
    if result.returncode == 0:
        green(f"Imefanikiwa! Pakiti zifuatazo zimesakinishwa: {', '.join(pakiti)}")
    else:
        red(f"Imeshindikana kusakinisha: {', '.join(pakiti)}. Angalia jina la pakiti au muunganisho wa mtandao.")
    return result.returncode


def ondoa(pakiti):
    """toa / ondoa <pkg> -> apt remove"""
    if not pakiti:
        red("Tumia hivi: toa <pakiti> [<pakiti> ...]")
        return 1
    hakikisha_mkuu()
    cyan(f"Inaondoa: {', '.join(pakiti)} ...")
    result = subprocess.run(["apt-get", "remove", "-y", *pakiti])
    if result.returncode == 0:
        green(f"Pakiti zifuatazo zimeondolewa: {', '.join(pakiti)}")
    else:
        red(f"Imeshindikana kuondoa: {', '.join(pakiti)}.")
    return result.returncode


def upya():
    """update / upya -> apt update && apt upgrade"""
    hakikisha_mkuu()
    cyan("Inasasisha orodha ya pakiti (update) ...")
    r1 = subprocess.run(["apt-get", "update"])
    if r1.returncode != 0:
        red("Imeshindikana kusasisha orodha ya pakiti.")
        return r1.returncode
    cyan("Inaboresha pakiti zilizosakinishwa (upgrade) ...")
    r2 = subprocess.run(["apt-get", "upgrade", "-y"])
    if r2.returncode == 0:
        green("Mfumo umesasishwa kikamilifu.")
    else:
        red("Imeshindikana kuboresha baadhi ya pakiti.")
    return r2.returncode


def tafuta_pakiti(neno):
    """tafuta <term> -> apt search"""
    if not neno:
        red("Tumia hivi: tafuta <neno>")
        return 1
    cyan(f"Inatafuta pakiti zenye: '{' '.join(neno)}' ...")
    result = subprocess.run(["apt-cache", "search", *neno])
    if result.returncode != 0:
        red("Utafutaji umeshindikana.")
    return result.returncode


def orodha_pakiti():
    """orodha -> apt list --installed"""
    result = subprocess.run(["apt", "list", "--installed"])
    return result.returncode


def usaidizi():
    cyan("== Amri za vuta (msimamizi wa pakiti wa ShengOS) ==")
    print(f"""
  {GREEN}vuta{RESET} / {GREEN}sakinisha{RESET} <pakiti>   Sakinisha pakiti mpya      (apt install)
  {GREEN}toa{RESET} / {GREEN}ondoa{RESET} <pakiti>        Ondoa pakiti                (apt remove)
  {GREEN}update{RESET} / {GREEN}upya{RESET}                Sasisha na boresha mfumo    (apt update && upgrade)
  {GREEN}tafuta{RESET} <neno>              Tafuta pakiti                (apt search)
  {GREEN}orodha{RESET}                     Onyesha pakiti zilizosakinishwa (apt list --installed)
  {GREEN}usaidizi{RESET} / -h / --help     Onyesha ujumbe huu
""")
    return 0


# ---- dispatch -------------------------------------------------------------
def main():
    invoked_as = os.path.basename(sys.argv[0])
    args = sys.argv[1:]

    # Determine the intended action. If invoked via a dedicated symlink
    # (vuta, sakinisha, toa, ondoa, upya, tafuta, orodha, usaidizi) use that.
    # Otherwise, fall back to reading the action from the first argument
    # so `python3 vuta.py sakinisha firefox` also works during development.
    known = {"vuta", "sakinisha", "toa", "ondoa", "update", "upya",
             "tafuta", "orodha", "usaidizi"}

    action = invoked_as if invoked_as in known else None
    if action is None and args and args[0] in known:
        action = args[0]
        args = args[1:]

    if action in (None, "-h", "--help") and not args:
        return usaidizi()

    if action in ("vuta", "sakinisha"):
        return sakinisha(args)
    if action in ("toa", "ondoa"):
        return ondoa(args)
    if action in ("update", "upya"):
        return upya()
    if action == "tafuta":
        return tafuta_pakiti(args)
    if action == "orodha":
        return orodha_pakiti()
    if action == "usaidizi" or "-h" in args or "--help" in args:
        return usaidizi()

    red(f"Amri haijulikani: '{invoked_as} {' '.join(sys.argv[1:])}'. Andika 'usaidizi' kuona amri zote.")
    return 1


if __name__ == "__main__":
    sys.exit(main())
