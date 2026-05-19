import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import 'game_data.dart';
import 'game_engine_widgets.dart';
import 'game_engine_widgets.dart' show showAnswerBurst;
import 'knowledge_engine.dart';

final _ke = KnowledgeEngine.instance;
final _rng = Random();

// ═══════════════════════════════════════════════════════════════
// 1. DIAGNOSIS CHAMBER
// ═══════════════════════════════════════════════════════════════
class DiagnosisChamberGame extends StatefulWidget {
  final VoidCallback onExit;
  const DiagnosisChamberGame({super.key, required this.onExit});
  @override
  State<DiagnosisChamberGame> createState() => _DiagnosisChamberState();
}

class _DiagnosisChamberState extends State<DiagnosisChamberGame> {
  late DiagnosisCase _case;
  final _diseaseCtrl = TextEditingController();
  final _nutrientCtrl = TextEditingController();
  bool _submitted = false;
  bool _correct = false;
  int _score = 0;
  int _round = 0;
  int _streak = 0;
  static const _maxRounds = 5;
  bool _finished = false;
  String _feedback = '';

  @override
  void initState() {
    super.initState();
    _nextCase();
  }

  void _nextCase() {
    setState(() {
      _case = _ke.getNextDiagnosis();
      _diseaseCtrl.clear();
      _nutrientCtrl.clear();
      _submitted = false;
      _correct = false;
      _feedback = '';
    });
  }

  void _submit() {
    if (_diseaseCtrl.text.trim().isEmpty) return;
    final d = _diseaseCtrl.text.trim().toLowerCase();
    final n = _nutrientCtrl.text.trim().toLowerCase();
    final cD = _case.disease.toLowerCase();
    final cN = _case.missingNutrient.toLowerCase();

    final diseaseOk = d.contains(cD.split(' ')[0]) || cD.contains(d.split(' ')[0]);
    final nutrientOk = n.isEmpty || n.contains(cN.split(' ')[0]) || cN.contains(n.split(' ')[0]);
    _correct = diseaseOk && nutrientOk;
    if (_correct) _streak++; else _streak = 0;
    showAnswerBurst(context, correct: _correct, streak: _streak);

    if (_correct) {
      _score += 20;
      _ke.recordAnswer(true);
      HapticFeedback.lightImpact();
    } else {
      _ke.recordAnswer(false);
      HapticFeedback.heavyImpact();
    }
    setState(() {
      _submitted = true;
      _feedback = _ke.getEncouragementMessage(_correct);
      _round++;
    });
  }

  void _continueGame() {
    if (_round >= _maxRounds) {
      setState(() => _finished = true);
    } else {
      _nextCase();
    }
  }

  @override
  void dispose() {
    _diseaseCtrl.dispose();
    _nutrientCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) {
      return GameResultScreen(
        gameName: '🔬 Diagnosis Chamber',
        score: _score,
        maxScore: _maxRounds * 20,
        correct: (_score / 20).round(),
        wrong: _maxRounds - (_score / 20).round(),
        facts: [_case.explanation],
        onPlayAgain: () { _round = 0; _score = 0; setState(() { _finished = false; }); _nextCase(); },
        onExit: widget.onExit,
      );
    }

    return GameShell(
      title: 'Diagnosis Chamber',
      emoji: '🔬',
      color: const Color(0xFF16A34A),
      score: _score,
      streak: _ke.streak,
      difficultyBadge: _ke.getDifficultyBadge(),
      onExit: widget.onExit,
      child: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              // Progress
              Row(children: [
                ...List.generate(_maxRounds, (i) => Expanded(
                  child: Container(
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: i < _round ? AppColors.success : AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                )),
              ]),
              const SizedBox(height: 16),
              // Case file
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF16A34A).withOpacity(0.06),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF16A34A).withOpacity(0.3)),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF16A34A),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(_case.title,
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
                    ),
                    const SizedBox(width: 8),
                    Flexible(child: Text(_case.chapter,
                        style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                        overflow: TextOverflow.ellipsis)),
                  ]),
                  const SizedBox(height: 12),
                  const Text('📋 PATIENT CASE FILE',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textSecondary, letterSpacing: 1)),
                  const SizedBox(height: 8),
                  Text(_case.symptoms,
                      style: const TextStyle(fontSize: 13.5, height: 1.6, color: AppColors.textPrimary)),
                ]),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),
              const SizedBox(height: 20),
              // Answer inputs
              TextField(
                controller: _diseaseCtrl,
                enabled: !_submitted,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Diagnosis (Disease Name)',
                  prefixIcon: const Icon(Icons.local_hospital_outlined, size: 18),
                  hintText: 'e.g. Scurvy, Rickets, Goitre...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: AppColors.neuSurface,
                ),
                onSubmitted: (_) => FocusScope.of(context).nextFocus(),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _nutrientCtrl,
                enabled: !_submitted,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Missing Nutrient (optional for bonus)',
                  prefixIcon: const Icon(Icons.science_outlined, size: 18),
                  hintText: 'e.g. Vitamin C, Iron, Iodine...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: AppColors.neuSurface,
                ),
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 16),
              if (!_submitted)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check_circle_outline, size: 20),
                    label: const Text('Submit Diagnosis', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: _submit,
                  ),
                ),
              const SizedBox(height: 80),
            ]),
          ),
          // Feedback overlay
          if (_submitted)
            AnswerFeedback(
              correct: _correct,
              message: _correct
                  ? 'Correct! ${ _case.disease}!'
                  : 'Incorrect! The answer was: ${_case.disease}',
              explanation: _case.explanation,
              onContinue: _continueGame,
            ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 2. WHO AM I?
// ═══════════════════════════════════════════════════════════════
class WhoAmIGame extends StatefulWidget {
  final VoidCallback onExit;
  const WhoAmIGame({super.key, required this.onExit});
  @override
  State<WhoAmIGame> createState() => _WhoAmIState();
}

class _WhoAmIState extends State<WhoAmIGame> {
  late WhoAmIItem _item;
  int _hintIndex = 0;
  final _ctrl = TextEditingController();
  bool _submitted = false;
  bool _correct = false;
  int _score = 0;
  int _round = 0;
  int _streak = 0;
  static const _maxRounds = 6;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _nextItem();
  }

  void _nextItem() {
    setState(() {
      _item = _ke.getNextWhoAmI();
      _hintIndex = 0;
      _ctrl.clear();
      _submitted = false;
    });
  }

  void _revealHint() {
    if (_hintIndex < _item.hints.length - 1) {
      setState(() => _hintIndex++);
      HapticFeedback.selectionClick();
    }
  }

  void _submit() {
    final ans = _ctrl.text.trim().toLowerCase();
    final correct = _item.answer.toLowerCase();
    _correct = ans.contains(correct.split(' ')[0]) || correct.contains(ans.split(' ')[0]);
    if (_correct) _streak++; else _streak = 0;
    showAnswerBurst(context, correct: _correct, streak: _streak);
    // Bonus: fewer hints = more points
    final bonus = (_item.hints.length - _hintIndex) * 5;
    if (_correct) {
      _score += 10 + bonus;
      _ke.recordAnswer(true);
      HapticFeedback.lightImpact();
    } else {
      _ke.recordAnswer(false);
    }
    setState(() {
      _submitted = true;
      _round++;
    });
  }

  void _continueGame() {
    if (_round >= _maxRounds) {
      setState(() => _finished = true);
    } else {
      _nextItem();
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    if (_finished) {
      return GameResultScreen(
        gameName: '🧩 Who Am I?',
        score: _score,
        maxScore: _maxRounds * 25,
        correct: _round,
        wrong: 0,
        facts: [_item.chapter],
        onPlayAgain: () { _round = 0; _score = 0; setState(() => _finished = false); _nextItem(); },
        onExit: widget.onExit,
      );
    }

    return GameShell(
      title: 'Who Am I?',
      emoji: '🧩',
      color: AppColors.primary,
      score: _score,
      streak: _ke.streak,
      onExit: widget.onExit,
      child: Stack(children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            // Round indicator
            Text('Round ${_round + 1} of $_maxRounds — Hint ${_hintIndex + 1} of ${_item.hints.length}',
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            // Hint card
            ...List.generate(_hintIndex + 1, (i) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: i == _hintIndex ? AppColors.primarySurface : AppColors.neuBackground,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: i == _hintIndex ? AppColors.primary : AppColors.border,
                ),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Hint ${i + 1}',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: i == _hintIndex ? AppColors.primary : AppColors.textHint)),
                const SizedBox(height: 4),
                Text(_item.hints[i],
                    style: TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: i == _hintIndex ? AppColors.textPrimary : AppColors.textSecondary)),
              ]),
            ).animate(key: ValueKey('hint_$i')).fadeIn(duration: 300.ms).slideY(begin: 0.1)),
            const SizedBox(height: 14),
            // Answer input
            TextField(
              controller: _ctrl,
              enabled: !_submitted,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: 'I am...',
                hintText: 'Type your answer',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: AppColors.neuSurface,
                prefixIcon: const Icon(Icons.quiz_outlined, size: 18),
              ),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 10),
            Row(children: [
              if (_hintIndex < _item.hints.length - 1 && !_submitted)
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.lightbulb_outlined, size: 16),
                    label: const Text('Next Hint (-5 pts)'),
                    onPressed: _revealHint,
                  ),
                ),
              if (_hintIndex < _item.hints.length - 1 && !_submitted) const SizedBox(width: 8),
              if (!_submitted)
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: const Text('Guess!', style: TextStyle(fontWeight: FontWeight.w800)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _submit,
                  ),
                ),
            ]),
            const SizedBox(height: 80),
          ]),
        ),
        if (_submitted)
          AnswerFeedback(
            correct: _correct,
            message: _correct ? 'You got it! I am ${_item.answer}!' : 'I was ${_item.answer}',
            explanation: _item.hints.last,
            onContinue: _continueGame,
          ),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 3. BINARY BLITZ (Hormone or Enzyme)
