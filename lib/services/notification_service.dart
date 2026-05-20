import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification_model.dart';
import 'toast_service.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  final _db = Supabase.instance.client;

  // ── Create ────────────────────────────────────────────────────

  Future<void> send({
    required NotificationType type,
    required String title,
    required String body,
    String targetType = 'all',
    List<String> targetBatches = const [],
    String? targetStudentId,
    Map<String, dynamic> data = const {},
    String createdBy = 'system',
  }) async {
    try {
      await _db.from('notifications').insert({
        'type':              type.value,
        'title':             title,
        'body':              body,
        'data':              data,
        'target_type':       targetType,
        'target_batches':    targetBatches,
        'target_student_id': targetStudentId,
        'created_by':        createdBy,
      });
      // Cleanup runs after insert (trigger also handles max-10 server-side)
      _cleanup();
    } catch (e) {
      // Log so we can see if the notifications table is missing or has a type error
      debugPrint('[NotificationService.send] DB insert failed: $e '
          '(type=${type.value} targetType=$targetType batches=$targetBatches)');
      // Toast was already fired before send() — UI still works even if DB fails
    }
  }

  Future<void> _cleanup() async {
    try {
      // Keep 500 most recent — enough for a multi-batch school
      // with many students without losing older per-student notifications.
      final keep = await _db
          .from('notifications')
          .select('id')
          .order('created_at', ascending: false)
          .limit(500);
      // Safe extraction — skip any malformed rows instead of crashing
      final keepIds = <String>[];
      for (final r in keep as List) {
        final id = (r as Map?)?['id'];
        if (id is String && id.isNotEmpty) keepIds.add(id);
      }
      if (keepIds.isEmpty) return;
      await _db.from('notifications').delete().not('id', 'in', keepIds);
    } catch (e) {
      debugPrint('[NotificationService._cleanup] $e');
    }
  }

  // ── Read ──────────────────────────────────────────────────────

  /// Last 10 notifications relevant to this student.
  /// Tries the RPC first; if it fails or returns nothing, fetches the 50 most
  /// recent notifications and filters client-side using isRelevantFor().
  Future<List<NotificationModel>> getForStudent(
      String studentId, String batch) async {
    // ── RPC path — trust the stored procedure result ──────────
    try {
      final res = await _db.rpc('get_notifications_for_student', params: {
        'p_student_id': studentId,
        'p_batch':      batch,
      });
      final list = (res as List? ?? [])
          .whereType<Map>()
          .map((r) => NotificationModel.fromMap(Map<String, dynamic>.from(r)))
          .toList();
      if (list.isNotEmpty) return list;
    } catch (e) {
      debugPrint('[NotificationService] RPC get_notifications_for_student: $e');
    }

    // ── Direct fallback — fetch recent 50, filter client-side ─
    // Avoids complex PostgREST OR syntax that can fail on some Supabase configs.
    try {
      final res = await _db
          .from('notifications')
          .select()
          .order('created_at', ascending: false)
          .limit(200); // fetch more so batch-specific notifications aren't missed

      final all = (res as List? ?? [])
          .whereType<Map>()
          .map((r) => NotificationModel.fromMap(Map<String, dynamic>.from(r)))
          .toList();

      // Use the model's own relevance check — handles all / batch / individual
      final relevant = all
          .where((n) => n.isRelevantFor(studentId, batch))
          .take(10)
          .toList();

      // Never fall back to unfiltered data — returning other students' notifications
      // is a privacy leak. If nothing is relevant for this student, return empty.
      final toReturn = relevant;

      // ── Critical fix: the `notifications` table has no `is_read` column.
      // Read status lives in `notification_reads`. Fetch it separately and
      // apply so that previously-read notifications don't reappear as unread.
      try {
        final reads = await _db
            .from('notification_reads')
            .select('notification_id')
            .eq('student_id', studentId);
        final readIds = <String>{};
        for (final r in reads as List) {
          final id = (r as Map?)? ['notification_id'];
          if (id is String) readIds.add(id);
        }
        if (readIds.isNotEmpty) {
          for (final n in toReturn) {
            if (readIds.contains(n.id)) n.isRead = true;
          }
        }
      } catch (_) {
        // Non-fatal — if we can't fetch reads, show all as unread
      }

      return toReturn;
    } catch (e) {
      debugPrint('[NotificationService] direct fallback: $e');
      return [];
    }
  }

  /// Unread count via RPC — used for the bell badge.
  Future<int> getUnreadCount(String studentId, String batch) async {
    try {
      final res = await _db.rpc('get_unread_count', params: {
        'p_student_id': studentId,
        'p_batch':      batch,
      });
      return (res as int?) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  // ── Mark read ─────────────────────────────────────────────────

  Future<void> markRead(String notificationId, String studentId) async {
    try {
      await _db.from('notification_reads').upsert({
        'notification_id': notificationId,
        'student_id':      studentId,
      });
    } catch (_) {}
  }

  Future<void> markAllRead(
      List<String> notificationIds, String studentId) async {
    if (notificationIds.isEmpty) return;
    try {
      await _db.from('notification_reads').upsert(
        notificationIds
            .map((id) => {
                  'notification_id': id,
                  'student_id':      studentId,
                })
            .toList(),
      );
    } catch (_) {}
  }

  // ── Realtime ──────────────────────────────────────────────────

  /// Subscribe to new notifications for this student.
  /// Returns the channel so the caller can unsubscribe on dispose.
  RealtimeChannel subscribe({
    required String studentId,
    required String batch,
    required void Function(NotificationModel) onNew,
  }) {
    return _db
        .channel('notifications_$studentId')
        .onPostgresChanges(
          event:    PostgresChangeEvent.insert,
          schema:   'public',
          table:    'notifications',
          callback: (payload) {
            try {
              final n = NotificationModel.fromMap(
                  Map<String, dynamic>.from(payload.newRecord));
              if (n.isRelevantFor(studentId, batch)) onNew(n);
            } catch (_) {}
          },
        )
        .subscribe();
  }

  // ── Admin: recent history ─────────────────────────────────────

  /// Last 10 notifications across all targets — for the admin history panel.
  Future<List<NotificationModel>> getRecent({int limit = 10}) async {
    try {
      final res = await _db
          .from('notifications')
          .select()
          .order('created_at', ascending: false)
          .limit(limit);
      return (res as List)
          .map((r) => NotificationModel.fromMap(
                Map<String, dynamic>.from(r as Map)..['is_read'] = false))
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ── Pre-built notification helpers ────────────────────────────
  // These are called from the various trigger points across the app.

  Future<void> notifyExamPublished({
    required String examTitle,
    required List<String> targetBatches,
    required String examId,
    required String createdBy,
  }) async {
    // Toast fires for every online student in target batches
    ToastService.instance.showExamPublished(examTitle);
    await send(
      type:          NotificationType.examPublished,
      title:         'New Exam Available',
      body:          '"$examTitle" is now live. Tap to start!',
      targetType:    'batch',
      targetBatches: targetBatches,
      data:          {'route': '/student/online-tests', 'examId': examId},
      createdBy:     createdBy,
    );
  }

  Future<void> notifyResultsReleased({
    required String examTitle,
    required String examId,
    required List<String> studentIds,
    required String createdBy,
  }) async {
    ToastService.instance.showResultsReleased(examTitle);
    for (final sid in studentIds) {
      await send(
        type:            NotificationType.resultsReleased,
        title:           'Rankings Released',
        body:            'Results for "$examTitle" are now visible. Check your rank!',
        targetType:      'individual',
        targetStudentId: sid,
        data:            {
          'route':  '/student/online-tests',
          'examId': examId,
        },
        createdBy: createdBy,
      );
    }
  }

  Future<void> notifyExamSubmitted({
    required String studentId,
    required String examTitle,
    required String examId,
    required int neetScore,
    required double percentage,
  }) async {
    ToastService.instance.showExamSubmitted(examTitle, neetScore);
    await send(
      type:            NotificationType.examSubmitted,
      title:           'Exam Submitted',
      body:            '"$examTitle" submitted. Score: $neetScore marks. Tap to review.',
      targetType:      'individual',
      targetStudentId: studentId,
      data:            {'route': '/student/online-tests', 'examId': examId},
    );
  }

  Future<void> notifyCoinsEarned({
    required String studentId,
    required int amount,
    required int newBalance,
    required String examTitle,
  }) async {
    ToastService.instance.showCoinsEarned(amount, newBalance);
    // Note: We deliberately do not store coin notifications in the database history
    // to avoid RLS insert issues. It purely shows as an on-screen toast.
  }

  Future<void> notifyCoinsDeducted({
    required String studentId,
    required int amount,
    required int newBalance,
    required String examTitle,
  }) async {
    ToastService.instance.showCoinsDeducted(amount, newBalance);
    // Note: We deliberately do not store coin notifications in the database history
    // to avoid RLS insert issues. It purely shows as an on-screen toast.
  }

  Future<void> notifyLowBalance({
    required String studentId,
    required int balance,
  }) =>
      send(
        type:            NotificationType.lowCoinBalance,
        title:           'Low PrepCoin Balance',
        body:
            'You have only $balance PrepCoins left. Complete exams to earn more!',
        targetType:      'individual',
        targetStudentId: studentId,
        data:            {'route': '/student/online-tests'},
      );

  Future<void> notifyNotesUploaded({
    required String noteName,
    required String createdBy,
    String visibility = 'all',
  }) async {
    ToastService.instance.showNotesUploaded(noteName);
    await send(
      type:       NotificationType.notesUploaded,
      title:      'New Study Material Added',
      body:       '"$noteName" has been added to your notes.',
      targetType: 'all',
      data:       {'route': '/student/notes'},
      createdBy:  createdBy,
    );
  }

  Future<void> notifyPyqAdded({
    required String paperTitle,
    required String createdBy,
  }) async {
    ToastService.instance.show(ToastData(
      title: 'New PYQ Paper Added',
      body:  '"$paperTitle" is available. Practice now!',
      type:  NotificationType.pyqAdded,
      route: '/student/pyq',
    ));
    await send(
      type:       NotificationType.pyqAdded,
      title:      'New PYQ Paper Added',
      body:       '"$paperTitle" is available. Practice now!',
      targetType: 'all',
      data:       {'route': '/student/pyq'},
      createdBy:  createdBy,
    );
  }

  Future<void> notifyWelcome({
    required String studentId,
    required String studentName,
  }) async {
    ToastService.instance.showWelcome(studentName);
    await send(
      type:            NotificationType.welcome,
      title:           'Welcome to PRAEPARATIO',
      body:            'Hi $studentName! Your NEET prep journey starts here.',
      targetType:      'individual',
      targetStudentId: studentId,
      data:            {'route': '/student/dashboard'},
    );
  }
}
