# Ghillie mobile

Ghillie for iPhone, iPad and Android: the [CAMO](https://camocoin.org) wallet. Status: **groundwork** (Nov 2026).
Planned release: Q1 2027, after CAMO mainnet (Dec 15, 2026). Desktop Ghillie lives in
[thedifference7717-sys/ghillie](https://github.com/thedifference7717-sys/ghillie).

## Rules (same as desktop Ghillie)
- **No new cryptography.** Keys, addresses, decoy selection, signing and transaction building all happen in CAMO's
  wallet library (`src/wallet/api` in the camo repository, from Monero, unchanged). This app is screens plus a thin
  C bridge (`native/camo_wallet_ffi.*`).
- **No fee on sends, ever** ("Ghillie fee: 0 · never"): an extra output would make Ghillie transactions stand out.
- **No third-party calls**: no analytics, no price lookups, no update checks. It talks only to the CAMO node you pick.
- **Phones never mine.** Remote control of mining on your own computers comes later (2027).
- Look: the approved mockups (night-ops palette, VT323 pixel headings and balance, Inter body text, notched corners,
  pixel-camo card; the Ghillie logo stays smooth).

## What works now
- Opening screen: the camocoin.org scope (living pixel-camo field, hidden CAMO, drag to aim, tap to enter; Skip;
  still when the phone asks for reduced motion).
- Screens: wallet home, send (with review), receive (QR, `camo:` links, a fresh address per payer), rigs (preview),
  settings. They run on **demo data** (`lib/wallet/demo_wallet.dart`) and show a DEMO badge.
- `camo:` payment links (build/parse; `monero:` refused), CAMO amounts (exact, 12 decimals, BigInt), address shape
  hints per network (C mainnet, Q stagenet, K/L testnet; Monero addresses get a clear message).
- 11 tests (`flutter test`), CI builds a demo Android APK and an unsigned iOS app.

## Plan
1. **Wallet bridge** (`native/`): C functions over `wallet2_api.h` (create/restore/open, subaddresses, sync,
   balance, history, prepare/commit send). Compiles against the camo headers (CI job `native-bridge`).
2. **Linux dev build with the real library**: link the bridge against a camo build and run the app against a
   private regtest chain (same tests as desktop Ghillie: create, restore from seed, send, receive exactly).
3. **Android**: build camo's wallet library with `contrib/depends` (Android NDK hosts are supported), package
   `libcamo_wallet.so` per ABI (arm64-v8a, x86_64) via the Flutter FFI plugin template.
4. **iOS**: build the library for `arm64-apple-ios` on a macOS CI runner (camo's CMake has an iOS mode; its
   dependencies need iOS builds), ship as an xcframework. Hardest step, so it starts early.
5. **Node**: a phone can't hold the chain, so it uses a remote node in untrusted mode. Needs a public,
   rate-limited `--restricted-rpc` CAMO node (decision pending: the free Google seed has only 1 GB/month egress).
6. **Security before release**: wallet files encrypted by the library with the user's password; optional
   Face ID / fingerprint unlock via iOS Keychain / Android Keystore; screenshot blocking on seed screens;
   seed shown once, with the printed recovery sheet.
7. **Distribution**: test builds are free (Android APK; iOS via Xcode with a free Apple ID on the owner's device,
   7-day signing). Store releases need Apple's Developer Program ($99/yr) and Google Play ($25 once): owner's call.

## Develop
```
flutter pub get
flutter test
flutter run -d linux        # phone-sized window
```
