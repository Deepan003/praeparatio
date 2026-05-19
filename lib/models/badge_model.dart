import 'package:flutter/material.dart';

class BadgeModel {
  final String id;
  final String name;
  final String description;
  final String icon;         // emoji or icon name
  final String tier;         // 'bronze', 'silver', 'gold', 'platinum', 'diamond'
  final String category;     // 'exam', 'flashcard', 'game', 'streak', 'special'
  final String requirement;  // human-readable requirement
  final Color color;
  final bool isAnimated;

  const BadgeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.tier,
    required this.category,
    required this.requirement,
    required this.color,
    this.isAnimated = false,
  });
}

class BadgeDefinitions {
  static const List<BadgeModel> all = [
    // Exam badges
    BadgeModel(id: 'first_exam', name: 'First Step', description: 'Complete your first online exam', icon: '🎯', tier: 'bronze', category: 'exam', requirement: 'Complete 1 online exam', color: Color(0xFFCD7F32)),
    BadgeModel(id: 'exam_5', name: 'Exam Warrior', description: 'Complete 5 online exams', icon: '⚔️', tier: 'silver', category: 'exam', requirement: 'Complete 5 online exams', color: Color(0xFFC0C0C0)),
    BadgeModel(id: 'exam_10', name: 'Exam Veteran', description: 'Complete 10 online exams', icon: '🏆', tier: 'gold', category: 'exam', requirement: 'Complete 10 online exams', color: Color(0xFFFFD700), isAnimated: true),
    BadgeModel(id: 'exam_perfect', name: 'Perfectionist', description: 'Score 100% in any exam', icon: '💯', tier: 'diamond', category: 'exam', requirement: 'Score 100% in an exam', color: Color(0xFF7FFFD4), isAnimated: true),
    BadgeModel(id: 'neet_ready', name: 'NEET Ready', description: 'Score above 90% in a NEET Level exam', icon: '🌟', tier: 'platinum', category: 'exam', requirement: '90%+ in NEET Level exam', color: Color(0xFFE5E4E2), isAnimated: true),
    BadgeModel(id: 'speed_demon', name: 'Speed Demon', description: 'Finish an exam in under half the allotted time with 80%+ score', icon: '⚡', tier: 'gold', category: 'exam', requirement: 'Fast + accurate exam completion', color: Color(0xFFFFD700)),
    BadgeModel(id: 'comeback', name: 'Comeback Kid', description: 'Improve score by 30%+ on a retaken exam', icon: '🔄', tier: 'silver', category: 'exam', requirement: '+30% improvement on retake', color: Color(0xFFC0C0C0)),

    // Flashcard badges
    BadgeModel(id: 'flashcard_first', name: 'Memory Seedling', description: 'Review your first flashcard set', icon: '🌱', tier: 'bronze', category: 'flashcard', requirement: 'Complete 1 flashcard chapter', color: Color(0xFFCD7F32)),
    BadgeModel(id: 'flashcard_10', name: 'Memory Bloom', description: 'Complete 10 flashcard chapters', icon: '🌸', tier: 'silver', category: 'flashcard', requirement: 'Complete 10 flashcard chapters', color: Color(0xFFC0C0C0)),
    BadgeModel(id: 'flashcard_all11', name: 'Class XI Scholar', description: 'Complete all Class 11 flashcard chapters', icon: '📚', tier: 'gold', category: 'flashcard', requirement: 'All Class 11 chapters reviewed', color: Color(0xFFFFD700), isAnimated: true),
    BadgeModel(id: 'flashcard_all12', name: 'Class XII Scholar', description: 'Complete all Class 12 flashcard chapters', icon: '🎓', tier: 'gold', category: 'flashcard', requirement: 'All Class 12 chapters reviewed', color: Color(0xFFFFD700), isAnimated: true),
    BadgeModel(id: 'flashcard_master', name: 'Memory Master', description: 'Complete all flashcard chapters', icon: '🧠', tier: 'diamond', category: 'flashcard', requirement: 'All chapters reviewed', color: Color(0xFF7FFFD4), isAnimated: true),

    // Game badges
    BadgeModel(id: 'game_first', name: 'Player One', description: 'Play your first biology game', icon: '🎮', tier: 'bronze', category: 'game', requirement: 'Play 1 game', color: Color(0xFFCD7F32)),
    BadgeModel(id: 'game_win', name: 'Champion', description: 'Win any game on the first try', icon: '🥇', tier: 'silver', category: 'game', requirement: 'Win a game on first attempt', color: Color(0xFFC0C0C0)),
    BadgeModel(id: 'game_streak', name: 'On Fire', description: 'Win 5 games in a row', icon: '🔥', tier: 'gold', category: 'game', requirement: '5 consecutive game wins', color: Color(0xFFFFD700), isAnimated: true),
    BadgeModel(id: 'leaderboard_top', name: 'Leaderboard Legend', description: 'Reach #1 on any game leaderboard', icon: '👑', tier: 'platinum', category: 'game', requirement: '#1 on any leaderboard', color: Color(0xFFE5E4E2), isAnimated: true),

    // PYQ badges
    BadgeModel(id: 'pyq_first', name: 'History Seeker', description: 'Complete your first PYQ test', icon: '🔍', tier: 'bronze', category: 'exam', requirement: 'Complete 1 PYQ test', color: Color(0xFFCD7F32)),
    BadgeModel(id: 'pyq_all_years', name: 'Time Traveller', description: 'Attempt PYQ from all available years', icon: '⏰', tier: 'gold', category: 'exam', requirement: 'PYQ from all 7 years attempted', color: Color(0xFFFFD700)),

    // Streak badges
    BadgeModel(id: 'streak_7', name: 'Week Warrior', description: 'Login for 7 consecutive days', icon: '📅', tier: 'bronze', category: 'streak', requirement: '7-day login streak', color: Color(0xFFCD7F32)),
    BadgeModel(id: 'streak_30', name: 'Monthly Master', description: 'Login for 30 consecutive days', icon: '🗓️', tier: 'gold', category: 'streak', requirement: '30-day login streak', color: Color(0xFFFFD700), isAnimated: true),

    // Special
    BadgeModel(id: 'prepcoin_100', name: 'Rich Student', description: 'Accumulate 100 PrepCoins', icon: '🪙', tier: 'bronze', category: 'special', requirement: '100 PrepCoins total', color: Color(0xFFCD7F32)),
    BadgeModel(id: 'all_rounder', name: 'All Rounder', description: 'Use every feature of the app', icon: '🌈', tier: 'platinum', category: 'special', requirement: 'Use all app features', color: Color(0xFFE5E4E2), isAnimated: true),
    BadgeModel(id: 'glossary_master', name: 'Vocabulary King', description: 'Look up 50 glossary terms', icon: '📖', tier: 'silver', category: 'special', requirement: 'View 50 glossary entries', color: Color(0xFFC0C0C0)),
    BadgeModel(id: 'lesson_planner_10', name: 'Organised Mind', description: 'Create 10 lesson plans', icon: '📋', tier: 'silver', category: 'special', requirement: 'Create 10 lesson plans', color: Color(0xFFC0C0C0)),
  ];

