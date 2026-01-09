import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../consts.dart';
import '../../home/state/home_state.dart';
import '../../settings/state/settings_state.dart';
import '../model/weather_forecast_view_data.dart';
import '../service/weather_forecast_mapper.dart';

class WeatherDetailState extends ChangeNotifier {
  final HomeState _home;
  final SettingsState _settings;
  final WeatherDetailMapper _mapper;

  WeatherForecastViewData view = WeatherForecastViewData.empty;

  bool loading = false;
  String? error;

  double? _lastLat;
  double? _lastLon;

  WeatherDetailState({
    required HomeState home,
    required SettingsState settings,
    WeatherDetailMapper? mapper,
  })  : _home = home,
        _settings = settings,
        _mapper = mapper ?? WeatherDetailMapper() {
    _home.addListener(_sync);
    _settings.addListener(_sync);
    _sync();
  }

  @override
  void dispose() {
    _home.removeListener(_sync);
    _settings.removeListener(_sync);
    super.dispose();
  }

  void _sync() {
    final lat = _home.lat;
    final lon = _home.lon;

    final changed = (_lastLat != lat) || (_lastLon != lon);
    _lastLat = lat;
    _lastLon = lon;

    if (changed && lat != null && lon != null) {
      refresh();
    }
  }

  Future<void> refresh() async {
    final lat = _home.lat;
    final lon = _home.lon;

    if (lat == null || lon == null) {
      error = _settings.isEnglish ? "Missing location." : "Thiếu vị trí.";
      notifyListeners();
      return;
    }

    if (loading) return;
    loading = true;
    error = null;
    notifyListeners();

    try {
      final lang = _settings.isEnglish ? "en" : "vi";

      // OpenWeather 2.5 forecast (5 days / 3 hours)
      final uri = Uri.https(
        "api.openweathermap.org",
        "/data/2.5/forecast",
        {
          "lat": lat.toString(),
          "lon": lon.toString(),
          "units": "metric",
          "lang": lang,
          "appid": openWeatherApiKey,
        },
      );

      final res = await http.get(uri);
      if (res.statusCode != 200) {
        throw Exception("OpenWeather error: ${res.statusCode} ${res.body}");
      }

      final raw = jsonDecode(res.body);
      if (raw is! Map<String, dynamic>) {
        throw Exception("Invalid forecast response.");
      }

      // Convert 2.5/forecast -> OneCall-like shape so existing UI/mapper can keep working
      final oneCallLike = _toOneCallLike(raw);

      view = _mapper.toForecastView(
        oneCallJson: oneCallLike,
        isEnglish: _settings.isEnglish,
      );
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Map<String, dynamic> _toOneCallLike(Map<String, dynamic> forecastJson) {
    final listAny = forecastJson["list"];
    if (listAny is! List) {
      throw Exception("Invalid forecast response: missing 'list'.");
    }

    final now = DateTime.now();
    final next24h = now.add(const Duration(hours: 24));

    double? _asDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    int? _asInt(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString());
    }

    Map<String, dynamic> _firstWeather(dynamic item) {
      if (item is Map<String, dynamic>) {
        final w = item["weather"];
        if (w is List && w.isNotEmpty && w.first is Map<String, dynamic>) {
          return (w.first as Map<String, dynamic>);
        }
      }
      return const {};
    }

    // Hourly (we keep all items; mapper can slice; but we also tag by dt)
    final hourly = <Map<String, dynamic>>[];
    // Daily aggregation from list (forecast is max 5 days, not 7)
    final byDay = <DateTime, List<Map<String, dynamic>>>{};

    for (final it in listAny) {
      if (it is! Map<String, dynamic>) continue;

      final dtSec = _asInt(it["dt"]);
      if (dtSec == null) continue;

      final dtLocal = DateTime.fromMillisecondsSinceEpoch(dtSec * 1000, isUtc: true).toLocal();

      final main = (it["main"] is Map<String, dynamic>) ? (it["main"] as Map<String, dynamic>) : const {};
      final wind = (it["wind"] is Map<String, dynamic>) ? (it["wind"] as Map<String, dynamic>) : const {};
      final w0 = _firstWeather(it);

      final temp = _asDouble(main["temp"]);
      final humidity = _asDouble(main["humidity"]);
      final windSpeed = _asDouble(wind["speed"]);
      final desc = w0["description"]?.toString();
      final icon = w0["icon"]?.toString();

      hourly.add({
        "dt": dtSec,
        "temp": temp,
        "humidity": humidity,
        "wind_speed": windSpeed,
        "weather": [
          {
            "description": desc,
            "icon": icon,
          }
        ],
      });

      // Group by local day start for "daily"
      final dayKey = DateTime(dtLocal.year, dtLocal.month, dtLocal.day);
      (byDay[dayKey] ??= <Map<String, dynamic>>[]).add({
        "dt": dtSec,
        "temp": temp,
        "humidity": humidity,
        "wind_speed": windSpeed,
        "description": desc,
        "icon": icon,
        "dt_local": dtLocal,
      });
    }

    // Build daily list: min/max temp per day + representative icon/desc (closest to 12:00)
    final days = byDay.keys.toList()..sort((a, b) => a.compareTo(b));
    final daily = <Map<String, dynamic>>[];

    for (final day in days) {
      final items = byDay[day]!;
      double? minT;
      double? maxT;

      for (final x in items) {
        final t = x["temp"] as double?;
        if (t == null) continue;
        minT = (minT == null) ? t : (t < minT ? t : minT);
        maxT = (maxT == null) ? t : (t > maxT ? t : maxT);
      }

      // pick representative around 12:00 local
      Map<String, dynamic>? rep;
      int bestDelta = 1 << 30;
      for (final x in items) {
        final dtLocal = x["dt_local"] as DateTime?;
        if (dtLocal == null) continue;
        final delta = (dtLocal.hour - 12).abs();
        if (delta < bestDelta) {
          bestDelta = delta;
          rep = x;
        }
      }
      rep ??= items.isNotEmpty ? items.first : null;

      final dtSec = rep?["dt"] as int? ?? (day.millisecondsSinceEpoch ~/ 1000);
      final desc = rep?["description"] as String?;
      final icon = rep?["icon"] as String?;
      final windSpeed = rep?["wind_speed"] as double?;
      final humidity = rep?["humidity"] as double?;

      daily.add({
        "dt": dtSec,
        "temp": {"min": minT, "max": maxT},
        "humidity": humidity,
        "wind_speed": windSpeed,
        "weather": [
          {
            "description": desc,
            "icon": icon,
          }
        ],
      });
    }

    // current: pick first item as "current"
    final current = hourly.isNotEmpty ? hourly.first : <String, dynamic>{};

    // Optionally trim hourly to next 24h (helps UI)
    final hourly24 = hourly.where((h) {
      final dt = h["dt"];
      if (dt is! int) return false;
      final dtLocal = DateTime.fromMillisecondsSinceEpoch(dt * 1000, isUtc: true).toLocal();
      return dtLocal.isAfter(now.subtract(const Duration(minutes: 1))) && dtLocal.isBefore(next24h);
    }).toList();

    return <String, dynamic>{
      "current": current,
      "hourly": hourly24,
      "daily": daily, // will be up to 5 days from 2.5/forecast
    };
  }
}
