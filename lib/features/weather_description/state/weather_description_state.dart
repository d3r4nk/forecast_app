import 'package:flutter/foundation.dart';
import '../../home/state/home_state.dart';
import '../model/weather_description_view_data.dart';
import '../service/weather_description_mapper.dart';

class WeatherDescriptionState extends ChangeNotifier {
  final HomeState _home;
  final WeatherDescriptionMapper _mapper;

  bool isCelsius = true;

  WeatherDescriptionViewData view = const WeatherDescriptionViewData(
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

  WeatherDescriptionState({
    required HomeState home,
    WeatherDescriptionMapper? mapper,
  })  : _home = home,
        _mapper = mapper ?? WeatherDescriptionMapper() {
    _home.addListener(_sync);
    _sync();
  }

  @override
  void dispose() {
    _home.removeListener(_sync);
    super.dispose();
  }

  void toggleUnit(bool celsius) {
    isCelsius = celsius;
    _sync();
  }

  void _sync() {
    view = _mapper.toViewData(_home.snapshot, isCelsius: isCelsius);
    notifyListeners();
  }

  Future<void> refresh() => _home.refreshWeather();
}
