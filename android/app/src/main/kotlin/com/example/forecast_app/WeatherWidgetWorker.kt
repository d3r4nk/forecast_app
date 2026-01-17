package com.example.forecast_app

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.widget.RemoteViews
import androidx.work.CoroutineWorker
import androidx.work.WorkerParameters
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import org.json.JSONObject
import java.net.HttpURLConnection
import java.net.URL

class WeatherWidgetWorker(
    appContext: Context,
    params: WorkerParameters
) : CoroutineWorker(appContext, params) {

    override suspend fun doWork(): Result = withContext(Dispatchers.IO) {
        try {
            val prefs = applicationContext.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
            val latStr = prefs.getString("w_lat", null)
            val lonStr = prefs.getString("w_lon", null)
            val lat = latStr?.toDoubleOrNull()
            val lon = lonStr?.toDoubleOrNull()

            val apiKey = BuildConfig.OPEN_WEATHER_API_KEY

            if (lat == null || lon == null || apiKey.isBlank()) {
                return@withContext Result.success()
            }

            val url = URL(
                "https://api.openweathermap.org/data/2.5/weather" +
                        "?lat=$lat&lon=$lon&units=metric&lang=vi&appid=$apiKey"
            )

            val conn = (url.openConnection() as HttpURLConnection).apply {
                connectTimeout = 10000
                readTimeout = 10000
                requestMethod = "GET"
            }

            val code = conn.responseCode
            val body = (if (code in 200..299) conn.inputStream else conn.errorStream)
                .bufferedReader()
                .use { it.readText() }

            if (code !in 200..299) return@withContext Result.retry()

            val json = JSONObject(body)

            val temp = json.getJSONObject("main").getDouble("temp")
            val hum = json.getJSONObject("main").getInt("humidity")
            val wind = json.optJSONObject("wind")?.optDouble("speed", Double.NaN)
            val desc = json.getJSONArray("weather").getJSONObject(0).optString("description", "")

            val windText = if (wind == null || wind.isNaN()) "—" else String.format("%.1f m/s", wind)
            val tempText = String.format("%.1f°C", temp)

            prefs.edit()
                .putString("w_temp", tempText)
                .putString("w_hum", "$hum%")
                .putString("w_wind", windText)
                .putString("w_desc", desc)
                .apply()

            val views = RemoteViews(applicationContext.packageName, R.layout.weather_quick_widget)
            views.setTextViewText(R.id.tv_temp_big, tempText)
            views.setTextViewText(R.id.tv_metrics, "Hum ${hum}%  •  Wind $windText")
            views.setTextViewText(R.id.tv_desc, desc)

            val tempValueInt = temp.toInt()
            val bgRes = when {
                tempValueInt >= 30 -> R.drawable.weather_widget_bg_hot
                tempValueInt <= 15 -> R.drawable.weather_widget_bg_cold
                else -> R.drawable.weather_widget_bg
            }
            views.setInt(R.id.widget_root, "setBackgroundResource", bgRes)

            val appWidgetManager = AppWidgetManager.getInstance(applicationContext)
            val component = ComponentName(applicationContext, WeatherQuickWidgetProvider::class.java)
            val ids = appWidgetManager.getAppWidgetIds(component)
            for (id in ids) {
                appWidgetManager.updateAppWidget(id, views)
            }

            Result.success()
        } catch (_: Throwable) {
            Result.retry()
        }
    }
}