// ═══════════════════════════════════════════════════════════════
class BinaryBlitzGame extends StatefulWidget {
  final VoidCallback onExit;
  const BinaryBlitzGame({super.key, required this.onExit});
  @override
  State<BinaryBlitzGame> createState() => _BinaryBlitzState();
}

class _BinaryBlitzState extends State<BinaryBlitzGame> {
  late List<BinaryItem> _items;
  int _index = 0;
  int _score = 0;
  int _correct = 0;
  int _streak = 0;
  bool _answered = false;
  String? _selectedAnswer;
  bool _finished = false;
  static const _total = 15;

  @override
  void initState() {
    super.initState();
    _items = _ke.getShuffledBinaryItems(_total);
  }

  BinaryItem get _current => _items[_index];

  void _answer(String choice) {
    if (_answered) return;
    _selectedAnswer = choice;
    _answered = true;
    final ok = choice == _current.correct;
    if (ok) _streak++; else _streak = 0;
    showAnswerBurst(context, correct: ok, streak: _streak);
    if (ok) { _score += 10; _correct++; _ke.recordAnswer(true); HapticFeedback.lightImpact(); }
    else { _ke.recordAnswer(false); HapticFeedback.heavyImpact(); }
    setState(() {});
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      if (_index + 1 >= _total) {
        setState(() => _finished = true);
      } else {
        setState(() { _index++; _answered = false; _selectedAnswer = null; });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) {
      return GameResultScreen(
        gameName: '⚡ Binary Blitz',
        score: _score,
        maxScore: _total * 10,
        correct: _correct,
        wrong: _total - _correct,
        facts: [_items.last.trick],
        onPlayAgain: () { _index = 0; _score = 0; _correct = 0; _answered = false; _selectedAnswer = null; _items = _ke.getShuffledBinaryItems(_total); setState(() => _finished = false); },
        onExit: widget.onExit,
      );
    }

    final item = _current;
    final isCorrect = _selectedAnswer != null && _selectedAnswer == item.correct;
    final isWrong = _selectedAnswer != null && _selectedAnswer != item.correct;

    Color btnAColor = AppColors.neuSurface;
    Color btnBColor = AppColors.neuSurface;
    if (_answered) {
      if (item.correct == 'A') btnAColor = const Color(0xFFDCFCE7);
      else btnAColor = const Color(0xFFFFE4E4);
      if (item.correct == 'B') btnBColor = const Color(0xFFDCFCE7);
      else btnBColor = const Color(0xFFFFE4E4);
    }

    return GameShell(
      title: '${item.labelA} or ${item.labelB}?',
      emoji: '⚡',
      color: AppColors.accent,
      score: _score,
      streak: _ke.streak,
      onExit: widget.onExit,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          // Progress bar
          LinearProgressIndicator(
            value: _index / _total,
            backgroundColor: AppColors.border,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
          const SizedBox(height: 8),
          Text('${_index + 1} / $_total', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          const Spacer(),
          // Term
          GlowText(item.term, color: AppColors.accent, fontSize: 32)
              .animate(key: ValueKey(_index)).fadeIn(duration: 300.ms).scale(),
          const SizedBox(height: 8),
          const Text('Classify this as:', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const Spacer(),
          // Two big buttons
          Row(children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _answer('A'),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 80,
                  decoration: BoxDecoration(
                    color: _answered && _selectedAnswer == 'A' ? btnAColor : AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _answered && _selectedAnswer == 'A'
                          ? (item.correct == 'A' ? const Color(0xFF16A34A) : const Color(0xFFDC2626))
                          : AppColors.primary,
                      width: 2,
                    ),
                    boxShadow: AppColors.neuRaisedSoft,
                  ),
                  child: Center(
                    child: Text(item.labelA,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.primary)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => _answer('B'),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 80,
                  decoration: BoxDecoration(
                    color: _answered && _selectedAnswer == 'B' ? btnBColor : AppColors.accentSurface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _answered && _selectedAnswer == 'B'
                          ? (item.correct == 'B' ? const Color(0xFF16A34A) : const Color(0xFFDC2626))
                          : AppColors.accent,
                      width: 2,
                    ),
                    boxShadow: AppColors.neuRaisedSoft,
                  ),
                  child: Center(
                    child: Text(item.labelB,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.accent)),
                  ),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 16),
          // Trick / hint after answering
          AnimatedOpacity(
            opacity: _answered ? 1 : 0,
            duration: const Duration(milliseconds: 300),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (isCorrect) ? const Color(0xFFDCFCE7) : const Color(0xFFFFE4E4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(item.trick,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 12,
                      color: isCorrect ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                      height: 1.4)),
            ),
          ),
          const Spacer(),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 4. DESCENDING ORDER CHALLENGE
// ═══════════════════════════════════════════════════════════════
class DescendingOrderGame extends StatefulWidget {
  final VoidCallback onExit;
  const DescendingOrderGame({super.key, required this.onExit});
  @override
  State<DescendingOrderGame> createState() => _DescendingOrderState();
}

class _DescendingOrderState extends State<DescendingOrderGame> {
  late OrderChallenge _challenge;
  late List<String> _shuffled;
  List<String> _playerOrder = [];
  int _score = 0;
  int _round = 0;
  static const _maxRounds = 5;
  bool _submitted = false;
  bool _correct = false;
  bool _finished = false;
  int _streak = 0;

  @override
  void initState() {
    super.initState();
    _nextChallenge();
  }

  void _nextChallenge() {
    setState(() {
      _challenge = _ke.getNextOrderChallenge();
      _shuffled = _ke.shuffleOrder(_challenge.correctOrder);
      _playerOrder = [];
      _submitted = false;
    });
  }

  void _tapItem(String item) {
    if (_submitted) return;
    if (!_playerOrder.contains(item)) {
      setState(() => _playerOrder.add(item));
      HapticFeedback.selectionClick();
    }
  }

  void _removeItem(String item) {
    if (_submitted) return;
    setState(() => _playerOrder.remove(item));
  }

  void _submit() {
    _correct = _playerOrder.join() == _challenge.correctOrder.join();
    if (_correct) _streak++; else _streak = 0;
    showAnswerBurst(context, correct: _correct, streak: _streak);
    if (_correct) { _score += 20; _ke.recordAnswer(true); }
    else { _ke.recordAnswer(false); }
    setState(() { _submitted = true; _round++; });
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) {
      return GameResultScreen(
        gameName: '📊 Descending Order',
        score: _score,
        maxScore: _maxRounds * 20,
        correct: (_score / 20).round(),
        wrong: _maxRounds - (_score / 20).round(),
        facts: [_challenge.chapter],
        onPlayAgain: () { _round = 0; _score = 0; setState(() => _finished = false); _nextChallenge(); },
        onExit: widget.onExit,
      );
    }

    final remaining = _shuffled.where((s) => !_playerOrder.contains(s)).toList();

    return GameShell(
      title: 'Descending Order',
      emoji: '📊',
      color: const Color(0xFF7C3AED),
      score: _score,
      streak: _ke.streak,
      onExit: widget.onExit,
      child: Stack(children: [
        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Challenge header
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF7C3AED).withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF7C3AED).withOpacity(0.3)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('📋 ${_challenge.category}',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF7C3AED))),
                const SizedBox(height: 4),
                Text(_challenge.instruction,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4)),
                Text(_challenge.chapter,
                    style: const TextStyle(fontSize: 10, color: AppColors.textHint)),
              ]),
            ),
            const SizedBox(height: 14),
            // Player's current order
            const Text('Your Order:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              constraints: const BoxConstraints(minHeight: 60),
              decoration: BoxDecoration(
                color: AppColors.neuSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _submitted
                    ? (_correct ? const Color(0xFF16A34A) : const Color(0xFFDC2626))
                    : AppColors.border),
                boxShadow: AppColors.neuInset,
              ),
              child: _playerOrder.isEmpty
                  ? const Text('Tap items below to arrange them',
                      style: TextStyle(color: AppColors.textHint, fontSize: 12))
                  : Wrap(
                      spacing: 6, runSpacing: 6,
                      children: _playerOrder.asMap().entries.map((e) => GestureDetector(
                        onTap: () => _removeItem(e.value),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: _submitted
                                ? (e.key < _challenge.correctOrder.length && e.value == _challenge.correctOrder[e.key]
                                    ? const Color(0xFFDCFCE7) : const Color(0xFFFFE4E4))
                                : AppColors.primarySurface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Text('${e.key + 1}. ', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
                            Text(e.value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          ]),
                        ),
                      )).toList(),
                    ),
            ),
            if (_submitted && !_correct) ...[
              const SizedBox(height: 8),
              const Text('Correct order:',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF16A34A))),
              Wrap(
                spacing: 4,
                children: _challenge.correctOrder.asMap().entries.map((e) => Chip(
                  label: Text('${e.key + 1}. ${e.value}', style: const TextStyle(fontSize: 11)),
                  backgroundColor: const Color(0xFFDCFCE7),
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                )).toList(),
              ),
            ],
            const SizedBox(height: 14),
            // Available items
            const Text('Tap to add:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: remaining.map((item) => GestureDetector(
                onTap: () => _tapItem(item),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.neuSurface,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: AppColors.neuRaisedSoft,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(item, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              )).toList(),
            ),
            const Spacer(),
            if (!_submitted && _playerOrder.length == _challenge.correctOrder.length)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Submit Order', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                ),
              ),
            if (_submitted)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_round >= _maxRounds) { setState(() => _finished = true); }
                    else { _nextChallenge(); }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(_round >= _maxRounds ? 'See Results' : 'Next Challenge',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                ),
              ),
          ]),
        ),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 5. WHAT'S WRONG WITH THIS STATEMENT?
