import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/developer_info_model.dart';

// ── Entry point ────────────────────────────────────────────────────────────────
void showDeveloperModal(BuildContext context, DeveloperInfoModel devInfo) {
  HapticFeedback.mediumImpact();
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Developer',
    barrierColor: Colors.black.withOpacity(0.75),
    transitionDuration: const Duration(milliseconds: 450),
    pageBuilder: (ctx, anim1, anim2) => _DevModal(devInfo: devInfo),
    transitionBuilder: (ctx, anim1, anim2, child) {
      final curved = CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: anim1,
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
              .animate(curved),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.94, end: 1.0).animate(curved),
            child: child,
          ),
        ),
      );
    },
  );
}

// ── Modal shell ────────────────────────────────────────────────────────────────
class _DevModal extends StatefulWidget {
  final DeveloperInfoModel devInfo;
  const _DevModal({required this.devInfo});

  @override
  State<_DevModal> createState() => _DevModalState();
}

class _DevModalState extends State<_DevModal> with TickerProviderStateMixin {
  bool _booted = false;
  late AnimationController _glowCtrl;
  late AnimationController _particleCtrl;
  late AnimationController _rainbowCtrl;

  @override
  void initState() {
    super.initState();
    _glowCtrl     = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
    _particleCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat();
    _rainbowCtrl  = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) setState(() => _booted = true);
    });
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    _particleCtrl.dispose();
    _rainbowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Center(
      child: Material(
        color: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(
          constraints: BoxConstraints(maxWidth: 420, maxHeight: size.height * 0.88),
          width: size.width * 0.9,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withOpacity(0.22), width: 1.2),
            boxShadow: [
              BoxShadow(color: AppColors.primary.withOpacity(0.28), blurRadius: 70, spreadRadius: 6),
              BoxShadow(color: Colors.black.withOpacity(0.35), blurRadius: 30),
            ],
            // Truly frosted — white-tinted transparent glass, not black
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.22),
                Colors.white.withOpacity(0.10),
                Colors.white.withOpacity(0.06),
              ],
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(children: [
              // Floating code particles behind content
              Positioned.fill(child: _CodeParticles(ctrl: _particleCtrl)),
              // Glass shine: bright edge highlight at top-left
              Positioned(
                top: 0, left: 0, right: 0,
                child: Container(
                  height: 1.5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.white.withOpacity(0.45),
                        Colors.white.withOpacity(0.55),
                        Colors.white.withOpacity(0.25),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
                    ),
                  ),
                ),
              ),
              // Glass shine: soft diagonal glare in upper-left corner
              Positioned(
                top: 0, left: 0,
                child: Container(
                  width: 180, height: 90,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.topLeft,
                      radius: 1.0,
                      colors: [
                        Colors.white.withOpacity(0.12),
                        Colors.transparent,
                      ],
                    ),
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(28)),
                  ),
                ),
              ),
              // Main content
              Column(mainAxisSize: MainAxisSize.min, children: [
                _TerminalTitleBar(onClose: () => Navigator.pop(context)),
                Flexible(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        transitionBuilder: (child, anim) => FadeTransition(
                          opacity: anim,
                          child: SlideTransition(
                            position: Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
                                .animate(anim),
                            child: child,
                          ),
                        ),
                        child: _booted
                            ? _DevProfile(key: const ValueKey('profile'), devInfo: widget.devInfo, glowCtrl: _glowCtrl, rainbowCtrl: _rainbowCtrl)
                            : const _BootSequence(key: ValueKey('boot')),
                      ),
                    ),
                  ),
                ),
              ]),
            ]),
          ),
        ),
          ),
        ),
      ),
    );
  }
}

// ── Title bar ─────────────────────────────────────────────────────────────────
class _TerminalTitleBar extends StatelessWidget {
  final VoidCallback onClose;
  const _TerminalTitleBar({required this.onClose});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(18, 10, 8, 10),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.08))),
        ),
        child: Row(children: [
          Icon(Icons.terminal_rounded, color: Colors.white.withOpacity(0.4), size: 14),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'developer@praeparatio: ~/profile',
              style: TextStyle(
                color: Colors.white.withOpacity(0.35),
                fontSize: 11,
                fontFamily: 'monospace',
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: onClose,
            child: Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.close_rounded, color: Colors.white.withOpacity(0.4), size: 14),
            ),
          ),
        ]),
      );
}

