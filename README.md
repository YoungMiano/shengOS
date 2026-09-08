# ShengOS

**A native Swahili & Sheng Linux distribution.**
**Mfumo wa uendeshaji wa Linux wenye asili ya Kiswahili na Sheng.**

ShengOS is not English Linux with a locale flag flipped on. It's an attempt to make
the command line, the package manager, and the desktop feel natively Swahili/Sheng
from the ground up — native command verbs, native error messages, native desktop
strings, native branding.

ShengOS si Linux ya Kiingereza yenye lugha ya Kiswahili imewekwa juu tu. Ni jaribio
la kufanya terminali, msimamizi wa pakiti, na dawati vionekane kwa asili ya
Kiswahili/Sheng tangu mwanzo — vitenzi vya amri vya asili, ujumbe wa hitilafu wa
asili, maandishi ya dawati ya asili, na chapa ya asili.

---

## Hali ya Mradi / Project Status

| # | Milestone | Hali |
|---|-----------|------|
| 1 | CLI & Native Command Mapping Engine (`sheng-sh`) | ✅ Kamili |
| 2 | Native Package Manager (`vuta`) | ✅ Kamili |
| 3 | Desktop Localization (`gettext` / `.po`/`.mo`) | ✅ Kamili |
| 4 | OS Customization & Branding | ✅ Kamili |
| 5 | Live-Build ISO Pipeline | ✅ Kamili |
| 6 | Documentation, Testing & Installation Guide | ✅ Kamili |

Install-to-disk (e.g. via calamares) is **not** yet implemented — this produces a
**live-boot ISO only**. That would be a natural next milestone beyond the original
scope of this project.

---

## Muundo wa Hazina / Repository Structure

```
shengos/
├── shell/          Milestone 1 — sheng-sh: native command aliases & functions
│   ├── commands.json      canonical Sheng/Swahili ↔ GNU coreutils dictionary
│   ├── helpers.sh          wrapped functions with native Swahili error handling
│   ├── .shengrc             environment file (aliases, prompt, banner)
│   └── install.sh          per-user installer
│
├── pkg/            Milestone 2 — vuta: native apt wrapper
│   ├── vuta.py             the CLI tool (vuta/sakinisha/toa/ondoa/update/tafuta/...)
│   └── install.sh          installs vuta + symlinks system-wide
│
├── l10n/           Milestone 3 — gettext desktop localization
│   ├── po/sw_KE/*.po       translation catalogs (appfinder, Thunar, settings, terminal)
│   ├── build.sh             compiles .po → .mo and installs them
│   ├── locale-setup.sh      generates sw_KE.UTF-8 with English fallback
│   └── validate_po.py       structural .po linter
│
├── branding/       Milestone 4 — themes, wallpaper, GRUB, LightDM
│   ├── wallpapers/shengos-default.svg
│   ├── set-theme.sh         per-user XFCE theme/wallpaper application
│   ├── branding-install.sh  system-wide branding installer
│   ├── grub-branding.sh     GRUB distributor name & background
│   ├── lightdm-branding.sh  login screen branding
│   └── desktop-shortcuts/*.desktop
│
├── iso/            Milestone 5 — live-build ISO pipeline
│   ├── build.sh              stages Milestones 1-4 and runs `lb build`
│   └── config/               live-build config (hooks, package lists, includes.chroot)
│
└── tests/          Milestone 6 — automated test suite
    ├── run-all-tests.sh
    ├── test-aliases.sh
    ├── test-vuta.sh
    └── test-locale.sh
```

---

## Kujenga Kutoka Chanzo / Building From Source

**Muhimu / Important:** `live-build` only runs on Debian/Ubuntu. You cannot build
the ISO directly on macOS or Windows — you need a Linux machine or VM. Since you're
on an Intel-based Mac, standard x86_64 virtualization works with no translation
layer needed.

### 1. Andaa VM ya Debian/Ubuntu (kwenye Mac yako) / Set up a build VM

1. Install [VirtualBox](https://www.virtualbox.org/) (free) or [UTM](https://mac.getutm.app/) (free, QEMU-based).
2. Download a **Debian 12 (bookworm) netinst ISO**: https://www.debian.org/distrib/netinst
3. Create a new VM: 4GB+ RAM, 25GB+ disk, attach the netinst ISO, boot and install
   Debian normally (a minimal install is fine — you don't need a desktop environment
   in the *build* VM, only in the resulting ShengOS ISO).
4. Once installed, boot into your new Debian VM and open a terminal.

### 2. Sakinisha zana za ujenzi / Install build tools

Inside the Debian VM:
```bash
sudo apt-get update
sudo apt-get install -y live-build git gettext librsvg2-bin
```

### 3. Pata msimbo / Clone the repo

```bash
git clone https://github.com/YoungMiano/shengOS.git
cd shengOS
```

### 4. Endesha majaribio kwanza / Run the test suite first

```bash
bash tests/run-all-tests.sh
```
This validates the `.po` catalogs and the shell/vuta logic before you spend 30-60
minutes building an ISO from something broken.

### 5. Jenga ISO / Build the ISO

```bash
cd iso
sudo ./build.sh
```
This takes anywhere from 20 minutes to over an hour depending on your VM's
resources and network speed (it downloads every package fresh). When it finishes,
you'll find `shengos-*.iso` inside `iso/build/`.

---

## Kujaribu ISO / Testing the Built ISO

Once you have a `.iso` file, test it **before** writing it to a USB drive:

1. Copy the `.iso` out of your build VM to your Mac (shared folder, `scp`, etc.)
2. Create a **second, separate** VM in VirtualBox/UTM — this one boots the ShengOS
   ISO itself (don't test inside your build VM).
3. Attach the ShengOS `.iso` as the boot media, allocate 2GB+ RAM, boot it.
4. Verify:
   - The desktop boots to LightDM with the ShengOS wallpaper and greeting.
   - Opening a terminal and running `usaidizi` shows the sheng-sh command list.
   - `cheki`, `unda`, `dema`, `vuka` behave as expected.
   - `vuta neofetch` (or any small package) installs correctly.
   - Menus, Thunar, and Settings show Swahili strings where translated.

If something's broken, `tests/run-all-tests.sh` inside the booted live session is
the fastest way to narrow down which milestone regressed.

---

## Majaribio / Test Suite

```bash
bash tests/run-all-tests.sh        # everything
bash tests/test-aliases.sh         # Milestone 1 only
bash tests/test-vuta.sh            # Milestone 2 only
bash tests/test-locale.sh          # Milestone 3 only
```

`test-locale.sh` has two tiers: `.po` structural validation runs anywhere
(including on your Mac); actual locale-generation checks only run on Linux and are
**skipped** (not failed) elsewhere.

---

## Kuchangia / Contributing

1. Fork the repo, create a branch per milestone/feature (`git checkout -b milestone-7-installer`).
2. Follow the existing naming convention: every user-facing command gets both a
   Sheng verb and a more formal Swahili verb (see `shell/commands.json` for the
   established pattern) — don't add English-only commands.
3. Every wrapped command should give native Swahili feedback on success *and*
   failure — not just an aliased pass-through to the raw English tool output.
4. Run `bash tests/run-all-tests.sh` before opening a PR. Add a test alongside any
   new command or catalog.
5. Open a PR describing which milestone/component it touches.

---

## Leseni / License

See `LICENSE`.
