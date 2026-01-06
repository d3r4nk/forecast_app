import 'package:weather/weather.dart';
import '../../consts.dart';
import '../models/weather_snapshot.dart';

class OpenWeatherService {
  final WeatherFactory _wf;

  OpenWeatherService() : _wf = WeatherFactory(openWeatherApiKey);

  Future<WeatherSnapshot> fetchSnapshot(double lat, double lon) async {
    final now = DateTime.now();

    final current = await _wf.currentWeatherByLocation(lat, lon);

    double? maxTempC;
    double? maxHum;

    try {
      final forecast = await _wf.fiveDayForecastByLocation(lat, lon);
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      for (final f in forecast) {
        final dt = f.date;
        if (dt == null) continue;
        if (dt.isBefore(startOfDay) || !dt.isBefore(endOfDay)) continue;

        final t = f.temperature?.celsius;
        if (t != null) {
          maxTempC = (maxTempC == null || t > maxTempC!) ? t : maxTempC;
        }
        final h = f.humidity;
        if (h != null) {
          maxHum = (maxHum == null || h > maxHum!) ? h : maxHum;
        }
      }
    } catch (_) {
      // keep nulls
    }

    return WeatherSnapshot(
      fetchedAt: DateTime.now(),
      tempC: current.temperature?.celsius,
      feelsLikeC: current.tempFeelsLike?.celsius,
      windSpeedMs: current.windSpeed,
      humidity: current.humidity,
      maxTempC: maxTempC ?? current.temperature?.celsius,
      maxHumidity: maxHum ?? current.humidity,
      description: current.weatherDescription,
      icon: current.weatherIcon,
      areaName: current.areaName,
      country: current.country,
      sunrise: current.sunrise,
      sunset: current.sunset,
    );
  }
}