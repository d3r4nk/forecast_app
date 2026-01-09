import 'package:flutter/material.dart';

class SettingsState extends ChangeNotifier {
  Locale locale = const Locale('vi');
  double themeIntensity = 0.7;

  void setLocale(Locale value){
    if (locale == value) return;
    locale = value;
    notifyListeners();
  }

  bool get isEnglish => locale.languageCode == 'en';

  void setIntensity(double value) {
    final newValue = value.clamp(0.3, 1.0);
    if (themeIntensity == newValue) return;
    themeIntensity = newValue;
    notifyListeners();
  }
}