import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import 'game_data_2.dart';
import 'game_engine_widgets.dart';
import 'knowledge_engine.dart';

final _ke2 = KnowledgeEngine.instance;

// ═══════════════════════════════════════════════════════════════
// 1. NEET RAPID FIRE ARENA
// ═══════════════════════════════════════════════════════════════
class NeetRapidFireGame extends StatefulWidget {
  final VoidCallback onExit;
  const NeetRapidFireGame({super.key, required this.onExit});
  @override
  State<NeetRapidFireGame> createState() => _NeetRapidFireState();
}

class _NeetRapidFireState extends State<NeetRapidFireGame> {
  late List<RapidFireQ> _questions;
  int _index = 0;
  int _score = 0;
  int _streak = 0;
  int _timeLeft = 5;
  Timer? _timer;
  String? _selected;
  bool _answered = false;
  bool _finished = false;
  int _correct = 0;

  @override
  void initState() {
    super.initState();
    _questions = List.from(rapidFireQuestions)..shuffle();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timeLeft = 5;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _timeLeft--);
      if (_timeLeft <= 0) { _timer?.cancel(); _autoSelect(); }
    });
  }

  void _autoSelect() {
    if (!_answered) _selectAnswer('__timeout__');
  }

  void _selectAnswer(String ans) {
    if (_answered) return;
    _timer?.cancel();
    _selected = ans;
    _answered = true;
    final q = _questions[_index];
    final ok = ans == q.options[q.correctIndex];
    if (ok) {
      final bonus = _timeLeft >= 4 ? 30 : _timeLeft >= 3 ? 20 : 10;
      _score += bonus;
      _correct++;
      _streak++;
      _ke2.recordAnswer(true);
      HapticFeedback.lightImpact();
    } else {
      _streak = 0;
      _ke2.recordAnswer(false);
      if (ans != '__timeout__') HapticFeedback.heavyImpact();
    }
    setState(() {});
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      if (_index + 1 >= _questions.length) { setState(() => _finished = true); }
      else { setState(() { _index++; _answered = false; _selected = null; }); _startTimer(); }
    });
  }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    if (_finished) {
      return GameResultScreen(
        gameName: '🏟️ NEET Rapid Fire Arena',
        score: _score,
        maxScore: _questions.length * 30,
        correct: _correct,
        wrong: _questions.length - _correct,
        facts: [_questions.last.explanation],
        onPlayAgain: () { _index = 0; _score = 0; _streak = 0; _correct = 0; _answered = false; _selected = null; _questions.shuffle(); setState(() => _finished = false); _startTimer(); },
        onExit: widget.onExit,
      );
    }

    final q = _questions[_index];
    final timeRatio = _timeLeft / 5.0;
    final timerColor = timeRatio > 0.5 ? AppColors.success : timeRatio > 0.25 ? Colors.orange : AppColors.error;

    return GameShell(
      title: 'NEET Rapid Fire Arena',
      emoji: '🏟️',
      color: AppColors.primary,
      score: _score,
      streak: _streak,
      timerWidget: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.bolt_rounded, size: 14, color: timerColor),
        Text('${_timeLeft}s', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: timerColor)),
      ]),
      difficultyBadge: _streak >= 3 ? '🔥 $_streak streak! +30 pts/correct' : 'Answer fast for bonus points!',
      onExit: widget.onExit,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          // Timer bar
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 1.0, end: _timeLeft / 5.0),
            duration: const Duration(milliseconds: 300),
            builder: (_, v, __) => ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: v.clamp(0, 1),
                backgroundColor: AppColors.border,
                valueColor: AlwaysStoppedAnimation<Color>(timerColor),
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text('Q${_index + 1}/${_questions.length} | ${q.chapter}',
              style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          // Question
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Text(q.question,
                style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, height: 1.5),
                textAlign: TextAlign.center),
          ).animate(key: ValueKey(_index)).fadeIn(duration: 200.ms),
          const SizedBox(height: 16),
          // Options
          ...q.options.asMap().entries.map((e) {
            final opt = e.value;
            Color bg = AppColors.neuSurface; Color border = AppColors.border;
            if (_answered) {
              if (e.key == q.correctIndex) { bg = const Color(0xFFDCFCE7); border = const Color(0xFF16A34A); }
              else if (_selected == opt) { bg = const Color(0xFFFFE4E4); border = const Color(0xFFDC2626); }
            } else if (_selected == opt) { bg = AppColors.primarySurface; border = AppColors.primary; }
            return GestureDetector(
              onTap: () => _selectAnswer(opt),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: bg, borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: border, width: 1.5),
                  boxShadow: AppColors.neuRaisedSoft,
                ),
                child: Text(opt, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            );
          }),
          if (_answered && _selected != null && _selected != '__timeout__') ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _selected == q.options[q.correctIndex] ? const Color(0xFFDCFCE7) : const Color(0xFFFFE4E4),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(q.explanation,
                  style: TextStyle(
                      fontSize: 11.5,
                      color: _selected == q.options[q.correctIndex]
                          ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                      height: 1.4)),
            ),
          ],
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 2. ASSERTION & REASON SHOWDOWN
// ═══════════════════════════════════════════════════════════════
class AssertionReasonGame extends StatefulWidget {
  final VoidCallback onExit;
  const AssertionReasonGame({super.key, required this.onExit});
  @override
  State<AssertionReasonGame> createState() => _AssertionReasonState();
}

