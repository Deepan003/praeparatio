import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/haptic_service.dart';

// ── Shared colours for game UI ────────────────────────────────
const _kCorrect = Color(0xFF16A34A);
const _kWrong   = Color(0xFFDC2626);
const _kNeutral = AppColors.primary;

// ── Countdown timer widget ────────────────────────────────────
class GameTimer extends StatefulWidget {
  final int seconds;
  final VoidCallback onExpired;
  const GameTimer({super.key, required this.seconds, required this.onExpired});

  @override
  State<GameTimer> createState() => GameTimerState();
}

class GameTimerState extends State<GameTimer> {
  late int _remaining;
  Timer? _t;

  @override
  void initState() {
    super.initState();
    _remaining = widget.seconds;
    _t = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _remaining--);
      if (_remaining <= 0) { _t?.cancel(); widget.onExpired(); }
    });
  }

  @override
  void dispose() { _t?.cancel(); super.dispose(); }

  void pause()  => _t?.cancel();
  void resume() {
    _t = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _remaining--);
      if (_remaining <= 0) { _t?.cancel(); widget.onExpired(); }
    });
  }

  @override
  Widget build(BuildContext context) {
    final pct = _remaining / widget.seconds;
    final color = pct > 0.5 ? _kCorrect : pct > 0.25 ? Colors.orange : _kWrong;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.timer_rounded, size: 16, color: color),
      const SizedBox(width: 4),
      AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 200),
        style: TextStyle(
          fontSize: _remaining <= 5 ? 18 : 15,
          fontWeight: FontWeight.w900,
          color: color,
        ),
        child: Text('${_remaining}s'),
      ),
    ]).animate(target: _remaining <= 5 ? 1 : 0)
        .shake(hz: 2, offset: const Offset(2, 0));
  }
}

// ── Score display ─────────────────────────────────────────────
class ScoreDisplay extends StatelessWidget {
  final int score;
  final int streak;
  const ScoreDisplay({super.key, required this.score, required this.streak});

  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.star_rounded, size: 14, color: AppColors.accent),
        const SizedBox(width: 4),
        Text('$score', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.primary)),
      ]),
    ),
    if (streak >= 2) ...[
      const SizedBox(width: 6),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(color: AppColors.errorSurface, borderRadius: BorderRadius.circular(10)),
        child: Text('🔥$streak', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
      ),
    ],
  ]);
}

// ── Answer feedback overlay ───────────────────────────────────
class AnswerFeedback extends StatelessWidget {
  final bool correct;
  final String message;
  final String explanation;
  final VoidCallback onContinue;
  const AnswerFeedback({
    super.key,
    required this.correct,
    required this.message,
    required this.explanation,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final color = correct ? _kCorrect : _kWrong;
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.neuSurface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: color, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Big icon
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    correct ? Icons.check_circle_rounded : Icons.cancel_rounded,
                    size: 40, color: color,
                  ),
                ),
              ).animate()
                  .scale(begin: const Offset(0, 0), duration: 400.ms, curve: Curves.elasticOut),
              const SizedBox(height: 14),
              Text(message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: color)),
              const SizedBox(height: 10),
              // Explanation
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.infoSurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(explanation,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.info, height: 1.5)),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () { HapticFeedback.lightImpact(); onContinue(); },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Continue',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Game shell — wraps a game with title bar + exit ───────────
class GameShell extends StatelessWidget {
  final String title;
  final String emoji;
  final Color color;
  final Widget child;
  final int score;
  final int streak;
  final Widget? timerWidget;
  final VoidCallback onExit;
  final String? difficultyBadge;

