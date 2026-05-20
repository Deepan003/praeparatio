import 'package:flutter/material.dart';

enum BadgeTier { bronze, silver, gold, mythic, legendary, bioLegend }

extension BadgeTierX on BadgeTier {
  Color get color => const [
    Color(0xFFCD7F32), // bronze
    Color(0xFFA8A9AD), // silver
    Color(0xFFFFD700), // gold
    Color(0xFF7C3AED), // mythic
    Color(0xFFE05D12), // legendary
    Color(0xFF06B6D4), // bioLegend
  ][index];

  String get label => const [
    'Bronze', 'Silver', 'Gold', 'Mythic', 'Legendary', 'Bio Legend',
  ][index];

  int get animationLevel => index; // 0-5
}

class BadgeModel {
  final String id;
  final String name;
  final String emoji;
  final String description;
  final String requirement;
  final String category;
  final BadgeTier tier;

  // Legacy field — kept so old code that references badge.icon still compiles
  String get icon => emoji;

  Color get color => tier.color;
  bool get isAnimated => tier.index >= 2; // gold and above

  const BadgeModel({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    required this.requirement,
    required this.category,
    required this.tier,
  });
}

class BadgeDefinitions {
  static const List<BadgeModel> all = [
    // ── warrior ─────────────────────────────────────────────────
    BadgeModel(id: 'warrior_bronze',    name: 'First Steps',        emoji: '⚔️',  description: 'Complete your first exam on first attempt.',              requirement: '1 first-attempt exam',              category: 'warrior',   tier: BadgeTier.bronze),
    BadgeModel(id: 'warrior_silver',    name: 'Battle Ready',       emoji: '🗡️',  description: 'Complete 5 exams on first attempt.',                      requirement: '5 first-attempt exams',             category: 'warrior',   tier: BadgeTier.silver),
    BadgeModel(id: 'warrior_gold',      name: 'Exam Warrior',       emoji: '🏅',  description: 'Complete 10 exams on first attempt.',                     requirement: '10 first-attempt exams',            category: 'warrior',   tier: BadgeTier.gold),
    BadgeModel(id: 'warrior_mythic',    name: 'Battle Hardened',    emoji: '🔱',  description: 'Complete 25 exams on first attempt.',                     requirement: '25 first-attempt exams',            category: 'warrior',   tier: BadgeTier.mythic),
    BadgeModel(id: 'warrior_legendary', name: 'War Veteran',        emoji: '🎖️',  description: 'Complete 50 exams on first attempt.',                     requirement: '50 first-attempt exams',            category: 'warrior',   tier: BadgeTier.legendary),
    BadgeModel(id: 'warrior_biolegend', name: 'NEET Conqueror',     emoji: '👑',  description: 'Complete 100 exams on first attempt.',                    requirement: '100 first-attempt exams',           category: 'warrior',   tier: BadgeTier.bioLegend),

    // ── score ────────────────────────────────────────────────────
    BadgeModel(id: 'score_bronze',      name: 'Test Taker',         emoji: '📊',  description: 'Submit any exam.',                                        requirement: 'Submit any exam',                   category: 'score',     tier: BadgeTier.bronze),
    BadgeModel(id: 'score_silver',      name: 'Half Century',       emoji: '📈',  description: 'Score 50% or above in any exam.',                         requirement: '50%+ in any exam',                  category: 'score',     tier: BadgeTier.silver),
    BadgeModel(id: 'score_gold',        name: 'Score Master',       emoji: '🥇',  description: 'Score 70% or above in any exam.',                         requirement: '70%+ in any exam',                  category: 'score',     tier: BadgeTier.gold),
    BadgeModel(id: 'score_mythic',      name: 'High Achiever',      emoji: '🌟',  description: 'Score 85% or above in any exam.',                         requirement: '85%+ in any exam',                  category: 'score',     tier: BadgeTier.mythic),
    BadgeModel(id: 'score_legendary',   name: 'Excellence',         emoji: '💫',  description: 'Score 95% or above in any exam.',                         requirement: '95%+ in any exam',                  category: 'score',     tier: BadgeTier.legendary),
    BadgeModel(id: 'score_biolegend',   name: 'Perfect Score',      emoji: '💯',  description: 'Score 100% in any exam.',                                 requirement: '100% in any exam',                  category: 'score',     tier: BadgeTier.bioLegend),

    // ── neet ─────────────────────────────────────────────────────
    BadgeModel(id: 'neet_bronze',       name: 'NEET Starter',       emoji: '🧬',  description: 'Score a positive NEET score.',                            requirement: 'Any positive NEET marks',           category: 'neet',      tier: BadgeTier.bronze),
    BadgeModel(id: 'neet_silver',       name: 'NEET Aspirant',      emoji: '🔬',  description: 'Score 100+ NEET marks in a single exam.',                 requirement: '100+ NEET marks',                   category: 'neet',      tier: BadgeTier.silver),
    BadgeModel(id: 'neet_gold',         name: 'NEET Hunter',        emoji: '🏆',  description: 'Score 200+ NEET marks in a single exam.',                 requirement: '200+ NEET marks',                   category: 'neet',      tier: BadgeTier.gold),
    BadgeModel(id: 'neet_mythic',       name: 'NEET Challenger',    emoji: '⚡',  description: 'Score 300+ NEET marks in a single exam.',                 requirement: '300+ NEET marks',                   category: 'neet',      tier: BadgeTier.mythic),
    BadgeModel(id: 'neet_legendary',    name: 'NEET Champion',      emoji: '🦾',  description: 'Score 360+ NEET marks in a single exam.',                 requirement: '360+ NEET marks',                   category: 'neet',      tier: BadgeTier.legendary),
    BadgeModel(id: 'neet_biolegend',    name: 'NEET Legend',        emoji: '🌌',  description: 'Score 400+ NEET marks in a single exam.',                 requirement: '400+ NEET marks',                   category: 'neet',      tier: BadgeTier.bioLegend),

    // ── consistent ───────────────────────────────────────────────
    BadgeModel(id: 'consistent_bronze',    name: 'Getting Started',     emoji: '🔁',  description: '3 exams scoring 40%+.',                               requirement: '3 first-attempt exams above 40%',   category: 'consistent', tier: BadgeTier.bronze),
    BadgeModel(id: 'consistent_silver',    name: 'Steady Performer',    emoji: '📐',  description: '5 exams scoring 50%+.',                               requirement: '5 first-attempt exams above 50%',   category: 'consistent', tier: BadgeTier.silver),
    BadgeModel(id: 'consistent_gold',      name: 'Consistency King',    emoji: '🔥',  description: '8 exams scoring 60%+.',                               requirement: '8 first-attempt exams above 60%',   category: 'consistent', tier: BadgeTier.gold),
    BadgeModel(id: 'consistent_mythic',    name: 'Reliable Scholar',    emoji: '💎',  description: '12 exams scoring 70%+.',                              requirement: '12 first-attempt exams above 70%',  category: 'consistent', tier: BadgeTier.mythic),
    BadgeModel(id: 'consistent_legendary', name: 'Iron Discipline',     emoji: '🛡️',  description: '18 exams scoring 75%+.',                              requirement: '18 first-attempt exams above 75%',  category: 'consistent', tier: BadgeTier.legendary),
    BadgeModel(id: 'consistent_biolegend', name: 'Consistency God',     emoji: '🌠',  description: '25 exams scoring 80%+.',                              requirement: '25 first-attempt exams above 80%',  category: 'consistent', tier: BadgeTier.bioLegend),

    // ── accuracy ─────────────────────────────────────────────────
    BadgeModel(id: 'accuracy_bronze',    name: 'Accurate',           emoji: '🎯',  description: 'Best exam: 70%+ accuracy (correct/attempted).',          requirement: '70%+ accuracy in best exam',         category: 'accuracy',  tier: BadgeTier.bronze),
    BadgeModel(id: 'accuracy_silver',    name: 'Sharp Shooter',      emoji: '🏹',  description: 'Best exam: 80%+ accuracy.',                              requirement: '80%+ accuracy in best exam',         category: 'accuracy',  tier: BadgeTier.silver),
    BadgeModel(id: 'accuracy_gold',      name: 'Sniper',             emoji: '🔭',  description: 'Best exam: 87%+ accuracy.',                              requirement: '87%+ accuracy in best exam',         category: 'accuracy',  tier: BadgeTier.gold),
    BadgeModel(id: 'accuracy_mythic',    name: 'Precision Master',   emoji: '🎪',  description: 'Best exam: 93%+ accuracy.',                              requirement: '93%+ accuracy in best exam',         category: 'accuracy',  tier: BadgeTier.mythic),
    BadgeModel(id: 'accuracy_legendary', name: 'Accuracy Sniper',    emoji: '💠',  description: 'Best exam: 97%+ accuracy.',                              requirement: '97%+ accuracy in best exam',         category: 'accuracy',  tier: BadgeTier.legendary),
    BadgeModel(id: 'accuracy_biolegend', name: 'Flawless',           emoji: '✨',  description: 'Zero wrong answers with 20+ questions answered.',        requirement: '100% accuracy, no wrong, min 20 Qs', category: 'accuracy',  tier: BadgeTier.bioLegend),

    // ── pyq ──────────────────────────────────────────────────────
    BadgeModel(id: 'pyq_bronze',     name: 'History Seeker',     emoji: '📖',  description: 'Complete your first PYQ test.',                           requirement: '1 PYQ test',                        category: 'pyq',       tier: BadgeTier.bronze),
    BadgeModel(id: 'pyq_silver',     name: 'PYQ Explorer',       emoji: '🔍',  description: 'Complete 5 PYQ tests.',                                   requirement: '5 PYQ tests',                       category: 'pyq',       tier: BadgeTier.silver),
    BadgeModel(id: 'pyq_gold',       name: 'Past Paper Pro',     emoji: '📚',  description: 'Complete 12 PYQ tests.',                                  requirement: '12 PYQ tests',                      category: 'pyq',       tier: BadgeTier.gold),
    BadgeModel(id: 'pyq_mythic',     name: 'PYQ Hunter',         emoji: '🗞️',  description: 'Complete 25 PYQ tests.',                                  requirement: '25 PYQ tests',                      category: 'pyq',       tier: BadgeTier.mythic),
    BadgeModel(id: 'pyq_legendary',  name: 'Archive Master',     emoji: '🏛️',  description: 'Complete 50 PYQ tests.',                                  requirement: '50 PYQ tests',                      category: 'pyq',       tier: BadgeTier.legendary),
    BadgeModel(id: 'pyq_biolegend',  name: 'PYQ Legend',         emoji: '📜',  description: 'Complete 100 PYQ tests.',                                 requirement: '100 PYQ tests',                     category: 'pyq',       tier: BadgeTier.bioLegend),

    // ── coins ────────────────────────────────────────────────────
    BadgeModel(id: 'coins_bronze',     name: 'First Coin',         emoji: '🪙',  description: 'Earn your first PrepCoin.',                               requirement: 'Any PrepCoins',                     category: 'coins',     tier: BadgeTier.bronze),
    BadgeModel(id: 'coins_silver',     name: 'Coin Saver',         emoji: '💰',  description: 'Accumulate 100 PrepCoins.',                               requirement: '100 PrepCoins',                     category: 'coins',     tier: BadgeTier.silver),
    BadgeModel(id: 'coins_gold',       name: 'Coin Hoarder',       emoji: '🤑',  description: 'Accumulate 300 PrepCoins.',                               requirement: '300 PrepCoins',                     category: 'coins',     tier: BadgeTier.gold),
    BadgeModel(id: 'coins_mythic',     name: 'Wealthy Scholar',    emoji: '💴',  description: 'Accumulate 700 PrepCoins.',                               requirement: '700 PrepCoins',                     category: 'coins',     tier: BadgeTier.mythic),
    BadgeModel(id: 'coins_legendary',  name: 'PrepCoin Mogul',     emoji: '💵',  description: 'Accumulate 1500 PrepCoins.',                              requirement: '1500 PrepCoins',                    category: 'coins',     tier: BadgeTier.legendary),
    BadgeModel(id: 'coins_biolegend',  name: 'PrepCoin Collector', emoji: '💎',  description: 'Accumulate 3000 PrepCoins.',                              requirement: '3000 PrepCoins',                    category: 'coins',     tier: BadgeTier.bioLegend),

    // ── chatbot ──────────────────────────────────────────────────
    BadgeModel(id: 'chatbot_bronze',     name: 'First Question',     emoji: '🤖',  description: 'Ask your first chatbot question.',                      requirement: '1 chatbot question',                category: 'chatbot',   tier: BadgeTier.bronze),
    BadgeModel(id: 'chatbot_silver',     name: 'Curious Mind',       emoji: '💬',  description: 'Ask 15 chatbot questions total.',                       requirement: '15 chatbot questions',              category: 'chatbot',   tier: BadgeTier.silver),
    BadgeModel(id: 'chatbot_gold',       name: 'Doubt Solver',       emoji: '🧠',  description: 'Ask 60 chatbot questions total.',                       requirement: '60 chatbot questions',              category: 'chatbot',   tier: BadgeTier.gold),
    BadgeModel(id: 'chatbot_mythic',     name: 'AI Companion',       emoji: '🤯',  description: 'Ask 150 chatbot questions total.',                      requirement: '150 chatbot questions',             category: 'chatbot',   tier: BadgeTier.mythic),
    BadgeModel(id: 'chatbot_legendary',  name: 'Doubt Destroyer',    emoji: '⚡',  description: 'Ask 350 chatbot questions total.',                      requirement: '350 chatbot questions',             category: 'chatbot',   tier: BadgeTier.legendary),
    BadgeModel(id: 'chatbot_biolegend',  name: 'AI Maestro',         emoji: '🌐',  description: 'Ask 700 chatbot questions total.',                      requirement: '700 chatbot questions',             category: 'chatbot',   tier: BadgeTier.bioLegend),

    // ── speed ────────────────────────────────────────────────────
    BadgeModel(id: 'speed_bronze',     name: 'Quick Starter',      emoji: '⚡',  description: 'Finish under 75% of time and score 40%+.',               requirement: '<75% time used & 40%+ score',       category: 'speed',     tier: BadgeTier.bronze),
    BadgeModel(id: 'speed_silver',     name: 'Fast Learner',       emoji: '💨',  description: 'Finish under 60% of time and score 50%+.',               requirement: '<60% time used & 50%+ score',       category: 'speed',     tier: BadgeTier.silver),
    BadgeModel(id: 'speed_gold',       name: 'Speed Racer',        emoji: '🏎️',  description: 'Finish under 50% of time and score 60%+.',               requirement: '<50% time used & 60%+ score',       category: 'speed',     tier: BadgeTier.gold),
    BadgeModel(id: 'speed_mythic',     name: 'Lightning Fast',     emoji: '🌩️',  description: 'Finish under 40% of time and score 70%+.',               requirement: '<40% time used & 70%+ score',       category: 'speed',     tier: BadgeTier.mythic),
    BadgeModel(id: 'speed_legendary',  name: 'Speed Demon',        emoji: '🔥',  description: 'Finish under 30% of time and score 75%+.',               requirement: '<30% time used & 75%+ score',       category: 'speed',     tier: BadgeTier.legendary),
    BadgeModel(id: 'speed_biolegend',  name: 'Untouchable',        emoji: '💫',  description: 'Finish under 20% of time and score 80%+.',               requirement: '<20% time used & 80%+ score',       category: 'speed',     tier: BadgeTier.bioLegend),

    // ── comeback ─────────────────────────────────────────────────
    BadgeModel(id: 'comeback_bronze',     name: 'Second Chance',    emoji: '🔄',  description: 'Retake any exam.',                                       requirement: 'Any retake exists',                 category: 'comeback',  tier: BadgeTier.bronze),
    BadgeModel(id: 'comeback_silver',     name: 'Bouncing Back',    emoji: '📈',  description: 'Improve score by 10%+ on a retake.',                    requirement: '+10% improvement on retake',        category: 'comeback',  tier: BadgeTier.silver),
    BadgeModel(id: 'comeback_gold',       name: 'Rising Star',      emoji: '⭐',  description: 'Improve score by 20%+ on a retake.',                    requirement: '+20% improvement on retake',        category: 'comeback',  tier: BadgeTier.gold),
    BadgeModel(id: 'comeback_mythic',     name: 'Comeback Master',  emoji: '🚀',  description: 'Improve score by 30%+ on a retake.',                    requirement: '+30% improvement on retake',        category: 'comeback',  tier: BadgeTier.mythic),
    BadgeModel(id: 'comeback_legendary',  name: 'Phoenix Rise',     emoji: '🦅',  description: 'Improve score by 40%+ on a retake.',                    requirement: '+40% improvement on retake',        category: 'comeback',  tier: BadgeTier.legendary),
    BadgeModel(id: 'comeback_biolegend',  name: 'Comeback Kid',     emoji: '🌅',  description: 'Improve score by 50%+ on a retake.',                    requirement: '+50% improvement on retake',        category: 'comeback',  tier: BadgeTier.bioLegend),

    // ── journey ──────────────────────────────────────────────────
    BadgeModel(id: 'journey_bronze',     name: 'Joined Up',         emoji: '📆',  description: 'Created your PRAEPARATIO account.',                      requirement: 'Account exists',                    category: 'journey',   tier: BadgeTier.bronze),
    BadgeModel(id: 'journey_silver',     name: 'Week Warrior',      emoji: '🗓️',  description: 'Using the app for 7 days.',                              requirement: '7 days since joining',              category: 'journey',   tier: BadgeTier.silver),
    BadgeModel(id: 'journey_gold',       name: 'Monthly Regular',   emoji: '📅',  description: 'Using the app for 30 days.',                             requirement: '30 days since joining',             category: 'journey',   tier: BadgeTier.gold),
    BadgeModel(id: 'journey_mythic',     name: 'Dedicated Student', emoji: '📚',  description: 'Using the app for 90 days.',                             requirement: '90 days since joining',             category: 'journey',   tier: BadgeTier.mythic),
    BadgeModel(id: 'journey_legendary',  name: 'Half Year Hero',    emoji: '🏅',  description: 'Using the app for 180 days.',                            requirement: '180 days since joining',            category: 'journey',   tier: BadgeTier.legendary),
    BadgeModel(id: 'journey_biolegend',  name: 'Year Legend',       emoji: '🏆',  description: 'Using the app for 365 days.',                            requirement: '365 days since joining',            category: 'journey',   tier: BadgeTier.bioLegend),

    // ── offline ──────────────────────────────────────────────────
    BadgeModel(id: 'offline_bronze',     name: 'Paper Warrior',     emoji: '📝',  description: 'Appear in any offline test.',                            requirement: '1 offline test appeared',           category: 'offline',   tier: BadgeTier.bronze),
    BadgeModel(id: 'offline_silver',     name: 'Above Average',     emoji: '📊',  description: 'Score above class average in 1 offline test.',           requirement: 'Above average in 1 offline test',   category: 'offline',   tier: BadgeTier.silver),
    BadgeModel(id: 'offline_gold',       name: 'Top Scorer',        emoji: '🥇',  description: 'Top score in any offline test.',                         requirement: 'Top score in 1 offline test',       category: 'offline',   tier: BadgeTier.gold),
    BadgeModel(id: 'offline_mythic',     name: 'Consistent Leader', emoji: '🌟',  description: 'Above average in 5 offline tests.',                      requirement: 'Above average in 5 offline tests',  category: 'offline',   tier: BadgeTier.mythic),
    BadgeModel(id: 'offline_legendary',  name: 'Offline Champion',  emoji: '🏆',  description: 'Above average in 10 offline tests.',                     requirement: 'Above average in 10 offline tests', category: 'offline',   tier: BadgeTier.legendary),
    BadgeModel(id: 'offline_biolegend',  name: 'Topper Legend',     emoji: '👑',  description: 'Top score in 5 offline tests.',                          requirement: 'Top score in 5 offline tests',      category: 'offline',   tier: BadgeTier.bioLegend),

    // ── games ────────────────────────────────────────────────────
    BadgeModel(id: 'games_bronze',     name: 'Player One',          emoji: '🎮',  description: 'Play your first game.',                                  requirement: '1 unique game played',              category: 'games',     tier: BadgeTier.bronze),
    BadgeModel(id: 'games_silver',     name: 'Game Explorer',       emoji: '🕹️',  description: 'Try 5 different games.',                                 requirement: '5 unique games played',             category: 'games',     tier: BadgeTier.silver),
    BadgeModel(id: 'games_gold',       name: 'Game Collector',      emoji: '🎲',  description: 'Try 10 different games.',                                requirement: '10 unique games played',            category: 'games',     tier: BadgeTier.gold),
    BadgeModel(id: 'games_mythic',     name: 'Game Enthusiast',     emoji: '🎰',  description: 'Try 15 different games.',                                requirement: '15 unique games played',            category: 'games',     tier: BadgeTier.mythic),
    BadgeModel(id: 'games_legendary',  name: 'Game Master',         emoji: '🎯',  description: 'Try 20 different games.',                                requirement: '20 unique games played',            category: 'games',     tier: BadgeTier.legendary),
    BadgeModel(id: 'games_biolegend',  name: 'Game Explorer Legend',emoji: '🌟',  description: 'Try all 25 games.',                                      requirement: '25 unique games played',            category: 'games',     tier: BadgeTier.bioLegend),

    // ── biolab ───────────────────────────────────────────────────
    BadgeModel(id: 'biolab_bronze',     name: 'Lab Newcomer',       emoji: '🔬',  description: 'Complete your first Bio Lab animation.',                 requirement: '1 process completed',               category: 'biolab',    tier: BadgeTier.bronze),
    BadgeModel(id: 'biolab_silver',     name: 'Lab Enthusiast',     emoji: '🧪',  description: 'Complete 3 Bio Lab animations.',                         requirement: '3 processes completed',             category: 'biolab',    tier: BadgeTier.silver),
    BadgeModel(id: 'biolab_gold',       name: 'Lab Researcher',     emoji: '⚗️',  description: 'Complete 10 Bio Lab animations.',                        requirement: '10 processes completed',            category: 'biolab',    tier: BadgeTier.gold),
    BadgeModel(id: 'biolab_mythic',     name: 'Lab Scientist',      emoji: '🧬',  description: 'Complete 16 Bio Lab animations.',                        requirement: '16 processes completed',            category: 'biolab',    tier: BadgeTier.mythic),
    BadgeModel(id: 'biolab_legendary',  name: 'Lab Expert',         emoji: '🔭',  description: 'Complete 20 Bio Lab animations.',                        requirement: '20 processes completed',            category: 'biolab',    tier: BadgeTier.legendary),
    BadgeModel(id: 'biolab_biolegend',  name: 'Bio Lab Explorer',   emoji: '🌌',  description: 'Complete all 32 Bio Lab animations.',                    requirement: '32 processes completed',            category: 'biolab',    tier: BadgeTier.bioLegend),

    // ── special ──────────────────────────────────────────────────
    BadgeModel(id: 'special_bronze',     name: 'Getting Going',     emoji: '💎',  description: 'Earn any bronze badge.',                                 requirement: 'Any bronze badge',                  category: 'special',   tier: BadgeTier.bronze),
    BadgeModel(id: 'special_silver',     name: 'Silver Seeker',     emoji: '🌙',  description: 'Earn any silver badge.',                                 requirement: 'Any silver badge',                  category: 'special',   tier: BadgeTier.silver),
    BadgeModel(id: 'special_gold',       name: 'Golden Touch',      emoji: '✨',  description: 'Earn any gold badge.',                                   requirement: 'Any gold badge',                    category: 'special',   tier: BadgeTier.gold),
    BadgeModel(id: 'special_mythic',     name: 'Mythic Seeker',     emoji: '🔮',  description: 'Earn any mythic badge.',                                 requirement: 'Any mythic badge',                  category: 'special',   tier: BadgeTier.mythic),
    BadgeModel(id: 'special_legendary',  name: 'Legend in Making',  emoji: '🌠',  description: 'Earn any legendary badge.',                              requirement: 'Any legendary badge',               category: 'special',   tier: BadgeTier.legendary),
    BadgeModel(id: 'special_biolegend',  name: 'Bio Legend',        emoji: '🌈',  description: 'Earn gold or above in all 14 non-special categories.',   requirement: 'Gold+ in all 14 categories',        category: 'special',   tier: BadgeTier.bioLegend),
  ];

