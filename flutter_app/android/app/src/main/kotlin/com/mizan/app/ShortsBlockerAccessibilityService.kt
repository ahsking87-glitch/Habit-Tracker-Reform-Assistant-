package com.mizan.app

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.AccessibilityServiceInfo
import android.content.Intent
import android.os.SystemClock
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo

/**
 * Mīzān Ethical Accessibility Service
 * Purpose: Detects short-form algorithmic video streams (YouTube Shorts, Instagram Reels, TikTok)
 * Strictly local-only. Zero network transmission. Zero keystroke logging.
 */
class ShortsBlockerAccessibilityService : AccessibilityService() {

    private var lastTriggerTimestamp = 0L
    private val debounceCooldownMs = 3000L

    companion object {
        const val PKG_YOUTUBE = "com.google.android.youtube"
        const val PKG_INSTAGRAM = "com.instagram.android"
        const val PKG_TIKTOK = "com.zhiliaoapp.musically"
        const val PKG_TIKTOK_LITE = "com.zhiliaoapp.musically.go"

        val REELS_VIEW_IDS = listOf(
            "com.instagram.android:id/reel_viewer_root",
            "com.instagram.android:id/clips_viewer_view_pager",
            "com.instagram.android:id/clips_video_container",
            "com.google.android.youtube:id/shorts_container",
            "com.google.android.youtube:id/reel_recycler"
        )
    }

    override fun onServiceConnected() {
        super.onServiceConnected()
        val info = AccessibilityServiceInfo().apply {
            eventTypes = AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED or
                         AccessibilityEvent.TYPE_VIEW_SCROLLED or
                         AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED
            feedbackType = AccessibilityServiceInfo.FEEDBACK_GENERIC
            flags = AccessibilityServiceInfo.FLAG_INCLUDE_NOT_IMPORTANT_VIEWS or
                    AccessibilityServiceInfo.FLAG_REPORT_VIEW_IDS
            packageNames = arrayOf(PKG_YOUTUBE, PKG_INSTAGRAM, PKG_TIKTOK, PKG_TIKTOK_LITE)
            notificationTimeout = 100
        }
        serviceInfo = info
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null) return
        val packageName = event.packageName?.toString() ?: return

        val now = SystemClock.elapsedRealtime()
        if (now - lastTriggerTimestamp < debounceCooldownMs) return

        val rootNode = rootInActiveWindow ?: return

        if (detectShortFormContent(rootNode, packageName)) {
            lastTriggerTimestamp = now
            triggerOverlayShield(packageName)
        }
    }

    private fun detectShortFormContent(root: AccessibilityNodeInfo, packageName: String): Boolean {
        for (viewId in REELS_VIEW_IDS) {
            val matchingNodes = root.findAccessibilityNodeInfosByViewId(viewId)
            if (matchingNodes.isNotEmpty()) return true
        }

        val shortsTextMatches = root.findAccessibilityNodeInfosByText("Shorts")
        if (shortsTextMatches.isNotEmpty() && packageName == PKG_YOUTUBE) {
            for (node in shortsTextMatches) {
                if (node.isSelected || node.isFocused || node.parent?.isSelected == true) return true
            }
        }

        val reelsTextMatches = root.findAccessibilityNodeInfosByText("Reels")
        if (reelsTextMatches.isNotEmpty() && packageName == PKG_INSTAGRAM) {
            for (node in reelsTextMatches) {
                if (node.isSelected || node.parent?.isSelected == true) return true
            }
        }

        return false
    }

    private fun triggerOverlayShield(blockedPackage: String) {
        val intent = Intent(this, FocusOverlayService::class.java).apply {
            putExtra("EXTRA_BLOCKED_APP", blockedPackage)
            putExtra("EXTRA_TRIGGER_REASON", "SHORT_FORM_DETECTED")
        }
        startService(intent)
    }

    override fun onInterrupt() {}
}