// ═══════════════════════════════════════════════════════════════
class WhatsWrongGame extends StatefulWidget {
  final VoidCallback onExit;
  const WhatsWrongGame({super.key, required this.onExit});
  @override
  State<WhatsWrongGame> createState() => _WhatsWrongState();
}

class _WhatsWrongState extends State<WhatsWrongGame> {
  late WrongStatement _stmt;
  final _ctrl = TextEditingController();
  bool _submitted = false;
  bool _correct = false;
  int _score = 0;
  int _round = 0;
  int _streak = 0;
  static const _maxRounds = 6;
  bool _finished = false;

  @override
  void initState() { super.initState(); _nextStmt(); }

  void _nextStmt() {
    setState(() {
      _stmt = _ke.getNextWrongStatement();
      _ctrl.clear();
      _submitted = false;
    });
  }

  void _submit() {
    final ans = _ctrl.text.trim().toLowerCase();
    final wrongWords = _stmt.wrongWord.toLowerCase().split('...');
    _correct = wrongWords.any((w) => ans.contains(w.trim().split(' ')[0]));
    if (_correct) _streak++; else _streak = 0;
    showAnswerBurst(context, correct: _correct, streak: _streak);
    if (_correct) { _score += 15; _ke.recordAnswer(true); }
    else { _ke.recordAnswer(false); }
    setState(() { _submitted = true; _round++; });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    if (_finished) {
      return GameResultScreen(
        gameName: '🔍 What\'s Wrong?',
        score: _score,
        maxScore: _maxRounds * 15,
        correct: (_score / 15).round(),
        wrong: _maxRounds - (_score / 15).round(),
        facts: [_stmt.correction],
        onPlayAgain: () { _round = 0; _score = 0; setState(() => _finished = false); _nextStmt(); },
        onExit: widget.onExit,
      );
    }

    return GameShell(
      title: "What's Wrong?",
      emoji: '🔍',
      color: const Color(0xFFDC2626),
      score: _score,
      streak: _ke.streak,
      onExit: widget.onExit,
      child: Stack(children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            Text('Round ${_round + 1} of $_maxRounds | ${_stmt.chapter}',
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFDC2626).withOpacity(0.06),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFDC2626).withOpacity(0.3)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('⚠️ THIS STATEMENT CONTAINS AN ERROR:',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFFDC2626), letterSpacing: 0.5)),
                const SizedBox(height: 10),
                Text('"${_stmt.statement}"',
                    style: const TextStyle(fontSize: 14, height: 1.65, fontStyle: FontStyle.italic, color: AppColors.textPrimary)),
              ]),
            ).animate().fadeIn(duration: 300.ms),
            const SizedBox(height: 20),
            const Text('What is wrong? Type the incorrect word(s) or describe the error:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            const SizedBox(height: 10),
            TextField(
              controller: _ctrl,
              enabled: !_submitted,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'e.g. "viral" should be "bacterial"',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: AppColors.neuSurface,
              ),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 12),
            if (!_submitted)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Flag the Error', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                ),
              ),
            if (_submitted) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _correct ? const Color(0xFFDCFCE7) : const Color(0xFFFFE4E4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(_correct ? '✅ Correct!' : '❌ The error was:',
                      style: TextStyle(fontWeight: FontWeight.w800, color: _correct ? const Color(0xFF16A34A) : const Color(0xFFDC2626))),
                  const SizedBox(height: 6),
                  if (!_correct) Text('Wrong: "${_stmt.wrongWord}"',
                      style: const TextStyle(fontSize: 12, color: Color(0xFFDC2626))),
                  const SizedBox(height: 4),
                  Text('Correction: ${_stmt.correction}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, height: 1.4)),
                ]),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_round >= _maxRounds) { setState(() => _finished = true); }
                    else { _nextStmt(); }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(_round >= _maxRounds ? 'See Results' : 'Next Statement',
                      style: const TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
            ],
            const SizedBox(height: 30),
          ]),
        ),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 6. ASSASSIN PROTEIN
