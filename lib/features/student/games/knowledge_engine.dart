import 'dart:math';
import 'game_data.dart';

/// The Knowledge Engine — an autonomous system that powers all biology games.
///
/// It maintains a shared pool of biology knowledge, prevents repetition,
/// adapts difficulty based on performance, and provides rich explanations
/// so every session feels fresh and educational.
class KnowledgeEngine {
  static final KnowledgeEngine _instance = KnowledgeEngine._();
  static KnowledgeEngine get instance => _instance;
  KnowledgeEngine._();

  final _rng = Random();

  // ── Session tracking — avoids repeating recently seen content ──
  final Set<String> _recentDiagnosis = {};
  final Set<String> _recentWhoAmI = {};
  final Set<String> _recentWrong = {};
  final Set<String> _recentOrder = {};
  final Set<String> _recentPunnett = {};
  final Set<String> _recentAssassin = {};
  final Set<String> _recentPloidy = {};
  final Set<String> _recentInvader = {};

  // ── Performance tracking ────────────────────────────────────────
  int _correctStreak = 0;
  int _totalCorrect = 0;
  int _totalAttempted = 0;
  String _currentDifficulty = 'medium'; // easy / medium / hard

  double get accuracy =>
      _totalAttempted == 0 ? 0 : _totalCorrect / _totalAttempted;
  int get streak => _correctStreak;
  String get difficulty => _currentDifficulty;

  void recordAnswer(bool correct) {
    _totalAttempted++;
    if (correct) {
      _totalCorrect++;
      _correctStreak++;
      // Increase difficulty after 3 correct in a row
      if (_correctStreak >= 3) _currentDifficulty = 'hard';
    } else {
      _correctStreak = 0;
      // Ease down after wrong answer
      if (_currentDifficulty == 'hard') _currentDifficulty = 'medium';
    }
  }

  void resetSession() {
    _correctStreak = 0;
    _currentDifficulty = 'medium';
  }

  // ── Diagnosis Chamber ──────────────────────────────────────────
  DiagnosisCase getNextDiagnosis() {
    final available = diagnosisCases
        .where((c) => !_recentDiagnosis.contains(c.disease))
        .toList();
    if (available.isEmpty) {
      _recentDiagnosis.clear();
      return diagnosisCases[_rng.nextInt(diagnosisCases.length)];
    }
    final item = available[_rng.nextInt(available.length)];
    _recentDiagnosis.add(item.disease);
    if (_recentDiagnosis.length > 6) {
      _recentDiagnosis.remove(_recentDiagnosis.first);
    }
    return item;
  }

  // ── Who Am I ──────────────────────────────────────────────────
  WhoAmIItem getNextWhoAmI() {
    final available = whoAmIItems
        .where((c) => !_recentWhoAmI.contains(c.answer))
        .toList();
    if (available.isEmpty) {
      _recentWhoAmI.clear();
      return whoAmIItems[_rng.nextInt(whoAmIItems.length)];
    }
    final item = available[_rng.nextInt(available.length)];
    _recentWhoAmI.add(item.answer);
    if (_recentWhoAmI.length > 8) {
      _recentWhoAmI.remove(_recentWhoAmI.first);
    }
    return item;
  }

  // ── Binary Blitz ──────────────────────────────────────────────
  List<BinaryItem> getShuffledBinaryItems(int count) {
    final shuffled = List<BinaryItem>.from(hormoneOrEnzymeItems)..shuffle(_rng);
    return shuffled.take(count.clamp(1, shuffled.length)).toList();
  }

  // ── Wrong Statements ──────────────────────────────────────────
  WrongStatement getNextWrongStatement() {
    final available = wrongStatements
        .where((c) => !_recentWrong.contains(c.wrongWord))
        .toList();
    if (available.isEmpty) {
      _recentWrong.clear();
      return wrongStatements[_rng.nextInt(wrongStatements.length)];
    }
    final item = available[_rng.nextInt(available.length)];
    _recentWrong.add(item.wrongWord);
    return item;
  }

  // ── Ordering Challenge ────────────────────────────────────────
  OrderChallenge getNextOrderChallenge() {
    final available = orderChallenges
        .where((c) => !_recentOrder.contains(c.category))
        .toList();
    if (available.isEmpty) {
      _recentOrder.clear();
      return orderChallenges[_rng.nextInt(orderChallenges.length)];
    }
    final item = available[_rng.nextInt(available.length)];
    _recentOrder.add(item.category);
    return item;
  }

  List<String> shuffleOrder(List<String> correct) {
    final copy = List<String>.from(correct)..shuffle(_rng);
    // Make sure it's not already in correct order
    while (copy.join() == correct.join()) {
      copy.shuffle(_rng);
    }
    return copy;
  }

