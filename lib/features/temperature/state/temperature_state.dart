import 'package:flutter/foundation.dart';
import '../../home/state/home_state.dart';
import '../model/temperature_view_data.dart';
import '../service/temperature_mapper.dart';

class TemperatureState extends ChangeNotifier {
  final HomeState _home;
  final TemperatureMapper _mapper;

  TemperatureViewData view = const TemperatureViewData(currentTempC: "—");

  TemperatureState({required HomeState home, TemperatureMapper? mapper})
      : _home = home,
        _mapper = mapper ?? TemperatureMapper() {
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