// ═══════════════════════════════════════════════════════════════
class AssassinProteinGame extends StatefulWidget {
  final VoidCallback onExit;
  const AssassinProteinGame({super.key, required this.onExit});
  @override
  State<AssassinProteinGame> createState() => _AssassinProteinState();
}

class _AssassinProteinState extends State<AssassinProteinGame> {
  late AssassinScenario _scenario;
  late List<String> _suspects;
  String? _selected;
  bool _submitted = false;
  bool _correct = false;
  int _score = 0;
  int _round = 0;
  int _streak = 0;
  static const _maxRounds = 5;
  bool _finished = false;

  @override
  void initState() { super.initState(); _nextScenario(); }

  void _nextScenario() {
    setState(() {
      _scenario = _ke.getNextAssassin();
      _suspects = _ke.shuffledSuspects(_scenario);
      _selected = null;
      _submitted = false;
    });
  }

  void _select(String suspect) {
    if (_submitted) return;
    setState(() => _selected = suspect);
  }

  void _submit() {
    if (_selected == null) return;
    _correct = _selected == _scenario.suspects[_scenario.culpritIndex];
    if (_correct) _streak++; else _streak = 0;
    showAnswerBurst(context, correct: _correct, streak: _streak);
    if (_correct) { _score += 20; _ke.recordAnswer(true); HapticFeedback.lightImpact(); }
    else { _ke.recordAnswer(false); HapticFeedback.heavyImpact(); }
    setState(() { _submitted = true; _round++; });
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) {
      return GameResultScreen(
        gameName: '🔪 Assassin Protein',
        score: _score,
        maxScore: _maxRounds * 20,
        correct: (_score / 20).round(),
        wrong: _maxRounds - (_score / 20).round(),
        facts: [_scenario.explanation],
        onPlayAgain: () { _round = 0; _score = 0; setState(() => _finished = false); _nextScenario(); },
        onExit: widget.onExit,
      );
    }

    final culprit = _scenario.suspects[_scenario.culpritIndex];

    return GameShell(
      title: 'Assassin Protein',
      emoji: '🔪',
      color: const Color(0xFF7C3AED),
      score: _score,
      streak: _ke.streak,
      onExit: widget.onExit,
      child: Stack(children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            Text('Case ${_round + 1} of $_maxRounds | ${_scenario.chapter}',
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            const SizedBox(height: 14),
            // Crime scene
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF7C3AED).withOpacity(0.06),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF7C3AED).withOpacity(0.3)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Row(children: [
                  Text('🚨', style: TextStyle(fontSize: 18)),
                  SizedBox(width: 8),
                  Text('CRIME SCENE REPORT',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800,
                          color: Color(0xFF7C3AED), letterSpacing: 0.5)),
                ]),
                const SizedBox(height: 10),
                Text(_scenario.scenario,
                    style: const TextStyle(fontSize: 13, height: 1.6, color: AppColors.textPrimary)),
              ]),
            ).animate().fadeIn(),
            const SizedBox(height: 20),
            const Text('🔍 SUSPECTS:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textSecondary)),
            const SizedBox(height: 10),
            ..._suspects.map((s) {
              Color bg = AppColors.neuSurface;
              Color border = AppColors.border;
              if (_submitted) {
                if (s == culprit) { bg = const Color(0xFFDCFCE7); border = const Color(0xFF16A34A); }
                else if (s == _selected && s != culprit) { bg = const Color(0xFFFFE4E4); border = const Color(0xFFDC2626); }
              } else if (_selected == s) {
                bg = const Color(0xFF7C3AED).withOpacity(0.1);
                border = const Color(0xFF7C3AED);
              }
              return GestureDetector(
                onTap: () => _select(s),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: bg, borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: border, width: 1.5),
                    boxShadow: AppColors.neuRaisedSoft,
                  ),
                  child: Row(children: [
                    Icon(
                      _submitted
                          ? (s == culprit ? Icons.gavel_rounded : Icons.check_circle_outline)
                          : (_selected == s ? Icons.radio_button_checked : Icons.radio_button_unchecked),
                      color: _submitted
                          ? (s == culprit ? const Color(0xFF16A34A) : AppColors.textHint)
                          : (_selected == s ? const Color(0xFF7C3AED) : AppColors.textHint),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(s, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
                    if (_submitted && s == culprit)
                      const Text('🔪 GUILTY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF16A34A))),
                  ]),
                ),
              );
            }),
            const SizedBox(height: 10),
            if (_submitted) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.infoSurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Row(children: [
                    Text('🧬', style: TextStyle(fontSize: 16)),
                    SizedBox(width: 6),
                    Text('Forensic Report:', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: AppColors.info)),
                  ]),
                  const SizedBox(height: 6),
                  Text(_scenario.explanation, style: const TextStyle(fontSize: 12, color: AppColors.info, height: 1.5)),
                ]),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_round >= _maxRounds) { setState(() => _finished = true); }
                    else { _nextScenario(); }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(_round >= _maxRounds ? 'See Results' : 'Next Case',
                      style: const TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
            ] else if (_selected != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Arrest Suspect', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                ),
              ),
            const SizedBox(height: 30),
          ]),
        ),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 7. PUNNETT SQUARE PRO
