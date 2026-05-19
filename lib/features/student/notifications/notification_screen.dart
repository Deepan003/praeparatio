import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/neu_theme.dart';
import '../../../models/notification_model.dart';
import '../../../providers/notification_provider.dart';
import '../../../widgets/neu_refresh.dart';
import '../../../widgets/skeleton.dart';

Future<void> showNotificationSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _NotificationSheet(),
  );
}

class _NotificationSheet extends ConsumerWidget {
  const _NotificationSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state   = ref.watch(notificationProvider);
    final notifier = ref.read(notificationProvider.notifier);
    final h = MediaQuery.sizeOf(context).height;

    // DefaultTextStyle.merge propagates decoration:none to ALL Text children
    // — kills the yellow underline that Flutter shows for "unstyled" text.
    // GoogleFonts.dmSans gives every text node a clean sans-serif font.
    return DefaultTextStyle.merge(
      style: GoogleFonts.dmSans(
        decoration: TextDecoration.none,
        decorationColor: Colors.transparent,
      ),
      child: Container(
      height: h * 0.86,
      decoration: BoxDecoration(
        color: context.neu.bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 32,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Handle ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 16, 0),
            child: Column(
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Header row
                Row(
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Notifications',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.3)),
                        Text('Tap to open · Swipe in exam to dismiss',
                            style: TextStyle(
                                fontSize: 10.5,
                                color: AppColors.textHint)),
                      ],
                    ),
                    const Spacer(),
                    state.maybeWhen(
                      data: (list) {
                        final unread = list.where((n) => !n.isRead).length;
                        if (unread == 0) return const SizedBox.shrink();
                        return _MarkReadBtn(
                          count: unread,
                          onTap: notifier.markAllRead,
                        );
                      },
                      orElse: () => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),
          const Divider(height: 1, color: AppColors.border),

          // ── Content ─────────────────────────────────────────────
          Expanded(
            child: state.when(
              loading: () => const SkeletonNotifList(),
              error:   (_, __) => const _EmptyState(
                icon: Icons.cloud_off_outlined,
                label: 'Could not load notifications',
              ),
              data: (list) {
                if (list.isEmpty) return const _EmptyState(
                  icon: Icons.notifications_off_rounded,
                  label: 'Nothing here yet',
                  sub:   'Notifications will appear when exams are published or results released',
                );

                final groups = _groupByDate(list);

                return NeuRefreshIndicator(
                  onRefresh: () => notifier.refresh(),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(14, 8, 14, 32),
                    itemCount: _itemCount(groups),
                    itemBuilder: (_, idx) {
                      final item = _itemAt(groups, idx);
                      if (item is String) {
                        return _DateLabel(label: item);
                      }
                      final n = item as NotificationModel;
                      return _NotifTile(
                        notification: n,
                        onTap: () {
                          notifier.markRead(n.id);
                          if (n.route != null && context.mounted) {
                            Navigator.pop(context);
                            context.go(n.route!);
                          }
                        },
                      ).animate(delay: (idx * 25).ms)
                          .fadeIn(duration: 180.ms)
                          .slideX(begin: 0.04, duration: 180.ms);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      ),
    ); // DefaultTextStyle.merge
  }

  Map<String, List<NotificationModel>> _groupByDate(List<NotificationModel> list) {
    final now    = DateTime.now();
    final groups = <String, List<NotificationModel>>{};
    for (final n in list) {
      final diff = now.difference(n.createdAt).inDays;
      groups.putIfAbsent(
          diff == 0 ? 'Today' : diff == 1 ? 'Yesterday' : 'Earlier',
          () => []).add(n);
    }
    return groups;
  }

  int _itemCount(Map<String, List<NotificationModel>> g) =>
      g.entries.fold(0, (s, e) => s + 1 + e.value.length);

  dynamic _itemAt(Map<String, List<NotificationModel>> g, int idx) {
    int cur = 0;
    for (final e in g.entries) {
      if (cur == idx) return e.key;
      cur++;
      for (final n in e.value) {
        if (cur == idx) return n;
        cur++;
      }
    }
    return null;
  }
}

// ── Date label ───────────────────────────────────────────────────

class _DateLabel extends StatelessWidget {
  final String label;
  const _DateLabel({required this.label});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(2, 18, 2, 6),
        child: Text(
          label.toUpperCase(),
          style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: AppColors.textSecondary,
              letterSpacing: 1.2),
        ),
      );
}

// ── Mark all read button ─────────────────────────────────────────

class _MarkReadBtn extends StatelessWidget {
  final int count;
  final VoidCallback onTap;
  const _MarkReadBtn({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.done_all_rounded,
                size: 13, color: AppColors.primary),
            const SizedBox(width: 5),
            Text('Read all ($count)',
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary)),
          ]),
        ),
      );
}

