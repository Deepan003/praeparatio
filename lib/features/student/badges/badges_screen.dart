import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/badge_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/badge_widget.dart';

class BadgesScreen extends ConsumerWidget {
  const BadgesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).value;
    final earnedIds = user?.earnedBadgeIds ?? [];

    return DefaultTabController(
      length: BadgeDefinitions.categories.length,
      child: Column(
        children: [
          // Scrollable tab bar
          Container(
            color: AppColors.neuSurface,
            child: TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              indicatorWeight: 2.5,
              labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              tabs: BadgeDefinitions.categories.map((cat) {
                final catBadges = BadgeDefinitions.forCategory(cat);
                final earned = catBadges.where((b) => earnedIds.contains(b.id)).length;
                return Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(BadgeDefinitions.categoryEmoji(cat)),
                      const SizedBox(width: 6),
                      Text(BadgeDefinitions.categoryLabel(cat)),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: earned > 0 ? AppColors.primary.withOpacity(0.1) : AppColors.border.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$earned/6',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: earned > 0 ? AppColors.primary : AppColors.textHint,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1),
          // Tab views
          Expanded(
            child: TabBarView(
              children: BadgeDefinitions.categories.map((cat) {
                final catBadges = BadgeDefinitions.forCategory(cat);
                final earned = catBadges.where((b) => earnedIds.contains(b.id)).length;
                return _CategoryTab(
                  category: cat,
                  badges: catBadges,
                  earnedIds: earnedIds,
                  earnedCount: earned,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryTab extends StatelessWidget {
  final String category;
  final List<BadgeModel> badges;
  final List<String> earnedIds;
  final int earnedCount;

  const _CategoryTab({
    required this.category,
    required this.badges,
    required this.earnedIds,
    required this.earnedCount,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // Category header
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.06),
                  AppColors.accent.withOpacity(0.04),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withOpacity(0.12)),
            ),
            child: Row(
              children: [
                Text(
                  BadgeDefinitions.categoryEmoji(category),
                  style: const TextStyle(fontSize: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        BadgeDefinitions.categoryLabel(category),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$earnedCount of ${badges.length} earned',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Progress indicator
                SizedBox(
                  width: 48,
                  height: 48,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: badges.isEmpty ? 0 : earnedCount / badges.length,
                        backgroundColor: AppColors.border,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                        strokeWidth: 4,
                      ),
                      Text(
                        '$earnedCount',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Badge grid
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.75,
            ),
            delegate: SliverChildBuilderDelegate(
              (_, i) {
                final badge = badges[i];
                final earned = earnedIds.contains(badge.id);
                return GestureDetector(
                  onTap: () => _showBadgeDetail(context, badge, earned, earnedIds),
                  child: AnimatedBadgeWidget(
                    badge: badge,
                    earned: earned,
                    large: false,
                    showLabel: true,
                  ),
                );
              },
              childCount: badges.length,
            ),
          ),
        ),
      ],
    );
  }

  void _showBadgeDetail(BuildContext context, BadgeModel badge, bool earned, List<String> earnedIds) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _BadgeDetailSheet(
        badge: badge,
        earned: earned,
        earnedIds: earnedIds,
      ),
    );
  }
}

class _BadgeDetailSheet extends StatelessWidget {
  final BadgeModel badge;
  final bool earned;
  final List<String> earnedIds;

  const _BadgeDetailSheet({
    required this.badge,
    required this.earned,
    required this.earnedIds,
  });

  @override
  Widget build(BuildContext context) {
    final color = badge.color;
    // Find next tier
    final catBadges = BadgeDefinitions.forCategory(badge.category);
    catBadges.sort((a, b) => a.tier.index.compareTo(b.tier.index));
    final earnedInCat = catBadges.where((b) => earnedIds.contains(b.id)).length;
    BadgeModel? nextBadge;
    for (final b in catBadges) {
      if (!earnedIds.contains(b.id)) {
        nextBadge = b;
        break;
      }
    }

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.neuSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Badge display
          AnimatedBadgeWidget(
            badge: badge,
            earned: earned,
            large: true,
            showLabel: false,
          ),
          const SizedBox(height: 16),
          // Tier chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Text(
              badge.tier.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Name
          Text(
            badge.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          // Description
          Text(
            badge.description,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          // Requirement
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withOpacity(0.12)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Requirement: ${badge.requirement}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Category progress
          Row(
            children: [
              Text(
                '${BadgeDefinitions.categoryEmoji(badge.category)} ${BadgeDefinitions.categoryLabel(badge.category)}: ',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              Text(
                '$earnedInCat / ${catBadges.length} earned',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
            ],
          ),
          if (nextBadge != null && !earned) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.lock_outline, size: 14, color: AppColors.textHint),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Next: ${nextBadge.name} — ${nextBadge.requirement}',
                    style: const TextStyle(fontSize: 11, color: AppColors.textHint),
                  ),
                ),
              ],
            ),
          ],
          if (earned) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_rounded, size: 16, color: color),
                const SizedBox(width: 6),
                Text(
                  'Earned!',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
