import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme/app_colors.dart';

const _kTourDoneKey = 'onboarding_tour_done_v1';

Future<bool> shouldShowTour() async {
  final prefs = await SharedPreferences.getInstance();
  return !(prefs.getBool(_kTourDoneKey) ?? false);
}

Future<void> markTourDone() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_kTourDoneKey, true);
}

// Call this from StudentDashboard after first build to show the tour overlay.
void maybeShowTour(BuildContext context) async {
  if (!await shouldShowTour()) return;
  if (!context.mounted) return;
  await showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black54,
    builder: (_) => const _TourDialog(),
  );
  await markTourDone();
}

// ── 3-slide coach mark dialog ─────────────────────────────────
class _TourDialog extends StatefulWidget {
  const _TourDialog();

  @override
  State<_TourDialog> createState() => _TourDialogState();
}

class _TourDialogState extends State<_TourDialog> {
  int _page = 0;

  static const _slides = [
    _Slide(
      icon: Icons.science_rounded,
      iconColor: Color(0xFF26A69A),
      title: 'Bio Lab',
      body:
          'Visualise 32+ biological processes — photosynthesis, respiration, cell division and more — with step-by-step animations.',
      hint: 'Find it in the menu → Bio Lab',
    ),
    _Slide(
      icon: Icons.history_edu_rounded,
      iconColor: Color(0xFF5E60CE),
      title: 'PYQ Practice',
      body:
          'Access previous year NEET questions organised by chapter and year. Start a timed practice test with a single tap.',
      hint: 'Find it in the menu → PYQs',
    ),
    _Slide(
      icon: Icons.notifications_rounded,
      iconColor: Color(0xFFFF6B35),
      title: 'Notifications',
      body:
          'Never miss a new exam or result — tap the bell icon in the top bar to see all your notifications.',
      hint: 'Look for the bell 🔔 in the top-right',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_page];
    final isLast = _page == _slides.length - 1;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.neuBackground,
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 40, offset: Offset(0, 12)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Skip',
                    style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textHint,
                        fontWeight: FontWeight.w600)),
              ),
            ),

            // Slide content
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 0),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.08, 0),
                      end: Offset.zero,
                    ).animate(anim),
                    child: child,
                  ),
                ),
                child: _SlideContent(key: ValueKey(_page), slide: slide),
              ),
            ),

            const SizedBox(height: 28),

            // Dot indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_slides.length, (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: i == _page ? 20 : 7,
                height: 7,
                decoration: BoxDecoration(
                  color: i == _page ? AppColors.primary : AppColors.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              )),
            ),

            const SizedBox(height: 20),

            // Action button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (isLast) {
                      Navigator.pop(context);
                    } else {
                      setState(() => _page++);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    isLast ? "Let's go!" : 'Next',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Slide {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String body;
  final String hint;
  const _Slide({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
    required this.hint,
  });
}

class _SlideContent extends StatelessWidget {
  final _Slide slide;
  const _SlideContent({super.key, required this.slide});

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon orb
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: slide.iconColor.withOpacity(0.12),
              shape: BoxShape.circle,
              border: Border.all(color: slide.iconColor.withOpacity(0.3), width: 2),
            ),
            child: Icon(slide.icon, size: 42, color: slide.iconColor),
          )
          .animate()
          .scale(begin: const Offset(0.7, 0.7), duration: 400.ms, curve: Curves.elasticOut),

          const SizedBox(height: 20),

          Text(slide.title,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.3)),

          const SizedBox(height: 10),

          Text(slide.body,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.6)),

          const SizedBox(height: 12),

          // Hint chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: slide.iconColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: slide.iconColor.withOpacity(0.2)),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.arrow_forward_ios_rounded,
                  size: 11, color: slide.iconColor),
              const SizedBox(width: 6),
              Text(slide.hint,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: slide.iconColor)),
            ]),
          ),
        ],
      );
}
