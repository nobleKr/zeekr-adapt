package com.dhuadapter.display;

import android.app.Activity;
import android.content.Context;
import android.content.pm.ActivityInfo;
import android.content.res.Configuration;
import android.graphics.Typeface;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.Display;
import android.view.View;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.widget.TextView;

import java.lang.reflect.Method;

import com.dhuadapter.core.HookEnv;

import top.canyie.pine.Pine;
import top.canyie.pine.callback.MethodHook;

/**
 * Category 1 — Display / UI (rendering-DPI, layout-DPI, orientation, font,
 * inset padding, WebView zoom/UA). The one category ON by default. Window
 * chrome (fullscreen / rounded corners / back button) lives in LifecycleHooks.
 */
public final class DisplayHooks {

    private static final String TAG = HookEnv.TAG;
    private static Typeface customTypeface;

    private DisplayHooks() {}

    public static void install() {
        installDisplayMetricsHook();
        installConfigurationHook();
        installSetRequestedOrientationHook();
        installViewOnAttachedHook();
        installSetPaddingRelativeHook();
        installWebViewZoomHook();
        installConfigUpdateFromDensity();
        installEarlyDensityPoints();
        installWidthCapResources();   // phone-UI: rewrite the Configuration the framework uses to SELECT resources
        installRelaxClippedLinear();  // app-agnostic: relax EXACTLY LinearLayouts that clip their children (e.g. 160dp Play pill)
    }

    // App-agnostic layout relief. Hooks android.widget.LinearLayout.onMeasure
    // (a pure framework class — no app/resource matching). After the normal
    // measure pass, if the LinearLayout was given an EXACTLY size smaller than
    // what its children actually need (they overflow/clip), we re-measure the
    // group with the needed size instead — bounded by the REAL screen capacity
    // (its Resources' DisplayMetrics widthPixels/heightPixels at the current
    // DPI, so the relief is derived from resolution+density, never hardcoded).
    // Horizontal: needed width = Σ children (measuredWidth+margins). Vertical:
    // needed height = Σ children. This fixes any fixed-size container that clips
    // its content at a raised density (e.g. AM's 160dp Play pill) generically.
    // gate: display + relaxClippedLinear.
    // Re-entrancy guard: our re-measure calls onMeasure again, which re-enters
    // this same hook — skip the nested pass.
    private static final ThreadLocal<Boolean> IN_RELAX = new ThreadLocal<>();

