import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';
import '../services/toast_service.dart';
import 'auth_provider.dart';

// ── State notifier ─────────────────────────────────────────────

class NotificationNotifier
    extends StateNotifier<AsyncValue<List<NotificationModel>>> {
  NotificationNotifier(this._studentId, this._batch)
      : super(const AsyncValue.loading()) {
    _load();
    _subscribeRealtime();
  }

  final String _studentId;
  final String _batch;
  RealtimeChannel? _channel;

  Future<void> _load() async {
    if (_studentId.isEmpty) { state = const AsyncValue.data([]); return; }
    state = const AsyncValue.loading();
    final raw = await NotificationService.instance
        .getForStudent(_studentId, _batch);
    if (!mounted) return;
    // Always cap at 10 — regardless of what the service returns
    final list = raw.take(10).toList();
    state = AsyncValue.data(list);

    // Show toasts for notifications the student missed while offline.
    // We track the last time we showed "on-open toasts" in SharedPreferences.
    // Only unread notifications newer than that timestamp get a toast.
    _showMissedToasts(list);
  }

  Future<void> _showMissedToasts(List<NotificationModel> list) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key   = 'last_toast_check_$_studentId';
      final raw   = prefs.getString(key);
      final lastCheck = raw != null
          ? DateTime.tryParse(raw) ?? DateTime(2000)
          : DateTime(2000);

      // Save NOW as the new checkpoint before showing — so if the app is
      // opened rapidly again, we don't repeat the same toasts.
      await prefs.setString(key, DateTime.now().toIso8601String());

      // Find unread notifications that arrived since last check
      final missed = list
          .where((n) => !n.isRead && n.createdAt.isAfter(lastCheck))
          .toList();

      if (missed.isEmpty) return;

      // Show at most 3, newest first, with a small delay between each
      for (int i = 0; i < missed.length && i < 3; i++) {
        final n = missed[i];
        await Future.delayed(Duration(milliseconds: i * 600));
        ToastService.instance.show(ToastData(
          title: n.title,
          body:  n.body,
          type:  n.type,
          route: n.route,
        ));
      }
    } catch (_) {
      // SharedPreferences error — non-fatal, just skip missed toasts
    }
  }

  Future<void> refresh() => _load();

  Future<void> markRead(String notificationId) async {
    await NotificationService.instance.markRead(notificationId, _studentId);
    state = state.whenData((list) {
      return list.map((n) {
        if (n.id == notificationId) n.isRead = true;
        return n;
      }).toList();
    });
  }

  Future<void> markAllRead() async {
    final ids = state.maybeWhen(
      data: (list) => list.where((n) => !n.isRead).map((n) => n.id).toList(),
      orElse: () => <String>[],
    );
    if (ids.isEmpty) return;
    await NotificationService.instance.markAllRead(ids, _studentId);
    state = state.whenData(
        (list) => list.map((n) { n.isRead = true; return n; }).toList());
  }

  void _subscribeRealtime() {
    if (_studentId.isEmpty) return; // skip for admin / unauthenticated
    _channel = NotificationService.instance.subscribe(
      studentId: _studentId,
      batch:     _batch,
      onNew: (n) {
        if (!mounted) return;
        // Prepend new notification and keep only the 10 most recent
        state = state.whenData((list) => [n, ...list].take(10).toList());
        // Also show an in-app toast so the student sees it instantly
        ToastService.instance.show(ToastData(
          title: n.title,
          body:  n.body,
          type:  n.type,
          route: n.route,
        ));
      },
    );
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    super.dispose();
  }
}

// ── Provider ──────────────────────────────────────────────────

final notificationProvider = StateNotifierProvider<
    NotificationNotifier, AsyncValue<List<NotificationModel>>>((ref) {
  final user = ref.watch(authProvider).value;
  if (user == null || user.isAdmin) {
    // Admins don't have an in-app notification feed
    return NotificationNotifier('', '');
  }
  return NotificationNotifier(user.id, user.batch);
});

// ── Derived: unread count for bell badge ──────────────────────

final unreadCountProvider = Provider<int>((ref) {
  return ref.watch(notificationProvider).maybeWhen(
    data: (list) => list.where((n) => !n.isRead).length,
    orElse: () => 0,
  );
});
