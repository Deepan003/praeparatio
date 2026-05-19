import 'dart:math' as math;
import 'package:flutter/material.dart';

part 'bio_diagram_painter_2.dart';

// ── Registry ──────────────────────────────────────────────────────────────────
// Returns a diagram Widget or null (null = screen falls back to step cards).
Widget? buildBioDiagram(String id, int step, double t) {
  switch (id) {
    // ── Existing 16 ──────────────────────────────────────────────
    case 'mitosis':              return _DiagramCanvas(painter: _MitosisPainter(step, t));
    case 'meiosis':              return _DiagramCanvas(painter: _MeiosisPainter(step, t));
    case 'dna_double_helix':     return _DiagramCanvas(painter: _DNAHelixPainter(step, t));
    case 'replication':          return _DiagramCanvas(painter: _ReplicationPainter(step, t));
    case 'transcription':        return _DiagramCanvas(painter: _TranscriptionPainter(step, t));
    case 'translation':          return _DiagramCanvas(painter: _TranslationPainter(step, t));
    case 'blood_circulation':    return _DiagramCanvas(painter: _HeartPainter(step, t));
    case 'action_potential':     return _DiagramCanvas(painter: _ActionPotentialPainter(step, t));
    case 'sliding_filament':     return _DiagramCanvas(painter: _SarcomrePainter(step, t));
    case 'pcr':                  return _DiagramCanvas(painter: _PCRPainter(step, t));
    case 'lac_operon':           return _DiagramCanvas(painter: _LacOperonPainter(step, t));
    case 'spermatogenesis':      return _DiagramCanvas(painter: _SpermatogenesisPainter(step, t));
    case 'oogenesis':            return _DiagramCanvas(painter: _OogenesisPainter(step, t));
    case 'gel_electrophoresis':  return _DiagramCanvas(painter: _GelElectroPainter(step, t));
    case 'meselson_stahl':       return _DiagramCanvas(painter: _MeselsonPainter(step, t));
    case 'z_scheme':             return _DiagramCanvas(painter: _ZSchemePainter(step, t));
    // ── New 16 ───────────────────────────────────────────────────
    case 'megasporogenesis':     return _DiagramCanvas(painter: _MegasporogenesisPainter(step, t));
    case 'double_fertilization': return _DiagramCanvas(painter: _DoubleFertilizationPainter(step, t));
    case 'embryo_development':   return _DiagramCanvas(painter: _EmbryoDevelopmentPainter(step, t));
    case 'placenta':             return _DiagramCanvas(painter: _PlacentaPainter(step, t));
    case 'griffith':             return _DiagramCanvas(painter: _GriffithPainter(step, t));
    case 'hershey_chase':        return _DiagramCanvas(painter: _HersheyPainter(step, t));
    case 'rdna':                 return _DiagramCanvas(painter: _RDNAPainter(step, t));
    case 'micropropagation':     return _DiagramCanvas(painter: _MicropropagationPainter(step, t));
    case 'bryophyta_lifecycle':  return _DiagramCanvas(painter: _BryophytaPainter(step, t));
    case 'pteridophyta_lifecycle': return _DiagramCanvas(painter: _PteridophytaPainter(step, t));
    case 'chemiosmotic':         return _DiagramCanvas(painter: _ChemiosmoticPainter(step, t));
    case 'c3_cycle':             return _DiagramCanvas(painter: _C3CyclePainter(step, t));
    case 'c4_cycle':             return _DiagramCanvas(painter: _C4CyclePainter(step, t));
    case 'oxidative_phosphorylation': return _DiagramCanvas(painter: _OxPhosphoPainter(step, t));
    case 'counter_current':      return _DiagramCanvas(painter: _CounterCurrentPainter(step, t));
    case 'hormone_mechanism':    return _DiagramCanvas(painter: _HormonePainter(step, t));
    default:                     return null;
  }
}

// ── Canvas wrapper ─────────────────────────────────────────────────────────────
class _DiagramCanvas extends StatelessWidget {
  final CustomPainter painter;
  const _DiagramCanvas({required this.painter});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, c) {
      final h = math.min(c.maxWidth * 0.90, 520.0); // extra height = room for all labels
      // RepaintBoundary isolates the 60fps canvas from parent tree repaints
      return RepaintBoundary(
        child: Container(
        width: double.infinity,
        height: h,
        decoration: BoxDecoration(
          color: const Color(0xFFF0F9FF), // subtle science-tinted bg
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFBFDBFE), width: 1.2),
          boxShadow: const [BoxShadow(color: Color(0x0A3B82F6), blurRadius: 8, offset: Offset(0, 2))],
        ),
        clipBehavior: Clip.hardEdge,
        child: CustomPaint(painter: painter, size: Size(c.maxWidth, h)),
      ));
    });
  }
}

// ── Shared drawing helpers ─────────────────────────────────────────────────────

Paint _fill(Color c) => Paint()..color = c..style = PaintingStyle.fill;
Paint _stroke(Color c, {double w = 1.5}) =>
    Paint()..color = c..style = PaintingStyle.stroke..strokeWidth = w..strokeCap = StrokeCap.round;

void _label(Canvas canvas, String text, Offset pos,
    {double fs = 10, Color c = const Color(0xFF2D3436), bool bold = false, TextAlign align = TextAlign.center, double maxW = 200}) {
  final tp = TextPainter(
    text: TextSpan(
        text: text,
        style: TextStyle(fontSize: fs, color: c, fontWeight: bold ? FontWeight.w700 : FontWeight.w500, height: 1.3)),
    textDirection: TextDirection.ltr,
    textAlign: align,
  )..layout(maxWidth: maxW);
  // Semi-transparent pill behind text so it reads cleanly on any diagram bg
  final rect = Rect.fromCenter(center: pos, width: tp.width + 6, height: tp.height + 2);
  canvas.drawRRect(
    RRect.fromRectAndRadius(rect, const Radius.circular(3)),
    Paint()..color = const Color(0xE8FFFFFF),
  );
  tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
}

void _arrow(Canvas canvas, Offset from, Offset to, Color c, {double w = 1.5}) {
  final p = _stroke(c, w: w);
  canvas.drawLine(from, to, p);
  final angle = math.atan2(to.dy - from.dy, to.dx - from.dx);
  const l = 8.0;
  canvas.drawLine(to, to + Offset(math.cos(angle - 2.5) * l, math.sin(angle - 2.5) * l), p);
  canvas.drawLine(to, to + Offset(math.cos(angle + 2.5) * l, math.sin(angle + 2.5) * l), p);
}

void _cell(Canvas canvas, Rect r, Color fill, Color stroke, {double rxy = 1.0}) {
  final rr = RRect.fromRectXY(r, r.width / 2 * rxy, r.height / 2 * rxy);
  canvas.drawRRect(rr, _fill(fill));
  canvas.drawRRect(rr, _stroke(stroke, w: 2));
}

void _chromosome(Canvas canvas, Offset c, double s, Color col) {
  final p = _stroke(col, w: 3);
  // X shape
  canvas.drawLine(c + Offset(-s, -s), c + Offset(s, s), p);
  canvas.drawLine(c + Offset(s, -s), c + Offset(-s, s), p);
  // centromere
  canvas.drawCircle(c, s * 0.25, _fill(col.withOpacity(0.5)));
}

void _nucleus(Canvas canvas, Offset c, double r, {Color fill = const Color(0xFFBBDEFB), Color stroke = const Color(0xFF1565C0)}) {
  canvas.drawCircle(c, r, _fill(fill));
  canvas.drawCircle(c, r, _stroke(stroke, w: 1.5));
}

void _dashedLine(Canvas canvas, Offset from, Offset to, Color c, {double dash = 6, double gap = 4, double w = 1.5}) {
  final dir = (to - from);
  final len = dir.distance;
  final unit = dir / len;
  double pos = 0;
  bool drawing = true;
  while (pos < len) {
    final next = math.min(pos + (drawing ? dash : gap), len);
    if (drawing) canvas.drawLine(from + unit * pos, from + unit * next, _stroke(c, w: w));
    pos = next;
    drawing = !drawing;
  }
}

double _lerp(double a, double b, double t) => a + (b - a) * t;

// ═══════════════════════════════════════════════════════════════════════════════
// 1. MITOSIS
// ═══════════════════════════════════════════════════════════════════════════════
class _MitosisPainter extends CustomPainter {
  final int step; final double t;
  _MitosisPainter(this.step, this.t);