class _AssertionReasonState extends State<AssertionReasonGame> {
  late List<ARQuestion> _questions;
  int _index = 0;
  int _score = 0;
  int _correct = 0;
  int _streak = 0;
  int? _selected;
  bool _submitted = false;
  bool _finished = false;

  static const _options = [
    'A) Both A & R are true, R explains A',
    'B) Both A & R are true, R does NOT explain A',
    'C) A is true, R is false',
    'D) A is false, R is true',
  ];

  @override
  void initState() { super.initState(); _questions = List.from(arQuestions)..shuffle(); }

  void _select(int i) { if (_submitted) return; setState(() => _selected = i); }

  void _submit() {
    if (_selected == null) return;
    final ok = _selected == _questions[_index].correct;
    if (ok) _streak++; else _streak = 0;
    showAnswerBurst(context, correct: ok, streak: _streak);
    if (ok) { _score += 25; _correct++; _ke2.recordAnswer(true); }
    else { _ke2.recordAnswer(false); }
    setState(() { _submitted = true; _index++; });
  }

  void _next() {
    if (_index >= _questions.length) { setState(() => _finished = true); }
    else { setState(() { _submitted = false; _selected = null; }); }
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) {
      return GameResultScreen(
        gameName: '⚖️ Assertion & Reason',
        score: _score,
        maxScore: _questions.length * 25,
        correct: _correct,
        wrong: _questions.length - _correct,
        facts: const ['Assertion & Reason questions test deep conceptual clarity — not just what, but WHY!'],
        onPlayAgain: () { _index = 0; _score = 0; _correct = 0; _submitted = false; _selected = null; _questions.shuffle(); setState(() => _finished = false); },
        onExit: widget.onExit,
      );
    }

    final q = _questions[_index < _questions.length ? _index : _questions.length - 1];

    return GameShell(
      title: 'Assertion & Reason',
      emoji: '⚖️',
      color: const Color(0xFF0891B2),
      score: _score,
      streak: _ke2.streak,
      onExit: widget.onExit,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Text('Q${_index + 1}/${_questions.length} | ${q.chapter}',
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          const SizedBox(height: 14),
          // Assertion
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0891B2).withOpacity(0.07),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF0891B2).withOpacity(0.3)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('ASSERTION (A):', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF0891B2), letterSpacing: 0.5)),
              const SizedBox(height: 6),
              Text(q.assertion, style: const TextStyle(fontSize: 13, height: 1.5, fontWeight: FontWeight.w600)),
            ]),
          ).animate(key: ValueKey('a_${_index}')).fadeIn(),
          const SizedBox(height: 10),
          // Reason
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.accentSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.accent.withOpacity(0.3)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('REASON (R):', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.accent, letterSpacing: 0.5)),
              const SizedBox(height: 6),
              Text(q.reason, style: const TextStyle(fontSize: 13, height: 1.5, fontWeight: FontWeight.w600)),
            ]),
          ).animate(key: ValueKey('r_${_index}')).fadeIn(delay: 100.ms),
          const SizedBox(height: 16),
          ..._options.asMap().entries.map((e) {
            Color bg = AppColors.neuSurface; Color border = AppColors.border;
            if (_submitted) {
              if (e.key == q.correct) { bg = const Color(0xFFDCFCE7); border = const Color(0xFF16A34A); }
              else if (_selected == e.key && e.key != q.correct) { bg = const Color(0xFFFFE4E4); border = const Color(0xFFDC2626); }
            } else if (_selected == e.key) { bg = const Color(0xFF0891B2).withOpacity(0.1); border = const Color(0xFF0891B2); }
            return GestureDetector(
              onTap: () => _select(e.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: bg, borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: border, width: _selected == e.key ? 2 : 1),
                  boxShadow: AppColors.neuRaisedSoft,
                ),
                child: Text(e.value, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
              ),
            );
          }),
          if (_submitted) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.infoSurface, borderRadius: BorderRadius.circular(12)),
              child: Text(q.explanation, style: const TextStyle(fontSize: 12, color: AppColors.info, height: 1.4)),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _next,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0891B2), foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: Text(_index >= _questions.length ? 'See Results' : 'Next Question',
                    style: const TextStyle(fontWeight: FontWeight.w800)),
              ),
            ),
          ] else if (_selected != null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0891B2), foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: const Text('Lock Answer', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
              ),
            ),
          const SizedBox(height: 30),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 3. EXCEPTION HUNTER
// ═══════════════════════════════════════════════════════════════
class ExceptionHunterGame extends StatefulWidget {
  final VoidCallback onExit;
  const ExceptionHunterGame({super.key, required this.onExit});
  @override
  State<ExceptionHunterGame> createState() => _ExceptionHunterState();
}

class _ExceptionHunterState extends State<ExceptionHunterGame> {
  late List<ExceptionItem> _items;
  int _index = 0;
  int _score = 0;
  int _correct = 0;
  int _streak = 0;
  final Set<int> _selected = {};
  bool _submitted = false;
  bool _finished = false;

  @override
  void initState() { super.initState(); _items = List.from(exceptionItems)..shuffle(); }

  void _toggle(int i) {
    if (_submitted) return;
    setState(() {
      if (_selected.contains(i)) _selected.remove(i);
      else _selected.add(i);
    });
  }

