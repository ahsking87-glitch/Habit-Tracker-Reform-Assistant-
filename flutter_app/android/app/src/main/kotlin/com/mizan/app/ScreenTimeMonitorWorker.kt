package com.mizan.app

import android.app.usage.UsageStatsManager
import android.content.Context
import androidx.work.CoroutineWorker
import androidx.work.WorkerParameters
import java.util.Calendar

/**
 * Periodic screen time auditing via UsageStatsManager
 * Runs every 15 minutes to evaluate daily distraction budget locally
 */
class ScreenTimeMonitorWorker(
    appContext: Context,
    workerParams: WorkerParameters
) : CoroutineWorker(appContext, workerParams) {

    override suspend fun doWork(): Result {
        val usageStatsManager =
            applicationContext.getSystemService(Context.USAGE_STATS_SERVICE) as? UsageStatsManager
                ?: return Result.failure()

        val calendar = Calendar.getInstance().apply {
            set(Calendar.HOUR_OF_DAY, 0)
            set(Calendar.MINUTE, 0)
            set(Calendar.SECOND, 0)
        }
        val startOfDay = calendar.timeInMillis
        val now = System.currentTimeMillis()

        val stats = usageStatsManager.queryUsageStats(
            UsageStatsManager.INTERVAL_DAILY,
            startOfDay,
            now
        )

        var totalSocialMediaTimeMs = 0L
        val monitoredPackages = setOf(
            "com.instagram.android",
            "com.google.android.youtube",
            "com.zhiliaoapp.musically",
            "com.twitter.android"
        )

        for (stat in stats) {
            if (stat.packageName in monitoredPackages) {
                totalSocialMediaTimeMs += stat.totalTimeInForeground
            }
        }

        val totalMinutes = totalSocialMediaTimeMs / (1000 * 60)
        val thresholdMinutes = 45
        if (totalMinutes >= thresholdMinutes) {
            CompanionAudioPoolManager.getInstance(applicationContext).playScreenLimitChime()
        }

        return Result.success()
    }
}