  @override
  void paint(Canvas canvas, Size s) {
    final cx = s.width / 2; final cy = s.height / 2;
    final sc = math.min(s.width / 420, s.height / 310);
    canvas.save(); canvas.translate(cx, cy); canvas.scale(sc);

    // Cell outer
    const cellW = 190.0; const cellH = 145.0;
    final cellR = Rect.fromCenter(center: Offset.zero, width: cellW, height: cellH);

    switch (step) {
      case 0: // G1 interphase
        canvas.drawOval(cellR, _fill(const Color(0xFFE3F2FD)));
        canvas.drawOval(cellR, _stroke(const Color(0xFF90A4AE), w: 2));
        _nucleus(canvas, Offset.zero, 42);
        // chromatin
        for (int i = 0; i < 6; i++) {
          final a = i * math.pi / 3;
          canvas.drawCircle(Offset(28 * math.cos(a), 22 * math.sin(a)), 5, _fill(const Color(0xFFEF9A9A)));
        }
        _label(canvas, 'Interphase', const Offset(0, 90), fs: 11, bold: true);
        _label(canvas, 'Nucleus', const Offset(65, -15), fs: 8, c: const Color(0xFF1565C0));
        _label(canvas, 'Chromatin', const Offset(0, 0), fs: 8, c: const Color(0xFFC62828));
      case 1: // Prophase
        canvas.drawOval(cellR, _fill(const Color(0xFFF3E5F5)));
        canvas.drawOval(cellR, _stroke(const Color(0xFFAB47BC), w: 2));
        // condensed chromosomes (X shapes)
        final positions = [const Offset(-40, -20), const Offset(40, -20), const Offset(-40, 20), const Offset(40, 20), const Offset(0, -35), const Offset(0, 35)];
        for (final p in positions) _chromosome(canvas, p, 14, const Color(0xFFAD1457));
        // nuclear envelope breaking - dashed circle fading
        _dashedLine(canvas, const Offset(-40, -42), const Offset(40, -42), const Color(0xFF1565C0).withOpacity(0.4));
        _label(canvas, 'Prophase', const Offset(0, 90), fs: 11, bold: true);
        _label(canvas, 'Chromosomes\ncondensing', const Offset(0, -78), fs: 8, c: const Color(0xFF880E4F));
        _label(canvas, 'Nuclear\nenvelope breaks', const Offset(0, 68), fs: 8, c: const Color(0xFF1565C0));
      case 2: // Metaphase
        canvas.drawOval(cellR, _fill(const Color(0xFFF1F8E9)));
        canvas.drawOval(cellR, _stroke(const Color(0xFF558B2F), w: 2));
        // metaphase plate - vertical line
        _dashedLine(canvas, const Offset(0, -cellH / 2), const Offset(0, cellH / 2), const Color(0xFF33691E));
        // chromosomes at plate
        for (int i = -1; i <= 1; i++) {
          _chromosome(canvas, Offset(0, i * 32), 13, const Color(0xFFAD1457));
          // spindle fibers to poles
          _arrow(canvas, const Offset(-80, 0), Offset(-14, i * 32.0), const Color(0xFF2E7D32));
          _arrow(canvas, const Offset(80, 0), Offset(14, i * 32.0), const Color(0xFF2E7D32));
        }
        _label(canvas, 'Metaphase', const Offset(0, 90), fs: 11, bold: true);
        _label(canvas, 'Metaphase\nplate', const Offset(30, -68), fs: 8, c: const Color(0xFF33691E));
        _label(canvas, 'Spindle\nfibres', const Offset(-95, 15), fs: 8, c: const Color(0xFF2E7D32));
      case 3: // Anaphase
        canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: cellW, height: cellH + 30), _fill(const Color(0xFFFFF8E1)));
        canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: cellW, height: cellH + 30), _stroke(const Color(0xFFF9A825), w: 2));
        // chromatids moving to poles
        for (int i = -1; i <= 1; i++) {
          _chromosome(canvas, Offset(i * 15.0, -55), 11, const Color(0xFFAD1457));
          _chromosome(canvas, Offset(i * 15.0, 55), 11, const Color(0xFFAD1457));
        }
        _arrow(canvas, const Offset(0, -20), const Offset(0, -48), const Color(0xFFF57F17), w: 2);
        _arrow(canvas, const Offset(0, 20), const Offset(0, 48), const Color(0xFFF57F17), w: 2);
        _label(canvas, 'Anaphase', const Offset(0, 100), fs: 11, bold: true);
        _label(canvas, 'Chromatids\nseparating', const Offset(90, 0), fs: 8, c: const Color(0xFFE65100));
      case 4: // Telophase
        final topCell = Rect.fromCenter(center: const Offset(0, -50), width: 150, height: 100);
        final botCell = Rect.fromCenter(center: const Offset(0, 50), width: 150, height: 100);
        canvas.drawOval(topCell, _fill(const Color(0xFFE1F5FE)));
        canvas.drawOval(topCell, _stroke(const Color(0xFF0277BD), w: 2));
        canvas.drawOval(botCell, _fill(const Color(0xFFE1F5FE)));
        canvas.drawOval(botCell, _stroke(const Color(0xFF0277BD), w: 2));
        _nucleus(canvas, const Offset(0, -50), 28, fill: const Color(0xFF90CAF9), stroke: const Color(0xFF1565C0));
        _nucleus(canvas, const Offset(0, 50), 28, fill: const Color(0xFF90CAF9), stroke: const Color(0xFF1565C0));
        // cleavage furrow
        _dashedLine(canvas, const Offset(-80, 0), const Offset(80, 0), const Color(0xFF37474F), w: 2);
        _label(canvas, 'Telophase', const Offset(0, 115), fs: 11, bold: true);
        _label(canvas, 'Cleavage\nfurrow', const Offset(90, 0), fs: 8, c: const Color(0xFF37474F));
      case 5: // Cytokinesis
        final r1 = Rect.fromCenter(center: const Offset(0, -52), width: 145, height: 95);
        final r2 = Rect.fromCenter(center: const Offset(0, 52), width: 145, height: 95);
        for (final r in [r1, r2]) {
          canvas.drawOval(r, _fill(const Color(0xFFE8F5E9)));
          canvas.drawOval(r, _stroke(const Color(0xFF388E3C), w: 2));
          _nucleus(canvas, r.center, 26);
        }
        _label(canvas, 'Cytokinesis', const Offset(0, 115), fs: 11, bold: true);
        _label(canvas, '2 diploid\ndaughter cells', const Offset(0, -8), fs: 9, bold: true, c: const Color(0xFF1B5E20));
      case 6: // Done - same as cytokinesis but clear
        final rc1 = Rect.fromCenter(center: const Offset(-70, 0), width: 120, height: 90);
        final rc2 = Rect.fromCenter(center: const Offset(70, 0), width: 120, height: 90);
        for (final r in [rc1, rc2]) {
          canvas.drawOval(r, _fill(const Color(0xFFE8F5E9)));
          canvas.drawOval(r, _stroke(const Color(0xFF2E7D32), w: 2.5));
          _nucleus(canvas, r.center, 24);
        }
        _arrow(canvas, const Offset(-5, 0), const Offset(-55, 0), const Color(0xFF1B5E20));
        _arrow(canvas, const Offset(5, 0), const Offset(55, 0), const Color(0xFF1B5E20));
        _label(canvas, 'Result: 2 genetically\nidentical diploid cells (2n)', const Offset(0, 70), fs: 10, bold: true, c: const Color(0xFF1B5E20));
      default:
        _label(canvas, 'Mitosis', Offset.zero, fs: 14, bold: true);
    }
    canvas.restore();
  }

  @override bool shouldRepaint(covariant _MitosisPainter old) => old.step != step || old.t != t;
}

// ═══════════════════════════════════════════════════════════════════════════════
// 2. MEIOSIS
// ═══════════════════════════════════════════════════════════════════════════════
class _MeiosisPainter extends CustomPainter {
  final int step; final double t;
  _MeiosisPainter(this.step, this.t);

  @override
  void paint(Canvas canvas, Size s) {
    final cx = s.width / 2; final cy = s.height / 2;
    canvas.save(); canvas.translate(cx, cy);
    final sc = math.min(s.width / 420, s.height / 310);
    canvas.scale(sc);

    void drawCell(Offset center, double w, double h, Color fill, Color stroke) {
      canvas.drawOval(Rect.fromCenter(center: center, width: w, height: h), _fill(fill));
      canvas.drawOval(Rect.fromCenter(center: center, width: w, height: h), _stroke(stroke, w: 2));
    }

    switch (step) {
      case 0: // Prophase I - synapsis, bivalents
        drawCell(Offset.zero, 185, 145, const Color(0xFFF3E5F5), const Color(0xFFAB47BC));
        // bivalents (pairs of homologs)
        final bPos = [const Offset(-35, -25), const Offset(35, -25), const Offset(-35, 25), const Offset(35, 25)];
        for (final p in bPos) {
          _chromosome(canvas, p + const Offset(-8, 0), 12, const Color(0xFFE53935));
          _chromosome(canvas, p + const Offset(8, 0), 12, const Color(0xFF1E88E5));
          // chiasma connection
          canvas.drawLine(p + const Offset(-4, 0), p + const Offset(4, 0), _stroke(const Color(0xFF6A1B9A), w: 2));
        }
        _label(canvas, 'Prophase I', const Offset(0, 88), fs: 11, bold: true);
        _label(canvas, 'Bivalents\n(crossing over)', const Offset(0, -80), fs: 8, c: const Color(0xFF6A1B9A));
        _label(canvas, '■ Maternal  ■ Paternal', const Offset(0, 68), fs: 8);
      case 1: // Metaphase I
        drawCell(Offset.zero, 185, 145, const Color(0xFFF1F8E9), const Color(0xFF558B2F));
        _dashedLine(canvas, const Offset(0, -75), const Offset(0, 75), const Color(0xFF33691E));
        // bivalents at plate
        for (int i = -1; i <= 1; i++) {
          final y = i * 35.0;
          _chromosome(canvas, Offset(-12, y), 12, const Color(0xFFE53935));
          _chromosome(canvas, Offset(12, y), 12, const Color(0xFF1E88E5));
          _arrow(canvas, Offset(-85, y), Offset(-25, y), const Color(0xFF2E7D32));
          _arrow(canvas, Offset(85, y), Offset(25, y), const Color(0xFF2E7D32));
        }
        _label(canvas, 'Metaphase I', const Offset(0, 88), fs: 11, bold: true);
        _label(canvas, 'Bivalents at\nmetaphase plate', const Offset(0, -82), fs: 8);
      case 2: // Anaphase I - homologs separate
        drawCell(Offset.zero, 185, 165, const Color(0xFFFFF8E1), const Color(0xFFF9A825));
        for (int i = -1; i <= 1; i++) {
          _chromosome(canvas, Offset(i * 15.0, -60), 12, const Color(0xFFE53935));
          _chromosome(canvas, Offset(i * 15.0, 60), 12, const Color(0xFF1E88E5));
        }
        _arrow(canvas, const Offset(0, -20), const Offset(0, -50), const Color(0xFFF57F17), w: 2.5);
        _arrow(canvas, const Offset(0, 20), const Offset(0, 50), const Color(0xFFF57F17), w: 2.5);
        _label(canvas, 'Anaphase I', const Offset(0, 100), fs: 11, bold: true);
        _label(canvas, 'Homologs\nseparate (reductional)', const Offset(0, -88), fs: 8, c: const Color(0xFFE65100));
      case 3: // After Meiosis I - two cells
        for (int side = -1; side <= 1; side += 2) {
          final cx2 = side * 88.0;
          drawCell(Offset(cx2, 0), 140, 110, const Color(0xFFE3F2FD), const Color(0xFF1565C0));
          _chromosome(canvas, Offset(cx2 - 20, -15), 11, side == -1 ? const Color(0xFFE53935) : const Color(0xFF1E88E5));
          _chromosome(canvas, Offset(cx2 + 20, -15), 11, side == -1 ? const Color(0xFFE53935) : const Color(0xFF1E88E5));
          _chromosome(canvas, Offset(cx2, 15), 11, side == -1 ? const Color(0xFFE53935) : const Color(0xFF1E88E5));
          _label(canvas, 'n\n(haploid)', Offset(cx2, 68), fs: 9);
        }
        _label(canvas, 'After Meiosis I: 2 haploid cells', const Offset(0, 90), fs: 10, bold: true);
      case 4: // Meiosis II - like mitosis
        for (int side = -1; side <= 1; side += 2) {
          final cx2 = side * 88.0;
          drawCell(Offset(cx2, 0), 140, 110, const Color(0xFFFFF3E0), const Color(0xFFE65100));
          // aligned at plate
          for (int i = -1; i <= 1; i++) {
            _chromosome(canvas, Offset(cx2, i * 25.0), 10, side == -1 ? const Color(0xFFE53935) : const Color(0xFF1E88E5));
          }
          _dashedLine(canvas, Offset(cx2, -55), Offset(cx2, 55), const Color(0xFFBF360C));
        }
        _label(canvas, 'Metaphase II (both cells)', const Offset(0, 88), fs: 10, bold: true);
      case 5: // Result - 4 haploid cells
        final pos4 = [const Offset(-120, -50), const Offset(-40, -50), const Offset(40, -50), const Offset(120, -50)];
        final cols = [const Color(0xFFE53935), const Color(0xFF1E88E5), const Color(0xFF1E88E5), const Color(0xFFE53935)];
        for (int i = 0; i < 4; i++) {
          drawCell(pos4[i], 70, 65, const Color(0xFFE8F5E9), const Color(0xFF388E3C));
          _nucleus(canvas, pos4[i], 18, fill: cols[i].withOpacity(0.3), stroke: cols[i]);
          _label(canvas, 'n', pos4[i] + const Offset(0, 0), fs: 11, bold: true, c: const Color(0xFF1B5E20));
        }
        _label(canvas, '4 haploid cells (genetically variable)', const Offset(0, 65), fs: 10, bold: true, c: const Color(0xFF1B5E20));
        _label(canvas, 'Meiosis complete — restores ploidy after fertilisation', const Offset(0, 88), fs: 8.5, c: const Color(0xFF37474F));
      default:
        _label(canvas, 'Meiosis', Offset.zero, fs: 14, bold: true);
    }
    canvas.restore();
  }