// ═══════════════════════════════════════════════════════════════
class PunnettSquareGame extends StatefulWidget {
  final VoidCallback onExit;
  const PunnettSquareGame({super.key, required this.onExit});
  @override
  State<PunnettSquareGame> createState() => _PunnettSquareState();
}

class _PunnettSquareState extends State<PunnettSquareGame> {
  late PunnettProblem _problem;
  final _gCtrl = TextEditingController();
  final _pCtrl = TextEditingController();
  bool _submitted = false;
  bool _correct = false;
  int _score = 0;
  int _round = 0;
  static const _maxRounds = 5;
  bool _finished = false;
  bool _showGenotype = false;
  int _streak = 0;

  @override
  void initState() { super.initState(); _nextProblem(); }

  void _nextProblem() {
    setState(() {
      _problem = _ke.getNextPunnett();
      _gCtrl.clear();
      _pCtrl.clear();
      _submitted = false;
      _showGenotype = false;
    });
  }

  void _submit() {
    final pAns = _pCtrl.text.trim().toLowerCase();
    final correct = _problem.phenotypeRatio.toLowerCase();
    _correct = pAns.contains(correct.split(':')[0].trim()) || pAns.contains('3') || correct.contains(pAns.split(':')[0].trim());
    if (_correct) _streak++; else _streak = 0;
    showAnswerBurst(context, correct: _correct, streak: _streak);
    if (_correct) { _score += 20; _ke.recordAnswer(true); }
    else { _ke.recordAnswer(false); }
    setState(() { _submitted = true; _round++; });
  }

  @override
  void dispose() { _gCtrl.dispose(); _pCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    if (_finished) {
      return GameResultScreen(
        gameName: '🧬 Punnett Square Pro',
        score: _score,
        maxScore: _maxRounds * 20,
        correct: (_score / 20).round(),
        wrong: _maxRounds - (_score / 20).round(),
        facts: [_problem.hint],
        onPlayAgain: () { _round = 0; _score = 0; setState(() => _finished = false); _nextProblem(); },
        onExit: widget.onExit,
      );
    }

    return GameShell(
      title: 'Punnett Square Pro',
      emoji: '🧬',
      color: const Color(0xFF0891B2),
      score: _score,
      streak: _ke.streak,
      onExit: widget.onExit,
      child: Stack(children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            Text('Round ${_round + 1} of $_maxRounds | ${_problem.chapter}',
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            // Cross
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF0891B2).withOpacity(0.06),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF0891B2).withOpacity(0.3)),
              ),
              child: Column(children: [
                Text('🔬 ${_problem.cross}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF0891B2))),
                const Divider(height: 16),
                Text(_problem.question,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13, height: 1.6)),
              ]),
            ).animate().fadeIn(),
            const SizedBox(height: 20),
            // Hint button
            TextButton.icon(
              icon: const Icon(Icons.lightbulb_outline_rounded, size: 16, color: AppColors.accent),
              label: const Text('Hint', style: TextStyle(color: AppColors.accent, fontSize: 12)),
              onPressed: () => setState(() => _showGenotype = !_showGenotype),
            ),
            if (_showGenotype) Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppColors.accentSurface, borderRadius: BorderRadius.circular(10)),
              child: Text(_problem.hint,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: AppColors.accent, height: 1.4)),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _gCtrl,
              enabled: !_submitted,
              decoration: InputDecoration(
                labelText: 'Genotypic ratio (e.g. 1:2:1)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: AppColors.neuSurface,
                prefixIcon: const Icon(Icons.biotech_outlined, size: 18),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _pCtrl,
              enabled: !_submitted,
              decoration: InputDecoration(
                labelText: 'Phenotypic ratio (e.g. 3:1)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: AppColors.neuSurface,
                prefixIcon: const Icon(Icons.people_outline_rounded, size: 18),
              ),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 14),
            if (_submitted) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _correct ? const Color(0xFFDCFCE7) : const Color(0xFFFFE4E4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(_correct ? '✅ Excellent genetics knowledge!' : '❌ Correct answer:',
                      style: TextStyle(fontWeight: FontWeight.w800, color: _correct ? const Color(0xFF16A34A) : const Color(0xFFDC2626))),
                  const SizedBox(height: 6),
                  Text('Genotypic: ${_problem.genotypeRatio}', style: const TextStyle(fontSize: 12)),
                  Text('Phenotypic: ${_problem.phenotypeRatio}', style: const TextStyle(fontSize: 12)),
                  Text('Description: ${_problem.phenotypeDescriptions}',
                      style: const TextStyle(fontSize: 12, height: 1.4, color: AppColors.textSecondary)),
                ]),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_round >= _maxRounds) { setState(() => _finished = true); }
                    else { _nextProblem(); }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0891B2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(_round >= _maxRounds ? 'See Results' : 'Next Cross',
                      style: const TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
            ] else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0891B2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Submit Ratios', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                ),
              ),
            const SizedBox(height: 30),
          ]),
        ),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 8. PLOIDY PATROL
// ═══════════════════════════════════════════════════════════════
class PloidyPatrolGame extends StatefulWidget {
  final VoidCallback onExit;
  const PloidyPatrolGame({super.key, required this.onExit});
  @override
  State<PloidyPatrolGame> createState() => _PloidyPatrolState();
}

class _PloidyPatrolState extends State<PloidyPatrolGame> {
  late PloidyQuestion _q;
  late List<String> _options;
  String? _selected;
  bool _submitted = false;
  bool _correct = false;
  int _score = 0;
  int _round = 0;
  static const _maxRounds = 6;
  bool _finished = false;
  int _streak = 0;

  @override
  void initState() { super.initState(); _nextQ(); }

  void _nextQ() {
    setState(() {
      _q = _ke.getNextPloidy();
      _options = _ke.ploidyOptions(_q);
      _selected = null;
      _submitted = false;
    });
  }

  void _select(String opt) {
    if (_submitted) return;
    setState(() => _selected = opt);
  }

