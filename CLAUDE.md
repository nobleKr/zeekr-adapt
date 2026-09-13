# zeekr-adapt — governing principle (read first)

## The one rule: hook the Android framework, never the app

Every adaptation MUST be implemented by hooking **public Android framework
API only**. The target app is treated as an opaque black box.

**Never, under any circumstances:**
- Reference the target app's package, class, resource, or id names
  (e.g. `com.apple...`, `button_play`, `KnockoutButton`,
  `getResourceEntryName(...)` matched against app names). No app-specific hooks.
- Modify, patch, or special-case the app's own code or layouts.
- Hardcode a screen resolution or density (no `2560`, `1600`, `536`, …).
  Derive everything from the **live** device metrics at runtime
  (`Resources.getDisplayMetrics().widthPixels/heightPixels`, the current
  `Configuration`, the real `densityDpi`).

**Always:**
- Hook only framework surfaces: `Resources`, `Display`, `Configuration`,
  `ResourcesImpl.updateConfiguration`, `android.widget.LinearLayout.onMeasure`,
  `WebView`/`WebSettings`, `Activity`, `View`, `Instrumentation`,
  `ContextWrapper`, `WindowInsetsController`, etc.
- Solve UI problems by generic layout/measure properties (orientation,
  LayoutParams, MeasureSpec, child desired sizes), not by knowing which app
  or which widget it is.

A fix that needs the app's names is out of scope by definition — find the
framework-level cause instead.

## Density model (current)

- Single, consistent density: `metricsDpi == configDpi` (both 280 by default).
  The old two-DPI split (280 render / 240 layout) is REMOVED — the render≠layout
  mismatch was the root cause of clipped/smeared custom views (e.g. software-layer
  buttons). Keep them equal.
- `recomputeDp(Configuration, DisplayMetrics)`: sets `screenWidthDp` /
  `screenHeightDp` / `smallestScreenWidthDp` = live usable px ÷ our density
  (Android's own formula). Applied via `ResourcesImpl.updateConfiguration` +
  early `pushMetrics`. No hardcoded dp, no phone-width cap (tablet layout kept).

## Clipped-container relief (app-agnostic)

`installRelaxClippedLinear` hooks `android.widget.LinearLayout.onMeasure`:
for a container given an EXACTLY size smaller than its children's true desired
size (children re-measured UNSPECIFIED), re-measure it to the content size,
bounded by live screen px. Gated to fixed-size containers (`LayoutParams
width/height > 0`) so match_parent/weighted rows are untouched. Fixes any
fixed-size widget that clips at a raised density — with zero app knowledge.

> NOTE: README.md "Two-DPI density" section is stale (describes the removed
> 280/240 split and "no updateConfiguration"); update it to match the above.
