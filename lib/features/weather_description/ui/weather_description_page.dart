import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:forecast_app/core/app_strings.dart';
import 'package:forecast_app/features/settings/state/settings_state.dart';
import '../../home/state/home_state.dart';
import '../state/weather_description_state.dart';

class WeatherDescriptionPage extends StatefulWidget {
  final SettingsState settings;
  final HomeState home;
  const WeatherDescriptionPage({
    super.key,
    required this.home,
    required this.settings,
  });

  @override
  State<WeatherDescriptionPage> createState() => _WeatherDescriptionPageState();
}

class _WeatherDescriptionPageState extends State<WeatherDescriptionPage> {
  late final WeatherDescriptionState _state;

  @override
  void initState() {
    super.initState();
    _state = WeatherDescriptionState(home: widget.home);
  }

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_state, widget.settings, widget.home]),
      builder: (context, _) {
        final v = _state.view;
        final strings = AppStrings(widget.settings.isEnglish);

        final snap = widget.home.snapshot;
        final sunriseDt = snap?.sunrise;
        final sunsetDt = snap?.sunset;
        final now = widget.home.now;

        return Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: _buildGradient(widget.settings.themeIntensity),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _iconButton(
                          icon: Icons.arrow_back,
                          onTap: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            v.locationText,
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
                        _iconButton(
                          icon: Icons.refresh,
                          onTap: () => _state.refresh(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Text(
                              v.tempText,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 56,
                                height: 1.0,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              v.feelsLikeText,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 10),
                            if (v.icon != null)
                              Image.network(
                                "https://openweathermap.org/img/wn/${v.icon}@4x.png",
                                width: 88,
                                height: 88,
                                errorBuilder: (_, __, ___) => const SizedBox(height: 88),
                              ),
                            Text(
                              v.descriptionText,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 10),
                            _unitToggle(),
                            const SizedBox(height: 10),
                            Text(
                              v.updatedText,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _sectionTitle(strings.wind),
                            const SizedBox(height: 10),
                            _windCard(v.windSpeedText, strings: strings.speed),
                            const SizedBox(height: 18),
                            _sectionTitle(strings.sunriseAndSunset),
                            const SizedBox(height: 10),
                            _sunCard(
                              sunrise: v.sunriseText,
                              sunset: v.sunsetText,
                              sunriseDt: sunriseDt,
                              sunsetDt: sunsetDt,
                              now: now,
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
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

  Widget _iconButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.18),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withOpacity(0.20)),
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }

  Widget _unitToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _unitChip(label: "°C", selected: _state.isCelsius, onTap: () => _state.toggleUnit(true)),
          const SizedBox(width: 8),
          _unitChip(label: "°F", selected: !_state.isCelsius, onTap: () => _state.toggleUnit(false)),
        ],
      ),
    );
  }

  Widget _unitChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? const Color(0xFF0B4AA6) : Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.18),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withOpacity(0.20)),
          ),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _windCard(String windText, {required String strings}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.20)),
      ),
      child: Column(
        children: [
          const Icon(Icons.air, color: Colors.white, size: 28),
          const SizedBox(height: 10),
          Text(
            "$strings $windText",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  double? _sunProgress({required DateTime now, DateTime? sunrise, DateTime? sunset}) {
    if (sunrise == null || sunset == null) return null;
    final total = sunset.difference(sunrise);
    if (total.inSeconds <= 0) return null;

    if (now.isBefore(sunrise)) return 0.0;
    if (now.isAfter(sunset)) return 1.0;

    final passed = now.difference(sunrise);
    final p = passed.inSeconds / total.inSeconds;
    if (p.isNaN || p.isInfinite) return null;
    return p.clamp(0.0, 1.0);
  }

  Widget _sunCard({
    required String sunrise,
    required String sunset,
    required DateTime? sunriseDt,
    required DateTime? sunsetDt,
    required DateTime now,
  }) {
    final progress = _sunProgress(now: now, sunrise: sunriseDt, sunset: sunsetDt);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.20)),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 150,
            child: CustomPaint(
              painter: _SunArcPainter(progress: progress),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.wb_sunny, color: Colors.white, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            sunrise,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            sunset,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.nights_stay, color: Colors.white, size: 16),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
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

class _SunArcPainter extends CustomPainter {
  final double? progress;

  _SunArcPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final arcPaint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final center = Offset(size.width / 2, size.height * 0.95);
    final radius = math.min(size.width, size.height) * 0.42;

    final path = Path()
      ..addArc(
        Rect.fromCircle(center: center, radius: radius),
        math.pi,
        math.pi,
      );

    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return;

    final metric = metrics.first;
    const dash = 8.0;
    const gap = 6.0;
    double dist = 0.0;

    while (dist < metric.length) {
      final len = math.min(dash, metric.length - dist);
      final extract = metric.extractPath(dist, dist + len);
      canvas.drawPath(extract, arcPaint);
      dist += dash + gap;
    }

    final p = progress;
    if (p == null) return;

    final angle = math.pi + (math.pi * p);
    final sunCenter = Offset(
      center.dx + radius * math.cos(angle),
      center.dy + radius * math.sin(angle),
    );

    final glow = Paint()
      ..color = Colors.white.withOpacity(0.25)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(sunCenter, 10, glow);

    final sunPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(sunCenter, 6, sunPaint);
  }

  @override
  bool shouldRepaint(covariant _SunArcPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