  void _submit() {
    if (_selected == null) return;
    _correct = _selected!.contains(_q.correctPloidy.split(' ')[0]) ||
        _q.correctPloidy.contains(_selected!.split(' ')[0]);
    if (_correct) _streak++; else _streak = 0;
    showAnswerBurst(context, correct: _correct, streak: _streak);
    if (_correct) { _score += 15; _ke.recordAnswer(true); }
    else { _ke.recordAnswer(false); }
    setState(() { _submitted = true; _round++; });
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) {
      return GameResultScreen(
        gameName: '🔬 Ploidy Patrol',
        score: _score,
        maxScore: _maxRounds * 15,
        correct: (_score / 15).round(),
        wrong: _maxRounds - (_score / 15).round(),
        facts: [_q.explanation],
        onPlayAgain: () { _round = 0; _score = 0; setState(() => _finished = false); _nextQ(); },
        onExit: widget.onExit,
      );
    }

    return GameShell(
      title: 'Ploidy Patrol',
      emoji: '🔢',
      color: const Color(0xFF16A34A),
      score: _score,
      streak: _ke.streak,
      onExit: widget.onExit,
      child: Stack(children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            Text('Q${_round + 1}/$_maxRounds | ${_q.chapter}',
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            // Scenario
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF16A34A).withOpacity(0.07),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF16A34A).withOpacity(0.3)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('🔬 ${_q.organism}',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF16A34A))),
                const SizedBox(height: 8),
                Text(_q.scenario, style: const TextStyle(fontSize: 13.5, height: 1.6)),
                const SizedBox(height: 8),
                Text('Stage: ${_q.stage}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              ]),
            ).animate().fadeIn(),
            const SizedBox(height: 20),
            const Text('What is the PLOIDY at this stage?',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            ..._options.map((opt) {
              Color bg = AppColors.neuSurface;
              Color border = AppColors.border;
              if (_submitted) {
                if (opt.contains(_q.correctPloidy.split(' ')[0]) || _q.correctPloidy.contains(opt.split(' ')[0])) {
                  bg = const Color(0xFFDCFCE7); border = const Color(0xFF16A34A);
                } else if (_selected == opt) {
                  bg = const Color(0xFFFFE4E4); border = const Color(0xFFDC2626);
                }
              } else if (_selected == opt) {
                bg = const Color(0xFF16A34A).withOpacity(0.1);
                border = const Color(0xFF16A34A);
              }
              return GestureDetector(
                onTap: () => _select(opt),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: bg, borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: border, width: 1.5),
                    boxShadow: AppColors.neuRaisedSoft,
                  ),
                  child: Text(opt, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                ),
              );
            }),
            if (_submitted) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.infoSurface, borderRadius: BorderRadius.circular(12)),
                child: Text(_q.explanation, style: const TextStyle(fontSize: 12, color: AppColors.info, height: 1.4)),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_round >= _maxRounds) { setState(() => _finished = true); }
                    else { _nextQ(); }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(_round >= _maxRounds ? 'See Results' : 'Next Stage',
                      style: const TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
            ] else if (_selected != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Confirm Ploidy', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                ),
              ),
            const SizedBox(height: 30),
          ]),
        ),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 9. INVADER FROM ABIOTIC WORLD
// ═══════════════════════════════════════════════════════════════
class InvaderAbioticGame extends StatefulWidget {
  final VoidCallback onExit;
  const InvaderAbioticGame({super.key, required this.onExit});
  @override
  State<InvaderAbioticGame> createState() => _InvaderAbioticState();
}

class _InvaderAbioticState extends State<InvaderAbioticGame> {
  late InvaderScenario _scenario;
  late List<String> _shuffled;
  String? _selected;
  bool _submitted = false;
  bool _correct = false;
  int _score = 0;
  int _round = 0;
  int _streak = 0;
  static const _maxRounds = 5;
  bool _finished = false;

  @override
  void initState() { super.initState(); _nextScenario(); }

  void _nextScenario() {
    setState(() {
      _scenario = _ke.getNextInvader();
      _shuffled = _ke.shuffledDefenses(_scenario);
      _selected = null;
      _submitted = false;
    });
  }

  void _select(String s) { if (_submitted) return; setState(() => _selected = s); }

  void _submit() {
    if (_selected == null) return;
    final correct = _scenario.defenses[_scenario.correctIndex];
    _correct = _selected == correct;
    if (_correct) _streak++; else _streak = 0;
    showAnswerBurst(context, correct: _correct, streak: _streak);
    if (_correct) { _score += 20; _ke.recordAnswer(true); }
    else { _ke.recordAnswer(false); }
    setState(() { _submitted = true; _round++; });
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) {
      return GameResultScreen(
        gameName: '🛡️ Invader: Abiotic World',
        score: _score,
        maxScore: _maxRounds * 20,
        correct: (_score / 20).round(),
        wrong: _maxRounds - (_score / 20).round(),
        facts: [_scenario.explanation],
        onPlayAgain: () { _round = 0; _score = 0; setState(() => _finished = false); _nextScenario(); },
        onExit: widget.onExit,
      );
    }

    final correct = _scenario.defenses[_scenario.correctIndex];

    return GameShell(
      title: 'Invader: Abiotic World',
      emoji: '🛡️',
      color: const Color(0xFF7C3AED),
      score: _score,
      streak: _ke.streak,
      onExit: widget.onExit,
      child: Stack(children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            Text('Mission ${_round + 1}/$_maxRounds | ${_scenario.chapter}',
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red.withOpacity(0.4)),
              ),
              child: Column(children: [
                Text(_scenario.alert,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, height: 1.5)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFF7C3AED).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text('Defence Category: ${_scenario.category}',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF7C3AED))),
                ),
              ]),
            ).animate().fadeIn().shake(hz: 1, offset: const Offset(2, 0)),
            const SizedBox(height: 16),
            const Text('CHOOSE YOUR DEFENCE:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.5, color: AppColors.textSecondary)),
            const SizedBox(height: 10),
            ..._shuffled.map((s) {
              Color bg = AppColors.neuSurface; Color border = AppColors.border;
              if (_submitted) {
                if (s == correct) { bg = const Color(0xFFDCFCE7); border = const Color(0xFF16A34A); }
                else if (_selected == s && s != correct) { bg = const Color(0xFFFFE4E4); border = const Color(0xFFDC2626); }
              } else if (_selected == s) { bg = const Color(0xFF7C3AED).withOpacity(0.1); border = const Color(0xFF7C3AED); }
              return GestureDetector(
                onTap: () => _select(s),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: bg, borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: border, width: 1.5),
                    boxShadow: AppColors.neuRaisedSoft,
                  ),
                  child: Row(children: [
                    Icon(_selected == s ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                        size: 18, color: _selected == s ? const Color(0xFF7C3AED) : AppColors.textHint),
                    const SizedBox(width: 10),
                    Expanded(child: Text(s, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600))),
                  ]),
                ),
              );
            }),
            if (_submitted) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.infoSurface, borderRadius: BorderRadius.circular(12)),
                child: Text(_scenario.explanation, style: const TextStyle(fontSize: 12, color: AppColors.info, height: 1.4)),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_round >= _maxRounds) { setState(() => _finished = true); }
                    else { _nextScenario(); }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(_round >= _maxRounds ? 'See Results' : 'Next Mission',
                      style: const TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
            ] else if (_selected != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Deploy Defence!', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                ),
              ),
            const SizedBox(height: 30),
          ]),
        ),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 10. BIOLOGY ANTAKSHARI (Word Chain)
