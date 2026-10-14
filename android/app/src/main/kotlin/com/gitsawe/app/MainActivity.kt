package com.gitsawe.app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.widget.RemoteViews
import com.ryanheise.audioservice.AudioServiceActivity
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONArray
import java.util.Calendar

class MainActivity : AudioServiceActivity()

/**
 * Everything a widget needs to draw "today".
 */
data class WidgetToday(
    val dateLabel: String,
    val title: String,
    val snksar: String,
    val verseText: String,
    val verseRef: String,
)

/**
 * Resolves today's reading natively so home-screen widgets move on to the
 * next day by themselves, even if the app was not opened. Flutter stores a
 * compact "DD-MM" -> reading cache in the shared widget preferences
 * (see HomeWidgetService.buildDailyCacheJson).
 */
object WidgetData {
    private const val EPOCH = 1723856 // Ethiopian calendar epoch (JDN)

    private val monthNames = arrayOf(
        "መስከረም", "ጥቅምት", "ኅዳር", "ታኅሣሥ", "ጥር", "የካቲት", "መጋቢት",
        "ሚያዝያ", "ግንቦት", "ሰኔ", "ሐምሌ", "ነሐሴ", "ጳጉሜን",
    )

    private fun gregorianToJdn(year: Int, month: Int, day: Int): Int {
        val a = (14 - month) / 12
        val y = year + 4800 - a
        val m = month + 12 * a - 3
        return day + (153 * m + 2) / 5 + 365 * y + y / 4 - y / 100 + y / 400 - 32045
    }

    /** Returns Triple(year, month, day) in the Ethiopian calendar for today. */
    fun ethiopianToday(): Triple<Int, Int, Int> {
        val cal = Calendar.getInstance()
        val jdn = gregorianToJdn(
            cal.get(Calendar.YEAR),
            cal.get(Calendar.MONTH) + 1,
            cal.get(Calendar.DAY_OF_MONTH),
        )
        val diff = jdn - EPOCH
        val r = Math.floorMod(diff, 1461)
        val n = r % 365 + 365 * (r / 1460)
        val year = 4 * Math.floorDiv(diff, 1461) + r / 365 - r / 1460
        val month = n / 30 + 1
        val day = n % 30 + 1
        return Triple(year, month, day)
    }

    fun resolve(prefs: SharedPreferences): WidgetToday {
        val (year, month, day) = ethiopianToday()
        val key = "%02d-%02d".format(day, month)
        val label = "$day/$month/$year"

        val fallbackTitle = "${monthNames[(month - 1).coerceIn(0, 12)]} $day"
        val storedLabel = prefs.getString("gitsawe_date", "") ?: ""
        val storedIsToday = storedLabel == label

        var title = if (storedIsToday) prefs.getString("gitsawe_title", null) else null
        var snksar = if (storedIsToday) prefs.getString("gitsawe_snksar", null) else null
        var verseText = if (storedIsToday) prefs.getString("gitsawe_verse_text", null) else null
        var verseRef = if (storedIsToday) prefs.getString("gitsawe_verse_ref", null) else null

        val cache = prefs.getString("gitsawe_daily_cache", null)
        if (!cache.isNullOrEmpty()) {
            try {
                val arr = JSONArray(cache)
                for (i in 0 until arr.length()) {
                    val o = arr.getJSONObject(i)
                    if (o.optString("date") == key) {
                        title = o.optString("title").ifEmpty { title }
                        snksar = o.optString("snksar").ifEmpty { snksar }
                        verseText = o.optString("verse").ifEmpty { verseText }
                        verseRef = o.optString("ref").ifEmpty { verseRef }
                        break
                    }
                }
            } catch (_: Exception) {
                // Corrupt cache: fall through to whatever Flutter last stored.
            }
        }

        return WidgetToday(
            dateLabel = label,
            title = title ?: fallbackTitle,
            snksar = snksar ?: "",
            verseText = verseText ?: "”የቅዱሳን መታሰቢያ ለበረከት ነው።”",
            verseRef = verseRef ?: "ምሳሌ 10:7",
        )
    }
}

private fun launchIntent(context: Context): PendingIntent =
    HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)

abstract class BaseGitsaweWidgetProvider : HomeWidgetProvider() {
    abstract val layoutRes: Int

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        val today = WidgetData.resolve(widgetData)

        for (widgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, layoutRes)

            try { views.setTextViewText(R.id.widget_title, today.title) } catch (_: Exception) {}
            try { views.setTextViewText(R.id.widget_date, today.dateLabel) } catch (_: Exception) {}
            try { views.setTextViewText(R.id.widget_snksar, today.snksar) } catch (_: Exception) {}

            // Tapping anywhere on the widget opens the app.
            try { views.setOnClickPendingIntent(R.id.widget_root, launchIntent(context)) } catch (_: Exception) {}

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
        val today = WidgetData.resolve(widgetData)

        for (widgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.gitsawe_widget_reading)
            try { views.setTextViewText(R.id.widget_title, today.title) } catch (_: Exception) {}
            try { views.setTextViewText(R.id.widget_date, today.dateLabel) } catch (_: Exception) {}
            try { views.setTextViewText(R.id.widget_snksar, today.snksar) } catch (_: Exception) {}
            try { views.setOnClickPendingIntent(R.id.widget_reading_root, launchIntent(context)) } catch (_: Exception) {}

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
        val today = WidgetData.resolve(widgetData)

        for (widgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.gitsawe_widget_verse)
            try { views.setTextViewText(R.id.widget_verse_text, today.verseText) } catch (_: Exception) {}
            try { views.setTextViewText(R.id.widget_verse_ref, today.verseRef) } catch (_: Exception) {}
            try { views.setOnClickPendingIntent(R.id.widget_verse_root, launchIntent(context)) } catch (_: Exception) {}

            // The refresh button re-runs onUpdate for this widget. AppWidgetProvider
            // ignores an update broadcast that carries no widget ids, so pass them.
            val refreshIntent = Intent(context, GitsaweVerseWidgetProvider::class.java).apply {
                action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, intArrayOf(widgetId))
            }
            val pendingRefresh = PendingIntent.getBroadcast(
                context,
                widgetId, // unique per widget instance so extras are not shared
                refreshIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
            try { views.setOnClickPendingIntent(R.id.widget_verse_refresh, pendingRefresh) } catch (_: Exception) {}

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
