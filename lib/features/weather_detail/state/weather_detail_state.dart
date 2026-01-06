import 'package:flutter/foundation.dart';
import '../../home/state/home_state.dart';
import '../model/weather_detail_view_data.dart';
import '../service/weather_detail_mapper.dart';

class WeatherDetailState extends ChangeNotifier {
  final HomeState _home;
  final WeatherDetailMapper _mapper;

  WeatherDetailViewData view = const WeatherDetailViewData(currentTemp: "—", maxTemp: "—");

  WeatherDetailState({required HomeState home, WeatherDetailMapper? mapper})
      : _home = home,
        _mapper = mapper ?? WeatherDetailMapper() {
    _home.addListener(_sync);
    _sync();
  }

  @override
  void dispose() {
    _home.removeListener(_sync);
    super.dispose();
  }

  void _sync() {
    view = _mapper.toView(_home.snapshot);
    notifyListeners();
  }
}