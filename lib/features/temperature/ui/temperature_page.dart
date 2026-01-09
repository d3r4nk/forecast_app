import 'package:flutter/material.dart';
import 'package:forecast_app/core/app_strings.dart';
import 'package:forecast_app/features/settings/state/settings_state.dart';
import '../../home/state/home_state.dart';
import '../state/temperature_state.dart';

class TemperaturePage extends StatefulWidget {
  final HomeState home;
  final SettingsState settings;
  const TemperaturePage({
    super.key,
    required this.home,
    required this.settings
  });

  @override
  State<TemperaturePage> createState() => _TemperaturePageState();
}

class _TemperaturePageState extends State<TemperaturePage> {
  late final TemperatureState _state;

  @override
  void initState() {
    super.initState();
    _state = TemperatureState(home: widget.home);
  }

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings(widget.settings.isEnglish);
    return AnimatedBuilder(
      animation: Listenable.merge([_state, widget.settings]),
      builder: (context, _) {
        final v = _state.view;
        return Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: _buildGradient(widget.settings.themeIntensity),
            ),
            child: Column(
              children: [
                // header
                _HearderTemperature(strings: strings.temperature),

                  // Nội dung
                _ContentTemperature(
                  strings: strings.currentTemperature,
                  temperature: v.currentTempC,
                ),
              ],
            ),
          ),
        );
      },
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

class _HearderTemperature extends StatelessWidget {
  const _HearderTemperature({required this.strings});
  final String strings;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: const Icon(Icons.arrow_back, color: Colors.black),
            ),
            const SizedBox(width: 16),
            Text(
              strings,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContentTemperature extends StatelessWidget {
  const _ContentTemperature({
    super.key,
    required this.temperature,
    required this.strings,
  });
  final String strings;
  final String temperature;
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.blue,
                width: 2,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.thermostat,
              size: 48,
              color: Colors.lightBlue,
            ),
          ),
      
          const SizedBox(height: 20),
      
          // Nhiệt độ (lấy từ state)
          Text(
            temperature, // ví dụ: "36°C"
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
      
          const SizedBox(height: 10),
      
          // Mô tả
          Text(
            strings,
            style: TextStyle(
              fontSize: 18,
              color: Colors.black,
            ),
          ),
        ],
      )
    );
  }
}