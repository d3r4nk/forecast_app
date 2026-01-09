import 'package:flutter/material.dart';
import 'package:forecast_app/core/app_strings.dart';
import 'package:forecast_app/features/settings/state/settings_state.dart';
import '../../home/state/home_state.dart';
import '../state/weather_detail_state.dart';

class WeatherDetailPage extends StatefulWidget {
  final SettingsState settings;
  final HomeState home;
  const WeatherDetailPage({
    super.key,
    required this.home,
    required this.settings,
  });

  @override
  State<WeatherDetailPage> createState() => _WeatherDetailPageState();
}

class _WeatherDetailPageState extends State<WeatherDetailPage> {
  late final WeatherDetailState _state;

  @override
  void initState() {
    super.initState();
    _state = WeatherDetailState(home: widget.home);
  }

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_state, widget.settings]),
      builder: (context, _) {
        final strings = AppStrings(widget.settings.isEnglish);
        final v = _state.view;
        final double temp = double.tryParse(v.currentTemp.replaceAll(RegExp(r'[^0-9.-]'), '').trim()) ?? 0;
        final double maxTemp = double.tryParse(v.maxTemp.replaceAll(RegExp(r'[^0-9.-]'), '').trim()) ?? 0;

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: _buildGradient(widget.settings.themeIntensity),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  _HearderWeatherDetail(
                    title: strings.weatherDetail,
                    onBack: () => Navigator.pop(context)
                  ),

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _WeatherDetailCard(
                            icon: tempIcon(temp),
                            title: strings.temperature,
                            value: v.currentTemp,
                            accentColor: tempColor(temp),
                          ),
                          const SizedBox(height: 20),
                          _WeatherDetailCard(
                            icon: tempIcon(maxTemp),
                            title: strings.maxTemperatureToday,
                            value: v.maxTemp,
                            accentColor: tempColor(maxTemp),
                          ),
                        ],
                      )
                    )
                  )
                ],
              )
            )
          )
        );
      },
    );
  }
  IconData tempIcon(double temp) {
    if (temp >= 30) return Icons.wb_sunny;
    if (temp <= 15) return Icons.ac_unit;
    return Icons.thermostat;
  }

  Color tempColor(double temp) {
    if (temp >= 30) return Colors.redAccent;
    if (temp <= 15) return Colors.lightBlue;
    return Colors.orange;
  }


  Widget _HearderWeatherDetail({
    required String title,
    required VoidCallback onBack,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            ),
            onPressed: onBack ,
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 48)
        ],
      )
    );
  }

  Widget _WeatherDetailCard({
    required IconData icon,
    required String title,
    required String value,
    required Color accentColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
          color: Colors.black12,
          blurRadius: 16,
          offset: Offset(0, 8)
          ),
        ],
      ),
      child: Row(
        children: [
          //Icon
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 32,
              color: accentColor,
            ),
          ),

          const SizedBox(width: 16),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      )
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