  void _submit() {
    final q = _items[_index];
    final expected = q.exceptionIndices.toSet();
    final ok = _selected.length == expected.length && _selected.every(expected.contains);
    if (ok) _streak++; else _streak = 0;
    showAnswerBurst(context, correct: ok, streak: _streak);
    if (ok) { _score += 20; _correct++; _ke2.recordAnswer(true); }
    else { _ke2.recordAnswer(false); }
    setState(() { _submitted = true; _index++; });
  }

  void _next() {
    if (_index >= _items.length) { setState(() => _finished = true); }
    else { setState(() { _submitted = false; _selected.clear(); }); }
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) {
      return GameResultScreen(
        gameName: '🔎 Exception Hunter',
        score: _score,
        maxScore: _items.length * 20,
        correct: _correct,
        wrong: _items.length - _correct,
        facts: const ['NCERT\'s exception lines often contain phrases like "with the exception of," "usually," or "generally." These are gold mines for NEET questions!'],
        onPlayAgain: () { _index = 0; _score = 0; _correct = 0; _submitted = false; _selected.clear(); _items.shuffle(); setState(() => _finished = false); },
        onExit: widget.onExit,
      );
    }

    final q = _items[_index < _items.length ? _index : _items.length - 1];

    return GameShell(
      title: 'Exception Hunter',
      emoji: '🔎',
      color: const Color(0xFFD97706),
      score: _score,
      streak: _ke2.streak,
      onExit: widget.onExit,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Text('Hunt ${_index + 1}/${_items.length} | ${q.chapter}',
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFD97706).withOpacity(0.07),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFD97706).withOpacity(0.4)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('📜 RULE:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFFD97706), letterSpacing: 0.5)),
              const SizedBox(height: 8),
              Text('"${q.rule}"', style: const TextStyle(fontSize: 14, height: 1.6, fontStyle: FontStyle.italic, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              const Text('Select ALL exceptions to this rule:',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            ]),
          ).animate(key: ValueKey('q_$_index')).fadeIn(),
          const SizedBox(height: 14),
          ...q.options.asMap().entries.map((e) {
            final isSelected = _selected.contains(e.key);
            final isException = q.exceptionIndices.contains(e.key);
            Color bg = AppColors.neuSurface; Color border = AppColors.border;
            if (_submitted) {
              if (isException) { bg = const Color(0xFFDCFCE7); border = const Color(0xFF16A34A); }
              else if (isSelected && !isException) { bg = const Color(0xFFFFE4E4); border = const Color(0xFFDC2626); }
            } else if (isSelected) { bg = const Color(0xFFD97706).withOpacity(0.1); border = const Color(0xFFD97706); }
            return GestureDetector(
              onTap: () => _toggle(e.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: bg, borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: border, width: isSelected ? 2 : 1),
                  boxShadow: AppColors.neuRaisedSoft,
                ),
                child: Row(children: [
                  Icon(isSelected ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                      color: isSelected ? const Color(0xFFD97706) : AppColors.textHint, size: 20),
                  const SizedBox(width: 10),
                  Expanded(child: Text(e.value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
                  if (_submitted && isException)
                    const Icon(Icons.error_outline_rounded, color: Color(0xFF16A34A), size: 18),
                ]),
              ),
            );
          }),
          if (_submitted) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.infoSurface, borderRadius: BorderRadius.circular(12)),
              child: Text(q.explanation, style: const TextStyle(fontSize: 12, color: AppColors.info, height: 1.4)),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _next,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD97706), foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: Text(_index >= _items.length ? 'See Results' : 'Next Hunt',
                    style: const TextStyle(fontWeight: FontWeight.w800)),
              ),
            ),
          ] else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selected.isEmpty ? null : _submit,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD97706), foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: const Text('Flag Exceptions!', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
              ),
            ),
          const SizedBox(height: 30),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 4. BIOLOGICAL COMPOUND WALL (Connections)
// ═══════════════════════════════════════════════════════════════
class CompoundWallGame extends StatefulWidget {
  final VoidCallback onExit;
  const CompoundWallGame({super.key, required this.onExit});
  @override
  State<CompoundWallGame> createState() => _CompoundWallState();
}

class _CompoundWallState extends State<CompoundWallGame> {
  late ConnectionsPuzzle _puzzle;
  late List<String> _allTerms;
  final Set<String> _selected = {};
  final List<ConnectionsGroup> _solved = [];
  int _lives = 3;
  int _score = 0;
  int _streak = 0;
  bool _finished = false;
  String? _feedback;
  int _puzzleIndex = 0;

  @override
  void initState() { super.initState(); _loadPuzzle(); }

  void _loadPuzzle() {
    _puzzle = connectionsPuzzles[_puzzleIndex % connectionsPuzzles.length];
    _allTerms = _puzzle.groups.expand((g) => g.members).toList()..shuffle();
    _selected.clear();
    _solved.clear();
    _lives = 3;
    _feedback = null;
  }

  void _toggle(String term) {
    if (_solved.any((g) => g.members.contains(term))) return;
    if (_selected.contains(term)) { setState(() => _selected.remove(term)); }
    else if (_selected.length < 4) { setState(() => _selected.add(term)); }
    else { setState(() => _feedback = 'Select exactly 4 items!'); }
  }

