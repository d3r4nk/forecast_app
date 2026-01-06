import 'package:flutter/foundation.dart';
import '../../home/state/home_state.dart';
import '../model/humidity_view_data.dart';
import '../service/humidity_mapper.dart';

class HumidityState extends ChangeNotifier {
  final HomeState _home;
  final HumidityMapper _mapper;

  HumidityViewData view = const HumidityViewData(currentText: "—", maxText: "—");

  HumidityState({required HomeState home, HumidityMapper? mapper})
      : _home = home,
        _mapper = mapper ?? HumidityMapper() {
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