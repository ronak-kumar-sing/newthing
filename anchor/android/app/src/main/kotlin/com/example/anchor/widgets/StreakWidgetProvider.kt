package com.example.anchor.widgets

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import org.json.JSONObject
import org.json.JSONArray
import android.graphics.Color

class StreakWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    private fun updateAppWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
        val packageName = context.packageName
        val layoutResId = context.resources.getIdentifier("streak_widget", "layout", packageName)
        if (layoutResId == 0) return

        val views = RemoteViews(packageName, layoutResId)

        // Decode synced JSON payload
        val jsonStr = WidgetDataHelper.getStreakData(context)
        if (jsonStr != null) {
            try {
                val json = JSONObject(jsonStr)
                val habitName = json.optString("habitName", "Focus Goal")
                val currentStreak = json.optInt("currentStreak", 0)
                val daysLeft = json.optInt("daysLeft", 0)
                val percentage = json.optDouble("percentage", 0.0)
                val last7Days = json.optJSONArray("last7Days")
                val accentColorHex = json.optString("accentColorHex", "#C6F52C")

                // Bind text elements
                val habitTextId = context.resources.getIdentifier("widget_habit_name", "id", packageName)
                if (habitTextId != 0) views.setTextViewText(habitTextId, habitName.uppercase())

                val streakTextId = context.resources.getIdentifier("widget_streak_count", "id", packageName)
                if (streakTextId != 0) views.setTextViewText(streakTextId, currentStreak.toString())

                val daysLeftTextId = context.resources.getIdentifier("widget_days_left", "id", packageName)
                if (daysLeftTextId != 0) views.setTextViewText(daysLeftTextId, "${daysLeft}d left")

                val progressTextId = context.resources.getIdentifier("widget_progress_percent", "id", packageName)
                if (progressTextId != 0) views.setTextViewText(progressTextId, "${percentage.toInt()}%")

                // Set 7-day dot matrix values
                if (last7Days != null) {
                    for (i in 0 until 7) {
                        val dotId = context.resources.getIdentifier("dot_${i + 1}", "id", packageName)
                        if (dotId != 0) {
                            val active = last7Days.optBoolean(i, false)
                            val drawableName = if (active) "widget_dot_active" else "widget_dot_inactive"
                            val drawableId = context.resources.getIdentifier(drawableName, "drawable", packageName)
                            if (drawableId != 0) {
                                views.setImageViewResource(dotId, drawableId)
                            }
                        }
                    }
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
        
        appWidgetManager.updateAppWidget(appWidgetId, views)
    }
}