  void _submit() {
    if (_selected.length != 4) { setState(() => _feedback = 'Select exactly 4 items!'); return; }
    final selectedList = _selected.toList()..sort();
    ConnectionsGroup? match;
    for (final g in _puzzle.groups) {
      if (!_solved.contains(g)) {
        final members = List<String>.from(g.members)..sort();
        if (selectedList.join() == members.join()) { match = g; break; }
      }
    }
    if (match != null) {
      _solved.add(match);
      _score += 25;
      _ke2.recordAnswer(true);
      _streak++;
      showAnswerBurst(context, correct: true, streak: _streak);
      setState(() { _selected.clear(); _feedback = '✅ ${match!.theme} found!'; });
      HapticFeedback.lightImpact();
      if (_solved.length == _puzzle.groups.length) {
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) setState(() => _finished = true);
        });
      }
    } else {
      _streak = 0;
      showAnswerBurst(context, correct: false, streak: 0);
      _lives--;
      _ke2.recordAnswer(false);
      HapticFeedback.heavyImpact();
      setState(() { _feedback = '❌ Wrong group! $_lives lives left'; _selected.clear(); });
      if (_lives <= 0) { Future.delayed(const Duration(milliseconds: 500), () { if (mounted) setState(() => _finished = true); }); }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) {
      return GameResultScreen(
        gameName: '🧱 Biological Compound Wall',
        score: _score,
        maxScore: _puzzle.groups.length * 25,
        correct: _solved.length,
        wrong: _puzzle.groups.length - _solved.length,
        facts: [_puzzle.groups.first.explanation],
        onPlayAgain: () { _puzzleIndex++; _loadPuzzle(); setState(() => _finished = false); },
        onExit: widget.onExit,
      );
    }

    final unsolved = _puzzle.groups.where((g) => !_solved.contains(g)).toList();

    return GameShell(
      title: _puzzle.title,
      emoji: '🧱',
      color: const Color(0xFF7C3AED),
      score: _score,
      streak: _ke2.streak,
      difficultyBadge: '❤️ Lives: $_lives',
      onExit: widget.onExit,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(children: [
          Text(_puzzle.chapter, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          // Solved groups
          ...(_solved.map((g) => Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF16A34A).withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF16A34A)),
            ),
            child: Column(children: [
              Text(g.theme, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: Color(0xFF16A34A))),
              Text(g.members.join(', '),
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ]),
          ))),
          // Remaining terms
          Expanded(
            child: GridView.count(
              crossAxisCount: 4,
              crossAxisSpacing: 6, mainAxisSpacing: 6,
              childAspectRatio: 1.8,
              children: _allTerms.where((t) => !_solved.any((g) => g.members.contains(t))).map((term) {
                final isSelected = _selected.contains(term);
                return GestureDetector(
                  onTap: () => _toggle(term),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF7C3AED) : AppColors.neuSurface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: isSelected ? const Color(0xFF7C3AED) : AppColors.border, width: isSelected ? 2 : 1),
                      boxShadow: AppColors.neuRaisedSoft,
                    ),
                    child: Center(
                      child: Text(term,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700,
                              color: isSelected ? Colors.white : AppColors.textPrimary)),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          if (_feedback != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(_feedback!, textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700,
                      color: _feedback!.contains('✅') ? const Color(0xFF16A34A) : const Color(0xFFDC2626))),
            ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selected.length == 4 ? _submit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED), foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text('Submit (${_selected.length}/4)',
                  style: const TextStyle(fontWeight: FontWeight.w800)),
            ),
          ),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 5. JOURNEY THROUGH THE NEPHRON
// ═══════════════════════════════════════════════════════════════
class NephronJourneyGame extends StatefulWidget {
  final VoidCallback onExit;
  const NephronJourneyGame({super.key, required this.onExit});
  @override
  State<NephronJourneyGame> createState() => _NephronJourneyState();
}

class _NephronJourneyState extends State<NephronJourneyGame> {
  int _nodeIndex = 0;
  int _moleculeIndex = 0;
  int _score = 0;
  int _correct = 0;
  int _streak = 0;
  bool _answered = false;
  bool _correct_ans = false;
  bool _finished = false;
  String? _moleculeName;

  @override
  void initState() {
    super.initState();
    _moleculeIndex = 0;
    _moleculeName = nephronMolecules[_moleculeIndex];
    _nodeIndex = 0;
  }

  void _choose(int choiceIndex) {
    if (_answered) return;
    final node = nephronJourney[_nodeIndex];
    final isValid = node.validMolecules.contains(_moleculeIndex);
    _correct_ans = isValid ? choiceIndex == node.correctChoice : choiceIndex == 1;
    if (_correct_ans) _streak++; else _streak = 0;
    showAnswerBurst(context, correct: _correct_ans, streak: _streak);
    if (_correct_ans) { _score += 15; _correct++; _ke2.recordAnswer(true); }
    else { _ke2.recordAnswer(false); }
    setState(() => _answered = true);
  }

