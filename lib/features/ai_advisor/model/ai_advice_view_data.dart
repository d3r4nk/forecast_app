class AiAdviceViewData {
  final String title;
  final String subtitle;
  final String weatherLine;
  final String adviceText;

  const AiAdviceViewData({
    required this.title,
    required this.subtitle,
    required this.weatherLine,
    required this.adviceText,
  });

  static const empty = AiAdviceViewData(
    title: "AI advisor",
    subtitle: "—",
    weatherLine: "—",
    adviceText: "",
  );
}