part of 'bio_diagram_painter.dart';

// ─── shared palette ───────────────────────────────────────────────────────────
const _kRepro  = Color(0xFFE91E8C);
const _kMol    = Color(0xFF3F51B5);
const _kBio    = Color(0xFF607D8B);
const _kPhoto  = Color(0xFF4CAF50);
const _kResp   = Color(0xFFFF5722);
const _kPlant  = Color(0xFF795548);
const _kExcr   = Color(0xFF0097A7);
const _kNeuro  = Color(0xFF9C27B0);
const _kGray   = Color(0xFF9E9E9E);
const _kBg     = Color(0xFFF8FAFB);

// ─────────────────────────────────────────────────────────────────────────────
// 1. MEGASPOROGENESIS
// ─────────────────────────────────────────────────────────────────────────────
class _MegasporogenesisPainter extends CustomPainter {
  final int step; final double t;
  _MegasporogenesisPainter(this.step, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), _fill(_kBg));
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);

    // Ovule shell
    final ow = size.width * 0.22, oh = size.height * 0.42;
    final ovuleRect = Rect.fromCenter(center: Offset.zero, width: ow * 2, height: oh * 2);
    canvas.drawOval(ovuleRect, _fill(const Color(0xFFFFF9C4)));
    canvas.drawOval(ovuleRect, _stroke(_kPlant, w: 2));
    _label(canvas, 'Micropyle', Offset(0, oh + 13), fs: 8.5, c: _kPlant);
    _label(canvas, 'Chalaza', Offset(0, -oh - 12), fs: 8.5, c: _kPlant);

    final double pulse = math.sin(t * 2 * math.pi) * 3;

    switch (step) {
      case 0:
        _drawCell(canvas, Offset(0, oh * 0.1), ow * 0.7, oh * 0.6, _kRepro.withOpacity(0.3), _kRepro);
        canvas.drawCircle(Offset(0, oh * 0.1), ow * 0.22, _fill(_kRepro.withOpacity(0.55)));
        _label(canvas, 'MMC (2n)', Offset(0, oh * 0.6), fs: 8.5, bold: true, c: _kRepro);
      case 1:
        for (int i = 0; i < 2; i++) {
          final dy = (i == 0 ? -1 : 1) * oh * 0.25;
          _drawCell(canvas, Offset(0, dy), ow * 0.6, oh * 0.25, _kRepro.withOpacity(0.25), _kRepro);
        }
        _label(canvas, 'Dyad\n(n+n)', Offset(0, oh * 0.6), fs: 8.5, bold: true, c: _kRepro);
      case 2:
        for (int i = 0; i < 4; i++) {
          final dy = -oh * 0.38 + i * oh * 0.25;
          _drawCell(canvas, Offset(0, dy), ow * 0.55, oh * 0.19, _kRepro.withOpacity(0.2), _kRepro);
        }
        _label(canvas, 'Linear Tetrad (n)', Offset(0, oh * 0.6), fs: 8, bold: true, c: _kRepro);
      case 3:
        for (int i = 0; i < 4; i++) {
          final dy = -oh * 0.38 + i * oh * 0.25;
          final deg = i < 3;
          _drawCell(canvas, Offset(0, dy), ow * 0.55, oh * 0.19,
              (deg ? _kGray : _kPhoto).withOpacity(0.3),
              deg ? _kGray : _kPhoto, w: deg ? 1.2 : 2.0);
        }
        _label(canvas, 'Functional Megaspore', Offset(0, -oh * 0.6), fs: 8, bold: true, c: _kPhoto);
        _label(canvas, '3 Degenerate', Offset(0, oh * 0.6), fs: 8, c: _kGray);
      case 4:
        _drawCell(canvas, const Offset(0, 0), ow * 0.68, oh * 0.5 + pulse, _kPhoto.withOpacity(0.18), _kPhoto, w: 2);
        canvas.drawCircle(Offset(0, -oh * 0.14), ow * 0.18, _fill(_kPhoto.withOpacity(0.5)));
        canvas.drawCircle(Offset(0, oh * 0.14), ow * 0.18, _fill(_kPhoto.withOpacity(0.5)));
        _label(canvas, '2 Nuclei (Mitosis ×1)', Offset(0, oh * 0.6), fs: 8, bold: true, c: _kPhoto);
      case 5:
        _drawCell(canvas, const Offset(0, 0), ow * 0.72, oh * 0.62, _kPhoto.withOpacity(0.14), _kPhoto, w: 2);
        for (final p in [Offset(-ow*0.22,-oh*0.2), Offset(ow*0.22,-oh*0.2), Offset(-ow*0.22,oh*0.2), Offset(ow*0.22,oh*0.2)]) {
          canvas.drawCircle(p, ow * 0.15, _fill(_kPhoto.withOpacity(0.5)));
        }
        _label(canvas, '4 Nuclei', Offset(0, oh * 0.65), fs: 8.5, bold: true, c: _kPhoto);
      case 6:
        _drawCell(canvas, const Offset(0, 0), ow * 0.78, oh * 0.72, _kPhoto.withOpacity(0.1), _kPhoto, w: 2);
        for (int i = 0; i < 8; i++) {
          final row = i ~/ 2, col = i % 2;
          final dx = (col == 0 ? -1 : 1) * ow * 0.2;
          final dy = -oh * 0.28 + row * oh * 0.18;
          canvas.drawCircle(Offset(dx, dy), ow * 0.13, _fill(_kPhoto.withOpacity(0.5)));
        }
        _label(canvas, '8 Nuclei', Offset(0, oh * 0.65), fs: 8.5, bold: true, c: _kPhoto);
      default:
        _drawCell(canvas, const Offset(0, 0), ow * 0.82, oh * 0.78, _kPhoto.withOpacity(0.08), _kPhoto, w: 2);
        // Egg cell
        canvas.drawCircle(Offset(0, oh * 0.3), ow * 0.2, _fill(_kRepro.withOpacity(0.55)));
        _label(canvas, 'Egg (n)', Offset(ow * 0.45, oh * 0.3), fs: 8, bold: true, c: _kRepro);
        // Synergids
        canvas.drawCircle(Offset(-ow*0.28, oh*0.14), ow*0.13, _fill(const Color(0xFFFF9800).withOpacity(0.55)));
        canvas.drawCircle(Offset(ow*0.28, oh*0.14), ow*0.13, _fill(const Color(0xFFFF9800).withOpacity(0.55)));
        _label(canvas, 'Synergids', Offset(0, oh * 0.08), fs: 7.5, c: const Color(0xFFE65100));
        // Polar nuclei
        canvas.drawCircle(Offset(-ow*0.15, -oh*0.05), ow*0.13, _fill(const Color(0xFF1565C0).withOpacity(0.5)));
        canvas.drawCircle(Offset(ow*0.15, -oh*0.05), ow*0.13, _fill(const Color(0xFF1565C0).withOpacity(0.5)));
        _label(canvas, 'Polar nuclei', Offset(0, -oh*0.18), fs: 7.5, c: const Color(0xFF1565C0));
        // Antipodals
        for (int i = 0; i < 3; i++) {
          canvas.drawCircle(Offset(-ow*0.22 + i*ow*0.22, -oh*0.48), ow*0.12, _fill(_kNeuro.withOpacity(0.5)));
        }
        _label(canvas, 'Antipodals', Offset(0, -oh*0.6), fs: 7.5, c: _kNeuro);
        _label(canvas, '7-celled Embryo Sac', Offset(0, oh + 13), fs: 8.5, bold: true, c: _kPhoto);
    }
    canvas.restore();
  }

  void _drawCell(Canvas canvas, Offset c, double rx, double ry, Color fill, Color stroke, {double w = 1.5}) {
    final r = Rect.fromCenter(center: c, width: rx * 2, height: ry * 2);
    canvas.drawOval(r, _fill(fill));
    canvas.drawOval(r, _stroke(stroke, w: w));
  }

  @override
  bool shouldRepaint(_MegasporogenesisPainter o) => o.step != step || o.t != t;
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. DOUBLE FERTILIZATION
// ─────────────────────────────────────────────────────────────────────────────
class _DoubleFertilizationPainter extends CustomPainter {
  final int step; final double t;
  _DoubleFertilizationPainter(this.step, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), _fill(_kBg));
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);

    final w = size.width, h = size.height;
    // Embryo sac (right half)
    final sacX = w * 0.1, sacW = w * 0.35, sacH = h * 0.7;
    final sacRect = Rect.fromCenter(center: Offset(sacX, 0), width: sacW, height: sacH);
    canvas.drawOval(sacRect, _fill(const Color(0xFFFCE4EC)));
    canvas.drawOval(sacRect, _stroke(_kRepro, w: 2));
    _label(canvas, 'Embryo Sac', Offset(sacX, -sacH * 0.42 - 12), fs: 8.5, bold: true, c: _kRepro);

    // Egg cell + synergids (micropyle end = bottom)
    canvas.drawCircle(Offset(sacX, sacH * 0.25), w * 0.06, _fill(_kRepro.withOpacity(0.7)));
    _label(canvas, 'Egg (n)', Offset(sacX, sacH * 0.38), fs: 8, bold: true, c: _kRepro);
    canvas.drawCircle(Offset(sacX - w*0.055, sacH*0.1), w*0.035, _fill(_kRepro.withOpacity(0.4)));
    canvas.drawCircle(Offset(sacX + w*0.055, sacH*0.1), w*0.035, _fill(_kRepro.withOpacity(0.4)));
    _label(canvas, 'Synergids', Offset(sacX - w*0.15, sacH*0.1), fs: 7.5, c: _kRepro);

    // Polar nuclei (centre)
    canvas.drawCircle(Offset(sacX - w*0.04, 0), w*0.04, _fill(const Color(0xFF1565C0).withOpacity(0.5)));
    canvas.drawCircle(Offset(sacX + w*0.04, 0), w*0.04, _fill(const Color(0xFF1565C0).withOpacity(0.5)));
    _label(canvas, 'Polar\nnuclei', Offset(sacX - w*0.22, 0), fs: 7.5, c: const Color(0xFF1565C0));

    // Antipodals (top)
    for (int i = 0; i < 3; i++) {
      canvas.drawCircle(Offset(sacX - w*0.07 + i*w*0.07, -sacH*0.3), w*0.035, _fill(_kNeuro.withOpacity(0.5)));
    }
    _label(canvas, 'Antipodals', Offset(sacX, -sacH*0.38), fs: 7.5, c: _kNeuro);

    // Pollen tube (left, animated based on step)
    final tubeProgress = step < 2 ? 0.0 : step < 4 ? (step - 2) * 0.5 : 1.0;
    final tubeEndX = sacX - sacW * 0.5;
    final tubeStartX = -w * 0.48;
    final tubeX = tubeStartX + (tubeEndX - tubeStartX) * (tubeProgress + (step >= 4 ? 0 : t * 0.15));

    _label(canvas, 'Pollen grain', Offset(tubeStartX + 10, -h * 0.36), fs: 8.5, bold: true, c: const Color(0xFF795548));
    // Pollen grain
    canvas.drawCircle(Offset(tubeStartX + 10, -h * 0.26), w * 0.055, _fill(const Color(0xFFFFCC02)));
    canvas.drawCircle(Offset(tubeStartX + 10, -h * 0.26), w * 0.055, _stroke(const Color(0xFF795548)));

    // Pollen tube
    if (step >= 1) {
      final path = Path()
        ..moveTo(tubeStartX + 10, -h * 0.2)
        ..quadraticBezierTo(tubeStartX + (tubeX - tubeStartX) * 0.5, 0, tubeX, sacH * 0.25);
      canvas.drawPath(path, _stroke(const Color(0xFF795548), w: 2));

      // 2 sperm cells in tube
      if (step >= 3) {
        final s1x = tubeStartX + (tubeX - tubeStartX) * 0.6;
        final s1y = -(h * 0.2) + (sacH * 0.25 + h * 0.2) * 0.6;
        final s2x = tubeStartX + (tubeX - tubeStartX) * 0.45;
        final s2y = -(h * 0.2) + (sacH * 0.25 + h * 0.2) * 0.45;
        canvas.drawCircle(Offset(s1x, s1y), w * 0.035, _fill(const Color(0xFFFF9800)));
        canvas.drawCircle(Offset(s2x, s2y), w * 0.035, _fill(const Color(0xFFFF9800)));
        _label(canvas, '2 sperms', Offset(s2x - 10, s2y - 14), fs: 7.5, c: const Color(0xFFE65100));
      }
    }
    _label(canvas, 'Micropyle', Offset(sacX, sacH * 0.42 + 12), fs: 8, c: _kPlant);

    // Show result
    if (step >= 5) {
      canvas.drawCircle(Offset(sacX, sacH * 0.25), w * 0.065, _fill(_kRepro.withOpacity(0.85)));
      _label(canvas, 'Zygote (2n)', Offset(sacX, sacH * 0.38), fs: 8.5, bold: true, c: const Color(0xFFC62828));
    }
    if (step >= 6) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(sacX, 0), width: w*0.22, height: sacH*0.22),
        _fill(const Color(0xFF1565C0).withOpacity(0.45)));
      _label(canvas, 'PEN (3n)\nEndosperm', Offset(sacX, -sacH * 0.18), fs: 7.5, bold: true, c: const Color(0xFF0D47A1));
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_DoubleFertilizationPainter o) => o.step != step || o.t != t;
}