  void _next() {
    if (_nodeIndex + 1 >= nephronJourney.length) {
      // Try next molecule
      if (_moleculeIndex + 1 >= nephronMolecules.length) {
        setState(() => _finished = true);
      } else {
        setState(() {
          _moleculeIndex++;
          _moleculeName = nephronMolecules[_moleculeIndex];
          _nodeIndex = 0;
          _answered = false;
        });
      }
    } else {
      setState(() { _nodeIndex++; _answered = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) {
      return GameResultScreen(
        gameName: '🧬 Journey Through the Nephron',
        score: _score,
        maxScore: nephronJourney.length * 15,
        correct: _correct,
        wrong: nephronJourney.length - _correct,
        facts: const ['The kidneys filter 180L of blood daily but excrete only 1-1.8L of urine. 99% reabsorption!'],
        onPlayAgain: () { _nodeIndex = 0; _moleculeIndex = 0; _score = 0; _correct = 0; _answered = false; _moleculeName = nephronMolecules[0]; setState(() => _finished = false); },
        onExit: widget.onExit,
      );
    }

    final node = nephronJourney[_nodeIndex];
    final isValid = node.validMolecules.contains(_moleculeIndex);

    return GameShell(
      title: 'Journey Through the Nephron',
      emoji: '🧬',
      color: const Color(0xFF0891B2),
      score: _score,
      streak: _ke2.streak,
      difficultyBadge: 'You are: $_moleculeName',
      onExit: widget.onExit,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          // Progress
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            ...List.generate(nephronJourney.length, (i) => Container(
              width: 28, height: 6, margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: i <= _nodeIndex ? const Color(0xFF0891B2) : AppColors.border,
                borderRadius: BorderRadius.circular(3),
              ),
            )),
          ]),
          const SizedBox(height: 4),
          Text('Step ${_nodeIndex + 1}/${nephronJourney.length}: ${node.location}',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF0891B2))),
          const SizedBox(height: 14),
          // Identity card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(children: [
              Text(_moleculeName![0], style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('YOU ARE:', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white70, letterSpacing: 1)),
                Text(_moleculeName!, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white)),
                Text(isValid ? 'You CAN be filtered' : 'You CANNOT be filtered (too large)',
                    style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.8))),
              ])),
            ]),
          ),
          const SizedBox(height: 14),
          // Scenario
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0891B2).withOpacity(0.07),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF0891B2).withOpacity(0.3)),
            ),
            child: Text(node.description, style: const TextStyle(fontSize: 13, height: 1.6)),
          ).animate(key: ValueKey('$_nodeIndex')).fadeIn(),
          const SizedBox(height: 16),
          ...node.choices.asMap().entries.map((e) {
            Color bg = AppColors.neuSurface; Color border = AppColors.border;
            if (_answered) {
              final shouldBe = isValid ? (e.key == node.correctChoice) : (e.key == 1);
              if (shouldBe) { bg = const Color(0xFFDCFCE7); border = const Color(0xFF16A34A); }
            }
            return GestureDetector(
              onTap: () => _choose(e.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: bg, borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: border, width: 1.5),
                  boxShadow: AppColors.neuRaisedSoft,
                ),
                child: Text('${String.fromCharCode(65 + e.key)}) ${e.value}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, height: 1.3)),
              ),
            );
          }),
          if (_answered) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _correct_ans ? const Color(0xFFDCFCE7) : const Color(0xFFFFE4E4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(node.explanation,
                  style: TextStyle(
                      fontSize: 12,
                      color: _correct_ans ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                      height: 1.4)),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _next,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0891B2), foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(_nodeIndex + 1 >= nephronJourney.length ? 'Next Molecule →' : 'Next Step →',
                    style: const TextStyle(fontWeight: FontWeight.w800)),
              ),
            ),
          ],
          const SizedBox(height: 30),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 6. DNA REPLICATION FORK FOREMAN
// ═══════════════════════════════════════════════════════════════
class DNAReplicationGame extends StatefulWidget {
  final VoidCallback onExit;
  const DNAReplicationGame({super.key, required this.onExit});
  @override
  State<DNAReplicationGame> createState() => _DNAReplicationState();
}

class _DNAReplicationState extends State<DNAReplicationGame> {
  int _index = 0;
  int _score = 0;
  int _correct = 0;
  int _streak = 0;
  String? _selected;
  bool _submitted = false;
  bool _finished = false;

  void _select(String opt) { if (_submitted) return; setState(() => _selected = opt); }

  void _submit() {
    if (_selected == null) return;
    final ok = _selected == replicationTasks[_index].correctEnzyme;
    if (ok) _streak++; else _streak = 0;
    showAnswerBurst(context, correct: ok, streak: _streak);
    if (ok) { _score += 15; _correct++; _ke2.recordAnswer(true); }
    else { _ke2.recordAnswer(false); }
    setState(() { _submitted = true; });
  }

  void _next() {
    if (_index + 1 >= replicationTasks.length) { setState(() => _finished = true); }
    else { setState(() { _index++; _submitted = false; _selected = null; }); }
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) {
      return GameResultScreen(
        gameName: '🧬 DNA Replication Foreman',
        score: _score,
        maxScore: replicationTasks.length * 15,
        correct: _correct,
        wrong: replicationTasks.length - _correct,
        facts: const ['DNA replication in E. coli takes ~40 minutes and copies 4.6 million base pairs at ~1000 bp/sec per replication fork!'],
        onPlayAgain: () { _index = 0; _score = 0; _correct = 0; _submitted = false; _selected = null; setState(() => _finished = false); },
        onExit: widget.onExit,
      );
    }

    final task = replicationTasks[_index];

