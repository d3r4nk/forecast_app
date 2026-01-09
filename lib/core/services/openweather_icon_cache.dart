import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:home_widget/home_widget.dart';

Future<void> cacheOwIconForWidget(String iconCode) async {
  final url = Uri.parse('https://openweathermap.org/img/wn/$iconCode@2x.png');
  final res = await http.get(url);
  if (res.statusCode != 200) return;

  final dir = await getApplicationSupportDirectory();
  final file = File('${dir.path}/ow_$iconCode.png');
  await file.writeAsBytes(res.bodyBytes, flush: true);

  await HomeWidget.saveWidgetData<String>('w_icon_path', file.path);
  await HomeWidget.updateWidget(name: 'WeatherQuickWidgetProvider');
}
