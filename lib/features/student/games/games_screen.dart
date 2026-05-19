import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/ncert_chapters.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/glass_card.dart';
import 'new_games.dart';
import 'new_games_2.dart';
import 'game_effects.dart';
import 'game_engine_widgets.dart' show showAnswerBurst;

// ─── Entry screen ────────────────────────────────────────────
class GamesScreen extends StatefulWidget {
  const GamesScreen({super.key});

  @override
  State<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen> {
  _Game? _activeGame;
  String _search = '';

  @override
  Widget build(BuildContext context) {
    if (_activeGame != null) {
      return _activeGame!.widget(context, () => setState(() => _activeGame = null));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Game Zone',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                  Text('Powered by the Knowledge Engine — every session is unique!',
                      style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary, height: 1.4)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('${_gamesList.length} Games',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12)),
            ),
          ]),
          const SizedBox(height: 12),

          // Search bar
          TextField(
            onChanged: (v) => setState(() => _search = v),
            decoration: InputDecoration(
              hintText: 'Search ${_gamesList.length} games…',
              hintStyle: const TextStyle(fontSize: 13),
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              suffixIcon: _search.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18),
                      onPressed: () => setState(() => _search = ''),
                    )
                  : null,
              filled: true,
              fillColor: AppColors.neuSurface,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Categories (filtered by search)
          ..._allCategories.asMap().entries.map((catEntry) {
            final cat = catEntry.value;
            final games = _search.isEmpty
                ? cat.games
                : cat.games
                    .where((g) => g.name.toLowerCase().contains(_search.toLowerCase()))
                    .toList();
            if (games.isEmpty) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Styled category header
                Padding(
                  padding: EdgeInsets.only(bottom: 10, top: catEntry.key > 0 ? 20 : 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.08),
                          AppColors.accent.withOpacity(0.04),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.primary.withOpacity(0.12)),
                    ),
                    child: Row(children: [
                      Text(cat.emoji, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(cat.name,
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(6)),
                        child: Text('${games.length}',
                            style: const TextStyle(
                                fontSize: 10, fontWeight: FontWeight.w800,
                                color: Colors.white)),
                      ),
                    ]),
                  ),
                ),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 220,
                    childAspectRatio: 1.3,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                  ),
                  itemCount: games.length,
                  itemBuilder: (_, i) {
                    final g = games[i];
                    final globalIdx = _gamesList.indexOf(g);
                    return _GameCard(
                      game: g,
                      onPlay: () => setState(() => _activeGame = g),
                    ).animate(delay: (globalIdx * 40).ms)
                        .fadeIn(duration: 250.ms)
                        .scale(begin: const Offset(0.88, 0.88), curve: Curves.easeOut);
                  },
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

// Flashcard-style compact game tile
class _GameCard extends StatefulWidget {
  final _Game game;
  final VoidCallback onPlay;
  const _GameCard({required this.game, required this.onPlay});
  @override
  State<_GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<_GameCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2200))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPlay,
      child: SolidCard(
        padding: EdgeInsets.zero,
        child: Column(children: [
          // Animated gradient top
          Expanded(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(18)),
              child: Stack(children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        widget.game.color.withOpacity(0.22),
                        widget.game.color.withOpacity(0.06),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                // Pulsing glow
                Center(
                  child: AnimatedBuilder(
                    animation: _pulse,
                    builder: (_, __) => Container(
                      width: 42 + _pulse.value * 10,
                      height: 42 + _pulse.value * 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.game.color
                            .withOpacity(0.10 + _pulse.value * 0.08),
                      ),
                    ),
                  ),
                ),
                // Floating emoji
                Center(
                  child: AnimatedBuilder(
                    animation: _pulse,
                    builder: (_, __) => Transform.translate(
                      offset: Offset(0, -1.5 + _pulse.value * 3),
                      child: Text(widget.game.emoji,
                          style: const TextStyle(fontSize: 30)),
                    ),
                  ),
                ),
                // Badge
                if (widget.game.badge.isNotEmpty)
                  Positioned(
                    top: 6, right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: widget.game.badge.contains('New')
                            ? AppColors.error
                            : AppColors.neuSurface,
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: AppColors.neuRaisedSoft,
                      ),
                      child: Text(
                        widget.game.badge.contains('New') ? 'NEW' : 'CLASSIC',
                        style: TextStyle(
                            fontSize: 7,
                            fontWeight: FontWeight.w900,
                            color: widget.game.badge.contains('New')
                                ? Colors.white
                                : AppColors.textSecondary,
                            letterSpacing: 0.3),
                      ),
                    ),
                  ),
              ]),
            ),
          ),
          // Info
          Padding(
            padding: const EdgeInsets.fromLTRB(9, 7, 9, 9),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Text(widget.game.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                      color: AppColors.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text(widget.game.description,
                  style: const TextStyle(
                      fontSize: 9,
                      color: AppColors.textSecondary,
                      height: 1.3),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ]),
          ),
        ]),
      ),
    );
  }
}

