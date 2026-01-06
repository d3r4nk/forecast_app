import '../../../core/models/weather_snapshot.dart';
import '../model/humidity_view_data.dart';

class HumidityMapper {
  HumidityViewData toView(WeatherSnapshot? s) {
    final cur = s?.humidity;
    final max = s?.maxHumidity;

    String fmt(double? v) => v == null ? "—" : "${v.toStringAsFixed(0)}%";

    return HumidityViewData(
      currentText: fmt(cur),
      maxText: fmt(max),
    );
  }
}