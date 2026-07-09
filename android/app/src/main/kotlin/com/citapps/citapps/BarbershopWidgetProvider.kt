package com.citapps.citapps

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import es.uxland.home_widget.HomeWidgetBackgroundIntent
import es.uxland.home_widget.HomeWidgetLaunchIntent
import es.uxland.home_widget.HomeWidgetPlugin

class BarbershopWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            // Get shared preferences via home_widget plugin helper
            val widgetData = HomeWidgetPlugin.getData(context)
            val views = RemoteViews(context.packageName, R.layout.barbershop_widget).apply {
                
                // Get values passed from Flutter
                val citasCount = widgetData.getInt("citas_count", 0)
                val proximaCita = widgetData.getString("proxima_cita_time", "Sin citas pendientes")

                // Update text values in the layout
                setTextViewText(R.id.widget_citas_count, citasCount.toString())
                setTextViewText(R.id.widget_proxima_cita_val, proximaCita)

                // PendingIntent to launch the MainActivity (app) when widget is clicked
                val pendingIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java
                )
                setOnClickPendingIntent(R.id.widget_title, pendingIntent)
                setOnClickPendingIntent(R.id.widget_citas_count, pendingIntent)
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
