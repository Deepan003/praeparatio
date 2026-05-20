import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/badge_model.dart';

// ── Animated Badge Widget ────────────────────────────────────────────────────
class AnimatedBadgeWidget extends StatefulWidget {
  final BadgeModel badge;
  final bool earned;
  final bool large;
  final bool showLabel;
  final VoidCallback? onTap;

  const AnimatedBadgeWidget({
    super.key,
    required this.badge,
    this.earned = true,
    this.large = false,
    this.showLabel = true,
    this.onTap,
  });

  @override
  State<AnimatedBadgeWidget> createState() => _AnimatedBadgeWidgetState();
}

class _AnimatedBadgeWidgetState extends State<AnimatedBadgeWidget>
    with TickerProviderStateMixin {
  // Controllers — created based on tier
  late final AnimationController _glowCtrl;
  late final AnimationController _spinCtrl;
  late final AnimationController _orbitCtrl;
  late final AnimationController _colorCtrl;
  late final AnimationController _spin2Ctrl;
  late final AnimationController _rainbowCtrl;

  late final Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    final tier = widget.badge.tier.index;

    _glowCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 6.0, end: 20.0).animate(
      CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut),
    );

    _spinCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 3000))
      ..repeat();
    _orbitCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2500))
      ..repeat();
    _colorCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat(reverse: true);
    _spin2Ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 4000))
      ..repeat(reverse: false);
    _rainbowCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 3000))
      ..repeat();

    // Only animate if earned and animated tier
    if (!widget.earned || tier < 2) {
      _glowCtrl.stop();
      _spinCtrl.stop();
      _orbitCtrl.stop();
      _colorCtrl.stop();
      _spin2Ctrl.stop();
      _rainbowCtrl.stop();
    }
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    _spinCtrl.dispose();
    _orbitCtrl.dispose();
    _colorCtrl.dispose();
    _spin2Ctrl.dispose();
    _rainbowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.large ? 72.0 : 52.0;
    final emojiSize = widget.large ? 28.0 : 20.0;
    final tier = widget.badge.tier.index;
    final color = widget.badge.color;

    Widget badge = GestureDetector(
      onTap: widget.onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size + 12,
            height: size + 12,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer rings for legendary/bioLegend
                if (widget.earned && tier >= 4)
                  _buildRings(size, color, tier),
                // Core badge circle
                _buildCore(size, emojiSize, color, tier),
                // Sparkle dots for gold
                if (widget.earned && tier >= 2 && tier < 4)
                  _buildSparkles(size, color),
                // Lock overlay for unearned
                if (!widget.earned)
                  Positioned(
                    right: 4,
                    bottom: 4,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: AppColors.neuSurface,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(Icons.lock, size: 10, color: AppColors.textHint),
                    ),
                  ),
              ],
            ),
          ),
          if (widget.showLabel) ...[
            const SizedBox(height: 4),
            SizedBox(
              width: size + 12,
              child: Text(
                widget.badge.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: widget.large ? 11 : 9,
                  fontWeight: FontWeight.w700,
                  color: widget.earned ? AppColors.textPrimary : AppColors.textHint,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ],
      ),
    );

    if (!widget.earned) {
      badge = ColorFiltered(
        colorFilter: const ColorFilter.matrix([
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0, 0, 0, 0.5, 0,
        ]),
        child: badge,
      );
    }

    return badge;
  }

  Widget _buildCore(double size, double emojiSize, Color color, int tier) {
    if (!widget.earned || tier < 2) {
      // Static for bronze/silver/unearned
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.earned ? color.withOpacity(0.12) : AppColors.border.withOpacity(0.3),
          border: Border.all(
            color: widget.earned ? color : AppColors.border,
            width: widget.large ? 2.5 : 2.0,
          ),
          boxShadow: widget.earned
              ? [BoxShadow(color: color.withOpacity(0.25), blurRadius: 8, spreadRadius: 1)]
              : null,
        ),
        child: Center(child: Text(widget.badge.emoji, style: TextStyle(fontSize: emojiSize))),
      );
    }

    // Gold: pulsing glow
    if (tier == 2) {
      return AnimatedBuilder(
        animation: _glowAnim,
        builder: (_, __) => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.15),
            border: Border.all(color: color, width: 2.5),
            boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: _glowAnim.value, spreadRadius: 2)],
          ),
          child: Center(child: Text(widget.badge.emoji, style: TextStyle(fontSize: emojiSize))),
        ),
      );
    }

    // Mythic: colour-morphing ring
    if (tier == 3) {
      return AnimatedBuilder(
        animation: _colorCtrl,
        builder: (_, __) {
          final t = _colorCtrl.value;
          final morphColor = Color.lerp(color, const Color(0xFF7C3AED), t)!;
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: morphColor.withOpacity(0.15),
              border: Border.all(color: morphColor, width: 3),
              boxShadow: [BoxShadow(color: morphColor.withOpacity(0.5), blurRadius: 14, spreadRadius: 2)],
            ),
            child: Center(child: Text(widget.badge.emoji, style: TextStyle(fontSize: emojiSize))),
          );
        },
      );
    }

    // Legendary: dual-ring glow
    if (tier == 4) {
      return AnimatedBuilder(
        animation: _glowAnim,
        builder: (_, __) => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.18),
            border: Border.all(color: color, width: 3),
            boxShadow: [
              BoxShadow(color: color.withOpacity(0.5), blurRadius: _glowAnim.value, spreadRadius: 3),
              BoxShadow(color: color.withOpacity(0.2), blurRadius: _glowAnim.value * 2, spreadRadius: 6),
            ],
          ),
          child: Center(child: Text(widget.badge.emoji, style: TextStyle(fontSize: emojiSize))),
        ),
      );
    }

    // bioLegend: rainbow gradient border
    return AnimatedBuilder(
      animation: _rainbowCtrl,
      builder: (_, __) {
        return ShaderMask(
          shaderCallback: (bounds) => SweepGradient(
            colors: const [
              Color(0xFFFF0000), Color(0xFFFF7F00), Color(0xFFFFFF00),
              Color(0xFF00FF00), Color(0xFF0000FF), Color(0xFF8B00FF),
              Color(0xFFFF0000),
            ],
            transform: GradientRotation(_rainbowCtrl.value * 2 * math.pi),
          ).createShader(bounds),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.15),
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [BoxShadow(color: color.withOpacity(0.6), blurRadius: 18, spreadRadius: 4)],
            ),
            child: Center(child: Text(widget.badge.emoji, style: TextStyle(fontSize: emojiSize))),
          ),
        );
      },
    );
  }

  Widget _buildSparkles(double size, Color color) {
    return AnimatedBuilder(
      animation: _orbitCtrl,
      builder: (_, __) {
        final angle = _orbitCtrl.value * 2 * math.pi;
        final radius = size / 2 + 4;
        return SizedBox(
          width: size + 12,
          height: size + 12,
          child: Stack(
            alignment: Alignment.center,
            children: List.generate(4, (i) {
              final a = angle + (i * math.pi / 2);
              final x = math.cos(a) * radius;
              final y = math.sin(a) * radius;
              return Transform.translate(
                offset: Offset(x, y),
                child: Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildRings(double size, Color color, int tier) {
    if (tier == 4) {
      // Legendary: two rings rotating opposite
      return Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _spinCtrl,
            builder: (_, __) => Transform.rotate(
              angle: _spinCtrl.value * 2 * math.pi,
              child: Container(
                width: size + 10,
                height: size + 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: color.withOpacity(0.5), width: 1.5),
                ),
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _spin2Ctrl,
            builder: (_, __) => Transform.rotate(
              angle: -_spin2Ctrl.value * 2 * math.pi,
              child: Container(
                width: size + 20,
                height: size + 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: color.withOpacity(0.25), width: 1),
                ),
              ),
            ),
          ),
        ],
      );
    }
    // bioLegend: triple rings
    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedBuilder(
          animation: _spinCtrl,
          builder: (_, __) => Transform.rotate(
            angle: _spinCtrl.value * 2 * math.pi,
            child: Container(
              width: size + 10,
              height: size + 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: color.withOpacity(0.6), width: 2),
              ),
            ),
          ),
        ),
        AnimatedBuilder(
          animation: _spin2Ctrl,
          builder: (_, __) => Transform.rotate(
            angle: -_spin2Ctrl.value * 2 * math.pi,
            child: Container(
              width: size + 20,
              height: size + 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF06B6D4).withOpacity(0.4), width: 1.5),
              ),
            ),
          ),
        ),
        AnimatedBuilder(
          animation: _rainbowCtrl,
          builder: (_, __) => Transform.rotate(
            angle: _rainbowCtrl.value * 2 * math.pi,
            child: Container(
              width: size + 30,
              height: size + 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: color.withOpacity(0.2), width: 1),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Backward-compatible alias
typedef BadgeWidget = AnimatedBadgeWidget;

// ── Badge Grid ───────────────────────────────────────────────────────────────
class BadgeGrid extends StatelessWidget {
  final List<String> earnedIds;
  final int crossAxisCount;

  const BadgeGrid({super.key, required this.earnedIds, this.crossAxisCount = 3});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: BadgeDefinitions.all.length,
      itemBuilder: (_, i) {
        final badge = BadgeDefinitions.all[i];
        final earned = earnedIds.contains(badge.id);
        return AnimatedBadgeWidget(badge: badge, earned: earned);
      },
    );
  }
}
