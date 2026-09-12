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
    }

    // Category 1 contribution to the SHARED Configuration.updateFrom hook: force
    // configDpi so a system config update doesn't override our layout density.
    // Registered via SharedHooks (single hook shared with Category 4's deCar) —
    // NOT a second Pine hook on updateFrom.
    private static void installConfigUpdateFromDensity() {
        com.dhuadapter.core.SharedHooks.registerConfigTransform(
                com.dhuadapter.core.SharedHooks.CONFIG_UPDATE_FROM,
                cfg -> cfg.densityDpi = HookEnv.config.configDpi);
        Log.i(TAG, "Registered: Configuration.updateFrom densityDpi (via SharedHooks)");
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
                cfg.densityDpi = HookEnv.config.configDpi;
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
                cfg -> cfg.densityDpi = HookEnv.config.configDpi);
        Log.i(TAG, "Registered: Resources.getConfiguration densityDpi (via SharedHooks)");
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
