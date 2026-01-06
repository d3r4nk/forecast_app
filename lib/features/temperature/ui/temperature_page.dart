import 'package:flutter/material.dart';
import '../../home/state/home_state.dart';
import '../state/temperature_state.dart';

class TemperaturePage extends StatefulWidget {
  final HomeState home;
  const TemperaturePage({super.key, required this.home});

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
    return AnimatedBuilder(
      animation: _state,
      builder: (context, _) {
        final v = _state.view;
        return Scaffold(
          appBar: AppBar(title: const Text("Temperature")),
          body: Center(
            child: Text(
              v.currentTempC,
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900),
            ),
          ),
        );
      },
    );
  }
}