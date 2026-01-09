import 'dart:math' as math;
import 'package:flutter/material.dart';

class SunriseSunsetArc extends StatelessWidget {
  final DateTime? sunrise;
  final DateTime? sunset;
  final double height;
  const SunriseSunsetArc({
    super.key,
    required this.sunrise,
    required this.sunset,
    this.height = 110,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    final p = _progress(now, sunrise, sunset);
    final hasData = sunrise != null && sunset != null;

    return SizedBox(
      height: height,
      width: double.infinity,
      child: LayoutBuilder(
        builder: (_, c) {
          final w = c.maxWidth;
          final h = height;
          final r = math.min(w / 2, h) * 0.92;
          final cx = w / 2;
          final cy = h;

          Offset? sun;
          if (hasData && p != null) {
            final angle = math.pi * (1 - p);
            final x = cx + r * math.cos(angle);
            final y = cy - r * math.sin(angle);
            sun = Offset(x, y);
          }

          return Stack(
            clipBehavior: Clip.none,
            children: [
              CustomPaint(
                size: Size(w, h),
                painter: _ArcPainter(),
              ),
              if (sun != null)
                Positioned(
                  left: sun.dx - 10,
                  top: sun.dy - 10,
                  child: _SunDot(dim: _isDay(now, sunrise, sunset) ? 1.0 : 0.45),
                ),
            ],
          );
        },
      ),
    );
  }

  bool _isDay(DateTime now, DateTime? sr, DateTime? ss) {
    if (sr == null || ss == null) return false;
    return now.isAfter(sr) && now.isBefore(ss);
  }

  double? _progress(DateTime now, DateTime? sr, DateTime? ss) {
    if (sr == null || ss == null) return null;
    final total = ss.difference(sr).inMilliseconds;
    if (total <= 0) return null;

    if (now.isBefore(sr)) return 0.0;
    if (now.isAfter(ss)) return 1.0;

    final done = now.difference(sr).inMilliseconds;
    final p = done / total;
    return p.clamp(0.0, 1.0);
  }
}

class _SunDot extends StatelessWidget {
  final double dim;
  const _SunDot({required this.dim});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: dim,
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.65),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Icon(Icons.wb_sunny, size: 14, color: Color(0xFF0B4AA6)),
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final r = math.min(w / 2, h) * 0.92;
    final center = Offset(w / 2, h);

    final rect = Rect.fromCircle(center: center, radius: r);

    final paint = Paint()
      ..color = Colors.white.withOpacity(0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path()..addArc(rect, math.pi, -math.pi);

    _drawDashedPath(canvas, path, paint, dash: 6, gap: 6);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint,
      {required double dash, required double gap}) {
    for (final m in path.computeMetrics()) {
      double dist = 0;
      while (dist < m.length) {
        final len = math.min(dash, m.length - dist);
        final seg = m.extractPath(dist, dist + len);
        canvas.drawPath(seg, paint);
        dist += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
