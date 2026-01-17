package com.example.forecast_app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Build
import android.widget.RemoteViews
import androidx.work.ExistingPeriodicWorkPolicy
import androidx.work.PeriodicWorkRequestBuilder
import androidx.work.WorkManager
import java.util.concurrent.TimeUnit

class WeatherQuickWidgetProvider : AppWidgetProvider() {

    override fun onEnabled(context: Context) {
        super.onEnabled(context)
        scheduleWorker(context)
        updateAllWidgets(context)
    }

    override fun onDisabled(context: Context) {
        super.onDisabled(context)
        WorkManager.getInstance(context).cancelUniqueWork(WORK_NAME)
    }

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        scheduleWorker(context)
        for (id in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, id)
        }
    }

    private fun scheduleWorker(context: Context) {
        val req = PeriodicWorkRequestBuilder<WeatherWidgetWorker>(15, TimeUnit.MINUTES).build()

        WorkManager.getInstance(context).enqueueUniquePeriodicWork(
            WORK_NAME,
            ExistingPeriodicWorkPolicy.UPDATE,
            req
        )
    }

    companion object {
        private const val WORK_NAME = "weather_widget_worker"

        fun updateAllWidgets(context: Context) {
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val component = ComponentName(context, WeatherQuickWidgetProvider::class.java)
            val ids = appWidgetManager.getAppWidgetIds(component)
            for (id in ids) {
                updateAppWidget(context, appWidgetManager, id)
            }
        }

        private fun updateAppWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
            val prefs = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)

            val temp = prefs.getString("w_temp", "—") ?: "—"
            val hum = prefs.getString("w_hum", "—") ?: "—"
            val wind = prefs.getString("w_wind", "—") ?: "—"
            val desc = prefs.getString("w_desc", "—") ?: "—"

            val views = RemoteViews(context.packageName, R.layout.weather_quick_widget)
            views.setTextViewText(R.id.tv_temp_big, temp)
            views.setTextViewText(R.id.tv_metrics, "Hum $hum  •  Wind $wind")
            views.setTextViewText(R.id.tv_desc, desc)

            val tempValue = temp.replace("°", "").toDoubleOrNull()
            val bgRes = when {
                tempValue != null && tempValue >= 30.0 -> R.drawable.weather_widget_bg_hot
                tempValue != null && tempValue <= 15.0 -> R.drawable.weather_widget_bg_cold
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
}