// ─────────────────────────────────────────────────────────────────────────────
// 3. EMBRYO DEVELOPMENT
// ─────────────────────────────────────────────────────────────────────────────
class _EmbryoDevelopmentPainter extends CustomPainter {
  final int step; final double t;
  _EmbryoDevelopmentPainter(this.step, this.t);

  static const _stages = ['Zygote', '2-cell\nProembryo', 'Octant', 'Globular', 'Heart', 'Torpedo', 'Endosperm', 'Seed'];
  static const _colors = [
    Color(0xFF7B1FA2), Color(0xFFE91E8C), Color(0xFF1976D2),
    Color(0xFF0097A7), Color(0xFF2E7D32), Color(0xFF388E3C),
    Color(0xFFE65100), Color(0xFF795548),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), _fill(_kBg));
    final cx = size.width / 2, cy = size.height / 2;
    final r = math.min(size.width * 0.11, size.height * 0.22);

    // Show stage row — past + current highlighted
    final count = math.min(step + 1, _stages.length);
    final spacing = size.width / (math.min(_stages.length, 5) + 1);
    final rowY = cy + size.height * 0.12;

    for (int i = 0; i < _stages.length; i++) {
      final x = spacing * (i % 4 + 1);
      final y = i < 4 ? cy - size.height * 0.18 : cy + size.height * 0.22;
      final isCur = i == step;
      final isPast = i < step;
      final c = _colors[i % _colors.length];
      canvas.drawCircle(Offset(x, y), r * (isCur ? 1.15 : 0.7),
          _fill(isCur ? c : isPast ? c.withOpacity(0.4) : c.withOpacity(0.12)));
      canvas.drawCircle(Offset(x, y), r * (isCur ? 1.15 : 0.7),
          _stroke(isCur ? c : c.withOpacity(0.4), w: isCur ? 2.5 : 1.2));
      _label(canvas, _stages[i], Offset(x, y + r * (isCur ? 1.5 : 1.1)), fs: isCur ? 9 : 7.5,
          bold: isCur, c: isCur ? c : c.withOpacity(0.7));
      if (i > 0 && i < 4) {
        _arrow(canvas, Offset(spacing * i + r * 0.85, i < 4 ? cy - size.height * 0.18 : cy + size.height * 0.22),
            Offset(spacing * (i + 1) - r * 0.85, i < 4 ? cy - size.height * 0.18 : cy + size.height * 0.22),
            _kGray, w: 1.2);
      }
    }

    // Draw detail of current stage
    canvas.save();
    canvas.translate(cx, cy - size.height * 0.08);
    _drawStageDetail(canvas, step, size, r);
    canvas.restore();
  }

  void _drawStageDetail(Canvas canvas, int step, Size size, double r) {
    final c = _colors[step % _colors.length];
    final rBig = r * 1.6;
    switch (step) {
      case 0: // Zygote
        canvas.drawCircle(Offset.zero, rBig, _fill(c.withOpacity(0.3)));
        canvas.drawCircle(Offset.zero, rBig, _stroke(c, w: 2.5));
        canvas.drawCircle(Offset.zero, rBig * 0.45, _fill(c.withOpacity(0.6)));
        _label(canvas, '2n', Offset.zero, fs: 11, bold: true, c: Colors.white);
      case 1: // 2-cell
        for (int i = 0; i < 2; i++) {
          final dy = (i == 0 ? -1 : 1) * rBig * 0.6;
          canvas.drawCircle(Offset(0, dy), rBig * 0.6, _fill(i == 0 ? c.withOpacity(0.4) : c.withOpacity(0.25)));
          canvas.drawCircle(Offset(0, dy), rBig * 0.6, _stroke(c));
        }
        _label(canvas, 'Apical', Offset(rBig + 8, -rBig * 0.6), fs: 8, c: c);
        _label(canvas, 'Basal\n(Suspensor)', Offset(rBig + 8, rBig * 0.6), fs: 8, c: c.withOpacity(0.7));
      case 2: // Octant (2x2x2)
        for (int i = 0; i < 4; i++) {
          final dx = (i % 2 == 0 ? -1 : 1) * rBig * 0.45;
          final dy = (i < 2 ? -1 : 1) * rBig * 0.45;
          canvas.drawRect(Rect.fromCenter(center: Offset(dx, dy), width: rBig * 0.8, height: rBig * 0.8),
              _fill(c.withOpacity(0.3)));
          canvas.drawRect(Rect.fromCenter(center: Offset(dx, dy), width: rBig * 0.8, height: rBig * 0.8),
              _stroke(c, w: 1.5));
        }
        _label(canvas, '8-cell Octant', Offset(0, rBig * 1.3), fs: 9, bold: true, c: c);
      case 3: // Globular
        canvas.drawCircle(Offset.zero, rBig, _fill(c.withOpacity(0.25)));
        canvas.drawCircle(Offset.zero, rBig, _stroke(c, w: 2.5));
        _label(canvas, 'Globular', Offset(0, rBig + 14), fs: 9, bold: true, c: c);
      case 4: // Heart
        final path = Path();
        final hx = rBig * 0.7;
        path.moveTo(0, rBig * 0.6);
        path.cubicTo(-hx * 2, rBig * 0.2, -hx * 2, -rBig * 0.6, 0, -rBig * 0.2);
        path.cubicTo(hx * 2, -rBig * 0.6, hx * 2, rBig * 0.2, 0, rBig * 0.6);
        canvas.drawPath(path, _fill(c.withOpacity(0.3)));
        canvas.drawPath(path, _stroke(c, w: 2.5));
        _label(canvas, 'Heart-shaped', Offset(0, rBig + 14), fs: 9, bold: true, c: c);
      case 5: // Torpedo
        final torpRect = Rect.fromCenter(center: const Offset(0, 0), width: rBig * 1.2, height: rBig * 2.2);
        canvas.drawOval(torpRect, _fill(c.withOpacity(0.25)));
        canvas.drawOval(torpRect, _stroke(c, w: 2.5));
        _label(canvas, 'Torpedo', Offset(rBig + 12, 0), fs: 9, bold: true, c: c);
        _label(canvas, 'Cotyledons', Offset(-rBig - 12, -rBig * 0.5), fs: 7.5, c: c, align: TextAlign.right);
      case 6: // Endosperm
        canvas.drawCircle(Offset.zero, rBig, _fill(const Color(0xFFE65100).withOpacity(0.2)));
        canvas.drawCircle(Offset.zero, rBig, _stroke(const Color(0xFFE65100), w: 2.5));
        for (int i = 0; i < 8; i++) {
          final angle = i * math.pi / 4;
          canvas.drawCircle(Offset(math.cos(angle) * rBig * 0.55, math.sin(angle) * rBig * 0.55),
              rBig * 0.22, _fill(const Color(0xFFE65100).withOpacity(0.4)));
        }
        _label(canvas, 'Endosperm\n(3n)', Offset(0, rBig + 14), fs: 9, bold: true, c: const Color(0xFFE65100));
      default: // Seed
        final seedRect = Rect.fromCenter(center: Offset.zero, width: rBig * 2, height: rBig * 2.4);
        canvas.drawOval(seedRect, _fill(const Color(0xFF795548).withOpacity(0.25)));
        canvas.drawOval(seedRect, _stroke(const Color(0xFF795548), w: 2.5));
        canvas.drawOval(Rect.fromCenter(center: Offset(0, -rBig * 0.2), width: rBig, height: rBig * 1.2),
            _fill(const Color(0xFF2E7D32).withOpacity(0.4)));
        _label(canvas, 'Embryo', Offset(rBig + 10, -rBig * 0.2), fs: 8.5, c: const Color(0xFF2E7D32));
        _label(canvas, 'Seed Coat\n(Testa)', Offset(-rBig - 10, 0), fs: 8, c: const Color(0xFF795548), align: TextAlign.right);
        _label(canvas, 'Seed', Offset(0, rBig * 1.4 + 12), fs: 9, bold: true, c: const Color(0xFF795548));
    }
  }

  @override
  bool shouldRepaint(_EmbryoDevelopmentPainter o) => o.step != step || o.t != t;
}