  @override bool shouldRepaint(covariant _MeiosisPainter old) => old.step != step;
}

// ═══════════════════════════════════════════════════════════════════════════════
// 3. DNA DOUBLE HELIX
// ═══════════════════════════════════════════════════════════════════════════════
class _DNAHelixPainter extends CustomPainter {
  final int step; final double t;
  _DNAHelixPainter(this.step, this.t);

  @override
  void paint(Canvas canvas, Size s) {
    final cx = s.width / 2; final cy = s.height / 2;
    canvas.save(); canvas.translate(cx, cy);

    const amp = 55.0; const turns = 3; const pairs = 18;
    final hh = s.height * 0.4;
    final offset = step == 0 ? t * math.pi : step * math.pi * 0.5;

    // Determine what to show per step
    final showBackbone = step >= 0;
    final showBases = step >= 2;
    final showLabels = step >= 3;
    final showMajorMinor = step >= 4;

    if (showBackbone) {
      // Draw two backbones
      final path1 = Path(); final path2 = Path();
      final bp1 = _stroke(const Color(0xFF7B1FA2), w: 3);
      final bp2 = _stroke(const Color(0xFF00838F), w: 3);
      for (int i = 0; i <= 100; i++) {
        final frac = i / 100;
        final angle = frac * turns * 2 * math.pi + offset;
        final y = (frac - 0.5) * hh * 2;
        final x1 = amp * math.cos(angle);
        final x2 = amp * math.cos(angle + math.pi);
        if (i == 0) {
          path1.moveTo(x1, y); path2.moveTo(x2, y);
        } else {
          path1.lineTo(x1, y); path2.lineTo(x2, y);
        }
      }
      canvas.drawPath(path1, bp1);
      canvas.drawPath(path2, bp2);
    }

    if (showBases) {
      // Base pair rungs
      for (int i = 0; i < pairs; i++) {
        final frac = (i + 0.5) / pairs;
        final angle = frac * turns * 2 * math.pi + offset;
        final y = (frac - 0.5) * hh * 2;
        final x1 = amp * math.cos(angle);
        final x2 = amp * math.cos(angle + math.pi);
        // Color: A-T blue, G-C red (alternating)
        final isAT = i % 2 == 0;
        final bc = isAT ? const Color(0xFF1E88E5) : const Color(0xFFE53935);
        canvas.drawLine(Offset(x1, y), Offset(x2, y), _stroke(bc, w: 2));
        // Small circles at attachment
        canvas.drawCircle(Offset(x1, y), 4, _fill(bc));
        canvas.drawCircle(Offset(x2, y), 4, _fill(bc));
      }
    }

    // Labels based on step
    if (showLabels) {
      _label(canvas, "5'", Offset(-amp - 18, -hh), fs: 11, bold: true, c: const Color(0xFF7B1FA2));
      _label(canvas, "3'", Offset(-amp - 18, hh), fs: 11, bold: true, c: const Color(0xFF7B1FA2));
      _label(canvas, "3'", Offset(amp + 18, -hh), fs: 11, bold: true, c: const Color(0xFF00838F));
      _label(canvas, "5'", Offset(amp + 18, hh), fs: 11, bold: true, c: const Color(0xFF00838F));
      _label(canvas, 'Antiparallel\nstrands', Offset(0, -hh - 20), fs: 9);
    }

    if (showMajorMinor) {
      // Annotate major/minor groove
      _arrow(canvas, const Offset(amp + 20, 0), const Offset(amp + 50, 0), const Color(0xFF37474F));
      _label(canvas, 'Major groove', const Offset(amp + 95, 0), fs: 8.5, c: const Color(0xFF37474F));
      _arrow(canvas, Offset(-amp - 20, hh * 0.3), Offset(-amp - 50, hh * 0.3), const Color(0xFF37474F));
      _label(canvas, 'Minor groove', Offset(-amp - 95, hh * 0.3), fs: 8.5, c: const Color(0xFF37474F));
    }

    // Step label at bottom
    const labels = ['Two polynucleotide strands', 'Antiparallel orientation (5\'→3\' / 3\'→5\')',
      'Base pair rungs\nA=T (blue) G≡C (red)', 'Polarity labels: 5\' and 3\' ends',
      'Major and minor grooves', '3.4 nm pitch · 2 nm diameter · 10 bp/turn',
      'Right-handed B-DNA helix (Watson & Crick, 1953)'];
    if (step < labels.length) {
      _label(canvas, labels[step], Offset(0, hh + 25), fs: 9.5, bold: step == 6, c: const Color(0xFF37474F));
    }

    canvas.restore();
  }

  @override bool shouldRepaint(covariant _DNAHelixPainter old) => old.step != step || old.t != t;
}

// ═══════════════════════════════════════════════════════════════════════════════
// 4. REPLICATION FORK
// ═══════════════════════════════════════════════════════════════════════════════
class _ReplicationPainter extends CustomPainter {
  final int step; final double t;
  _ReplicationPainter(this.step, this.t);

  @override
  void paint(Canvas canvas, Size s) {
    canvas.save();
    canvas.translate(s.width / 2, s.height / 2);
    final sc = math.min(s.width / 420, s.height / 310);
    canvas.scale(sc);

    const forkTip = Offset(60, 0); // fork opening point
    final forkOpen = step >= 1 ? 50.0 + step * 8 : 20.0;

    // Parent strands (coming from right)
    canvas.drawLine(const Offset(200, 0), forkTip, _stroke(const Color(0xFF7B1FA2), w: 3));
    canvas.drawLine(const Offset(200, 0), forkTip, _stroke(const Color(0xFF00838F), w: 3));

    if (step >= 1) {
      // Helicase at fork
      canvas.drawCircle(forkTip, 14, _fill(const Color(0xFFFF8F00)));
      canvas.drawCircle(forkTip, 14, _stroke(const Color(0xFFE65100), w: 1.5));
      _label(canvas, 'Helicase', forkTip + const Offset(0, 22), fs: 8, c: const Color(0xFFE65100), bold: true);
    }

    if (step >= 1) {
      // Separated strands going left (fork)
      final top = Offset(-140, -forkOpen);
      final bot = Offset(-140, forkOpen);
      canvas.drawLine(forkTip, top, _stroke(const Color(0xFF7B1FA2), w: 3));
      canvas.drawLine(forkTip, bot, _stroke(const Color(0xFF00838F), w: 3));
      // SSB proteins
      if (step >= 2) {
        for (double x = -20; x > -130; x -= 30) {
          canvas.drawCircle(Offset(x, -(forkOpen * (x + 140) / 200)), 5, _fill(const Color(0xFF90A4AE)));
          canvas.drawCircle(Offset(x, (forkOpen * (x + 140) / 200)), 5, _fill(const Color(0xFF90A4AE)));
        }
        _label(canvas, 'SSB', Offset(-80, -forkOpen - 15), fs: 8, c: const Color(0xFF546E7A));
      }
    }

    if (step >= 3) {
      // Leading strand (continuous synthesis)
      final leadEnd = Offset(-140, -forkOpen);
      canvas.drawLine(leadEnd, Offset(-120, -forkOpen - 5), _stroke(const Color(0xFF43A047), w: 4));
      _label(canvas, 'Leading strand\n(continuous)', Offset(-120, -forkOpen - 28), fs: 8, c: const Color(0xFF2E7D32), bold: true);
      // DNA Pol III on leading
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(-100, -forkOpen), width: 28, height: 20), const Radius.circular(5)), _fill(const Color(0xFF66BB6A)));
      _label(canvas, 'Pol III', Offset(-100, -forkOpen), fs: 7, c: Colors.white, bold: true);
    }

    if (step >= 4) {
      // Lagging strand (Okazaki fragments)
      final lagBase = forkOpen;
      for (int f = 0; f < 3; f++) {
        final startX = -30.0 - f * 40;
        final endX = startX - 35;
        final y = lagBase + 5;
        // Primer (RNA, red)
        canvas.drawLine(Offset(startX, y), Offset(startX - 8, y), _stroke(const Color(0xFFE53935), w: 4));
        // Okazaki fragment (green)
        canvas.drawLine(Offset(startX - 8, y), Offset(endX, y), _stroke(const Color(0xFF43A047), w: 4));
      }
      _label(canvas, 'Okazaki\nfragments', Offset(-80, lagBase + 25), fs: 8, c: const Color(0xFF2E7D32), bold: true);
      _label(canvas, 'RNA Primer', Offset(-30, lagBase + 25), fs: 7.5, c: const Color(0xFFE53935));
      _label(canvas, 'Lagging strand (discontinuous)', Offset(-80, lagBase + 45), fs: 8.5, c: const Color(0xFF37474F));
    }

    if (step >= 5) {
      // DNA Ligase
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(-95, forkOpen + 5), width: 30, height: 18), const Radius.circular(5)), _fill(const Color(0xFFFFA726)));
      _label(canvas, 'Ligase', Offset(-95, forkOpen + 5), fs: 7, c: Colors.white, bold: true);
    }

    if (step >= 6) {
      _label(canvas, '← 5\'       3\' →', Offset(-80, -forkOpen - 48), fs: 8, c: const Color(0xFF7B1FA2));
    }

    // Replication direction arrow
    if (step >= 1) {
      _arrow(canvas, const Offset(140, -30), const Offset(30, -30), const Color(0xFF37474F));
      _label(canvas, 'Replication fork\nmoves this way', const Offset(140, -48), fs: 7.5, c: const Color(0xFF37474F));
    }

    canvas.restore();
  }

  @override bool shouldRepaint(covariant _ReplicationPainter old) => old.step != step;
}

// ═══════════════════════════════════════════════════════════════════════════════
// 5. TRANSCRIPTION
// ═══════════════════════════════════════════════════════════════════════════════
class _TranscriptionPainter extends CustomPainter {
  final int step; final double t;
  _TranscriptionPainter(this.step, this.t);