// ─── Game definitions ─────────────────────────────────────────
class _Game {
  final String name, description, emoji;
  final Color color;
  final String badge;
  final Widget Function(BuildContext, VoidCallback) widget;

  const _Game({
    required this.name,
    required this.description,
    required this.emoji,
    required this.color,
    required this.widget,
    this.badge = '',
  });
}

// ── Category label ────────────────────────────────────────────
class _GameCategory {
  final String name;
  final String emoji;
  final List<_Game> games;
  const _GameCategory(this.name, this.emoji, this.games);
}

final _allCategories = [
  _GameCategory('Classic Arcade', '🎮', [
    _Game(name: 'Quiz Blitz', description: 'Rapid-fire biology questions. Beat the clock!', emoji: '⚡', color: AppColors.primary, badge: '🏅 Classic', widget: (_, e) => _QuizBlitz(onExit: e)),
    _Game(name: 'Match Master', description: 'Flip cards to find matching biology pairs!', emoji: '🃏', color: AppColors.success, badge: '🏅 Classic', widget: (_, e) => _MatchMaster(onExit: e)),
    _Game(name: 'True or False', description: 'How fast can you classify NCERT facts?', emoji: '🎯', color: AppColors.accent, badge: '🏅 Classic', widget: (_, e) => _TrueOrFalse(onExit: e)),
    _Game(name: 'Spell It!', description: 'Unscramble the biology term before time runs out.', emoji: '🔤', color: AppColors.info, badge: '🏅 Classic', widget: (_, e) => _SpellIt(onExit: e)),
  ]),
  _GameCategory('Mystery & Deduction', '🔍', [
    _Game(name: 'Diagnosis Chamber', description: 'Read patient symptoms and diagnose the deficiency disease!', emoji: '🔬', color: const Color(0xFF16A34A), badge: '🆕 New', widget: (_, e) => DiagnosisChamberGame(onExit: e)),
    _Game(name: 'Who Am I?', description: 'Guess the biological entity from progressive NCERT clues.', emoji: '🧩', color: AppColors.primary, badge: '🆕 New', widget: (_, e) => WhoAmIGame(onExit: e)),
    _Game(name: 'Assassin Protein', description: 'A molecular whodunit — find the faulty molecule stopping a process!', emoji: '🔪', color: const Color(0xFF7C3AED), badge: '🆕 New', widget: (_, e) => AssassinProteinGame(onExit: e)),
    _Game(name: "What's Wrong?", description: 'Spot the error hidden in NCERT-style statements.', emoji: '❌', color: const Color(0xFFDC2626), badge: '🆕 New', widget: (_, e) => WhatsWrongGame(onExit: e)),
  ]),
  _GameCategory('Rapid-Fire Classification', '⚡', [
    _Game(name: 'Binary Blitz', description: 'Hormone or Enzyme? Classify 15 molecules faster than light!', emoji: '⚡', color: AppColors.accent, badge: '🆕 New', widget: (_, e) => BinaryBlitzGame(onExit: e)),
    _Game(name: 'Garbage Collector', description: 'Sort urea, uric acid & ammonia to the correct organism!', emoji: '♻️', color: const Color(0xFF16A34A), badge: '🆕 New', widget: (_, e) => GarbageCollectorGame(onExit: e)),
    _Game(name: 'Invader: Abiotic', description: 'Choose the right immune defence for each biological threat!', emoji: '🛡️', color: const Color(0xFF7C3AED), badge: '🆕 New', widget: (_, e) => InvaderAbioticGame(onExit: e)),
  ]),
  _GameCategory('Ordering & Sequencing', '📊', [
    _Game(name: 'Descending Order', description: 'Arrange taxonomic ranks, trophic levels & more in correct order!', emoji: '📊', color: const Color(0xFF7C3AED), badge: '🆕 New', widget: (_, e) => DescendingOrderGame(onExit: e)),
  ]),
  _GameCategory('Genetics Lab', '🧬', [
    _Game(name: 'Punnett Square Pro', description: 'Solve Mendelian crosses — monohybrid to dihybrid!', emoji: '🧬', color: const Color(0xFF0891B2), badge: '🆕 New', widget: (_, e) => PunnettSquareGame(onExit: e)),
    _Game(name: 'Ploidy Patrol', description: 'Track chromosome ploidy through life cycles of plants & animals!', emoji: '🔢', color: const Color(0xFF16A34A), badge: '🆕 New', widget: (_, e) => PloidyPatrolGame(onExit: e)),
  ]),
  _GameCategory('Vocabulary & Etymology', '📖', [
    _Game(name: 'Root Word Botany', description: 'Decode scientific terms by their Greek & Latin roots.', emoji: '🌿', color: const Color(0xFF16A34A), badge: '🆕 New', widget: (_, e) => RootWordBotanyGame(onExit: e)),
    _Game(name: 'Biology Antakshari', description: 'Chain NCERT biology terms — last letter becomes first!', emoji: '🎵', color: const Color(0xFFD97706), badge: '🆕 New', widget: (_, e) => AntakshariGame(onExit: e)),
    _Game(name: 'Spell Checker of Doom', description: 'Type the exact binomial scientific name — case matters!', emoji: '🔤', color: const Color(0xFF7C3AED), badge: '🆕 New', widget: (_, e) => SpellCheckerGame(onExit: e)),
  ]),
  _GameCategory('Speed & Competitive', '🏟️', [
    _Game(name: 'NEET Rapid Fire Arena', description: '5 seconds per question — answer fast for bonus points!', emoji: '🏟️', color: AppColors.primary, badge: '🆕 New', widget: (_, e) => NeetRapidFireGame(onExit: e)),
    _Game(name: 'Assertion & Reason', description: 'Master NEET\'s most challenging question type — A&R!', emoji: '⚖️', color: const Color(0xFF0891B2), badge: '🆕 New', widget: (_, e) => AssertionReasonGame(onExit: e)),
    _Game(name: 'Exception Hunter', description: 'Biology rules have exceptions — find them all!', emoji: '🔎', color: const Color(0xFFD97706), badge: '🆕 New', widget: (_, e) => ExceptionHunterGame(onExit: e)),
    _Game(name: 'Biological Compound Wall', description: 'Group 16 biology terms into 4 hidden categories!', emoji: '🧱', color: const Color(0xFF7C3AED), badge: '🆕 New', widget: (_, e) => CompoundWallGame(onExit: e)),
  ]),
  _GameCategory('🎨 Animation Games', '🎮', [
    _Game(name: 'Synapse Shooter', description: 'Identify neurotransmitters flying across an animated synapse before they reach the receptor!', emoji: '🧠', color: const Color(0xFF6C63FF), badge: '🎨 Animated', widget: (_, e) => SynapseShooterGame(onExit: e)),
    _Game(name: 'Cell Division', description: 'Watch a real animated cell divide — identify which phase you\'re seeing!', emoji: '🔬', color: const Color(0xFF4FC3F7), badge: '🎨 Animated', widget: (_, e) => CellDivisionGame(onExit: e)),
  ]),
  _GameCategory('Narrative Adventure', '🗺️', [
    _Game(name: 'Journey Through the Nephron', description: 'You ARE a molecule. Navigate urine formation!', emoji: '🧬', color: const Color(0xFF0891B2), badge: '🆕 New', widget: (_, e) => NephronJourneyGame(onExit: e)),
    _Game(name: 'Triple Taxonomy Match', description: 'Match common name, scientific name & unique feature!', emoji: '🔗', color: const Color(0xFF16A34A), badge: '🆕 New', widget: (_, e) => TaxonomyMatchGame(onExit: e)),
    _Game(name: 'DNA Replication Foreman', description: 'Deploy the right enzyme for each replication step!', emoji: '🏗️', color: const Color(0xFF16A34A), badge: '🆕 New', widget: (_, e) => DNAReplicationGame(onExit: e)),
    _Game(name: 'Biological Calendar', description: 'Pin biology\'s landmark discoveries on the timeline!', emoji: '📅', color: const Color(0xFFD97706), badge: '🆕 New', widget: (_, e) => BiologicalCalendarGame(onExit: e)),
  ]),
];

