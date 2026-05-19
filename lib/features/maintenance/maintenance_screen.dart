import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';

class MaintenanceScreen extends StatefulWidget {
  final VoidCallback onAdminTap;
  final VoidCallback? onLogout;
  const MaintenanceScreen({super.key, required this.onAdminTap, this.onLogout});

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen>
    with TickerProviderStateMixin {
  late AnimationController _gearCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _dotCtrl;

  @override
  void initState() {
    super.initState();
    _gearCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _dotCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat();
  }

  @override
  void dispose() {
    _gearCtrl.dispose();
    _pulseCtrl.dispose();
    _dotCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F0C29), Color(0xFF302B63), Color(0xFF24243E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(children: [
          // Ambient glow background
          Positioned.fill(child: _AmbientGlow(ctrl: _pulseCtrl)),
          // Grid pattern overlay
          Positioned.fill(child: _GridOverlay()),
          // Main content
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Animated gears
                    _GearGroup(gearCtrl: _gearCtrl),
                    const SizedBox(height: 40),

                    // Title
                    const Text(
                      'Under Maintenance',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.5,
                        height: 1.1,
                      ),
                    ).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideY(begin: 0.2),

                    const SizedBox(height: 14),

                    // Subtitle
                    Text(
                      "We're upgrading PRAEPARATIO to serve you better.\nWe'll be back shortly!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white.withOpacity(0.65),
                        height: 1.6,
                        fontWeight: FontWeight.w500,
                      ),
                    ).animate().fadeIn(duration: 600.ms, delay: 350.ms),

                    const SizedBox(height: 36),

                    // Animated loading dots
                    _LoadingDots(ctrl: _dotCtrl),

                    const SizedBox(height: 40),

                    // Status card
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white.withOpacity(0.12)),
                      ),
                      child: Row(children: [
                        Container(
                          width: 10, height: 10,
                          decoration: const BoxDecoration(
                            color: Color(0xFF39D353),
                            shape: BoxShape.circle,
                          ),
                        ).animate(onPlay: (c) => c.repeat(reverse: true))
                         .scale(begin: const Offset(0.7, 0.7), end: const Offset(1.3, 1.3), duration: 900.ms),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('System Update in Progress',
                                style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 2),
                            Text('Estimated downtime: a few minutes',
                                style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
                          ]),
                        ),
                      ]),
                    ).animate().fadeIn(duration: 500.ms, delay: 500.ms),

                    const SizedBox(height: 40),

                    // Logout button
                    if (widget.onLogout != null)
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: widget.onLogout,
                          icon: const Icon(Icons.logout_rounded, size: 17),
                          label: const Text('Log Out', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white.withOpacity(0.75),
                            side: BorderSide(color: Colors.white.withOpacity(0.22)),
                            backgroundColor: Colors.white.withOpacity(0.06),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ).animate().fadeIn(duration: 400.ms, delay: 600.ms),

                    const SizedBox(height: 32),

                    // App branding
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Container(
                        width: 28, height: 28,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: const Center(child: Icon(Icons.science_rounded, color: Colors.white, size: 14)),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'PRAEPARATIO',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ]).animate().fadeIn(duration: 400.ms, delay: 700.ms),

                    const SizedBox(height: 20),

                    // Admin access (subtle)
                    GestureDetector(
                      onTap: widget.onAdminTap,
                      child: Text(
                        'Admin Access',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.18),
                          fontSize: 11,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.white.withOpacity(0.18),
                        ),
                      ),
                    ).animate().fadeIn(duration: 300.ms, delay: 900.ms),
                  ],
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

// ── Animated gear group ────────────────────────────────────────────────────────
class _GearGroup extends StatelessWidget {
  final AnimationController gearCtrl;
  const _GearGroup({required this.gearCtrl});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 140,
        height: 100,
        child: AnimatedBuilder(
          animation: gearCtrl,
          builder: (_, __) => CustomPaint(
            painter: _GearPainter(gearCtrl.value),
          ),
        ),
      ).animate().scale(duration: 700.ms, curve: Curves.easeOutBack).fadeIn(duration: 500.ms);
}

