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
        views.setTextViewText(R.id.tv_temp_big, "$temp°")
        views.setTextViewText(
            R.id.tv_metrics,
            "Hum $hum  •  Wind $wind"
        )
        views.setTextViewText(R.id.tv_desc, desc)
        views.setImageViewResource(R.id.iv_weather_desc, iconRes(iconCode))

        // Background theo nhiệt độ
        val tempValue = temp.replace("°", "").toIntOrNull()
        val bgRes = when {
            tempValue != null && tempValue >= 30 -> R.drawable.weather_widget_bg_hot
            tempValue != null && tempValue <= 15 -> R.drawable.weather_widget_bg_cold
            else -> R.drawable.weather_widget_bg
        }
        views.setInt(R.id.widget_root, "setBackgroundResource", bgRes)

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
}