// ── Empty state ──────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? sub;
  const _EmptyState({required this.icon, required this.label, this.sub});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                  color: AppColors.neuSurface,
                  shape: BoxShape.circle,
                  boxShadow: AppColors.neuRaisedSoft,
                ),
                child: Icon(icon, size: 32, color: AppColors.textHint),
              ).animate().scale(
                    begin: const Offset(0.8, 0.8),
                    duration: 400.ms,
                    curve: Curves.elasticOut),
              const SizedBox(height: 16),
              Text(label,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary)),
              if (sub != null) ...[
                const SizedBox(height: 6),
                Text(sub!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textHint,
                        height: 1.5)),
              ],
            ],
          ),
        ),
      );
}

// ── Notification tile ────────────────────────────────────────────

class _NotifTile extends StatefulWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  const _NotifTile({required this.notification, required this.onTap});

  @override
  State<_NotifTile> createState() => _NotifTileState();
}

class _NotifTileState extends State<_NotifTile>
    with SingleTickerProviderStateMixin {
  // Subtle pulse animation on the icon for unread notifications
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1400),
        lowerBound: 0.92,
        upperBound: 1.08);
    if (!widget.notification.isRead) {
      _pulse.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(_NotifTile old) {
    super.didUpdateWidget(old);
    if (widget.notification.isRead && !old.notification.isRead) {
      _pulse.stop();
      _pulse.animateTo(1.0, duration: const Duration(milliseconds: 200));
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final n     = widget.notification;
    final color = n.type.color;
    final isRead = n.isRead;

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isRead ? AppColors.neuSurface : color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(18),
          boxShadow: isRead
              ? AppColors.neuRaisedSoft
              : [BoxShadow(color: color.withOpacity(0.12), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          // IntrinsicHeight lets the accent bar stretch to match the content
          // height without collapsing to zero inside an unbounded ListView.
          child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Coloured left accent bar
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 4,
                color: color.withOpacity(isRead ? 0.35 : 0.9),
              ),
              Expanded(child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Animated icon ──────────────────────────────────
              AnimatedBuilder(
                animation: _pulse,
                builder: (_, __) => Transform.scale(
                  scale: isRead ? 1.0 : _pulse.value,
                  child: Container(
                    width: 42, height: 42,
                    decoration: BoxDecoration(
                      color: color.withOpacity(isRead ? 0.08 : 0.14),
                      borderRadius: BorderRadius.circular(13),
                      boxShadow: isRead
                          ? null
                          : [
                              BoxShadow(
                                  color: color.withOpacity(0.2),
                                  blurRadius: 8,
                                  spreadRadius: 1),
                            ],
                    ),
                    child: Icon(n.type.icon,
                        size: 20,
                        color: color.withOpacity(isRead ? 0.7 : 1.0)),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // ── Text ───────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            n.title,
                            style: GoogleFonts.dmSans(
                              fontSize: 13.5,
                              fontWeight: isRead
                                  ? FontWeight.w600
                                  : FontWeight.w800,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.2,
                              decoration: TextDecoration.none,
                              decorationColor: Colors.transparent,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Unread dot
                        if (!isRead) ...[
                          const SizedBox(width: 6),
                          Container(
                            width: 7, height: 7,
                            decoration: BoxDecoration(
                                color: color, shape: BoxShape.circle),
                          ),
                        ],
                      ],
                    ),
                    if (n.body.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        n.body,
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.4,
                          decoration: TextDecoration.none,
                          decorationColor: Colors.transparent,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 5),
                    // Time + type label row
                    Row(children: [
                      Text(n.timeAgo,
                          style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textHint,
                              decoration: TextDecoration.none)),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _typeLabel(n.type),
                          style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: color,
                              decoration: TextDecoration.none),
                        ),
                      ),
                    ]),
                  ],
                ),
              ),

              // Arrow chevron
              if (n.route != null) ...[
                const SizedBox(width: 6),
                Icon(Icons.chevron_right_rounded,
                    size: 18,
                    color: isRead
                        ? AppColors.textHint
                        : color.withOpacity(0.6)),
              ],
            ],
          ),
        )), // Expanded + Padding
          ], // Row children
        ), // ClipRRect Row
          ), // IntrinsicHeight
        ), // ClipRRect
      ),
    );
  }

  String _typeLabel(NotificationType t) => switch (t) {
        NotificationType.examPublished   => 'NEW EXAM',
        NotificationType.resultsReleased => 'RESULTS',
        NotificationType.examSubmitted   => 'SUBMITTED',
        NotificationType.coinsEarned     => 'COINS',
        NotificationType.coinsDeducted   => 'COINS',
        NotificationType.lowCoinBalance  => 'WARNING',
        NotificationType.notesUploaded   => 'NOTES',
        NotificationType.pyqAdded        => 'PYQ',
        NotificationType.announcement    => 'NOTICE',
        NotificationType.welcome         => 'WELCOME',
        _                                => 'INFO',
      };
}
