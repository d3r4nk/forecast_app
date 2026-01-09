import '../model/weather_forecast_view_data.dart';

class WeatherDetailMapper {
  WeatherForecastViewData toForecastView({
    required Map<String, dynamic> oneCallJson,
    required bool isEnglish,
  }) {
    int? asInt(dynamic v) => v == null ? null : (v is num ? v.toInt() : int.tryParse(v.toString()));
    double? asDouble(dynamic v) => v == null ? null : (v is num ? v.toDouble() : double.tryParse(v.toString()));

    final tzOffset = asInt(oneCallJson['timezone_offset']) ?? 0;

    DateTime toLocalFromDt(dynamic dtSec) {
      final sec = asInt(dtSec) ?? 0;
      final utc = DateTime.fromMillisecondsSinceEpoch(sec * 1000, isUtc: true);
      return utc.add(Duration(seconds: tzOffset));
    }

    String two(int v) => v.toString().padLeft(2, "0");

    String fmtTime(DateTime d) => "${two(d.hour)}:${two(d.minute)}";

    const wdEn = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    const wdVi = ["T2", "T3", "T4", "T5", "T6", "T7", "CN"];
    String fmtDay(DateTime d) {
      final wd = isEnglish ? wdEn : wdVi;
      final idx = d.weekday - 1;
      final name = (idx >= 0 && idx < 7) ? wd[idx] : "";
      return "$name ${two(d.day)}/${two(d.month)}";
    }

    String fmtC(double? v) => v == null ? "—" : "${v.toStringAsFixed(1)}°C";
    String fmtPct(int? v) => v == null ? "—" : "$v%";
    String fmtWind(double? v) => v == null ? "—" : "${v.toStringAsFixed(1)} m/s";

    String? iconOf(Map<String, dynamic> m) {
      final w = m["weather"];
      if (w is List && w.isNotEmpty && w.first is Map) {
        return (w.first as Map)["icon"]?.toString();
      }
      return null;
    }

    String descOf(Map<String, dynamic> m) {
      final w = m["weather"];
      if (w is List && w.isNotEmpty && w.first is Map) {
        final d = (w.first as Map)["description"]?.toString();
        if (d != null && d.trim().isNotEmpty) return d.trim();
      }
      return "—";
    }

    final hourlyRaw = (oneCallJson["hourly"] is List) ? (oneCallJson["hourly"] as List) : const [];
    final dailyRaw = (oneCallJson["daily"] is List) ? (oneCallJson["daily"] as List) : const [];

    final hourly = <HourlyForecastViewData>[];
    for (final e in hourlyRaw.take(24)) {
      if (e is! Map) continue;
      final m = Map<String, dynamic>.from(e as Map);
      final dt = toLocalFromDt(m["dt"]);
      hourly.add(
        HourlyForecastViewData(
          timeText: fmtTime(dt),
          tempText: fmtC(asDouble(m["temp"])),
          humText: fmtPct(asInt(m["humidity"])),
          windText: fmtWind(asDouble(m["wind_speed"])),
          descText: descOf(m),
          iconCode: iconOf(m),
        ),
      );
    }

    final daily = <DailyForecastViewData>[];
    for (final e in dailyRaw.take(7)) {
      if (e is! Map) continue;
      final m = Map<String, dynamic>.from(e as Map);
      final dt = toLocalFromDt(m["dt"]);

      double? minT;
      double? maxT;
      final t = m["temp"];
      if (t is Map) {
        final tm = Map<String, dynamic>.from(t as Map);
        minT = asDouble(tm["min"]);
        maxT = asDouble(tm["max"]);
      }

      daily.add(
        DailyForecastViewData(
          dayText: fmtDay(dt),
          minMaxText: "${fmtC(minT)} / ${fmtC(maxT)}",
          humText: fmtPct(asInt(m["humidity"])),
          windText: fmtWind(asDouble(m["wind_speed"])),
          descText: descOf(m),
          iconCode: iconOf(m),
        ),
      );
    }

    final now = DateTime.now();
    final updatedAtText = "${two(now.hour)}:${two(now.minute)} ${two(now.day)}/${two(now.month)}/${now.year}";

    return WeatherForecastViewData(
      updatedAtText: updatedAtText,
      hourly: hourly,
      daily: daily,
    );
  }
}