// Flat list for grid view
final _gamesList = _allCategories.expand((c) => c.games).toList();

// ─────────────────────────────────────────────
// QUIZ BLITZ
// ─────────────────────────────────────────────
class _QuizBlitz extends StatefulWidget {
  final VoidCallback onExit;
  const _QuizBlitz({required this.onExit});

  @override
  State<_QuizBlitz> createState() => _QuizBlitzState();
}

class _QuizBlitzState extends State<_QuizBlitz> {
  int _score = 0, _qIndex = 0, _timeLeft = 15, _streak = 0;
  String? _selected, _feedback;
  Timer? _timer;
  bool _gameOver = false;
  late final List<_QuizQ> _questions;

  @override
  void initState() {
    super.initState();
    // Shuffle the options of every question so the correct answer
    // isn't always in the same position (was always last = "D").
    _questions = _quizQuestions.map((q) {
      final opts = List<String>.from(q.options)..shuffle();
      return _QuizQ(q.question, q.correct, opts);
    }).toList()
      ..shuffle();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timeLeft = 15;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_timeLeft <= 0) { t.cancel(); _timeUp(); }
      else setState(() => _timeLeft--);
    });
  }

  void _timeUp() {
    if (_gameOver) return;
    setState(() => _feedback = 'Time up! Answer: ${_questions[_qIndex].correct}');
    Future.delayed(1.5.seconds, _next);
  }

  void _answer(String opt) {
    if (_selected != null) return;
    _timer?.cancel();
    final correct = opt == _questions[_qIndex].correct;
    if (correct) _streak++; else _streak = 0;
    setState(() {
      _selected = opt;
      _feedback = correct ? '✅ Correct! +10' : '❌ Wrong';
      if (correct) _score += 10 + _timeLeft;
    });
    showAnswerBurst(context, correct: correct, streak: _streak);
    Future.delayed(1.2.seconds, _next);
  }

  void _next() {
    if (_qIndex + 1 >= _questions.length) {
      setState(() => _gameOver = true);
    } else {
      setState(() { _qIndex++; _selected = null; _feedback = null; });
      _startTimer();
    }
  }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    if (_gameOver) return _GameOverScreen(score: _score, maxScore: _questions.length * 25, onExit: widget.onExit, onReplay: () { setState(() { _score = 0; _qIndex = 0; _streak = 0; _gameOver = false; _selected = null; _feedback = null; _questions.shuffle(); for (final q in _questions) { q.options.shuffle(); } }); _startTimer(); });

    final q = _questions[_qIndex];
    return Scaffold(
      backgroundColor: AppColors.neuBackground,
      appBar: AppBar(title: const Text('Quiz Blitz ⚡'), leading: IconButton(icon: const Icon(Icons.close), onPressed: widget.onExit)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(children: [
              Expanded(child: LinearProgressIndicator(value: _timeLeft / 15, color: _timeLeft > 5 ? AppColors.primary : AppColors.error, backgroundColor: AppColors.border, minHeight: 8)),
              const SizedBox(width: 12),
              Text('${_timeLeft}s', style: TextStyle(fontWeight: FontWeight.w800, color: _timeLeft > 5 ? AppColors.primary : AppColors.error)),
              const SizedBox(width: 16),
              Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(8)), child: Text('$_score pts', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800))),
            ]),
            const SizedBox(height: 8),
            Text('Q ${_qIndex + 1} / ${_questions.length}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 20),
            SolidCard(child: Text(q.question, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, height: 1.5))),
            const SizedBox(height: 16),
            ...q.options.map((opt) {
              Color bg = AppColors.neuSurface;
              Color border = AppColors.border;
              if (_selected != null) {
                if (opt == q.correct) { bg = AppColors.successSurface; border = AppColors.success; }
                else if (opt == _selected) { bg = AppColors.errorSurface; border = AppColors.error; }
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GestureDetector(
                  onTap: () => _answer(opt),
                  child: AnimatedContainer(
                    duration: 200.ms,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: border)),
                    child: Text(opt, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  ),
                ),
              );
            }),
            if (_feedback != null) Text(_feedback!, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: _feedback!.startsWith('✅') ? AppColors.success : AppColors.error)).animate().shake(),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// MATCH MASTER