  @override
  void paint(Canvas canvas, Size s) {
    canvas.save();
    canvas.translate(s.width / 2, s.height / 2);
    final sc = math.min(s.width / 420, s.height / 280);
    canvas.scale(sc);

    // DNA molecule (horizontal)
    const dnaY = -30.0;
    const dnaLeft = -180.0; const dnaRight = 180.0;

    // Template strand (bottom of pair)
    canvas.drawLine(const Offset(dnaLeft, dnaY + 8), const Offset(dnaRight, dnaY + 8), _stroke(const Color(0xFF7B1FA2), w: 3));
    // Coding strand (top)
    canvas.drawLine(const Offset(dnaLeft, dnaY - 8), const Offset(dnaRight, dnaY - 8), _stroke(const Color(0xFF00838F), w: 3));

    // Labels
    _label(canvas, "Template strand (3'→5')", const Offset(-40, dnaY + 22), fs: 8, c: const Color(0xFF7B1FA2), bold: true, align: TextAlign.left);
    _label(canvas, "Coding strand (5'→3')", const Offset(-40, dnaY - 22), fs: 8, c: const Color(0xFF00838F), bold: true, align: TextAlign.left);

    // Promoter box (visible from step 0)
    const promX = -130.0;
    canvas.drawRect(Rect.fromCenter(center: const Offset(promX, dnaY), width: 40, height: 30), _fill(const Color(0xFFFFF9C4)));
    canvas.drawRect(Rect.fromCenter(center: const Offset(promX, dnaY), width: 40, height: 30), _stroke(const Color(0xFFF9A825), w: 1.5));
    _label(canvas, 'Promoter', const Offset(promX, dnaY + 24), fs: 8, c: const Color(0xFFF57F17));

    if (step >= 1) {
      // RNA Polymerase big oval
      const polX = -60.0;
      canvas.drawOval(Rect.fromCenter(center: const Offset(polX, dnaY), width: 70, height: 52), _fill(const Color(0xFFE3F2FD)));
      canvas.drawOval(Rect.fromCenter(center: const Offset(polX, dnaY), width: 70, height: 52), _stroke(const Color(0xFF1565C0), w: 2));
      _label(canvas, 'RNA\nPolymerase', const Offset(polX, dnaY), fs: 8.5, bold: true, c: const Color(0xFF0D47A1));

      // Transcription bubble (DNA opening)
      _dashedLine(canvas, const Offset(polX - 30, dnaY - 5), const Offset(polX - 30, dnaY - 22), const Color(0xFF37474F));
      _dashedLine(canvas, const Offset(polX + 30, dnaY - 5), const Offset(polX + 30, dnaY - 22), const Color(0xFF37474F));
    }

    if (step >= 2) {
      // Growing RNA chain (orange, extends from RNA Pol)
      const rnaStart = Offset(-30, 0);
      const rnaLen = 80.0;
      final rnaEnd = Offset(-30 + rnaLen * math.min(1.0, (step - 1) * 0.4), 50);
      final path = Path()..moveTo(rnaStart.dx, rnaStart.dy);
      path.quadraticBezierTo(rnaStart.dx + 20, 30, rnaEnd.dx, rnaEnd.dy);
      canvas.drawPath(path, _stroke(const Color(0xFFE65100), w: 3));
      _label(canvas, 'mRNA\n(growing, 5\'→3\')', rnaEnd + const Offset(30, 10), fs: 8.5, c: const Color(0xFFE65100), bold: true);
    }

    if (step >= 3) {
      // 5' cap symbol
      canvas.drawCircle(const Offset(-32, 2), 8, _fill(const Color(0xFF66BB6A)));
      _label(canvas, "5'\ncap", const Offset(-50, 8), fs: 7.5, c: const Color(0xFF2E7D32));
    }

    if (step >= 5) {
      // Poly-A tail
      const tailX = 80.0; const tailY = 70.0;
      canvas.drawLine(const Offset(tailX - 30, tailY), const Offset(tailX + 40, tailY), _stroke(const Color(0xFF9C27B0), w: 3));
      _label(canvas, 'Poly-A tail (3\' end)', const Offset(tailX + 30, tailY + 14), fs: 8, c: const Color(0xFF6A1B9A));
    }

    if (step >= 6) {
      // Splicing
      _label(canvas, 'Splicing removes introns', const Offset(0, 95), fs: 9, c: const Color(0xFF37474F), bold: true);
    }

    if (step >= 7) {
      _label(canvas, 'Mature mRNA exported\nthrough nuclear pore → ribosome', const Offset(0, 115), fs: 9, c: const Color(0xFF1B5E20), bold: true);
    }

    canvas.restore();
  }

  @override bool shouldRepaint(covariant _TranscriptionPainter old) => old.step != step;
}

// ═══════════════════════════════════════════════════════════════════════════════
// 6. TRANSLATION
// ═══════════════════════════════════════════════════════════════════════════════
class _TranslationPainter extends CustomPainter {
  final int step; final double t;
  _TranslationPainter(this.step, this.t);

  @override
  void paint(Canvas canvas, Size s) {
    canvas.save();
    canvas.translate(s.width / 2, s.height / 2);
    final sc = math.min(s.width / 420, s.height / 280);
    canvas.scale(sc);

    // mRNA backbone (horizontal)
    const mRNAY = 40.0;
    canvas.drawLine(const Offset(-185, mRNAY), const Offset(185, mRNAY), _stroke(const Color(0xFFE65100), w: 3.5));
    _label(canvas, "mRNA  5'", const Offset(-175, mRNAY + 16), fs: 9, c: const Color(0xFFE65100), bold: true, align: TextAlign.left);
    _label(canvas, "3'", const Offset(175, mRNAY + 16), fs: 9, c: const Color(0xFFE65100), bold: true);

    // Codons on mRNA
    if (step >= 0) {
      const codons = ['AUG', 'UGG', 'GAA', 'CUG', 'UAA'];
      for (int i = 0; i < codons.length; i++) {
        _label(canvas, codons[i], Offset(-90 + i * 45.0, mRNAY - 1), fs: 8, c: const Color(0xFFBF360C), bold: true);
      }
    }

    // Ribosome (big oval straddling mRNA)
    const ribCX = -45.0;
    if (step >= 1) {
      // Small subunit (40S/30S)
      canvas.drawOval(Rect.fromCenter(center: const Offset(ribCX, mRNAY + 22), width: 100, height: 30), _fill(const Color(0xFFBBDEFB)));
      canvas.drawOval(Rect.fromCenter(center: const Offset(ribCX, mRNAY + 22), width: 100, height: 30), _stroke(const Color(0xFF1565C0), w: 1.5));
      _label(canvas, 'Small (30S)', const Offset(ribCX, mRNAY + 22), fs: 7, c: const Color(0xFF0D47A1));

      // Large subunit (60S/50S)
      canvas.drawOval(Rect.fromCenter(center: const Offset(ribCX, mRNAY - 25), width: 100, height: 38), _fill(const Color(0xFF90CAF9)));
      canvas.drawOval(Rect.fromCenter(center: const Offset(ribCX, mRNAY - 25), width: 100, height: 38), _stroke(const Color(0xFF1565C0), w: 1.5));
      _label(canvas, 'Large (50S)', const Offset(ribCX, mRNAY - 25), fs: 7, c: const Color(0xFF0D47A1));
    }

    // tRNA at sites
    if (step >= 2) {
      // P site tRNA (with growing chain)
      void drawTRNA(Canvas cv, Offset center, String anticodon, Color col) {
        // L-shaped tRNA
        cv.drawLine(center, center + const Offset(0, -30), _stroke(col, w: 2.5));
        cv.drawLine(center, center + const Offset(-15, 0), _stroke(col, w: 2.5));
        cv.drawLine(center + const Offset(-15, 0), center + const Offset(-15, -20), _stroke(col, w: 2.5));
        cv.drawCircle(center + const Offset(-15, -25), 8, _fill(col.withOpacity(0.3)));
        cv.drawCircle(center + const Offset(-15, -25), 8, _stroke(col, w: 1.5));
        // Amino acid circle
        cv.drawCircle(center + const Offset(0, -38), 10, _fill(const Color(0xFFFFCC02)));
        _label(cv, 'AA', center + const Offset(0, -38), fs: 7, bold: true, c: const Color(0xFF37474F));
        _label(cv, anticodon, center + const Offset(0, 12), fs: 7, c: col);
      }

      drawTRNA(canvas, const Offset(ribCX - 20, mRNAY + 3), 'P-site', const Color(0xFF43A047));
      drawTRNA(canvas, const Offset(ribCX + 22, mRNAY + 3), 'A-site', const Color(0xFFE53935));
      _label(canvas, 'P site', const Offset(ribCX - 20, mRNAY + 55), fs: 7.5, c: const Color(0xFF2E7D32));
      _label(canvas, 'A site', const Offset(ribCX + 22, mRNAY + 55), fs: 7.5, c: const Color(0xFFC62828));
    }

    if (step >= 3) {
      // Growing polypeptide chain
      _label(canvas, 'Growing polypeptide (N→C)', const Offset(-120, mRNAY - 75), fs: 8.5, c: const Color(0xFFF57F17), bold: true);
      const ppStart = Offset(-155, mRNAY - 55);
      for (int i = 0; i < step - 2 && i < 5; i++) {
        canvas.drawCircle(ppStart + Offset(i * 18.0, 0), 9, _fill(const Color(0xFFFFCC02)));
        canvas.drawCircle(ppStart + Offset(i * 18.0, 0), 9, _stroke(const Color(0xFFE65100), w: 1.5));
        if (i > 0) canvas.drawLine(ppStart + Offset((i - 1) * 18.0, 0), ppStart + Offset(i * 18.0, 0), _stroke(const Color(0xFFE65100)));
        _label(canvas, 'AA', ppStart + Offset(i * 18.0, 0), fs: 6, c: const Color(0xFF37474F));
      }
    }

    if (step >= 6) {
      _label(canvas, 'Stop codon → release factor → polypeptide released', const Offset(0, 95), fs: 8.5, c: const Color(0xFF37474F), bold: true);
    }

    canvas.restore();
  }

  @override bool shouldRepaint(covariant _TranslationPainter old) => old.step != step;
}

// ═══════════════════════════════════════════════════════════════════════════════
// 7. HEART — BLOOD CIRCULATION
// ═══════════════════════════════════════════════════════════════════════════════
class _HeartPainter extends CustomPainter {
  final int step; final double t;
  _HeartPainter(this.step, this.t);

