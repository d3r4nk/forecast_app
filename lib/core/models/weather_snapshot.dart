class WeatherSnapshot {
  final double? tempC;
  final double? feelsLikeC;
  final double? windSpeedMs;
  final double? humidity;

  final double? maxTempC;
  final double? maxHumidity;

  final String? description;
  final String? icon;

  final String? areaName;
  final String? country;

  final DateTime? sunrise;
  final DateTime? sunset;

  final DateTime fetchedAt;

  const WeatherSnapshot({
    required this.fetchedAt,
    this.tempC,
    this.feelsLikeC,
    this.windSpeedMs,
    this.humidity,
    this.maxTempC,
    this.maxHumidity,
    this.description,
    this.icon,
    this.areaName,
    this.country,
    this.sunrise,
    this.sunset,
  });
}