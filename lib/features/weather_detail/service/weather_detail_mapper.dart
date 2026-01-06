import '../../../core/models/weather_snapshot.dart';
import '../model/weather_detail_view_data.dart';

class WeatherDetailMapper {
  WeatherDetailViewData toView(WeatherSnapshot? s) {
    String fmt(double? v) => v == null ? "—" : "${v.toStringAsFixed(1)}°C";
    return WeatherDetailViewData(
      currentTemp: fmt(s?.tempC),
      maxTemp: fmt(s?.maxTempC),
    );
  }
}