  @override
  void paint(Canvas canvas, Size s) {
    canvas.save();
    canvas.translate(s.width / 2, s.height / 2);
    final sc = math.min(s.width / 400, s.height / 300);
    canvas.scale(sc);

    // Heart outline
    final heartPath = Path();
    heartPath.moveTo(0, 90);
    heartPath.cubicTo(-120, 20, -130, -60, -60, -80);
    heartPath.cubicTo(-30, -100, 0, -70, 0, -50);
    heartPath.cubicTo(0, -70, 30, -100, 60, -80);
    heartPath.cubicTo(130, -60, 120, 20, 0, 90);
    canvas.drawPath(heartPath, _fill(const Color(0xFFFCE4EC)));
    canvas.drawPath(heartPath, _stroke(const Color(0xFFE53935), w: 2.5));

    // Septum
    canvas.drawLine(const Offset(0, -50), const Offset(0, 80), _stroke(const Color(0xFFB71C1C), w: 2));

    // Chambers
    _label(canvas, 'RA', const Offset(55, -20), fs: 13, bold: true, c: const Color(0xFF1565C0));
    _label(canvas, 'LA', const Offset(-55, -20), fs: 13, bold: true, c: const Color(0xFFC62828));
    _label(canvas, 'RV', const Offset(45, 40), fs: 13, bold: true, c: const Color(0xFF1565C0));
    _label(canvas, 'LV', const Offset(-45, 40), fs: 13, bold: true, c: const Color(0xFFC62828));

    // Valves
    if (step >= 1) {
      canvas.drawLine(const Offset(8, 0), const Offset(-8, 0), _stroke(const Color(0xFF795548), w: 3));
      canvas.drawLine(const Offset(8, 10), const Offset(-8, 10), _stroke(const Color(0xFF795548), w: 3));
      _label(canvas, 'Bicuspid\n(Mitral)', const Offset(-80, 8), fs: 7.5, c: const Color(0xFF4E342E));
      canvas.drawLine(const Offset(8, 2), const Offset(-8, 2), _stroke(const Color(0xFF795548), w: 3));
      _label(canvas, 'Tricuspid', const Offset(78, 5), fs: 7.5, c: const Color(0xFF4E342E));
    }

    // Vessels
    if (step >= 2) {
      // Aorta (top left, red)
      canvas.drawRect(const Rect.fromLTWH(-35, -118, 20, 40), _fill(const Color(0xFFEF9A9A)));
      canvas.drawRect(const Rect.fromLTWH(-35, -118, 20, 40), _stroke(const Color(0xFFC62828), w: 2));
      _label(canvas, 'Aorta', const Offset(-45, -130), fs: 8, c: const Color(0xFFC62828), bold: true);

      // Pulmonary artery (top right, blue)
      canvas.drawRect(const Rect.fromLTWH(15, -118, 20, 40), _fill(const Color(0xFF90CAF9)));
      canvas.drawRect(const Rect.fromLTWH(15, -118, 20, 40), _stroke(const Color(0xFF1565C0), w: 2));
      _label(canvas, 'Pulmonary\nartery', const Offset(50, -130), fs: 8, c: const Color(0xFF1565C0), bold: true);

      // Vena cava (right, blue)
      canvas.drawRect(const Rect.fromLTWH(90, -45, 40, 18), _fill(const Color(0xFF90CAF9)));
      canvas.drawRect(const Rect.fromLTWH(90, -45, 40, 18), _stroke(const Color(0xFF1565C0), w: 2));
      _label(canvas, 'Vena\ncava', const Offset(140, -36), fs: 7.5, c: const Color(0xFF1565C0));

      // Pulmonary vein (left, red)
      canvas.drawRect(const Rect.fromLTWH(-130, -45, 40, 18), _fill(const Color(0xFFEF9A9A)));
      canvas.drawRect(const Rect.fromLTWH(-130, -45, 40, 18), _stroke(const Color(0xFFC62828), w: 2));
      _label(canvas, 'Pulmonary\nvein', const Offset(-145, -36), fs: 7.5, c: const Color(0xFFC62828));
    }

    // Flow arrows
    if (step >= 3) {
      _arrow(canvas, const Offset(110, -36), const Offset(72, -36), const Color(0xFF1565C0));
      _arrow(canvas, const Offset(-90, -36), const Offset(-55, -36), const Color(0xFFC62828));
    }

    if (step >= 5) {
      _arrow(canvas, const Offset(-25, -95), const Offset(-25, -82), const Color(0xFFC62828), w: 2.5);
      _arrow(canvas, const Offset(25, -95), const Offset(25, -82), const Color(0xFF1565C0), w: 2.5);
    }

    if (step >= 6) {
      _label(canvas, 'SAN pacemaker', const Offset(75, -55), fs: 7.5, c: const Color(0xFF37474F));
      canvas.drawCircle(const Offset(60, -45), 5, _fill(const Color(0xFFF9A825)));
    }

    // Color legend
    _label(canvas, '■ Oxygenated (red)   ■ Deoxygenated (blue)', const Offset(0, 120), fs: 8, c: const Color(0xFF37474F));

    canvas.restore();
  }

  @override bool shouldRepaint(covariant _HeartPainter old) => old.step != step;
}

// ═══════════════════════════════════════════════════════════════════════════════
// 8. ACTION POTENTIAL — VOLTAGE GRAPH
// ═══════════════════════════════════════════════════════════════════════════════
class _ActionPotentialPainter extends CustomPainter {
  final int step; final double t;
  _ActionPotentialPainter(this.step, this.t);

  @override
  void paint(Canvas canvas, Size s) {
    canvas.save();
    canvas.translate(s.width / 2, s.height / 2);
    final sc = math.min(s.width / 400, s.height / 300);
    canvas.scale(sc);

    // Axes
    const originX = -160.0; const originY = 80.0;
    const axisW = 310.0; const axisH = 200.0;

    // Background grid lines
    for (int i = 1; i < 4; i++) {
      final y = originY - i * axisH / 4;
      _dashedLine(canvas, Offset(originX, y), Offset(originX + axisW, y), const Color(0xFFE0E0E0));
    }

    // Axes
    canvas.drawLine(const Offset(originX, originY), const Offset(originX + axisW, originY), _stroke(const Color(0xFF37474F), w: 1.5));
    canvas.drawLine(const Offset(originX, originY), const Offset(originX, originY - axisH), _stroke(const Color(0xFF37474F), w: 1.5));
    _arrow(canvas, const Offset(originX + axisW - 5, originY), const Offset(originX + axisW + 5, originY), const Color(0xFF37474F));
    _arrow(canvas, const Offset(originX, originY - axisH + 5), const Offset(originX, originY - axisH - 5), const Color(0xFF37474F));

    _label(canvas, 'Time (ms)', const Offset(originX + axisW / 2, originY + 20), fs: 9, c: const Color(0xFF37474F));
    _label(canvas, 'Voltage\n(mV)', const Offset(originX - 32, originY - axisH / 2), fs: 9, c: const Color(0xFF37474F));

    // mV labels
    final mvLabels = {'+40': 0.2, '0': 0.5, '-55': 0.7, '-70': 0.85};
    for (final e in mvLabels.entries) {
      final y = originY - axisH * (1 - e.value);
      _label(canvas, e.key, Offset(originX - 22, y), fs: 8, c: const Color(0xFF37474F));
      canvas.drawLine(Offset(originX - 4, y), Offset(originX + 4, y), _stroke(const Color(0xFF37474F)));
    }

    // Build the action potential curve points
    final pts = <Offset>[];
    const n = 200;
    for (int i = 0; i < n; i++) {
      final frac = i / n;
      double v;
      if (frac < 0.08) { v = -0.85 + frac * 0.5; } // resting
      else if (frac < 0.15) { v = -0.85 + (frac - 0.08) / 0.07 * 0.65; } // depol rising
      else if (frac < 0.22) { v = -0.2 + (frac - 0.15) / 0.07 * 0.5; } // overshoot
      else if (frac < 0.32) { v = 0.3 - (frac - 0.22) / 0.10 * 1.15; } // repol falling
      else if (frac < 0.42) { v = -0.85 - (frac - 0.32) / 0.10 * 0.08; } // hyperpol
      else { v = -0.85 + (frac - 0.42) / 0.58 * 0.02; } // return to resting
      pts.add(Offset(originX + frac * axisW, originY - (0.85 + v * 0.5) * axisH * 0.85));
    }

    // Draw curve up to current step
    final drawUntil = ((step + 1) / 8.0).clamp(0.0, 1.0);
    final path = Path();
    final limit = (pts.length * drawUntil).toInt().clamp(1, pts.length);
    path.moveTo(pts[0].dx, pts[0].dy);
    for (int i = 1; i < limit; i++) path.lineTo(pts[i].dx, pts[i].dy);
    canvas.drawPath(path, _stroke(const Color(0xFFE53935), w: 2.5));

    // Annotations per step
    if (step >= 0) {
      _label(canvas, 'Resting\n−70 mV', const Offset(originX + 12, originY - axisH * 0.15), fs: 7.5, c: const Color(0xFF1565C0));
    }
    if (step >= 2) {
      _label(canvas, 'Depolarisation\n(Na⁺ in)', const Offset(originX + axisW * 0.18, originY - axisH * 0.55), fs: 7.5, c: const Color(0xFFE53935), bold: true);
    }
    if (step >= 3) {
      _label(canvas, '+40 mV\novershoot', const Offset(originX + axisW * 0.22, originY - axisH * 0.88), fs: 7.5, c: const Color(0xFFE53935));
    }
    if (step >= 4) {
      _label(canvas, 'Repolarisation\n(K⁺ out)', const Offset(originX + axisW * 0.38, originY - axisH * 0.4), fs: 7.5, c: const Color(0xFF7B1FA2), bold: true);
    }
    if (step >= 5) {
      _label(canvas, 'After-\nhyperpolarisation', const Offset(originX + axisW * 0.44, originY - axisH * 0.08), fs: 7, c: const Color(0xFF00838F));
    }
    if (step >= 6) {
      _label(canvas, 'Threshold\n−55 mV', const Offset(originX + axisW * 0.58, originY - axisH * 0.3), fs: 7.5, c: const Color(0xFFF57F17));
      _dashedLine(canvas, const Offset(originX, originY - axisH * 0.3), const Offset(originX + axisW, originY - axisH * 0.3), const Color(0xFFF57F17));
    }
    if (step >= 7) {
      _label(canvas, 'Refractory period →', const Offset(originX + axisW * 0.54, originY - axisH * 0.55), fs: 7.5, c: const Color(0xFF37474F));
    }

    canvas.restore();
  }

  @override bool shouldRepaint(covariant _ActionPotentialPainter old) => old.step != step;
}

// ═══════════════════════════════════════════════════════════════════════════════
// 9. SARCOMERE — SLIDING FILAMENT
// ═══════════════════════════════════════════════════════════════════════════════
class _SarcomrePainter extends CustomPainter {
  final int step; final double t;
  _SarcomrePainter(this.step, this.t);

  @override
  void paint(Canvas canvas, Size s) {
    canvas.save();
    canvas.translate(s.width / 2, s.height / 2);
    final sc = math.min(s.width / 400, s.height / 280);
    canvas.scale(sc);

    // Contraction: step >=5 → actin slides in
    final contractionT = step >= 5 ? math.min(1.0, (step - 5) / 2.0) : 0.0;
    final slide = contractionT * 35;

    const zLeft = -170.0; const zRight = 170.0;
    const mLine = 0.0;
    const myoLen = 120.0; // myosin half-length
    const actBase = 80.0; // actin base position from Z

    // Z lines
    for (final x in [zLeft, zRight]) {
      canvas.drawLine(Offset(x, -35), Offset(x, 35), _stroke(const Color(0xFF37474F), w: 3));
    }
    _label(canvas, 'Z-line', const Offset(zLeft, 45), fs: 8, bold: true, c: const Color(0xFF37474F));
    _label(canvas, 'Z-line', const Offset(zRight, 45), fs: 8, bold: true, c: const Color(0xFF37474F));

    // M line
    canvas.drawLine(const Offset(mLine, -20), const Offset(mLine, 20), _stroke(const Color(0xFF795548), w: 2));
    _label(canvas, 'M-line', const Offset(mLine, 30), fs: 8, c: const Color(0xFF795548));

    // Myosin thick filaments (from M-line)
    final myoPaint = _stroke(const Color(0xFF1565C0), w: 5);
    canvas.drawLine(const Offset(mLine, -10), const Offset(mLine + myoLen, -10), myoPaint);
    canvas.drawLine(const Offset(mLine, 10), const Offset(mLine + myoLen, 10), myoPaint);
    canvas.drawLine(const Offset(mLine, -10), const Offset(mLine - myoLen, -10), myoPaint);
    canvas.drawLine(const Offset(mLine, 10), const Offset(mLine - myoLen, 10), myoPaint);
    _label(canvas, 'Myosin\n(thick)', const Offset(mLine + 65, -22), fs: 8, c: const Color(0xFF0D47A1), bold: true);

    // Myosin heads (cross-bridges)
    if (step >= 3) {
      for (double x = 30; x < myoLen; x += 25) {
        canvas.drawLine(Offset(x, -10), Offset(x + 5, -22), _stroke(const Color(0xFF1565C0), w: 2));
        canvas.drawLine(Offset(-x, -10), Offset(-x - 5, -22), _stroke(const Color(0xFF1565C0), w: 2));
      }
    }

    // Actin thin filaments (from Z lines, sliding in on contraction)
    final actRight = zLeft + actBase + slide;
    final actLeft = zRight - actBase - slide;
    final actPaint = _stroke(const Color(0xFFE53935), w: 3.5);
    canvas.drawLine(const Offset(zLeft, -22), Offset(actRight, -22), actPaint);
    canvas.drawLine(const Offset(zLeft, 22), Offset(actRight, 22), actPaint);
    canvas.drawLine(const Offset(zRight, -22), Offset(actLeft, -22), actPaint);
    canvas.drawLine(const Offset(zRight, 22), Offset(actLeft, 22), actPaint);
    _label(canvas, 'Actin\n(thin)', const Offset(zLeft + 55, -36), fs: 8, c: const Color(0xFFC62828), bold: true);

    // Band labels
    if (step >= 1) {
      // I band (between Z line and actin tip)
      final iBandW = (actBase + slide - 0);
      if (iBandW > 5) {
        canvas.drawRect(Rect.fromLTWH(zLeft, -38, iBandW, 6), _fill(const Color(0xFFFFF9C4)));
        _label(canvas, 'I-band', Offset(zLeft + iBandW / 2, -42), fs: 7.5, c: const Color(0xFFF57F17));
      }
      // A band (full myosin width)
      canvas.drawRect(const Rect.fromLTWH(-myoLen, -52, myoLen * 2, 6), _fill(const Color(0xFFBBDEFB)));
      _label(canvas, 'A-band (constant)', const Offset(mLine, -56), fs: 7.5, c: const Color(0xFF1565C0));
    }

    // Ca2+ ions
    if (step >= 2) {
      for (int i = 0; i < 5; i++) {
        canvas.drawCircle(Offset(-80 + i * 40.0, -55), 6, _fill(const Color(0xFFFF8F00)));
        _label(canvas, 'Ca²⁺', Offset(-80 + i * 40.0, -55), fs: 6, c: Colors.white, bold: true);
      }
      _label(canvas, 'Ca²⁺ released from SR', const Offset(0, -72), fs: 8.5, c: const Color(0xFFE65100), bold: true);
    }

    if (contractionT > 0.3) {
      _label(canvas, 'Sarcomere shortening\n(H-zone disappears)', const Offset(0, 65), fs: 9, bold: true, c: const Color(0xFF1B5E20));
    } else if (step >= 1) {
      _label(canvas, 'Sarcomere structure', const Offset(0, 65), fs: 9, bold: true);
    }

    canvas.restore();
  }