// ─────────────────────────────────────────────
class _MatchMaster extends StatefulWidget {
  final VoidCallback onExit;
  const _MatchMaster({required this.onExit});

  @override
  State<_MatchMaster> createState() => _MatchMasterState();
}

class _MatchMasterState extends State<_MatchMaster> {
  late List<_Card> _cards;
  int? _first, _second;
  int _matches = 0, _attempts = 0, _streak = 0;

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() {
    final pairs = _matchPairs.take(8).toList();
    _cards = [...pairs.map((p) => _Card(p.term, true, p.term)), ...pairs.map((p) => _Card(p.def, false, p.term))]..shuffle();
    _matches = 0; _attempts = 0; _first = null; _second = null;
  }

  void _flip(int i) {
    if (_cards[i].revealed || _cards[i].matched) return;
    if (_second != null) return;

    setState(() => _cards[i] = _cards[i].copyWith(revealed: true));

    if (_first == null) {
      _first = i;
    } else {
      _second = i;
      _attempts++;
      if (_cards[_first!].pairId == _cards[_second!].pairId) {
        setState(() {
          _cards[_first!] = _cards[_first!].copyWith(matched: true);
          _cards[_second!] = _cards[_second!].copyWith(matched: true);
          _matches++;
          _first = null; _second = null;
        });
        showAnswerBurst(context, correct: true, streak: ++_streak);
      } else {
        showAnswerBurst(context, correct: false, streak: 0); _streak = 0;
        Future.delayed(1.seconds, () {
          if (!mounted) return;
          setState(() {
            _cards[_first!] = _cards[_first!].copyWith(revealed: false);
            _cards[_second!] = _cards[_second!].copyWith(revealed: false);
            _first = null; _second = null;
          });
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final done = _matches == 8;
    return Scaffold(
      backgroundColor: AppColors.neuBackground,
      appBar: AppBar(title: const Text('Match Master 🃏'), leading: IconButton(icon: const Icon(Icons.close), onPressed: widget.onExit)),
      body: done
          ? _GameOverScreen(score: max(0, 1000 - _attempts * 40), maxScore: 1000, onExit: widget.onExit, onReplay: () { setState(_init); })
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('Matches: $_matches/8', style: const TextStyle(fontWeight: FontWeight.w700)),
                    Text('Attempts: $_attempts', style: const TextStyle(color: AppColors.textSecondary)),
                  ]),
                  const SizedBox(height: 16),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 0.9),
                      itemCount: _cards.length,
                      itemBuilder: (_, i) {
                        final c = _cards[i];
                        return GestureDetector(
                          onTap: () => _flip(i),
                          child: AnimatedContainer(
                            duration: 300.ms,
                            decoration: BoxDecoration(
                              color: c.matched ? AppColors.successSurface : c.revealed ? AppColors.primarySurface : AppColors.primary,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: c.matched ? AppColors.success : c.revealed ? AppColors.primary : AppColors.primaryDark),
                            ),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: Text(
                                  c.revealed || c.matched ? c.text : '?',
                                  style: TextStyle(
                                    fontSize: c.revealed || c.matched ? 10 : 20,
                                    fontWeight: FontWeight.w700,
                                    color: c.revealed || c.matched ? AppColors.textPrimary : Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

// ─────────────────────────────────────────────
// TRUE OR FALSE
// ─────────────────────────────────────────────
class _TrueOrFalse extends StatefulWidget {
  final VoidCallback onExit;
  const _TrueOrFalse({required this.onExit});

  @override
  State<_TrueOrFalse> createState() => _TrueOrFalseState();
}

class _TrueOrFalseState extends State<_TrueOrFalse> {
  int _score = 0, _idx = 0, _streak = 0;
  final List<_TFQ> _qs = List.from(_tfQuestions)..shuffle();
  String? _lastFeedback;
  bool _gameOver = false;

  void _answer(bool answer) {
    final correct = answer == _qs[_idx].answer;
    if (correct) _streak++; else _streak = 0;
    showAnswerBurst(context, correct: correct, streak: _streak);
    setState(() {
      _lastFeedback = correct ? '✅ Correct!' : '❌ Wrong!';
      if (correct) _score++;
    });
    Future.delayed(900.ms, () {
      if (!mounted) return;
      if (_idx + 1 >= _qs.length) setState(() => _gameOver = true);
      else setState(() { _idx++; _lastFeedback = null; });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_gameOver) return _GameOverScreen(score: _score, maxScore: _qs.length, onExit: widget.onExit, onReplay: () { setState(() { _score = 0; _idx = 0; _gameOver = false; _lastFeedback = null; _qs.shuffle(); }); });

    final q = _qs[_idx];
    return Scaffold(
      backgroundColor: AppColors.neuBackground,
      appBar: AppBar(title: const Text('True or False 🎯'), leading: IconButton(icon: const Icon(Icons.close), onPressed: widget.onExit)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            LinearProgressIndicator(value: (_idx + 1) / _qs.length, backgroundColor: AppColors.border, minHeight: 6),
            const SizedBox(height: 8),
            Text('${_idx + 1}/${_qs.length}  •  Score: $_score', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            const Spacer(),
            SolidCard(child: Padding(padding: const EdgeInsets.all(8), child: Text(q.statement, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, height: 1.5)))),
            const SizedBox(height: 40),
            if (_lastFeedback != null)
              Text(_lastFeedback!, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _lastFeedback!.startsWith('✅') ? AppColors.success : AppColors.error)).animate().scale(begin: const Offset(0.5, 0.5), duration: 200.ms, curve: Curves.elasticOut),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: ElevatedButton.icon(icon: const Icon(Icons.close, size: 20), label: const Text('FALSE', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)), onPressed: () => _answer(false), style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, padding: const EdgeInsets.symmetric(vertical: 16)))),
                const SizedBox(width: 16),
                Expanded(child: ElevatedButton.icon(icon: const Icon(Icons.check, size: 20), label: const Text('TRUE', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)), onPressed: () => _answer(true), style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, padding: const EdgeInsets.symmetric(vertical: 16)))),
              ],
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SPELL IT
// ─────────────────────────────────────────────
class _SpellIt extends StatefulWidget {
  final VoidCallback onExit;
  const _SpellIt({required this.onExit});

  @override
  State<_SpellIt> createState() => _SpellItState();
}

class _SpellItState extends State<_SpellIt> {
  int _score = 0, _idx = 0, _streak = 0;
  final List<_SpellQ> _qs = List.from(_spellQuestions)..shuffle();
  final TextEditingController _ctrl = TextEditingController();
  String? _feedback;
  bool _gameOver = false;

  void _check() {
    final answer = _ctrl.text.trim().toLowerCase();
    final correct = answer == _qs[_idx].answer.toLowerCase();
    if (correct) _streak++; else _streak = 0;
    showAnswerBurst(context, correct: correct, streak: _streak);
    setState(() { _feedback = correct ? '✅ Correct!' : '❌ ${_qs[_idx].answer}'; if (correct) _score += 10; });
    Future.delayed(1.2.seconds, () {
      if (!mounted) return;
      _ctrl.clear();
      if (_idx + 1 >= _qs.length) setState(() => _gameOver = true);
      else setState(() { _idx++; _feedback = null; });
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    if (_gameOver) return _GameOverScreen(score: _score, maxScore: _qs.length * 10, onExit: widget.onExit, onReplay: () { setState(() { _score = 0; _idx = 0; _gameOver = false; _feedback = null; _qs.shuffle(); }); _ctrl.clear(); });

    final q = _qs[_idx];
    final scrambled = _scramble(q.answer);

    return Scaffold(
      backgroundColor: AppColors.neuBackground,
      appBar: AppBar(title: const Text('Spell It! 🔤'), leading: IconButton(icon: const Icon(Icons.close), onPressed: widget.onExit)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            LinearProgressIndicator(value: (_idx + 1) / _qs.length, minHeight: 6),
            const SizedBox(height: 8),
            Text('${_idx + 1}/${_qs.length}  •  Score: $_score', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 30),
            SolidCard(child: Column(children: [
              const Text('HINT', style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w700, letterSpacing: 2)),
              const SizedBox(height: 8),
              Text(q.hint, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, height: 1.5)),
            ])),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(14)),
              child: Column(children: [
                const Text('Scrambled Letters', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 2)),
                const SizedBox(height: 8),
                Text(scrambled, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 8)),
              ]),
            ),
            const SizedBox(height: 24),
            TextField(controller: _ctrl, autofocus: true, textCapitalization: TextCapitalization.none, decoration: const InputDecoration(hintText: 'Type the correct spelling…', prefixIcon: Icon(Icons.spellcheck)), onSubmitted: (_) => _check()),
            if (_feedback != null) ...[
              const SizedBox(height: 12),
              Text(_feedback!, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _feedback!.startsWith('✅') ? AppColors.success : AppColors.error)).animate().fadeIn(),
            ],
            const SizedBox(height: 16),
            GradientButton(label: 'Submit', icon: Icons.check, onPressed: _check, width: double.infinity),
          ],
        ),
      ),
    );
  }

  String _scramble(String word) {
    final chars = word.split('')..shuffle();
    return chars.join().toUpperCase();
  }
}