// ─────────────────────────────────────────────────────────────────────────────
// 4. PLACENTA
// ─────────────────────────────────────────────────────────────────────────────
class _PlacentaPainter extends CustomPainter {
  final int step; final double t;
  _PlacentaPainter(this.step, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), _fill(_kBg));
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);

    final w = size.width, h = size.height;
    final stripH = h * 0.15;

    // Maternal blood space (red, top)
    final matY = -h * 0.28;
    canvas.drawRRect(RRect.fromRectXY(Rect.fromCenter(center: Offset(0, matY), width: w * 0.82, height: stripH * 1.4), 8, 8),
        _fill(const Color(0xFFFFCDD2)));
    canvas.drawRRect(RRect.fromRectXY(Rect.fromCenter(center: Offset(0, matY), width: w * 0.82, height: stripH * 1.4), 8, 8),
        _stroke(const Color(0xFFC62828), w: 1.5));
    _label(canvas, 'Maternal Blood Sinuses', Offset(0, matY), fs: 9, bold: true, c: const Color(0xFFC62828));

    // Chorionic villi (middle)
    final villiY = -h * 0.05;
    _label(canvas, 'Chorionic Villi\n(Trophoblast)', Offset(0, villiY), fs: 9, bold: true, c: _kRepro);
    for (int i = -2; i <= 2; i++) {
      final vx = w * 0.12 * i;
      // Finger projections up into maternal space
      final villPath = Path()
        ..moveTo(vx, villiY - h * 0.02)
        ..cubicTo(vx - w * 0.03, matY + stripH * 0.3, vx + w * 0.03, matY + stripH * 0.5, vx, matY + h * 0.02);
      canvas.drawPath(villPath, _stroke(_kRepro, w: step >= 4 ? 3 : 1.5));
    }

    // Fetal capillaries (blue, bottom)
    final fetY = h * 0.22;
    canvas.drawRRect(RRect.fromRectXY(Rect.fromCenter(center: Offset(0, fetY), width: w * 0.82, height: stripH * 1.4), 8, 8),
        _fill(const Color(0xFFBBDEFB)));
    canvas.drawRRect(RRect.fromRectXY(Rect.fromCenter(center: Offset(0, fetY), width: w * 0.82, height: stripH * 1.4), 8, 8),
        _stroke(const Color(0xFF1565C0), w: 1.5));
    _label(canvas, 'Fetal Blood Capillaries', Offset(0, fetY), fs: 9, bold: true, c: const Color(0xFF1565C0));

    // Exchange arrows (step >= 5)
    if (step >= 5) {
      final flowT = (t * 2) % 1.0;
      final animY = matY + (fetY - matY) * flowT;
      // O₂ + nutrients → fetus
      _arrow(canvas, Offset(-w * 0.15, matY + stripH * 0.5), Offset(-w * 0.15, fetY - stripH * 0.5),
          const Color(0xFF2E7D32), w: 2.5);
      _label(canvas, 'O₂\nGlucose', Offset(-w * 0.28, (matY + fetY) / 2), fs: 8, bold: true, c: const Color(0xFF2E7D32));
      // CO₂ + waste → mother
      _arrow(canvas, Offset(w * 0.15, fetY - stripH * 0.5), Offset(w * 0.15, matY + stripH * 0.5),
          const Color(0xFF757575), w: 2.5);
      _label(canvas, 'CO₂\nUrea', Offset(w * 0.28, (matY + fetY) / 2), fs: 8, bold: true, c: const Color(0xFF757575));
    }

    // Labels at sides
    _label(canvas, 'Mother', Offset(-w * 0.44, matY), fs: 9, bold: true, c: const Color(0xFFC62828));
    _label(canvas, 'Fetus', Offset(-w * 0.44, fetY), fs: 9, bold: true, c: const Color(0xFF1565C0));

    canvas.restore();
  }

  @override
  bool shouldRepaint(_PlacentaPainter o) => o.step != step || o.t != t;
}

// ─────────────────────────────────────────────────────────────────────────────
// 5. GRIFFITH'S EXPERIMENT
// ─────────────────────────────────────────────────────────────────────────────
class _GriffithPainter extends CustomPainter {
  final int step; final double t;
  _GriffithPainter(this.step, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), _fill(_kBg));
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);

    final w = size.width, h = size.height;
    // Always show 4 panels (highlight active)
    final panels = [
      ('S strain\n(virulent)', const Color(0xFFC62828), 'DEAD', true),
      ('R strain\n(avirulent)', const Color(0xFF2E7D32), 'ALIVE', false),
      ('Heat-killed S', const Color(0xFF757575), 'ALIVE', false),
      ('Heat-killed S\n+ Live R', const Color(0xFF7B1FA2), 'DEAD!', true),
    ];
    final pW = w * 0.21, pX0 = -w * 0.36;

    for (int i = 0; i < panels.length; i++) {
      final (label, color, result, dies) = panels[i];
      final px = pX0 + i * (pW + w * 0.02);
      final isActive = i == step % 4;

      // Panel border
      canvas.drawRRect(
        RRect.fromRectXY(Rect.fromCenter(center: Offset(px, 0), width: pW, height: h * 0.8), 10, 10),
        _fill(isActive ? color.withOpacity(0.12) : const Color(0xFFEEEEEE)));
      canvas.drawRRect(
        RRect.fromRectXY(Rect.fromCenter(center: Offset(px, 0), width: pW, height: h * 0.8), 10, 10),
        _stroke(isActive ? color : _kGray, w: isActive ? 2 : 1));

      // Bacteria dots
      final bColor = i == 2 ? const Color(0xFF424242) : color;
      for (int b = 0; b < 3; b++) {
        canvas.drawCircle(Offset(px - pW * 0.2 + b * pW * 0.2, -h * 0.2), 5,
            _fill(bColor.withOpacity(i == 2 ? 0.4 : 0.7)));
      }
      _label(canvas, label, Offset(px, -h * 0.05), fs: 8, bold: isActive, c: isActive ? color : _kGray);

      // Arrow
      _arrow(canvas, Offset(px, h * 0.1), Offset(px, h * 0.2), isActive ? color : _kGray);

      // Mouse symbol
      canvas.drawCircle(Offset(px, h * 0.3), 12,
          _fill(dies ? const Color(0xFFFFCDD2) : const Color(0xFFE8F5E9)));
      canvas.drawCircle(Offset(px, h * 0.3), 12, _stroke(dies ? const Color(0xFFC62828) : const Color(0xFF2E7D32)));
      _label(canvas, dies ? '✗' : '✓', Offset(px, h * 0.3), fs: 10, bold: true,
          c: dies ? const Color(0xFFC62828) : const Color(0xFF2E7D32));
      _label(canvas, result, Offset(px, h * 0.42 + 4), fs: 8, bold: true,
          c: dies ? const Color(0xFFC62828) : const Color(0xFF2E7D32));
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_GriffithPainter o) => o.step != step || o.t != t;
}

