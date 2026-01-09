package com.example.forecast_app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.graphics.BitmapFactory
import android.os.Build
import android.widget.RemoteViews
import java.io.File

class WeatherQuickWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (id in appWidgetIds) updateAppWidget(context, appWidgetManager, id)
    }

    private fun updateAppWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
        val prefs = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)

        val temp = prefs.getString("w_temp", "—") ?: "—"
        val hum  = prefs.getString("w_hum", "—") ?: "—"
        val wind = prefs.getString("w_wind", "—") ?: "—"
        val desc = prefs.getString("w_desc", "—") ?: "—"
        val iconCode = prefs.getString("w_icon", "na") ?: "na"

        val views = RemoteViews(context.packageName, R.layout.weather_quick_widget)
        views.setTextViewText(R.id.tv_metrics, "Temp: $temp  |  Hum: $hum  |  Wind: $wind")
        views.setTextViewText(R.id.tv_desc, desc)
        val iconPath = prefs.getString("w_icon_path", null)
        var iconSet = false
        if (iconPath != null) {
            val f = File(iconPath)
            if (f.exists()) {
                val bmp = BitmapFactory.decodeFile(f.absolutePath)
                if (bmp != null) {
                    views.setImageViewBitmap(R.id.iv_icon, bmp)
                    iconSet = true
                }
            }
        }

        if (!iconSet) {
            views.setImageViewResource(R.id.iv_icon, iconRes(iconCode))
        }

        val launchIntent = Intent(context, MainActivity::class.java)
        val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }
        val pi = PendingIntent.getActivity(context, 0, launchIntent, flags)
        views.setOnClickPendingIntent(R.id.widget_root, pi)

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }

    private fun iconRes(code: String): Int {
        return when (code) {
            "01d" -> R.drawable.ow_01d
            "01n" -> R.drawable.ow_01n
            "02d" -> R.drawable.ow_02d
            "02n" -> R.drawable.ow_02n
            "03d" -> R.drawable.ow_03d
            "03n" -> R.drawable.ow_03n
            "04d" -> R.drawable.ow_04d
            "04n" -> R.drawable.ow_04n
            "09d" -> R.drawable.ow_09d
            "09n" -> R.drawable.ow_09n
            "10d" -> R.drawable.ow_10d
            "10n" -> R.drawable.ow_10n
            "11d" -> R.drawable.ow_11d
            "11n" -> R.drawable.ow_11n
            "13d" -> R.drawable.ow_13d
            "13n" -> R.drawable.ow_13n
            "50d" -> R.drawable.ow_50d
            "50n" -> R.drawable.ow_50n
            else  -> R.drawable.ow_na
        }
    }
}