    return GameShell(
      title: 'DNA Replication Foreman',
      emoji: '🏗️',
      color: const Color(0xFF16A34A),
      score: _score,
      streak: _ke2.streak,
      onExit: widget.onExit,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          // Progress
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            ...List.generate(replicationTasks.length, (i) => Expanded(
              child: Container(
                height: 5, margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: i < _index ? AppColors.success : i == _index ? const Color(0xFF16A34A) : AppColors.border,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            )),
          ]),
          const SizedBox(height: 14),
          // Task
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF16A34A).withOpacity(0.07),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF16A34A).withOpacity(0.3)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: const Color(0xFF16A34A), borderRadius: BorderRadius.circular(8)),
                  child: Text('STEP ${_index + 1}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900)),
                ),
                const SizedBox(width: 8),
                Text(task.chapter, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
              ]),
              const SizedBox(height: 10),
              Text(task.task, style: const TextStyle(fontSize: 14, height: 1.6, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              const Text('Which enzyme do you deploy?',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
            ]),
          ).animate(key: ValueKey(_index)).fadeIn(),
          const SizedBox(height: 16),
          ...task.options.map((opt) {
            Color bg = AppColors.neuSurface; Color border = AppColors.border;
            if (_submitted) {
              if (opt == task.correctEnzyme) { bg = const Color(0xFFDCFCE7); border = const Color(0xFF16A34A); }
              else if (_selected == opt && opt != task.correctEnzyme) { bg = const Color(0xFFFFE4E4); border = const Color(0xFFDC2626); }
            } else if (_selected == opt) { bg = const Color(0xFF16A34A).withOpacity(0.1); border = const Color(0xFF16A34A); }
            return GestureDetector(
              onTap: () => _select(opt),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: bg, borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: border, width: _selected == opt ? 2 : 1),
                  boxShadow: AppColors.neuRaisedSoft,
                ),
                child: Row(children: [
                  Icon(_selected == opt ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                      color: _selected == opt ? const Color(0xFF16A34A) : AppColors.textHint, size: 20),
                  const SizedBox(width: 10),
                  Expanded(child: Text(opt, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
                ]),
              ),
            );
          }),
          if (_submitted) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.infoSurface, borderRadius: BorderRadius.circular(12)),
              child: Text(task.explanation, style: const TextStyle(fontSize: 12, color: AppColors.info, height: 1.4)),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _next,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A), foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(_index + 1 >= replicationTasks.length ? 'See Results' : 'Next Step',
                    style: const TextStyle(fontWeight: FontWeight.w800)),
              ),
            ),
          ] else if (_selected != null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A), foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Deploy Enzyme!', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
              ),
            ),
          const SizedBox(height: 30),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 7. SPELL CHECKER OF DOOM (Scientific Names)
// ═══════════════════════════════════════════════════════════════
class SpellCheckerGame extends StatefulWidget {
  final VoidCallback onExit;
  const SpellCheckerGame({super.key, required this.onExit});
  @override
  State<SpellCheckerGame> createState() => _SpellCheckerState();
}

class _SpellCheckerState extends State<SpellCheckerGame> {
  late List<SpellItem> _items;
  int _index = 0;
  int _score = 0;
  int _correct = 0;
  int _streak = 0;
  final _ctrl = TextEditingController();
  bool _submitted = false;
  bool _correct_ans = false;
  bool _finished = false;

  @override
  void initState() { super.initState(); _items = List.from(spellItems)..shuffle(); }

  void _submit() {
    if (_ctrl.text.trim().isEmpty) return;
    final ans = _ctrl.text.trim();
    final expected = _items[_index].answer;
    _correct_ans = ans == expected || ans.toLowerCase() == expected.toLowerCase();
    if (_correct_ans) _streak++; else _streak = 0;
    showAnswerBurst(context, correct: _correct_ans, streak: _streak);
    if (_correct_ans) {
      // Strict: check case of first letter
      final genusCorrect = ans[0] == expected[0];
      _score += genusCorrect ? 20 : 10;
      _correct++;
      _ke2.recordAnswer(true);
    } else {
      _ke2.recordAnswer(false);
    }
    setState(() { _submitted = true; _index++; });
  }

