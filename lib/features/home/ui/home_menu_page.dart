// lib/features/home/ui/home_menu_page.dart
import 'package:flutter/material.dart';
import 'package:forecast_app/core/app_strings.dart';
import 'package:forecast_app/features/settings/state/settings_state.dart';
import '../state/home_state.dart';
import '../service/home_formatter.dart';
import '../../ai_advisor/ui/ai_advisor_page.dart';
import '../../humidity/ui/humidity_page.dart';
import '../../temperature/ui/temperature_page.dart';
import '../../weather_detail/ui/weather_detail_page.dart';
import '../../weather_description/ui/weather_description_page.dart';
import '../../settings/ui/settings_page.dart';

class HomeMenuPage extends StatelessWidget {
  final HomeState state;
  final SettingsState settings;
  HomeMenuPage({
    super.key,
    required this.state,
    required this.settings,
  });

  final HomeFormatter _fmt = HomeFormatter();

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings(settings.isEnglish);
    return AnimatedBuilder(
      animation: Listenable.merge([state, settings]),
      builder: (context, _) {
        final header = _fmt.buildHeader(lat: state.lat, lon: state.lon, now: state.now);

        return Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: _buildGradient(settings.themeIntensity),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            header.latLonText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          header.dateTimeText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _menuItem(
                      context,
                      title: strings.humidity,
                      iconBg: const Color(0xFFD7F1FF),
                      icon: Icons.water_drop,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => HumidityPage(home: state, settings: settings)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _menuItem(
                      context,
                      title: strings.weatherDetail,
                      iconBg: const Color(0xFFFFF0BF),
                      icon: Icons.wb_sunny,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => WeatherDetailPage(home: state, settings: settings)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _menuItem(
                      context,
                      title: strings.temperature,
                      iconBg: const Color(0xFFFFD6D6),
                      icon: Icons.thermostat,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => TemperaturePage(home: state, settings: settings)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _menuItem(
                      context,
                      title: strings.weatherDescription,
                      iconBg: const Color(0xFFE6DDFF),
                      icon: Icons.cloud,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => WeatherDescriptionPage(home: state, settings: settings)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _menuItem(
                      context,
                      title: strings.settings,
                      iconBg: const Color(0xFFE6DDFF),
                      icon: Icons.settings,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => SettingsPage(settings: settings)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (!state.locationReady)
                      Text(
                        strings.locationPermissionDenied,
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _menuItem(
      BuildContext context, {
        required String title,
        required Color iconBg,
        required IconData icon,
        required VoidCallback onTap,
      }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 12,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFF0B4AA6)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF1A1A1A)),
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
        Color.lerp(const Color(0xFF0B4AA6), Colors.white, 1 - intensity)!,
        Color.lerp(const Color(0xFF0F66D0), Colors.white, 1 - intensity)!,
      ],
    );
  }
}
