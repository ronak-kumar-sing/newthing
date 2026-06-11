package com.example.anchor.widgets

import android.content.Context
import android.content.SharedPreferences

object WidgetDataHelper {
    private const val PREFS_NAME = "com.example.anchor.widget_data"
    private const val KEY_STREAK = "streak_data"
    private const val KEY_TASKS = "tasks_data"

    private fun getPrefs(context: Context): SharedPreferences {
        return context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
    }

    fun saveStreakData(context: Context, json: String) {
        getPrefs(context).edit().putString(KEY_STREAK, json).apply()
    }

    fun getStreakData(context: Context): String? {
        return getPrefs(context).getString(KEY_STREAK, null)
    }

    fun saveTaskData(context: Context, json: String) {
        getPrefs(context).edit().putString(KEY_TASKS, json).apply()
    }

    fun getTaskData(context: Context): String? {
        return getPrefs(context).getString(KEY_TASKS, null)
    }
}
