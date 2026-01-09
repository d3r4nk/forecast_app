import 'package:flutter/material.dart';
@immutable
class WeatherDescriptionViewData {
  final String locationText;
  final String tempText;
  final String feelsLikeText;
  final String descriptionText;
  final String updatedText;
  final String windSpeedText;
  final String sunriseText;
  final String sunsetText;
  final DateTime? sunriseAt;
  final DateTime? sunsetAt;
  final IconData? icon;

  const WeatherDescriptionViewData({
    required this.locationText,
    required this.tempText,
    required this.feelsLikeText,
    required this.descriptionText,
    required this.updatedText,
    required this.windSpeedText,
    required this.sunriseText,
    required this.sunsetText,
    required this.sunriseAt,
    required this.sunsetAt,
    required this.icon,
  });

  WeatherDescriptionViewData copyWith({
    String? locationText,
    String? tempText,
    String? feelsLikeText,
    String? descriptionText,
    String? updatedText,
    String? windSpeedText,
    String? sunriseText,
    String? sunsetText,
    DateTime? sunriseAt,
    DateTime? sunsetAt,
    IconData? icon,
  }) {
    return WeatherDescriptionViewData(
      locationText: locationText ?? this.locationText,
      tempText: tempText ?? this.tempText,
      feelsLikeText: feelsLikeText ?? this.feelsLikeText,
      descriptionText: descriptionText ?? this.descriptionText,
      updatedText: updatedText ?? this.updatedText,
      windSpeedText: windSpeedText ?? this.windSpeedText,
      sunriseText: sunriseText ?? this.sunriseText,
      sunsetText: sunsetText ?? this.sunsetText,
      sunriseAt: sunriseAt ?? this.sunriseAt,
      sunsetAt: sunsetAt ?? this.sunsetAt,
      icon: icon ?? this.icon,
    );
  }
}
