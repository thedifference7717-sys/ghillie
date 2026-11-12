# Ghillie Windows Installer #

Copyright (c) 2026, The CAMO Project. Based on the Monero GUI wallet installer,
Copyright (c) 2017-2024, The Monero Project.

## Introduction ##

`Ghillie.iss` is an *Inno Setup* script that builds a standard Windows installer (.exe)
for Ghillie, the CAMO wallet. It installs Ghillie (`ghillie.exe`) and the CAMO node
(`camod.exe`) into `C:\Program Files\Ghillie`, adds Start menu icons, registers the
`camo:` and `camoseed:` link types, and supports uninstall.

## Building ##

1. Put the release files in a `bin` folder next to `Ghillie.iss`: `ghillie.exe`,
   `camod.exe`, `start-low-graphics-mode.bat`, `opengl32sw.dll`.
2. Open `Ghillie.iss` in Inno Setup 6 and compile.

See `Deterministic.md` for reproducible builds.

## License ##

See [LICENSE](LICENSE).
