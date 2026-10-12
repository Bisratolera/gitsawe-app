package com.example.gitsawe

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import com.ryanheise.audioservice.AudioServiceActivity


class MainActivity : AudioServiceActivity()


abstract class BaseGitsaweWidgetProvider : HomeWidgetProvider() {
    abstract val layoutRes: Int

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        val date = widgetData.getString("gitsawe_date", "") ?: ""
        val title = widgetData.getString("gitsawe_title", "ገና አልተጫነም") ?: "ገና አልተጫነም"
        val snksar = widgetData.getString("gitsawe_snksar", "") ?: ""

        for (widgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, layoutRes)
            
            try {
                views.setTextViewText(R.id.widget_title, title)
            } catch (_: Exception) {}
            try {
                views.setTextViewText(R.id.widget_date, date)
            } catch (_: Exception) {}
            try {
                views.setTextViewText(R.id.widget_snksar, snksar)
            } catch (_: Exception) {}

            // Tapping anywhere on the widget opens the app.
            val pendingIntent = HomeWidgetLaunchIntent.getActivity(
                context,
                MainActivity::class.java
            )
            try {
                views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)
            } catch (_: Exception) {}

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}

class GitsaweWidgetSmallProvider : BaseGitsaweWidgetProvider() {
    override val layoutRes = R.layout.gitsawe_widget_small
}

class GitsaweWidgetCompactProvider : BaseGitsaweWidgetProvider() {
    override val layoutRes = R.layout.gitsawe_widget_compact
}

class GitsaweWidgetMediumProvider : BaseGitsaweWidgetProvider() {
    override val layoutRes = R.layout.gitsawe_widget_medium
}

class GitsaweWidgetLargeProvider : BaseGitsaweWidgetProvider() {
    override val layoutRes = R.layout.gitsawe_widget_large
}

class GitsaweWidgetCustomProvider : BaseGitsaweWidgetProvider() {
    override val layoutRes = R.layout.gitsawe_widget_sm
}

class GitsaweReadingWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        val date = widgetData.getString("gitsawe_date", "") ?: ""
        val title = widgetData.getString("gitsawe_title", "ገና አልተጫነም") ?: "ገና አልተጫነም"
        val snksar = widgetData.getString("gitsawe_snksar", "") ?: ""

        for (widgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.gitsawe_widget_reading)
            try { views.setTextViewText(R.id.widget_title, title) } catch (_: Exception) {}
            try { views.setTextViewText(R.id.widget_date, date) } catch (_: Exception) {}
            try { views.setTextViewText(R.id.widget_snksar, snksar) } catch (_: Exception) {}

            val pendingIntent = HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)
            try { views.setOnClickPendingIntent(R.id.widget_reading_root, pendingIntent) } catch (_: Exception) {}

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}

class GitsaweVerseWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        val verseText = widgetData.getString("gitsawe_verse_text", "”የቅዱሳን መታሰቢያ ለበረከት ነው።”") ?: ""
        val verseRef = widgetData.getString("gitsawe_verse_ref", "ምሳሌ 10:7") ?: ""

        for (widgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.gitsawe_widget_verse)
            try { views.setTextViewText(R.id.widget_verse_text, verseText) } catch (_: Exception) {}
            try { views.setTextViewText(R.id.widget_verse_ref, verseRef) } catch (_: Exception) {}

            val pendingIntent = HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)
            try { views.setOnClickPendingIntent(R.id.widget_verse_root, pendingIntent) } catch (_: Exception) {}

            // Refresh action intent
            val refreshIntent = Intent(context, GitsaweVerseWidgetProvider::class.java).apply {
                action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
            }
            val pendingRefresh = PendingIntent.getBroadcast(
                context,
                202,
                refreshIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            try { views.setOnClickPendingIntent(R.id.widget_verse_refresh, pendingRefresh) } catch (_: Exception) {}

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