// ── Boot sequence animation ────────────────────────────────────────────────────
class _BootSequence extends StatefulWidget {
  const _BootSequence({super.key});

  @override
  State<_BootSequence> createState() => _BootSequenceState();
}

class _BootSequenceState extends State<_BootSequence> {
  static const _lines = [
    ('Initializing developer profile...', Colors.white70),
    ('Loading credentials...', Colors.white70),
    ('Compiling identity modules...', Colors.white70),
    ('Verifying cryptographic signature...', Colors.white70),
    ('Establishing secure tunnel...', Colors.white70),
    ('ACCESS GRANTED ✓', Color(0xFF39D353)),
  ];

  int _visible = 0;

  @override
  void initState() {
    super.initState();
    _showNext();
  }

  void _showNext() {
    if (_visible >= _lines.length) return;
    Future.delayed(Duration(milliseconds: 220 + _visible * 260), () {
      if (mounted) {
        setState(() => _visible++);
        _showNext();
      }
    });
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: _PulsingCodeIcon(),
            ),
            const SizedBox(height: 24),
            ..._lines.take(_visible).indexed.map((e) {
              final (i, line) = e;
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Text('> ', style: TextStyle(color: AppColors.primary.withOpacity(0.9), fontSize: 12, fontFamily: 'monospace', fontWeight: FontWeight.w700)),
                    Expanded(
                      child: Text(
                        line.$1,
                        style: TextStyle(color: line.$2, fontSize: 12, fontFamily: 'monospace'),
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.03),
              );
            }),
            if (_visible > 0 && _visible < _lines.length)
              const _BlinkingCursor(),
          ],
        ),
      );
}

class _PulsingCodeIcon extends StatelessWidget {
  const _PulsingCodeIcon();

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 72,
        height: 72,
        child: Stack(alignment: Alignment.center, children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1.5),
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true))
           .scale(begin: const Offset(0.85, 0.85), end: const Offset(1.15, 1.15), duration: 1200.ms, curve: Curves.easeInOutSine)
           .fadeIn(begin: 0.2),
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.accent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.5), blurRadius: 16)],
            ),
            child: const Center(child: Icon(Icons.code_rounded, color: Colors.white, size: 26)),
          ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 2000.ms, color: Colors.white.withOpacity(0.3)),
        ]),
      );
}

class _BlinkingCursor extends StatelessWidget {
  const _BlinkingCursor();

  @override
  Widget build(BuildContext context) => const Text(
        '▋',
        style: TextStyle(color: Color(0xFF39D353), fontSize: 12, fontFamily: 'monospace'),
      ).animate(onPlay: (c) => c.repeat(reverse: true)).fadeIn(duration: 500.ms);
}

// ── Developer profile card ─────────────────────────────────────────────────────
class _DevProfile extends StatelessWidget {
  final DeveloperInfoModel devInfo;
  final AnimationController glowCtrl;
  final AnimationController rainbowCtrl;
  const _DevProfile({super.key, required this.devInfo, required this.glowCtrl, required this.rainbowCtrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),
        // Avatar with glow
        AnimatedBuilder(
          animation: glowCtrl,
          builder: (_, child) => Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.15 + 0.2 * glowCtrl.value),
                  blurRadius: 24 + 20 * glowCtrl.value,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: child,
          ),
          child: devInfo.showAvatar
              ? _TiltAvatar(url: devInfo.avatarUrl)
              : _DefaultAvatar(),
        ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack).fadeIn(duration: 400.ms),

        const SizedBox(height: 20),

        // "DEVELOPED BY" label — brighter on transparent glass
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.25),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.primary.withOpacity(0.55)),
          ),
          child: const Text(
            '< DEVELOPED BY />',
            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 2, fontFamily: 'monospace'),
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 100.ms),

        const SizedBox(height: 12),

        // Name as a bordered unit — rainbow travels around the perimeter
        AnimatedBuilder(
          animation: rainbowCtrl,
          builder: (_, child) => CustomPaint(
            painter: _TravelingBorderPainter(rainbowCtrl.value),
            child: child,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            child: Text(
              devInfo.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -0.3,
                height: 1.1,
                shadows: [Shadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, 2))],
              ),
            ),
          ),
        ).animate().fadeIn(duration: 500.ms, delay: 150.ms).slideY(begin: 0.12),

        const SizedBox(height: 10),

        // Role line — brighter
        Text(
          'Flutter Developer · NEET EdTech',
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.75),
            fontFamily: 'monospace',
            fontWeight: FontWeight.w600,
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 300.ms),

        const SizedBox(height: 24),

        // Divider — brighter
        Row(children: [
          Expanded(child: Container(height: 1, color: Colors.white.withOpacity(0.18))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text('// connect', style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.5), fontFamily: 'monospace', fontWeight: FontWeight.w600)),
          ),
          Expanded(child: Container(height: 1, color: Colors.white.withOpacity(0.18))),
        ]).animate().fadeIn(duration: 400.ms, delay: 350.ms),

        const SizedBox(height: 18),

        // Social links
        if (devInfo.links.isNotEmpty)
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: devInfo.links.indexed.map((e) {
              final (i, link) = e;
              return _SocialChip(link: link, delay: 400 + i * 80);
            }).toList(),
          )
        else
          Text(
            '// no links configured',
            style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.4), fontFamily: 'monospace'),
          ),

        const SizedBox(height: 20),
      ],
    );
  }
}

