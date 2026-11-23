package com.mizan.app

import android.app.Service
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.graphics.PixelFormat
import android.graphics.drawable.GradientDrawable
import android.os.Build
import android.os.IBinder
import android.view.*
import android.widget.FrameLayout
import android.widget.TextView
import kotlin.math.abs

/**
 * FloatingCompanionOverlayService
 *
 * Manages the bounded system-level floating companion ("Nūr") that rests on screen edges,
 * responds to touch & tap with expressive chimes, and alerts 10m before Salah.
 */
class FloatingCompanionOverlayService : Service() {

    private var windowManager: WindowManager? = null
    private var overlayView: FrameLayout? = null
    private var params: WindowManager.LayoutParams? = null
    private val audioManager by lazy { CompanionAudioPoolManager.getInstance(this) }

    private var initialX = 0
    private var initialY = 0
    private var initialTouchX = 0f
    private var initialTouchY = 0f
    private var isHiding = false

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        windowManager = getSystemService(Context.WINDOW_SERVICE) as WindowManager
        initOverlayView()
    }

    private fun initOverlayView() {
        val badge = TextView(this).apply {
            text = "🏮"
            textSize = 24f
            gravity = Gravity.CENTER
        }
        val bg = GradientDrawable().apply {
            shape = GradientDrawable.OVAL
            setColor(Color.parseColor("#E6071D17"))
            setStroke(3, Color.parseColor("#F59E0B"))
        }
        val container = FrameLayout(this).apply {
            background = bg
            setPadding(24, 24, 24, 24)
            addView(badge)
        }
        overlayView = container

        val layoutFlag = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
        } else {
            @Suppress("DEPRECATION")
            WindowManager.LayoutParams.TYPE_PHONE
        }

        params = WindowManager.LayoutParams(
            148,
            148,
            layoutFlag,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP or Gravity.START
            x = 40
            y = 320
        }

        container.setOnTouchListener { _, event ->
            when (event.action) {
                MotionEvent.ACTION_DOWN -> {
                    initialX = params!!.x
                    initialY = params!!.y
                    initialTouchX = event.rawX
                    initialTouchY = event.rawY
                    true
                }
                MotionEvent.ACTION_MOVE -> {
                    params!!.x = initialX + (event.rawX - initialTouchX).toInt()
                    params!!.y = initialY + (event.rawY - initialTouchY).toInt()
                    windowManager?.updateViewLayout(overlayView, params)
                    true
                }
                MotionEvent.ACTION_UP -> {
                    val diffX = abs(event.rawX - initialTouchX)
                    val diffY = abs(event.rawY - initialTouchY)
                    if (diffX < 10 && diffY < 10) {
                        onPetCompanion()
                    } else {
                        snapToNearestEdge()
                    }
                    true
                }
                else -> false
            }
        }

        windowManager?.addView(overlayView, params)
        audioManager.playRestingPurr()
    }

    private fun onPetCompanion() {
        audioManager.playWaterDropTap()
        overlayView?.animate()
            ?.scaleX(1.2f)?.scaleY(1.2f)
            ?.setDuration(150)
            ?.withEndAction {
                overlayView?.animate()?.scaleX(1.0f)?.scaleY(1.0f)?.setDuration(150)?.start()
            }?.start()
    }

    private fun snapToNearestEdge() {
        val screenWidth = resources.displayMetrics.widthPixels
        val w = overlayView?.width ?: 148
        val targetX = if (params!!.x + w / 2 < screenWidth / 2) 20 else screenWidth - w - 20
        params!!.x = targetX
        windowManager?.updateViewLayout(overlayView, params)
        audioManager.playRestingPurr()
    }

    fun onSalahApproaching() {
        val screenWidth = resources.displayMetrics.widthPixels
        val w = overlayView?.width ?: 148
        params?.x = (screenWidth / 2) - (w / 2)
        params?.y = 200
        windowManager?.updateViewLayout(overlayView, params)
        audioManager.playSalah10mBell()
    }

    fun togglePeekABoo() {
        isHiding = !isHiding
        if (isHiding) {
            params?.x = -60
            audioManager.playMarimbaTick()
            windowManager?.updateViewLayout(overlayView, params)
        } else {
            snapToNearestEdge()
            audioManager.playPeekGlissando()
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        if (overlayView != null) {
            windowManager?.removeView(overlayView)
            overlayView = null
        }
    }
}