// ─────────────────────────────────────────────────────────────────────────────
// 6. HERSHEY-CHASE
// ─────────────────────────────────────────────────────────────────────────────
class _HersheyPainter extends CustomPainter {
  final int step; final double t;
  _HersheyPainter(this.step, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), _fill(_kBg));
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);

    final w = size.width, h = size.height;
    final isBatch1 = step < 3 || step == 3;

    // Batch label
    _label(canvas, step < 3 ? 'Batch 1: ³⁵S-labelled (Protein)' : 'Batch 2: ³²P-labelled (DNA)',
        Offset(0, -h * 0.44), fs: 9, bold: true, c: step < 3 ? const Color(0xFFE65100) : _kMol);

    // T4 phage
    final phageX = -w * 0.32;
    _drawPhage(canvas, Offset(phageX, -h * 0.1), step < 3, w * 0.035);

    // Bacteria
    if (step >= 2) {
      canvas.drawOval(Rect.fromCenter(center: Offset(-w * 0.05, -h * 0.08), width: w * 0.22, height: h * 0.28),
          _fill(const Color(0xFFE8F5E9)));
      canvas.drawOval(Rect.fromCenter(center: Offset(-w * 0.05, -h * 0.08), width: w * 0.22, height: h * 0.28),
          _stroke(const Color(0xFF2E7D32), w: 2));
      _label(canvas, 'E. coli', Offset(-w * 0.05, -h * 0.08), fs: 9, c: const Color(0xFF2E7D32));
      _arrow(canvas, Offset(phageX + w * 0.06, -h * 0.1), Offset(-w * 0.13, -h * 0.1), _kMol, w: 1.5);

      // DNA injected into bacteria
      if (step >= 2) {
        final dnaColor = step < 3 ? const Color(0xFF757575) : _kMol;
        _dashedLine(canvas, Offset(-w * 0.1, -h * 0.05), Offset(-w * 0.1, h * 0.02), dnaColor, w: 2);
        _label(canvas, step < 3 ? 'Protein\nstays out' : '³²P DNA\ninside', Offset(-w * 0.05, h * 0.1), fs: 8,
            bold: true, c: dnaColor);
      }
    }

    // Centrifuge result
    if (step >= 4) {
      // Supernatant (top)
      canvas.drawRRect(
        RRect.fromRectXY(Rect.fromCenter(center: Offset(w * 0.28, -h * 0.15), width: w * 0.24, height: h * 0.22), 6, 6),
        _fill(step < 3 ? const Color(0xFFFFE0B2) : const Color(0xFFEEEEEE)));
      _label(canvas, 'Supernatant\n${step < 3 ? "(³⁵S protein)" : "(no ³²P)"}', Offset(w * 0.28, -h * 0.15),
          fs: 8, c: step < 3 ? const Color(0xFFE65100) : _kGray);
      // Pellet
      canvas.drawRRect(
        RRect.fromRectXY(Rect.fromCenter(center: Offset(w * 0.28, h * 0.18), width: w * 0.24, height: h * 0.18), 6, 6),
        _fill(step < 3 ? const Color(0xFFEEEEEE) : const Color(0xFFBBDEFB)));
      _label(canvas, 'Pellet\n${step < 3 ? "(no ³⁵S)" : "(³²P DNA)"}', Offset(w * 0.28, h * 0.18),
          fs: 8, c: step < 3 ? _kGray : _kMol);
    }

    if (step >= 6) {
      _label(canvas, 'DNA = Genetic Material', Offset(0, h * 0.42), fs: 10, bold: true, c: _kMol);
    }
    canvas.restore();
  }

  void _drawPhage(Canvas canvas, Offset pos, bool labeled35S, double r) {
    // Head
    canvas.drawOval(Rect.fromCenter(center: pos, width: r * 2.2, height: r * 2.8),
        _fill(labeled35S ? const Color(0xFFFFE0B2) : const Color(0xFFBBDEFB)));
    canvas.drawOval(Rect.fromCenter(center: pos, width: r * 2.2, height: r * 2.8),
        _stroke(labeled35S ? const Color(0xFFE65100) : _kMol, w: 1.5));
    _label(canvas, labeled35S ? '³⁵S' : '³²P', pos, fs: 8, bold: true,
        c: labeled35S ? const Color(0xFFE65100) : _kMol);
    // Tail
    canvas.drawLine(Offset(pos.dx, pos.dy + r * 1.4), Offset(pos.dx, pos.dy + r * 2.8),
        _stroke(const Color(0xFF424242), w: 1.5));
    // Tail fibres
    for (int f = 0; f < 3; f++) {
      final angle = (f * 60 - 60) * math.pi / 180;
      canvas.drawLine(Offset(pos.dx, pos.dy + r * 2.8),
          Offset(pos.dx + math.cos(angle) * r * 1.2, pos.dy + r * 2.8 + math.sin(angle).abs() * r),
          _stroke(const Color(0xFF424242)));
    }
  }

  @override
  bool shouldRepaint(_HersheyPainter o) => o.step != step || o.t != t;
}

// ─────────────────────────────────────────────────────────────────────────────
// 7. RECOMBINANT DNA TECHNOLOGY
// ─────────────────────────────────────────────────────────────────────────────
class _RDNAPainter extends CustomPainter {
  final int step; final double t;
  _RDNAPainter(this.step, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), _fill(_kBg));
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);

    final w = size.width, h = size.height;
    final r = math.min(w, h) * 0.18;

    final labels = ['Gene of\nInterest', 'Restriction\nDigestion', 'Vector\nPrep', 'Ligation', 'Transformation', 'Selection', 'Expression'];
    final colors = [_kMol, const Color(0xFFE65100), _kBio, const Color(0xFF2E7D32), _kRepro, const Color(0xFF795548), _kPhoto];

    // Plasmid (circle) on left
    final plasmidX = -w * 0.22;
    canvas.drawCircle(Offset(plasmidX, 0), r * 1.1, _fill(const Color(0xFFE8F5E9)));
    canvas.drawCircle(Offset(plasmidX, 0), r * 1.1, _stroke(const Color(0xFF2E7D32), w: 2.5));
    _label(canvas, 'Plasmid\n(Vector)', Offset(plasmidX, 0), fs: 9, bold: true, c: const Color(0xFF2E7D32));

    // Insert (linear DNA) on right
    final insertX = w * 0.22;
    canvas.drawRRect(
      RRect.fromRectXY(Rect.fromCenter(center: Offset(insertX, 0), width: w * 0.3, height: h * 0.18), 6, 6),
      _fill(const Color(0xFFE3F2FD)));
    canvas.drawRRect(
      RRect.fromRectXY(Rect.fromCenter(center: Offset(insertX, 0), width: w * 0.3, height: h * 0.18), 6, 6),
      _stroke(_kMol, w: 2));
    _label(canvas, 'Gene of\nInterest', Offset(insertX, 0), fs: 9, bold: true, c: _kMol);

    if (step >= 1) {
      // Scissors (restriction enzyme)
      _label(canvas, '✂ RE cuts', Offset(plasmidX + r * 0.8, -r * 0.5), fs: 8, c: const Color(0xFFE65100));
      _label(canvas, '✂ RE cuts', Offset(insertX, -h * 0.14), fs: 8, c: const Color(0xFFE65100));
    }

    if (step >= 3) {
      // Recombinant plasmid (below)
      canvas.drawCircle(Offset(0, h * 0.28), r * 1.2, _fill(const Color(0xFFF3E5F5)));
      canvas.drawCircle(Offset(0, h * 0.28), r * 1.2, _stroke(_kRepro, w: 2.5));
      // Insert arc shown as different color
      final arcPaint = _stroke(const Color(0xFF1565C0), w: 4);
      canvas.drawArc(Rect.fromCenter(center: Offset(0, h * 0.28), width: r * 2.4, height: r * 2.4),
          -0.5, 1.0, false, arcPaint);
      _label(canvas, 'Recombinant\nPlasmid', Offset(0, h * 0.28), fs: 9, bold: true, c: _kRepro);
      _arrow(canvas, Offset(plasmidX * 0.4, h * 0.1), Offset(-w * 0.06, h * 0.18), _kRepro, w: 1.5);
      _arrow(canvas, Offset(insertX * 0.4, h * 0.08), Offset(w * 0.06, h * 0.18), _kRepro, w: 1.5);
    }

    if (step >= 4) {
      // E. coli host
      canvas.drawOval(Rect.fromCenter(center: Offset(0, h * 0.28), width: r * 3, height: r * 2.8),
          _stroke(const Color(0xFF2E7D32), w: 1.5));
      _label(canvas, 'E. coli host', Offset(r * 1.8, h * 0.28), fs: 8, c: const Color(0xFF2E7D32));
    }

    // Current step label
    _label(canvas, 'Step: ${labels[step.clamp(0, labels.length - 1)]}', Offset(0, -h * 0.44),
        fs: 10, bold: true, c: colors[step.clamp(0, colors.length - 1)]);

    canvas.restore();
  }

  @override
  bool shouldRepaint(_RDNAPainter o) => o.step != step || o.t != t;
}