  const GameShell({
    super.key,
    required this.title,
    required this.emoji,
    required this.color,
    required this.child,
    required this.score,
    required this.streak,
    this.timerWidget,
    required this.onExit,
    this.difficultyBadge,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neuBackground,
      body: SafeArea(
        child: Column(children: [
          // Top bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              border: Border(bottom: BorderSide(color: color.withOpacity(0.2))),
            ),
            child: Row(children: [
              // Exit button
              GestureDetector(
                onTap: onExit,
                child: Container(
                  width: 34, height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.neuSurface,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: AppColors.neuRaisedSoft,
                  ),
                  child: const Icon(Icons.close_rounded, size: 18, color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(width: 10),
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w800)),
                    if (difficultyBadge != null)
                      Text(difficultyBadge!,
                          style: const TextStyle(
                              fontSize: 9, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              if (timerWidget != null) timerWidget!,
              const SizedBox(width: 8),
              ScoreDisplay(score: score, streak: streak),
            ]),
          ),
          // Content
          Expanded(child: child),
        ]),
      ),
    );
  }
}

// ── Game Result Screen ────────────────────────────────────────
class GameResultScreen extends StatefulWidget {
  final String gameName;
  final int score;
  final int maxScore;
  final int correct;
  final int wrong;
  final List<String> facts;
  final VoidCallback onPlayAgain;
  final VoidCallback onExit;
  const GameResultScreen({
    super.key,
    required this.gameName,
    required this.score,
    required this.maxScore,
    required this.correct,
    required this.wrong,
    required this.facts,
    required this.onPlayAgain,
    required this.onExit,
  });

  @override
  State<GameResultScreen> createState() => _GameResultScreenState();
}

