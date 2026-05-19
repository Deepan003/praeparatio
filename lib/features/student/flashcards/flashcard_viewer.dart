import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flip_card/flip_card.dart';
import '../../../core/constants/flashcard_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/flashcard_model.dart';

class FlashcardViewer extends StatefulWidget {
  final String chapter;
  const FlashcardViewer({super.key, required this.chapter});

  @override
  State<FlashcardViewer> createState() => _FlashcardViewerState();
}

class _FlashcardViewerState extends State<FlashcardViewer> {
  late List<FlashcardModel> _cards;
  int _current = 0;
  int _known = 0;
  int _review = 0;
  bool _isFlipped = false;
  final GlobalKey<FlipCardState> _flipKey = GlobalKey<FlipCardState>();

  @override
  void initState() {
    super.initState();
    _cards = FlashcardData.all
        .where((f) => f.chapter == widget.chapter)
        .toList()
      ..shuffle();
  }

  void _next() {
    if (_current < _cards.length - 1) {
      setState(() {
        _current++;
        _isFlipped = false;
      });
      if (_isFlipped) _flipKey.currentState?.toggleCard();
    }
  }

  void _prev() {
    if (_current > 0) {
      setState(() {
        _current--;
        _isFlipped = false;
      });
      if (_isFlipped) _flipKey.currentState?.toggleCard();
    }
  }

  void _markKnown() {
    HapticFeedback.lightImpact();
    setState(() => _known++);
    _next();
  }

  void _markReview() {
    HapticFeedback.mediumImpact();
    setState(() => _review++);
    _next();
  }

  @override
  Widget build(BuildContext context) {
    if (_cards.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.chapter)),
        body: const Center(child: Text('No flashcards for this chapter.')),
      );
    }

    final card = _cards[_current];
    final progress = (_current + 1) / _cards.length;

    return Scaffold(
      backgroundColor: AppColors.neuBackground,
      appBar: AppBar(
        title: Text(widget.chapter,
            style: const TextStyle(fontSize: 15)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.border,
            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            minHeight: 4,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(MediaQuery.sizeOf(context).width < 400 ? 16 : 24),
          child: Column(
            children: [
              // Progress text
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${_current + 1} / ${_cards.length}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary)),
                  Row(
                    children: [
                      const Icon(Icons.check_circle_outline,
                          color: AppColors.success, size: 16),
                      const SizedBox(width: 4),
                      Text('$_known',
                          style: const TextStyle(
                              color: AppColors.success,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(width: 14),
                      const Icon(Icons.replay_outlined,
                          color: AppColors.warning, size: 16),
                      const SizedBox(width: 4),
                      Text('$_review',
                          style: const TextStyle(
                              color: AppColors.warning,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Flip card
              Expanded(
                child: FlipCard(
                  key: _flipKey,
                  onFlip: () => setState(() => _isFlipped = !_isFlipped),
                  front: _CardFace(
                    text: card.front,
                    label: 'QUESTION',
                    color: AppColors.primary,
                    isBack: false,
                  ),
                  back: _CardFace(
                    text: card.back,
                    label: 'ANSWER',
                    color: AppColors.success,
                    isBack: true,
                  ),
                ).animate().fadeIn(duration: 200.ms),
              ),

              const SizedBox(height: 8),
              Text(
                _isFlipped ? 'Tap card to go back' : 'Tap card to reveal answer',
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textHint),
              ),
              const SizedBox(height: 20),

              // Action buttons (shown after flip)
              if (_isFlipped) ...[
                Row(
                  children: [
                    Expanded(
                      child: _ActionBtn(
                        label: 'Review Again',
                        icon: Icons.replay_outlined,
                        color: AppColors.warning,
                        onTap: _markReview,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ActionBtn(
                        label: 'Got It!',
                        icon: Icons.check_circle_outline,
                        color: AppColors.success,
                        onTap: _markKnown,
                      ),
                    ),
                  ],
                ).animate().slideY(begin: 0.3, duration: 200.ms).fadeIn(),
                const SizedBox(height: 12),
              ],

              // Navigation
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_rounded),
                    onPressed: _current > 0 ? _prev : null,
                    color: _current > 0 ? AppColors.primary : AppColors.border,
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios_rounded),
                    onPressed: _current < _cards.length - 1 ? _next : null,
                    color: _current < _cards.length - 1
                        ? AppColors.primary
                        : AppColors.border,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardFace extends StatelessWidget {
  final String text;
  final String label;
  final Color color;
  final bool isBack;

  const _CardFace({
    required this.text,
    required this.label,
    required this.color,
    required this.isBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.neuSurface, color.withOpacity(0.06)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.25), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                label,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: color,
                    letterSpacing: 1.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: isBack ? 14 : 17,
                  fontWeight:
                      isBack ? FontWeight.w400 : FontWeight.w700,
                  height: 1.65,
                  color: AppColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                  fontWeight: FontWeight.w700, color: color, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
