import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../services/haptic_service.dart';

// Call CoinRain.show(context) right after coins are awarded.
// The overlay is non-blocking and auto-removes after ~2.5s.
class CoinRain {
  static void show(BuildContext context, {int coins = 0}) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _CoinRainWidget(
        coins: coins,
        onDone: () => entry.remove(),
      ),
    );
    overlay.insert(entry);
  }
}

class _CoinRainWidget extends StatefulWidget {
  final int coins;
  final VoidCallback onDone;
  const _CoinRainWidget({required this.coins, required this.onDone});

  @override
  State<_CoinRainWidget> createState() => _CoinRainWidgetState();
}

class _CoinRainWidgetState extends State<_CoinRainWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  final _rng = math.Random();
  late List<_Coin> _coins;

  @override
  void initState() {
    super.initState();
    HapticService.celebrate();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2600))
      ..forward().then((_) => widget.onDone());

    _coins = List.generate(28, (i) => _Coin(
      x: _rng.nextDouble(),
      delay: _rng.nextDouble() * 0.4,
      speed: 0.5 + _rng.nextDouble() * 0.5,
      size: 16 + _rng.nextDouble() * 14,
      spin: (_rng.nextBool() ? 1 : -1) * (0.5 + _rng.nextDouble()),
    ));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final t = _ctrl.value;
        final fadeOut = t > 0.75 ? 1.0 - (t - 0.75) / 0.25 : 1.0;

        return DefaultTextStyle.merge(
          style: const TextStyle(decoration: TextDecoration.none, decorationColor: Colors.transparent),
          child: Opacity(
          opacity: fadeOut,
          child: Stack(
            children: [
              // Label banner
              Positioned(
                top: size.height * 0.32,
                left: 0, right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFC107),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 16, offset: Offset(0, 6)),
                      ],
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Text('🪙', style: TextStyle(fontSize: 22)),
                      const SizedBox(width: 8),
                      Text(
                        widget.coins > 0 ? '+${widget.coins} PrepCoins!' : 'Coins Earned!',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF5D4037),
                        ),
                      ),
                    ]),
                  ),
                ),
              ),

              // Falling coins
              ..._coins.map((c) {
                final progress = ((t - c.delay) / c.speed).clamp(0.0, 1.0);
                if (progress <= 0) return const SizedBox.shrink();
                final y = -0.05 + progress * 1.1;
                final wobble = math.sin(progress * math.pi * 4 + c.x * 10) * 0.03;
                return Positioned(
                  left: (c.x + wobble) * size.width - c.size / 2,
                  top: y * size.height,
                  child: Transform.rotate(
                    angle: progress * c.spin * math.pi * 4,
                    child: Text(
                      '🪙',
                      style: TextStyle(fontSize: c.size),
                    ),
                  ),
                );
              }),
            ],
          ),
        ));  // closes Opacity + DefaultTextStyle.merge
      },
    );
  }
}

class _Coin {
  final double x;
  final double delay;
  final double speed;
  final double size;
  final double spin;

  const _Coin({
    required this.x,
    required this.delay,
    required this.speed,
    required this.size,
    required this.spin,
  });
}
