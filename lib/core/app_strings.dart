class AppStrings {
  final bool isEnglish;

  AppStrings(this.isEnglish);

  String get settings => isEnglish ? "Settings" : "Cài đặt";
  String get language => isEnglish ? "Language" : "Ngôn ngữ";
  String get themeIntensity => isEnglish ? "Theme Intensity" : "Độ đậm màu";

  String get temperature => isEnglish ? "Temperature" : "Nhiệt độ";
  String get currentTemperature =>
      isEnglish ? "Current Temperature" : "Nhiệt độ hiện tại";
  String get maxTemperatureToday =>
      isEnglish ? "Max Temperature (Today)" : "Nhiệt độ cao nhất (Hôm nay)";

  String get humidity => isEnglish ? "Humidity Meter" : "Độ ẩm";
  String get weatherDetail => isEnglish ? "Weather Detail" : "Chi tiết thời tiết";
  String get weatherDescription =>
      isEnglish ? "Weather Description" : "Mô tả thời tiết";
  String get english => "English";
  String get vietnamese => "Vietnamese";
  String get maxHumidityToday =>
      isEnglish ? "Max Humidity (Today)" : "Độ ẩm cao nhất (Hôm nay)";
  String get currentHumidity =>
      isEnglish ? "Current Humidity" : "Độ ẩm hiện tại";
  String get fellLike => isEnglish ? "Fell Like" : "Cảm giác như";
  String get windSpeed => isEnglish ? "Wind Speed" : "Tốc độ gió";
  String get wind => isEnglish ? "Wind" : "Gió";
  String get sunriseAndSunset => isEnglish ? "Sunrise & Sunset" : "Bình mình & Hoàng hôn";
  String get speed => isEnglish ? "Speed" : "Tốc độ";
  String get updated => isEnglish ? "Updated" : "Cập nhật lúc";

  String get locationPermissionDenied => isEnglish
      ? "Location permission denied. Please enable it in settings."
      : "Quyền vị trí bị từ chối. Vui lòng bật nó trong cài đặt.";
}