String _scramble(String word) {
  final chars = word.split('')..shuffle(Random());
  return chars.join().toUpperCase();
}

// Game-over screen
class _GameOverScreen extends StatelessWidget {
  final int score, maxScore;
  final VoidCallback onExit, onReplay;
  const _GameOverScreen({required this.score, required this.maxScore, required this.onExit, required this.onReplay});

  @override
  Widget build(BuildContext context) {
    final pct = maxScore > 0 ? score / maxScore : 0.0;
    final msg = pct >= 0.8 ? '🏆 Excellent!' : pct >= 0.6 ? '⭐ Good job!' : pct >= 0.4 ? '💪 Keep practising!' : '📚 Study more!';

    return Scaffold(
      backgroundColor: AppColors.neuBackground,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(msg, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)).animate().scale(begin: const Offset(0.5, 0.5), duration: 600.ms, curve: Curves.elasticOut),
            const SizedBox(height: 16),
            Text('$score pts', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: AppColors.primary)).animate(delay: 200.ms).fadeIn(),
            const SizedBox(height: 4),
            Text('out of $maxScore', style: const TextStyle(color: AppColors.textSecondary)).animate(delay: 300.ms).fadeIn(),
            const SizedBox(height: 40),
            Row(mainAxisSize: MainAxisSize.min, children: [
              OutlinedButton.icon(icon: const Icon(Icons.home), label: const Text('Home'), onPressed: onExit),
              const SizedBox(width: 16),
              ElevatedButton.icon(icon: const Icon(Icons.replay), label: const Text('Play Again'), onPressed: onReplay, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary)),
            ]).animate(delay: 400.ms).slideY(begin: 0.3).fadeIn(),
          ],
        ),
      ),
    );
  }
}

