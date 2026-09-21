package com.example.gitsawe

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import org.json.JSONArray
import org.json.JSONObject
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

    companion object {
        private const val KEY_DATE = "gitsawe_date"
        private const val KEY_TITLE = "gitsawe_title"
        private const val KEY_SNKSAR = "gitsawe_snksar"
        private const val KEY_DAILY_CACHE = "gitsawe_daily_cache"
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
                    val date = entry.optString("date", "")
                    if (date == todayKey) {
                        val title = entry.optString("title", savedTitle)
                        val snksarArray = entry.optJSONArray("snksar")
                        val snksar = if (snksarArray != null && snksarArray.length() > 0) {
                            val first = snksarArray.getJSONObject(0)
                            first.optString("amharic", savedSnksar)
                        } else {
                            savedSnksar
                        }
                        val ethiopianDate = if (savedDate.isNotBlank()) savedDate else todayKey
                        return Triple(ethiopianDate, title, snksar)
                    }
                }
            } catch (_: Exception) {
                // Fall through to the last saved widget payload.
            }
        }

        return Triple(savedDate, savedTitle, savedSnksar)
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        val (date, title, snksar) = loadDailyReading(context)

        for (widgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.gitsawe_widget)
            views.setTextViewText(R.id.widget_date, date)
            views.setTextViewText(R.id.widget_title, title)
            views.setTextViewText(R.id.widget_snksar, snksar)

            val pendingIntent = HomeWidgetLaunchIntent.getActivity(
                context,
                MainActivity::class.java
            )
            views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}