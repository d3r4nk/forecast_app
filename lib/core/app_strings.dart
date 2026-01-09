class AppStrings {
  final bool isEnglish;
  AppStrings(this.isEnglish);
  String get settings => isEnglish ? "Settings" : "Cài đặt";
  String get language => isEnglish ? "Language" : "Ngôn ngữ";
  String get themeIntensity => isEnglish ? "Theme Intensity" : "Độ đậm màu";
  String get advisor => isEnglish ? "AI advisor" : "Cố vấn AI";
  String get temperature => isEnglish ? "Temperature" : "Nhiệt độ";
  String get currentTemperature =>
      isEnglish ? "Current Temperature" : "Nhiệt độ hiện tại";
  String get maxTemperatureToday =>
      isEnglish ? "Max Temperature (Today)" : "Nhiệt độ cao nhất (Hôm nay)";

  String get humidity => isEnglish ? "Humidity Meter" : "Độ ẩm";
  String get maxHumidityToday =>
      isEnglish ? "Max Humidity (Today)" : "Độ ẩm cao nhất (Hôm nay)";
  String get currentHumidity =>
      isEnglish ? "Current Humidity" : "Độ ẩm hiện tại";
  String get weatherForecast => isEnglish ? "Weather forecast" : "Dự báo thời tiết";
  String get forecastNext24h => isEnglish ? "Next 24 hours" : "24 giờ tới";
  String get forecastNext7d => isEnglish ? "Next 7 days" : "7 ngày tới";
  String get updated => isEnglish ? "Updated" : "Cập nhật lúc";
  String get refresh => isEnglish ? "Refresh" : "Làm mới";

  String get weatherDescription =>
      isEnglish ? "Weather Description" : "Mô tả thời tiết";

  String get english => "English";
  String get vietnamese => "Vietnamese";

  String get fellLike => isEnglish ? "Fell Like" : "Cảm giác như";
  String get windSpeed => isEnglish ? "Wind Speed" : "Tốc độ gió";
  String get wind => isEnglish ? "Wind" : "Gió";
  String get sunriseAndSunset =>
      isEnglish ? "Sunrise & Sunset" : "Bình mình & Hoàng hôn";
  String get speed => isEnglish ? "Speed" : "Tốc độ";

  String get locationPermissionDenied => isEnglish
      ? "Location permission denied. Please enable it in settings."
      : "Quyền vị trí bị từ chối. Vui lòng bật nó trong cài đặt.";

  String get missingLocation =>
      isEnglish ? "Missing location." : "Thiếu vị trí.";
  String get forecastLoadError =>
      isEnglish ? "Failed to load forecast." : "Không tải được dự báo.";
}