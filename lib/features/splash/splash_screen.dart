import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/animated_logo.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800))
      ..forward();

    // 3.5s minimum — lets all letter + tagline animations complete before navigating
    Future.delayed(const Duration(milliseconds: 3500), () async {
      if (!mounted) return;
      // Poll until auth is no longer loading (session restore completes)
      var auth = ref.read(authProvider);
      while (auth.isLoading) {
        await Future.delayed(const Duration(milliseconds: 80));
        if (!mounted) return;
        auth = ref.read(authProvider);
      }
      if (!mounted) return;
      final user = auth.value;
      if (user != null) {
        context.go(user.isAdmin ? Routes.adminDashboard : Routes.studentDashboard);
      } else {
        context.go(Routes.login);
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final logoSize = size.width < 400 ? 140.0 : 170.0;

    return Scaffold(
      // Neumorphic background — single colour, depth through shadows
      backgroundColor: AppColors.neuBackground,
      body: Stack(
        children: [
          // Subtle large recessed circle — neu style decorative element
          Positioned(
            top: -size.height * 0.15,
            left: -size.width * 0.2,
            child: Container(
              width: size.width * 0.9,
              height: size.width * 0.9,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  const BoxShadow(
                    color: AppColors.neuShadowLight,
                    offset: Offset(-10, -10),
                    blurRadius: 30,
                  ),
                  BoxShadow(
                    color: AppColors.neuShadowDark.withOpacity(0.4),
                    offset: const Offset(10, 10),
                    blurRadius: 30,
                  ),
                ],
                color: AppColors.neuBackground,
              ),
            ),
          ),

          Positioned(
            bottom: -size.height * 0.15,
            right: -size.width * 0.2,
            child: Container(
              width: size.width * 0.7,
              height: size.width * 0.7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.neuBackground,
                boxShadow: [
                  const BoxShadow(
                    color: AppColors.neuShadowLight,
                    offset: Offset(-8, -8),
                    blurRadius: 24,
                  ),
                  BoxShadow(
                    color: AppColors.neuShadowDark.withOpacity(0.35),
                    offset: const Offset(8, 8),
                    blurRadius: 24,
                  ),
                ],
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── 3-D Bio Logo ──
                    // Wrap logo in a raised neumorphic circle
                    Container(
                      width: logoSize + 40,
                      height: logoSize + 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.neuSurface,
                        boxShadow: AppColors.neuRaisedStrong,
                      ),
                      child: Center(
                        child: AnimatedLogo(
                          size: logoSize,
                          interactive: true,
                          autoRotate: true,
                        ),
                      ),
                    )
                        .animate()
                        .scale(
                          begin: const Offset(0.4, 0.4),
                          duration: 900.ms,
                          curve: Curves.elasticOut,
                        )
                        .fadeIn(duration: 500.ms),

                    const SizedBox(height: 36),

                    // ── App name + tagline (all self-animated, staggered) ──
                    _NeuTitle(),

                    const SizedBox(height: 48),

                    // ── Neumorphic dot loader ──
                    _NeuDotLoader()
                        .animate(delay: 1900.ms)
                        .fadeIn(duration: 400.ms),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Title block with staggered letter animation ───────────────
class _NeuTitle extends StatelessWidget {
  static const _letters = ['P','R','A','E','P','A','R','A','T','I','O'];
  static const _taglineWords = ['Examination','is','nothing','but','fine','preparation.'];

  @override
  Widget build(BuildContext context) {
    // Last letter lands at: 80 + 10 * 90 = 980ms. Tagline starts after that.
    const lettersEndMs = 980;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Each letter drops in with a generous stagger — professional, unhurried
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(_letters.length, (i) {
            return Text(
              _letters[i],
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: AppColors.primary.withOpacity(
                    0.65 + 0.35 * (1.0 - (i - 5).abs() / 5.0).clamp(0.0, 1.0)),
                letterSpacing: 3,
              ),
            )
            .animate(delay: (80 + i * 90).ms)          // 90ms stagger — slower, cinematic
            .fadeIn(duration: 380.ms)
            .slideY(begin: -0.5, end: 0, duration: 420.ms, curve: Curves.easeOutCubic)
            .scale(begin: const Offset(0.75, 0.75), end: const Offset(1.0, 1.0),
                   duration: 480.ms, curve: Curves.elasticOut);
          }),
        ),

        const SizedBox(height: 8),

        // Subtitle: 'NEET Biology Platform' — clean fade after letters
        const Text(
          'NEET Biology Platform',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
            letterSpacing: 2.2,
          ),
        )
        .animate(delay: (lettersEndMs + 80).ms)
        .fadeIn(duration: 600.ms),

        const SizedBox(height: 20),

        // Tagline — word-by-word cinematic reveal
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 5,
          runSpacing: 2,
          children: List.generate(_taglineWords.length, (i) {
            final isLast = i == _taglineWords.length - 1;
            return Text(
              _taglineWords[i],
              style: TextStyle(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                fontWeight: isLast ? FontWeight.w700 : FontWeight.w400,
                color: isLast
                    ? AppColors.primary.withOpacity(0.85)
                    : AppColors.textSecondary.withOpacity(0.8),
                height: 1.5,
              ),
            )
            .animate(delay: (lettersEndMs + 300 + i * 110).ms)
            .fadeIn(duration: 500.ms)
            .slideY(begin: 0.25, end: 0, duration: 450.ms, curve: Curves.easeOutCubic)
            .blur(begin: const Offset(0, 3), end: Offset.zero, duration: 450.ms);
          }),
        ),
      ],
    );
  }
}

// ── Minimal 3-dot pulse loader ────────────────────────────────
class _NeuDotLoader extends StatefulWidget {
  @override
  State<_NeuDotLoader> createState() => _NeuDotLoaderState();
}

class _NeuDotLoaderState extends State<_NeuDotLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1100))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          final phase = (i / 3);
          final t = ((_ctrl.value - phase + 1) % 1);
          final wave = math.sin(t * math.pi);
          final dotSize = 7.0 + wave * 4.0;
          final opacity = 0.3 + wave * 0.7;

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: dotSize,
            height: dotSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(opacity),
            ),
          );
        }),
      ),
    );
  }
}
