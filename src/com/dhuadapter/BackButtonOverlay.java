package com.dhuadapter;

import android.app.Activity;
import android.content.Context;
import android.content.SharedPreferences;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.PixelFormat;
import android.graphics.drawable.Drawable;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import android.view.Gravity;
import android.view.MotionEvent;
import android.view.View;
import android.view.WindowManager;
import android.widget.FrameLayout;

/**
 * Draggable floating back button overlay for DHU.
 *
 * - Tap = onBackPressed()
 * - Long press (2s hold) = toggle visibility
 * - Drag to reposition, persisted in SharedPreferences
 */
public class BackButtonOverlay {

    private static final String TAG = "DhuAdapter";
    private static final String PREFS_NAME = "DhuAdapterPrefs";
    private static final String KEY_X = "back_btn_x";
    private static final String KEY_Y = "back_btn_y";
    private static final String KEY_VISIBLE = "back_btn_visible";
    private static final long LONG_PRESS_MS = 2000;

    private View overlayView;
    private WindowManager windowManager;
    private WindowManager.LayoutParams layoutParams;
    private SharedPreferences prefs;
    private boolean visible = true;
    private final int sizePx;
    private final float alpha;

    public BackButtonOverlay(int sizeDp, float alpha) {
        // Will be converted to px at attach time
        this.sizePx = sizeDp; // stored as dp, converted later
        this.alpha = alpha;
    }

