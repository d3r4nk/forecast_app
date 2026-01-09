// lib/features/ai_advisor/ui/ai_advisor_page.dart
import 'package:flutter/material.dart';
import 'package:forecast_app/features/settings/state/settings_state.dart';
import '../../home/state/home_state.dart';
import '../state/ai_advisor_state.dart';

class AiAdvisorPage extends StatefulWidget {
  final HomeState home;
  final SettingsState settings;

  const AiAdvisorPage({
    super.key,
    required this.home,
    required this.settings,
  });

  @override
  State<AiAdvisorPage> createState() => _AiAdvisorPageState();
}

class _AiAdvisorPageState extends State<AiAdvisorPage> {
  late final AiAdvisorState _state;

  @override
  void initState() {
    super.initState();
    _state = AiAdvisorState(
      home: widget.home,
      settings: widget.settings,
    );
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
        final v = _state.view;

        final isEn = widget.settings.isEnglish;
        final title = isEn ? "AI advisor" : "Cố vấn AI";
        final btnText = isEn ? "Generate advice" : "Tạo lời khuyên";
        final btnLoading = isEn ? "Generating..." : "Đang tạo...";
        final emptyHint = isEn
            ? "Press Generate advice to get analysis."
            : "Nhấn Tạo lời khuyên để nhận phân tích.";

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
                          icon: Icons.arrow_back_ios,
                          onTap: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            title,
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        _iconButton(
                          icon: Icons.refresh,
                          onTap: _state.loading ? null : _state.generateAdvice,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _infoCard(
                      title: v.subtitle,
                      subtitle: v.weatherLine,
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: _adviceCard(emptyHint: emptyHint),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _primaryButton(
                            label: _state.loading ? btnLoading : btnText,
                            onTap: _state.loading ? null : _state.generateAdvice,
                          ),
                        ),
                        const SizedBox(width: 10),
                        _secondaryButton(
                          icon: Icons.delete_outline,
                          onTap: _state.loading ? null : _state.clear,
                        ),
                      ],
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

  Widget _infoCard({required String title, required String subtitle}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _adviceCard({required String emptyHint}) {
    final text = _state.view.adviceText;
    final err = _state.error;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.20)),
      ),
      child: _state.loading
          ? const Center(child: CircularProgressIndicator())
          : (err != null && err.isNotEmpty)
          ? SingleChildScrollView(
        child: Text(
          err,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      )
          : (text.isEmpty)
          ? Center(
        child: Text(
          emptyHint,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
      )
          : SingleChildScrollView(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
            height: 1.35,
          ),
        ),
      ),
    );
  }

  Widget _iconButton({required IconData icon, required VoidCallback? onTap}) {
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

  Widget _primaryButton({required String label, required VoidCallback? onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: onTap == null ? Colors.white.withOpacity(0.25) : Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: onTap == null ? Colors.white : const Color(0xFF0B4AA6),
            fontWeight: FontWeight.w900,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _secondaryButton({required IconData icon, required VoidCallback? onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.18),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.20)),
        ),
        child: Icon(icon, color: Colors.white),
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
