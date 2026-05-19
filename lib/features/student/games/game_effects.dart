import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';

// ── Particle Explosion (correct answer celebration) ────────────
class ParticleExplosion extends StatefulWidget {
  final Color color;
  final VoidCallback onComplete;
  const ParticleExplosion({super.key, required this.color, required this.onComplete});

  @override
  State<ParticleExplosion> createState() => _ParticleExplosionState();
}

class _ParticleExplosionState extends State<ParticleExplosion>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  final _rng = Random();
  late List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    _particles = List.generate(30, (_) => _Particle(
      angle: _rng.nextDouble() * 2 * pi,
      speed: 80 + _rng.nextDouble() * 120,
      size: 4 + _rng.nextDouble() * 6,
      color: HSVColor.fromAHSV(
        1,
        (_rng.nextDouble() * 60 - 30 + HSVColor.fromColor(widget.color).hue) % 360,
        0.8 + _rng.nextDouble() * 0.2,
        0.9,
      ).toColor(),
    ));
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))
      ..forward().whenComplete(widget.onComplete);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _ctrl,
    builder: (_, __) => CustomPaint(
      painter: _ParticlePainter(_particles, _ctrl.value),
      size: Size.infinite,
    ),
  );
}

class _Particle {
  final double angle, speed, size;
  final Color color;
  const _Particle({required this.angle, required this.speed, required this.size, required this.color});
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double t;
  _ParticlePainter(this.particles, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final eased = Curves.easeOut.transform(t);
    for (final p in particles) {
      final x = cx + cos(p.angle) * p.speed * eased;
      final y = cy + sin(p.angle) * p.speed * eased;
      final opacity = (1 - eased).clamp(0.0, 1.0);
      canvas.drawCircle(
        Offset(x, y),
        p.size * (1 - eased * 0.5),
        Paint()..color = p.color.withOpacity(opacity),
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.t != t;
}

// ── Score Pop (+10, +20 etc) ──────────────────────────────────
class ScorePop extends StatefulWidget {
  final int points;
  final VoidCallback onComplete;
  const ScorePop({super.key, required this.points, required this.onComplete});

  @override
  State<ScorePop> createState() => _ScorePopState();
}

class _ScorePopState extends State<ScorePop>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _opacity, _y;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..forward().whenComplete(widget.onComplete);
    _opacity = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 30),
    ]).animate(_ctrl);
    _y = Tween(begin: 0.0, end: -60.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _ctrl,
    builder: (_, __) => Opacity(
      opacity: _opacity.value,
      child: Transform.translate(
        offset: Offset(0, _y.value),
        child: Text(
          '+${widget.points}',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: AppColors.success,
            shadows: [Shadow(color: AppColors.success.withOpacity(0.5), blurRadius: 12)],
          ),
        ),
      ),
    ),
  );
}

// ── Shake effect widget (wrong answer) ───────────────────────
class ShakeWidget extends StatefulWidget {
  final Widget child;
  final bool shake;
  const ShakeWidget({super.key, required this.child, required this.shake});

  @override
  State<ShakeWidget> createState() => _ShakeWidgetState();
}

class _ShakeWidgetState extends State<ShakeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _shake;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _shake = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -8.0), weight: 25),
      TweenSequenceItem(tween: Tween(begin: -8.0, end: 8.0), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: -4.0), weight: 25),
      TweenSequenceItem(tween: Tween(begin: -4.0, end: 0.0), weight: 25),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(ShakeWidget old) {
    super.didUpdateWidget(old);
    if (widget.shake && !old.shake) _ctrl.forward(from: 0);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _ctrl,
    builder: (_, child) => Transform.translate(
      offset: Offset(_shake.value, 0),
      child: child,
    ),
    child: widget.child,
  );
}

// ── Streak Fire Banner ────────────────────────────────────────
class StreakBanner extends StatelessWidget {
  final int streak;
  const StreakBanner({super.key, required this.streak});

  @override
  Widget build(BuildContext context) {
    if (streak < 3) return const SizedBox.shrink();
    final label = streak >= 10 ? '🌪️ UNSTOPPABLE! $streak streak!'
        : streak >= 7 ? '⚡ ON FIRE! $streak streak!'
        : '🔥 $streak streak!';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          Colors.orange.shade700, Colors.red.shade600,
        ]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.4), blurRadius: 12, spreadRadius: 2)],
      ),
      child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13)),
    )
        .animate(key: ValueKey(streak))
        .scale(begin: const Offset(0.5, 0.5), duration: 400.ms, curve: Curves.elasticOut)
        .fadeIn(duration: 200.ms);
  }
}