class _DefaultAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        width: 110,
        height: 110,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.accent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: const Color(0xFF30363D), width: 3),
        ),
        child: const Center(child: Icon(Icons.code_rounded, color: Colors.white, size: 44)),
      );
}

// ── Tilting avatar with 3D parallax ───────────────────────────────────────────
class _TiltAvatar extends StatefulWidget {
  final String? url;
  const _TiltAvatar({required this.url});

  @override
  State<_TiltAvatar> createState() => _TiltAvatarState();
}

class _TiltAvatarState extends State<_TiltAvatar> {
  Offset _pos = const Offset(55, 55);
  static const _size = 110.0;

  @override
  Widget build(BuildContext context) => MouseRegion(
        onHover: (e) => setState(() => _pos = e.localPosition),
        onExit: (_) => setState(() => _pos = const Offset(55, 55)),
        child: GestureDetector(
          onPanUpdate: (d) => setState(() => _pos = d.localPosition),
          onPanEnd: (_) => setState(() => _pos = const Offset(55, 55)),
          child: TweenAnimationBuilder<Offset>(
            tween: Tween(begin: const Offset(55, 55), end: _pos),
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            builder: (_, pos, child) {
              final x = (pos.dx - 55) / 55;
              final y = (pos.dy - 55) / 55;
              return Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateX(-y * 0.25)
                  ..rotateY(x * 0.25),
                alignment: Alignment.center,
                child: Container(
                  width: _size,
                  height: _size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary.withOpacity(0.6), width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 20,
                        offset: Offset(-x * 12, -y * 12),
                      ),
                    ],
                    image: (widget.url != null && widget.url!.isNotEmpty)
                        ? DecorationImage(image: NetworkImage(widget.url!), fit: BoxFit.cover)
                        : null,
                    gradient: (widget.url == null || widget.url!.isEmpty)
                        ? const LinearGradient(colors: [AppColors.primary, AppColors.accent], begin: Alignment.topLeft, end: Alignment.bottomRight)
                        : null,
                  ),
                  child: (widget.url == null || widget.url!.isEmpty)
                      ? const Center(child: Icon(Icons.person_rounded, color: Colors.white, size: 42))
                      : null,
                ),
              );
            },
          ),
        ),
      );
}

// ── Social chip button ─────────────────────────────────────────────────────────
class _SocialChip extends StatefulWidget {
  final DeveloperLink link;
  final int delay;
  const _SocialChip({required this.link, required this.delay});

  @override
  State<_SocialChip> createState() => _SocialChipState();
}

class _SocialChipState extends State<_SocialChip> {
  bool _hovered = false;

  (IconData, Color, String) get _meta {
    final p = widget.link.platform.toLowerCase();
    if (p == 'github')   return (Icons.code_rounded,             const Color(0xFF58A6FF), 'GitHub');
    if (p == 'linkedin') return (Icons.business_center_rounded,  const Color(0xFF0A66C2), 'LinkedIn');
    if (p == 'discord')  return (Icons.chat_bubble_rounded,      const Color(0xFF7289DA), 'Discord');
    if (p == 'twitter')  return (Icons.alternate_email_rounded,  const Color(0xFF1DA1F2), 'Twitter');
    if (p == 'mail')     return (Icons.email_rounded,            const Color(0xFFEA4335), 'Email');
    if (p == 'website')  return (Icons.language_rounded,         const Color(0xFF56D364), 'Website');
    return (Icons.link_rounded, AppColors.primary, widget.link.platform);
  }

