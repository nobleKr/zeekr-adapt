package com.dhuadapter;

import com.dhuadapter.core.TransformRegistry;
import com.dhuadapter.root.RootPathMatcher;
import com.dhuadapter.signature.CertReader;
import com.dhuadapter.sysprops.PropSpoofTable;

/**
 * Zero-dependency JVM test runner for the pure decision logic (no JUnit, no
 * android, no Pine). Runs on a bare JDK — see run-tests.sh / the GitHub CI
 * workflow. Exits non-zero if any assertion fails.
 *
 * Scope: only device-independent logic is covered here. The Pine hooks
 * themselves hook android.* framework classes and can only be exercised on a
 * device/emulator, so they are out of scope for JVM unit tests.
 */
public final class PureLogicTests {

    private static int passed = 0;
    private static int failed = 0;

    public static void main(String[] args) {
        testRootPathPositive();
        testRootPathNegative();
        testRootPathCaseInsensitive();
        testRootPathNullAndEdges();
        testRootProps();
        testEmulatorProps();
        testSpoofGateMatrix();
        testCertReader();
        testTransformRegistry();

        System.out.println();
        System.out.println("Tests: " + (passed + failed)
                + "  passed: " + passed + "  failed: " + failed);
        if (failed > 0) {
            System.out.println("RESULT: FAIL");
            System.exit(1);
        }
        System.out.println("RESULT: PASS");
    }

    // ── RootPathMatcher ──────────────────────────────────────────────────

    private static void testRootPathPositive() {
        String[] roots = {
                "/system/bin/su", "/system/xbin/su", "/sbin/su", "/su/bin/su",
                "/su/bin", "/system/xbin/daemonsu", "/system/xbin/busybox",
                "/data/local/tmp/magisk", "/system/app/Superuser.apk",
                "/system/app/SuperSU.apk", "/system/usr/we-need-root/su-backup",
        };
        for (String p : roots) {
            assertTrue("isRootPath positive: " + p, RootPathMatcher.isRootPath(p));
        }
    }

    private static void testRootPathNegative() {
        String[] clean = {
                "/data/data/com.spotify.music/databases/app.db",
                "/system/framework/framework.jar",
                "/data/app/com.apple.android.music/base.apk",
                "/sdcard/Download/track.mp3",
                "/proc/self/maps",
                "/system/lib64/libc.so",
                "normal_file.txt",
                "",
        };
        for (String p : clean) {
            assertFalse("isRootPath negative: " + p, RootPathMatcher.isRootPath(p));
        }
    }

    private static void testRootPathCaseInsensitive() {
        assertTrue("case: /System/XBin/SU", RootPathMatcher.isRootPath("/System/XBin/SU"));
        assertTrue("case: MAGISK", RootPathMatcher.isRootPath("/data/MAGISK/x"));
        assertTrue("case: SuperSU", RootPathMatcher.isRootPath("/x/SuperSU/y"));
        assertTrue("case: BusyBox", RootPathMatcher.isRootPath("/x/BusyBox"));
    }

    private static void testRootPathNullAndEdges() {
        assertFalse("null path is not root (no NPE)", RootPathMatcher.isRootPath(null));
        // needle longer than haystack must not throw / must be false
        assertFalse("short haystack", RootPathMatcher.containsIgnoreCase("s", "superuser"));
        assertTrue("exact needle", RootPathMatcher.containsIgnoreCase("magisk", "magisk"));
    }

    // ── PropSpoofTable ───────────────────────────────────────────────────

    private static void testRootProps() {
        assertEq("ro.build.tags", "release-keys", PropSpoofTable.rootProp("ro.build.tags"));
        assertEq("ro.build.type", "user", PropSpoofTable.rootProp("ro.build.type"));
        assertEq("ro.debuggable", "0", PropSpoofTable.rootProp("ro.debuggable"));
        assertEq("ro.secure", "1", PropSpoofTable.rootProp("ro.secure"));
        assertEq("ro.build.selinux", "1", PropSpoofTable.rootProp("ro.build.selinux"));
        assertEq("ro.bootmode", "unknown", PropSpoofTable.rootProp("ro.bootmode"));
        assertEq("init.svc.magisk", "", PropSpoofTable.rootProp("init.svc.magisk"));
        assertEq("init.svc.su", "", PropSpoofTable.rootProp("init.svc.su"));
        // emulator/unknown keys are NOT root props
        assertNull("rootProp ro.kernel.qemu", PropSpoofTable.rootProp("ro.kernel.qemu"));
        assertNull("rootProp unknown", PropSpoofTable.rootProp("ro.something.else"));
        assertNull("rootProp null", PropSpoofTable.rootProp(null));
    }