  @override bool shouldRepaint(covariant _SarcomrePainter old) => old.step != step;
}

// ═══════════════════════════════════════════════════════════════════════════════
// 10. PCR
// ═══════════════════════════════════════════════════════════════════════════════
class _PCRPainter extends CustomPainter {
  final int step; final double t;
  _PCRPainter(this.step, this.t);

  @override
  void paint(Canvas canvas, Size s) {
    canvas.save();
    canvas.translate(s.width / 2, s.height / 2);
    final sc = math.min(s.width / 400, s.height / 290);
    canvas.scale(sc);

    // Three temperature zones shown as sections
    const zoneW = 115.0; const zoneH = 160.0; const gap = 10.0;
    const startX = -(zoneW * 3 + gap * 2) / 2;

    final zones = [
      ('Denaturation\n94–95°C', const Color(0xFFFFEBEE), const Color(0xFFE53935)),
      ('Annealing\n50–65°C', const Color(0xFFE8F5E9), const Color(0xFF43A047)),
      ('Extension\n72°C', const Color(0xFFE3F2FD), const Color(0xFF1E88E5)),
    ];

    for (int z = 0; z < zones.length; z++) {
      final zx = startX + z * (zoneW + gap);
      final rr = RRect.fromRectAndRadius(Rect.fromLTWH(zx, -zoneH / 2, zoneW, zoneH), const Radius.circular(14));

      // Dim zones not yet reached
      final opacity = step >= z ? 1.0 : 0.3;
      canvas.drawRRect(rr, Paint()..color = zones[z].$2.withOpacity(opacity)..style = PaintingStyle.fill);
      canvas.drawRRect(rr, Paint()..color = zones[z].$3.withOpacity(opacity)..style = PaintingStyle.stroke..strokeWidth = 2);

      // Temperature label
      _label(canvas, zones[z].$1, Offset(zx + zoneW / 2, -zoneH / 2 + 22), fs: 9, bold: true, c: zones[z].$3.withOpacity(opacity));

      // DNA diagram in each zone
      const dcy = 10.0;
      final dcx = zx + zoneW / 2;

      if (z == 0) {
        // Denaturation: two separated strands
        if (step >= 0) {
          canvas.drawLine(Offset(dcx - 30, dcy - 30), Offset(dcx - 30, dcy + 40), _stroke(const Color(0xFF7B1FA2).withOpacity(opacity), w: 3));
          canvas.drawLine(Offset(dcx + 30, dcy - 30), Offset(dcx + 30, dcy + 40), _stroke(const Color(0xFF00838F).withOpacity(opacity), w: 3));
          if (step == 0) _dashedLine(canvas, Offset(dcx - 25, dcy + 5), Offset(dcx + 25, dcy + 5), const Color(0xFF37474F));
          _label(canvas, 'ssDNA\n(separated)', Offset(dcx, dcy + 55), fs: 7.5, c: zones[z].$3.withOpacity(opacity));
        }
      } else if (z == 1) {
        // Annealing: primers binding
        if (step >= 1) {
          canvas.drawLine(Offset(dcx - 32, dcy - 30), Offset(dcx - 32, dcy + 40), _stroke(const Color(0xFF7B1FA2).withOpacity(opacity), w: 3));
          canvas.drawLine(Offset(dcx + 32, dcy - 30), Offset(dcx + 32, dcy + 40), _stroke(const Color(0xFF00838F).withOpacity(opacity), w: 3));
          // Primers
          canvas.drawLine(Offset(dcx - 32, dcy - 20), Offset(dcx - 8, dcy - 20), _stroke(const Color(0xFFF57F17).withOpacity(opacity), w: 4));
          canvas.drawLine(Offset(dcx + 32, dcy + 20), Offset(dcx + 8, dcy + 20), _stroke(const Color(0xFFF57F17).withOpacity(opacity), w: 4));
          _label(canvas, 'Primers\n(anneal)', Offset(dcx, dcy + 55), fs: 7.5, c: const Color(0xFFE65100).withOpacity(opacity));
        }
      } else if (z == 2) {
        // Extension: new strand growing
        if (step >= 2) {
          canvas.drawLine(Offset(dcx - 32, dcy - 30), Offset(dcx - 32, dcy + 40), _stroke(const Color(0xFF7B1FA2).withOpacity(opacity), w: 3));
          canvas.drawLine(Offset(dcx + 32, dcy - 30), Offset(dcx + 32, dcy + 40), _stroke(const Color(0xFF00838F).withOpacity(opacity), w: 3));
          // New strands (partial)
          canvas.drawLine(Offset(dcx - 32, dcy - 20), Offset(dcx + 10, dcy - 20), _stroke(const Color(0xFF43A047).withOpacity(opacity), w: 3));
          canvas.drawLine(Offset(dcx + 32, dcy + 20), Offset(dcx - 10, dcy + 20), _stroke(const Color(0xFF43A047).withOpacity(opacity), w: 3));
          // Taq polymerase
          canvas.drawCircle(Offset(dcx + 10, dcy - 20), 10, _fill(const Color(0xFFFF8F00).withOpacity(opacity)));
          _label(canvas, 'Taq', Offset(dcx + 10, dcy - 20), fs: 7, c: Colors.white, bold: true);
          _label(canvas, 'New strand\n5\'→3\'', Offset(dcx, dcy + 55), fs: 7.5, c: const Color(0xFF1565C0).withOpacity(opacity));
        }
      }
    }

    // Arrows between zones
    if (step >= 1) _arrow(canvas, const Offset(startX + zoneW + 2, 0), const Offset(startX + zoneW + gap - 2, 0), const Color(0xFF37474F));
    if (step >= 2) _arrow(canvas, const Offset(startX + zoneW * 2 + gap + 2, 0), const Offset(startX + zoneW * 2 + gap * 2 - 2, 0), const Color(0xFF37474F));

    // Cycle count
    if (step >= 3) {
      _label(canvas, '1 cycle = ~2 min.  ×30 cycles = 2³⁰ ≈ 1 billion copies', const Offset(0, 95), fs: 9, bold: true, c: const Color(0xFF37474F));
    }
    if (step >= 4) {
      _label(canvas, 'Exponential amplification: 2ⁿ copies after n cycles', const Offset(0, 113), fs: 8.5, c: const Color(0xFF1B5E20));
    }

    canvas.restore();
  }

  @override bool shouldRepaint(covariant _PCRPainter old) => old.step != step;
}

// ═══════════════════════════════════════════════════════════════════════════════
// 11. LAC OPERON
// ═══════════════════════════════════════════════════════════════════════════════
class _LacOperonPainter extends CustomPainter {
  final int step; final double t;
  _LacOperonPainter(this.step, this.t);

