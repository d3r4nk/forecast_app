import 'package:flutter/material.dart';
import 'package:forecast_app/core/app_strings.dart';
import 'package:forecast_app/features/settings/state/settings_state.dart';
import '../../home/state/home_state.dart';
import '../state/humidity_state.dart';

class HumidityPage extends StatefulWidget {
  final SettingsState settings;
  final HomeState home;
  const HumidityPage({
    super.key,
    required this.home,
    required this.settings,});

  @override
  State<HumidityPage> createState() => _HumidityPageState();
}

class _HumidityPageState extends State<HumidityPage> {
  late final HumidityState _state;

  @override
  void initState() {
    super.initState();
    _state = HumidityState(home: widget.home);
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
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: _buildGradient(widget.settings.themeIntensity),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  _HeaderHumidity(
                    title: strings.humidity,
                    onBack: () => Navigator.pop(context),
                  ),

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _weatherCard(
                            icon: Icons.water_drop,
                            title: strings.currentHumidity,
                            value: v.currentText,
                            accentColor: Colors.blue
                          ),
                          const SizedBox(height: 20),
                          _weatherCard(
                            icon: Icons.trending_up,
                            title: strings.maxHumidityToday,
                            value: v.maxText,
                            accentColor: Colors.indigo
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _HeaderHumidity({
    required String title,
    required VoidCallback onBack,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            )
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 48)
        ],
      ),
    );
  }

  Widget _weatherCard({
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
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
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

          // Text
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