    /**
     * Attach the overlay to the given activity's window.
     */
    public void attach(Activity activity) {
        try {
            float density = activity.getResources().getDisplayMetrics().density;
            int sizePxActual = (int) (sizePx * density);

            prefs = activity.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE);
            visible = prefs.getBoolean(KEY_VISIBLE, true);

            windowManager = (WindowManager) activity.getSystemService(Context.WINDOW_SERVICE);

            overlayView = new BackButtonView(activity, sizePxActual);
            overlayView.setAlpha(alpha);

            int savedX = prefs.getInt(KEY_X, 200);
            int savedY = prefs.getInt(KEY_Y, 200);

            layoutParams = new WindowManager.LayoutParams(
                    sizePxActual,
                    sizePxActual,
                    WindowManager.LayoutParams.TYPE_APPLICATION,
                    WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE
                            | WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL,
                    PixelFormat.TRANSLUCENT
            );
            layoutParams.gravity = Gravity.TOP | Gravity.START;
            layoutParams.x = savedX;
            layoutParams.y = savedY;

            setupTouchListener(activity, sizePxActual);

            if (visible) {
                windowManager.addView(overlayView, layoutParams);
            }

            if (Log.isLoggable(TAG, Log.DEBUG)) {
                Log.d(TAG, "BackButtonOverlay attached at (" + savedX + "," + savedY + ")");
            }
        } catch (Exception e) {
            Log.e(TAG, "Failed to attach BackButtonOverlay", e);
        }
    }

    /**
     * Remove the overlay from the window.
     *
     * addView() on a TYPE_APPLICATION window is queued asynchronously, so on a
     * short-lived activity (splash / UID onboarding) the view may still be
     * PENDING (isAttachedToWindow()==false) when the activity is destroyed.
     * Gating removeView on isAttachedToWindow() would then skip the removal and
     * leak the window (WindowLeaked BackButtonView). So we remove unconditionally
     * and use removeViewImmediate to tear it down synchronously before the
     * activity's own window token is gone.
     */
    public void detach() {
        try {
            if (overlayView != null && windowManager != null) {
                windowManager.removeViewImmediate(overlayView);
            }
        } catch (IllegalArgumentException notAttached) {
            // View was never actually added (addView failed / not yet queued) —
            // nothing to remove, safe to ignore.
        } catch (Exception e) {
            Log.e(TAG, "Failed to detach BackButtonOverlay", e);
        }
        overlayView = null;
        windowManager = null;
    }

    private void setupTouchListener(final Activity activity, int sizePxActual) {
        overlayView.setOnTouchListener(new View.OnTouchListener() {
            private float downX, downY;
            private int origX, origY;
            private boolean dragging = false;
            private boolean longPressed = false;
            private final Handler handler = new Handler(Looper.getMainLooper());
            private final Runnable longPressRunnable = new Runnable() {
                @Override
                public void run() {
                    longPressed = true;
                    toggleVisibility();
                }
            };

            @Override
            public boolean onTouch(View v, MotionEvent event) {
                switch (event.getActionMasked()) {
                    case MotionEvent.ACTION_DOWN:
                        downX = event.getRawX();
                        downY = event.getRawY();
                        origX = layoutParams.x;
                        origY = layoutParams.y;
                        dragging = false;
                        longPressed = false;
                        handler.postDelayed(longPressRunnable, LONG_PRESS_MS);
                        return true;

                    case MotionEvent.ACTION_MOVE:
                        float dx = event.getRawX() - downX;
                        float dy = event.getRawY() - downY;
                        if (Math.abs(dx) > 10 || Math.abs(dy) > 10) {
                            dragging = true;
                            handler.removeCallbacks(longPressRunnable);
                        }
                        if (dragging) {
                            layoutParams.x = origX + (int) dx;
                            layoutParams.y = origY + (int) dy;
                            try {
                                windowManager.updateViewLayout(overlayView, layoutParams);
                            } catch (Exception ignored) {}
                        }
                        return true;

                    case MotionEvent.ACTION_UP:
                        handler.removeCallbacks(longPressRunnable);
                        if (dragging) {
                            // Save position
                            prefs.edit()
                                    .putInt(KEY_X, layoutParams.x)
                                    .putInt(KEY_Y, layoutParams.y)
                                    .apply();
                        } else if (!longPressed) {
                            // Tap -> back
                            try {
                                activity.onBackPressed();
                            } catch (Exception e) {
                                Log.e(TAG, "onBackPressed failed", e);
                            }
                        }
                        return true;

                    case MotionEvent.ACTION_CANCEL:
                        handler.removeCallbacks(longPressRunnable);
                        return true;
                }
                return false;
            }
        });
    }

    private void toggleVisibility() {
        try {
            visible = !visible;
            prefs.edit().putBoolean(KEY_VISIBLE, visible).apply();
            if (visible) {
                if (!overlayView.isAttachedToWindow()) {
                    windowManager.addView(overlayView, layoutParams);
                }
                overlayView.setVisibility(View.VISIBLE);
            } else {
                overlayView.setVisibility(View.GONE);
            }
            Log.i(TAG, "BackButton visibility toggled: " + visible);
        } catch (Exception e) {
            Log.e(TAG, "toggleVisibility failed", e);
        }
    }

    // ---- Custom Drawable rendered on Canvas ----

    private static class BackButtonView extends View {

        private final Paint circlePaint;
        private final Paint arrowPaint;
        private final int sizePx;

        BackButtonView(Context context, int sizePx) {
            super(context);
            this.sizePx = sizePx;

            circlePaint = new Paint(Paint.ANTI_ALIAS_FLAG);
            circlePaint.setColor(0xFF4CAF50); // Material Green 500
            circlePaint.setStyle(Paint.Style.FILL);

            arrowPaint = new Paint(Paint.ANTI_ALIAS_FLAG);
            arrowPaint.setColor(Color.WHITE);
            arrowPaint.setStyle(Paint.Style.STROKE);
            arrowPaint.setStrokeWidth(sizePx * 0.08f);
            arrowPaint.setStrokeCap(Paint.Cap.ROUND);
            arrowPaint.setStrokeJoin(Paint.Join.ROUND);
        }

        @Override
        protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
            setMeasuredDimension(sizePx, sizePx);
        }

        @Override
        protected void onDraw(Canvas canvas) {
            super.onDraw(canvas);
            float cx = sizePx / 2f;
            float cy = sizePx / 2f;
            float radius = sizePx / 2f - 2f;

            // Green circle
            canvas.drawCircle(cx, cy, radius, circlePaint);

            // White back arrow  <-
            float arrowLen = sizePx * 0.3f;
            float headLen = sizePx * 0.15f;

            // Shaft: from right to left
            float startX = cx + arrowLen / 2f;
            float endX = cx - arrowLen / 2f;
            canvas.drawLine(startX, cy, endX, cy, arrowPaint);

            // Arrowhead
            Path head = new Path();
            head.moveTo(endX + headLen, cy - headLen);
            head.lineTo(endX, cy);
            head.lineTo(endX + headLen, cy + headLen);
            canvas.drawPath(head, arrowPaint);
        }
    }
}