class _GearPainter extends CustomPainter {
  final double t;
  _GearPainter(this.t);

  void _drawGear(Canvas canvas, Offset center, double r, double angle, Color color, int teeth) {
    final p = Paint()..color = color..style = PaintingStyle.fill;
    final ps = Paint()..color = Colors.white.withOpacity(0.15)..style = PaintingStyle.stroke..strokeWidth = 1.5;

    // Gear body
    final path = Path();
    for (int i = 0; i < teeth * 2; i++) {
      final a = angle + (i / (teeth * 2)) * 2 * math.pi;
      final rr = i.isEven ? r : r * 0.75;
      final x = center.dx + rr * math.cos(a);
      final y = center.dy + rr * math.sin(a);
      if (i == 0) path.moveTo(x, y);
      else path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, p);
    canvas.drawPath(path, ps);

    // Center hole
    canvas.drawCircle(center, r * 0.3, Paint()..color = const Color(0xFF0F0C29)..style = PaintingStyle.fill);
    canvas.drawCircle(center, r * 0.3, Paint()..color = Colors.white.withOpacity(0.1)..style = PaintingStyle.stroke..strokeWidth = 1);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final angle1 = t * 2 * math.pi;
    final angle2 = -t * 2 * math.pi;
    final angle3 = t * 2 * math.pi * 1.5;

    _drawGear(canvas, const Offset(50, 50), 36, angle1, AppColors.primary.withOpacity(0.7), 10);
    _drawGear(canvas, const Offset(104, 55), 24, angle2, AppColors.accent.withOpacity(0.6), 7);
    _drawGear(canvas, const Offset(120, 30), 14, angle3, const Color(0xFF39D353).withOpacity(0.5), 5);
  }

  @override
  bool shouldRepaint(_GearPainter old) => old.t != t;
}

// ── Loading dots ───────────────────────────────────────────────────────────────
class _LoadingDots extends StatelessWidget {
  final AnimationController ctrl;
  const _LoadingDots({required this.ctrl});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(5, (i) => AnimatedBuilder(
          animation: ctrl,
          builder: (_, __) {
            final phase = ((ctrl.value * 5 - i) % 5 / 5).clamp(0.0, 1.0);
            final scale = 1.0 + 0.5 * math.sin(phase * math.pi);
            return Transform.scale(
              scale: scale,
              child: Container(
                width: 7, height: 7,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.3 + 0.7 * math.sin(phase * math.pi).clamp(0.0, 1.0)),
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        )),
      );
}

// ── Ambient glow ───────────────────────────────────────────────────────────────
class _AmbientGlow extends StatelessWidget {
  final AnimationController ctrl;
  const _AmbientGlow({required this.ctrl});

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: ctrl,
        builder: (_, __) => CustomPaint(painter: _GlowPainter(ctrl.value)),
      );
}

class _GlowPainter extends CustomPainter {
  final double t;
  _GlowPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final glow = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.primary.withOpacity(0.08 + 0.06 * t),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCenter(center: Offset(size.width * 0.3, size.height * 0.4), width: size.width * 0.8, height: size.width * 0.8));
    canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.4), size.width * 0.4, glow);

    final glow2 = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.accent.withOpacity(0.06 + 0.04 * (1 - t)),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCenter(center: Offset(size.width * 0.75, size.height * 0.65), width: size.width * 0.6, height: size.width * 0.6));
    canvas.drawCircle(Offset(size.width * 0.75, size.height * 0.65), size.width * 0.3, glow2);
  }

  @override
  bool shouldRepaint(_GlowPainter old) => old.t != t;
}

// ── Grid overlay ───────────────────────────────────────────────────────────────
class _GridOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) => CustomPaint(painter: _GridPainter());
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 1;
    const spacing = 40.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => false;
}
