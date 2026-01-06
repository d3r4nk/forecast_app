import 'package:flutter/material.dart';
import '../features/home/state/home_state.dart';
import '../features/home/ui/home_menu_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

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
    return HomeMenuPage(state: _state);
  }
}