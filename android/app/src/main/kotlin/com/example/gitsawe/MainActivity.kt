package com.example.gitsawe

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.os.Bundle
import android.widget.RemoteViews
import org.json.JSONArray
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetPlugin

/**
 * Renders the "today's Gitsawe" home screen widget at three sizes.
 * One provider, one set of saved data (written from Dart via
 * HomeWidgetService) — the LAYOUT chosen depends on the actual size
 * the user resized the widget to on their home screen, using Android's
 * own AppWidgetManager size options rather than three separate pinned
 * widgets.
 */
class GitsaweWidgetProvider : AppWidgetProvider() {

    companion object {
        private const val KEY_DATE = "gitsawe_date"
        private const val KEY_TITLE = "gitsawe_title"
        private const val KEY_SNKSAR = "gitsawe_snksar"
        private const val KEY_DAILY_CACHE = "gitsawe_daily_cache"

        // Thresholds are approximate cell-to-dp conversions; tune to taste.
        private const val MEDIUM_MIN_WIDTH_DP = 180
        private const val LARGE_MIN_HEIGHT_DP = 180
    }

    private fun loadDailyReading(context: Context): Triple<String, String, String> {
        val prefs = HomeWidgetPlugin.getData(context)
        val cachedJson = prefs.getString(KEY_DAILY_CACHE, "") ?: ""
        val savedDate = prefs.getString(KEY_DATE, "") ?: ""
        val savedTitle = prefs.getString(KEY_TITLE, "ገና አልተጫነም") ?: "ገና አልተጫነም"
        val savedSnksar = prefs.getString(KEY_SNKSAR, "") ?: ""

        if (cachedJson.isNotBlank()) {
            try {
                val entries = JSONArray(cachedJson)
                val today = java.time.LocalDate.now()
                val todayKey = "%02d-%02d".format(today.dayOfMonth, today.monthValue)
                for (i in 0 until entries.length()) {
                    val entry = entries.getJSONObject(i)
                    if (entry.optString("date", "") == todayKey) {
                        val title = entry.optString("title", savedTitle)
                        val snksarArray = entry.optJSONArray("snksar")
                        val snksar = if (snksarArray != null && snksarArray.length() > 0) {
                            snksarArray.getJSONObject(0).optString("amharic", savedSnksar)
                        } else savedSnksar
                        val ethiopianDate = savedDate.ifBlank { todayKey }
                        return Triple(ethiopianDate, title, snksar)
                    }
                }
            } catch (_: Exception) {
                // Fall through to the last saved widget payload.
            }
        }
        return Triple(savedDate, savedTitle, savedSnksar)
    }

    /** Picks the layout resource for the widget's CURRENT placed size. */
    private fun layoutFor(context: Context, appWidgetManager: AppWidgetManager, widgetId: Int): Int {
        val options = appWidgetManager.getAppWidgetOptions(widgetId)
        val minWidth = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH, 0)
        val minHeight = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT, 0)

        return when {
            minHeight >= LARGE_MIN_HEIGHT_DP -> R.layout.gitsawe_widget_large
            minWidth >= MEDIUM_MIN_WIDTH_DP -> R.layout.gitsawe_widget_medium
            else -> R.layout.gitsawe_widget_small
        }
    }

    private fun render(context: Context, appWidgetManager: AppWidgetManager, widgetId: Int) {
        val (date, title, snksar) = loadDailyReading(context)
        val layoutRes = layoutFor(context, appWidgetManager, widgetId)
        val views = RemoteViews(context.packageName, layoutRes)

        // widget_date/widget_title/widget_snksar/widget_open only exist in
        // SOME of the three layouts — RemoteViews.setTextViewText silently
        // no-ops for an id that isn't present in whichever layout is
        // actually inflated, so it's safe to set all of them unconditionally.
        views.setTextViewText(R.id.widget_date, date)
        views.setTextViewText(R.id.widget_title, title)
        views.setTextViewText(R.id.widget_snksar, snksar)

        val pendingIntent = HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)
        views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)

        appWidgetManager.updateAppWidget(widgetId, views)
    }

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (widgetId in appWidgetIds) {
            render(context, appWidgetManager, widgetId)
        }
    }

    /** Called automatically by Android whenever the user resizes the widget. */
    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: Bundle
    ) {
        render(context, appWidgetManager, appWidgetId)
    }
}