  @override
  Widget build(BuildContext context) {
    final (icon, color, label) = _meta;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () async {
          HapticFeedback.lightImpact();
          final uri = Uri.parse(widget.link.url);
          if (await canLaunchUrl(uri)) launchUrl(uri, mode: LaunchMode.externalApplication);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: _hovered ? color.withOpacity(0.18) : Colors.white.withOpacity(0.10),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _hovered ? color.withOpacity(0.7) : Colors.white.withOpacity(0.25),
            ),
            boxShadow: _hovered ? [BoxShadow(color: color.withOpacity(0.2), blurRadius: 12)] : null,
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text('> ', style: TextStyle(color: _hovered ? color : Colors.white.withOpacity(0.5), fontSize: 11, fontFamily: 'monospace', fontWeight: FontWeight.w700)),
            Icon(icon, size: 15, color: _hovered ? color : Colors.white.withOpacity(0.8)),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _hovered ? color : Colors.white.withOpacity(0.8), fontFamily: 'monospace')),
          ]),
        ),
      ),
    ).animate(delay: widget.delay.ms).fadeIn(duration: 350.ms).slideY(begin: 0.15, curve: Curves.easeOut);
  }
}

// ── Rainbow border that travels around the name container perimeter ────────────
class _TravelingBorderPainter extends CustomPainter {
  final double t; // 0→1, continuously repeating
  _TravelingBorderPainter(this.t);

  static const _colors = [
    Color(0xFF6366F1), // indigo
    Color(0xFF8B5CF6), // violet
    Color(0xFFEC4899), // pink
    Color(0xFFEF4444), // red
    Color(0xFFF97316), // orange
    Color(0xFFEAB308), // yellow
    Color(0xFF22C55E), // green
    Color(0xFF06B6D4), // cyan
    Color(0xFF3B82F6), // blue
    Color(0xFF6366F1), // back to indigo — seamless loop
  ];

  static const _radius = 16.0;
  static const _strokeWidth = 2.5;
  static const _glowWidth = 9.0;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final inner = rect.deflate(_strokeWidth / 2);
    final rRect = RRect.fromRectXY(inner, _radius, _radius);

    // Rotating SweepGradient: as t goes 0→1, gradient rotates 360°
    // This makes ALL colors appear to travel continuously around the border
    final shader = SweepGradient(
      colors: _colors,
      transform: GradientRotation(t * 2 * math.pi),
    ).createShader(rect);

    // Outer glow for depth
    canvas.drawRRect(
      rRect,
      Paint()
        ..shader = shader
        ..style = PaintingStyle.stroke
        ..strokeWidth = _glowWidth
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );

    // Sharp bright stroke on top
    canvas.drawRRect(
      rRect,
      Paint()
        ..shader = shader
        ..style = PaintingStyle.stroke
        ..strokeWidth = _strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_TravelingBorderPainter old) => old.t != t;
}

// ── Floating code particles background ────────────────────────────────────────
class _CodeParticles extends StatelessWidget {
  final AnimationController ctrl;
  const _CodeParticles({required this.ctrl});

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: ctrl,
        builder: (_, __) => CustomPaint(
          painter: _ParticlesPainter(ctrl.value),
        ),
      );
}

class _ParticlesPainter extends CustomPainter {
  final double t;
  _ParticlesPainter(this.t);

  static const _chars = ['0', '1', '{', '}', '<', '>', '/', ';', '(', ')', '=', '+'];
  static final _rng = math.Random(42);
  static final _particles = List.generate(22, (i) => (
    x: _rng.nextDouble(),
    y: _rng.nextDouble(),
    speed: 0.03 + _rng.nextDouble() * 0.06,
    char: _chars[_rng.nextInt(_chars.length)],
    size: 8.0 + _rng.nextDouble() * 6,
    opacity: 0.04 + _rng.nextDouble() * 0.07,
  ));

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in _particles) {
      final y = (p.y + t * p.speed) % 1.0;
      final tp = TextPainter(
        text: TextSpan(
          text: p.char,
          style: TextStyle(
            color: const Color(0xFF39D353).withOpacity(p.opacity),
            fontSize: p.size,
            fontFamily: 'monospace',
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(p.x * size.width, y * size.height));
    }
  }

  @override
  bool shouldRepaint(_ParticlesPainter old) => old.t != t;
}
