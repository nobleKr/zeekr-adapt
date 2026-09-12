package com.dhuadapter;

import android.app.AppComponentFactory;
import android.app.Application;
import android.os.Build;
import android.util.Log;

import com.dhuadapter.automotive.AutomotiveHooks;
import com.dhuadapter.capture.CaptureHooks;
import com.dhuadapter.core.HookEnv;
import com.dhuadapter.display.DisplayHooks;
import com.dhuadapter.display.LifecycleHooks;
import com.dhuadapter.emulator.EmulatorBypass;
import com.dhuadapter.mediabridge.MediaSessionHooks;
import com.dhuadapter.network.NetworkBypass;
import com.dhuadapter.network.SimGate;
import com.dhuadapter.root.RootBypass;
import com.dhuadapter.signature.SignatureSpoof;
import com.dhuadapter.sysprops.SystemPropertiesSpoof;

import top.canyie.pine.PineConfig;

/**
 * DHU Adapter — AppComponentFactory that hooks Android internals via Pine to
 * adapt phone apps for an Android 12 DHU (2560×1600 @ 160dpi → target 280dpi).
 *
 * No root, no Xposed, no native code — pure Java + Pine inline hooking.
 *
 * This class is a thin ORCHESTRATOR: it loads the embedded config, populates
 * {@link HookEnv}, then calls each feature category's installer. Every hook
 * lives in its own package (display / capture / automotive / root / emulator /
 * sysprops / network / mediabridge), gated by an explicit config flag. Only
 * Category 1 (Display/UI) is ON by default.
 *
 * Declare in AndroidManifest.xml:
 *   <application android:appComponentFactory="com.dhuadapter.DhuAdapterFactory" ...>
 */
public class DhuAdapterFactory extends AppComponentFactory {

    private static final String TAG = "DhuAdapter";

    // APK path captured in instantiateClassLoader (fires before
    // instantiateApplication) so we can read the embedded config from the APK
    // zip directly — Application.getAssets() isn't usable that early.
    private static String apkSourceDir;

    @Override
    public ClassLoader instantiateClassLoader(ClassLoader cl,
            android.content.pm.ApplicationInfo aInfo) {
        try {
            if (aInfo != null && aInfo.sourceDir != null) {
                apkSourceDir = aInfo.sourceDir;
            }
        } catch (Throwable t) {
            // best-effort
        }
        return super.instantiateClassLoader(cl, aInfo);
    }

    // ────────────────────────────────────────────────────────────────
    //  Entry point — called BEFORE Application.onCreate()
    // ────────────────────────────────────────────────────────────────

    @Override
    public Application instantiateApplication(ClassLoader cl, String className)
            throws InstantiationException, IllegalAccessException, ClassNotFoundException {

        Log.i(TAG, "=== DHU Adapter initializing (pre-Application) ===");
        Log.i(TAG, "Build: " + Build.DISPLAY + ", SDK " + Build.VERSION.SDK_INT);

        // Create the real Application FIRST so we have a Context to read the
        // embedded assets/dhu-adapter-config.json. Application.onCreate has NOT
        // run yet (it fires after instantiateApplication returns), so installing
        // hooks after this point is still "pre-onCreate" — no behavior change,
        // but now config is the real embedded one, not defaults.
        Application app = super.instantiateApplication(cl, className);

        // Populate the shared hook environment (approach A: static holder).
        HookEnv.appContext = app;
        HookEnv.classLoader = getClass().getClassLoader();
        HookEnv.apkSourceDir = apkSourceDir;
        // Read the embedded config from the APK zip directly (apkSourceDir was
        // captured in instantiateClassLoader). Application.getAssets() isn't
        // usable this early, so we don't rely on it.
        HookEnv.config = DhuConfig.loadFromApk(apkSourceDir);
        DhuConfig config = HookEnv.config;

        // Pine init — PineConfig.debug MUST stay false. It enables Pine's own
        // INTERNAL logging, which formats every bridged call via String.format;
        // that initialises the locale → TimeZone.getDefault() →
        // SystemProperties.get("persist.sys.timezone"), which we hook, so Pine.log
        // re-enters the hook → unbounded recursion → SIGSEGV (the Telegram crash).
        // false breaks the cycle; debuggable (hook/JIT mechanics only, no logging)
        // still tracks config.debug.
        PineConfig.debug = false;
        PineConfig.debuggable = config.debug;

        Log.i(TAG, "Density mode: metricsDpi=" + config.metricsDpi
                + " configDpi=" + config.configDpi);

        // ── Category 1: Display / UI (default ON; --no-display to disable) ──
        if (config.display) {
            DisplayHooks.install();
        } else {
            Log.i(TAG, "Display/UI category disabled (config.display=false)");
        }
        // ── Category 7: Capture (gate: config.allowCapture) ──
        CaptureHooks.install();
        // ── Category 6: MediaCenter (gate: config.mediaBridge) ──
        MediaSessionHooks.install();
        // ── Category 4: Automotive (gate: config.automotiveFix) ──
        AutomotiveHooks.install();
        // ── Category 2: Root bypass (gate: config.rootBypass) ──
        RootBypass.install();
        // ── Category 3: Emulator bypass (gate: config.emulatorBypass) ──
        EmulatorBypass.install();
        // ── Categories 2+3 shared: SystemProperties spoof (root||emulator) ──
        SystemPropertiesSpoof.install();
        // ── Category 5a: Network systemic bypass (gate: config.networkBypass) ──
        NetworkBypass.install();
        // ── Category 5b: SIM-gate (gate: config.simReady) ──
        SimGate.install();
        // ── Category 9: Signature spoof (gate: config.copySign) ──
        SignatureSpoof.install();

        // Install shared framework hooks ONCE, after every category has registered
        // its transforms (e.g. Configuration.updateFrom: Cat.1 density + Cat.4 deCar).
        com.dhuadapter.core.SharedHooks.installAll();

        Log.i(TAG, "All hooks installed (two-DPI: render "
                + config.metricsDpi + " / layout " + config.configDpi + ")");

        // ── Category 1 (window chrome): fullscreen + rounded corners + back button ──
        if (config.display) {
            LifecycleHooks.register(app);
        }
        return app;
    }
}
