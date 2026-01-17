import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<bool> ensurePermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  Future<Position?> getCurrent({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final ok = await ensurePermission();
    if (!ok) return null;

    //  Try fresh position with timeout (avoid hanging)
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
        ),
      ).timeout(timeout);
      return pos;
    } on TimeoutException {
      // last known (cached)
      try {
        final cached = await Geolocator.getLastKnownPosition();
        if (cached != null) return cached;
      } catch (_) {}

      //  try again with lower accuracy & shorter timeout
      try {
        return await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.low,
          ),
        ).timeout(const Duration(seconds: 5));
      } catch (_) {
        return null;
      }
    } catch (_) {
      //  last known (cached)
      try {
        final cached = await Geolocator.getLastKnownPosition();
        if (cached != null) return cached;
      } catch (_) {}

      //  try again with lower accuracy & shorter timeout
      try {
        return await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.low,
          ),
        ).timeout(const Duration(seconds: 5));
      } catch (_) {
        return null;
      }
    }
  }

  Stream<Position> watch({
    int distanceFilter = 5,
    Duration interval = const Duration(seconds: 2),
  }) {
    final LocationSettings settings;

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      settings = AndroidSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: distanceFilter,
        intervalDuration: interval,
      );
    } else if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      settings = AppleSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: distanceFilter,
      );
    } else {
      settings = LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: distanceFilter,
      );
    }

    return Geolocator.getPositionStream(locationSettings: settings);
  }
}
