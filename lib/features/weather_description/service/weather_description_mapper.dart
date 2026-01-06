import 'package:intl/intl.dart';
import '../../../core/models/weather_snapshot.dart';
import '../model/weather_description_view_data.dart';

class WeatherDescriptionMapper {
  static const double _msToMph = 2.2369362920544;

  String _fmtTime(DateTime? dt) {
    if (dt == null) return "—";
    return DateFormat("HH:mm").format(dt);
  }

  String _fmtUpdated(DateTime dt) {
    return DateFormat("dd/MM/yyyy HH:mm").format(dt);
  }

  String _fmtTemp(double? c, bool isCelsius) {
    if (c == null) return "—";
    if (isCelsius) return c.toStringAsFixed(1);
    final f = (c * 9 / 5) + 32;
    return f.toStringAsFixed(1);
  }

  WeatherDescriptionViewData toViewData(
      WeatherSnapshot? s, {
        required bool isCelsius,
      }) {
    final loc = [
      s?.areaName,
      s?.country,
    ].where((e) => (e ?? "").trim().isNotEmpty).join(", ");
    final unit = isCelsius ? "°C" : "°F";

    final temp = "${_fmtTemp(s?.tempC, isCelsius)}$unit";
    final feels = "Feels like ${_fmtTemp(s?.feelsLikeC, isCelsius)}$unit";

    final windMs = s?.windSpeedMs;
    final windMph = windMs == null ? null : windMs * _msToMph;
    final windText = windMph == null ? "—" : "${windMph.toStringAsFixed(1)} mph";

    return WeatherDescriptionViewData(
      locationText: loc.isEmpty ? "—" : loc,
      tempText: temp,
      feelsLikeText: feels,
      descriptionText: (s?.description ?? "—"),
      updatedText: s == null ? "Updated: —" : "Updated: ${_fmtUpdated(s.fetchedAt)}",
      windSpeedText: windText,
      sunriseText: _fmtTime(s?.sunrise),
      sunsetText: _fmtTime(s?.sunset),
      icon: s?.icon,
    );
  }
}