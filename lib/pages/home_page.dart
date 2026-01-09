import 'package:flutter/material.dart';
import '../features/home/state/home_state.dart';
import '../features/home/ui/home_menu_page.dart';
import '../features/settings/state/settings_state.dart';

class HomePage extends StatefulWidget {
  final SettingsState settings;
  const HomePage({
    super.key,
    required this.settings,  
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeState _state;

  @override
  void initState() {
    super.initState();
    _state = HomeState()..init();
  }

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.settings,
      builder: (context, _) {
        return HomeMenuPage(
          state: _state,
          settings: widget.settings,
        );
      }
    );
  }
}