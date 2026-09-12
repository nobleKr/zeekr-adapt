# zeekr-adapt

Runtime framework that adapts regular Android apps for automotive DHU (head unit) displays with non-standard DPI. No root, no Xposed — applied per-app by patching the APK.

## Problem

Zeekr DHU (and similar) have high-res screens (2560×1600) reporting low density (MDPI 160dpi). Regular phone apps render microscopic UI — unusable while driving. On top of that, apps misbehave on the DHU: root/emulator detection blocks them, network shows "offline" (internet arrives via Ethernet/TBOX without Android validation), car-aware apps take an automotive onboarding path that lays out into 0×0 fragment containers on the multi-display compositor (blank/white screen), and media apps don't talk to the car (no steering-wheel control / cover art).

## Solution

`zeekr-adapt` injects into any APK via `AppComponentFactory` and uses [Pine](https://github.com/nicholascw/pine) inline hooks applied before `Application.onCreate`. Each patched APK is self-contained; its config is baked in at patch time.

**No root. No Xposed. No system modifications.**

### Two-DPI density (rendering vs layout)

Unlike a naive ×2 density (which breaks layouts on wide screens), zeekr-adapt splits density:

- **metricsDpi** (default **280**) → `Resources.getDisplayMetrics` / `Display.getMetrics` / `getRealMetrics` (afterCall) — drives **rendering** size (large, readable UI).
- **configDpi** (default **240**) → `Resources.getConfiguration` (afterCall) — drives **layout** width (more `dp` so elements still fit).

Pure `afterCall` mutation — the config callback touches only `densityDpi`, never `screenWidthDp`/`smallestScreenWidthDp`, and there is no `updateConfiguration` / global Resources rewrite.

> **End-user guide:** to go from a Play Store app to a patched DHU APK (get a
> token → download with apkeep → merge → patch → install), see
> **[USAGE.md](USAGE.md)**. The section below is for building `zeekr-adapt` itself.

## Quick Start

### Prerequisites

**You need exactly three things installed** — everything else the scripts fetch
or generate for you:

1. **Java 21, HotSpot** (Eclipse Temurin / Oracle / Zulu) — for `javac`, `d8`,
   `keytool`. **Must NOT be IBM Semeru / OpenJ9** — `d8` crashes on it
   (`ScavengerRootScanner` assertion / "Misaligned object" core dump); `build.sh`
   detects this and stops with a clear message. Check with `java -version`.
2. **Python 3** (3.8+) — for the binary-manifest patcher and config generation.
3. **Android SDK** — **build-tools `36.1.0`** + **platform `android-34`**. These
   provide `d8`, `zipalign`, `apksigner`, `aapt2` and `android.jar`. Install via:
   ```bash
   sdkmanager "build-tools;36.1.0" "platforms;android-34"
   ```

**How the Android SDK is located:** the scripts use `$ANDROID_HOME` (then
`$ANDROID_SDK_ROOT`); if neither is set they probe common locations —
`~/Library/Android/sdk` (macOS), `~/Android/Sdk` (Linux),
`~/android-sdk`, `/usr/lib/android-sdk`. If your SDK is elsewhere, export it:
```bash
export ANDROID_HOME=/path/to/Android/sdk
```
A missing build-tools/platform yields an actionable error (with the exact
`sdkmanager` line), not a cryptic failure.

**Auto-provided (do NOT install):**
- **baksmali/smali** — `build.sh` downloads the standalone fat jars from
  [baksmali/smali](https://github.com/baksmali/smali/releases) into `libs/` (once,
  cached) if they aren't already on `PATH`.
- **Pine** — `libs/pine.jar` is decoded from the vendored `vendor/pine.jar.base64`.
- **Signing key** — a branded `keystore/dhuadapter.keystore` is generated on first
  patch and reused.
- `curl`, `unzip`, `zip`, `git` are used too, but ship with macOS/Linux.

#### Installing the tools

**baksmali/smali — auto-downloaded, nothing to install.** `build.sh` looks for
`baksmali`/`smali` on `PATH`; if absent, it downloads the standalone
fat-release jars from [baksmali/smali](https://github.com/baksmali/smali/releases)
into `libs/` (once, then cached) and runs them via `java -jar`. So you normally
do **not** need to install them by hand. (dex2jar's `d2j-baksmali` is a different
CLI and is not used.)

If you'd rather provide your own — e.g. an offline build — just put `baksmali`
and `smali` executables on `PATH` (build.sh will use those instead) or drop the
jars at `libs/baksmali.jar` / `libs/smali.jar`.

**Java 21 + Android SDK:**

```bash
# macOS
brew install --cask temurin@21                  # Java 21 (HotSpot — NOT OpenJ9)
brew install --cask android-commandlinetools
sdkmanager "build-tools;36.1.0" "platforms;android-34"

# Linux (Debian/Ubuntu)
sudo apt install python3
#   Java 21: Adoptium apt repo, or SDKMAN:  sdk install java 21-tem
#   Android SDK: unzip Google's cmdline-tools, then the same sdkmanager line as above
```

Point the build at your SDK/tools before running:
```bash
export JAVA_HOME=/path/to/temurin-21
export ANDROID_HOME=$HOME/Library/Android/sdk        # or ~/Android/Sdk on Linux
export PATH="$JAVA_HOME/bin:$ANDROID_HOME/build-tools/36.1.0:$ANDROID_HOME/platform-tools:$PATH"
```

### 1. Build

```bash
export JAVA_HOME=/path/to/temurin-21
./build.sh
```

### 2. Patch

Config is **baked into the APK** at patch time (`assets/dhu-adapter-config.json`).
Hooks are grouped into **8 feature categories**, each gated by an explicit flag.
**Only Category 1 (Display/UI) is ON by default** — every other category is opt-in.

```bash
# Defaults only: Display/UI (density 280/240, landscape, fullscreen, back button)
./patch_apk.sh MyApp.apk

# Music/media app with MediaCenter + a signature-sensitive server
./patch_apk.sh music-app.apk out.apk --media-bridge --copy-sign

# Navigation / car-aware app: full automotive de-mask
./patch_apk.sh nav-app.apk out.apk --automotive-fix
```

> ⚠️ **Breaking change (8-category refactor):** root-bypass and the automotive
> fix used to be **always-on**. They are now **opt-in flags**. A build that used
> to "just work" now needs them explicitly — e.g. a car-aware app needs
> `--automotive-fix`, an app that root-detects needs `--root-bypass`.

#### Feature categories & flags

| # | Category | Flag | Default | What it does |
|---|----------|------|---------|--------------|
| 1 | **Display / UI** | on; `--no-display` to disable | **ON** | two-DPI density (280/240), landscape, fullscreen, rounded corners, draggable back button, zero inset padding, font override, WebView zoom + Chrome UA |
| 2 | **Root bypass** | `--root-bypass` | off | `Build.TAGS`→release-keys, `File.exists`, `Runtime.exec`, `ProcessBuilder`, `PackageManager` + root `SystemProperties` |
| 3 | **Emulator bypass** | `--emulator-bypass` | off | de-genericise `Build.*` + qemu/goldfish `SystemProperties` — **emulator only**, dead weight on a real DHU |
| 4 | **Automotive** | `--automotive-fix` | off | `isAutomotiveOS`→false (blank-screen fix) + block Android Auto overlay + `hasSystemFeature(automotive)`→false + `UiModeManager`→NORMAL + `Configuration.uiMode` de-car |
| 5a | **Network** | `--network-bypass` / `--no-network-bypass` | off | force "online": `hasCapability`/`hasTransport`/`isConnected` |
| 5b | **SIM-gate** | `--sim-ready` | off | `getSimState`→READY + `key_use_cellular_data`→true (some music apps' online-gate; **harmful to SIM-aware apps** e.g. phone-number registration) |
| 6 | **MediaCenter** | `--media-bridge` | off | direct-bind `ZeekrMediaCenterService` (wheel control, cover, metadata, reboot-resume) + `CoverProvider` + `<queries>` + `RecoveryReceiver`. Media apps only. |
| 7 | **Capture** | `--allow-capture` | off | strip `FLAG_SECURE` for screen capture/mirroring |
| 8 | **Diagnostics** | `--debug` | off | `Log.d` (`adb logcat -s DhuAdapter`) |
| 9 | **Signature spoof** | `--copy-sign` | off | preserve the stock APK's genuine signer cert (extracted from its v2/v3 block → `assets/orig-cert.der`) and feed it to the app's signature self-check. No hardcoded cert. |

Sub-flags of Category 1: `--no-orientation`, `--no-fullscreen`, `--metrics-dpi <n>`
(default 280), `--config-dpi <n>` (default 240). `--config <file>` uses an explicit
config.json instead of generating one.

#### Per-app flag sets (tested)

| App kind | Flags |
|----------|-------|
| Music app (SIM-gated online, MediaCenter) | `--root-bypass --emulator-bypass --network-bypass --sim-ready --media-bridge` |
| Music app (signature-sensitive server) | `--media-bridge --copy-sign` |
| Navigation / car-aware | `--automotive-fix` |
| Messaging | *(defaults only — Display)* |

Add `--debug` to any of the above for logs.

### 3. Install

Patched APKs are re-signed with a project-owned **DHUAdapter key**, generated once on first patch at `keystore/dhuadapter.keystore` (`CN=DHUAdapter, OU=https://github.com/nobleKr, O=nobleKr`, v2+v3) and reused for every subsequent build. What matters is a cryptographically **valid** signature — the cert identity itself is irrelevant to the apps (some refuse server-backed content under an *invalid* signature, none care about the DN). The keystore is gitignored (never committed). Uninstall the original first and disable Play Protect verification:

```bash
adb shell settings put global package_verifier_enable 0
adb uninstall <package>
adb install -r -d out.apk
```

### Signing — each user gets their own key

The signing keystore (`keystore/dhuadapter.keystore`) is **gitignored and never
committed** — a private signing key must not live in a public repo. So when you
clone this project and run `patch_apk.sh` for the first time, it **generates
your own** keystore: the same branded identity (`CN=DHUAdapter,
OU=https://github.com/nobleKr, O=nobleKr`) but a **different private key**, unique
to you. It is created once and reused for all your subsequent builds.

This is intentional and correct — what the apps care about is a cryptographically
**valid** signature, not *which* key produced it (proven with Spotify: the cert
identity is irrelevant, only validity matters). The visible identity (DN) is the
same for everyone; the private key is per-user.

**Practical consequence — `install -r`:** APKs signed by two *different* people
have different signer certs, so you **cannot** `adb install -r` (update-in-place)
over an APK someone else built — Android returns
`INSTALL_FAILED_UPDATE_INCOMPATIBLE`. Just uninstall first:

```bash
adb uninstall <package>
adb install -d out.apk
```

Within your own builds the key is stable (generate-once), so **your** updates
install over each other fine. There is deliberately no shared/common key —
publishing one would let anyone sign a mod "as DHUAdapter", which defeats the point.

## Getting APKs (universal merge pipeline)

Split APKs (XAPK) carry only one density + can miss native libs. Best quality comes from a **universal** APK:

```
apkeep (split_apk=true, locale ru_RU/uk_UA)   # base + arm64 native + xxhdpi + lang splits
   → APKEditor merge (m -i <dir> -o out.apk)  # → single universal APK
   → ./patch_apk.sh out.apk ...               # → zeekr-adapt patched
```

The merge is essential for apps with `extractNativeLibs=false` whose base has no native `.so` without the arm64 split (splash hang otherwise).

## The automotive-OS gate (blank/white screen fix)

Some car-aware apps (those built against the AndroidX **Car App Library**) choose their onboarding/UI flow from `androidx.car.app.utils.CommonUtils.isAutomotiveOS()`. On an automotive head unit it returns `true`, so the app runs its **automotive** onboarding path — whose fragments are added to a plain `FrameLayout` container that measures **0×0** inside the Zeekr MDS multi-window (`WrongFragmentContainerViolation`), producing a blank/white screen that never reaches the main UI. On an emulator (not automotive) it already returns `false`, so the UI renders — which is why the same APK looks fine there.

zeekr-adapt forces `isAutomotiveOS()` to `false` (resolved by name, signature-agnostic), so the app takes the ordinary phone onboarding flow that lays out correctly. Pure `androidx.car.app` API; a no-op when the class is absent.

## Hooks

Density/UI:
| Hook | Purpose |
|------|---------|
| `Resources.getDisplayMetrics`, `Display.getMetrics`/`getRealMetrics` | metricsDpi (rendering) |
| `Resources.getConfiguration` | configDpi (layout, `densityDpi` only) |
| `Activity.setRequestedOrientation` | block portrait lock (flag) |
| `View.onAttachedToWindow` | optional font override |
| `View.setPaddingRelative` | zero system inset padding |
| Fullscreen + rounded corners + draggable back button | via ActivityLifecycleCallbacks (flags) |
| `WebView.getSettings` / `getDefaultUserAgent` | text zoom + Chrome mobile UA (fixes web-rendered map flows) |

Compatibility / integration:
| Hook | Category | Purpose |
|------|----------|---------|
| `CommonUtils.isAutomotiveOS` + `hasSystemFeature(automotive)` + `UiModeManager.getCurrentModeType` + `Configuration.uiMode` de-car | 4 (`--automotive-fix`) | full automotive de-mask — the blank/white-screen fix + phone onboarding flow |
| `ContentResolver.query` | 4 (`--automotive-fix`) | block Android Auto detection overlay |
| `Build.TAGS`/`File.exists`/`Runtime.exec`/`ProcessBuilder`/`PackageManager` + root `SystemProperties` | 2 (`--root-bypass`) | root detection bypass |
| `Build.*` de-generic + qemu/goldfish `SystemProperties` | 3 (`--emulator-bypass`) | emulator detection bypass (emulator only) |
| `NetworkCapabilities.hasCapability`/`hasTransport` + `NetworkInfo.isConnected` | 5a (`--network-bypass`) | report connected |
| `TelephonyManager.getSimState` + `SharedPreferencesImpl.getBoolean` | 5b (`--sim-ready`) | SIM READY + allow-cellular for SIM-gated apps |
| `SurfaceView`/`SurfaceControl.setSecure` + `Window.add/setFlags` | 7 (`--allow-capture`) | strip `FLAG_SECURE` |
| `MediaSession.setActive` | 6 (`--media-bridge`) | direct-bind to `ZeekrMediaCenterService` |
| `SigningInfo.getApkContentsSigners`/`getSigningCertificateHistory` + `PackageManager.getPackageInfo(GET_SIGNATURES)` | 9 (`--copy-sign`) | feed the genuine cert to the app's signature self-check |

**Shared hooks:** framework methods needed by more than one category
(`Configuration.updateFrom`, `Activity.onConfigurationChanged`,
`Resources.getConfiguration`, `SystemProperties.get`) are routed through a single
`core.SharedHooks` dispatcher — each is hooked **exactly once** and every
category's contribution is composited in order, so no method is double-hooked.

## Media bridge (Zeekr MediaCenter)

With `--media-bridge`, the patched media app registers with the car's MediaCenter so the steering wheel controls playback and the cluster shows track/cover. Runs **in-process** inside the patched app — no standalone service, no privileged/signature permission, no `WRITE_SECURE_SETTINGS`.

**Direct-bind, raw Binder.** The MediaCenter SDK facade is *not* used: on the DHU it routes through `com.zeekr.coreservice`, which rejects a non-whitelisted app **server-side** (disconnect 305) before any client-side hook can fire. Instead the bridge binds **directly** to `ZeekrMediaCenterService` (exported without an `android:permission`, so the allowlist — a client-side SDK check — is bypassed) and speaks the two-layer Binder protocol directly. No Zeekr SDK classes are vendored or dexed; the bridge uses only string interface descriptors and numeric transaction codes reversed from the firmware.

- **Bind** — `ZeekrMediaCenterService` (action `ecarx.xsf.ZEEKR_MEDIA_CENTER_SERVICE`). Requires a `<queries><package android:name="com.zeekr.mediacenter"/></queries>` entry injected into the manifest (Android 11+ package visibility), which `patch_apk.sh` adds under `--media-bridge`.
- **Register** — layer-1 `IZeekrSupportService.asyncBinderCall(ZeekrPlatformMessage, cb)` (transact 3) with method `mediaCenterRegisterMusicNew`; the token arrives async via `ITokenCallBack`, and `IMediaCenterSvc` + client token follow. `requestPlay` (layer-2 code 6) claims focus.
- **Metadata / state** — `updateMusicPlaybackState` (code 7) hands the server a **live** `IMusicPlaybackInfo` binder; MediaCenter pulls getters on demand (`getTitle/getArtist/getAlbum/getDuration/getArtwork/getPlaybackStatus/getPlayingMediaListId/getUuid/...`), read from the app's own `MediaController`. Status never reports IDLE (maps to PAUSED) so the server doesn't drop the source.
- **Cover art** — `getArtwork()` returns a `Uri`. Prefer the app's http(s) art URI from `MediaMetadata` (MediaCenter fetches it itself); fall back to the injected `CoverProvider` `content://` URI for `Bitmap`-only apps.
- **Steering commands** — arrive on our `IZeekrMusicClient` stub (`onPlay/onPause/onNext/onPrevious/progressDrag`) → forwarded to `MediaController.getTransportControls()`.
- **Wake-from-sleep** — `getLaunchIntent`/`getPlayerIntent` return a `PendingIntent`; the server caches its inner Intent URI and cold-starts the app itself when a dead source is tapped.
- **Reboot resume** — `registerMusicRecoveryIntent` (type 1 → the server broadcasts with `FLAG_INCLUDE_STOPPED_PACKAGES` to our injected `RecoveryReceiver`, waking the killed process) + `setMusicRecoveryCallback` + `onResumePlaybackInfo`; last-state snapshot persisted to `SharedPreferences`.

Multiple media apps register as **separate sources** — MediaCenter keys them by `packageName`, so Apple Music and Spotify get distinct tokens.

> The full firmware-verified transaction map lives in the internal (gitignored) protocol notes, not here.

## Configuration (defaults)

```json
{
  "metricsDpi": 280,
  "configDpi": 240,
  "forceOrientation": true,
  "backButton": { "enabled": true, "sizeDp": 48, "alpha": 0.5 },
  "roundedCorners": { "enabled": true, "radiusDp": 16 },
  "fullscreen": true,
  "fontOverride": null,
  "userAgentOverride": "Mozilla/5.0 (Linux; Android 13; Pixel 5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36",
  "display": true,
  "rootBypass": false,
  "emulatorBypass": false,
  "automotiveFix": false,
  "networkBypass": false,
  "simReady": false,
  "mediaBridge": false,
  "allowCapture": false,
  "copySign": false,
  "debug": false
}
```

**Config is embedded-only.** Read from `assets/dhu-adapter-config.json` inside the APK (via the APK zip at `instantiateClassLoader`, since `getAssets()` isn't ready that early). No `/sdcard` / `/data/local/tmp` paths — those were global and leaked one app's flags onto every patched app. To change flags, re-patch.

## Patching process (direct dex injection, no apktool)

```
Input APK
  ├── patch_manifest.py: patch binary AXML appComponentFactory → com.dhuadapter.DhuAdapterFactory
  │      (string-pool append when the new name is longer)
  │   + inject <provider> for CoverProvider when --media-bridge
  ├── generate assets/dhu-adapter-config.json from config.json + flag overrides
  ├── add classesN.dex (adapter + Pine [+ Zeekr SDK when --media-bridge])
  ├── add libpine.so (arm64, Stored)
  ├── zipalign -p 4 (page-align; required for extractNativeLibs=false apps)
  └── apksigner sign (DHUAdapter keystore)
```

Direct binary injection preserves all original resources and native libs.

## Known issues

- **WebView modals** — fixed-size CSS containers may keep small text despite zoom.
- **Apps with signature verification** — banking/DRM apps may detect re-signing.
- **First launch may relaunch after onboarding** on an emulator without Google Play Services — the app's Firebase Installations call times out and the app restarts its service; the second launch is fine. This is an emulator artifact (no GMS backend), not a patch regression.

## Build toolchain notes

- **d8 must run on Temurin 21 (HotSpot)** — IBM Semeru/OpenJ9 crashes it (GC ScavengerRootScanner assertion).
- Pine smali must be the **original** disassembly (not dex2jar output) — kept under `vendor/pine-smali/top`, swapped into `build/smali/top`.
- `rm -rf` is avoided in scripts; fresh `mktemp -d` dirs are used.

## Tested

| Kind | Result |
|------|--------|
| Navigation app (5.22.x, merged universal) | ✅ **confirmed on real DHU** — automotive-OS fix renders the map (`isAutomotiveOS→false`); density/hooks fine |
| Music app A (6.5.x, merged universal) | ✅ **confirmed on real DHU** — plays with artwork; **MediaCenter working** (register → focus → events / cover / metadata / stop-resume) |
| Music app B (full single APK + merged universal) | ✅ works re-signed with a valid signature (invalid signature breaks its server Home feed) |
| Messaging app (12.10.x) | ✅ launches on DHU (SIGSEGV-at-launch fixed by forcing Pine internal logging off) |

## Project structure

```
zeekr-adapt/
├── src/com/dhuadapter/
│   ├── DhuAdapterFactory.java      — AppComponentFactory orchestrator (populates HookEnv, calls each category)
│   ├── DhuConfig.java              — embedded config loader (APK zip + assets)
│   ├── BackButtonOverlay.java      — draggable floating back button
│   ├── RoundedCornersProvider.java — ViewOutlineProvider
│   ├── core/
│   │   ├── HookEnv.java            — shared static holder (config, appContext, classLoader, mediaBridge)
│   │   ├── BuildFields.java        — reflective Build.* field setter (root + emulator)
│   │   ├── SharedHooks.java        — one-hook-per-shared-method dispatcher (updateFrom / getConfiguration / SystemProperties.get / onConfigurationChanged)
│   │   └── TransformRegistry.java  — pure ordered-transform registry (unit-tested)
│   ├── display/                    — Cat.1: DisplayHooks + LifecycleHooks
│   ├── capture/                    — Cat.7: CaptureHooks (FLAG_SECURE strip)
│   ├── automotive/                 — Cat.4: AutomotiveHooks (de-mask)
│   ├── root/                       — Cat.2: RootBypass + RootPathMatcher (pure)
│   ├── emulator/                   — Cat.3: EmulatorBypass
│   ├── sysprops/                   — Cat.2+3: SystemPropertiesSpoof + PropSpoofTable (pure)
│   ├── network/                    — Cat.5a NetworkBypass + Cat.5b SimGate
│   ├── signature/                  — Cat.9: SignatureSpoof + CertReader (pure)
│   └── mediabridge/                — Cat.6: MediaSessionHooks + MediaBridge + CoverProvider + RecoveryReceiver
├── test/com/dhuadapter/
│   └── PureLogicTests.java         — zero-dependency JVM unit tests (no JUnit/Gradle)
├── tools/extract_apk_cert.py       — v2/v3 signing-block cert extractor (for --copy-sign)
├── .github/workflows/tests.yml     — CI: run-tests.sh on Temurin 21
├── run-tests.sh                    — compile the pure classes on a bare JDK + run PureLogicTests
├── vendor/pine-smali/top/          — original Pine smali (merged into dex)
├── libs/pine.jar                   — Pine engine (top.canyie/pine, see NOTICE)
├── native/arm64-v8a/libpine.so
├── config.json                     — default configuration
├── build.sh                        — compile → d8 → baksmali → +Pine smali → smali a
├── patch_apk.sh                    — patch APK (flags → embedded config, direct injection, DHUAdapter sign)
├── patch_manifest.py               — binary AXML patcher (factory + <provider> + <queries> + <receiver>)
└── README.md
```

### Tests & CI

Device-independent decision logic (root-path matching, prop-spoof tables, cert
parsing, the SharedHooks transform registry) is extracted into pure,
dependency-free classes and covered by a **zero-dependency JVM test runner**
(`test/com/dhuadapter/PureLogicTests.java` — plain `main()` with assertions, no
JUnit/Gradle). Run locally with `bash run-tests.sh`; GitHub Actions runs it on
Temurin 21 for every push/PR (`.github/workflows/tests.yml`). The Pine hooks
themselves target framework classes and are verified on a device/emulator.

## Support

If zeekr-adapt saved you a trip to the "specialists", a coffee keeps it going 🜛

☕ **[ko-fi.com/nobleKr](https://ko-fi.com/nobleKr)**

## License

MIT
