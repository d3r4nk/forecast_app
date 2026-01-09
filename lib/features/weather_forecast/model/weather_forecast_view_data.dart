class WeatherForecastViewData {
  final String updatedAtText;
  final List<HourlyForecastViewData> hourly;
  final List<DailyForecastViewData> daily;

  const WeatherForecastViewData({
    required this.updatedAtText,
    required this.hourly,
    required this.daily,
  });

  static const empty = WeatherForecastViewData(
    updatedAtText: "—",
    hourly: [],
    daily: [],
  );
}

class HourlyForecastViewData {
  final String timeText;
  final String tempText;
  final String humText;
  final String windText;
  final String descText;
  final String? iconCode;

  const HourlyForecastViewData({
    required this.timeText,
    required this.tempText,
    required this.humText,
    required this.windText,
    required this.descText,
    this.iconCode,
  });
}

class DailyForecastViewData {
  final String dayText;
  final String minMaxText;
  final String humText;
  final String windText;
  final String descText;
  final String? iconCode;

  const DailyForecastViewData({
    required this.dayText,
    required this.minMaxText,
    required this.humText,
    required this.windText,
    required this.descText,
    this.iconCode,
  });
}