  @override
  void paint(Canvas canvas, Size s) {
    canvas.save();
    canvas.translate(s.width / 2, s.height / 2);
    final sc = math.min(s.width / 400, s.height / 290);
    canvas.scale(sc);

    // DNA line
    const dnaY = -20.0;
    canvas.drawLine(const Offset(-185, dnaY), const Offset(185, dnaY), _stroke(const Color(0xFF37474F), w: 3.5));

    // Gene boxes
    final genes = [
      ('lacI', -160.0, 40.0, const Color(0xFF9C27B0)),
      ('P', -100.0, 22.0, const Color(0xFF1565C0)),
      ('O', -65.0, 22.0, const Color(0xFFE53935)),
      ('lacZ', -5.0, 55.0, const Color(0xFF2E7D32)),
      ('lacY', 65.0, 45.0, const Color(0xFF2E7D32)),
      ('lacA', 130.0, 38.0, const Color(0xFF2E7D32)),
    ];

    for (final g in genes) {
      final x = g.$2; final w = g.$3; final col = g.$4;
      canvas.drawRect(Rect.fromCenter(center: Offset(x, dnaY), width: w, height: 24), _fill(col.withOpacity(0.18)));
      canvas.drawRect(Rect.fromCenter(center: Offset(x, dnaY), width: w, height: 24), _stroke(col, w: 1.5));
      _label(canvas, g.$1, Offset(x, dnaY), fs: 9, bold: true, c: col);
    }

    // Labels below
    _label(canvas, 'Repressor\ngene', const Offset(-160, dnaY + 24), fs: 7);
    _label(canvas, 'Promoter', const Offset(-100, dnaY + 24), fs: 7);
    _label(canvas, 'Operator', const Offset(-65, dnaY + 24), fs: 7, c: const Color(0xFFE53935));
    _label(canvas, 'β-gal', const Offset(-5, dnaY + 30), fs: 7, c: const Color(0xFF1B5E20));
    _label(canvas, 'Permease', const Offset(65, dnaY + 28), fs: 7, c: const Color(0xFF1B5E20));
    _label(canvas, 'Transacet.', const Offset(130, dnaY + 24), fs: 7, c: const Color(0xFF1B5E20));

    // State: no lactose (step 0-2) vs lactose (step 3+)
    final hasLactose = step >= 3;

    // Repressor protein
    if (step >= 1) {
      final repPos = hasLactose ? const Offset(-65, -75) : const Offset(-65, dnaY - 30);
      canvas.drawOval(Rect.fromCenter(center: repPos, width: 44, height: 32), _fill(const Color(0xFFE53935).withOpacity(0.7)));
      canvas.drawOval(Rect.fromCenter(center: repPos, width: 44, height: 32), _stroke(const Color(0xFFB71C1C), w: 2));
      _label(canvas, 'Repressor', repPos, fs: 8, c: Colors.white, bold: true);

      if (!hasLactose) {
        // Repressor ON operator — blocks
        _label(canvas, 'BLOCKED', const Offset(-65, dnaY - 60), fs: 9, bold: true, c: const Color(0xFFE53935));
        _label(canvas, 'No transcription of lacZ/Y/A', const Offset(-10, 70), fs: 9, c: const Color(0xFF37474F));
      } else {
        // Allolactose kicks repressor off
        _label(canvas, '(inactive)', repPos + const Offset(0, 15), fs: 7, c: const Color(0xFF757575));
        // Allolactose
        canvas.drawCircle(const Offset(-65, -100), 14, _fill(const Color(0xFFFF8F00)));
        _label(canvas, 'Allo-\nlactose', const Offset(-65, -100), fs: 7.5, bold: true, c: Colors.white);
        _arrow(canvas, const Offset(-65, -86), const Offset(-65, -60), const Color(0xFFE65100));
        _label(canvas, '+ Inducer\n(allolactose)', const Offset(-110, -90), fs: 8, c: const Color(0xFFE65100));
      }
    }

    // RNA Pol
    if (step >= 2) {
      final polX = hasLactose ? -95.0 : -180.0;
      canvas.drawOval(Rect.fromCenter(center: Offset(polX, dnaY - 20), width: 40, height: 30), _fill(const Color(0xFF1E88E5).withOpacity(0.8)));
      _label(canvas, 'RNA\nPol', Offset(polX, dnaY - 20), fs: 7.5, c: Colors.white, bold: true);
      if (hasLactose) {
        _arrow(canvas, Offset(polX + 20, dnaY), Offset(polX + 40, dnaY), const Color(0xFF1565C0), w: 2.5);
        _label(canvas, 'TRANSCRIPTION ON →', const Offset(60, dnaY - 42), fs: 9.5, bold: true, c: const Color(0xFF1B5E20));
        _label(canvas, 'β-galactosidase, Permease, Transacetylase produced', const Offset(0, 70), fs: 8.5, c: const Color(0xFF1B5E20));
      }
    }

    canvas.restore();
  }

  @override bool shouldRepaint(covariant _LacOperonPainter old) => old.step != step;
}

// ═══════════════════════════════════════════════════════════════════════════════
// 12. SPERMATOGENESIS
// ═══════════════════════════════════════════════════════════════════════════════
class _SpermatogenesisPainter extends CustomPainter {
  final int step; final double t;
  _SpermatogenesisPainter(this.step, this.t);

  @override
  void paint(Canvas canvas, Size s) {
    canvas.save();
    canvas.translate(s.width / 2, s.height / 2);
    final sc = math.min(s.width / 420, s.height / 300);
    canvas.scale(sc);

    // Vertical cell progression diagram
    final stages = [
      ('Spermatogonium\n(2n)', const Color(0xFF9C27B0), 20.0, 'Type A stem cell'),
      ('Primary\nSpermatocyte (2n)', const Color(0xFF3F51B5), 22.0, 'After mitosis + growth'),
      ('2 Secondary\nSpermatocytes (n)', const Color(0xFF2196F3), 18.0, 'After Meiosis I'),
      ('4 Spermatids (n)', const Color(0xFF009688), 15.0, 'After Meiosis II'),
      ('Spermatozoa (n)', const Color(0xFF4CAF50), 12.0, 'After spermiogenesis'),
    ];

    const startY = -115.0;
    const yStep = 52.0;
    const cx2 = 0.0;

    for (int i = 0; i < stages.length; i++) {
      if (i > step && step < 5) continue; // show only up to current step
      final y = startY + i * yStep;
      final st = stages[i];
      final col = st.$2;
      final r = st.$3;

      // Multiply: show 2 circles from stage 2, 4 from stage 3
      final count = i == 2 ? 2 : i == 3 ? 4 : i == 4 ? 4 : 1;
      final spacing = count > 1 ? (count - 1) * (r * 2 + 6) / 2.0 : 0.0;

      for (int j = 0; j < count; j++) {
        final ox = count > 1 ? -spacing + j * (r * 2 + 6) : 0.0;
        canvas.drawCircle(Offset(cx2 + ox - 60, y), r, _fill(col.withOpacity(0.2)));
        canvas.drawCircle(Offset(cx2 + ox - 60, y), r, _stroke(col, w: 2));
        _nucleus(canvas, Offset(cx2 + ox - 60, y), r * 0.45, fill: col.withOpacity(0.5), stroke: col);
        if (i == 4) {
          // Spermatozoon: add tail
          canvas.drawLine(Offset(cx2 + ox - 60, y + r), Offset(cx2 + ox - 60, y + r + 20), _stroke(col, w: 2));
        }
      }

      // Label
      _label(canvas, st.$1, Offset(55, y), fs: 9, bold: i == step, c: i == step ? col : const Color(0xFF37474F), align: TextAlign.left);
      _label(canvas, st.$4, Offset(55, y + 14), fs: 7.5, c: const Color(0xFF757575), align: TextAlign.left);

      // Division label between stages
      if (i < stages.length - 1 && (i < step || step == 5)) {
        final divLabels = ['Mitosis', 'Meiosis I', 'Meiosis II', 'Spermiogenesis'];
        if (i < divLabels.length) {
          _arrow(canvas, Offset(-60, y + st.$3 + 2), Offset(-60, y + yStep - stages[i + 1].$3 - 2), const Color(0xFF37474F));
          _label(canvas, divLabels[i], Offset(-115, y + yStep / 2), fs: 7.5, c: const Color(0xFF555555));
        }
      }
    }

    _label(canvas, 'Spermatogenesis — Seminiferous tubules', const Offset(0, 125), fs: 9.5, bold: true, c: const Color(0xFF37474F));

    canvas.restore();
  }

  @override bool shouldRepaint(covariant _SpermatogenesisPainter old) => old.step != step;
}

// ═══════════════════════════════════════════════════════════════════════════════
// 13. OOGENESIS
// ═══════════════════════════════════════════════════════════════════════════════
class _OogenesisPainter extends CustomPainter {
  final int step; final double t;
  _OogenesisPainter(this.step, this.t);

  @override
  void paint(Canvas canvas, Size s) {
    canvas.save();
    canvas.translate(s.width / 2, s.height / 2);
    final sc = math.min(s.width / 420, s.height / 290);
    canvas.scale(sc);

    final stages = [
      ('Oogonium (2n)', const Color(0xFFE91E8C), 16.0),
      ('Primary Oocyte (2n)\n[arrested Prophase I]', const Color(0xFF9C27B0), 24.0),
      ('Secondary Oocyte (n)\n+ 1st Polar Body', const Color(0xFF3F51B5), 26.0),
      ('Mature Ovum (n)\n+ 2nd Polar Body', const Color(0xFF009688), 28.0),
    ];

    const startY = -90.0; const yStep = 62.0;

    for (int i = 0; i < stages.length; i++) {
      if (i > step && step < stages.length) continue;
      final y = startY + i * yStep;
      final col = stages[i].$2;
      final r = stages[i].$3;

      // Main cell
      canvas.drawCircle(Offset(-40, y), r, _fill(col.withOpacity(0.15)));
      canvas.drawCircle(Offset(-40, y), r, _stroke(col, w: 2.5));
      _nucleus(canvas, Offset(-40, y), r * 0.5, fill: col.withOpacity(0.4), stroke: col);

      // Polar body (small) from stage 2
      if (i >= 2) {
        const pbR = 8.0;
        canvas.drawCircle(Offset(-40 + r + pbR + 4, y - 10), pbR, _fill(col.withOpacity(0.2)));
        canvas.drawCircle(Offset(-40 + r + pbR + 4, y - 10), pbR, _stroke(col, w: 1.5));
        _label(canvas, 'PB', Offset(-40 + r + pbR + 4, y - 10), fs: 7, c: col, bold: true);
      }

      _label(canvas, stages[i].$1, Offset(65, y), fs: 9, bold: i == step, c: i == step ? col : const Color(0xFF37474F), align: TextAlign.left);

      if (i < stages.length - 1 && i < step) {
        final divLabels = ['Mitosis', 'Meiosis I\n(at ovulation)', 'Meiosis II\n(on fertilisation)'];
        if (i < divLabels.length) {
          _arrow(canvas, Offset(-40, y + stages[i].$3 + 3), Offset(-40, y + yStep - stages[i + 1].$3 - 3), const Color(0xFF37474F));
          _label(canvas, divLabels[i], Offset(-110, y + yStep / 2), fs: 7.5, c: const Color(0xFF555555));
        }
      }
    }

    _label(canvas, 'Oogenesis — Unequal division → 1 large ovum\n(polar bodies degenerate)', const Offset(0, 110), fs: 9, bold: true, c: const Color(0xFF37474F));

    canvas.restore();
  }

  @override bool shouldRepaint(covariant _OogenesisPainter old) => old.step != step;
}

// ═══════════════════════════════════════════════════════════════════════════════
// 14. GEL ELECTROPHORESIS
// ═══════════════════════════════════════════════════════════════════════════════
class _GelElectroPainter extends CustomPainter {
  final int step; final double t;
  _GelElectroPainter(this.step, this.t);