    private static void installRelaxClippedLinear() {
        if (!HookEnv.config.display || !HookEnv.config.relaxClippedLinear) return;
        try {
            Method m = android.widget.LinearLayout.class.getDeclaredMethod(
                    "onMeasure", int.class, int.class);
            m.setAccessible(true);
            Pine.hook(m, new MethodHook() {
                @Override public void afterCall(Pine.CallFrame f) {
                    try {
                        if (Boolean.TRUE.equals(IN_RELAX.get())) return;   // nested re-measure — skip
                        android.widget.LinearLayout ll = (android.widget.LinearLayout) f.thisObject;
                        if (ll == null) return;
                        // relax ONLY fixed-size containers (e.g. 160dp Play pill);
                        // never match_parent / wrap / weighted rows -> no collateral widening,
                        // no nested double-relax with a software-layer child.
                        android.view.ViewGroup.LayoutParams llp = ll.getLayoutParams();
                        boolean fixedW = llp != null && llp.width  > 0;
                        boolean fixedH = llp != null && llp.height > 0;
                        if (!fixedW && !fixedH) return;
                        int wSpec = (int) f.args[0];
                        int hSpec = (int) f.args[1];
                        boolean horizontal =
                                ll.getOrientation() == android.widget.LinearLayout.HORIZONTAL;

                        // screen capacity in px (real resolution ÷ our DPI is already
                        // baked into these metrics); upper bound so we never blow past screen
                        DisplayMetrics dm = ll.getResources().getDisplayMetrics();
                        int capW = (dm != null && dm.widthPixels  > 0) ? dm.widthPixels  : Integer.MAX_VALUE;
                        int capH = (dm != null && dm.heightPixels > 0) ? dm.heightPixels : Integer.MAX_VALUE;

                        // sum/max of children's needed sizes (measured + margins)
                        int needW = 0, needH = 0, n = ll.getChildCount();
                        for (int i = 0; i < n; i++) {
                            View ch = ll.getChildAt(i);
                            if (ch == null || ch.getVisibility() == View.GONE) continue;
                            // true desired size: children in an EXACTLY parent were
                            // measured AT_MOST (already clipped) — re-measure UNSPECIFIED.
                            IN_RELAX.set(Boolean.TRUE);
                            try {
                                ch.measure(
                                    View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED),
                                    View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED));
                            } finally { IN_RELAX.set(Boolean.FALSE); }
                            int mw = ch.getMeasuredWidth();
                            int mh = ch.getMeasuredHeight();
                            android.view.ViewGroup.LayoutParams lp = ch.getLayoutParams();
                            if (lp instanceof android.view.ViewGroup.MarginLayoutParams) {
                                android.view.ViewGroup.MarginLayoutParams mp =
                                        (android.view.ViewGroup.MarginLayoutParams) lp;
                                mw += mp.leftMargin + mp.rightMargin;
                                mh += mp.topMargin + mp.bottomMargin;
                            }
                            if (horizontal) { needW += mw; needH = Math.max(needH, mh); }
                            else            { needH += mh; needW = Math.max(needW, mw); }
                        }
                        needW += ll.getPaddingLeft() + ll.getPaddingRight();
                        needH += ll.getPaddingTop()  + ll.getPaddingBottom();

                        int haveW = ll.getMeasuredWidth();
                        int haveH = ll.getMeasuredHeight();
                        boolean wExact = View.MeasureSpec.getMode(wSpec) == View.MeasureSpec.EXACTLY;
                        boolean hExact = View.MeasureSpec.getMode(hSpec) == View.MeasureSpec.EXACTLY;

                        boolean fixW = fixedW && wExact && needW > haveW && needW <= capW;
                        boolean fixH = fixedH && hExact && needH > haveH && needH <= capH;
                        // NOTE: children were re-measured UNSPECIFIED above (state clobbered),
                        // so we must always re-run onMeasure with the final specs (relaxed OR
                        // original) to leave children consistent with the layout size.
                        int newWSpec = fixW
                                ? View.MeasureSpec.makeMeasureSpec(needW, View.MeasureSpec.EXACTLY)
                                : wSpec;
                        int newHSpec = fixH
                                ? View.MeasureSpec.makeMeasureSpec(needH, View.MeasureSpec.EXACTLY)
                                : hSpec;
                        // re-run the real measure with the relaxed spec(s)
                        IN_RELAX.set(Boolean.TRUE);
                        try {
                            m.invoke(ll, newWSpec, newHSpec);
                        } finally {
                            IN_RELAX.set(Boolean.FALSE);
                        }
                    } catch (Throwable t) { /* ignore — never break layout */ }
                }
            });
            Log.i(TAG, "Hook installed: LinearLayout.onMeasure relax-clipped (app-agnostic)");
        } catch (Throwable t) {
            Log.e(TAG, "Failed to hook LinearLayout.onMeasure", t);
        }
    }

    // Density-only Configuration transform for paths WITHOUT paired metrics
    // (SharedHooks updateFrom / getConfiguration results). Keeps densityDpi
    // consistent with our single chosen density; the full dp recompute needs
    // real pixels and happens in recomputeDp (updateConfiguration / pushMetrics).
    private static void capConfig(Configuration c) {
        if (c == null) return;
        c.densityDpi = HookEnv.config.configDpi;
    }

    // Recompute the Configuration's dp dimensions for OUR single density
    // (configDpi == metricsDpi), dynamically from the screen — no hardcoded dp,
    // NO phone cap (native tablet layout preserved).
    //
    // Non-fullscreen aware: the system bars (status/navigation) eat part of the
    // height when fullscreen=false, so screenHeightDp is NOT widthPixels-style
    // "full pixels / density" — the framework already subtracted the bars. We
    // must preserve that subtraction. So:
    //   • WIDTH: no side bars in landscape → recompute from full widthPixels.
    //   • HEIGHT: take the framework's already-bars-excluded screenHeightDp and
    //     rescale it by the density ratio (stock density that produced it →
    //     ours), instead of dividing raw heightPixels (which would ignore the
    //     bars and push content under them).
    // Recompute BOTH dp dimensions for OUR single density (configDpi ==
    // metricsDpi), dynamically from the screen's REAL USABLE capacity — no
    // hardcoded dp, NO phone cap (native tablet layout preserved).
    //
    // Fullscreen-aware by construction: the DisplayMetrics handed to
    // ResourcesImpl.updateConfiguration carry widthPixels/heightPixels for the
    // CURRENT usable window area — the framework already accounts for the
    // system bars, so these pixels SHRINK when fullscreen=false and GROW back
    // when fullscreen=true. Dividing them by our density therefore yields dp
    // that track the real capacity on every config change (including a
    // fullscreen toggle or a bar show/hide), which is exactly what we want.
    //   screenWidthDp  = usableWidthPx  / density
    //   screenHeightDp = usableHeightPx / density
    private static void recomputeDp(Configuration c, DisplayMetrics dm) {
        if (c == null) return;
        c.densityDpi = HookEnv.config.configDpi;                 // impose our density
        if (dm == null || dm.widthPixels <= 0 || dm.heightPixels <= 0) return;
        float ourDensity = HookEnv.config.configDpi / 160f;      // Android: density = densityDpi / 160
        int wDp = Math.round(dm.widthPixels  / ourDensity);      // usable width  → dp
        int hDp = Math.round(dm.heightPixels / ourDensity);      // usable height → dp
        c.screenWidthDp  = wDp;
        c.screenHeightDp = hDp;
        c.smallestScreenWidthDp = Math.min(wDp, hDp);
    }

    // THE KEY HOOK — ResourcesImpl.updateConfiguration builds the ResTable_config
    // the framework uses to SELECT resource buckets (values-w####dp / sw###dp).
    // We rewrite the dp dimensions here to match OUR density, dynamically from
    // the paired real DisplayMetrics — no phone cap, tablet layout preserved.
    private static void installWidthCapResources() {
        if (!HookEnv.config.display) return;
        try {
            Class<?> impl = Class.forName("android.content.res.ResourcesImpl");
            Class<?> compat = Class.forName("android.content.res.CompatibilityInfo");
            Method m = impl.getDeclaredMethod("updateConfiguration",
                    Configuration.class, DisplayMetrics.class, compat);
            m.setAccessible(true);
            Pine.hook(m, new MethodHook() {
                @Override public void beforeCall(Pine.CallFrame f) {
                    try {
                        Configuration cfg = (f.args != null && f.args.length > 0 && f.args[0] instanceof Configuration)
                                ? (Configuration) f.args[0] : null;
                        DisplayMetrics dm = (f.args != null && f.args.length > 1 && f.args[1] instanceof DisplayMetrics)
                                ? (DisplayMetrics) f.args[1] : null;
                        if (cfg != null) {
                            recomputeDp(cfg, dm);   // dynamic dp from real px ÷ our density
                        }
                    } catch (Throwable t) { /* ignore */ }
                }
            });
            Log.i(TAG, "Hook installed: ResourcesImpl.updateConfiguration dynamic dp @ "
                    + HookEnv.config.configDpi + "dpi");
        } catch (Throwable t) {
            Log.e(TAG, "Failed to hook ResourcesImpl.updateConfiguration", t);
        }
    }

    // Optional fallback: force the tablet bool resources false by name (version-stable).
    // Category 1 contribution to the SHARED Configuration.updateFrom hook: cap
    // width toward phone + force configDpi. Registered via SharedHooks (single
    // hook shared with Category 4's deCar) — NOT a second Pine hook on updateFrom.
    private static void installConfigUpdateFromDensity() {
        com.dhuadapter.core.SharedHooks.registerConfigTransform(
                com.dhuadapter.core.SharedHooks.CONFIG_UPDATE_FROM,
                DisplayHooks::capConfig);
        Log.i(TAG, "Registered: Configuration.updateFrom width-cap + densityDpi (via SharedHooks)");
    }

    // Early density points: apply metrics BEFORE Application.onCreate and on the
    // earliest ContextWrapper, so the app sees our density from the very start.
    // Both are pure android.* framework methods.
    private static void installEarlyDensityPoints() {
        // Instrumentation.callApplicationOnCreate(Application) — fires just before
        // Application.onCreate; push metrics onto the app's Resources first.
        try {
            Method m = android.app.Instrumentation.class.getMethod(
                    "callApplicationOnCreate", android.app.Application.class);
            Pine.hook(m, new MethodHook() {
                @Override
                public void beforeCall(Pine.CallFrame f) {
                    try {
                        if (f.args != null && f.args.length > 0
                                && f.args[0] instanceof android.content.Context) {
                            pushMetrics((android.content.Context) f.args[0]);
                        }
                    } catch (Throwable t) { /* ignore */ }
                }
            });
        } catch (Throwable t) {
            Log.e(TAG, "Failed to hook Instrumentation.callApplicationOnCreate", t);
        }

        // ContextWrapper.attachBaseContext(Context) — protected; resolve reflectively.
        try {
            Method m = android.content.ContextWrapper.class.getDeclaredMethod(
                    "attachBaseContext", android.content.Context.class);
            m.setAccessible(true);
            Pine.hook(m, new MethodHook() {
                @Override
                public void beforeCall(Pine.CallFrame f) {
                    try {
                        if (f.args != null && f.args.length > 0
                                && f.args[0] instanceof android.content.Context) {
                            pushMetrics((android.content.Context) f.args[0]);
                        }
                    } catch (Throwable t) { /* ignore */ }
                }
            });
            Log.i(TAG, "Hook installed: early density (callApplicationOnCreate + attachBaseContext)");
        } catch (Throwable t) {
            Log.e(TAG, "Failed to hook ContextWrapper.attachBaseContext", t);
        }
    }

    // Push our density onto a context's Resources metrics + configuration.
    private static void pushMetrics(android.content.Context ctx) {
        try {
            android.content.res.Resources res = ctx.getResources();
            if (res == null) return;
            scaleMetrics(res.getDisplayMetrics(), HookEnv.config.metricsDpi);
            android.content.res.Configuration cfg = res.getConfiguration();
            if (cfg != null) {
                recomputeDp(cfg, res.getDisplayMetrics());
            }
        } catch (Throwable t) { /* ignore — afterCall hooks remain the primary path */ }
    }

    // Apply metricsDpi to a DisplayMetrics (rendering-DPI mutation)
    private static void scaleMetrics(DisplayMetrics dm, int dpi) {
        if (dm == null) return;
        float d = dpi / 160f;
        dm.densityDpi = dpi;
        dm.density = d;
        dm.scaledDensity = d;
        dm.xdpi = dpi;
        dm.ydpi = dpi;
    }

    private static void installDisplayMetricsHook() {
        // Resources.getDisplayMetrics() → result
        try {
            Method rGetMetrics = android.content.res.Resources.class
                    .getDeclaredMethod("getDisplayMetrics");
            Pine.hook(rGetMetrics, new MethodHook() {
                @Override
                public void afterCall(Pine.CallFrame callFrame) {
                    try {
                        scaleMetrics((DisplayMetrics) callFrame.getResult(), HookEnv.config.metricsDpi);
                    } catch (Exception e) { /* ignore */ }
                }
            });
        } catch (Exception e) {
            Log.e(TAG, "Failed to hook Resources.getDisplayMetrics", e);
        }

        // Display.getMetrics(DisplayMetrics) → arg[0]
        try {
            Method dGetMetrics = Display.class.getMethod("getMetrics", DisplayMetrics.class);
            Pine.hook(dGetMetrics, new MethodHook() {
                @Override
                public void afterCall(Pine.CallFrame callFrame) {
                    try {
                        if (callFrame.args.length > 0
                                && callFrame.args[0] instanceof DisplayMetrics) {
                            scaleMetrics((DisplayMetrics) callFrame.args[0], HookEnv.config.metricsDpi);
                        }
                    } catch (Exception e) { /* ignore */ }
                }
            });
        } catch (Exception e) {
            Log.e(TAG, "Failed to hook Display.getMetrics", e);
        }

        // Display.getRealMetrics(DisplayMetrics) → arg[0] (some apps use this)
        try {
            Method dRealMetrics = Display.class.getMethod("getRealMetrics", DisplayMetrics.class);
            Pine.hook(dRealMetrics, new MethodHook() {
                @Override
                public void afterCall(Pine.CallFrame callFrame) {
                    try {
                        if (callFrame.args.length > 0
                                && callFrame.args[0] instanceof DisplayMetrics) {
                            scaleMetrics((DisplayMetrics) callFrame.args[0], HookEnv.config.metricsDpi);
                        }
                    } catch (Exception e) { /* ignore */ }
                }
            });
        } catch (Exception e) { /* getRealMetrics optional */ }

        Log.i(TAG, "Hook installed: getDisplayMetrics/getMetrics → " + HookEnv.config.metricsDpi + "dpi");
    }

    private static void installConfigurationHook() {
        // Register a result-transform on the SHARED Resources.getConfiguration hook
        // (afterCall sets densityDpi) instead of hooking the method directly — so it
        // is composited with any other category that needs getConfiguration, hooked once.
        com.dhuadapter.core.SharedHooks.registerConfigResultTransform(
                DisplayHooks::capConfig);
        Log.i(TAG, "Registered: Resources.getConfiguration width-cap + densityDpi (via SharedHooks)");
    }

    private static void installSetRequestedOrientationHook() {
        try {
            Method method = Activity.class.getMethod("setRequestedOrientation", int.class);
            Pine.hook(method, new MethodHook() {
                @Override
                public void beforeCall(Pine.CallFrame callFrame) {
                    try {
                        if (HookEnv.config.forceOrientation) {
                            int original = (int) callFrame.args[0];
                            callFrame.args[0] = ActivityInfo.SCREEN_ORIENTATION_UNSPECIFIED;
                            if (HookEnv.config.debug) {
                                Log.d(TAG, "setRequestedOrientation: " + original
                                        + " -> SCREEN_ORIENTATION_UNSPECIFIED");
                            }
                        }
                    } catch (Exception e) {
                        Log.e(TAG, "setRequestedOrientation hook error", e);
                    }
                }
            });
            Log.i(TAG, "Hook installed: Activity.setRequestedOrientation");
        } catch (Exception e) {
            Log.e(TAG, "Failed to hook Activity.setRequestedOrientation", e);
        }
    }

    private static void installViewOnAttachedHook() {
        try {
            Method method = View.class.getDeclaredMethod("onAttachedToWindow");
            method.setAccessible(true);
            Pine.hook(method, new MethodHook() {
                @Override
                public void afterCall(Pine.CallFrame callFrame) {
                    try {
                        View view = (View) callFrame.thisObject;
                        if (view instanceof TextView && HookEnv.config.fontOverride != null) {
                            if (customTypeface == null) {
                                try {
                                    customTypeface = Typeface.createFromAsset(
                                            view.getContext().getAssets(),
                                            "fonts/" + HookEnv.config.fontOverride);
                                } catch (Exception e) {
                                    Log.w(TAG, "Font not found: fonts/"
                                            + HookEnv.config.fontOverride + ", disabling override");
                                    HookEnv.config.fontOverride = null; // don't retry every view
                                    return;
                                }
                            }
                            ((TextView) view).setTypeface(customTypeface);
                        }
                    } catch (Exception e) {
                        Log.e(TAG, "onAttachedToWindow hook error", e);
                    }
                }
            });
            Log.i(TAG, "Hook installed: View.onAttachedToWindow");
        } catch (Exception e) {
            Log.e(TAG, "Failed to hook View.onAttachedToWindow", e);
        }
    }

    private static void installSetPaddingRelativeHook() {
        try {
            Method method = View.class.getMethod("setPaddingRelative",
                    int.class, int.class, int.class, int.class);
            Pine.hook(method, new MethodHook() {
                @Override
                public void beforeCall(Pine.CallFrame callFrame) {
                    try {
                        View view = (View) callFrame.thisObject;
                        if (view.getParent() instanceof View) {
                            String parentClass =
                                    view.getParent().getClass().getName();
                            if (parentClass.contains("Inset")
                                    || parentClass.contains("FitWindows")
                                    || parentClass.contains("NavigationBar")
                                    || parentClass.contains("StatusBar")) {
                                callFrame.args[0] = 0; // start
                                callFrame.args[1] = 0; // top
                                callFrame.args[2] = 0; // end
                                callFrame.args[3] = 0; // bottom
                                if (HookEnv.config.debug) {
                                    Log.d(TAG, "Zeroed inset padding for parent: "
                                            + parentClass);
                                }
                            }
                        }
                    } catch (Exception e) {
                        Log.e(TAG, "setPaddingRelative hook error", e);
                    }
                }
            });
            Log.i(TAG, "Hook installed: View.setPaddingRelative");
        } catch (Exception e) {
            Log.e(TAG, "Failed to hook View.setPaddingRelative", e);
        }
    }

    private static void installWebViewZoomHook() {
        // Only set textZoom on WebSettings — clean, universal, no JS injection
        try {
            Method getSettings = WebView.class.getMethod("getSettings");
            Pine.hook(getSettings, new MethodHook() {
                @Override
                public void afterCall(Pine.CallFrame callFrame) {
                    try {
                        WebSettings settings = (WebSettings) callFrame.getResult();
                        if (settings != null && settings.getTextZoom() == 100) {
                            settings.setTextZoom((int) (HookEnv.config.density() * 100));
                        }
                    } catch (Exception e) { /* ignore */ }
                }
            });
        } catch (Exception e) {
            Log.e(TAG, "Failed to hook WebView.getSettings", e);
        }

        // WebView User-Agent fix: some apps render the map via a WebView and the
        // default DHU/emulator UA gets rejected by the tile/map server → blank
        // white map. Force a standard mobile Chrome UA so map content loads.
        try {
            Method getDefaultUA = WebSettings.class.getMethod(
                    "getDefaultUserAgent", Context.class);
            Pine.hook(getDefaultUA, new MethodHook() {
                @Override
                public void beforeCall(Pine.CallFrame callFrame) {
                    if (HookEnv.config.userAgentOverride != null
                            && !HookEnv.config.userAgentOverride.isEmpty()) {
                        callFrame.setResult(HookEnv.config.userAgentOverride);
                    }
                }
            });
            Log.i(TAG, "Hook installed: WebSettings.getDefaultUserAgent → "
                    + (HookEnv.config.userAgentOverride != null ? "custom UA" : "unchanged"));
        } catch (Exception e) {
            Log.e(TAG, "Failed to hook getDefaultUserAgent", e);
        }

        Log.i(TAG, "Hook installed: WebView textZoom (" + (int)(HookEnv.config.density() * 100) + "%)");
    }
}