// ─────────────────────────────────────────────────────────────────────────────
// 8. MICROPROPAGATION
// ─────────────────────────────────────────────────────────────────────────────
class _MicropropagationPainter extends CustomPainter {
  final int step; final double t;
  _MicropropagationPainter(this.step, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), _fill(_kBg));
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);

    final w = size.width, h = size.height;
    final stages = ['Explant', 'Sterilise', 'Culture\nMedium', 'Callus', 'Organogenesis', 'Shoot +\nRoot', 'Hardening', 'Field\nTransfer'];
    final colors = [_kPlant, const Color(0xFF0097A7), _kBio, const Color(0xFFE65100), _kPhoto, const Color(0xFF2E7D32), const Color(0xFFFF9800), _kPlant];
    final count = stages.length;
    final spacing = w / (count / 2 + 1);
    final row0y = -h * 0.22, row1y = h * 0.22;

    for (int i = 0; i < count; i++) {
      final row = i ~/ 4;
      final col = i % 4;
      final x = -w * 0.38 + col * spacing;
      final y = row == 0 ? row0y : row1y;
      final isCur = i == step;
      final isPast = i < step;
      final c = colors[i];

      canvas.drawCircle(Offset(x, y), isCur ? 22 : 14,
          _fill(isCur ? c.withOpacity(0.25) : isPast ? c.withOpacity(0.4) : const Color(0xFFEEEEEE)));
      canvas.drawCircle(Offset(x, y), isCur ? 22 : 14,
          _stroke(isCur ? c : isPast ? c.withOpacity(0.6) : _kGray, w: isCur ? 2.5 : 1));
      if (col < 3) {
        _arrow(canvas, Offset(x + (isCur ? 22 : 14) + 2, y), Offset(x + spacing - (i + 1 == step ? 22 : 14) - 2, y),
            _kGray, w: 1);
      }
      _label(canvas, stages[i], Offset(x, y + (isCur ? 28 : 20)), fs: isCur ? 9 : 7.5, bold: isCur, c: isCur ? c : _kGray);
    }
    // Row connector
    _arrow(canvas, Offset(w * 0.18, row0y), Offset(w * 0.18, row1y), _kGray, w: 1);

    // Detail drawing
    canvas.save();
    canvas.translate(0, h * 0.02);
    _drawMicropropDetail(canvas, step, w, h, colors[step.clamp(0, colors.length - 1)]);
    canvas.restore();

    canvas.restore();
  }

  void _drawMicropropDetail(Canvas canvas, int step, double w, double h, Color c) {
    final s = h * 0.12;
    switch (step) {
      case 0: // Explant leaf
        final path = Path()..moveTo(0,-s)..quadraticBezierTo(s*1.2,0,0,s)..quadraticBezierTo(-s*1.2,0,0,-s);
        canvas.drawPath(path, _fill(c.withOpacity(0.3)));
        canvas.drawPath(path, _stroke(c, w: 2));
        _dashedLine(canvas, const Offset(0, 0), Offset(0, s * 0.7), c);
      case 3: // Callus blob
        for (int i = 0; i < 8; i++) {
          final angle = i * math.pi / 4 + t * math.pi;
          final r = s * (0.7 + 0.3 * math.sin(i * 1.3));
          canvas.drawCircle(Offset(math.cos(angle) * r * 0.6, math.sin(angle) * r * 0.6), r * 0.5,
              _fill(c.withOpacity(0.35)));
        }
        _label(canvas, 'Callus', const Offset(0, 0), fs: 8.5, bold: true, c: c);
      case 5: // Plantlet
        // Shoot
        canvas.drawLine(Offset(0, s * 0.4), Offset(0, -s * 0.6), _stroke(_kPhoto, w: 3));
        canvas.drawCircle(Offset(0, -s * 0.6), s * 0.35, _fill(_kPhoto.withOpacity(0.4)));
        // Roots
        for (int i = 0; i < 3; i++) {
          final angle = (i - 1) * 0.6;
          canvas.drawLine(Offset(0, s * 0.4), Offset(math.sin(angle) * s * 0.6, s * 0.4 + math.cos(angle).abs() * s * 0.5),
              _stroke(const Color(0xFF795548), w: 2));
        }
      default:
        break;
    }
  }

  @override
  bool shouldRepaint(_MicropropagationPainter o) => o.step != step || o.t != t;
}

// ─────────────────────────────────────────────────────────────────────────────
// 9. BRYOPHYTA LIFE CYCLE
// ─────────────────────────────────────────────────────────────────────────────
class _BryophytaPainter extends CustomPainter {
  final int step; final double t;
  _BryophytaPainter(this.step, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    _drawLifeCycle(canvas, size, step, t,
        stages: ['Spore (n)', 'Protonema (n)', 'Gametophyte\n(Dominant, n)', 'Sex Organs\n(Archegonia+Antheridia)', 'Fertilisation\n(Needs water)', 'Sporophyte\n(2n, dependent)', 'Meiosis in\nCapsule', 'Spore (n)\n↺ Cycle repeats'],
        ploidy: ['n', 'n', 'n', 'n', '2n', '2n', '2n→n', 'n'],
        nodeColors: [_kPhoto, _kPhoto, _kPhoto, const Color(0xFF1976D2), const Color(0xFF7B1FA2), _kPlant, _kPlant, _kPhoto],
        highlight: const Color(0xFF2E7D32),
        title: 'Bryophyta Life Cycle\n(Gametophyte dominant)');
  }

  @override
  bool shouldRepaint(_BryophytaPainter o) => o.step != step || o.t != t;
}

// ─────────────────────────────────────────────────────────────────────────────
// 10. PTERIDOPHYTA LIFE CYCLE
// ─────────────────────────────────────────────────────────────────────────────
class _PteridophytaPainter extends CustomPainter {
  final int step; final double t;
  _PteridophytaPainter(this.step, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    _drawLifeCycle(canvas, size, step, t,
        stages: ['Sporophyte\n(Dominant, 2n)', 'Sori /\nSporangia', 'Meiosis →\nSpores (n)', 'Germination', 'Prothallus\n(Gametophyte, n)', 'Sex Organs\non Prothallus', 'Fertilisation\n(Needs water)', 'Young\nSporophyte'],
        ploidy: ['2n', '2n', '2n→n', 'n', 'n', 'n', '2n', '2n'],
        nodeColors: [_kPlant, _kPlant, _kPlant, _kPhoto, _kPhoto, const Color(0xFF1976D2), const Color(0xFF7B1FA2), _kPlant],
        highlight: _kPlant,
        title: 'Pteridophyta Life Cycle\n(Sporophyte dominant)');
  }

  @override
  bool shouldRepaint(_PteridophytaPainter o) => o.step != step || o.t != t;
}

// shared life cycle wheel drawer
void _drawLifeCycle(Canvas canvas, Size size, int step, double t,
    {required List<String> stages, required List<String> ploidy, required List<Color> nodeColors,
     required Color highlight, required String title}) {
  canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), _fill(_kBg));
  canvas.save();
  canvas.translate(size.width / 2, size.height / 2);

  final r = math.min(size.width, size.height) * 0.32;
  final n = stages.length;

  // Background circle
  canvas.drawCircle(Offset.zero, r * 1.05, _stroke(_kGray.withOpacity(0.3), w: 1.5));

  for (int i = 0; i < n; i++) {
    final angle = 2 * math.pi * i / n - math.pi / 2;
    final pos = Offset(r * math.cos(angle), r * math.sin(angle));
    final isCur = i == step;
    final c = nodeColors[i];

    // Arrow to next
    final nextAngle = 2 * math.pi * (i + 1) / n - math.pi / 2;
    final nextPos = Offset(r * math.cos(nextAngle), r * math.sin(nextAngle));
    final midAngle = (angle + nextAngle) / 2;
    final arrowMid = Offset(r * 0.78 * math.cos(midAngle), r * 0.78 * math.sin(midAngle));
    _arrow(canvas, pos + (arrowMid - pos) * 0.35, nextPos + (arrowMid - nextPos) * 0.35,
        isCur ? c : _kGray.withOpacity(0.5), w: isCur ? 2 : 1);

    // Node
    final nr = isCur ? 20.0 : 13.0;
    canvas.drawCircle(pos, nr, _fill(isCur ? c.withOpacity(0.25) : c.withOpacity(0.15)));
    canvas.drawCircle(pos, nr, _stroke(isCur ? c : c.withOpacity(0.5), w: isCur ? 2.5 : 1.2));

    // Ploidy label inside
    _label(canvas, ploidy[i], pos, fs: isCur ? 8.5 : 7, bold: true, c: isCur ? c : c.withOpacity(0.7));

    // Stage label outside
    final labelPos = Offset((r + 30) * math.cos(angle), (r + 30) * math.sin(angle));
    _label(canvas, stages[i], labelPos, fs: isCur ? 8 : 7, bold: isCur, c: isCur ? c : _kGray);
  }

  _label(canvas, title, Offset(0, r * 1.55), fs: 8.5, bold: true, c: highlight);
  canvas.restore();
}

