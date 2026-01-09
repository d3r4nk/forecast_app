import 'package:flutter/material.dart';
import 'package:forecast_app/core/app_strings.dart';
import 'package:forecast_app/features/settings/state/settings_state.dart';
import '../../home/state/home_state.dart';
import '../state/weather_forecast_state.dart';

class WeatherForecastPage extends StatefulWidget {
  final SettingsState settings;
  final HomeState home;

  const WeatherForecastPage({
    super.key,
    required this.home,
    required this.settings,
  });

  @override
  State<WeatherForecastPage> createState() => _WeatherForecastPageState();
}

class _WeatherForecastPageState extends State<WeatherForecastPage> {
  late final WeatherDetailState _state;

  @override
  void initState() {
    super.initState();
    _state = WeatherDetailState(
      home: widget.home,
      settings: widget.settings,
    );
    _state.refresh();
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
                  _header(
                    title: strings.weatherForecast,
                    onBack: () => Navigator.pop(context),
                    onRefresh: _state.loading ? null : _state.refresh,
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${strings.updated}: ${v.updatedAtText}",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                        if (_state.loading)
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                      ],
                    ),
                  ),

                  if (_state.error != null && _state.error!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        _state.error!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionTitle(strings.forecastNext24h),
                          const SizedBox(height: 10),
                          _hourlyList(v),

                          const SizedBox(height: 18),
                          _sectionTitle(strings.forecastNext7d),
                          const SizedBox(height: 10),
                          _dailyList(v),
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

  Widget _header({
    required String title,
    required VoidCallback onBack,
    required VoidCallback? onRefresh,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: onBack,
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: onRefresh,
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w900,
        fontSize: 14,
      ),
    );
  }

  Widget _hourlyList(dynamic v) {
    final items = v.hourly;
    if (items.isEmpty) return _emptyCard();

    return SizedBox(
      height: 132,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final it = items[i];
          return Container(
            width: 128,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.92),
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 6)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(it.timeText, style: const TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _owIcon(it.iconCode, size: 34),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        it.tempText,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text("Hum: ${it.humText}", style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                Text("Wind: ${it.windText}", style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _dailyList(dynamic v) {
    final items = v.daily;
    if (items.isEmpty) return _emptyCard();

    return Column(
      children: [
        for (final it in items)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.92),
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 6)),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(it.dayText, style: const TextStyle(fontWeight: FontWeight.w900)),
                      const SizedBox(height: 4),
                      Text(
                        it.descText,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Hum: ${it.humText}  |  Wind: ${it.windText}",
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  children: [
                    _owIcon(it.iconCode, size: 42),
                    const SizedBox(height: 4),
                    Text(it.minMaxText, style: const TextStyle(fontWeight: FontWeight.w900)),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _emptyCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.20),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.25)),
      ),
      child: const Text(
        "—",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _owIcon(String? code, {double size = 40}) {
    if (code == null || code.trim().isEmpty) {
      return Icon(Icons.cloud, color: Colors.black54, size: size);
    }
    final url = "https://openweathermap.org/img/wn/$code@2x.png";
    return Image.network(
      url,
      width: size,
      height: size,
      errorBuilder: (_, __, ___) => Icon(Icons.cloud, color: Colors.black54, size: size),
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