class _GameResultScreenState extends State<GameResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _ringCtrl;
  late AnimationController _burstCtrl;

  @override
  void initState() {
    super.initState();
    _ringCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..forward();
    _burstCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700))
      ..forward();
    HapticFeedback.mediumImpact();
  }

  @override
  void dispose() {
    _ringCtrl.dispose();
    _burstCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pct = widget.maxScore > 0 ? widget.score / widget.maxScore : 0.0;
    final grade =
        pct >= 0.9 ? 'S' : pct >= 0.7 ? 'A' : pct >= 0.5 ? 'B' : 'C';
    final gradeColor =
        pct >= 0.7 ? _kCorrect : pct >= 0.5 ? Colors.orange : _kWrong;
    final medalEmoji = pct >= 0.9
        ? '🏆'
        : pct >= 0.7
            ? '🥇'
            : pct >= 0.5
                ? '🥈'
                : '🥉';
    final msg = pct >= 0.9
        ? 'Outstanding!'
        : pct >= 0.7
            ? 'Great job!'
            : pct >= 0.5
                ? 'Good effort!'
                : 'Keep practising!';

    final isMobile = MediaQuery.sizeOf(context).width < 600;

    return Scaffold(
      backgroundColor: AppColors.neuBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 20 : 80, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(children: [
              const SizedBox(height: 12),

              // ── Medal + burst ────────────────────────────────
              Stack(alignment: Alignment.center, children: [
                // Outer burst rings (decorative)
                AnimatedBuilder(
                  animation: _burstCtrl,
                  builder: (_, __) {
                    final t = Curves.easeOut.transform(_burstCtrl.value);
                    return CustomPaint(
                      size: const Size(140, 140),
                      painter: _BurstRingPainter(t, gradeColor),
                    );
                  },
                ),
                // Grade circle
                AnimatedBuilder(
                  animation: _ringCtrl,
                  builder: (_, child) {
                    final t =
                        CurvedAnimation(parent: _ringCtrl, curve: Curves.easeOut)
                            .value;
                    return Transform.scale(
                      scale: Curves.elasticOut.transform(
                          (_ringCtrl.value).clamp(0.0, 1.0)),
                      child: child,
                    );
                  },
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: gradeColor.withOpacity(0.10),
                      shape: BoxShape.circle,
                      border: Border.all(color: gradeColor, width: 3),
                      boxShadow: [
                        BoxShadow(
                            color: gradeColor.withOpacity(0.20),
                            blurRadius: 20,
                            spreadRadius: 2),
                      ],
                    ),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(medalEmoji,
                              style: const TextStyle(fontSize: 22)),
                          Text(grade,
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: gradeColor,
                                  height: 1.1)),
                        ]),
                  ),
                ),
              ]),

              const SizedBox(height: 14),

              // ── Title + message ──────────────────────────────
              Text(widget.gameName,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w800))
                  .animate(delay: 250.ms)
                  .fadeIn(duration: 350.ms)
                  .slideY(begin: 0.2),
              const SizedBox(height: 4),
              Text(msg,
                      style: TextStyle(
                          fontSize: 13,
                          color: gradeColor,
                          fontWeight: FontWeight.w700))
                  .animate(delay: 350.ms)
                  .fadeIn(),

              const SizedBox(height: 22),

              // ── Circular progress ring ───────────────────────
              AnimatedBuilder(
                animation: _ringCtrl,
                builder: (_, __) => CustomPaint(
                  size: const Size(130, 130),
                  painter: _ScoreRingPainter(
                    progress: pct * _ringCtrl.value,
                    color: gradeColor,
                    percentage: (pct * 100).toInt(),
                    score: widget.score,
                    maxScore: widget.maxScore,
                  ),
                ),
              ).animate(delay: 200.ms).fadeIn(duration: 400.ms),

              const SizedBox(height: 20),

              // ── Stat cards row ────────────────────────────────
              Row(children: [
                _StatCard('Correct', '${widget.correct}', _kCorrect,
                    Icons.check_circle_rounded),
                const SizedBox(width: 10),
                _StatCard('Wrong', '${widget.wrong}', _kWrong,
                    Icons.cancel_rounded),
                const SizedBox(width: 10),
                _StatCard(
                    'Skipped',
                    '${widget.maxScore ~/ 10 - widget.correct - widget.wrong < 0 ? 0 : widget.maxScore ~/ 10 - widget.correct - widget.wrong}',
                    AppColors.textSecondary,
                    Icons.remove_circle_outline_rounded),
              ]).animate(delay: 550.ms).fadeIn().slideY(begin: 0.15),

              const SizedBox(height: 18),

              // ── NCERT Insight card ────────────────────────────
              if (widget.facts.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                        color: AppColors.primary.withOpacity(0.2)),
                    boxShadow: AppColors.neuRaisedSoft,
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Row(children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                            child:
                                Text('🧠', style: TextStyle(fontSize: 14))),
                      ),
                      const SizedBox(width: 10),
                      const Text('NCERT Insight',
                          style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                              fontSize: 13)),
                    ]),
                    const SizedBox(height: 10),
                    Text(widget.facts.first,
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            height: 1.6)),
                  ]),
                ).animate(delay: 750.ms).fadeIn(),

              const SizedBox(height: 16),

              // ── Share result ──────────────────────────────────
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  final text = 'I scored $medalEmoji ${widget.score}/${widget.maxScore} ($grade grade) in ${widget.gameName} on PRAEPARATIO! 🧬';
                  Clipboard.setData(ClipboardData(text: text));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Row(children: [
                        Icon(Icons.copy_rounded, size: 14, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Score copied — paste it anywhere!'),
                      ]),
                      duration: const Duration(seconds: 2),
                      backgroundColor: AppColors.primary,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  decoration: BoxDecoration(
                    color: AppColors.neuSurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.share_rounded, size: 15, color: AppColors.textSecondary),
                    SizedBox(width: 7),
                    Text('Share Score', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                  ]),
                ),
              ).animate(delay: 950.ms).fadeIn(),

              const SizedBox(height: 16),

              // ── Action buttons ────────────────────────────────
              Row(children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.neuSurface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppColors.neuRaisedSoft,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: TextButton.icon(
                      icon: const Icon(Icons.arrow_back_rounded, size: 16),
                      label: const Text('Exit',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      onPressed: widget.onExit,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                            color: AppColors.primary.withOpacity(0.30),
                            blurRadius: 14,
                            offset: const Offset(0, 4)),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.replay_rounded, size: 18),
                      label: const Text('Play Again',
                          style: TextStyle(fontWeight: FontWeight.w800)),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        widget.onPlayAgain();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                ),
              ]).animate(delay: 900.ms).fadeIn().slideY(begin: 0.2),

              const SizedBox(height: 16),
            ]),
          ),
        ),
      ),
    );
  }
}