// ─────────────────────────────────────────────────────────────────────────────
// 11. CHEMIOSMOTIC HYPOTHESIS
// ─────────────────────────────────────────────────────────────────────────────
class _ChemiosmoticPainter extends CustomPainter {
  final int step; final double t;
  _ChemiosmoticPainter(this.step, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), _fill(_kBg));
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);

    final w = size.width, h = size.height;
    final memY = h * 0.05;
    final memThick = h * 0.08;

    // Thylakoid membrane
    canvas.drawRect(Rect.fromCenter(center: Offset(0, memY), width: w * 0.9, height: memThick),
        _fill(const Color(0xFF80CBC4)));
    canvas.drawRect(Rect.fromCenter(center: Offset(0, memY), width: w * 0.9, height: memThick),
        _stroke(const Color(0xFF00695C), w: 1.5));
    _label(canvas, 'Thylakoid Membrane', Offset(0, memY + memThick * 0.8), fs: 7.5, bold: true, c: const Color(0xFF004D40));

    // Lumen (below membrane) — acidic, H+ rich
    final lumenY = memY + memThick * 0.5 + h * 0.15;
    canvas.drawRect(Rect.fromCenter(center: Offset(0, lumenY), width: w * 0.9, height: h * 0.22),
        _fill(const Color(0xFFFFECB3).withOpacity(0.5)));
    _label(canvas, 'Lumen (H⁺ rich, pH~5)', Offset(0, lumenY), fs: 8.5, bold: true, c: const Color(0xFFE65100));

    // Stroma (above membrane) — basic, H+ poor
    final stromaY = memY - memThick * 0.5 - h * 0.18;
    canvas.drawRect(Rect.fromCenter(center: Offset(0, stromaY), width: w * 0.9, height: h * 0.25),
        _fill(const Color(0xFFE8F5E9).withOpacity(0.6)));
    _label(canvas, 'Stroma (H⁺ poor, pH~8)', Offset(0, stromaY + h * 0.03), fs: 8.5, bold: true, c: const Color(0xFF2E7D32));

    // CF0 (rotor in membrane)
    final synthX = -w * 0.05;
    canvas.drawOval(Rect.fromCenter(center: Offset(synthX, memY), width: w * 0.1, height: memThick * 1.1),
        _fill(const Color(0xFF1565C0)));
    _label(canvas, 'CF₀', Offset(synthX, memY), fs: 8, bold: true, c: Colors.white);

    // CF1 (knob in stroma)
    if (step >= 2) {
      canvas.drawOval(Rect.fromCenter(center: Offset(synthX, stromaY + h * 0.1), width: w * 0.12, height: h * 0.13),
          _fill(const Color(0xFF1976D2)));
      canvas.drawOval(Rect.fromCenter(center: Offset(synthX, stromaY + h * 0.1), width: w * 0.12, height: h * 0.13),
          _stroke(const Color(0xFF0D47A1), w: 1.5));
      _label(canvas, 'CF₁', Offset(synthX, stromaY + h * 0.1), fs: 8.5, bold: true, c: Colors.white);
      canvas.drawLine(Offset(synthX, memY - memThick * 0.5), Offset(synthX, stromaY + h * 0.17),
          _stroke(const Color(0xFF0D47A1), w: 2));
    }

    // Animated H+ flowing through CF0
    if (step >= 3) {
      for (int i = 0; i < 3; i++) {
        final frac = ((t + i / 3.0) % 1.0);
        final hy = lumenY - h * 0.11 + (memY - (lumenY - h * 0.11)) * frac;
        canvas.drawCircle(Offset(synthX, hy), 5, _fill(const Color(0xFFE65100)));
        _label(canvas, 'H⁺', Offset(synthX + 10, hy), fs: 7, bold: true, c: const Color(0xFFE65100));
      }
    }

    // H+ sources (left side)
    if (step >= 0) {
      _label(canvas, 'H₂O → 2H⁺ + ½O₂\n(OEC / PS-II)', Offset(-w * 0.25, lumenY), fs: 7.5, c: const Color(0xFFE65100));
    }
    if (step >= 5) {
      _label(canvas, 'ADP + Pᵢ → ATP', Offset(synthX + w * 0.12, stromaY + h * 0.1), fs: 8.5, bold: true, c: _kPhoto);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ChemiosmoticPainter o) => o.step != step || o.t != t;
}

// ─────────────────────────────────────────────────────────────────────────────
// 12. C3 CYCLE (CALVIN)
// ─────────────────────────────────────────────────────────────────────────────
class _C3CyclePainter extends CustomPainter {
  final int step; final double t;
  _C3CyclePainter(this.step, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), _fill(_kBg));
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);

    final r = math.min(size.width, size.height) * 0.28;
    final w = size.width;

    // Cycle nodes: RuBP → 3-PGA → G3P → RuBP
    final nodes = [
      (const Offset(0, -1.0), 'RuBP\n(5C)', _kPhoto),
      (const Offset(0.95, 0.3), '3-PGA\n(3C)', _kMol),
      (const Offset(0, 1.0), 'G3P\n(3C)', const Color(0xFF2E7D32)),
    ];

    for (int i = 0; i < nodes.length; i++) {
      final (posN, label, color) = nodes[i];
      final pos = Offset(posN.dx * r, posN.dy * r);
      final next = nodes[(i + 1) % nodes.length];
      final nextPos = Offset(next.$1.dx * r, next.$1.dy * r);
      final isActive = i == step % nodes.length;

      // Arrow
      final dir = nextPos - pos;
      final arrowStart = pos + dir * 0.35;
      final arrowEnd = nextPos - dir * 0.35;
      _arrow(canvas, arrowStart, arrowEnd, isActive ? color : _kGray, w: isActive ? 2.5 : 1.2);

      // Node
      canvas.drawCircle(pos, isActive ? 28 : 20, _fill(isActive ? color.withOpacity(0.25) : color.withOpacity(0.1)));
      canvas.drawCircle(pos, isActive ? 28 : 20, _stroke(color, w: isActive ? 2.5 : 1.5));
      _label(canvas, label, pos, fs: isActive ? 9 : 8, bold: isActive, c: color);
    }

    // CO₂ input at RuBP→3-PGA arrow
    final co2Pos = Offset(r * 0.7, -r * 0.45);
    _arrow(canvas, Offset(co2Pos.dx + 20, co2Pos.dy - 20), co2Pos, const Color(0xFF424242), w: 1.5);
    _label(canvas, 'CO₂\n(RuBisCO)', Offset(co2Pos.dx + 34, co2Pos.dy - 24), fs: 8, c: const Color(0xFF424242));

    // ATP/NADPH at 3-PGA→G3P
    final energyPos = Offset(r * 0.6, r * 0.75);
    _label(canvas, 'ATP + NADPH', energyPos + const Offset(36, 0), fs: 7.5, c: const Color(0xFFE65100));

    // Output at G3P
    if (step >= 3) {
      _arrow(canvas, Offset(-r * 0.35, r * 0.92), Offset(-r * 0.35 - 28, r * 0.92 + 20), _kPhoto, w: 2);
      _label(canvas, '→ Glucose\n(1/6 G3P)', Offset(-r - 22, r * 0.92 + 20), fs: 8, bold: true, c: _kPhoto);
    }

    // ATP for regeneration
    if (step >= 4) {
      _label(canvas, '3 ATP\n(regen)', Offset(-r * 0.85, 0), fs: 8, c: const Color(0xFFE65100));
    }

    _label(canvas, 'Calvin Cycle (Stroma)', Offset(0, r * 1.48), fs: 9, bold: true, c: _kPhoto);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_C3CyclePainter o) => o.step != step || o.t != t;
}

