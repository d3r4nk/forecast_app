import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:forecast_app/features/settings/state/settings_state.dart';
import 'package:forecast_app/pages/home_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  final settingsState = SettingsState();
  runApp(MyApp(settingsState: settingsState));
}

class MyApp extends StatefulWidget {
  final SettingsState settingsState;
  const MyApp({
    super.key,
    required this.settingsState,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.settingsState,
      builder: (context, _) {
        return MaterialApp(
          locale: widget.settingsState.locale,
          supportedLocales: const [
            Locale('vi'),
            Locale('en'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          debugShowCheckedModeBanner: false,
          home: HomePage(settings: widget.settingsState),
        );
      }
    );
  }
}
