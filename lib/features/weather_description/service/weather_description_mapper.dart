import 'package:flutter/material.dart';
import '../../../core/models/weather_snapshot.dart';
import '../model/weather_description_view_data.dart';

class WeatherDescriptionMapper {
  WeatherDescriptionViewData toViewData(WeatherSnapshot? s, {required bool isCelsius}) {
    if (s == null) {
      return const WeatherDescriptionViewData(
        locationText: "—",
        tempText: "—",
        feelsLikeText: "Feels like —",
        descriptionText: "—",
        updatedText: "Updated: —",
        windSpeedText: "—",
        sunriseText: "—",
        sunsetText: "—",
        sunriseAt: null,
        sunsetAt: null,
        icon: null,
      );
    }

    final tempC = s.tempC;
    final feelsC = s.feelsLikeC;
    final temp = tempC == null ? null : (isCelsius ? tempC : (tempC * 9 / 5) + 32);
    final feels = feelsC == null ? null : (isCelsius ? feelsC : (feelsC * 9 / 5) + 32);

    final unit = isCelsius ? "°C" : "°F";

    return WeatherDescriptionViewData(
      locationText: [
        if ((s.areaName ?? "").trim().isNotEmpty) s.areaName!.trim(),
        if ((s.country ?? "").trim().isNotEmpty) s.country!.trim(),
      ].join(", ").isEmpty
          ? "—"
          : [
        if ((s.areaName ?? "").trim().isNotEmpty) s.areaName!.trim(),
        if ((s.country ?? "").trim().isNotEmpty) s.country!.trim(),
      ].join(", "),
      tempText: temp == null ? "—" : "${temp.toStringAsFixed(1)}$unit",
      feelsLikeText: feels == null ? "Feels like —" : "Feels like ${feels.toStringAsFixed(1)}$unit",
      descriptionText: (s.description ?? "—").trim().isEmpty ? "—" : s.description!.trim(),
      updatedText: s.fetchedAt == null ? "Updated: —" : "Updated: ${_fmtTime(s.fetchedAt!)}",
      windSpeedText: s.windSpeedMs == null ? "—" : "${s.windSpeedMs!.toStringAsFixed(1)} m/s",
      sunriseText: s.sunrise == null ? "—" : _fmtTime(s.sunrise!),
      sunsetText: s.sunset == null ? "—" : _fmtTime(s.sunset!),
      sunriseAt: s.sunrise,
      sunsetAt: s.sunset,
      icon: _iconFromDescription(s.description),
    );
  }

  String _fmtTime(DateTime d) {
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    return "$hh:$mm";
  }

  IconData? _iconFromDescription(String? desc) {
    final t = (desc ?? "").toLowerCase();
    if (t.contains("rain")) return Icons.water_drop;
    if (t.contains("cloud")) return Icons.cloud;
    if (t.contains("clear")) return Icons.wb_sunny;
    if (t.contains("thunder")) return Icons.flash_on;
    return Icons.cloud;
  }
}
