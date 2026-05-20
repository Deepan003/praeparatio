import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/badge_model.dart';
import '../models/exam_result_model.dart';
import '../providers/auth_provider.dart';
import 'supabase_service.dart';
import '../widgets/badge_unlock_dialog.dart';

class BadgeService {
  static final BadgeService instance = BadgeService._();
  BadgeService._();

  /// Set true while an exam is in progress — dialogs are queued
  static bool isExamActive = false;

  /// Queue of badges to show after exam ends
  static final List<BadgeModel> _pendingDialogs = [];

  /// Call this after exam ends to flush queued dialogs
  static void flushPendingDialogs(BuildContext context) {
    if (_pendingDialogs.isEmpty) return;
    final toShow = List<BadgeModel>.from(_pendingDialogs);
    _pendingDialogs.clear();
    _showSequential(context, toShow, 0);
  }

  static void _showSequential(BuildContext context, List<BadgeModel> badges, int idx) {
    if (idx >= badges.length || !context.mounted) return;
    _showDialog(context, badges[idx], onDismiss: () {
      _showSequential(context, badges, idx + 1);
    });
  }

  static void _showDialog(BuildContext context, BadgeModel badge, {required VoidCallback onDismiss}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      builder: (_) => BadgeUnlockDialog(badge: badge, onDismiss: onDismiss),
    );
  }

  /// Main entry point: check all badge categories and award new ones.
  /// Pass showDialogs=false for silent background checks.
  Future<void> checkAndAward(
    WidgetRef ref,
    BuildContext context, {
    bool showDialogs = true,
    bool isRetroactive = false,
  }) async {
    final user = ref.read(authProvider).value;
    if (user == null || user.isAdmin) return;

    final studentId = user.id;
    final currentEarned = Set<String>.from(user.earnedBadgeIds);

    // ── Fetch all data needed ────────────────────────────────
    final allResults = await SupabaseService.instance.getAllStudentResults(studentId);
    final firstAttempts = allResults.where((r) => r.isFirstAttempt && !r.isInProgress).toList();
    final pyqResults = allResults.where((r) => r.examType == 'pyq' && !r.isInProgress).toList();
    final chatbotTotal = await SupabaseService.instance.getChatbotUsageTotal(studentId);
    final offlineTests = await SupabaseService.instance.getOfflineTestsByBatch(user.batch);
    final gamesPlayed = Set<String>.from(user.gamesPlayed);
    final bioLabDone = Set<String>.from(user.bioLabCompleted);
    final daysSinceJoining = DateTime.now().difference(user.createdAt).inDays;

    // ── Compute newly earned ─────────────────────────────────
    final newlyEarned = <String>{};

    // Helper to add badge if not already earned
    void award(String id) {
      if (!currentEarned.contains(id)) newlyEarned.add(id);
    }

    // Category 1: Warrior (first attempt count)
    final faCount = firstAttempts.length;
    if (faCount >= 1)   award('warrior_bronze');
    if (faCount >= 5)   award('warrior_silver');
    if (faCount >= 10)  award('warrior_gold');
    if (faCount >= 25)  award('warrior_mythic');
    if (faCount >= 50)  award('warrior_legendary');
    if (faCount >= 100) award('warrior_biolegend');

    // Category 2: Score (best percentage)
    final bestPct = firstAttempts.isEmpty ? 0.0
        : firstAttempts.map((r) => r.percentage).reduce(math.max);
    if (firstAttempts.isNotEmpty) award('score_bronze'); // only once an exam is submitted
    if (bestPct >= 50) award('score_silver');
    if (bestPct >= 70) award('score_gold');
    if (bestPct >= 85) award('score_mythic');
    if (bestPct >= 95) award('score_legendary');
    if (bestPct >= 100) award('score_biolegend');

    // Category 3: NEET marks (best single exam neet score)
    final bestNeet = firstAttempts.isEmpty ? 0
        : firstAttempts.map((r) => r.neetScore).reduce(math.max);
    if (bestNeet > 0)    award('neet_bronze');
    if (bestNeet >= 100) award('neet_silver');
    if (bestNeet >= 200) award('neet_gold');
    if (bestNeet >= 300) award('neet_mythic');
    if (bestNeet >= 360) award('neet_legendary');
    if (bestNeet >= 400) award('neet_biolegend');

    // Category 4: Consistency
    final above40 = firstAttempts.where((r) => r.percentage >= 40).length;
    final above50 = firstAttempts.where((r) => r.percentage >= 50).length;
    final above60 = firstAttempts.where((r) => r.percentage >= 60).length;
    final above70 = firstAttempts.where((r) => r.percentage >= 70).length;
    final above75 = firstAttempts.where((r) => r.percentage >= 75).length;
    final above80 = firstAttempts.where((r) => r.percentage >= 80).length;
    if (above40 >= 3)  award('consistent_bronze');
    if (above50 >= 5)  award('consistent_silver');
    if (above60 >= 8)  award('consistent_gold');
    if (above70 >= 12) award('consistent_mythic');
    if (above75 >= 18) award('consistent_legendary');
    if (above80 >= 25) award('consistent_biolegend');

    // Category 5: Accuracy (correct/(correct+wrong) best exam)
    double bestAcc = 0;
    for (final r in firstAttempts) {
      final total = r.correctCount + r.incorrectCount;
      if (total > 0) {
        final acc = r.correctCount / total * 100;
        if (acc > bestAcc) bestAcc = acc;
      }
    }
    if (bestAcc >= 70) award('accuracy_bronze');
    if (bestAcc >= 80) award('accuracy_silver');
    if (bestAcc >= 87) award('accuracy_gold');
    if (bestAcc >= 93) award('accuracy_mythic');
    if (bestAcc >= 97) award('accuracy_legendary');
    // Flawless: 100% accuracy AND no wrong answers AND min 20 questions
    final flawless = firstAttempts.any((r) =>
      r.incorrectCount == 0 && r.correctCount >= 20);
    if (flawless) award('accuracy_biolegend');

    // Category 6: PYQ
    final pyqCount = pyqResults.length;
    if (pyqCount >= 1)   award('pyq_bronze');
    if (pyqCount >= 5)   award('pyq_silver');
    if (pyqCount >= 12)  award('pyq_gold');
    if (pyqCount >= 25)  award('pyq_mythic');
    if (pyqCount >= 50)  award('pyq_legendary');
    if (pyqCount >= 100) award('pyq_biolegend');

    // Category 7: PrepCoins
    final coins = user.prepcoins;
    if (coins > 0)     award('coins_bronze');
    if (coins >= 100)  award('coins_silver');
    if (coins >= 300)  award('coins_gold');
    if (coins >= 700)  award('coins_mythic');
    if (coins >= 1500) award('coins_legendary');
    if (coins >= 3000) award('coins_biolegend');

    // Category 8: Chatbot
    if (chatbotTotal >= 1)   award('chatbot_bronze');
    if (chatbotTotal >= 15)  award('chatbot_silver');
    if (chatbotTotal >= 60)  award('chatbot_gold');
    if (chatbotTotal >= 150) award('chatbot_mythic');
    if (chatbotTotal >= 350) award('chatbot_legendary');
    if (chatbotTotal >= 700) award('chatbot_biolegend');

    // Category 9: Speed (time efficiency)
    for (final r in firstAttempts) {
      if (r.timeTakenSeconds <= 0 || r.totalQuestions == 0) continue;
      // Estimate total duration: neet standard 72s/q
      final estimatedTotal = r.totalQuestions * 72;
      final timePct = r.timeTakenSeconds / estimatedTotal * 100;
      final pct = r.percentage;
      if (timePct < 75 && pct >= 40) award('speed_bronze');
      if (timePct < 60 && pct >= 50) award('speed_silver');
      if (timePct < 50 && pct >= 60) award('speed_gold');
      if (timePct < 40 && pct >= 70) award('speed_mythic');
      if (timePct < 30 && pct >= 75) award('speed_legendary');
      if (timePct < 20 && pct >= 80) award('speed_biolegend');
    }

    // Category 10: Comeback (improvement from first to latest retake)
    final examGroups = <String, List<ExamResultModel>>{};
    for (final r in allResults.where((r) => !r.isInProgress)) {
      examGroups.putIfAbsent(r.examId, () => []).add(r);
    }
    for (final group in examGroups.values) {
      if (group.length < 2) continue;
      group.sort((a, b) => a.submittedAt.compareTo(b.submittedAt));
      final first = group.first;
      final latest = group.last;
      final improvement = latest.percentage - first.percentage;
      award('comeback_bronze'); // has retake
      if (improvement >= 10) award('comeback_silver');
      if (improvement >= 20) award('comeback_gold');
      if (improvement >= 30) award('comeback_mythic');
      if (improvement >= 40) award('comeback_legendary');
      if (improvement >= 50) award('comeback_biolegend');
    }

    // Category 11: Journey (days since joining)
    award('journey_bronze'); // always — account exists
    if (daysSinceJoining >= 7)   award('journey_silver');
    if (daysSinceJoining >= 30)  award('journey_gold');
    if (daysSinceJoining >= 90)  award('journey_mythic');
    if (daysSinceJoining >= 180) award('journey_legendary');
    if (daysSinceJoining >= 365) award('journey_biolegend');

    // Category 12: Offline tests
    final myOfflineTests = offlineTests
        .where((t) => t.studentMarks.containsKey(studentId) && t.studentMarks[studentId] != null)
        .toList();
    if (myOfflineTests.isNotEmpty) award('offline_bronze');

    int aboveAvgCount = 0;
    int topScoreCount = 0;
    for (final t in myOfflineTests) {
      if (t.fullMarks <= 0) continue;
      final myMark = t.studentMarks[studentId] ?? 0;
      final allMarks = t.studentMarks.values.whereType<int>().toList();
      if (allMarks.isEmpty) continue;
      final avg = allMarks.reduce((a, b) => a + b) / allMarks.length;
      final maxMark = allMarks.reduce(math.max);
      if (myMark > avg) aboveAvgCount++;
      if (myMark >= maxMark && myMark > 0) topScoreCount++;
    }
    if (aboveAvgCount >= 1)  award('offline_silver');
    if (topScoreCount >= 1)  award('offline_gold');
    if (aboveAvgCount >= 5)  award('offline_mythic');
    if (aboveAvgCount >= 10) award('offline_legendary');
    if (topScoreCount >= 5)  award('offline_biolegend');

    // Category 13: Games
    final gameCount = gamesPlayed.length;
    if (gameCount >= 1)  award('games_bronze');
    if (gameCount >= 5)  award('games_silver');
    if (gameCount >= 10) award('games_gold');
    if (gameCount >= 15) award('games_mythic');
    if (gameCount >= 20) award('games_legendary');
    if (gameCount >= 25) award('games_biolegend');

    // Category 14: Bio Lab
    final bioCount = bioLabDone.length;
    if (bioCount >= 1)  award('biolab_bronze');
    if (bioCount >= 3)  award('biolab_silver');
    if (bioCount >= 10) award('biolab_gold');
    if (bioCount >= 16) award('biolab_mythic');
    if (bioCount >= 20) award('biolab_legendary');
    if (bioCount >= 32) award('biolab_biolegend');

    // Category 15: Special
    final allEarned = currentEarned.union(newlyEarned);
    final hasBronzeAny = allEarned.any((id) => id.endsWith('_bronze'));
    final hasSilverAny = allEarned.any((id) => id.endsWith('_silver'));
    final hasGoldAny   = allEarned.any((id) => id.endsWith('_gold'));
    final hasMythicAny = allEarned.any((id) => id.endsWith('_mythic'));
    final hasLegAny    = allEarned.any((id) => id.endsWith('_legendary'));
    if (hasBronzeAny) award('special_bronze');
    if (hasSilverAny) award('special_silver');
    if (hasGoldAny)   award('special_gold');
    if (hasMythicAny) award('special_mythic');
    if (hasLegAny)    award('special_legendary');
    // Bio Legend special: gold+ in all 14 other categories
    const cats14 = [
      'warrior', 'score', 'neet', 'consistent', 'accuracy', 'pyq',
      'coins', 'chatbot', 'speed', 'comeback', 'journey', 'offline',
      'games', 'biolab',
    ];
    final allGold = cats14.every((cat) => allEarned.any((id) =>
      id.startsWith('${cat}_') &&
      ['gold', 'mythic', 'legendary', 'biolegend'].any((t) => id.endsWith('_$t'))));
    if (allGold) award('special_biolegend');

    if (newlyEarned.isEmpty) return;

    // ── Save to DB ───────────────────────────────────────────
    final updated = [...currentEarned, ...newlyEarned].toList();
    await SupabaseService.instance.updateEarnedBadges(studentId, updated);

    // Update local state
    ref.read(authProvider.notifier).refreshCurrentUser();

    // ── Show dialogs ─────────────────────────────────────────
    if (!showDialogs || !context.mounted) return;

    // Sort by tier ascending so lower tier shows first
    final badgesToShow = newlyEarned
        .map((id) => BadgeDefinitions.findById(id))
        .whereType<BadgeModel>()
        .toList()
      ..sort((a, b) => a.tier.index.compareTo(b.tier.index));

    if (isRetroactive && badgesToShow.length > 1) {
      // Show a single summary dialog for retroactive batch
      _showRetroBatchDialog(context, badgesToShow);
      return;
    }

    if (isExamActive) {
      _pendingDialogs.addAll(badgesToShow);
      return;
    }

    if (context.mounted) _showSequential(context, badgesToShow, 0);
  }

  static void _showRetroBatchDialog(BuildContext context, List<BadgeModel> badges) {
    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (_) => BadgeRetroDialog(badges: badges),
    );
  }
}
