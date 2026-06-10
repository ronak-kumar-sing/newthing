package com.example.anchor

import android.app.AppOpsManager
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Process
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.Calendar

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.example.anchor/usage_stats"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "checkUsageStatsPermission" -> {
                    result.success(hasUsageStatsPermission())
                }
                "requestUsageStatsPermission" -> {
                    openUsageAccessSettings()
                    result.success(null)
                }
                "getUsageStats" -> {
                    val startTime = call.argument<Long>("startTime")
                    val endTime = call.argument<Long>("endTime")
                    if (startTime != null && endTime != null) {
                        val stats = getUsageStats(startTime, endTime)
                        result.success(stats)
                    } else {
                        result.error("INVALID_ARGS", "startTime and endTime required", null)
                    }
                }
                "getUsageEvents" -> {
                    val startTime = call.argument<Long>("startTime")
                    val endTime = call.argument<Long>("endTime")
                    if (startTime != null && endTime != null) {
                        val events = getUsageEvents(startTime, endTime)
                        result.success(events)
                    } else {
                        result.error("INVALID_ARGS", "startTime and endTime required", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    /// Check if the app has been granted PACKAGE_USAGE_STATS permission.
    /// On Android, this requires checking AppOpsManager since it's a special permission
    /// that cannot be requested via the normal permission dialog.
    private fun hasUsageStatsPermission(): Boolean {
        val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            appOps.unsafeCheckOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                Process.myUid(),
                packageName
            )
        } else {
            @Suppress("DEPRECATION")
            appOps.checkOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                Process.myUid(),
                packageName
            )
        }
        return mode == AppOpsManager.MODE_ALLOWED
    }

    /// Open the system Usage Access settings page for this app.
    /// This is the only way to request PACKAGE_USAGE_STATS permission —
    /// the user must manually toggle it on.
    private fun openUsageAccessSettings() {
        val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS).apply {
            // Try to deep-link to this app's settings page
            data = Uri.parse("package:$packageName")
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
        }
        startActivity(intent)
    }

    /// Query UsageStatsManager for aggregated app usage data.
    /// Returns a list of maps containing packageName and totalTimeInForeground (ms).
    private fun getUsageStats(startTime: Long, endTime: Long): List<Map<String, Any>> {
        if (!hasUsageStatsPermission()) {
            return emptyList()
        }
        val usm = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val stats = usm.queryUsageStats(
            UsageStatsManager.INTERVAL_DAILY,
            startTime,
            endTime
        )
        return stats.map { s ->
            mapOf(
                "packageName" to s.packageName,
                "totalTimeInForeground" to s.totalTimeInForeground,
                "lastTimeUsed" to s.lastTimeUsed
            )
        }
    }

    /// Query UsageStatsManager for individual usage events (app open/close).
    /// This gives more granular data than aggregated stats.
    private fun getUsageEvents(startTime: Long, endTime: Long): List<Map<String, Any>> {
        if (!hasUsageStatsPermission()) {
            return emptyList()
        }
        val usm = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val events = usm.queryEvents(startTime, endTime)
        val result = mutableListOf<Map<String, Any>>()
        val event = UsageEvents.Event()

        while (events.hasNextEvent()) {
            events.getNextEvent(event)
            result.add(
                mapOf(
                    "packageName" to event.packageName,
                    "timeStamp" to event.timeStamp,
                    "eventType" to event.eventType
                )
            )
        }
        return result
    }
}
