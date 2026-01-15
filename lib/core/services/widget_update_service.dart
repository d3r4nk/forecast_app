import 'package:home_widget/home_widget.dart';
import '../../consts.dart';
import '../models/weather_snapshot.dart';
class WidgetUpdateService {
  static const String _androidProvider = 'WeatherQuickWidgetProvider';
  static Future<void> updateFromSnapshot(
      WeatherSnapshot s, {
        double? lat,
        double? lon,
      }) async {
    final temp = s.tempC == null ? '—' : '${s.tempC!.toStringAsFixed(1)}°C';
    final hum = s.humidity == null ? '—' : '${s.humidity!.toStringAsFixed(0)}%';
    final wind =
    s.windSpeedMs == null ? '—' : '${s.windSpeedMs!.toStringAsFixed(1)} m/s';
    final desc = (s.description ?? '').trim().isEmpty ? '—' : s.description!.trim();
    final iconCode = (s.iconCode ?? '').trim();
    final iconSafe = iconCode.isEmpty ? 'na' : iconCode;
    final updated = s.fetchedAt.toLocal();
    final hh = updated.hour.toString().padLeft(2, '0');
    final mm = updated.minute.toString().padLeft(2, '0');
    final dd = updated.day.toString().padLeft(2, '0');
    final mo = updated.month.toString().padLeft(2, '0');
    final yy = updated.year.toString();
    final updatedText = '$dd/$mo/$yy $hh:$mm';
    await HomeWidget.saveWidgetData<String>('w_temp', temp);
    await HomeWidget.saveWidgetData<String>('w_hum', hum);
    await HomeWidget.saveWidgetData<String>('w_wind', wind);
    await HomeWidget.saveWidgetData<String>('w_desc', desc);
    await HomeWidget.saveWidgetData<String>('w_icon', iconSafe);
    await HomeWidget.saveWidgetData<String>('w_updated', updatedText);
    if (lat != null) {
      await HomeWidget.saveWidgetData<double>('w_lat', lat);
    }
    if (lon != null) {
      await HomeWidget.saveWidgetData<double>('w_lon', lon);
    }
    try {
      final key = openWeatherApiKey;
      if (key.trim().isNotEmpty) {
        await HomeWidget.saveWidgetData<String>('w_ow_key', key.trim());
      }
    } catch (_) {}

    await HomeWidget.updateWidget(name: _androidProvider);
  }
}