// ═══════════════════════════════════════════════════════════════
class AntakshariGame extends StatefulWidget {
  final VoidCallback onExit;
  const AntakshariGame({super.key, required this.onExit});
  @override
  State<AntakshariGame> createState() => _AntakshariState();
}

class _AntakshariState extends State<AntakshariGame> {
  final _ctrl = TextEditingController();
  final List<Map<String, dynamic>> _chain = []; // {word, byPlayer}
  String _currentLetter = 'G'; // start with G (Glycolysis)
  int _score = 0;
  int _skips = 3;
  Timer? _timer;
  int _timeLeft = 20;
  String? _error;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _chain.add({'word': 'GLYCOLYSIS', 'byPlayer': false});
    _currentLetter = 'S';
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timeLeft = 20;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _timeLeft--);
      if (_timeLeft <= 0) {
        _timer?.cancel();
        _computerPlay();
      }
    });
  }

  void _submitWord() {
    final word = _ctrl.text.trim().toUpperCase();
    _ctrl.clear();

    if (word.isEmpty || !word.startsWith(_currentLetter)) {
      setState(() => _error = 'Must start with $_currentLetter!');
      return;
    }
    if (!_ke.isValidBioTerm(word)) {
      setState(() => _error = '"$word" is not a valid NCERT biology term.');
      return;
    }
    if (_chain.any((c) => c['word'] == word)) {
      setState(() => _error = '"$word" was already used!');
      return;
    }

    _timer?.cancel();
    _score += 10 + _timeLeft;
    _chain.add({'word': word, 'byPlayer': true});
    _currentLetter = word[word.length - 1];
    setState(() => _error = null);
    HapticFeedback.lightImpact();

    // Computer responds
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      _computerPlay();
    });
  }

  void _computerPlay() {
    final used = _chain.map((c) => c['word'] as String).toSet();
    final word = _ke.antakshariFindWord(_currentLetter, used);
    if (word == null) {
      // Computer can't answer — player wins!
      setState(() => _finished = true);
      return;
    }
    _chain.add({'word': word, 'byPlayer': false});
    _currentLetter = word[word.length - 1];
    setState(() {});
    _startTimer();
  }

  void _skip() {
    if (_skips <= 0) return;
    _timer?.cancel();
    _skips--;
    setState(() {});
    _computerPlay();
  }

  @override
  void dispose() { _ctrl.dispose(); _timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    if (_finished) {
      return GameResultScreen(
        gameName: '🎵 Biology Antakshari',
        score: _score,
        maxScore: 200,
        correct: _chain.where((c) => c['byPlayer'] == true).length,
        wrong: 0,
        facts: const ['Biology Antakshari builds vocabulary through chain association — one of the most effective memory techniques!'],
        onPlayAgain: () {
          _chain.clear();
          _chain.add({'word': 'GLYCOLYSIS', 'byPlayer': false});
          _currentLetter = 'S';
          _score = 0;
          _skips = 3;
          setState(() => _finished = false);
          _startTimer();
        },
        onExit: widget.onExit,
      );
    }

    return GameShell(
      title: 'Biology Antakshari',
      emoji: '🎵',
      color: const Color(0xFFD97706),
      score: _score,
      streak: _ke.streak,
      timerWidget: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: _timeLeft <= 5 ? AppColors.errorSurface : AppColors.warningSurface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text('⏱ ${_timeLeft}s',
            style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 13,
                color: _timeLeft <= 5 ? AppColors.error : AppColors.warning)),
      ),
      onExit: widget.onExit,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(children: [
          // Current letter prompt
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              gradient: AppColors.accentGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(children: [
              const Text('Your word must start with:',
                  style: TextStyle(fontSize: 11, color: Colors.white70)),
              Text(_currentLetter,
                  style: const TextStyle(fontSize: 44, fontWeight: FontWeight.w900, color: Colors.white)),
            ]),
          ).animate().scale(duration: 300.ms, curve: Curves.elasticOut),
          const SizedBox(height: 14),
          // Chain display
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _chain.length,
              itemBuilder: (_, i) {
                final item = _chain[_chain.length - 1 - i];
                final byPlayer = item['byPlayer'] as bool;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    mainAxisAlignment: byPlayer ? MainAxisAlignment.end : MainAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: byPlayer ? AppColors.primaryGradient : null,
                          color: byPlayer ? null : AppColors.neuSurface,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: Radius.circular(byPlayer ? 16 : 4),
                            bottomRight: Radius.circular(byPlayer ? 4 : 16),
                          ),
                          border: byPlayer ? null : Border.all(color: AppColors.border),
                          boxShadow: AppColors.neuRaisedSoft,
                        ),
                        child: Text(item['word'] as String,
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: byPlayer ? Colors.white : AppColors.textPrimary)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          if (_error != null) Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 12)),
          // Input
          Row(children: [
            Expanded(
              child: TextField(
                controller: _ctrl,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: 'Type a biology term starting with $_currentLetter...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: AppColors.neuSurface,
                  isDense: true,
                ),
                onSubmitted: (_) => _submitWord(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.send_rounded, color: AppColors.primary),
              onPressed: _submitWord,
            ),
          ]),
          const SizedBox(height: 6),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            TextButton.icon(
              icon: const Icon(Icons.skip_next_rounded, size: 16),
              label: Text('Skip ($_skips left)', style: const TextStyle(fontSize: 12)),
              onPressed: _skips > 0 ? _skip : null,
              style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
            ),
          ]),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 11. GARBAGE COLLECTOR
// ═══════════════════════════════════════════════════════════════
class GarbageCollectorGame extends StatefulWidget {
  final VoidCallback onExit;
  const GarbageCollectorGame({super.key, required this.onExit});
  @override
  State<GarbageCollectorGame> createState() => _GarbageCollectorState();
}