    private static void testEmulatorProps() {
        assertEq("ro.kernel.qemu", "0", PropSpoofTable.emulatorProp("ro.kernel.qemu"));
        assertEq("ro.kernel.qemu.gles", "0", PropSpoofTable.emulatorProp("ro.kernel.qemu.gles"));
        assertEq("ro.hardware", "redfin", PropSpoofTable.emulatorProp("ro.hardware"));
        assertEq("ro.product.model", "Pixel 5", PropSpoofTable.emulatorProp("ro.product.model"));
        assertEq("ro.product.manufacturer", "Google", PropSpoofTable.emulatorProp("ro.product.manufacturer"));
        assertEq("ro.product.brand", "google", PropSpoofTable.emulatorProp("ro.product.brand"));
        assertEq("ro.product.device", "redfin", PropSpoofTable.emulatorProp("ro.product.device"));
        // any qemu/goldfish/ranchu/genym/vbox substring → empty
        assertEq("contains qemu", "", PropSpoofTable.emulatorProp("init.svc.qemud"));
        assertEq("contains goldfish", "", PropSpoofTable.emulatorProp("ro.boot.goldfish.x"));
        assertEq("contains ranchu", "", PropSpoofTable.emulatorProp("ro.ranchu.foo"));
        assertEq("contains genym", "", PropSpoofTable.emulatorProp("ro.genymotion.version"));
        assertEq("contains vbox", "", PropSpoofTable.emulatorProp("ro.vbox86.thing"));
        // root/unknown keys are NOT emulator props
        assertNull("emulatorProp ro.build.tags", PropSpoofTable.emulatorProp("ro.build.tags"));
        assertNull("emulatorProp unknown", PropSpoofTable.emulatorProp("persist.sys.timezone"));
        assertNull("emulatorProp null", PropSpoofTable.emulatorProp(null));
    }

    private static void testSpoofGateMatrix() {
        // neither gate → never spoof
        assertNull("gate off: tags", PropSpoofTable.spoof(false, false, "ro.build.tags"));
        assertNull("gate off: qemu", PropSpoofTable.spoof(false, false, "ro.kernel.qemu"));
        // root only
        assertEq("root on: tags", "release-keys", PropSpoofTable.spoof(true, false, "ro.build.tags"));
        assertNull("root on: qemu (emulator key)", PropSpoofTable.spoof(true, false, "ro.kernel.qemu"));
        // emulator only
        assertEq("emu on: qemu", "0", PropSpoofTable.spoof(false, true, "ro.kernel.qemu"));
        assertNull("emu on: tags (root key)", PropSpoofTable.spoof(false, true, "ro.build.tags"));
        // both on
        assertEq("both: tags", "release-keys", PropSpoofTable.spoof(true, true, "ro.build.tags"));
        assertEq("both: qemu", "0", PropSpoofTable.spoof(true, true, "ro.kernel.qemu"));
        assertNull("both: unknown", PropSpoofTable.spoof(true, true, "persist.sys.timezone"));
        assertNull("both: null key", PropSpoofTable.spoof(true, true, null));
    }

    // ── CertReader (signature spoof helper) ──────────────────────────────