// ─────────────────────────────────────────────────────────────────────────────
// 13. C4 CYCLE
// ─────────────────────────────────────────────────────────────────────────────
class _C4CyclePainter extends CustomPainter {
  final int step; final double t;
  _C4CyclePainter(this.step, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), _fill(_kBg));
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);

    final w = size.width, h = size.height;
    final cellW = w * 0.34, cellH = h * 0.72;

    // Mesophyll cell (left)
    final mesX = -w * 0.22;
    canvas.drawRRect(RRect.fromRectXY(Rect.fromCenter(center: Offset(mesX, 0), width: cellW, height: cellH), 14, 14),
        _fill(const Color(0xFFE8F5E9)));
    canvas.drawRRect(RRect.fromRectXY(Rect.fromCenter(center: Offset(mesX, 0), width: cellW, height: cellH), 14, 14),
        _stroke(_kPhoto, w: 2));
    _label(canvas, 'Mesophyll Cell', Offset(mesX, -cellH * 0.38), fs: 8.5, bold: true, c: _kPhoto);

    // Bundle sheath cell (right)
    final bsX = w * 0.22;
    canvas.drawRRect(RRect.fromRectXY(Rect.fromCenter(center: Offset(bsX, 0), width: cellW, height: cellH), 14, 14),
        _fill(const Color(0xFFE3F2FD)));
    canvas.drawRRect(RRect.fromRectXY(Rect.fromCenter(center: Offset(bsX, 0), width: cellW, height: cellH), 14, 14),
        _stroke(_kMol, w: 2));
    _label(canvas, 'Bundle Sheath', Offset(bsX, -cellH * 0.38), fs: 8.5, bold: true, c: _kMol);

    // Mesophyll steps
    final mesSteps = ['PEP (3C)', 'OAA (4C)', 'Malate (4C)', '→ Transport'];
    final mesColors = [_kPhoto, const Color(0xFFE65100), const Color(0xFF7B1FA2), _kGray];
    for (int i = 0; i < 3; i++) {
      final y = -h * 0.22 + i * h * 0.18;
      canvas.drawRRect(RRect.fromRectXY(Rect.fromCenter(center: Offset(mesX, y), width: cellW * 0.8, height: h * 0.12), 6, 6),
          _fill(mesColors[i].withOpacity(0.25)));
      _label(canvas, mesSteps[i], Offset(mesX, y), fs: 8.5, bold: i == step % 3, c: mesColors[i]);
      if (i < 2) {
        _arrow(canvas, Offset(mesX, y + h * 0.07), Offset(mesX, y + h * 0.11), mesColors[i + 1], w: 1.5);
      }
    }
    // CO2 in
    _arrow(canvas, Offset(mesX - cellW * 0.35, -h * 0.27), Offset(mesX - cellW * 0.1, -h * 0.27), const Color(0xFF424242), w: 2);
    _label(canvas, 'CO₂\n(PEP-case)', Offset(mesX - cellW * 0.48, -h * 0.27), fs: 7.5, c: const Color(0xFF424242));

    // Transport arrow (Malate → bundle sheath)
    if (step >= 2) {
      final animX = mesX + cellW * 0.5 + (bsX - mesX - cellW) * ((t + 0.5) % 1.0);
      canvas.drawCircle(Offset(animX, h * 0.1), 5, _fill(const Color(0xFF7B1FA2)));
      _arrow(canvas, Offset(mesX + cellW * 0.5, h * 0.1), Offset(bsX - cellW * 0.5, h * 0.1),
          const Color(0xFF7B1FA2), w: 2);
      _label(canvas, 'Malate', Offset((mesX + bsX) / 2, h * 0.1 - 12), fs: 8, c: const Color(0xFF7B1FA2));
    }

    // Bundle sheath contents
    final bsItems = ['Malate (4C)', 'Pyruvate + CO₂', 'Calvin Cycle', '→ Starch'];
    for (int i = 0; i < 3; i++) {
      final y = -h * 0.22 + i * h * 0.18;
      final c = i == 0 ? const Color(0xFF7B1FA2) : i == 1 ? const Color(0xFFE65100) : _kPhoto;
      canvas.drawRRect(RRect.fromRectXY(Rect.fromCenter(center: Offset(bsX, y), width: cellW * 0.8, height: h * 0.12), 6, 6),
          _fill(c.withOpacity(0.2)));
      _label(canvas, bsItems[i], Offset(bsX, y), fs: 8.5, c: c);
      if (i < 2) _arrow(canvas, Offset(bsX, y + h * 0.07), Offset(bsX, y + h * 0.11), c, w: 1.5);
    }
    // Pyruvate back
    if (step >= 5) {
      _arrow(canvas, Offset(bsX - cellW * 0.5, h * 0.26), Offset(mesX + cellW * 0.5, h * 0.26),
          const Color(0xFF795548), w: 2);
      _label(canvas, 'Pyruvate', Offset((mesX + bsX) / 2, h * 0.26 + 12), fs: 8, c: const Color(0xFF795548));
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_C4CyclePainter o) => o.step != step || o.t != t;
}

// ─────────────────────────────────────────────────────────────────────────────
// 14. OXIDATIVE PHOSPHORYLATION (ETC)
// ─────────────────────────────────────────────────────────────────────────────
class _OxPhosphoPainter extends CustomPainter {
  final int step; final double t;
  _OxPhosphoPainter(this.step, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), _fill(_kBg));
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);

    final w = size.width, h = size.height;
    final memY = h * 0.05, memH = h * 0.1;

    // Inner mitochondrial membrane
    canvas.drawRect(Rect.fromCenter(center: Offset(0, memY), width: w * 0.92, height: memH),
        _fill(const Color(0xFFFFE0B2)));
    canvas.drawRect(Rect.fromCenter(center: Offset(0, memY), width: w * 0.92, height: memH),
        _stroke(const Color(0xFFE65100), w: 1.5));
    _label(canvas, 'Inner Mitochondrial Membrane', Offset(0, memY + memH * 0.5 + 10), fs: 7.5, c: const Color(0xFFE65100));

    // Intermembrane space (above)
    _label(canvas, 'Intermembrane Space (H⁺ high)', Offset(0, memY - h * 0.18), fs: 8, c: const Color(0xFFBF360C));
    // Matrix (below)
    _label(canvas, 'Matrix', Offset(0, memY + h * 0.28), fs: 8, c: const Color(0xFF2E7D32));

    // Complexes
    final complexes = [
      ('I', 'NADH\nDH', const Color(0xFF1565C0), -w * 0.33),
      ('II', 'Succ\nDH', const Color(0xFF7B1FA2), -w * 0.18),
      ('III', 'Cyt bc1', const Color(0xFF00838F), w * 0.02),
      ('IV', 'Cyt Ox', const Color(0xFFC62828), w * 0.18),
      ('V', 'ATP\nSynth', const Color(0xFF2E7D32), w * 0.35),
    ];
    final cW = w * 0.1, cH = memH * 1.1;

    for (int i = 0; i < complexes.length; i++) {
      final (num, label, color, cx) = complexes[i];
      final isActive = i == step % complexes.length;
      canvas.drawRRect(
        RRect.fromRectXY(Rect.fromCenter(center: Offset(cx, memY), width: cW, height: cH), 4, 4),
        _fill(color.withOpacity(isActive ? 0.8 : 0.45)));
      _label(canvas, num, Offset(cx, memY - memH * 0.1), fs: isActive ? 9 : 7.5, bold: true, c: Colors.white);
      _label(canvas, label, Offset(cx, memY + memH * 0.8), fs: 7, c: color);
      // H+ pumping arrows (not complex II)
      if (i != 1 && i != 4) {
        final arrowY = memY - memH * 0.7 - (isActive ? 8 * math.sin(t * 2 * math.pi) : 0);
        _arrow(canvas, Offset(cx, memY - memH * 0.5), Offset(cx, arrowY - 8), const Color(0xFFBF360C), w: 1.5);
        _label(canvas, 'H⁺', Offset(cx + 10, arrowY - 4), fs: 7, c: const Color(0xFFBF360C));
      }
    }

    // Electron flow (horizontal arrows below complexes)
    final carriers = ['NADH/FADH₂', 'CoQ', 'Cyt c', 'O₂→H₂O'];
    final arrowXs = [-w * 0.26, -w * 0.1, w * 0.1, w * 0.26];
    if (step >= 1) {
      for (int i = 0; i < 3; i++) {
        _arrow(canvas, Offset(arrowXs[i] - 6, memY + memH * 0.3), Offset(arrowXs[i] + 8, memY + memH * 0.3), _kGray, w: 1.5);
        _label(canvas, carriers[i + 1], Offset(arrowXs[i] + 4, memY + h * 0.12), fs: 7, c: _kGray);
      }
    }
    // Input
    _label(canvas, 'NADH / FADH₂', Offset(-w * 0.44, memY + memH * 0.3), fs: 7.5, c: _kMol);
    // Output
    _label(canvas, 'ATP', Offset(w * 0.28, memY + h * 0.22), fs: 9, bold: true, c: const Color(0xFF2E7D32));
    _label(canvas, 'H₂O', Offset(w * 0.22, memY - h * 0.22), fs: 9, bold: true, c: _kMol);

    canvas.restore();
  }

  @override
  bool shouldRepaint(_OxPhosphoPainter o) => o.step != step || o.t != t;
}

