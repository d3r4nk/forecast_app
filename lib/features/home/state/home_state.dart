import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/models/weather_snapshot.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/openweather_service.dart';

class HomeState extends ChangeNotifier {
  final LocationService _locationService;
  final OpenWeatherService _weatherService;

  HomeState({
    LocationService? locationService,
    OpenWeatherService? weatherService,
  })  : _locationService = locationService ?? LocationService(),
        _weatherService = weatherService ?? OpenWeatherService();

  double? lat;
  double? lon;

  DateTime now = DateTime.now();

  WeatherSnapshot? snapshot;

  bool locationReady = false;
  bool weatherLoading = false;

  StreamSubscription<Position>? _posSub;
  Timer? _clockTimer;
  Timer? _weatherTimer;

  void init() {
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      now = DateTime.now();
      notifyListeners();
    });

    _initLocationAndWeather();
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _clockTimer?.cancel();
    _weatherTimer?.cancel();
    super.dispose();
  }

  Future<void> _initLocationAndWeather() async {
    final pos = await _locationService.getCurrent();
    if (pos == null) {
      locationReady = false;
      notifyListeners();
      return;
    }

    lat = pos.latitude;
    lon = pos.longitude;
    locationReady = true;
    notifyListeners();

    await refreshWeather();

    _posSub?.cancel();
    _posSub = _locationService.watch().listen((p) {
      final changed = lat != p.latitude || lon != p.longitude;
      lat = p.latitude;
      lon = p.longitude;
      locationReady = true;
      if (changed) notifyListeners();
    });

    _weatherTimer?.cancel();
    _weatherTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      await refreshWeather();
    });
  }

  Future<void> refreshWeather() async {
    final a = lat;
    final o = lon;
    if (a == null || o == null) return;

    if (weatherLoading) return;
    weatherLoading = true;
    notifyListeners();

    try {
      snapshot = await _weatherService.fetchSnapshot(a, o);
    } finally {
      weatherLoading = false;
      notifyListeners();
    }
  }
}