  void _next() {
    if (_index >= _items.length) { setState(() => _finished = true); }
    else { _ctrl.clear(); setState(() => _submitted = false); }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    if (_finished) {
      return GameResultScreen(
        gameName: '🔤 Spell Checker of Doom',
        score: _score,
        maxScore: _items.length * 20,
        correct: _correct,
        wrong: _items.length - _correct,
        facts: const ['In binomial nomenclature (Linnaeus, 1758): Genus is capitalised, species is lowercase. Both are italicised or underlined in print.'],
        onPlayAgain: () { _index = 0; _score = 0; _correct = 0; _submitted = false; _ctrl.clear(); _items.shuffle(); setState(() => _finished = false); },
        onExit: widget.onExit,
      );
    }

    final item = _items[_index < _items.length ? _index : _items.length - 1];

    return GameShell(
      title: 'Spell Checker of Doom',
      emoji: '🔤',
      color: const Color(0xFF7C3AED),
      score: _score,
      streak: _ke2.streak,
      difficultyBadge: 'Genus CAPITALISED, species lowercase',
      onExit: widget.onExit,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Text('${_index + 1}/${_items.length} | ${item.chapter}',
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF7C3AED).withOpacity(0.07),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF7C3AED).withOpacity(0.3)),
            ),
            child: Column(children: [
              const Text('IDENTIFY & SPELL:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF7C3AED), letterSpacing: 0.5)),
              const SizedBox(height: 12),
              Text(item.hint, textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, height: 1.5)),
            ]),
          ).animate(key: ValueKey(_index)).fadeIn(),
          const SizedBox(height: 24),
          TextField(
            controller: _ctrl,
            enabled: !_submitted,
            textCapitalization: TextCapitalization.sentences,
            style: const TextStyle(fontSize: 15, fontStyle: FontStyle.italic, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              labelText: 'Type the binomial scientific name',
              hintText: 'e.g. Homo sapiens',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              filled: true,
              fillColor: AppColors.neuSurface,
              prefixIcon: const Icon(Icons.edit_note_rounded, size: 20, color: Color(0xFF7C3AED)),
            ),
            onSubmitted: (_) => _submit(),
          ),
          if (_submitted) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _correct_ans ? const Color(0xFFDCFCE7) : const Color(0xFFFFE4E4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(children: [
                Text(_correct_ans ? '✅ Perfectly spelled!' : '❌ The correct spelling is:',
                    style: TextStyle(fontWeight: FontWeight.w800, color: _correct_ans ? const Color(0xFF16A34A) : const Color(0xFFDC2626))),
                if (!_correct_ans) ...[
                  const SizedBox(height: 6),
                  Text(item.answer,
                      style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic, fontWeight: FontWeight.w900, color: Color(0xFF16A34A))),
                  const SizedBox(height: 4),
                  Text('You wrote: "${_ctrl.text.trim()}"',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ]),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _next,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED), foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(_index >= _items.length ? 'See Results' : 'Next Organism',
                    style: const TextStyle(fontWeight: FontWeight.w800)),
              ),
            ),
          ] else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED), foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Check Spelling!', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
              ),
            ),
          const SizedBox(height: 30),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 8. BIOLOGICAL CALENDAR
// ═══════════════════════════════════════════════════════════════
class BiologicalCalendarGame extends StatefulWidget {
  final VoidCallback onExit;
  const BiologicalCalendarGame({super.key, required this.onExit});
  @override
  State<BiologicalCalendarGame> createState() => _BiologicalCalendarState();
}

class _BiologicalCalendarState extends State<BiologicalCalendarGame> {
  late List<CalendarEvent> _events;
  int _index = 0;
  int _score = 0;
  int _correct = 0;
  int _streak = 0;
  final _ctrl = TextEditingController();
  bool _submitted = false;
  bool _correct_ans = false;
  bool _finished = false;

  @override
  void initState() { super.initState(); _events = List.from(calendarEvents)..shuffle(); }

  void _submit() {
    if (_ctrl.text.trim().isEmpty) return;
    final ans = _ctrl.text.trim();
    final expected = _events[_index].year;
    _correct_ans = ans == expected;
    if (_correct_ans) _streak++; else _streak = 0;
    showAnswerBurst(context, correct: _correct_ans, streak: _streak);
    if (_correct_ans) { _score += 20; _correct++; _ke2.recordAnswer(true); }
    else { _ke2.recordAnswer(false); }
    setState(() { _submitted = true; _index++; });
  }

  void _next() {
    if (_index >= _events.length) { setState(() => _finished = true); }
    else { _ctrl.clear(); setState(() => _submitted = false); }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    if (_finished) {
      return GameResultScreen(
        gameName: '📅 Biological Calendar',
        score: _score,
        maxScore: _events.length * 20,
        correct: _correct,
        wrong: _events.length - _correct,
        facts: const ['History of biology is a NEET topic. Key years: 1665 (Hooke), 1676 (Leeuwenhoek), 1859 (Darwin), 1953 (Watson-Crick), 1982 (Humulin).'],
        onPlayAgain: () { _index = 0; _score = 0; _correct = 0; _submitted = false; _ctrl.clear(); _events.shuffle(); setState(() => _finished = false); },
        onExit: widget.onExit,
      );
    }

    final event = _events[_index < _events.length ? _index : _events.length - 1];

    return GameShell(
      title: 'Biological Calendar',
      emoji: '📅',
      color: const Color(0xFFD97706),
      score: _score,
      streak: _ke2.streak,
      onExit: widget.onExit,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Text('Event ${_index + 1}/${_events.length} | ${event.chapter}',
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFD97706).withOpacity(0.07),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFD97706).withOpacity(0.4)),
            ),
            child: Column(children: [
              const Text('🗓️ WHEN DID THIS HAPPEN?', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFFD97706), letterSpacing: 0.5)),
              const SizedBox(height: 12),
              Text(event.event, textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, height: 1.6, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppColors.accentSurface, borderRadius: BorderRadius.circular(8)),
                child: Text('💡 ${event.hint}',
                    style: const TextStyle(fontSize: 11, color: AppColors.accent, height: 1.4)),
              ),
            ]),
          ).animate(key: ValueKey(_index)).fadeIn(),
          const SizedBox(height: 20),
          TextField(
            controller: _ctrl,
            keyboardType: TextInputType.number,
            enabled: !_submitted,
            decoration: InputDecoration(
              labelText: 'Enter the year',
              hintText: 'e.g. 1859, 1953',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: AppColors.neuSurface,
              prefixIcon: const Icon(Icons.calendar_today_rounded, size: 18),
            ),
            onSubmitted: (_) => _submit(),
          ),
          if (_submitted) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _correct_ans ? const Color(0xFFDCFCE7) : const Color(0xFFFFE4E4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(children: [
                Text(_correct_ans ? '✅ Correct Year: ${event.year}!' : '❌ The year was: ${event.year}',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15,
                        color: _correct_ans ? const Color(0xFF16A34A) : const Color(0xFFDC2626))),
              ]),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _next,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD97706), foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: Text(_index >= _events.length ? 'See Results' : 'Next Event',
                    style: const TextStyle(fontWeight: FontWeight.w800)),
              ),
            ),
          ] else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD97706), foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: const Text('Pin the Year!', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
              ),
            ),
          const SizedBox(height: 30),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 9. TRIPLE TAXONOMY MATCH
