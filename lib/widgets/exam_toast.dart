import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_colors.dart';
import '../models/notification_model.dart';
import '../services/toast_service.dart';

/// Overlay that listens to [ToastService] and renders queued toasts
/// one at a time. Add via MaterialApp.builder.
class ToastOverlay extends StatefulWidget {
  final Widget child;
  const ToastOverlay({super.key, required this.child});

  @override
  State<ToastOverlay> createState() => _ToastOverlayState();
}

class _ToastOverlayState extends State<ToastOverlay> {
  final List<ToastData> _queue = [];
  ToastData? _current;
  StreamSubscription<ToastData>? _sub;

  @override
  void initState() {
    super.initState();
    _sub = ToastService.instance.stream.listen((toast) {
      _queue.add(toast);
      if (_current == null) _showNext();
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _showNext() {
    if (_queue.isEmpty) {
      if (mounted) setState(() => _current = null);
      return;
    }
    if (mounted) setState(() => _current = _queue.removeAt(0));
  }

  void _dismiss() {
    Future.delayed(const Duration(milliseconds: 300), _showNext);
    if (mounted) setState(() => _current = null);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_current != null)
          Positioned(
            // Sits just below the status bar, horizontally centred
            top: MediaQuery.of(context).padding.top + 12,
            left: 20,
            right: 20,
            child: _AchievementToast(
              key: ValueKey(_current.hashCode),
              data: _current!,
              onDismiss: _dismiss,
            ),
          ),
      ],
    );
  }
}

// ── Google Play–style achievement toast ───────────────────────────────────────

class _AchievementToast extends StatefulWidget {
  final ToastData data;
  final VoidCallback onDismiss;
  const _AchievementToast({super.key, required this.data, required this.onDismiss});

  @override
  State<_AchievementToast> createState() => _AchievementToastState();
}

class _AchievementToastState extends State<_AchievementToast>
    with TickerProviderStateMixin {
  // Slide + fade in
  late final AnimationController _entryCtrl;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  // Icon ring pulse
  late final AnimationController _pulseCtrl;
  late final Animation<double> _ring;

  // Auto-dismiss progress
  late final AnimationController _progressCtrl;

  @override
  void initState() {
    super.initState();

    _entryCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _slide = Tween<Offset>(begin: const Offset(0, -0.8), end: Offset.zero)
        .animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCirc));
    _fade  = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut));
    _entryCtrl.forward();

    // Pulse animation removed per user request for cleaner look

    _progressCtrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 3600));
    _progressCtrl.forward().whenComplete(_exit);
  }

  Future<void> _exit() async {
    _progressCtrl.stop();
    if (!mounted) return;
    await _entryCtrl.reverse();
    widget.onDismiss();
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _progressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final type  = widget.data.type;
    final color = type.color;
    final icon  = _iconFor(type);

    return Dismissible(
      key: ValueKey(widget.data.hashCode),
      direction: DismissDirection.horizontal,
      onDismissed: (_) => widget.onDismiss(),
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _fade,
          child: GestureDetector(
            onTap: () {
              if (widget.data.route != null && context.mounted) {
                context.go(widget.data.route!);
              }
              _exit();
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: Material(
                color: Colors.transparent,
                child: BackdropFilter(
                  // Strong Frosted-glass blur for iOS feel
                  filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                  child: AnimatedBuilder(
                    animation: _progressCtrl,
                    builder: (_, child) => Container(
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.6), width: 0.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 20,
                            spreadRadius: 2,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: child!,
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 14),
                        // ── Static icon circle (iOS style) ──────
                        Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: color.withOpacity(0.12),
                          ),
                          child: Icon(icon, size: 18, color: color),
                        ),
                        const SizedBox(width: 12),
                        // ── Text ────────────────────────────────
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center, // Centered per user request
                            children: [
                              Text(
                                widget.data.title,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                    height: 1.2),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (widget.data.body.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  widget.data.body,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black54,
                                      height: 1.2),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                        // ── Dismiss X ───────────────────────────
                        GestureDetector(
                          onTap: _exit,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 14),
                            child: Icon(Icons.close_rounded,
                                size: 16,
                                color: Colors.black38),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _iconFor(NotificationType t) => switch (t) {
        NotificationType.examPublished   => Icons.rocket_launch_rounded,
        NotificationType.resultsReleased => Icons.leaderboard_rounded,
        NotificationType.examSubmitted   => Icons.check_circle_rounded,
        NotificationType.coinsEarned     => Icons.monetization_on_rounded,
        NotificationType.coinsDeducted   => Icons.remove_circle_rounded,
        NotificationType.lowCoinBalance  => Icons.warning_rounded,
        NotificationType.notesUploaded   => Icons.folder_special_rounded,
        NotificationType.pyqAdded        => Icons.history_edu_rounded,
        NotificationType.announcement    => Icons.campaign_rounded,
        NotificationType.welcome         => Icons.celebration_rounded,
        _                                => Icons.notifications_rounded,
      };
}