class _GarbageCollectorState extends State<GarbageCollectorGame> {
  late List<WasteItem> _items;
  int _index = 0;
  int _score = 0;
  int _correct = 0;
  int _streak = 0;
  String? _selected;
  bool _answered = false;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _items = _ke.getShuffledWasteItems();
  }

  WasteItem get _current => _items[_index];

  void _select(String bin) {
    if (_answered) return;
    _selected = bin;
    final ok = bin == _current.correctBin ||
        _current.correctBin.toLowerCase().contains(bin.toLowerCase()) ||
        bin.toLowerCase().contains(_current.correctBin.toLowerCase().split('/')[0]);
    if (ok) _streak++; else _streak = 0;
    showAnswerBurst(context, correct: ok, streak: _streak);
    if (ok) { _score += 15; _correct++; _ke.recordAnswer(true); HapticFeedback.lightImpact(); }
    else { _ke.recordAnswer(false); HapticFeedback.heavyImpact(); }
    setState(() => _answered = true);
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (!mounted) return;
      if (_index + 1 >= _items.length) { setState(() => _finished = true); }
      else { setState(() { _index++; _answered = false; _selected = null; }); }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) {
      return GameResultScreen(
        gameName: '♻️ Garbage Collector',
        score: _score,
        maxScore: _items.length * 15,
        correct: _correct,
        wrong: _items.length - _correct,
        facts: const ['Ureotelic (urea), uricotelic (uric acid), ammonotelic (ammonia) — three strategies for nitrogen waste, each suited to different habitats!'],
        onPlayAgain: () { _index = 0; _score = 0; _correct = 0; _answered = false; _selected = null; _items = _ke.getShuffledWasteItems(); setState(() => _finished = false); },
        onExit: widget.onExit,
      );
    }

    final item = _current;
    final bins = item.bins;

    return GameShell(
      title: 'Garbage Collector',
      emoji: '♻️',
      color: const Color(0xFF16A34A),
      score: _score,
      streak: _ke.streak,
      onExit: widget.onExit,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          // Waste molecule
          const Text('Sort this waste molecule:',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          GlowText(item.molecule, color: const Color(0xFF16A34A), fontSize: 34)
              .animate(key: ValueKey(_index)).scale(duration: 400.ms, curve: Curves.elasticOut).fadeIn(),
          const Spacer(),
          // Bins
          ...bins.map((bin) {
            final isCorrect = bin == item.correctBin || item.correctBin.toLowerCase().contains(bin.toLowerCase());
            Color bg = AppColors.neuSurface; Color border = AppColors.border;
            if (_answered) {
              if (isCorrect) { bg = const Color(0xFFDCFCE7); border = const Color(0xFF16A34A); }
              else if (_selected == bin && !isCorrect) { bg = const Color(0xFFFFE4E4); border = const Color(0xFFDC2626); }
            }
            return GestureDetector(
              onTap: () => _select(bin),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: bg, borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: border, width: 2),
                  boxShadow: AppColors.neuRaisedSoft,
                ),
                child: Center(
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Text('🗑️', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 10),
                    Text(bin, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                  ]),
                ),
              ),
            );
          }),
          if (_answered) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.infoSurface, borderRadius: BorderRadius.circular(12)),
              child: Text(item.fact,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11.5, color: AppColors.info, height: 1.4)),
            ),
          ],
          const Spacer(),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 12. ROOT WORD BOTANY
// ═══════════════════════════════════════════════════════════════
class RootWordBotanyGame extends StatefulWidget {
  final VoidCallback onExit;
  const RootWordBotanyGame({super.key, required this.onExit});
  @override
  State<RootWordBotanyGame> createState() => _RootWordBotanyState();
}

class _RootWordBotanyState extends State<RootWordBotanyGame> {
  late RootWordItem _item;
  final List<TextEditingController> _ctrls = [];
  final _bonusCtrl = TextEditingController();
  bool _submitted = false;
  bool _correct = false;
  int _score = 0;
  int _round = 0;
  static const _maxRounds = 5;
  bool _finished = false;
  int _streak = 0;

  @override
  void initState() { super.initState(); _nextItem(); }

  void _nextItem() {
    for (final c in _ctrls) c.dispose();
    _ctrls.clear();
    _bonusCtrl.clear();
    setState(() {
      _item = _ke.getRandomRootWord();
      _ctrls.addAll(List.generate(_item.roots.length, (_) => TextEditingController()));
      _submitted = false;
    });
  }

  void _submit() {
    int pts = 0;
    for (int i = 0; i < _item.roots.length; i++) {
      final ans = _ctrls[i].text.trim().toLowerCase();
      final correct = _item.roots[i]['meaning']!.toLowerCase();
      if (ans.contains(correct.split(' ')[0]) || correct.contains(ans.split(' ')[0])) {
        pts += 10;
      }
    }
    final bonusAns = _bonusCtrl.text.trim().toLowerCase();
    final bonusCorrect = _item.bonusAnswer.toLowerCase();
    if (bonusAns.contains(bonusCorrect.split(' ')[0]) || bonusCorrect.contains(bonusAns.split(' ')[0])) {
      pts += 5;
    }
    _correct = pts > 0;
    if (_correct) _streak++; else _streak = 0;
    showAnswerBurst(context, correct: _correct, streak: _streak);
    _score += pts;
    _ke.recordAnswer(_correct);
    setState(() { _submitted = true; _round++; });
  }

  @override
  void dispose() {
    for (final c in _ctrls) c.dispose();
    _bonusCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) {
      return GameResultScreen(
        gameName: '🌿 Root Word Botany',
        score: _score,
        maxScore: _maxRounds * 25,
        correct: (_score / 20).round(),
        wrong: 0,
        facts: const ['Etymology helps you decode unfamiliar scientific terms in NEET. Most biology terms come from Greek and Latin roots!'],
        onPlayAgain: () { _round = 0; _score = 0; setState(() => _finished = false); _nextItem(); },
        onExit: widget.onExit,
      );
    }

    return GameShell(
      title: 'Root Word Botany',
      emoji: '🌿',
      color: const Color(0xFF16A34A),
      score: _score,
      streak: _ke.streak,
      onExit: widget.onExit,
      child: Stack(children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            Text('Round ${_round + 1}/$_maxRounds | ${_item.chapter}',
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            GlowText(_item.term, color: const Color(0xFF16A34A), fontSize: 28)
                .animate(key: ValueKey(_item.term)).fadeIn().scale(),
            const SizedBox(height: 20),
            ...List.generate(_item.roots.length, (i) {
              final root = _item.roots[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Root: "${root['root']}" means...?',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _ctrls[i],
                    enabled: !_submitted,
                    decoration: InputDecoration(
                      hintText: 'Type the meaning of "${root['root']}"',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      filled: true,
                      fillColor: AppColors.neuSurface,
                      isDense: true,
                      suffixText: _submitted ? root['meaning'] : null,
                    ),
                  ),
                ]),
              );
            }),
            // Bonus
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.accentSurface, borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.accent.withOpacity(0.3)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('🌟 BONUS (+5 pts):',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.accent)),
                const SizedBox(height: 6),
                Text(_item.bonus, style: const TextStyle(fontSize: 12.5, height: 1.4)),
                const SizedBox(height: 8),
                TextField(
                  controller: _bonusCtrl,
                  enabled: !_submitted,
                  decoration: InputDecoration(
                    hintText: 'Your answer',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    filled: true,
                    fillColor: AppColors.neuSurface,
                    isDense: true,
                    suffixText: _submitted ? _item.bonusAnswer : null,
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 16),
            if (!_submitted)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A), foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Decode!', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_round >= _maxRounds) { setState(() => _finished = true); }
                    else { _nextItem(); }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A), foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(_round >= _maxRounds ? 'See Results' : 'Next Term',
                      style: const TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
            const SizedBox(height: 30),
          ]),
        ),
      ]),
    );
  }
}