  static BadgeModel? findById(String id) {
    try {
      return all.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  static List<BadgeModel> forCategory(String category) =>
      all.where((b) => b.category == category).toList();

  static List<String> get categories => [
    'warrior', 'score', 'neet', 'consistent', 'accuracy', 'pyq',
    'coins', 'chatbot', 'speed', 'comeback', 'journey', 'offline',
    'games', 'biolab', 'special',
  ];

  static String categoryLabel(String cat) => switch (cat) {
    'warrior'    => 'Exam Warrior',
    'score'      => 'Score Master',
    'neet'       => 'NEET Hunter',
    'consistent' => 'Consistency King',
    'accuracy'   => 'Accuracy Sniper',
    'pyq'        => 'PYQ Explorer',
    'coins'      => 'PrepCoin Collector',
    'chatbot'    => 'Doubt Destroyer',
    'speed'      => 'Speed Demon',
    'comeback'   => 'Comeback Kid',
    'journey'    => 'Journey',
    'offline'    => 'Offline Champion',
    'games'      => 'Game Explorer',
    'biolab'     => 'Bio Lab Explorer',
    'special'    => 'Special',
    _            => cat,
  };

  static String categoryEmoji(String cat) => switch (cat) {
    'warrior'    => '⚔️',
    'score'      => '📊',
    'neet'       => '🧬',
    'consistent' => '🔁',
    'accuracy'   => '🎯',
    'pyq'        => '📖',
    'coins'      => '🪙',
    'chatbot'    => '🤖',
    'speed'      => '⚡',
    'comeback'   => '🔄',
    'journey'    => '📆',
    'offline'    => '📝',
    'games'      => '🎮',
    'biolab'     => '🔬',
    'special'    => '💎',
    _            => '🏅',
  };
}

// Avatar definitions — kept unchanged
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
