import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/app_colors.dart';
import '../models/badge_model.dart';

class BadgeWidget extends StatelessWidget {
  final BadgeModel badge;
  final bool earned;
  final bool large;
  final VoidCallback? onTap;

  const BadgeWidget({
    super.key,
    required this.badge,
    this.earned = true,
    this.large = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = large ? 80.0 : 56.0;
    final iconSize = large ? 32.0 : 22.0;

    Widget badgeWidget = GestureDetector(
      onTap: onTap,
      child: Tooltip(
        message: '${badge.name}\n${badge.description}',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: earned ? badge.color.withOpacity(0.15) : AppColors.border,
                border: Border.all(
                  color: earned ? badge.color : AppColors.border,
                  width: large ? 3 : 2,
                ),
                boxShadow: earned
                    ? [BoxShadow(color: badge.color.withOpacity(0.3), blurRadius: 12, spreadRadius: 2)]
                    : null,
              ),
              child: Center(
                child: Text(
                  badge.icon,
                  style: TextStyle(fontSize: iconSize),
                ),
              ),
            ),
            if (large) ...[
              const SizedBox(height: 6),
              SizedBox(
                width: 80,
                child: Text(
                  badge.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: earned ? AppColors.textPrimary : AppColors.textHint,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );

    if (earned && badge.isAnimated) {
      badgeWidget = badgeWidget
          .animate(onPlay: (c) => c.repeat())
          .shimmer(duration: 3.seconds, color: badge.color.withOpacity(0.6));
    }

    if (!earned) {
      badgeWidget = ColorFiltered(
        colorFilter: const ColorFilter.matrix([
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0, 0, 0, 0.5, 0,
        ]),
        child: badgeWidget,
      );
    }

    return badgeWidget;
  }
}

class BadgeGrid extends StatelessWidget {
  final List<String> earnedIds;
  final int crossAxisCount;

  const BadgeGrid({super.key, required this.earnedIds, this.crossAxisCount = 4});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: BadgeDefinitions.all.map((badge) {
        final earned = earnedIds.contains(badge.id);
        return BadgeWidget(badge: badge, earned: earned, large: true);
      }).toList(),
    );
  }
}
