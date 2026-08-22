package com.example.gitsawe

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetPlugin

import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity()


/**
 * Renders the "today's Gitsawe" home screen widget.
 *
 * Data is written from Dart via HomeWidgetService (lib/services/home_widget_service.dart),
 * which calls HomeWidget.saveWidgetData + HomeWidget.updateWidget. That plugin call lands
 * here as onUpdate, and the same keys are read back out of the shared preferences store
 * the plugin manages. Android will also invoke onUpdate periodically on its own
 * (see updatePeriodMillis in gitsawe_widget_info.xml), which just re-renders whatever
 * was last cached — it does not fetch fresh data from the network itself.
 */
class GitsaweWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        val prefs = HomeWidgetPlugin.getData(context)
        val date = prefs.getString("gitsawe_date", "") ?: ""
        val title = prefs.getString("gitsawe_title", "ገና አልተጫነም") ?: "ገና አልተጫነም"
        val snksar = prefs.getString("gitsawe_snksar", "") ?: ""

        for (widgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.gitsawe_widget)
            views.setTextViewText(R.id.widget_date, date)
            views.setTextViewText(R.id.widget_title, title)
            views.setTextViewText(R.id.widget_snksar, snksar)

            // Tapping anywhere on the widget opens the app.
            val pendingIntent = HomeWidgetLaunchIntent.getActivity(
                context,
                MainActivity::class.java
            )
            views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}