// ── Difficulty Badge ──────────────────────────────────────────
class DifficultyBadgeWidget extends StatelessWidget {
  final String mode;
  const DifficultyBadgeWidget({super.key, required this.mode});

  @override
  Widget build(BuildContext context) {
    final config = switch (mode) {
      'hard' => ('🔥 HARD', Colors.red.shade700, Colors.red.shade100),
      'easy' => ('🌱 EASY', AppColors.success, const Color(0xFFDCFCE7)),
      _ => ('⚡ NORMAL', AppColors.primary, AppColors.primarySurface),
    };
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: config.$3,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: config.$2.withOpacity(0.4)),
      ),
      child: Text(config.$1,
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: config.$2)),
    );
  }
}

// ── Animated Synapse Game ─────────────────────────────────────
class SynapseShooterGame extends StatefulWidget {
  final VoidCallback onExit;
  const SynapseShooterGame({super.key, required this.onExit});

  @override
  State<SynapseShooterGame> createState() => _SynapseShooterState();
}

class _SynapseShooterState extends State<SynapseShooterGame>
    with TickerProviderStateMixin {
  late AnimationController _bubbleCtrl;
  int _score = 0;
  int _correct = 0;
  int _round = 0;
  static const _maxRounds = 10;
  bool _finished = false;
  bool _answered = false;
  bool _isCorrect = false;
  int _showExplosion = -1; // index of exploded bubble

  static const _scenarios = [
    _SynapseQ('ACh', 'Acetylcholine', 'Neuromuscular junction — triggers muscle contraction', 0),
    _SynapseQ('GABA', 'GABA (γ-aminobutyric acid)', 'Inhibitory CNS neurotransmitter — reduces neuron excitability', 1),
    _SynapseQ('Dopa', 'Dopamine', 'Reward & pleasure — deficiency causes Parkinson\'s disease', 2),
    _SynapseQ('5-HT', 'Serotonin (5-HT)', 'Mood regulation — low levels linked to depression', 3),
    _SynapseQ('Epi', 'Epinephrine (Adrenaline)', 'Fight-or-flight — released by adrenal medulla, also a neurotransmitter', 0),
    _SynapseQ('GLU', 'Glutamate', 'Main excitatory neurotransmitter in CNS; important for memory', 1),
    _SynapseQ('NE', 'Norepinephrine', 'Sympathetic nervous system; alertness and arousal', 2),
    _SynapseQ('His', 'Histamine', 'Allergic response & gastric acid stimulation; CNS wakefulness', 3),
    _SynapseQ('Gly', 'Glycine', 'Inhibitory in spinal cord; target of tetanus toxin (INDIRECT)', 1),
    _SynapseQ('ACh', 'Acetylcholine', 'Parasympathetic junction — slows heart rate (vagal tone)', 0),
  ];

  late List<_SynapseQ> _shuffled;
  int _qIndex = 0;
  late List<String> _options;
  double _bubblePos = 0; // 0 to 1

  @override
  void initState() {
    super.initState();
    _shuffled = List.from(_scenarios)..shuffle();
    _bubbleCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2500),
    )..addStatusListener((s) {
      if (s == AnimationStatus.completed && !_answered) {
        // Missed the bubble — timeout
        _handleAnswer(-1);
      }
    });
    _loadQuestion();
  }

  void _loadQuestion() {
    final q = _shuffled[_qIndex % _shuffled.length];
    // Build 4 options including the correct one
    final allNames = _scenarios.map((s) => s.fullName).toSet().toList()..shuffle();
    final opts = [q.fullName];
    for (final n in allNames) {
      if (n != q.fullName && opts.length < 4) opts.add(n);
    }
    opts.shuffle();
    setState(() {
      _options = opts;
      _answered = false;
      _isCorrect = false;
      _showExplosion = -1;
    });
    _bubbleCtrl.forward(from: 0);
  }

  void _handleAnswer(int optionIndex) {
    if (_answered) return;
    _bubbleCtrl.stop();
    final q = _shuffled[_qIndex % _shuffled.length];
    final ok = optionIndex >= 0 && _options[optionIndex] == q.fullName;
    if (ok) {
      _score += 20;
      _correct++;
      setState(() { _answered = true; _isCorrect = true; _showExplosion = optionIndex; });
    } else {
      setState(() { _answered = true; _isCorrect = false; });
    }
    _round++;
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      if (_round >= _maxRounds) { setState(() => _finished = true); return; }
      _qIndex++;
      _loadQuestion();
    });
  }

  @override
  void dispose() { _bubbleCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    if (_finished) {
      return Scaffold(
        backgroundColor: AppColors.neuBackground,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text('🧠', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 16),
              const Text('Synapse Shooter', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
              Text('Score: $_score / ${_maxRounds * 20}', style: const TextStyle(fontSize: 18, color: AppColors.primary)),
              const SizedBox(height: 24),
              Row(children: [
                Expanded(child: OutlinedButton(onPressed: widget.onExit, child: const Text('Exit'))),
                const SizedBox(width: 12),
                Expanded(flex: 2, child: ElevatedButton(
                  onPressed: () { _score = 0; _correct = 0; _round = 0; _qIndex = 0; _finished = false; _shuffled.shuffle(); _loadQuestion(); setState(() {}); },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                  child: const Text('Play Again', style: TextStyle(fontWeight: FontWeight.w800)),
                )),
              ]),
            ]),
          ),
        ),
      );
    }

    final q = _shuffled[_qIndex % _shuffled.length];

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Column(children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              GestureDetector(onTap: widget.onExit,
                child: const Icon(Icons.close_rounded, color: Colors.white54, size: 24)),
              const SizedBox(width: 12),
              const Text('🧠 Synapse Shooter',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
              const Spacer(),
              Text('⭐ $_score', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.w900, fontSize: 16)),
            ]),
          ),
          // Round progress
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _round / _maxRounds,
                backgroundColor: Colors.white12,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.purple),
                minHeight: 6,
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Synapse animation
          SizedBox(
            height: 180,
            child: AnimatedBuilder(
              animation: _bubbleCtrl,
              builder: (_, __) {
                final progress = Curves.easeIn.transform(_bubbleCtrl.value);
                return CustomPaint(
                  painter: _SynapsePainter(
                    bubbleProgress: progress,
                    bubbleLabel: q.shortLabel,
                    answered: _answered,
                    correct: _isCorrect,
                  ),
                  size: Size.infinite,
                );
              },
            ),
          ),
          // Question
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text('Identify the neurotransmitter reaching the receptor!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4)),
          ),
          if (_answered) Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _isCorrect ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _isCorrect ? Colors.green : Colors.red),
              ),
              child: Column(children: [
                Text(_isCorrect ? '✅ Correct!' : '❌ It was ${q.fullName}',
                    style: TextStyle(color: _isCorrect ? Colors.green : Colors.red, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(q.fact, textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 11, height: 1.4)),
              ]),
            ),
          ),
          const Spacer(),
          // Options
          Padding(
            padding: const EdgeInsets.all(14),
            child: GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.8,
              children: _options.asMap().entries.map((e) {
                final isCorrectOption = e.value == q.fullName;
                Color bg = const Color(0xFF2D2D5E);
                Color border = Colors.white24;
                if (_answered) {
                  if (isCorrectOption) { bg = Colors.green.withOpacity(0.3); border = Colors.green; }
                }
                return GestureDetector(
                  onTap: () => _handleAnswer(e.key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: bg, borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: border, width: 1.5),
                    ),
                    child: Center(
                      child: Text(e.value,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ]),
      ),
    );
  }
}