// ─── Data ─────────────────────────────────────────────────────
class _QuizQ { final String question, correct; final List<String> options; const _QuizQ(this.question, this.correct, this.options); }
class _Card { final String text, pairId; final bool isTerm, revealed, matched; const _Card(this.text, this.isTerm, this.pairId, {this.revealed = false, this.matched = false}); _Card copyWith({bool? revealed, bool? matched}) => _Card(text, isTerm, pairId, revealed: revealed ?? this.revealed, matched: matched ?? this.matched); }
class _Pair { final String term, def; const _Pair(this.term, this.def); }
class _TFQ { final String statement; final bool answer; const _TFQ(this.statement, this.answer); }
class _SpellQ { final String answer, hint; const _SpellQ(this.answer, this.hint); }

const _quizQuestions = <_QuizQ>[
  _QuizQ('Which organelle is called the "powerhouse of the cell"?', 'Mitochondria', ['Chloroplast', 'Ribosome', 'Nucleus', 'Mitochondria']),
  _QuizQ('The pacemaker of the human heart is located in which structure?', 'SAN', ['AVN', 'Purkinje fibres', 'Bundle of His', 'SAN']),
  _QuizQ('What is the correct base pairing in DNA?', 'A-T, G-C', ['A-G, T-C', 'A-C, G-T', 'A-U, G-C', 'A-T, G-C']),
  _QuizQ('Which enzyme catalyzes the first step of the Calvin cycle?', 'RuBisCO', ['Hexokinase', 'PEP carboxylase', 'ATP synthase', 'RuBisCO']),
  _QuizQ('Which gas is released during the light reactions of photosynthesis?', 'Oxygen', ['CO₂', 'N₂', 'H₂', 'Oxygen']),
  _QuizQ('Haemophilia is a sex-linked disorder linked to which chromosome?', 'X chromosome', ['Y chromosome', 'Chromosome 21', 'Autosome', 'X chromosome']),
  _QuizQ('Down syndrome is caused by trisomy of which chromosome?', 'Chromosome 21', ['Chromosome 18', 'Chromosome 13', 'X chromosome', 'Chromosome 21']),
  _QuizQ('Which cells secrete insulin in the pancreas?', 'Beta cells', ['Alpha cells', 'Delta cells', 'Acinar cells', 'Beta cells']),
  _QuizQ('EMP pathway is another name for?', 'Glycolysis', ['Krebs cycle', 'Calvin cycle', 'Beta oxidation', 'Glycolysis']),
  _QuizQ('Photorespiration occurs in which type of plants?', 'C3 plants', ['C4 plants', 'CAM plants', 'Gymnosperms', 'C3 plants']),
];

