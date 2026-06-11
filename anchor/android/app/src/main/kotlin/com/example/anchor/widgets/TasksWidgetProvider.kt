package com.example.anchor.widgets

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.widget.RemoteViews

class TasksWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    private fun updateAppWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
        val packageName = context.packageName
        val layoutResId = context.resources.getIdentifier("tasks_widget", "layout", packageName)
        if (layoutResId == 0) return

        val views = RemoteViews(packageName, layoutResId)

        // Setup the RemoteViewsService intent to populate tasks list
        val serviceIntent = Intent(context, TasksWidgetService::class.java).apply {
            putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
            data = Uri.parse(toUri(Intent.URI_INTENT_SCHEME))
        }

        val listViewId = context.resources.getIdentifier("tasks_list_view", "id", packageName)
        val emptyViewId = context.resources.getIdentifier("widget_empty_view", "id", packageName)
        
        if (listViewId != 0) {
            views.setRemoteAdapter(listViewId, serviceIntent)
            if (emptyViewId != 0) {
                views.setEmptyView(listViewId, emptyViewId)
            }
        }

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }
}
