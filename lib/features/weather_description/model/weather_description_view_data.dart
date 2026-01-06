class WeatherDescriptionViewData {
  final String locationText;
  final String tempText;
  final String feelsLikeText;
  final String descriptionText;
  final String updatedText;

  final String windSpeedText;

  final String sunriseText;
  final String sunsetText;

  final String? icon;

  const WeatherDescriptionViewData({
    required this.locationText,
    required this.tempText,
    required this.feelsLikeText,
    required this.descriptionText,
    required this.updatedText,
    required this.windSpeedText,
    required this.sunriseText,
    required this.sunsetText,
    required this.icon,
  });
}