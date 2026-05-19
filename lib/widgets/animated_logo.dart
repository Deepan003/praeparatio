import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Minimal, professional biology logo — clean DNA double helix
/// on a soft indigo background circle.
class AnimatedLogo extends StatefulWidget {
  final double size;
  final bool interactive;
  final bool autoRotate;

  const AnimatedLogo({
    super.key,
    this.size = 120,
    this.interactive = true,
    this.autoRotate = true,
  });

  @override
  State<AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<AnimatedLogo>
    with TickerProviderStateMixin {
  late AnimationController _scrollCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _tiltCtrl;

  double _tiltX = 0;
  double _tiltY = 0;
  double _targetTiltX = 0;
  double _targetTiltY = 0;

  @override
  void initState() {
    super.initState();

    _scrollCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);

    _tiltCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _tiltCtrl.addListener(() {
      setState(() {
        _tiltX = _tiltX + (_targetTiltX - _tiltX) * _tiltCtrl.value;
        _tiltY = _tiltY + (_targetTiltY - _tiltY) * _tiltCtrl.value;
      });
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _pulseCtrl.dispose();
    _tiltCtrl.dispose();
    super.dispose();
  }

  void _onHover(Offset local) {
    if (!widget.interactive) return;
    final s = widget.size;
    _targetTiltX = (local.dy / s - 0.5) * 0.45;
    _targetTiltY = -(local.dx / s - 0.5) * 0.45;
    _tiltCtrl.forward(from: 0);
  }

  void _onReset() {
    _targetTiltX = 0;
    _targetTiltY = 0;
    _tiltCtrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    return MouseRegion(
      onHover: (e) => _onHover(e.localPosition),
      onExit: (_) => _onReset(),
      cursor: widget.interactive
          ? SystemMouseCursors.resizeUpDown
          : MouseCursor.defer,
      child: GestureDetector(
        onPanUpdate: (d) => _onHover(d.localPosition),
        onPanEnd: (_) => _onReset(),
        child: AnimatedBuilder(
          animation: Listenable.merge([_scrollCtrl, _pulseCtrl]),
          builder: (_, __) => Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateX(_tiltX)
              ..rotateY(_tiltY),
            child: SizedBox(
              width: s,
              height: s,
              child: CustomPaint(
                painter: _HelixPainter(
                  phase: _scrollCtrl.value * 2 * math.pi,
                  pulse: _pulseCtrl.value,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HelixPainter extends CustomPainter {
  final double phase;
  final double pulse; // 0..1

  _HelixPainter({required this.phase, required this.pulse});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    // ── 1. Background circle ─────────────────────────────────
    final bgPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFFF4F2FF), Color(0xFFEAE6FF)],
        stops: [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r));
    canvas.drawCircle(Offset(cx, cy), r, bgPaint);

    // ── 2. Clip to circle so helix doesn't bleed outside ────
    canvas.save();
    canvas.clipPath(Path()
      ..addOval(Rect.fromCircle(center: Offset(cx, cy), radius: r - 1)));

    // ── 3. Draw the helix ───────────────────────────────────
    _drawHelix(canvas, cx, cy, r);

    canvas.restore();

    // ── 4. Thin border ring ─────────────────────────────────
    canvas.drawCircle(
      Offset(cx, cy),
      r - 0.5,
      Paint()
        ..color = AppColors.primary.withOpacity(0.18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // ── 5. Outer glow (subtle) ──────────────────────────────
    final glowOpacity = 0.07 + pulse * 0.05;
    canvas.drawCircle(
      Offset(cx, cy),
      r + 2,
      Paint()
        ..color = AppColors.primary.withOpacity(glowOpacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
  }

  void _drawHelix(Canvas canvas, double cx, double cy, double r) {
    const int segments = 100;
    const int turns = 2; // full twists visible
    const int rungs = 12; // base pair connections
    final helixH = r * 1.8; // taller than the circle — clipped anyway
    final helixTop = cy - helixH / 2;
    final spread = r * 0.32; // horizontal amplitude

    final pts1 = <Offset>[];
    final pts2 = <Offset>[];

    for (int i = 0; i <= segments; i++) {
      final t = i / segments;
      final y = helixTop + t * helixH;
      final angle = t * turns * 2 * math.pi - phase;
      pts1.add(Offset(cx + spread * math.cos(angle), y));
      pts2.add(Offset(cx + spread * math.cos(angle + math.pi), y));
    }

    // ── Rungs (base pairs) — drawn first so strands sit on top ──
    const rungStep = segments ~/ rungs;
    for (int i = 0; i <= segments; i += rungStep) {
      final t = i / segments;
      final angle = t * turns * 2 * math.pi - phase;
      // Depth: cos(angle) gives front/back — affects opacity
      final depth = math.cos(angle);
      final alpha = (0.25 + depth.abs() * 0.55).clamp(0.0, 1.0);

      // Rung line
      canvas.drawLine(
        pts1[i],
        pts2[i],
        Paint()
          ..color = const Color(0xFF9CA3AF).withOpacity(alpha * 0.5)
          ..strokeWidth = 1.2
          ..strokeCap = StrokeCap.round,
      );

      // Nucleotide dots — green on strand1, indigo on strand2
      final dotR = 2.8 + pulse * 0.8;
      canvas.drawCircle(
        pts1[i],
        dotR,
        Paint()..color = AppColors.bioGreen.withOpacity(alpha),
      );
      canvas.drawCircle(
        pts2[i],
        dotR,
        Paint()..color = AppColors.primary.withOpacity(alpha),
      );
    }

    // ── Strand 1 — bio green ────────────────────────────────
    _drawStrand(canvas, pts1, AppColors.bioGreen, 2.5);
    // ── Strand 2 — indigo ──────────────────────────────────
    _drawStrand(canvas, pts2, AppColors.primary, 2.5);
  }

  void _drawStrand(
      Canvas canvas, List<Offset> pts, Color color, double width) {
    if (pts.isEmpty) return;
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (int i = 1; i < pts.length - 1; i++) {
      final xc = (pts[i].dx + pts[i + 1].dx) / 2;
      final yc = (pts[i].dy + pts[i + 1].dy) / 2;
      path.quadraticBezierTo(pts[i].dx, pts[i].dy, xc, yc);
    }
    path.lineTo(pts.last.dx, pts.last.dy);

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_HelixPainter old) =>
      old.phase != phase || old.pulse != pulse;
}