class _SynapseQ {
  final String shortLabel;
  final String fullName;
  final String fact;
  final int receptor; // which receptor slot (0-3)
  const _SynapseQ(this.shortLabel, this.fullName, this.fact, this.receptor);
}

class _SynapsePainter extends CustomPainter {
  final double bubbleProgress; // 0 to 1 (left to right)
  final String bubbleLabel;
  final bool answered;
  final bool correct;

  _SynapsePainter({
    required this.bubbleProgress,
    required this.bubbleLabel,
    required this.answered,
    required this.correct,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;

    // Draw presynaptic terminal (left)
    final prePaint = Paint()
      ..color = const Color(0xFF6C63FF)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(20, cy - 30, 80, 60), const Radius.circular(12)), prePaint);
    _drawText(canvas, 'Pre-\nsynaptic', Offset(60, cy), Colors.white, 10);

    // Draw postsynaptic terminal (right)
    final postPaint = Paint()
      ..color = const Color(0xFF00B4D8)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(w - 100, cy - 30, 80, 60), const Radius.circular(12)), postPaint);
    _drawText(canvas, 'Post-\nsynaptic', Offset(w - 60, cy), Colors.white, 10);

    // Draw synapse gap
    canvas.drawRect(
      Rect.fromLTWH(105, cy - 2, w - 210, 4),
      Paint()..color = Colors.white12,
    );

    // Draw receptor slots on postsynaptic
    for (int i = 0; i < 3; i++) {
      canvas.drawCircle(
        Offset(w - 100 + 12 + i * 14, cy + 20),
        5,
        Paint()..color = Colors.white30,
      );
    }

    // Draw the traveling neurotransmitter bubble
    if (!answered || correct) {
      final bx = 105 + (w - 215) * bubbleProgress;
      final waveY = cy + sin(bubbleProgress * pi * 4) * 12;

      // Glow
      canvas.drawCircle(
        Offset(bx, waveY),
        22,
        Paint()
          ..color = const Color(0xFFFFE066).withOpacity(0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
      );

      // Main bubble
      canvas.drawCircle(
        Offset(bx, waveY),
        16,
        Paint()
          ..shader = const RadialGradient(
            colors: [Color(0xFFFFE066), Color(0xFFFF9800)],
          ).createShader(Rect.fromCircle(center: Offset(bx, waveY), radius: 16)),
      );

      // Label
      _drawText(canvas, bubbleLabel, Offset(bx, waveY), const Color(0xFF1A1A2E), 9);
    }

    // Correct/wrong flash
    if (answered) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(w - 100, cy - 30, 80, 60),
          const Radius.circular(12),
        ),
        Paint()..color = (correct ? Colors.green : Colors.red).withOpacity(0.4),
      );
    }
  }

  void _drawText(Canvas canvas, String text, Offset center, Color color, double size) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: color, fontSize: size, fontWeight: FontWeight.w700, height: 1.2)),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 70);
    tp.paint(canvas, center.translate(-tp.width / 2, -tp.height / 2));
  }

  @override
  bool shouldRepaint(_SynapsePainter old) =>
      old.bubbleProgress != bubbleProgress || old.answered != answered;
}

