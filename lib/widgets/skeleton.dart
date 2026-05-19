import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../core/theme/app_colors.dart';

// ── Shared shimmer wrapper ────────────────────────────────────
Widget _shimmer(Widget child) => Shimmer.fromColors(
      baseColor: AppColors.neuShadowDark.withOpacity(0.35),
      highlightColor: AppColors.neuShadowLight,
      period: const Duration(milliseconds: 1400),
      child: child,
    );

Widget _neuSkeleton({
  double? width,
  double height = 16,
  double radius = 10,
}) =>
    _shimmer(
      Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.neuShadowDark.withOpacity(0.3),
          borderRadius: BorderRadius.circular(radius),
          boxShadow: AppColors.neuRaisedSoft,
        ),
      ),
    );

// ── Public widgets ────────────────────────────────────────────
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;

  const SkeletonBox({super.key, this.width, this.height = 16, this.radius = 10});

  @override
  Widget build(BuildContext context) =>
      _neuSkeleton(width: width, height: height, radius: radius);
}

class SkeletonCircle extends StatelessWidget {
  final double size;
  const SkeletonCircle({super.key, this.size = 48});

  @override
  Widget build(BuildContext context) => _shimmer(
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.neuShadowDark.withOpacity(0.3),
            shape: BoxShape.circle,
            boxShadow: AppColors.neuRaisedSoft,
          ),
        ),
      );
}

class SkeletonCard extends StatelessWidget {
  final double? height;
  final double radius;
  const SkeletonCard({super.key, this.height, this.radius = 18});

  @override
  Widget build(BuildContext context) => _shimmer(
        Container(
          height: height ?? 120,
          decoration: BoxDecoration(
            color: AppColors.neuShadowDark.withOpacity(0.25),
            borderRadius: BorderRadius.circular(radius),
            boxShadow: AppColors.neuRaisedSoft,
          ),
        ),
      );
}

class SkeletonExamCard extends StatelessWidget {
  const SkeletonExamCard({super.key});

  @override
  Widget build(BuildContext context) => _shimmer(
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: AppColors.neuSurface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppColors.neuRaisedSoft,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.neuShadowDark.withOpacity(0.2),
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 200,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppColors.neuShadowDark.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 130,
                      height: 11,
                      decoration: BoxDecoration(
                        color: AppColors.neuShadowDark.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(children: [
                      Container(
                        width: 90,
                        height: 34,
                        decoration: BoxDecoration(
                          color: AppColors.neuShadowDark.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        width: 110,
                        height: 34,
                        decoration: BoxDecoration(
                          color: AppColors.neuShadowDark.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

class SkeletonListItem extends StatelessWidget {
  const SkeletonListItem({super.key});

  @override
  Widget build(BuildContext context) => _shimmer(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.neuShadowDark.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 13,
                      decoration: BoxDecoration(
                        color: AppColors.neuShadowDark.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 150,
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppColors.neuShadowDark.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

class SkeletonDashboard extends StatelessWidget {
  const SkeletonDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 600;
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome banner
          const SkeletonCard(height: 110, radius: 22),
          const SizedBox(height: 18),
          // Stat row
          Row(children: List.generate(3, (i) => Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i < 2 ? 10 : 0),
              child: const SkeletonCard(height: 88),
            ),
          ))),
          const SizedBox(height: 18),
          // Quick access grid placeholder
          const SkeletonCard(height: 160),
          const SizedBox(height: 18),
          // Chart
          const SkeletonCard(height: 200),
        ],
      ),
    );
  }
}

// ── Sleek arc spinner ────────────────────────────────────────
class AppLoader extends StatefulWidget {
  final String? message;
  final double size;
  final Color? color;

  const AppLoader({super.key, this.message, this.size = 40, this.color});

  @override
  State<AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<AppLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1100))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppColors.primary;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: widget.size + 16,
          height: widget.size + 16,
          decoration: BoxDecoration(
            color: AppColors.neuSurface,
            shape: BoxShape.circle,
            boxShadow: AppColors.neuRaisedSoft,
          ),
          child: Center(
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (_, __) => Transform.rotate(
                angle: _ctrl.value * 2 * math.pi,
                child: CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: _ArcPainter(color: color),
                ),
              ),
            ),
          ),
        ),
        if (widget.message != null) ...[
          const SizedBox(height: 14),
          Text(
            widget.message!,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}

class _ArcPainter extends CustomPainter {
  final Color color;
  _ArcPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2 - 3;

    // Track ring
    canvas.drawCircle(Offset(cx, cy), r,
        Paint()
          ..color = color.withOpacity(0.10)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3);

    // Sweep arc
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      -math.pi / 2,
      math.pi * 1.5,
      false,
      Paint()
        ..shader = SweepGradient(
          colors: [color.withOpacity(0), color],
          startAngle: 0,
          endAngle: math.pi * 1.5,
          transform: const GradientRotation(-math.pi / 2),
        ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Notes skeleton ────────────────────────────────────────────
class SkeletonNotes extends StatelessWidget {
  const SkeletonNotes({super.key});

  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
        baseColor: AppColors.neuShadowDark.withOpacity(0.35),
        highlightColor: AppColors.neuShadowLight,
        period: const Duration(milliseconds: 1400),
        child: ListView.builder(
          padding: const EdgeInsets.all(14),
          itemCount: 3,
          itemBuilder: (_, __) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.neuShadowDark.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(height: 8),
                ...List.generate(3, (_) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.neuShadowDark.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                )),
              ],
            ),
          ),
        ),
      );
}

// ── Grid skeleton (PYQ chapters, year tiles) ──────────────────
class SkeletonGrid extends StatelessWidget {
  final int count;
  final double itemHeight;
  const SkeletonGrid({super.key, this.count = 6, this.itemHeight = 130});

  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
        baseColor: AppColors.neuShadowDark.withOpacity(0.35),
        highlightColor: AppColors.neuShadowLight,
        period: const Duration(milliseconds: 1400),
        child: GridView.builder(
          padding: const EdgeInsets.all(14),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 260,
            childAspectRatio: 1.4,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
          ),
          itemCount: count,
          itemBuilder: (_, __) => Container(
            decoration: BoxDecoration(
              color: AppColors.neuShadowDark.withOpacity(0.18),
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
      );
}

// ── Notification list skeleton ────────────────────────────────
class SkeletonNotifList extends StatelessWidget {
  const SkeletonNotifList({super.key});

  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
        baseColor: AppColors.neuShadowDark.withOpacity(0.35),
        highlightColor: AppColors.neuShadowLight,
        period: const Duration(milliseconds: 1400),
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 32),
          itemCount: 5,
          itemBuilder: (_, __) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.neuShadowDark.withOpacity(0.18),
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
      );
}

// ── Full-screen loading overlay ───────────────────────────────
class FullScreenLoader extends StatelessWidget {
  final String? message;
  const FullScreenLoader({super.key, this.message});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.neuBackground,
        body: Center(
          child: AppLoader(
            message: message ?? 'Loading…',
            size: 44,
          ),
        ),
      );
}