  static BadgeModel? findById(String id) {
    try {
      return all.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }
}

// Avatar definitions
class AvatarDefinition {
  final String id;
  final String name;
  final String emoji;
  final bool isClaimable;
  final String? claimRequirement;

  const AvatarDefinition({
    required this.id,
    required this.name,
    required this.emoji,
    this.isClaimable = false,
    this.claimRequirement,
  });
}

class AvatarDefinitions {
  static const List<AvatarDefinition> all = [
    AvatarDefinition(id: 'av_01', name: 'Scholar Owl', emoji: '🦉'),
    AvatarDefinition(id: 'av_02', name: 'DNA Helix', emoji: '🧬'),
    AvatarDefinition(id: 'av_03', name: 'Microscope', emoji: '🔬'),
    AvatarDefinition(id: 'av_04', name: 'Brain', emoji: '🧠'),
    AvatarDefinition(id: 'av_05', name: 'Leaf', emoji: '🌿'),
    AvatarDefinition(id: 'av_06', name: 'Cell', emoji: '🔵'),
    AvatarDefinition(id: 'av_07', name: 'Lightning', emoji: '⚡'),
    AvatarDefinition(id: 'av_08', name: 'Star', emoji: '⭐'),
    AvatarDefinition(id: 'av_09', name: 'Fire', emoji: '🔥'),
    AvatarDefinition(id: 'av_10', name: 'Diamond', emoji: '💎'),
    AvatarDefinition(id: 'av_11', name: 'Crown', emoji: '👑', isClaimable: true, claimRequirement: 'Top the leaderboard'),
    AvatarDefinition(id: 'av_12', name: 'Trophy', emoji: '🏆', isClaimable: true, claimRequirement: 'Win 10 exams'),
    AvatarDefinition(id: 'av_13', name: 'Comet', emoji: '☄️'),
    AvatarDefinition(id: 'av_14', name: 'Nebula', emoji: '🌌', isClaimable: true, claimRequirement: 'Complete all flashcards'),
    AvatarDefinition(id: 'av_15', name: 'Phoenix', emoji: '🦅', isClaimable: true, claimRequirement: 'Come back after a break'),
    AvatarDefinition(id: 'av_16', name: 'Plant Cell', emoji: '🌱'),
    AvatarDefinition(id: 'av_17', name: 'Atom', emoji: '⚛️'),
    AvatarDefinition(id: 'av_18', name: 'Heart', emoji: '❤️'),
    AvatarDefinition(id: 'av_19', name: 'Globe', emoji: '🌍'),
    AvatarDefinition(id: 'av_20', name: 'Mountain', emoji: '⛰️'),
  ];
}
