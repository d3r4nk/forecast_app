import 'package:flutter/material.dart';
import 'package:forecast_app/core/app_strings.dart';
import 'package:forecast_app/features/settings/state/settings_state.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({
    super.key,
    required this.settings,
    });

  final SettingsState settings;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: settings,
      builder: (context, _) {
        final strings = AppStrings(settings.isEnglish);
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: _buildGradient(settings.themeIntensity),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HeaderSettings(
                    title: strings.settings,
                    onBack: () => Navigator.pop(context),
                  ),
                  _LanguageSetting(
                    strings: strings.language,
                  ),
                  const SizedBox(height: 24),
                    
                  _ThemeIntensitySetting(
                    strings: strings.themeIntensity,
                    intensity: settings.themeIntensity,
                    onChanged: settings.setIntensity,
                  ),
                ],
              )
            ),
          ),
        );
      }
    );
  }

  Widget _HeaderSettings({
    required String title,
    required VoidCallback onBack,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: onBack,
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: Colors.white
              ),
            )
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _ThemeIntensitySetting({
    required String strings,
    required double intensity,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          strings,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        Slider(
          value: intensity,
          min: 0.3,
          max: 1.0,
          divisions: 10,
          label: intensity.toStringAsFixed(1),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _LanguageSetting({required String strings}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          strings,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        _languageOption(
          title: "English",
          locale: const Locale('en'),
        ),
        const SizedBox(height: 8),

        _languageOption(
          title: "Vietnamese",
          locale: const Locale('vi'),
        ),
      ],
    );
  }

  Widget _languageOption({
    required String title,
    required Locale locale,
  }) {
    final bool selected = settings.locale.languageCode == locale.languageCode;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: selected ? null : () => settings.setLocale(locale),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? Colors.blue : Colors.black12,
            width: selected ? 2 : 1,
          ),
          color: selected ? Colors.blue.withOpacity(0.08) : Colors.transparent,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.red : Colors.black,
                ),
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle, color: Colors.blue)
          ],
        ),
      ),
    );
  }
  LinearGradient _buildGradient(double intensity) {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color.lerp(const Color.fromARGB(255, 68, 130, 222), Colors.white, 1 - intensity)!,
        Color.lerp(const Color(0xFF0F66D0), Colors.white, 1 - intensity)!,
      ],
    );
  }
}