import 'package:intl/intl.dart';
import '../model/home_header_model.dart';

class HomeFormatter {
  String formatLatLon(double? lat, double? lon) {
    if (lat == null || lon == null) return "Lat: —   Lon: —";
    return "Lat: ${lat.toStringAsFixed(5)}   Lon: ${lon.toStringAsFixed(5)}";
  }

  String formatDateTime(DateTime dt) {
    return DateFormat("dd/MM/yyyy HH:mm:ss").format(dt);
  }

  HomeHeaderModel buildHeader({
    required double? lat,
    required double? lon,
    required DateTime now,
  }) {
    return HomeHeaderModel(
      latLonText: formatLatLon(lat, lon),
      dateTimeText: formatDateTime(now),
    );
  }
}