// ── Animated Cell Division Phase Picker ───────────────────────
class CellDivisionGame extends StatefulWidget {
  final VoidCallback onExit;
  const CellDivisionGame({super.key, required this.onExit});

  @override
  State<CellDivisionGame> createState() => _CellDivisionState();
}

class _CellDivisionState extends State<CellDivisionGame>
    with TickerProviderStateMixin {
  late AnimationController _phaseCtrl;
  int _score = 0;
  int _round = 0;
  static const _maxRounds = 8;
  bool _answered = false;
  bool _finished = false;
  int? _selectedOption;

  static const _phases = [
    _DivisionPhase('Interphase', 'Cell is growing. DNA replication occurs. Chromosomes are long and thin (chromatin).', ['Interphase', 'Prophase', 'Metaphase', 'Anaphase'], 0, 0.0),
    _DivisionPhase('Prophase', 'Chromosomes condense and become visible. Nuclear envelope breaks down. Spindle fibers form.', ['Interphase', 'Prophase', 'Metaphase', 'Telophase'], 1, 0.2),
    _DivisionPhase('Metaphase', 'Chromosomes align at the cell equator (metaphase plate). Spindle fibers attach to centromeres.', ['Prophase', 'Metaphase', 'Anaphase', 'Telophase'], 1, 0.4),
    _DivisionPhase('Anaphase', 'Sister chromatids are pulled to opposite poles by shortening spindle fibers. Cell elongates.', ['Metaphase', 'Anaphase', 'Telophase', 'Cytokinesis'], 1, 0.6),
    _DivisionPhase('Telophase', 'Two nuclei reform. Chromosomes decondense. Nuclear envelope reforms around each set.', ['Anaphase', 'Telophase', 'Cytokinesis', 'Interphase'], 1, 0.8),
    _DivisionPhase('Cytokinesis', 'Cytoplasm divides. Cleavage furrow in animals; cell plate in plants. Two daughter cells form.', ['Telophase', 'Cytokinesis', 'Interphase', 'Prophase'], 1, 1.0),
    _DivisionPhase('Meiosis I — Prophase I', 'Homologous chromosomes pair up (synapsis). Crossing over (chiasmata) occurs. Tetrads form.', ['Prophase (Mitosis)', 'Prophase I (Meiosis)', 'Metaphase I', 'Anaphase I'], 1, 0.25),
    _DivisionPhase('Meiosis II — Anaphase II', 'Sister chromatids separate. Results in 4 haploid cells. No DNA replication before meiosis II.', ['Anaphase I', 'Anaphase II', 'Telophase II', 'Cytokinesis II'], 1, 0.75),
  ];

  late List<_DivisionPhase> _shuffled;
  int _phaseIndex = 0;

  @override
  void initState() {
    super.initState();
    _shuffled = List.from(_phases)..shuffle();
    _phaseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat(reverse: false);
    _loadPhase();
  }

  void _loadPhase() {
    setState(() { _answered = false; _selectedOption = null; });
    _phaseCtrl.forward(from: 0);
  }

  void _select(int i) {
    if (_answered) return;
    final phase = _shuffled[_phaseIndex % _shuffled.length];
    final ok = phase.options[i] == phase.name;
    if (ok) { _score += 15; }
    setState(() { _answered = true; _selectedOption = i; _round++; });
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (!mounted) return;
      if (_round >= _maxRounds) { setState(() => _finished = true); return; }
      _phaseIndex++;
      _loadPhase();
    });
  }

  @override
  void dispose() { _phaseCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    if (_finished) {
      return Scaffold(
        backgroundColor: AppColors.neuBackground,
        body: SafeArea(child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('🔬', style: TextStyle(fontSize: 64)),
          const Text('Cell Division', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
          Text('$_score / ${_maxRounds * 15} pts', style: const TextStyle(fontSize: 18, color: AppColors.primary)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () { _score = 0; _round = 0; _phaseIndex = 0; _finished = false; _shuffled.shuffle(); _loadPhase(); setState((){}); },
            child: const Text('Play Again'),
          ),
          TextButton(onPressed: widget.onExit, child: const Text('Exit')),
        ]))),
      );
    }

    final phase = _shuffled[_phaseIndex % _shuffled.length];

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              GestureDetector(onTap: widget.onExit, child: const Icon(Icons.close_rounded, color: Colors.white54)),
              const SizedBox(width: 12),
              const Text('🔬 Cell Division', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
              const Spacer(),
              Text('⭐ $_score', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.w900)),
            ]),
          ),
          // Animated cell
          Expanded(
            flex: 3,
            child: AnimatedBuilder(
              animation: _phaseCtrl,
              builder: (_, __) => CustomPaint(
                painter: _CellPainter(phase: phase, t: _phaseCtrl.value),
                size: Size.infinite,
              ),
            ),
          ),
          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(phase.description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 12.5, height: 1.5)),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 6),
            child: Text('Which phase is this?',
                style: TextStyle(color: Colors.white60, fontSize: 12)),
          ),
          // Options
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 20),
            child: GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 3.0,
              children: phase.options.asMap().entries.map((e) {
                final isCorrect = e.value == phase.name;
                Color bg = const Color(0xFF1C2130);
                Color border = Colors.white12;
                if (_answered) {
                  if (isCorrect) { bg = Colors.green.withOpacity(0.3); border = Colors.green; }
                  else if (_selectedOption == e.key) { bg = Colors.red.withOpacity(0.3); border = Colors.red; }
                }
                return GestureDetector(
                  onTap: () => _select(e.key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: bg, borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: border, width: 1.5),
                    ),
                    child: Center(child: Text(e.value,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700))),
                  ),
                );
              }).toList(),
            ),
          ),
        ]),
      ),
    );
  }
}

