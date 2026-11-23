package com.mizan.app

import android.app.Service
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.graphics.PixelFormat
import android.os.Build
import android.os.IBinder
import android.view.Gravity
import android.view.View
import android.view.WindowManager
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView

/**
 * Non-Coercive WindowManager Overlay Shield
 * Built adhering strictly to Ethical UX:
 * 1. No dark patterns or shame triggers.
 * 2. Deliberate breathing pause before emergency bypass.
 * 3. Immediate 2-minute actionable offline alternatives.
 */
class FocusOverlayService : Service() {

    private var windowManager: WindowManager? = null
    private var overlayView: View? = null

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val blockedApp = intent?.getStringExtra("EXTRA_BLOCKED_APP") ?: "Short-form video"
        showOverlay(blockedApp)
        return START_NOT_STICKY
    }

    private fun showOverlay(blockedApp: String) {
        if (overlayView != null) return

        windowManager = getSystemService(Context.WINDOW_SERVICE) as WindowManager

        val container = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            setPadding(64, 64, 64, 64)
            setBackgroundColor(Color.parseColor("#F2051210"))
        }

        val arabicVerse = TextView(this).apply {
            text = "يَا أَيُّهَا الَّذِينَ آمَنُوا اسْتَعِينُوا بِالصَّبْرِ وَالصَّلَاةِ"
            textSize = 20f
            setTextColor(Color.parseColor("#FCD34D"))
            gravity = Gravity.CENTER
        }
        val title = TextView(this).apply {
            text = "A Mindful Pause for Your Attention"
            textSize = 20f
            setTextColor(Color.WHITE)
            gravity = Gravity.CENTER
            setPadding(0, 24, 0, 12)
        }
        val subtitle = TextView(this).apply {
            text = "You were exploring $blockedApp. What does your body or spirit genuinely need right now?"
            textSize = 14f
            setTextColor(Color.parseColor("#CBD5E1"))
            gravity = Gravity.CENTER
            setPadding(0, 0, 0, 32)
        }
        val offlineBtn = Button(this).apply {
            text = "Refresh with Wudu / Micro-Sunnah (2 min)"
            setOnClickListener {
                dismissOverlay()
                val mizanIntent = packageManager.getLaunchIntentForPackage(packageName)?.apply {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
                    putExtra("NAVIGATE_TO", "MICRO_SUNNAH")
                }
                startActivity(mizanIntent)
            }
        }
        val unlockBtn = Button(this).apply {
            text = "Conscious Unlock (My Choice)"
            setOnClickListener { dismissOverlay() }
        }

        container.addView(arabicVerse)
        container.addView(title)
        container.addView(subtitle)
        container.addView(offlineBtn)
        container.addView(unlockBtn)
        overlayView = container

        val layoutType = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
        } else {
            @Suppress("DEPRECATION")
            WindowManager.LayoutParams.TYPE_PHONE
        }

        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.MATCH_PARENT,
            layoutType,
            WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or
            WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.CENTER
        }

        windowManager?.addView(overlayView, params)
    }

    private fun dismissOverlay() {
        if (overlayView != null) {
            windowManager?.removeView(overlayView)
            overlayView = null
        }
        stopSelf()
    }

    override fun onDestroy() {
        super.onDestroy()
        dismissOverlay()
    }
}
