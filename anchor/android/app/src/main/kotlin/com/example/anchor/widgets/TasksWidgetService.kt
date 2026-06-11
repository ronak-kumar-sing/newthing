package com.example.anchor.widgets

import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import android.widget.RemoteViewsService
import org.json.JSONArray
import org.json.JSONObject

class TasksWidgetService : RemoteViewsService() {
    override fun onGetViewFactory(intent: Intent): RemoteViewsFactory {
        return TasksRemoteViewsFactory(applicationContext)
    }
}

class TasksRemoteViewsFactory(private val context: Context) : RemoteViewsService.RemoteViewsFactory {
    private var tasksList = mutableListOf<JSONObject>()

    override fun onCreate() {
        loadTasks()
    }

    override fun onDataSetChanged() {
        loadTasks()
    }

    override fun onDestroy() {
        tasksList.clear()
    }

    override fun getCount(): Int {
        return tasksList.size
    }

    override fun getViewAt(position: Int): RemoteViews {
        val packageName = context.packageName
        val itemResId = context.resources.getIdentifier("task_item", "layout", packageName)
        
        val views = RemoteViews(packageName, itemResId)
        
        if (position >= tasksList.size) return views
        
        val task = tasksList[position]
        val title = task.optString("title", "")
        val category = task.optString("category", "General")
        val isCompleted = task.optBoolean("isCompleted", false)

        val titleId = context.resources.getIdentifier("task_item_title", "id", packageName)
        val categoryId = context.resources.getIdentifier("task_item_category", "id", packageName)
        val statusIconId = context.resources.getIdentifier("task_item_status_icon", "id", packageName)

        if (titleId != 0) {
            views.setTextViewText(titleId, title)
        }
        if (categoryId != 0) {
            views.setTextViewText(categoryId, category.uppercase())
        }
        if (statusIconId != 0) {
            val drawableName = if (isCompleted) "widget_checkbox_checked" else "widget_checkbox_unchecked"
            val drawableId = context.resources.getIdentifier(drawableName, "drawable", packageName)
            if (drawableId != 0) {
                views.setImageViewResource(statusIconId, drawableId)
            }
        }
        
        // Make the item clickable by adding a fill-in intent
        val fillInIntent = android.content.Intent()
        val rootId = context.resources.getIdentifier("task_item_root", "id", packageName)
        if (rootId != 0) {
            views.setOnClickFillInIntent(rootId, fillInIntent)
        }

        return views
    }

    override fun getLoadingView(): RemoteViews? {
        return null
    }

    override fun getViewTypeCount(): Int {
        return 1
    }

    override fun getItemId(position: Int): Long {
        return position.toLong()
    }

    override fun hasStableIds(): Boolean {
        return true
    }

    private fun loadTasks() {
        tasksList.clear()
        val jsonStr = WidgetDataHelper.getTaskData(context)
        if (jsonStr != null) {
            try {
                val array = JSONArray(jsonStr)
                for (i in 0 until array.length()) {
                    tasksList.add(array.getJSONObject(i))
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }
}