  @override
  void paint(Canvas canvas, Size s) {
    canvas.save();
    canvas.translate(s.width / 2, s.height / 2);
    final sc = math.min(s.width / 380, s.height / 290);
    canvas.scale(sc);

    // Gel rectangle
    const gelW = 280.0; const gelH = 200.0;
    canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: gelW, height: gelH), _fill(const Color(0xFFF5F5DC)));
    canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: gelW, height: gelH), _stroke(const Color(0xFF795548), w: 2));

    // Wells at top
    const wellsY = -gelH / 2 + 12.0; const nWells = 5; const wellW = 22.0; const wellGap = 38.0;
    for (int w = 0; w < nWells; w++) {
      final wx = -(nWells - 1) * wellGap / 2 + w * wellGap;
      canvas.drawRect(Rect.fromCenter(center: Offset(wx, wellsY), width: wellW, height: 16), _fill(step >= 2 ? const Color(0xFF90CAF9) : const Color(0xFFE0E0E0)));
      canvas.drawRect(Rect.fromCenter(center: Offset(wx, wellsY), width: wellW, height: 16), _stroke(const Color(0xFF555555), w: 1));
    }

    // Electrode labels
    _label(canvas, '− (Cathode)', const Offset(0, -gelH / 2 - 18), fs: 9, bold: true, c: const Color(0xFF555555));
    _label(canvas, '+ (Anode)', const Offset(0, gelH / 2 + 18), fs: 9, bold: true, c: const Color(0xFF555555));

    // Migration arrow
    if (step >= 3) {
      _arrow(canvas, const Offset(gelW / 2 + 18, -gelH / 3), const Offset(gelW / 2 + 18, gelH / 3), const Color(0xFF1565C0), w: 2.5);
      _label(canvas, 'DNA\nmigrates', const Offset(gelW / 2 + 45, 0), fs: 8.5, c: const Color(0xFF1565C0));
    }

    // DNA bands (appear progressively, smaller fragments travel farther)
    if (step >= 2) {
      final migration = math.min(1.0, (step - 2) / 4.0);
      // Lane 1: Ladder
      final ladderSizes = [200.0, 130.0, 90.0, 60.0, 35.0];
      const lx = -(nWells - 1) * wellGap / 2;
      for (final frac in ladderSizes) {
        final by = wellsY + 8 + (gelH - 24) * (1 - frac / 200.0) * migration;
        canvas.drawLine(Offset(lx - 10, by), Offset(lx + 10, by), _stroke(const Color(0xFF9E9E9E), w: 2.5));
        _label(canvas, '${frac.toInt()}', Offset(lx - 24, by), fs: 6.5, c: const Color(0xFF555555));
      }

      // Sample lanes (2-5) with different band patterns
      const sampleBands = [
        [0.8, 0.55, 0.3],
        [0.7, 0.4],
        [0.9, 0.6, 0.35, 0.18],
        [0.75, 0.45],
      ];
      for (int lane = 0; lane < 4; lane++) {
        final laneX = lx + (lane + 1) * wellGap;
        for (final frac in sampleBands[lane]) {
          final by = wellsY + 8 + (gelH - 24) * (1 - frac) * migration;
          final intensity = (0.6 + frac * 0.4).clamp(0.4, 1.0);
          canvas.drawLine(Offset(laneX - 9, by), Offset(laneX + 9, by), _stroke(const Color(0xFFEF9A9A).withOpacity(intensity), w: 3.5));
        }
      }

      // UV glow background (simulate EtBr staining)
      if (step >= 5) {
        canvas.drawRect(
          Rect.fromCenter(center: Offset.zero, width: gelW, height: gelH),
          Paint()
            ..color = const Color(0xFFFF8F00).withOpacity(0.05)
            ..style = PaintingStyle.fill,
        );
      }
    }

    if (step >= 6) _label(canvas, 'Bands visualized under UV → size from DNA ladder', const Offset(0, gelH / 2 + 38), fs: 8.5, c: const Color(0xFF37474F), bold: true);

    canvas.restore();
  }

  @override bool shouldRepaint(covariant _GelElectroPainter old) => old.step != step;
}

// ═══════════════════════════════════════════════════════════════════════════════
// 15. MESELSON-STAHL
// ═══════════════════════════════════════════════════════════════════════════════
class _MeselsonPainter extends CustomPainter {
  final int step; final double t;
  _MeselsonPainter(this.step, this.t);

  @override
  void paint(Canvas canvas, Size s) {
    canvas.save();
    canvas.translate(s.width / 2, s.height / 2);
    final sc = math.min(s.width / 400, s.height / 290);
    canvas.scale(sc);

    // CsCl gradient tubes (4 tubes side by side)
    const tubeW = 44.0; const tubeH = 180.0; const tubeGap = 28.0;
    const nTubes = 4;
    const startX = -(nTubes - 1) * (tubeW + tubeGap) / 2;

    final tubeLabels = ['Gen 0\n(¹⁵N)', 'Gen 1\n(mix)', 'Gen 2', 'Gen 3'];
    final showUntil = step.clamp(0, 3);

    for (int i = 0; i <= showUntil; i++) {
      final tx = startX + i * (tubeW + tubeGap);
      // Tube outline
      canvas.drawRect(Rect.fromCenter(center: Offset(tx, 0), width: tubeW, height: tubeH), _fill(const Color(0xFFE3F2FD)));
      canvas.drawRect(Rect.fromCenter(center: Offset(tx, 0), width: tubeW, height: tubeH), _stroke(const Color(0xFF1565C0), w: 2));

      // CsCl gradient (light → dense bottom to top for display)
      _label(canvas, tubeLabels[i], Offset(tx, tubeH / 2 + 18), fs: 8, bold: true, c: const Color(0xFF37474F));

      // Bands
      void drawBand(double fracFromTop, Color col, double w2) {
        final by = -tubeH / 2 + fracFromTop * tubeH;
        canvas.drawLine(Offset(tx - tubeW / 2 + 4, by), Offset(tx + tubeW / 2 - 4, by), _stroke(col, w: w2));
      }

      if (i == 0) {
        // Gen 0: one heavy band (bottom = denser)
        drawBand(0.8, const Color(0xFF1565C0), 5);
        _label(canvas, '¹⁵N-¹⁵N\n(heavy)', Offset(tx + tubeW / 2 + 30, tubeH / 2 * 0.6), fs: 7.5, c: const Color(0xFF1565C0));
      } else if (i == 1) {
        // Gen 1: one hybrid band (middle)
        drawBand(0.55, const Color(0xFF7B1FA2), 5);
        _label(canvas, '¹⁵N-¹⁴N\n(hybrid)', Offset(tx + tubeW / 2 + 30, tubeH / 2 * 0.1), fs: 7.5, c: const Color(0xFF7B1FA2));
      } else if (i == 2) {
        // Gen 2: hybrid + light
        drawBand(0.55, const Color(0xFF7B1FA2), 4);
        drawBand(0.32, const Color(0xFF43A047), 4);
        _label(canvas, '1:1\nratio', Offset(tx + tubeW / 2 + 30, -tubeH / 2 * 0.1), fs: 7.5, c: const Color(0xFF37474F));
      } else if (i == 3) {
        // Gen 3: 1 hybrid, 3 light
        drawBand(0.55, const Color(0xFF7B1FA2), 4);
        drawBand(0.30, const Color(0xFF43A047), 6);
        _label(canvas, '1:3\nratio', Offset(tx + tubeW / 2 + 30, -tubeH / 2 * 0.2), fs: 7.5, c: const Color(0xFF37474F));
      }
    }

    // Labels
    _label(canvas, 'CsCl Density Gradient Centrifugation', const Offset(0, -tubeH / 2 - 24), fs: 10, bold: true, c: const Color(0xFF37474F));
    _label(canvas, '■ Heavy (¹⁵N-¹⁵N)   ■ Hybrid (¹⁵N-¹⁴N)   ■ Light (¹⁴N-¹⁴N)', const Offset(0, tubeH / 2 + 38), fs: 8, c: const Color(0xFF37474F));
    if (step >= 2) _label(canvas, 'Proves: SEMI-CONSERVATIVE replication', const Offset(0, tubeH / 2 + 55), fs: 9.5, bold: true, c: const Color(0xFF1B5E20));

    canvas.restore();
  }

  @override bool shouldRepaint(covariant _MeselsonPainter old) => old.step != step;
}

// ═══════════════════════════════════════════════════════════════════════════════
// 16. Z-SCHEME (Photosynthesis)
// ═══════════════════════════════════════════════════════════════════════════════
class _ZSchemePainter extends CustomPainter {
  final int step; final double t;
  _ZSchemePainter(this.step, this.t);

  @override
  void paint(Canvas canvas, Size s) {
    canvas.save();
    canvas.translate(s.width / 2, s.height / 2);
    final sc = math.min(s.width / 420, s.height / 300);
    canvas.scale(sc);

    // Axes
    const axisLeft = -185.0; const axisBottom = 110.0; const axisH = 220.0; const axisW = 360.0;
    canvas.drawLine(const Offset(axisLeft, axisBottom), const Offset(axisLeft, axisBottom - axisH), _stroke(const Color(0xFF37474F), w: 1.5));
    canvas.drawLine(const Offset(axisLeft, axisBottom), const Offset(axisLeft + axisW, axisBottom), _stroke(const Color(0xFF37474F), w: 1.5));
    _label(canvas, 'Energy\n(redox potential)', const Offset(axisLeft - 38, axisBottom - axisH / 2), fs: 8, c: const Color(0xFF37474F));
    _label(canvas, 'Electron flow →', const Offset(axisLeft + axisW / 2, axisBottom + 18), fs: 8, c: const Color(0xFF37474F));

    // Z-shaped electron path
    // Points: Water → P680 (low energy) → excited P680 (high) → ETC → P700 (low) → excited P700 (high) → NADPH
    final pts = [
      const Offset(axisLeft + 20, axisBottom - 55),   // Water / P680 ground
      const Offset(axisLeft + 60, axisBottom - 180),  // Excited P680
      const Offset(axisLeft + 130, axisBottom - 60),  // ETC (PQ, Cytb6f, PC)
      const Offset(axisLeft + 175, axisBottom - 95),  // P700 ground
      const Offset(axisLeft + 240, axisBottom - 210), // Excited P700
      const Offset(axisLeft + 320, axisBottom - 165), // Fd → NADPH
    ];

    if (step >= 1) {
      for (int i = 0; i < math.min(pts.length - 1, step + 1); i++) {
        _arrow(canvas, pts[i], pts[i + 1], i.isEven ? const Color(0xFFE53935) : const Color(0xFF1E88E5), w: 2.5);
      }
    }

    // Station labels
    if (step >= 0) {
      canvas.drawCircle(pts[0], 14, _fill(const Color(0xFF1E88E5)));
      _label(canvas, 'P680\nPS-II', pts[0], fs: 7.5, bold: true, c: Colors.white);
      canvas.drawCircle(pts[3], 14, _fill(const Color(0xFF43A047)));
      _label(canvas, 'P700\nPS-I', pts[3], fs: 7.5, bold: true, c: Colors.white);
    }
    if (step >= 1) {
      canvas.drawCircle(pts[1], 10, _fill(const Color(0xFFE53935)));
      _label(canvas, 'e⁻*\n(excited)', pts[1] + const Offset(20, 0), fs: 7.5, c: const Color(0xFFC62828));
    }
    if (step >= 3) {
      canvas.drawCircle(pts[4], 10, _fill(const Color(0xFF43A047)));
      _label(canvas, 'e⁻*', pts[4] + const Offset(15, 0), fs: 7.5, c: const Color(0xFF2E7D32));
    }

    // Key labels
    if (step >= 0) {
      _label(canvas, '2H₂O→O₂+4H⁺', pts[0] + const Offset(-5, 24), fs: 8, c: const Color(0xFF1565C0), bold: true);
    }
    if (step >= 2) {
      _label(canvas, 'ATP\n(Cytb6f)', const Offset(axisLeft + 130, axisBottom - 35), fs: 8, c: const Color(0xFFE65100), bold: true);
    }
    if (step >= 5) {
      _label(canvas, 'NADPH', pts[5] + const Offset(15, 0), fs: 9, bold: true, c: const Color(0xFF388E3C));
    }

    // Light arrows
    if (step >= 1) {
      _arrow(canvas, pts[0] - const Offset(0, 30), pts[0] - const Offset(0, 8), const Color(0xFFFFB300), w: 2.5);
      _label(canvas, 'Light\n(680nm)', pts[0] - const Offset(-22, 20), fs: 7.5, c: const Color(0xFFFF8F00));
    }
    if (step >= 4) {
      _arrow(canvas, pts[3] - const Offset(0, 30), pts[3] - const Offset(0, 8), const Color(0xFFFFB300), w: 2.5);
      _label(canvas, 'Light\n(700nm)', pts[3] + const Offset(25, -18), fs: 7.5, c: const Color(0xFFFF8F00));
    }

    canvas.restore();
  }

  @override bool shouldRepaint(covariant _ZSchemePainter old) => old.step != step;
}

