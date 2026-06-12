package com.example.anchor

import android.app.AppOpsManager
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.appwidget.AppWidgetManager
import android.app.WallpaperManager
import android.graphics.BitmapFactory
import android.content.ComponentName
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
import com.example.anchor.widgets.WidgetDataHelper
import com.example.anchor.widgets.StreakWidgetProvider
import com.example.anchor.widgets.TasksWidgetProvider

class MainActivity : FlutterActivity() {

    private val USAGE_CHANNEL = "com.example.anchor/usage_stats"
    private val WIDGET_CHANNEL = "com.example.anchor/streak_widget"
    private val WALLPAPER_CHANNEL = "com.example.anchor/wallpaper"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // 1. Original Usage Stats Channel
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            USAGE_CHANNEL
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

        // 2. Widget Synchronization Channel
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            WIDGET_CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "syncStreakData" -> {
                    val data = call.argument<String>("data")
                    if (data != null) {
                        WidgetDataHelper.saveStreakData(this, data)
                        updateStreakWidgets()
                        result.success(true)
                    } else {
                        result.error("INVALID_ARGS", "streak data JSON string required", null)
                    }
                }
                "syncTaskData" -> {
                    val tasks = call.argument<String>("tasks")
                    if (tasks != null) {
                        WidgetDataHelper.saveTaskData(this, tasks)
                        updateTasksWidgets()
                        result.success(true)
                    } else {
                        result.error("INVALID_ARGS", "tasks JSON list required", null)
                    }
                }
                "pinStreakWidget" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        val appWidgetManager = AppWidgetManager.getInstance(this@MainActivity)
                        val myProvider = ComponentName(this@MainActivity, StreakWidgetProvider::class.java)
                        if (appWidgetManager.isRequestPinAppWidgetSupported) {
                            appWidgetManager.requestPinAppWidget(myProvider, null, null)
                            result.success(true)
                        } else {
                            result.success(false)
                        }
                    } else {
                        result.success(false)
                    }
                }
                "pinTasksWidget" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        val appWidgetManager = AppWidgetManager.getInstance(this@MainActivity)
                        val myProvider = ComponentName(this@MainActivity, TasksWidgetProvider::class.java)
                        if (appWidgetManager.isRequestPinAppWidgetSupported) {
                            appWidgetManager.requestPinAppWidget(myProvider, null, null)
                            result.success(true)
                        } else {
                            result.success(false)
                        }
                    } else {
                        result.success(false)
                    }
                }
                else -> result.notImplemented()
            }
        }

        // 3. Wallpaper Management Channel
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            WALLPAPER_CHANNEL
        ).setMethodCallHandler { call, result ->
            if (call.method == "setWallpaper") {
                val path = call.argument<String>("path")
                val type = call.argument<String>("type")
                if (path != null && type != null) {
                    val success = setWallpaper(path, type)
                    result.success(success)
                } else {
                    result.error("INVALID_ARGS", "path and type parameters required", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun updateStreakWidgets() {
        val intent = Intent(this, StreakWidgetProvider::class.java).apply {
            action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
            val ids = AppWidgetManager.getInstance(this@MainActivity).getAppWidgetIds(
                ComponentName(this@MainActivity, StreakWidgetProvider::class.java)
            )
            putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
        }
        sendBroadcast(intent)
    }

    private fun updateTasksWidgets() {
        val appWidgetManager = AppWidgetManager.getInstance(this)
        val componentName = ComponentName(this, TasksWidgetProvider::class.java)
        val ids = appWidgetManager.getAppWidgetIds(componentName)

        // Notify tasks ListView in RemoteViews to fetch latest data
        // R.id.tasks_list_view should correspond to the layout resource id
        val viewId = resources.getIdentifier("tasks_list_view", "id", packageName)
        if (viewId != 0) {
            appWidgetManager.notifyAppWidgetViewDataChanged(ids, viewId)
        }

        val intent = Intent(this, TasksWidgetProvider::class.java).apply {
            action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
            putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
        }
        sendBroadcast(intent)
    }

    private fun setWallpaper(path: String, type: String): Boolean {
        return try {
            val bitmap = BitmapFactory.decodeFile(path)
            val wallpaperManager = WallpaperManager.getInstance(this)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                val flag = when (type) {
                    "lock" -> WallpaperManager.FLAG_LOCK
                    "home" -> WallpaperManager.FLAG_SYSTEM
                    "both" -> WallpaperManager.FLAG_SYSTEM or WallpaperManager.FLAG_LOCK
                    else -> WallpaperManager.FLAG_SYSTEM
                }
                wallpaperManager.setBitmap(bitmap, null, true, flag)
            } else {
                wallpaperManager.setBitmap(bitmap)
            }
            true
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }

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

    private fun openUsageAccessSettings() {
        val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS).apply {
            data = Uri.parse("package:$packageName")
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
        }
        startActivity(intent)
    }

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
