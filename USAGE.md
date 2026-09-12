# zeekr-adapt — User Guide

How to take an app from Google Play and produce a DHU-ready patched APK.

Pipeline:

```
1. Get a YA29 auth token   →  authorize apkeep against your Google account
2. Download with apkeep    →  base + arm64 native + xxhdpi + uk/ru/en language splits
3. Merge with APKEditor    →  one universal APK
4. Patch with zeekr-adapt  →  DHU-ready APK  (density, hooks, integration flags)
5. Install on the DHU
```

You need: a computer with `apkeep` and Java 17+ (for APKEditor), plus the built `zeekr-adapt` (see the main README's *Build* section) on the machine that patches.

---

## 1. Get a YA29 auth token

`apkeep` downloads from Google Play as a real account. It needs an **OAuth token** that starts with `ya29.` (a short-lived Google access token), together with your Gmail address and an **AAS token / GSF ID** flow. The simplest, well-known method:

1. On a desktop browser, open the Google embedded sign-in page apkeep uses:

   ```
   https://accounts.google.com/EmbeddedSetup
   ```

2. Sign in with the Google account you want to download as. **Use a throwaway/secondary account** — Play may flag automated downloads.

3. After you accept the terms, **do not close the page**. Open the browser's **DevTools → Application → Cookies** for `google.com` and copy the value of the **`oauth_token`** cookie. It looks like:

   ```
   oauth_token=oauth2_4/0Ax4XfW...        ← this is the "master" token
   ```

   > Some flows instead expose a token that already begins with `ya29.` in the network requests — either works as the credential apkeep exchanges.

4. apkeep exchanges that for the `ya29.`/AAS token itself; you pass it on the command line (next step). If your apkeep build wants the raw `ya29.` token, grab it from the DevTools **Network** tab on any authenticated `googleapis.com` request (the `Authorization: Bearer ya29....` header).

> **Security:** the token is a live credential for that Google account. Do not commit it, do not paste it into shared logs. It expires within ~1 hour — re-fetch when downloads start returning `401`.

---

## 2. Download with apkeep (uk, ru, en locales)

Binary: `apkeep-x86_64-linux` (mark it executable once: `chmod +x apkeep-x86_64-linux`).

Download the app **as split APKs** (`--split-apk=true`) so you get the base + the arm64 native split + the density split + the language splits, then we merge them in step 3.

```bash
# Example: download com.example.app split APKs into ./dl/
./apkeep-x86_64-linux \
  --app com.example.app \
  --download-source google \
  --split-apk true \
  --options "locale=uk_UA,ru_RU,en_US,arch=arm64-v8a,dpi=xxhdpi" \
  --email you@gmail.com \
  --aas-token 'ya29.a0Ax4XfW...' \
  ./dl
```

Key options:

| Option | Why |
|--------|-----|
| `--split-apk true` | fetch base + splits (needed for native libs + all densities) |
| `locale=uk_UA,ru_RU,en_US` | pull the **Ukrainian, Russian and English** language splits so the UI has all three |
| `arch=arm64-v8a` | the DHU is arm64 — without this split, apps with `extractNativeLibs=false` have no native `.so` and hang on the splash |
| `dpi=xxhdpi` | highest-density drawables → sharp icons at 280dpi |
| `--email` / `--aas-token` | your account + the `ya29.`/AAS token from step 1 |

After it finishes, `./dl/` contains something like:

```
com.example.app.apk                 # base
com.example.app.config.arm64_v8a.apk
com.example.app.config.xxhdpi.apk
com.example.app.config.uk.apk
com.example.app.config.ru.apk
com.example.app.config.en.apk
```

> If apkeep produces a single `.xapk`/`.apkm` (a zip of the splits), unzip it into a folder first — that folder is the input to the merge.

---

## 3. Merge the splits into one universal APK (APKEditor)

Split APKs cannot be installed/patched directly — merge them into a single universal APK with [APKEditor](https://github.com/REAndroid/APKEditor):

```bash
# from a directory containing all the split APKs (./dl)
java -jar APKEditor.jar m -i ./dl -o com.example.app.universal.apk
```

- `m` = merge mode; `-i` = input dir (or a `.xapk`/`.apkm` file); `-o` = output universal APK.
- The merge folds the base + arm64 + xxhdpi + uk/ru/en splits into one installable APK with all locales and native libs.

The result `com.example.app.universal.apk` is the input to patching.

---

## 4. Patch with zeekr-adapt

Run the patcher on the universal APK. Hooks are grouped into **8 feature
categories**; **only Category 1 (Display/UI) is ON by default** — everything else
is opt-in via a flag.

```bash
export JAVA_HOME=/path/to/temurin-21          # HotSpot, NOT OpenJ9/Semeru
./patch_apk.sh com.example.app.universal.apk out.apk [flags]
```

If you omit the output name, the patcher derives one.

> ⚠️ **Breaking change:** root-bypass and the automotive fix used to be always-on.
> They are now **opt-in flags** — a car-aware app needs `--automotive-fix`, an app
> that root-detects needs `--root-bypass`. Defaults alone give you Display/UI only.

### Flag examples

```bash
# 1) Plain app — just make the UI DHU-sized (Display only, the default)
./patch_apk.sh app.universal.apk app.dhu.apk

# 2) Navigation / car-aware app — full automotive de-mask (blank-screen fix)
./patch_apk.sh nav.universal.apk nav.dhu.apk --automotive-fix

# 3) Music / media app with SIM-gated online + MediaCenter
./patch_apk.sh music.universal.apk music.dhu.apk \
  --root-bypass --emulator-bypass --network-bypass --sim-ready --media-bridge

# 4) Music app whose server checks the app signature — feed the genuine cert
./patch_apk.sh music.universal.apk music.dhu.apk --media-bridge --copy-sign

# 5) App that root-detects on the userdebug head unit
./patch_apk.sh app.universal.apk app.dhu.apk --root-bypass

# 6) Portrait-only app you want to keep portrait, with bigger text
./patch_apk.sh app.universal.apk app.dhu.apk --no-orientation --metrics-dpi 300

# 7) Add --debug to any of the above for `adb logcat -s DhuAdapter`
```

### All flags (by category)

| # | Category | Flag | Default | Effect |
|---|----------|------|---------|--------|
| 1 | Display / UI | *(on)*; `--no-display` | ON | density 280/240, landscape, fullscreen, corners, back button, font, WebView zoom/UA |
| 1 | ↳ orientation | `--no-orientation` | forces landscape | don't force landscape |
| 1 | ↳ fullscreen | `--no-fullscreen` | fullscreen | don't force fullscreen |
| 1 | ↳ render DPI | `--metrics-dpi <n>` | 280 | bigger = larger UI |
| 1 | ↳ layout DPI | `--config-dpi <n>` | 240 | bigger = more elements per row |
| 2 | Root bypass | `--root-bypass` | off | hide root/su; needed by apps that refuse on rooted/userdebug head units |
| 3 | Emulator bypass | `--emulator-bypass` | off | de-genericise Build.* + qemu props — **emulator only** |
| 4 | Automotive | `--automotive-fix` | off | blank-screen fix + block Android Auto + full de-mask |
| 5a | Network | `--network-bypass` / `--no-network-bypass` | off | report the network as connected |
| 5b | SIM-gate | `--sim-ready` | off | SIM READY + allow-cellular (music online-gate; **harmful to phone-number registration**) |
| 6 | MediaCenter | `--media-bridge` | off | Zeekr MediaCenter (cover / metadata / wheel / reboot-resume). Media apps only |
| 7 | Capture | `--allow-capture` | off | strip `FLAG_SECURE` for capture/mirroring |
| 8 | Diagnostics | `--debug` | off | verbose logging |
| 9 | Signature spoof | `--copy-sign` | off | preserve + feed the genuine signer cert to the app's own signature check |
| — | explicit config | `--config <file>` | — | use your own config.json instead of generating one |

---

## 5. Install on the DHU

Patched APKs are re-signed with the project's DHUAdapter key (`keystore/dhuadapter.keystore`, generated once, valid v2+v3), so uninstall the stock app first and turn off Play Protect verification:

```bash
adb connect <dhu-ip>:5555            # or however you reach the DHU
adb shell settings put global package_verifier_enable 0
adb uninstall com.example.app        # remove any prior copy
adb install -r -d out.apk            # -d allows the debug-signed downgrade
```

Then launch the app from the DHU launcher.

---

## Troubleshooting

| Symptom | Cause / fix |
|---------|-------------|
| `apkeep` returns `401` / auth error | the `ya29.` token expired (~1h) — re-fetch it (step 1) |
| App hangs on splash / logo | missing arm64 split — re-download with `arch=arm64-v8a` and re-merge |
| UI still tiny after patch | wrong DPI — raise `--metrics-dpi` (e.g. 300–320) |
| Install fails `INSTALL_FAILED_UPDATE_INCOMPATIBLE` | a copy is already installed — `adb uninstall <pkg>` first |
| Install fails `signatures do not match` | Play Protect / verifier on — `settings put global package_verifier_enable 0` |
| Blank/white screen on a car-aware app | rebuild with `--automotive-fix` (Category 4 — no longer always-on); capture the log with `--debug` and `adb logcat -s DhuAdapter` |
| Media app doesn't show on the cluster | rebuild with `--media-bridge`; the DHU must have `com.zeekr.mediacenter` / `com.zeekr.coreservice` (standard); check `adb logcat -s DhuAdapter` for `MediaBridge.bindService ... -> true` and `mCode=200` |

> `d8` (used by the build) must run on **Temurin 21 (HotSpot)** — the default IBM Semeru/OpenJ9 JVM crashes it. Set `JAVA_HOME` accordingly before building/patching.