class _DivisionPhase {
  final String name, description;
  final List<String> options;
  final int correctIndex;
  final double animationPoint;
  const _DivisionPhase(this.name, this.description, this.options, this.correctIndex, this.animationPoint);
}

class _CellPainter extends CustomPainter {
  final _DivisionPhase phase;
  final double t;
  _CellPainter({required this.phase, required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = min(size.width, size.height) * 0.38;
    final prog = phase.animationPoint;

    // Outer cell membrane
    final cellSplit = prog > 0.85 ? (prog - 0.85) / 0.15 : 0.0;
    if (cellSplit < 0.8) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(cx, cy), width: r * 2 * (1 + cellSplit * 0.3), height: r * 2),
        Paint()..color = const Color(0xFF4FC3F7).withOpacity(0.15),
      );
      canvas.drawOval(
        Rect.fromCenter(center: Offset(cx, cy), width: r * 2 * (1 + cellSplit * 0.3), height: r * 2),
        Paint()
          ..color = const Color(0xFF4FC3F7).withOpacity(0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
      );
    } else {
      // Two daughter cells forming
      final sep = (cellSplit - 0.8) / 0.2 * r * 0.6;
      for (final side in [-1, 1]) {
        canvas.drawOval(
          Rect.fromCenter(center: Offset(cx + side * sep, cy), width: r * 1.5, height: r * 1.5),
          Paint()..color = const Color(0xFF4FC3F7).withOpacity(0.2),
        );
        canvas.drawOval(
          Rect.fromCenter(center: Offset(cx + side * sep, cy), width: r * 1.5, height: r * 1.5),
          Paint()
            ..color = const Color(0xFF4FC3F7).withOpacity(0.6)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      }
    }

    // Draw chromosomes based on phase
    _drawChromosomes(canvas, cx, cy, r, prog, t);

    // Spindle fibers
    if (prog > 0.15 && prog < 0.85) {
      final opacity = (prog < 0.3 ? (prog - 0.15) / 0.15 : prog > 0.7 ? (0.85 - prog) / 0.15 : 1.0).clamp(0.0, 1.0);
      for (int i = -2; i <= 2; i++) {
        canvas.drawLine(
          Offset(cx - r * 0.9, cy + i * r * 0.15),
          Offset(cx + r * 0.9, cy + i * r * 0.15),
          Paint()..color = const Color(0xFFCE93D8).withOpacity(opacity * 0.4)..strokeWidth = 0.8,
        );
      }
    }
  }