    // A throwaway self-signed X.509 cert (DER, base64) generated for tests only.
    // Its SHA-256 is fixed, so we can assert the digest logic exactly.
    private static final String TEST_CERT_B64 =
            "MIIDATCCAemgAwIBAgIIRR3AqdLKy0cwDQYJKoZIhvcNAQEMBQAwLzEZMBcGA1UEChMQemVla3"
          + "ItYWRhcHQtdGVzdDESMBAGA1UEAxMJVGVzdCBDZXJ0MB4XDTI2MDkxMTE2MTY1MVoXDTM2MDkw"
          + "ODE2MTY1MVowLzEZMBcGA1UEChMQemVla3ItYWRhcHQtdGVzdDESMBAGA1UEAxMJVGVzdCBDZX"
          + "J0MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAwayJU82P7InKdmH4RL/vtvZSKi1S"
          + "Weja1ckREPmue8hZT9O8eCWh65VltxJjLMHqNACuETWNW50ejWG2MnxiN9/4WibV+HXzd/bN8v"
          + "jPFEn6tzt2ccFJlalTY+/Q7PG39gM6ZKuaaPgZnp/xyd3KYpTSXABjKr00+g32qBKNxuwyLNK5"
          + "iCH/+RgVDl/FLkceTVjddQG7wbDtIx7Z1q60naxSAN/Z0WuUK+WXQaTmOb8fK1w7SvIm9Bc2/0"
          + "ja1+4IwneE4CqjaZB3jzZscGNib63IIAJrZ24FpGxdTyVpJQagFdtrk0GlTJ8qBexUkhdOCUoG"
          + "EAI9z6RXRpqzFOyz5QIDAQABoyEwHzAdBgNVHQ4EFgQUFnyoLrJuMEY4794vzFMqLftI5rwwDQ"
          + "YJKoZIhvcNAQEMBQADggEBAF8NTVEj3YWajQHTnSpN5D/kf8PicVfNtFEFvofEf3BgC4qROfR3"
          + "xx3a/KI/R6TmsR3MWH5buMmUZgk3qSSRod6cZv2hPGMcSSbe2IOQNtfmp9QaSJNfOJ76CcPBrp"
          + "TNBKGJPrXxOV+CzYSlATazKkxy+AvMnx2ACPtBYghTmVz5dEVwcVEJlK9iDAz7iNVQ9V3JPtip"
          + "51q1fczRi9zzFF2rI+0dpewqov0p5eYgI5aQV8rBpPVWTsVq3F4bI7XvsJolORolgGnLEQxA1Y"
          + "EptUPvhRZf/3Rc6AcmeeXtmz7Hamn3Deepy+SSJC0eax81B4daSNfM2uEnXZ+zv9pBZJA=";
    private static final String TEST_CERT_SHA256 =
            "e35bb4a5d47bd80625ce3a52e8a5ac415f26ce4d3eb114d44db44af525c045db";

    private static void testCertReader() {
        byte[] der = java.util.Base64.getDecoder().decode(TEST_CERT_B64);
        // parse a valid X.509 DER
        assertTrue("CertReader.parse valid X.509", CertReader.parse(der) != null);
        // SHA-256 of the DER equals the known cert digest
        assertEq("CertReader.sha256Hex(der)", TEST_CERT_SHA256, CertReader.sha256Hex(der));
        // garbage is not a cert, and helpers are null-safe (no throw)
        assertTrue("CertReader.parse(garbage)=null",
                CertReader.parse(new byte[]{1, 2, 3, 4, 5}) == null);
        assertTrue("CertReader.parse(null)=null", CertReader.parse(null) == null);
        assertTrue("CertReader.parse(empty)=null", CertReader.parse(new byte[0]) == null);
        assertNull("CertReader.sha256Hex(null)", CertReader.sha256Hex(null));
        // digest is stable / lowercase hex of correct length
        assertTrue("sha256 length 64", CertReader.sha256Hex(der).length() == 64);
    }

    // ── TransformRegistry (SharedHooks compositing core) ─────────────────

    // A tiny mutable stand-in for android.content.res.Configuration.
    private static final class Cfg {
        int uiMode;
        int densityDpi;
    }

