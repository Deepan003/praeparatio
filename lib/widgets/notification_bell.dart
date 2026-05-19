import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_colors.dart';
import '../providers/notification_provider.dart';

class NotificationBell extends ConsumerWidget {
  final VoidCallback onTap;
  const NotificationBell({super.key, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(unreadCountProvider);

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Bell icon pulses when there are unread notifications
            Icon(
              count > 0 ? Icons.notifications_rounded : Icons.notifications_outlined,
              size: 24,
              color: count > 0 ? AppColors.primary : AppColors.textSecondary,
            )
            .animate(
              key: ValueKey(count > 0),
              onPlay: (c) => count > 0 ? c.repeat(reverse: true) : null,
            )
            .scale(
              begin: const Offset(1.0, 1.0),
              end: const Offset(1.12, 1.12),
              duration: 900.ms,
              curve: Curves.easeInOut,
            ),

            if (count > 0)
              Positioned(
                top: -4, right: -4,
                // Badge pops in (elastic overshoot) each time count changes
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.elasticOut,
                  width: count > 9 ? 18 : 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: Center(
                    child: Text(
                      count > 9 ? '9+' : '$count',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                )
                .animate(key: ValueKey(count))
                .scale(
                  begin: const Offset(1.5, 1.5),
                  end: const Offset(1.0, 1.0),
                  duration: 350.ms,
                  curve: Curves.elasticOut,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