  void _drawChromosomes(Canvas canvas, double cx, double cy, double r, double prog, double t) {
    final chromPaint = Paint()..color = const Color(0xFFFF7043);

    if (prog < 0.1) {
      // Interphase — diffuse chromatin
      for (int i = 0; i < 12; i++) {
        final angle = i / 12 * 2 * pi + t * 0.5;
        final d = r * 0.4 * (0.5 + 0.5 * sin(i + t));
        canvas.drawCircle(
          Offset(cx + cos(angle) * d, cy + sin(angle) * d), 3,
          Paint()..color = const Color(0xFFFF7043).withOpacity(0.5),
        );
      }
    } else if (prog < 0.35) {
      // Prophase — condensing
      for (int i = 0; i < 4; i++) {
        final angle = i / 4 * 2 * pi;
        final d = r * 0.3;
        _drawChromosome(canvas, Offset(cx + cos(angle) * d, cy + sin(angle) * d), 12, angle + pi / 2, chromPaint);
      }
    } else if (prog < 0.55) {
      // Metaphase — aligned
      for (int i = -1; i <= 1; i++) {
        _drawChromosome(canvas, Offset(cx, cy + i * r * 0.28), 14, pi / 2, chromPaint);
        _drawChromosome(canvas, Offset(cx + r * 0.05, cy + i * r * 0.28), 14, pi / 2, chromPaint);
      }
    } else if (prog < 0.75) {
      // Anaphase — separating
      final sep = (prog - 0.55) / 0.2;
      for (int i = -1; i <= 1; i++) {
        _drawChromosome(canvas, Offset(cx - r * 0.35 * sep, cy + i * r * 0.28), 10, pi / 2,
            Paint()..color = const Color(0xFFFF7043));
        _drawChromosome(canvas, Offset(cx + r * 0.35 * sep, cy + i * r * 0.28), 10, pi / 2,
            Paint()..color = const Color(0xFF42A5F5));
      }
    }
  }

  void _drawChromosome(Canvas canvas, Offset center, double length, double angle, Paint paint) {
    final dx = cos(angle) * length / 2;
    final dy = sin(angle) * length / 2;
    final path = Path()
      ..moveTo(center.dx - dx, center.dy - dy)
      ..lineTo(center.dx + dx, center.dy + dy);
    canvas.drawPath(path, paint..style = PaintingStyle.stroke..strokeWidth = 4..strokeCap = StrokeCap.round);
    canvas.drawCircle(center, 3, paint..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(_CellPainter old) => old.t != t;
}