// ─────────────────────────────────────────────────────────────────────────────
// 15. COUNTER-CURRENT MECHANISM
// ─────────────────────────────────────────────────────────────────────────────
class _CounterCurrentPainter extends CustomPainter {
  final int step; final double t;
  _CounterCurrentPainter(this.step, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), _fill(_kBg));
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);

    final w = size.width, h = size.height;
    final tubeW = w * 0.09, loopH = h * 0.65, loopX = -w * 0.08;

    // Descending limb (left side of U)
    final descX = loopX - tubeW;
    canvas.drawRect(Rect.fromLTWH(descX - tubeW / 2, -loopH / 2, tubeW, loopH),
        _fill(const Color(0xFFE3F2FD)));
    canvas.drawRect(Rect.fromLTWH(descX - tubeW / 2, -loopH / 2, tubeW, loopH),
        _stroke(_kMol, w: 1.5));
    _label(canvas, 'Descending\nLimb', Offset(descX, -loopH / 2 - 14), fs: 8, bold: true, c: _kMol);
    _label(canvas, 'H₂O\n permeable', Offset(descX - tubeW * 1.5 - 8, 0), fs: 7.5, c: _kMol, align: TextAlign.right);

    // Hairpin bottom
    canvas.drawArc(Rect.fromCenter(center: Offset(loopX, loopH / 2), width: tubeW * 3, height: loopH * 0.2),
        0, math.pi, false, _stroke(_kExcr, w: 2));

    // Ascending limb (right side of U)
    final ascX = loopX + tubeW;
    canvas.drawRect(Rect.fromLTWH(ascX - tubeW / 2, -loopH / 2, tubeW, loopH),
        _fill(const Color(0xFFFFF9C4)));
    canvas.drawRect(Rect.fromLTWH(ascX - tubeW / 2, -loopH / 2, tubeW, loopH),
        _stroke(const Color(0xFFE65100), w: 1.5));
    _label(canvas, 'Ascending\nLimb', Offset(ascX, -loopH / 2 - 14), fs: 8, bold: true, c: const Color(0xFFE65100));
    _label(canvas, 'NaCl\npumped out', Offset(ascX + tubeW * 1.5 + 8, 0), fs: 7.5, c: const Color(0xFFE65100));

    // Osmolarity gradient bars (right side)
    final osmX = w * 0.28;
    final osmLevels = ['300\nmOsm', '600\nmOsm', '900\nmOsm', '1200\nmOsm'];
    for (int i = 0; i < 4; i++) {
      final y = -loopH * 0.42 + i * loopH * 0.28;
      final barW = w * 0.04 + w * 0.08 * i / 3;
      canvas.drawRect(Rect.fromCenter(center: Offset(osmX, y), width: barW, height: loopH * 0.2),
          _fill(const Color(0xFF7B1FA2).withOpacity(0.1 + 0.25 * i / 3)));
      canvas.drawRect(Rect.fromCenter(center: Offset(osmX, y), width: barW, height: loopH * 0.2),
          _stroke(const Color(0xFF7B1FA2), w: 1));
      _label(canvas, osmLevels[i], Offset(osmX + barW / 2 + 22, y), fs: 7.5, c: const Color(0xFF7B1FA2));
    }
    _label(canvas, 'Osmotic\nGradient', Offset(osmX, loopH * 0.48), fs: 8, bold: true, c: const Color(0xFF7B1FA2));
    _arrow(canvas, Offset(osmX - 6, -loopH * 0.4), Offset(osmX - 6, loopH * 0.4), const Color(0xFF7B1FA2), w: 1.5);

    // Water arrows on descending limb (step >= 1)
    if (step >= 1) {
      for (int i = 0; i < 3; i++) {
        final y = -loopH * 0.25 + i * loopH * 0.22;
        final flowX = descX - tubeW * 0.5 - (15 * ((t + i / 3.0) % 1.0));
        _arrow(canvas, Offset(descX - tubeW * 0.5, y), Offset(descX - tubeW * 1.5, y),
            _kMol.withOpacity(0.6), w: 1.5);
      }
    }

    // Na+ arrows from ascending limb (step >= 3)
    if (step >= 3) {
      for (int i = 0; i < 3; i++) {
        final y = -loopH * 0.25 + i * loopH * 0.22;
        _arrow(canvas, Offset(ascX + tubeW * 0.5, y), Offset(ascX + tubeW * 1.5, y),
            const Color(0xFFE65100).withOpacity(0.7), w: 1.5);
      }
    }

    // ADH label (step >= 6)
    if (step >= 6) {
      canvas.drawRRect(
        RRect.fromRectXY(Rect.fromCenter(center: Offset(-w * 0.38, -h * 0.32), width: w * 0.2, height: h * 0.18), 8, 8),
        _fill(const Color(0xFF9C27B0).withOpacity(0.15)));
      _label(canvas, 'ADH\n→ AQP-2\n→ H₂O reabs', Offset(-w * 0.38, -h * 0.32), fs: 8, bold: true, c: _kNeuro);
    }

    // Region labels
    _label(canvas, 'Cortex', Offset(-w * 0.45, -loopH * 0.43), fs: 8, c: _kGray);
    _label(canvas, 'Medulla', Offset(-w * 0.45, loopH * 0.38), fs: 8, c: _kGray);
    _dashedLine(canvas, Offset(-w * 0.48, 0), Offset(osmX + w * 0.1, 0), _kGray.withOpacity(0.4), w: 1);

    canvas.restore();
  }

  @override
  bool shouldRepaint(_CounterCurrentPainter o) => o.step != step || o.t != t;
}

// ─────────────────────────────────────────────────────────────────────────────
// 16. HORMONE MECHANISM
// ─────────────────────────────────────────────────────────────────────────────
class _HormonePainter extends CustomPainter {
  final int step; final double t;
  _HormonePainter(this.step, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), _fill(_kBg));
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);

    final w = size.width, h = size.height;

    // Determine which pathway to highlight
    final showPeptide = step <= 3 || step == 4;
    final showSteroid = step >= 5;

    // ── Left: Peptide / Water-soluble ──────────────────────────────
    final pepX = -w * 0.26;
    const c1 = Color(0xFF1565C0);
    _label(canvas, 'Peptide Hormone\n(Water-soluble)', Offset(pepX, -h * 0.44), fs: 8.5,
        bold: showPeptide, c: showPeptide ? c1 : _kGray);

    // Cell membrane
    canvas.drawRRect(RRect.fromRectXY(Rect.fromCenter(center: Offset(pepX, -h * 0.12), width: w * 0.38, height: h * 0.06), 4, 4),
        _fill(const Color(0xFF80CBC4).withOpacity(showPeptide ? 0.6 : 0.2)));
    _label(canvas, 'Cell Membrane', Offset(pepX, -h * 0.12), fs: 7.5, c: const Color(0xFF00695C));

    // Hormone (cannot enter)
    canvas.drawCircle(Offset(pepX, -h * 0.28), 10, _fill(c1.withOpacity(showPeptide ? 0.8 : 0.3)));
    _label(canvas, 'H', Offset(pepX, -h * 0.28), fs: 8, bold: true, c: Colors.white);
    // Receptor on membrane
    canvas.drawOval(Rect.fromCenter(center: Offset(pepX + 14, -h * 0.12), width: 14, height: 20),
        _fill(const Color(0xFF7B1FA2).withOpacity(showPeptide ? 0.7 : 0.2)));
    _label(canvas, 'R', Offset(pepX + 14, -h * 0.12), fs: 7, bold: true, c: Colors.white);

    if (step >= 2 && showPeptide) {
      // cAMP cascade
      _arrow(canvas, Offset(pepX, -h * 0.07), Offset(pepX, h * 0.02), c1, w: 2);
      _label(canvas, 'G-protein\n→ cAMP', Offset(pepX - 32, h * 0.04), fs: 8, c: const Color(0xFFE65100));
      _arrow(canvas, Offset(pepX, h * 0.09), Offset(pepX, h * 0.18), c1, w: 2);
      _label(canvas, 'PKA\nactivated', Offset(pepX + 30, h * 0.14), fs: 8, c: c1);
      _arrow(canvas, Offset(pepX, h * 0.24), Offset(pepX, h * 0.33), c1, w: 2);
      _label(canvas, 'Rapid\nResponse', Offset(pepX - 32, h * 0.35), fs: 8, bold: true, c: const Color(0xFF2E7D32));
    }

    // ── Right: Steroid / Lipid-soluble ─────────────────────────────
    final sterX = w * 0.26;
    const c2 = Color(0xFFE65100);
    _label(canvas, 'Steroid Hormone\n(Lipid-soluble)', Offset(sterX, -h * 0.44), fs: 8.5,
        bold: showSteroid, c: showSteroid ? c2 : _kGray);

    canvas.drawRRect(RRect.fromRectXY(Rect.fromCenter(center: Offset(sterX, -h * 0.12), width: w * 0.38, height: h * 0.06), 4, 4),
        _fill(const Color(0xFF80CBC4).withOpacity(showSteroid ? 0.6 : 0.2)));

    // Hormone entering cell
    final hormPosX = showSteroid ? sterX - 12 + (step >= 6 ? 24 : 0) : sterX - 20;
    canvas.drawCircle(Offset(hormPosX, -h * 0.28 + (step >= 5 ? (h * 0.22 * (t.clamp(0, 1))) : 0)), 10,
        _fill(c2.withOpacity(showSteroid ? 0.8 : 0.3)));
    _label(canvas, 'H', Offset(hormPosX, -h * 0.28 + (step >= 5 ? h * 0.22 * t.clamp(0, 1) : 0)),
        fs: 8, bold: true, c: Colors.white);

    if (step >= 6) {
      // Nucleus
      canvas.drawOval(Rect.fromCenter(center: Offset(sterX, h * 0.15), width: w * 0.24, height: h * 0.2),
          _fill(const Color(0xFFBBDEFB)));
      canvas.drawOval(Rect.fromCenter(center: Offset(sterX, h * 0.15), width: w * 0.24, height: h * 0.2),
          _stroke(c2, w: 1.5));
      _label(canvas, 'Nucleus\n→ HRE', Offset(sterX, h * 0.15), fs: 8, bold: true, c: c2);
      _arrow(canvas, Offset(sterX, h * 0.27), Offset(sterX, h * 0.37), c2, w: 2);
      _label(canvas, 'Gene\nExpression\n(Slow)', Offset(sterX, h * 0.44), fs: 8, bold: true, c: const Color(0xFF2E7D32));
    }

    // Divider
    _dashedLine(canvas, Offset(0, -h * 0.46), Offset(0, h * 0.46), _kGray.withOpacity(0.3), w: 1);

    canvas.restore();
  }

  @override
  bool shouldRepaint(_HormonePainter o) => o.step != step || o.t != t;
}
