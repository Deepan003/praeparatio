import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

enum NotificationType {
  examPublished,
  resultsReleased,
  examSubmitted,
  notesUploaded,
  pyqAdded,
  coinsEarned,
  coinsDeducted,
  lowCoinBalance,
  announcement,
  batchPromoted,
  welcome,
}

extension NotificationTypeX on NotificationType {
  static NotificationType fromString(String s) => switch (s) {
        'exam_published'   => NotificationType.examPublished,
        'results_released' => NotificationType.resultsReleased,
        'exam_submitted'   => NotificationType.examSubmitted,
        'notes_uploaded'   => NotificationType.notesUploaded,
        'pyq_added'        => NotificationType.pyqAdded,
        'coins_earned'     => NotificationType.coinsEarned,
        'coins_deducted'   => NotificationType.coinsDeducted,
        'low_coin_balance' => NotificationType.lowCoinBalance,
        'announcement'     => NotificationType.announcement,
        'batch_promoted'   => NotificationType.batchPromoted,
        'welcome'          => NotificationType.welcome,
        _                  => NotificationType.announcement,
      };

  String get value => switch (this) {
        NotificationType.examPublished   => 'exam_published',
        NotificationType.resultsReleased => 'results_released',
        NotificationType.examSubmitted   => 'exam_submitted',
        NotificationType.notesUploaded   => 'notes_uploaded',
        NotificationType.pyqAdded        => 'pyq_added',
        NotificationType.coinsEarned     => 'coins_earned',
        NotificationType.coinsDeducted   => 'coins_deducted',
        NotificationType.lowCoinBalance  => 'low_coin_balance',
        NotificationType.announcement    => 'announcement',
        NotificationType.batchPromoted   => 'batch_promoted',
        NotificationType.welcome         => 'welcome',
      };

  IconData get icon => switch (this) {
        NotificationType.examPublished   => Icons.quiz_rounded,
        NotificationType.resultsReleased => Icons.bar_chart_rounded,
        NotificationType.examSubmitted   => Icons.check_circle_rounded,
        NotificationType.notesUploaded   => Icons.folder_rounded,
        NotificationType.pyqAdded        => Icons.history_edu_rounded,
        NotificationType.coinsEarned     => Icons.monetization_on_rounded,
        NotificationType.coinsDeducted   => Icons.remove_circle_rounded,
        NotificationType.lowCoinBalance  => Icons.warning_amber_rounded,
        NotificationType.announcement    => Icons.campaign_rounded,
        NotificationType.batchPromoted   => Icons.upgrade_rounded,
        NotificationType.welcome         => Icons.waving_hand_rounded,
      };

  Color get color => switch (this) {
        NotificationType.examPublished   => AppColors.primary,
        NotificationType.resultsReleased => AppColors.info,
        NotificationType.examSubmitted   => AppColors.success,
        NotificationType.notesUploaded   => AppColors.accent,
        NotificationType.pyqAdded        => AppColors.info,
        NotificationType.coinsEarned     => const Color(0xFFFF8F00),
        NotificationType.coinsDeducted   => AppColors.error,
        NotificationType.lowCoinBalance  => AppColors.warning,
        NotificationType.announcement    => AppColors.primary,
        NotificationType.batchPromoted   => AppColors.success,
        NotificationType.welcome         => AppColors.primary,
      };
}

class NotificationModel {
  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final Map<String, dynamic> data;   // may include 'route', 'examId', etc.
  final String targetType;           // 'all' | 'batch' | 'individual'
  final List<String> targetBatches;
  final String? targetStudentId;
  final String createdBy;
  final DateTime createdAt;
  bool isRead;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.data = const {},
    this.targetType = 'all',
    this.targetBatches = const [],
    this.targetStudentId,
    this.createdBy = 'system',
    required this.createdAt,
    this.isRead = false,
  });

  String? get route => data['route'] as String?;

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inSeconds < 60)  return 'Just now';
    if (diff.inMinutes < 60)  return '${diff.inMinutes}m ago';
    if (diff.inHours   < 24)  return '${diff.inHours}h ago';
    if (diff.inDays    < 7)   return '${diff.inDays}d ago';
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  factory NotificationModel.fromMap(Map<String, dynamic> m) => NotificationModel(
        id:               m['id'] as String,
        type:             NotificationTypeX.fromString(m['type'] as String? ?? ''),
        title:            m['title'] as String? ?? '',
        body:             m['body']  as String? ?? '',
        data:             Map<String, dynamic>.from(m['data'] as Map? ?? {}),
        targetType:       m['target_type'] as String? ?? 'all',
        targetBatches:    List<String>.from(m['target_batches'] as List? ?? []),
        targetStudentId:  m['target_student_id'] as String?,
        createdBy:        m['created_by'] as String? ?? 'system',
        createdAt:        DateTime.parse(m['created_at'] as String),
        isRead:           m['is_read'] as bool? ?? false,
      );

  bool isRelevantFor(String studentId, String batch) {
    if (targetType == 'all') return true;
    if (targetType == 'batch') return targetBatches.contains(batch);
    if (targetType == 'individual') return targetStudentId == studentId;
    return false;
  }
}
