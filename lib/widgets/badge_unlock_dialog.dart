import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/badge_model.dart';
import 'badge_widget.dart';

// ── Single Badge Unlock Dialog ───────────────────────────────────────────────
class BadgeUnlockDialog extends StatefulWidget {
  final BadgeModel badge;
  final VoidCallback onDismiss;

  const BadgeUnlockDialog({
    super.key,
    required this.badge,
    required this.onDismiss,
  });

  @override
  State<BadgeUnlockDialog> createState() => _BadgeUnlockDialogState();
}

class _BadgeUnlockDialogState extends State<BadgeUnlockDialog>
    with TickerProviderStateMixin {
  late AnimationController _entryCtrl;
  late AnimationController _shimmerCtrl;

  late Animation<double> _scale;
  late Animation<double> _fade;
  late Animation<double> _slideY;

  @override
  void initState() {
    super.initState();

    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();

    _scale = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic),
    );
    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entryCtrl, curve: const Interval(0.0, 0.5)),
    );
    _slideY = Tween<double>(begin: 18.0, end: 0.0).animate(
      CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic),
    );

    _entryCtrl.forward();
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _shimmerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final badge  = widget.badge;
    final tColor = badge.color;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 52),
      child: AnimatedBuilder(
        animation: Listenable.merge([_entryCtrl, _shimmerCtrl]),
        builder: (_, __) {
          return FadeTransition(
            opacity: _fade,
            child: Transform.translate(
              offset: Offset(0, _slideY.value),
              child: Transform.scale(
                scale: _scale.value,
                child: _DialogCard(
                  badge: badge,
                  tierColor: tColor,
                  shimmerT: _shimmerCtrl.value,
                  onDismiss: () {
                    Navigator.of(context).pop();
                    widget.onDismiss();
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Card body ────────────────────────────────────────────────────────────────
class _DialogCard extends StatelessWidget {
  final BadgeModel badge;
  final Color tierColor;
  final double shimmerT;
  final VoidCallback onDismiss;

  const _DialogCard({
    required this.badge,
    required this.tierColor,
    required this.shimmerT,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          decoration: BoxDecoration(
            // Glass: nearly-white with very slight tint of tier colour
            color: Color.lerp(
              const Color(0xFFF4F5FA),
              tierColor,
              0.04,
            ),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: Colors.white.withOpacity(0.55),
              width: 1.2,
            ),
            boxShadow: [
              // Soft neumorphic lift
              const BoxShadow(
                color: Color(0xFFFFFFFF),
                offset: Offset(-6, -6),
                blurRadius: 18,
              ),
              BoxShadow(
                color: const Color(0xFFC8CCDC).withOpacity(0.60),
                offset: const Offset(6, 6),
                blurRadius: 18,
              ),
              // Gentle tier-colour outer glow
              BoxShadow(
                color: tierColor.withOpacity(0.18),
                blurRadius: 28,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Stack(
            children: [
              // ── Shimmer sweep ─────────────────────────────────
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(26),
                  child: CustomPaint(
                    painter: _ShimmerPainter(shimmerT, tierColor),
                  ),
                ),
              ),

              // ── Content ───────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Label row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 5, height: 5,
                          decoration: BoxDecoration(
                            color: tierColor.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'ACHIEVEMENT UNLOCKED',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: tierColor.withOpacity(0.75),
                            letterSpacing: 2.0,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 5, height: 5,
                          decoration: BoxDecoration(
                            color: tierColor.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),

                    // Badge widget
                    AnimatedBadgeWidget(
                      badge: badge,
                      earned: true,
                      large: true,
                      showLabel: false,
                    ),
                    const SizedBox(height: 18),

                    // Badge name
                    Text(
                      badge.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),

                    // Tier chip — subtle glass pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: tierColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: tierColor.withOpacity(0.25), width: 1),
                      ),
                      child: Text(
                        badge.tier.label.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: tierColor,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Description
                    Text(
                      badge.description,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textSecondary.withOpacity(0.85),
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 22),

                    // Dismiss button — neumorphic pressed style
                    _NeuButton(
                      label: 'Continue',
                      color: tierColor,
                      onTap: onDismiss,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Subtle shimmer sweep ─────────────────────────────────────────────────────
class _ShimmerPainter extends CustomPainter {
  final double t;
  final Color color;
  _ShimmerPainter(this.t, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    // A single diagonal band of light that sweeps slowly across
    final angle  = -math.pi / 5;
    final sweep  = size.width * 2.8;
    final offset = (t * sweep) - size.width * 0.9;

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.transparent,
          Colors.white.withOpacity(0.0),
          Colors.white.withOpacity(0.12),
          Colors.white.withOpacity(0.0),
          Colors.transparent,
        ],
        stops: const [0.0, 0.38, 0.50, 0.62, 1.0],
      ).createShader(Rect.fromLTWH(offset, 0, sweep, size.height));

    canvas.save();
    canvas.rotate(angle);
    canvas.drawRect(
      Rect.fromLTWH(offset, -size.height, sweep, size.height * 3),
      paint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ShimmerPainter old) => old.t != t;
}

// ── Neumorphic dismiss button ────────────────────────────────────────────────
class _NeuButton extends StatefulWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _NeuButton({required this.label, required this.color, required this.onTap});

  @override
  State<_NeuButton> createState() => _NeuButtonState();
}

class _NeuButtonState extends State<_NeuButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: _pressed
              ? widget.color.withOpacity(0.82)
              : widget.color.withOpacity(0.92),
          borderRadius: BorderRadius.circular(14),
          boxShadow: _pressed
              ? [
                  BoxShadow(
                    color: widget.color.withOpacity(0.22),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: widget.color.withOpacity(0.32),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                  const BoxShadow(
                    color: Colors.white,
                    blurRadius: 1,
                    offset: Offset(0, -1),
                  ),
                ],
        ),
        child: Text(
          widget.label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}

// ── Retroactive Batch Dialog ─────────────────────────────────────────────────
class BadgeRetroDialog extends StatelessWidget {
  final List<BadgeModel> badges;
  const BadgeRetroDialog({super.key, required this.badges});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.neuSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                const Text('🎉', style: TextStyle(fontSize: 32)),
                const SizedBox(height: 8),
                Text(
                  'Welcome back! You earned ${badges.length} badges!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 300),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.8,
                ),
                itemCount: badges.length,
                itemBuilder: (_, i) => AnimatedBadgeWidget(
                  badge: badges[i],
                  earned: true,
                  showLabel: true,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Let's Go!",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