  // ── Punnett Square ────────────────────────────────────────────
  PunnettProblem getNextPunnett() {
    final available = punnettProblems
        .where((c) => !_recentPunnett.contains(c.cross))
        .toList();
    if (available.isEmpty) {
      _recentPunnett.clear();
      return punnettProblems[_rng.nextInt(punnettProblems.length)];
    }
    final item = available[_rng.nextInt(available.length)];
    _recentPunnett.add(item.cross);
    return item;
  }

  // ── Assassin Protein ──────────────────────────────────────────
  AssassinScenario getNextAssassin() {
    final available = assassinScenarios
        .where((c) => !_recentAssassin.contains(c.scenario.substring(0, 30)))
        .toList();
    if (available.isEmpty) {
      _recentAssassin.clear();
      return assassinScenarios[_rng.nextInt(assassinScenarios.length)];
    }
    final item = available[_rng.nextInt(available.length)];
    _recentAssassin.add(item.scenario.substring(0, 30));
    return item;
  }

  List<String> shuffledSuspects(AssassinScenario scenario) {
    final list = List<String>.from(scenario.suspects)..shuffle(_rng);
    return list;
  }

  // ── Ploidy Patrol ─────────────────────────────────────────────
  PloidyQuestion getNextPloidy() {
    final available = ploidyQuestions
        .where((c) => !_recentPloidy.contains(c.organism))
        .toList();
    if (available.isEmpty) {
      _recentPloidy.clear();
      return ploidyQuestions[_rng.nextInt(ploidyQuestions.length)];
    }
    final item = available[_rng.nextInt(available.length)];
    _recentPloidy.add(item.organism);
    return item;
  }

  List<String> ploidyOptions(PloidyQuestion q) {
    final base = ['n (Haploid)', '2n (Diploid)', '3n (Triploid)', '4n (Tetraploid)'];
    if (!base.contains(q.correctPloidy)) {
      // Remove one wrong option and add the correct one
      base.removeAt(_rng.nextInt(base.length));
      base.add(q.correctPloidy);
    }
    return base..shuffle(_rng);
  }

  // ── Invader Abiotic ───────────────────────────────────────────
  InvaderScenario getNextInvader() {
    final available = invaderScenarios
        .where((c) => !_recentInvader.contains(c.category))
        .toList();
    if (available.isEmpty) {
      _recentInvader.clear();
      return invaderScenarios[_rng.nextInt(invaderScenarios.length)];
    }
    final item = available[_rng.nextInt(available.length)];
    _recentInvader.add(item.category);
    return item;
  }

  List<String> shuffledDefenses(InvaderScenario scenario) {
    return List<String>.from(scenario.defenses)..shuffle(_rng);
  }

  // ── Antakshari ────────────────────────────────────────────────
  String? antakshariFindWord(String lastLetter, Set<String> usedWords) {
    final candidates = ncertBioTerms
        .where((w) =>
            w.startsWith(lastLetter.toUpperCase()) &&
            !usedWords.contains(w))
        .toList();
    if (candidates.isEmpty) return null;
    candidates.shuffle(_rng);
    return candidates.first;
  }

  bool isValidBioTerm(String word) {
    return ncertBioTerms.contains(word.toUpperCase());
  }

  // ── Root Word Botany ──────────────────────────────────────────
  RootWordItem getRandomRootWord() {
    return rootWordItems[_rng.nextInt(rootWordItems.length)];
  }

  // ── Pathway Poet ─────────────────────────────────────────────
  PathwayPoem getNextPathway() {
    return pathwayPoems[_rng.nextInt(pathwayPoems.length)];
  }

  // ── Garbage Collector ─────────────────────────────────────────
  List<WasteItem> getShuffledWasteItems() {
    return List<WasteItem>.from(wasteItems)..shuffle(_rng);
  }

  // ── General: Random NCERT Biology Fact Generator ──────────────
  String getEncouragementMessage(bool correct) {
    final encourageCorrect = [
      '🎉 Brilliant! NCERT mastery unlocked!',
      '⚡ Correct! Your brain cells are firing perfectly!',
      '🔬 Excellent! That\'s textbook-perfect!',
      '🧬 Spot on! A true biologist in the making!',
      '🌟 Perfect! Keep this streak alive!',
      '🏆 Outstanding! NEET is going to be easy for you!',
    ];
    final encourageWrong = [
      '📚 Not quite! Review this topic and come back stronger.',
      '🔍 Close! The explanation below will help you remember.',
      '💡 Learning moment! Biology has many tricky details.',
      '🌱 Every mistake is a seed of knowledge. Read why below!',
      '🧠 Your brain just got a new pathway! Study the explanation.',
    ];
    final list = correct ? encourageCorrect : encourageWrong;
    return list[_rng.nextInt(list.length)];
  }

  String getDifficultyBadge() {
    switch (_currentDifficulty) {
      case 'hard': return '🔥 Hard Mode';
      case 'easy': return '🌱 Easy Mode';
      default: return '⚡ Normal Mode';
    }
  }
}