// ── Score ring painter ────────────────────────────────────────
class _ScoreRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final int percentage;
  final int score;
  final int maxScore;
  _ScoreRingPainter(
      {required this.progress,
      required this.color,
      required this.percentage,
      required this.score,
      required this.maxScore});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2;
    final r = size.width / 2 - 8;

    // Background track
    canvas.drawCircle(
        Offset(cx, cy),
        r,
        Paint()
          ..color = AppColors.border
          ..style = PaintingStyle.stroke
          ..strokeWidth = 10);

    // Progress arc
    final rect = Rect.fromCenter(center: Offset(cx, cy), width: r * 2, height: r * 2);
    canvas.drawArc(
        rect,
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 10
          ..strokeCap = StrokeCap.round);

    // Centre text — score
    final tpScore = TextPainter(
      text: TextSpan(
          text: '$score',
          style: TextStyle(
              fontSize: 26, fontWeight: FontWeight.w900, color: color)),
      textDirection: TextDirection.ltr,
    )..layout();
    tpScore.paint(
        canvas, Offset(cx - tpScore.width / 2, cy - tpScore.height / 2 - 8));

    final tpMax = TextPainter(
      text: TextSpan(
          text: '/ $maxScore pts',
          style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary)),
      textDirection: TextDirection.ltr,
    )..layout();
    tpMax.paint(
        canvas, Offset(cx - tpMax.width / 2, cy + tpScore.height / 2 - 4));
  }

  @override
  bool shouldRepaint(_ScoreRingPainter old) => old.progress != progress;
}

// ── Burst ring painter (decorative rays behind medal) ─────────
class _BurstRingPainter extends CustomPainter {
  final double t;
  final Color color;
  _BurstRingPainter(this.t, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2;
    final p = Paint()
      ..color = color.withOpacity(0.12 * (1 - t))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final r1 = 52.0 + 30 * t;
    final r2 = 60.0 + 35 * t;
    canvas.drawCircle(Offset(cx, cy), r1, p);
    canvas.drawCircle(Offset(cx, cy), r2,
        p..color = color.withOpacity(0.07 * (1 - t)));
  }

  @override
  bool shouldRepaint(_BurstRingPainter old) => old.t != t;
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final Color color;
  final IconData icon;
  const _StatCard(this.label, this.value, this.color, this.icon);

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.neuSurface,
            borderRadius: BorderRadius.circular(14),
            boxShadow: AppColors.neuRaisedSoft,
            border:
                Border.all(color: color.withOpacity(0.18)),
          ),
          child: Column(children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 5),
            Text(value,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: color)),
            Text(label,
                style: const TextStyle(
                    fontSize: 9.5, color: AppColors.textSecondary)),
          ]),
        ),
      );
}

// ── Legacy _StatPill kept for any callers ─────────────────────
class _StatPill extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatPill(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(children: [
            Text(value,
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w900, color: color)),
            Text(label,
                style: const TextStyle(
                    fontSize: 10, color: AppColors.textSecondary)),
          ]),
        ),
      );
}

// ── Multiple-choice option tile ───────────────────────────────
class OptionTile extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final Color? highlightColor;
  final bool isSelected;
  const OptionTile({
    super.key,
    required this.text,
    required this.onTap,
    this.highlightColor,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = highlightColor ?? AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : AppColors.neuSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? color : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? AppColors.neuInset : AppColors.neuRaisedSoft,
        ),
        child: Text(text,
            style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? color : AppColors.textPrimary,
                height: 1.4)),
      ),
    );
  }
}

// ── Non-blocking correct-answer burst popup ───────────────────
//
// Call showAnswerBurst(context, correct: true/false, streak: n)
// It appears at the top of the screen WITHOUT covering question content.
// Auto-dismisses after 1.6 seconds.
void showAnswerBurst(BuildContext context,
    {required bool correct, int streak = 0}) {
  if (correct) {
    HapticService.light();
  } else {
    HapticService.error();
  }
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _AnswerBurstOverlay(
      correct: correct,
      streak: streak,
      onDone: () {
        if (entry.mounted) entry.remove();
      },
    ),
  );
  Overlay.of(context, rootOverlay: true).insert(entry);
}

