# Ghillie: plan and rules

Ghillie is CAMO's wallet. **Ghillie desktop v0.9** is a fork of Monero's desktop wallet (monero-gui, tag
`v0.18.5.4`, full upstream history kept for BSD-3 attribution), rebranded and restyled for CAMO. It ships for
mainnet launch on Dec 15, 2026 (Mac, Windows, Linux). Mobile and the remote-mining features come in 2027.

Owner: Anthony (GitHub thedifference7717-sys). CAMO node repo: `thedifference7717-sys/camo`.
Design reference: Ghillie mockups https://claude.ai/artifact/RfFeusuAaxrHQnLayoFgVM

## Ground rules
- **Never change wallet cryptography or transaction logic.** All of it lives in libwallet, which comes from the CAMO
  repo (the `monero` submodule points at `thedifference7717-sys/camo`). Ghillie changes names, look, defaults and
  removes Monero-specific services. Nothing else.
- Keep Monero copyright headers and `LICENSE` (BSD-3). Add CAMO lines; never remove Monero's.
- **No fee on sends, ever** (an extra output would fingerprint Ghillie transactions). Show "Ghillie fee: 0 · never".
- **No fiat prices** and no third-party network calls by default (decided Nov 4): remove the Kraken/CoinGecko price
  fetch and the getmonero.org update checker.
- Look (decided Nov 4): retro but very readable. VT323 pixel font for headings, labels, big numbers, addresses and
  pixel buttons; Inter for body text; notched 4 px corners; dark pixel-camo texture on key cards; website colors.
  The Ghillie logo stays smooth (`camo/website/assets/ghillie-icon-512.png`), never pixelated.

## Work plan
1. **Plumbing**: `monero` submodule -> CAMO repo (pinned commit); app name, bundle id, binary name `ghillie`;
   builds on Linux in CI.
2. **CAMO network**: ticker XMR -> CAMO; `camo:` URIs only (`monero:` rejected, like the CLI wallet); address hints
   (mainnet `C...`, stagenet `Q...`); default ports 19741/39741; remove Monero remote-node lists and bootstrap nodes
   (add CAMO's when there are public ones); wizard text pointing to getmonero.org -> camocoin.org.
3. **Remove outside calls**: fiat price providers, updater (getmonero.org hashes), any other default network calls.
4. **Ghillie look**: fonts (VT323 + Inter, bundled, OFL), colors, notched corners, camo cards, logo/icons, Send page
   "Ghillie fee: 0 · never".
5. **Release**: GitHub Actions builds for Mac/Windows/Linux; later reproducible builds and signing with the CAMO
   release key (`5F1A 8350 C748 BC43 AD19  2472 AF13 7B28 E11A 0857`).

## Status
- Nov 11, 2026: repo created; upstream monero-gui `v0.18.5.4` history pushed to `main`. Nothing changed yet.