const _matchPairs = <_Pair>[
  _Pair('RuBisCO', 'CO₂ fixation enzyme in Calvin cycle'),
  _Pair('Chargaff\'s rule', 'A=T and G=C in DNA'),
  _Pair('Synapsis', 'Pairing of homologous chromosomes in meiosis'),
  _Pair('Acrosome', 'Enzyme-filled cap on sperm head'),
  _Pair('Nephron', 'Structural and functional unit of kidney'),
  _Pair('Sarcomere', 'Contractile unit of skeletal muscle'),
  _Pair('Opsonisation', 'Coating of pathogens with antibodies'),
  _Pair('Melatonin', 'Hormone from pineal gland'),
];

const _tfQuestions = <_TFQ>[
  _TFQ('Mitochondria have 70S ribosomes.', true),
  _TFQ('Viruses contain both DNA and RNA.', false),
  _TFQ('Stomata are open during the day in C3 plants.', true),
  _TFQ('Sucrose is the main form of sugar transported in phloem.', true),
  _TFQ('Insulin is secreted by alpha cells of the islets of Langerhans.', false),
  _TFQ('NADPH is produced in the Calvin cycle.', false),
  _TFQ('Oogenesis results in 4 functional egg cells.', false),
  _TFQ('The left ventricle has thicker walls than the right ventricle.', true),
  _TFQ('Crossing over occurs during pachytene of Prophase I.', true),
  _TFQ('C4 plants have RuBisCO only in mesophyll cells.', false),
  _TFQ('Lichen is a mutualism between fungi and algae.', true),
  _TFQ('All fungi store glycogen as reserve food.', true),
];

const _spellQuestions = <_SpellQ>[
  _SpellQ('Osmosis', 'Movement of water across semi-permeable membrane'),
  _SpellQ('Chloroplast', 'Site of photosynthesis in plant cells'),
  _SpellQ('Ribosome', 'Site of protein synthesis'),
  _SpellQ('Mitochondria', 'Powerhouse of the cell'),
  _SpellQ('Haemoglobin', 'Oxygen-carrying protein in RBCs'),
  _SpellQ('Spermatogenesis', 'Formation of sperm cells'),
  _SpellQ('Chromosomes', 'DNA + protein structures carrying genes'),
  _SpellQ('Germination', 'Process by which a seed sprouts'),
  _SpellQ('Transpiration', 'Water loss from leaves'),
  _SpellQ('Glycolysis', 'First stage of cellular respiration'),
];
