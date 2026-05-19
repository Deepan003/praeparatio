import 'dart:async';
import '../models/notification_model.dart';

class ToastData {
  final String title;
  final String body;
  final NotificationType type;
  final String? route;

  const ToastData({
    required this.title,
    required this.body,
    required this.type,
    this.route,
  });
}

/// Singleton stream-based toast queue.
/// Works everywhere — no BuildContext needed at the call site.
class ToastService {
  static final ToastService instance = ToastService._();
  ToastService._();

  final _controller = StreamController<ToastData>.broadcast();
  Stream<ToastData> get stream => _controller.stream;

  // When true (student in exam) only time-warning toasts are shown immediately;
  // other toasts are held and flushed when the exam ends.
  bool _examActive = false;
  final List<ToastData> _held = [];

  void setExamActive(bool active) {
    _examActive = active;
    if (!active) {
      // Flush held toasts now that exam is done
      for (final t in _held) {
        _controller.add(t);
      }
      _held.clear();
    }
  }

  /// Show a toast. During an active exam, non-warning toasts are queued
  /// and flushed automatically when the exam ends.
  void show(ToastData toast) {
    if (_examActive && toast.type != NotificationType.lowCoinBalance) {
      // Hold exam-publish / results / announcement toasts until exam ends
      if (toast.type == NotificationType.examPublished ||
          toast.type == NotificationType.resultsReleased ||
          toast.type == NotificationType.announcement) {
        _held.add(toast);
        return;
      }
    }
    _controller.add(toast);
  }

  // ── Convenience helpers ─────────────────────────────────────

  void showExamPublished(String title) => show(ToastData(
        title: 'New Exam Available',
        body: '"$title" is now live. Tap to start!',
        type: NotificationType.examPublished,
        route: '/student/online-tests',
      ));

  void showResultsReleased(String title) => show(ToastData(
        title: 'Rankings Released',
        body: 'Results for "$title" are now visible.',
        type: NotificationType.resultsReleased,
      ));

  void showExamSubmitted(String title, int score) => show(ToastData(
        title: 'Exam Submitted',
        body: '"$title" — Score: $score marks',
        type: NotificationType.examSubmitted,
      ));

  void showCoinsEarned(int amount, int balance) => show(ToastData(
        title: '+$amount PrepCoins Earned!',
        body: 'New balance: $balance coins',
        type: NotificationType.coinsEarned,
      ));

  void showCoinsDeducted(int amount, int balance) => show(ToastData(
        title: '$amount PrepCoins Used',
        body: 'Remaining balance: $balance coins',
        type: NotificationType.coinsDeducted,
      ));

  void showAnnouncement(String title, String body) => show(ToastData(
        title: title,
        body: body,
        type: NotificationType.announcement,
      ));

  void showTimeWarning(String message, NotificationType level) => show(ToastData(
        title: message,
        body: '',
        type: level,
      ));

  void showNotesUploaded(String name) => show(ToastData(
        title: 'New Study Material',
        body: '"$name" added to your notes',
        type: NotificationType.notesUploaded,
        route: '/student/notes',
      ));

  void showWelcome(String name) => show(ToastData(
        title: 'Welcome, $name!',
        body: 'Your NEET prep journey starts here.',
        type: NotificationType.welcome,
      ));
}
