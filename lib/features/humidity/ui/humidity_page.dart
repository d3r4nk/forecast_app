import 'package:flutter/material.dart';
import '../../home/state/home_state.dart';
import '../state/humidity_state.dart';

class HumidityPage extends StatefulWidget {
  final HomeState home;
  const HumidityPage({super.key, required this.home});

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
      animation: _state,
      builder: (context, _) {
        final v = _state.view;
        return Scaffold(
          appBar: AppBar(title: const Text("Humidity")),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _card("Current Humidity", v.currentText),
                const SizedBox(height: 12),
                _card("Max Humidity (Today)", v.maxText),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _card(String title, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}