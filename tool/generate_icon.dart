// Run with: dart tool/generate_icon.dart
// Generates a simple biology-themed app icon PNG using dart:ui.
// Requires Dart with dart:ui access (run via flutter).

import 'dart:io';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';

Future<void> main() async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  const size = 1024.0;

  // Background — deep indigo circle
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      const Rect.fromLTWH(0, 0, size, size),
      const Radius.circular(220),
    ),
    Paint()
      ..shader = ui.Gradient.linear(
        const Offset(0, 0),
        const Offset(size, size),
        [const Color(0xFF2D2670), const Color(0xFF4E46A8)],
      ),
  );

  // White circle inner background
  canvas.drawCircle(
    const Offset(size / 2, size / 2),
    size * 0.38,
    Paint()..color = const Color(0xFFE8FFF4),
  );

  // DNA helix (simplified for icon)
  const cx = size / 2;
  const cy = size / 2;
  const helixH = size * 0.32;
  const helixW = size * 0.08;
  const turns = 2.5;
  const segs = 40;

  final strand1 = <Offset>[];
  final strand2 = <Offset>[];
  for (int i = 0; i <= segs; i++) {
    final t = i / segs;
    final y = cy - helixH + t * helixH * 2;
    final angle = t * turns * 2 * math.pi;
    strand1.add(Offset(cx + helixW * math.cos(angle), y));
    strand2.add(Offset(cx + helixW * math.cos(angle + math.pi), y));
  }

  // Draw strands
  void drawStrand(List<Offset> pts, Color color) {
    final p = Path()..moveTo(pts[0].dx, pts[0].dy);
    for (int i = 1; i < pts.length - 2; i++) {
      final xc = (pts[i].dx + pts[i + 1].dx) / 2;
      final yc = (pts[i].dy + pts[i + 1].dy) / 2;
      p.quadraticBezierTo(pts[i].dx, pts[i].dy, xc, yc);
    }
    canvas.drawPath(p, Paint()
      ..color = color
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = size * 0.025
      ..strokeCap = ui.StrokeCap.round);
  }

  drawStrand(strand1, const Color(0xFF22A06B));
  drawStrand(strand2, const Color(0xFFFFFFFF));

  // Base pairs
  for (int i = 0; i <= segs; i += 5) {
    canvas.drawLine(strand1[i], strand2[i],
        Paint()
          ..color = const Color(0xFF86EFAC).withOpacity(0.8)
          ..strokeWidth = size * 0.012
          ..strokeCap = ui.StrokeCap.round);
    canvas.drawCircle(strand1[i], size * 0.014,
        Paint()..color = const Color(0xFF22A06B));
    canvas.drawCircle(strand2[i], size * 0.014,
        Paint()..color = Colors.white.withOpacity(0.9));
  }

  // Nucleus circle
  canvas.drawCircle(
    const Offset(cx, cy),
    size * 0.14,
    Paint()
      ..shader = ui.Gradient.radial(
        const Offset(cx - size * 0.04, cy - size * 0.04),
        size * 0.14,
        [Colors.white, const Color(0xFFD4C6FF), const Color(0xFF4E46A8)],
        [0, 0.4, 1],
      ),
  );

  // Nucleus specular
  canvas.drawCircle(
    const Offset(cx - size * 0.04, cy - size * 0.04),
    size * 0.055,
    Paint()
      ..shader = ui.Gradient.radial(
        const Offset(cx - size * 0.04, cy - size * 0.04),
        size * 0.055,
        [Colors.white.withOpacity(0.7), Colors.transparent],
      ),
  );

  // "P" text
  final pb = ui.ParagraphBuilder(ui.ParagraphStyle(
    textAlign: TextAlign.center,
    fontSize: size * 0.13,
  ))
    ..pushStyle(ui.TextStyle(
      color: Colors.white,
      fontSize: size * 0.13,
      fontWeight: ui.FontWeight.w900,
    ))
    ..addText('P');
  final para = pb.build()
    ..layout(const ui.ParagraphConstraints(width: size * 0.3));
  canvas.drawParagraph(
      para, Offset(cx - size * 0.15, cy - para.height / 2));

  final picture = recorder.endRecording();
  final image = await picture.toImage(size.toInt(), size.toInt());
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

  if (byteData != null) {
    final file = File('assets/images/app_icon.png');
    await file.writeAsBytes(byteData.buffer.asUint8List());
    print('Icon saved to assets/images/app_icon.png');
  }
}
