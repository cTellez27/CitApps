package com.citapps.citapps

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class BarbershopWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.barbershop_widget).apply {
                // Get values passed from Flutter using widgetData (SharedPreferences)
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
