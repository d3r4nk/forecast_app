import '../../../core/models/weather_snapshot.dart';
import '../model/temperature_view_data.dart';

class TemperatureMapper {
  TemperatureViewData toView(WeatherSnapshot? s) {
    final t = s?.tempC;
    final text = t == null ? "—" : "${t.toStringAsFixed(1)}°C";
    return TemperatureViewData(currentTempC: text);
  }
}