// ═══════════════════════════════════════════════════════════════
class TaxonomyMatchGame extends StatefulWidget {
  final VoidCallback onExit;
  const TaxonomyMatchGame({super.key, required this.onExit});
  @override
  State<TaxonomyMatchGame> createState() => _TaxonomyMatchState();
}

class _TaxonomyMatchState extends State<TaxonomyMatchGame> {
  late List<TaxonomyTriple> _triples;
  final Map<String, String?> _colB = {};  // commonName → scientificName
  final Map<String, String?> _colC = {};  // commonName → uniqueFeature
  String? _selectedA;
  String? _selectedB;
  String? _selectedC;
  final Set<String> _solved = {};
  int _score = 0;
  bool _finished = false;
  int _mistakes = 0;
  int _streak = 0;

  @override
  void initState() {
    super.initState();
    _triples = List.from(taxonomyTriples)..shuffle();
    if (_triples.length > 6) _triples = _triples.take(6).toList();
  }

  void _tryMatch() {
    if (_selectedA == null || _selectedB == null || _selectedC == null) return;
    final triple = _triples.firstWhere((t) => t.commonName == _selectedA, orElse: () => _triples.first);
    if (triple.scientificName == _selectedB && triple.uniqueFeature == _selectedC) {
      _solved.add(_selectedA!);
      _score += 20;
      _ke2.recordAnswer(true);
      _streak++;
      showAnswerBurst(context, correct: true, streak: _streak);
      HapticFeedback.lightImpact();
    } else {
      _streak = 0;
      showAnswerBurst(context, correct: false, streak: 0);
      _mistakes++;
      _ke2.recordAnswer(false);
      HapticFeedback.heavyImpact();
    }
    setState(() { _selectedA = null; _selectedB = null; _selectedC = null; });
    if (_solved.length == _triples.length) {
      Future.delayed(const Duration(milliseconds: 500), () => setState(() => _finished = true));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) {
      return GameResultScreen(
        gameName: '🔗 Triple Taxonomy Match',
        score: _score,
        maxScore: _triples.length * 20,
        correct: _solved.length,
        wrong: _mistakes,
        facts: const ['Animal Kingdom is the most example-heavy chapter in NCERT. Know phylum for each example organism!'],
        onPlayAgain: () { _solved.clear(); _score = 0; _mistakes = 0; _selectedA = null; _selectedB = null; _selectedC = null; _triples.shuffle(); setState(() => _finished = false); },
        onExit: widget.onExit,
      );
    }

    final unsolved = _triples.where((t) => !_solved.contains(t.commonName)).toList();
    final bOptions = unsolved.map((t) => t.scientificName).toList()..shuffle();
    final cOptions = unsolved.map((t) => t.uniqueFeature).toList()..shuffle();

    return GameShell(
      title: 'Triple Taxonomy Match',
      emoji: '🔗',
      color: const Color(0xFF16A34A),
      score: _score,
      streak: _ke2.streak,
      difficultyBadge: 'Tap A → B → C to match',
      onExit: widget.onExit,
      child: Column(children: [
        Container(
          padding: const EdgeInsets.all(10),
          color: AppColors.infoSurface,
          child: const Text('Tap: Common Name → Scientific Name → Unique Feature',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: AppColors.info)),
        ),
        Expanded(
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Column A
            Expanded(child: _buildColumn('Common Name', unsolved.map((t) => t.commonName).toList(), _selectedA, (v) => setState(() => _selectedA = v), const Color(0xFF0891B2))),
            // Column B
            Expanded(child: _buildColumn('Scientific Name', bOptions, _selectedB, (v) => setState(() => _selectedB = v), const Color(0xFF7C3AED))),
            // Column C
            Expanded(child: _buildColumn('Unique Feature', cOptions, _selectedC, (v) => setState(() => _selectedC = v), const Color(0xFF16A34A))),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (_selectedA != null && _selectedB != null && _selectedC != null) ? _tryMatch : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A), foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text('Match! (${_solved.length}/${_triples.length} solved)',
                  style: const TextStyle(fontWeight: FontWeight.w800)),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildColumn(String header, List<String> items, String? selected, ValueChanged<String?> onSelect, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8),
          color: color.withOpacity(0.1),
          child: Text(header, textAlign: TextAlign.center,
              style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: color)),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 6),
            children: items.map((item) => GestureDetector(
              onTap: () => onSelect(selected == item ? null : item),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.only(bottom: 4),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: selected == item ? color.withOpacity(0.15) : AppColors.neuSurface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: selected == item ? color : AppColors.border,
                      width: selected == item ? 2 : 1),
                  boxShadow: AppColors.neuRaisedSoft,
                ),
                child: Text(item, textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 9, fontWeight: selected == item ? FontWeight.w800 : FontWeight.w500,
                        color: selected == item ? color : AppColors.textPrimary)),
              ),
            )).toList(),
          ),
        ),
      ]),
    );
  }
}