class _AnswerBurstOverlay extends StatefulWidget {
  final bool correct;
  final int streak;
  final VoidCallback onDone;
  const _AnswerBurstOverlay(
      {required this.correct, required this.streak, required this.onDone});

  @override
  State<_AnswerBurstOverlay> createState() => _AnswerBurstOverlayState();
}

class _AnswerBurstOverlayState extends State<_AnswerBurstOverlay>
    with TickerProviderStateMixin {
  late AnimationController _ringCtrl;
  late AnimationController _fadeCtrl;
  late AnimationController _streakCtrl;

  @override
  void initState() {
    super.initState();
    _ringCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))
      ..forward();
    _streakCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 450))
      ..forward();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));

    Future.delayed(const Duration(milliseconds: 1300), () {
      if (mounted) _fadeCtrl.forward().whenComplete(widget.onDone);
    });
  }

  @override
  void dispose() {
    _ringCtrl.dispose();
    _fadeCtrl.dispose();
    _streakCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.correct ? _kCorrect : _kWrong;
    final icon  = widget.correct ? Icons.check_circle_rounded : Icons.cancel_rounded;
    final label = widget.correct ? 'Correct!' : 'Wrong!';
    final sub   = widget.correct
        ? (widget.streak >= 3 ? '🔥 ${widget.streak}× Streak!' : 'Well done!')
        : 'Better luck next time';
    final emoji = widget.correct ? '✅' : '❌';

    return Positioned(
      // Centered vertically at 35% — clearly visible, never covers game buttons
      top: MediaQuery.sizeOf(context).height * 0.28,
      left: 24,
      right: 24,
      child: FadeTransition(
        opacity: Tween(begin: 1.0, end: 0.0).animate(
            CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn)),
        // DefaultTextStyle.merge kills the yellow underline Flutter shows in overlays
      child: DefaultTextStyle.merge(
        style: const TextStyle(decoration: TextDecoration.none, decorationColor: Colors.transparent),
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, -0.25), end: Offset.zero)
              .animate(CurvedAnimation(parent: _ringCtrl, curve: Curves.elasticOut)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                decoration: BoxDecoration(
                  // Glass: nearly transparent white with a strong colored border
                  color: Colors.white.withOpacity(0.88),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color, width: 2.2),
                  boxShadow: [
                    BoxShadow(
                        color: color.withOpacity(0.22),
                        blurRadius: 18,
                        spreadRadius: 0,
                        offset: const Offset(0, 4)),
                    const BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 2)),
                  ],
                ),
                child: Row(
                  children: [
                    // Colored icon circle
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        shape: BoxShape.circle,
                        border: Border.all(color: color.withOpacity(0.35), width: 1.5),
                      ),
                      child: Center(child: Icon(icon, color: color, size: 24)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(label,
                              style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                  color: color,
                                  letterSpacing: -0.2,
                                  decoration: TextDecoration.none)),
                          const SizedBox(height: 1),
                          Text(sub,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: color.withOpacity(0.75),
                                  fontWeight: FontWeight.w500,
                                  decoration: TextDecoration.none)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(emoji,
                        style: const TextStyle(fontSize: 24, decoration: TextDecoration.none)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      ),
    );
  }
}

// ── Glowing animated text (for big reveals) ───────────────────
class GlowText extends StatelessWidget {
  final String text;
  final Color color;
  final double fontSize;
  const GlowText(this.text, {super.key, required this.color, this.fontSize = 28});

  @override
  Widget build(BuildContext context) => Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          color: color,
          shadows: [
            Shadow(color: color.withOpacity(0.5), blurRadius: 20),
            Shadow(color: color.withOpacity(0.3), blurRadius: 40),
          ],
        ),
      );
}
