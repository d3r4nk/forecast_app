import 'dart:async';
import 'package:flutter/material.dart';
import 'package:weather/weather.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../consts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final WeatherFactory _wf;

  Weather? _weather;

  double? _lat;
  double? _lon;

  String? _placeName;

  StreamSubscription<Position>? _posSub;

  bool _fetchingWeather = false;
  bool _fetchingPlace = false;

  Timer? _clockTimer;
  Timer? _weatherTimer;

  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _wf = WeatherFactory(openWeatherApiKey);
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _now = DateTime.now());
    });

    _startLocationTracking();
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _clockTimer?.cancel();
    _weatherTimer?.cancel();
    super.dispose();
  }

  Future<void> _startLocationTracking() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    final current = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
    );

    _updateLatLon(current.latitude, current.longitude);

    await Future.wait([
      _fetchPlaceName(_lat!, _lon!),
      _fetchWeather(_lat!, _lon!),
    ]);

    const settings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 5, // giảm để update thường xuyên hơn
    );

    _posSub =
        Geolocator.getPositionStream(locationSettings: settings).listen((pos) {
          _updateLatLon(pos.latitude, pos.longitude);
          _fetchPlaceName(_lat!, _lon!);
        });
    _weatherTimer?.cancel();
    _weatherTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      final lat = _lat;
      final lon = _lon;
      if (lat == null || lon == null) return;
      await _fetchWeather(lat, lon);
    });
  }

  void _updateLatLon(double lat, double lon) {
    if (!mounted) return;
    setState(() {
      _lat = lat;
      _lon = lon;
    });
  }

  Future<void> _fetchWeather(double lat, double lon) async {
    if (_fetchingWeather) return;
    _fetchingWeather = true;
    try {
      final w = await _wf.currentWeatherByLocation(lat, lon);
      if (!mounted) return;
      setState(() => _weather = w);
    } finally {
      _fetchingWeather = false;
    }
  }

  Future<void> _fetchPlaceName(double lat, double lon) async {
    if (_fetchingPlace) return;
    _fetchingPlace = true;
    try {
      final placemarks = await placemarkFromCoordinates(lat, lon);
      if (!mounted) return;

      String? name;
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        name = _firstNonEmpty([
          p.locality,
          p.subAdministrativeArea,
          p.administrativeArea,
          p.country,
        ]);
      }

      if (!mounted) return;
      setState(() => _placeName = name);
    } catch (_) {
      // giữ nguyên _placeName nếu geocoding fail
    } finally {
      _fetchingPlace = false;
    }
  }

  String? _firstNonEmpty(List<String?> xs) {
    for (final x in xs) {
      final s = x?.trim();
      if (s != null && s.isNotEmpty) return s;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2238E8),
              Color(0xFF14A7FD),
            ],
          ),
        ),
        child: SafeArea(child: _buildUI()),
      ),
    );
  }

  Widget _buildUI() {
    if (_weather == null) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      height: MediaQuery.sizeOf(context).height,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _locationHeader(),
          const SizedBox(height: 6),
          _latLonInfo(),
          SizedBox(height: MediaQuery.sizeOf(context).height * 0.08),
          _dateTimeInfo(),
          SizedBox(height: MediaQuery.sizeOf(context).height * 0.05),
          _tempHumBox(),
        ],
      ),
    );
  }

  Widget _locationHeader() {
    final title = _placeName ?? _weather?.areaName ?? "";
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
    );
  }

  Widget _latLonInfo() {
    final lat = _lat;
    final lon = _lon;

    return Text(
      lat == null || lon == null
          ? "Lat: --, Lon: --"
          : "Lat: ${lat.toStringAsFixed(6)}, Lon: ${lon.toStringAsFixed(6)}",
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: Colors.white70,
      ),
    );
  }
  Widget _dateTimeInfo() {
    final DateTime now = _now;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          DateFormat("h:mm:ss a").format(now),
          style: const TextStyle(
            fontSize: 35,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              DateFormat("EEEE").format(now),
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              DateFormat("d.M.y").format(now),
              style: const TextStyle(
                fontWeight: FontWeight.w400,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _tempHumBox() {
    final temp = _weather?.temperature?.celsius;
    final hum = _weather?.humidity;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF0B4AA6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Temperature: ",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                temp == null ? "--°C" : "${temp.toStringAsFixed(0)}°C",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Humidity: ",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                hum == null ? "--%" : "${hum.toStringAsFixed(0)}%",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
