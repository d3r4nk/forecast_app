import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/models/weather_snapshot.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/openweather_service.dart';
import '../../../core/services/widget_update_service.dart';
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

  String? locationError;

  StreamSubscription<Position>? _posSub;
  Timer? _clockTimer;
  Timer? _weatherTimer;

  bool _initialized = false;

  void init() {
    if (_initialized) return;
    _initialized = true;

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

  Future<bool> _ensureLocationReady() async {
    locationError = null;

    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      locationReady = false;
      locationError = "Location service OFF";
      notifyListeners();
      return false;
    }

    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }

    if (perm == LocationPermission.denied) {
      locationReady = false;
      locationError = "Permission denied";
      notifyListeners();
      return false;
    }

    if (perm == LocationPermission.deniedForever) {
      locationReady = false;
      locationError = "Permission deniedForever";
      notifyListeners();
      return false;
    }

    return true;
  }

  Future<Position?> _getCurrentPositionSafe() async {
    try {
      final p = await _locationService.getCurrent();
      if (p != null) return p;
    } catch (_) {}

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (_) {
      return null;
    }
  }

  Stream<Position> _watchPositionsSafe() {
    try {
      return _locationService.watch();
    } catch (_) {
      return Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      );
    }
  }

  Future<void> _initLocationAndWeather() async {
    final ok = await _ensureLocationReady();
    if (!ok) return;

    final pos = await _getCurrentPositionSafe();
    if (pos == null) {
      locationReady = false;
      locationError = "Insufficient data to verify";
      notifyListeners();
      return;
    }

    lat = pos.latitude;
    lon = pos.longitude;
    locationReady = true;
    notifyListeners();

    await refreshWeather();

    _posSub?.cancel();
    _posSub = _watchPositionsSafe().listen((p) async {
      final prevLat = lat;
      final prevLon = lon;

      lat = p.latitude;
      lon = p.longitude;
      locationReady = true;
      locationError = null;

      final changed = prevLat != lat || prevLon != lon;
      notifyListeners();

      if (changed) {
        await refreshWeather();
      }
    });

    _weatherTimer?.cancel();
    _weatherTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      if (!locationReady) return;
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
      final s = snapshot;
      if (s != null) {
        await WidgetUpdateService.updateFromSnapshot(s);
      }
    } finally {
      weatherLoading = false;
      notifyListeners();
    }
  }
}
