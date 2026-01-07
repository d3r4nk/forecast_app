import 'package:flutter/foundation.dart';
import '../../home/state/home_state.dart';
import '../model/ai_advice_view_data.dart';
import '../service/ai_weather_service.dart';

class AiAdvisorState extends ChangeNotifier {
  final HomeState _home;
  final AiWeatherService _service;

  AiAdviceViewData view = AiAdviceViewData.empty;

  bool loading = false;
  String? error;

  AiAdvisorState({
    required HomeState home,
    AiWeatherService? service,
  })  : _home = home,
        _service = service ?? AiWeatherService() {
    _home.addListener(_sync);
    _sync();
  }

  @override
  void dispose() {
    _home.removeListener(_sync);
    super.dispose();
  }

  void _sync() {
    final s = _home.snapshot;
    final lat = _home.lat;
    final lon = _home.lon;

    final subtitle = (s?.areaName == null || (s?.areaName ?? "").trim().isEmpty)
        ? "Vị trí hiện tại"
        : (s!.country == null || (s.country ?? "").trim().isEmpty)
        ? s.areaName!.trim()
        : "${s.areaName!.trim()}, ${s.country!.trim()}";

    final weatherLine = s == null
        ? "Temp: — | Humidity: — | Wind: —"
        : "Temp: ${s.tempC?.toStringAsFixed(1) ?? "—"}°C  |  "
        "Humidity: ${s.humidity?.toStringAsFixed(0) ?? "—"}%  |  "
        "Wind: ${s.windSpeedMs?.toStringAsFixed(1) ?? "—"} m/s";

    view = AiAdviceViewData(
      title: "AI advisor",
      subtitle: "$subtitle  (Lat/Lon: ${lat?.toStringAsFixed(5) ?? "—"}, ${lon?.toStringAsFixed(5) ?? "—"})",
      weatherLine: weatherLine,
      adviceText: view.adviceText,
    );
    notifyListeners();
  }

  Future<void> generateAdvice() async {
    final s = _home.snapshot;
    final lat = _home.lat;
    final lon = _home.lon;

    if (s == null || lat == null || lon == null) {
      error = "Thiếu dữ liệu thời tiết hoặc vị trí.";
      notifyListeners();
      return;
    }

    loading = true;
    error = null;
    notifyListeners();

    try {
      final text = await _service.getAdvice(snapshot: s, lat: lat, lon: lon);
      view = AiAdviceViewData(
        title: view.title,
        subtitle: view.subtitle,
        weatherLine: view.weatherLine,
        adviceText: text.trim(),
      );
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void clear() {
    view = AiAdviceViewData(
      title: view.title,
      subtitle: view.subtitle,
      weatherLine: view.weatherLine,
      adviceText: "",
    );
    error = null;
    notifyListeners();
  }
}