    private static void testTransformRegistry() {
        // ordering: transforms run in registration order
        TransformRegistry<StringBuilder> ord = new TransformRegistry<>();
        ord.register("k", sb -> sb.append("A"));
        ord.register("k", sb -> sb.append("B"));
        ord.register("k", sb -> sb.append("C"));
        StringBuilder sb = new StringBuilder();
        ord.apply("k", sb);
        assertEq("registry applies in order", "ABC", sb.toString());

        // count / has / unknown key
        assertTrue("has(k)", ord.has("k"));
        assertEq("count(k)=3", "3", String.valueOf(ord.count("k")));
        assertFalse("has(missing)", ord.has("nope"));
        assertEq("count(missing)=0", "0", String.valueOf(ord.count("nope")));
        // apply on unknown key is a no-op (no throw)
        ord.apply("nope", new StringBuilder());

        // null key / null transform are ignored (no throw, not registered)
        ord.register(null, s -> s.append("X"));
        ord.register("k2", null);
        assertFalse("null transform not registered", ord.has("k2"));

        // isolation: a throwing transform is skipped, others still run
        TransformRegistry<StringBuilder> iso = new TransformRegistry<>();
        iso.register("k", s -> s.append("1"));
        iso.register("k", s -> { throw new RuntimeException("boom"); });
        iso.register("k", s -> s.append("2"));
        StringBuilder r = new StringBuilder();
        iso.apply("k", r);
        assertEq("throwing transform isolated", "12", r.toString());

        // the real SharedHooks use case: Cat.1 density + Cat.4 deCar on ONE target,
        // composited in order onto one Configuration-like object.
        TransformRegistry<Cfg> cfgReg = new TransformRegistry<>();
        final int CONFIG_DPI = 240;
        // Cat.4 deCar: UI_MODE_TYPE_CAR(3) → NORMAL(1)
        cfgReg.register("updateFrom", c -> c.uiMode = (c.uiMode & ~0x0F) | 1);
        // Cat.1 density
        cfgReg.register("updateFrom", c -> c.densityDpi = CONFIG_DPI);
        Cfg cfg = new Cfg();
        cfg.uiMode = 0x03;        // UI_MODE_TYPE_CAR
        cfg.densityDpi = 160;
        cfgReg.apply("updateFrom", cfg);
        assertEq("shared updateFrom → deCar applied", "1", String.valueOf(cfg.uiMode & 0x0F));
        assertEq("shared updateFrom → density applied", "240", String.valueOf(cfg.densityDpi));
        assertEq("two categories on one target", "2", String.valueOf(cfgReg.count("updateFrom")));

        // SystemProperties.get resolver semantics (SharedHooks.resolveSysProp):
        // ordered list of key→value functions, first non-null wins, bad resolver isolated.
        java.util.List<java.util.function.Function<String,String>> resolvers = new java.util.ArrayList<>();
        resolvers.add(k -> "ro.build.tags".equals(k) ? "release-keys" : null);   // root
        resolvers.add(k -> k.contains("qemu") ? "0" : null);                     // emulator
        assertEq("resolver: root key", "release-keys", firstNonNull(resolvers, "ro.build.tags"));
        assertEq("resolver: emulator key", "0", firstNonNull(resolvers, "ro.kernel.qemu"));
        assertNull("resolver: unknown key", firstNonNull(resolvers, "persist.sys.timezone"));
        // a throwing resolver is skipped, later resolver still wins
        java.util.List<java.util.function.Function<String,String>> withBad = new java.util.ArrayList<>();
        withBad.add(k -> { throw new RuntimeException("boom"); });
        withBad.add(k -> "x".equals(k) ? "ok" : null);
        assertEq("resolver: throwing skipped", "ok", firstNonNull(withBad, "x"));
    }

    // Mirror of SharedHooks.resolveSysProp (first non-null wins, isolate throwers).
    private static String firstNonNull(
            java.util.List<java.util.function.Function<String,String>> rs, String key) {
        for (java.util.function.Function<String,String> r : rs) {
            try { String v = r.apply(key); if (v != null) return v; }
            catch (Throwable ignored) {}
        }
        return null;
    }

    // ── tiny assertion helpers ───────────────────────────────────────────

    private static void assertTrue(String name, boolean cond) {
        record(name, cond, "expected true");
    }

    private static void assertFalse(String name, boolean cond) {
        record(name, !cond, "expected false");
    }

    private static void assertEq(String name, String expected, String actual) {
        boolean ok = expected == null ? actual == null : expected.equals(actual);
        record(name, ok, "expected [" + expected + "] got [" + actual + "]");
    }

    private static void assertNull(String name, String actual) {
        record(name, actual == null, "expected null got [" + actual + "]");
    }

    private static void record(String name, boolean ok, String detail) {
        if (ok) {
            passed++;
        } else {
            failed++;
            System.out.println("FAIL: " + name + " — " + detail);
        }
    }
}
