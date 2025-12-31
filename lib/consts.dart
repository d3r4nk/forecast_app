import 'package:flutter_dotenv/flutter_dotenv.dart';

String get openWeatherApiKey {
  final key = dotenv.env['OPENWEATHER_API_KEY'];
  if (key == null || key.isEmpty) {
    throw Exception('Missing OPENWEATHER_API_KEY in .env');
  }
  return key;
}
