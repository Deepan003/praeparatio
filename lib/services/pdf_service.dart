import 'dart:convert';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/exam_model.dart';
import '../models/exam_result_model.dart';
import '../models/offline_test_model.dart';
import '../models/question_model.dart';
import '../models/user_model.dart';

// ── Brand colours ─────────────────────────────────────────────
const _primary   = PdfColor.fromInt(0xFF6C63FF);
const _dark      = PdfColor.fromInt(0xFF1A1A2E);
const _surface   = PdfColor.fromInt(0xFFF8F9FF);
const _gold      = PdfColor.fromInt(0xFFFFB300);
const _silver    = PdfColor.fromInt(0xFF9E9E9E);
const _bronze    = PdfColor.fromInt(0xFFBF8A50);
const _green     = PdfColor.fromInt(0xFF43A047);
const _red       = PdfColor.fromInt(0xFFE53935);
const _white     = PdfColors.white;

class PdfService {
  // ── Helpers ──────────────────────────────────────────────────

  static pw.TextStyle _h1() =>
      pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: _white);
  static pw.TextStyle _h2([PdfColor c = _dark]) =>
      pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold, color: c);
  static pw.TextStyle _h3([PdfColor c = _dark]) =>
      pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: c);
  static pw.TextStyle _body([PdfColor c = _dark]) =>
      pw.TextStyle(fontSize: 10, color: c);
  static pw.TextStyle _small([PdfColor c = _dark]) =>
      pw.TextStyle(fontSize: 8, color: c);

  static String _fmt(DateTime d) => DateFormat('dd MMM yyyy').format(d);
  static String _pct(double v) => '${v.toStringAsFixed(1)}%';

  /// Replace Unicode characters unsupported by standard PDF fonts.
  /// Standard PDF fonts (Helvetica/Times) only cover Latin-1 (ISO-8859-1).
  /// Characters like → ← − ≥ ≤ ≠ etc. render as ⊠ boxes without this fix.
  static String _s(String? text) {
    if (text == null || text.isEmpty) return '';
    return text
        .replaceAll('→', ' > ')   // →
        .replaceAll('←', ' < ')   // ←
        .replaceAll('⇒', ' => ')  // ⇒
        .replaceAll('−', '-')     // − (minus sign)
        .replaceAll('—', '--')    // — (em dash)
        .replaceAll('–', '-')     // – (en dash)
        .replaceAll('×', 'x')     // × (multiplication)
        .replaceAll('÷', '/')     // ÷
        .replaceAll('≠', '!=')    // ≠
        .replaceAll('≥', '>=')    // ≥
        .replaceAll('≤', '<=')    // ≤
        .replaceAll('²', '2')     // ²
        .replaceAll('³', '3')     // ³
        .replaceAll('α', 'alpha') // α
        .replaceAll('β', 'beta')  // β
        .replaceAll('γ', 'gamma') // γ
        .replaceAll('δ', 'delta') // δ
        .replaceAll('ω', 'omega') // ω
        .replaceAll('’', "'")     // ' (right single quote)
        .replaceAll('‘', "'")     // ' (left single quote)
        .replaceAll('“', '"')     // " (left double quote)
        .replaceAll('”', '"')     // " (right double quote)
        .replaceAll('•', '-')     // • bullet (U+2022, outside Latin-1)
        .replaceAll('✓', 'v')     // ✓ checkmark
        .replaceAll('✕', 'x')     // ✕ cross
        // Note: · (U+00B7 middle dot) is Latin-1 — no replacement needed
        // Note: common accented chars (é, ñ, etc.) are Latin-1 — no replacement needed
        ;
  }

  static pw.Widget _divider() => pw.Container(
      height: 1, margin: const pw.EdgeInsets.symmetric(vertical: 6),
      color: const PdfColor.fromInt(0xFFE0E0E0));

  // ── Shared page header/footer for all multi-page PDFs ────────
  static pw.Widget _pageHeader(String title, String date) => pw.Container(
        padding: const pw.EdgeInsets.only(bottom: 8),
        decoration: pw.BoxDecoration(
          border: pw.Border(
              bottom: pw.BorderSide(color: _primary.shade(0.4), width: 0.8)),
        ),
        child: pw.Row(children: [
          pw.Container(
              width: 4, height: 14, color: _primary,
              margin: const pw.EdgeInsets.only(right: 8)),
          pw.Text(title,
              style: pw.TextStyle(
                  fontSize: 9, fontWeight: pw.FontWeight.bold, color: _primary)),
          pw.Spacer(),
          pw.Text(date, style: _small(const PdfColor.fromInt(0xFF777777))),
        ]),
      );

  static pw.Widget _pageFooter(pw.Context ctx) => pw.Container(
        padding: const pw.EdgeInsets.only(top: 8),
        decoration: const pw.BoxDecoration(
          border: pw.Border(
              top: pw.BorderSide(
                  color: PdfColor.fromInt(0xFFDEDEDE), width: 0.6)),
        ),
        child: pw.Row(children: [
          pw.Text('PRAEPARATIO',
              style: pw.TextStyle(
                  fontSize: 8,
                  fontWeight: pw.FontWeight.bold,
                  color: _primary.shade(0.7))),
          pw.Spacer(),
          pw.Text('Page ${ctx.pageNumber} of ${ctx.pagesCount}',
              style: _small(const PdfColor.fromInt(0xFF9E9E9E))),
        ]),
      );

  // ── Page header band ─────────────────────────────────────────
  static pw.Widget _headerBand({
    required String title,
    required String subtitle,
    String? right,
  }) =>
      pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        decoration: const pw.BoxDecoration(color: _primary),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(title, style: _h1()),
                  pw.SizedBox(height: 4),
                  pw.Text(subtitle,
                      style: pw.TextStyle(fontSize: 11, color: _white.shade(0.75))),
                ],
              ),
            ),
            if (right != null)
              pw.Text(right,
                  style: pw.TextStyle(fontSize: 10, color: _white.shade(0.8))),
          ],
        ),
      );

  // ── Stat box — white bg, left accent stripe, clean contrast ──
  static pw.Widget _statBox(String label, String value, PdfColor color) =>
      pw.Expanded(
        child: pw.Container(
          margin: const pw.EdgeInsets.symmetric(horizontal: 3),
          decoration: pw.BoxDecoration(
            color: PdfColors.white,
            // No borderRadius — pdf package forbids it with non-uniform borders
            border: pw.Border(
              left: pw.BorderSide(color: color, width: 3),
              top: const pw.BorderSide(color: PdfColor.fromInt(0xFFE8E8F0), width: 0.8),
              right: const pw.BorderSide(color: PdfColor.fromInt(0xFFE8E8F0), width: 0.8),
              bottom: const pw.BorderSide(color: PdfColor.fromInt(0xFFE8E8F0), width: 0.8),
            ),
          ),
          child: pw.Padding(
            padding: const pw.EdgeInsets.fromLTRB(10, 11, 8, 11),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(value,
                    style: pw.TextStyle(
                        fontSize: 17, fontWeight: pw.FontWeight.bold, color: color)),
                pw.SizedBox(height: 2),
                pw.Text(label,
                    style: const pw.TextStyle(
                        fontSize: 8, color: PdfColor.fromInt(0xFF666677))),
              ],
            ),
          ),
        ),
      );

  // ── Podium block ─────────────────────────────────────────────
  static pw.Widget _podium({
    required int rank,
    required String name,
    required String score,
    required String marks,
    required double height,
    required PdfColor color,
  }) {
    final rankLabel = rank == 1 ? '1st' : rank == 2 ? '2nd' : '3rd';
    return pw.Column(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: pw.BoxDecoration(
            color: color.shade(0.15),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
            border: pw.Border.all(color: color.shade(0.5), width: 0.8),
          ),
          child: pw.Text(rankLabel,
              style: pw.TextStyle(
                  fontSize: 10, fontWeight: pw.FontWeight.bold, color: _dark)),
        ),
        pw.SizedBox(height: 6),
        pw.Text(_s(name),
            maxLines: 2,
            style: pw.TextStyle(
                fontSize: 9, fontWeight: pw.FontWeight.bold, color: _dark),
            textAlign: pw.TextAlign.center),
        pw.SizedBox(height: 2),
        pw.Text(score,
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: _dark)),
        pw.Text(marks, style: _small()),
        pw.SizedBox(height: 4),
        pw.Container(
          width: 80,
          height: height,
          decoration: pw.BoxDecoration(
            color: color,
            borderRadius: const pw.BorderRadius.only(
              topLeft: pw.Radius.circular(6),
              topRight: pw.Radius.circular(6),
            ),
          ),
          child: pw.Center(
            child: pw.Text('#$rank',
                style: pw.TextStyle(
                    fontSize: 20, fontWeight: pw.FontWeight.bold, color: _white)),
          ),
        ),
      ],
    );
  }

  // ── Table header row ─────────────────────────────────────────
  static pw.Widget _tableHeader(List<String> cols, List<double> flex) =>
      pw.Container(
        color: _dark,
        padding: const pw.EdgeInsets.symmetric(vertical: 7, horizontal: 8),
        child: pw.Row(
          children: List.generate(
            cols.length,
            (i) => pw.Expanded(
              flex: (flex[i] * 10).round(),
              child: pw.Text(cols[i],
                  style: pw.TextStyle(
                      fontSize: 9, fontWeight: pw.FontWeight.bold, color: _white)),
            ),
          ),
        ),
      );

  static pw.Widget _tableRow(
    List<String> cells,
    List<double> flex, {
    bool shaded = false,
    PdfColor? rowColor,
  }) =>
      pw.Container(
        color: rowColor ?? (shaded ? _surface : _white),
        padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        child: pw.Row(
          children: List.generate(
            cells.length,
            (i) => pw.Expanded(
              flex: (flex[i] * 10).round(),
              child: pw.Text(cells[i], style: _body(), maxLines: 2),
            ),
          ),
        ),
      );

  // ════════════════════════════════════════════════════════════
  // 1. EXAM RESULTS PDF (single exam, all batch students)
  // ════════════════════════════════════════════════════════════
  static Future<Uint8List> examResultsPdf({
    required ExamModel exam,
    required List<ExamResultModel> results,
    required Map<String, UserModel> studentMap,
  }) async {
    final doc = pw.Document();
    final now = _fmt(DateTime.now());

    // Sort by score desc
    final sorted = [...results]
      ..sort((a, b) => b.score.compareTo(a.score));

    final total = sorted.length;
    final avg = total == 0
        ? 0.0
        : sorted.map((r) => r.percentage).reduce((a, b) => a + b) / total;
    final highest = total == 0 ? 0.0 : sorted.first.percentage;
    final passRate = total == 0
        ? 0.0
        : sorted.where((r) => r.percentage >= 35).length / total * 100;

    final top3 = sorted.take(3).toList();

    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(44, 44, 44, 44),
      header: (ctx) => ctx.pageNumber == 1
          ? pw.SizedBox(height: 0)
          : pw.Padding(padding: const pw.EdgeInsets.only(bottom: 12),
              child: _pageHeader(exam.title, now)),
      footer: (ctx) => pw.Padding(padding: const pw.EdgeInsets.only(top: 10),
          child: _pageFooter(ctx)),
      build: (ctx) => [
        // ── Cover header ──
        _headerBand(
          title: exam.title,
          subtitle: '${exam.targetBatches.join(", ")}  ·  ${exam.durationMinutes} min  ·  ${exam.questionIds.length} Questions',
          right: 'Generated $now',
        ),

        pw.Padding(
          padding: const pw.EdgeInsets.fromLTRB(0, 16, 0, 0),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // ── Stats row ──
              pw.Row(children: [
                _statBox('Students', '$total', _primary),
                _statBox('Avg Score', _pct(avg), _green),
                _statBox('Highest', _pct(highest), _gold),
                _statBox('Pass Rate (≥35%)', _pct(passRate), const PdfColor.fromInt(0xFF0288D1)),
              ]),

              pw.SizedBox(height: 20),

              // ── Podium ──
              if (top3.isNotEmpty) ...[
                pw.Center(
                  child: pw.Text('TOP PERFORMERS',
                      style: _h2(_primary)),
                ),
                pw.SizedBox(height: 12),
                pw.Center(
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      // 2nd place
                      if (top3.length >= 2)
                        _podium(
                          rank: 2,
                          name: studentMap[top3[1].studentId]?.name ?? top3[1].studentId,
                          score: _pct(top3[1].percentage),
                          marks: '${top3[1].score}/${top3[1].totalQuestions}',
                          height: 60,
                          color: _silver,
                        ),
                      pw.SizedBox(width: 12),
                      // 1st place
                      _podium(
                        rank: 1,
                        name: studentMap[top3[0].studentId]?.name ?? top3[0].studentId,
                        score: _pct(top3[0].percentage),
                        marks: '${top3[0].score}/${top3[0].totalQuestions}',
                        height: 80,
                        color: _gold,
                      ),
                      pw.SizedBox(width: 12),
                      // 3rd place
                      if (top3.length >= 3)
                        _podium(
                          rank: 3,
                          name: studentMap[top3[2].studentId]?.name ?? top3[2].studentId,
                          score: _pct(top3[2].percentage),
                          marks: '${top3[2].score}/${top3[2].totalQuestions}',
                          height: 45,
                          color: _bronze,
                        ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),
              ],

              // ── Full results table ──
              pw.Text('FULL RESULTS', style: _h2()),
              pw.SizedBox(height: 8),
              _tableHeader(
                ['Rank', 'Student Name', 'Score', 'Marks', 'Percentage', 'Status'],
                [0.7, 2.5, 1.0, 1.0, 1.2, 1.0],
              ),
              ...sorted.asMap().entries.map((e) {
                final r = e.value;
                final rank = e.key + 1;
                final name = _s(studentMap[r.studentId]?.name ?? r.studentId);
                final isPodium = rank <= 3;
                final color = isPodium
                    ? (rank == 1 ? _gold : rank == 2 ? _silver : _bronze).shade(0.08)
                    : null;
                final passed = r.percentage >= 35;
                return _tableRow(
                  [
                    '#$rank',
                    name,
                    '${r.score}',
                    '${r.neetScore}/${r.totalQuestions * 4}',
                    _pct(r.percentage),
                    passed ? 'Pass' : 'Fail',
                  ],
                  [0.7, 2.5, 1.0, 1.0, 1.2, 1.0],
                  shaded: e.key.isOdd,
                  rowColor: color,
                );
              }),

              pw.SizedBox(height: 20),
              _divider(),
              pw.Center(
                child: pw.Text(
                  'PRAEPARATIO  ·  Examination is nothing but fine preparation.',
                  style: _small(const PdfColor.fromInt(0xFF9E9E9E)),
                ),
              ),
            ],
          ),
        ),
      ],
    ));

    return doc.save();
  }

  // ════════════════════════════════════════════════════════════
  // 2. BATCH REPORT PDF (all students × all exams)
  // ════════════════════════════════════════════════════════════
  // 2. BATCH REPORT PDF
  // ════════════════════════════════════════════════════════════
  static Future<Uint8List> batchReportPdf({
    required List<UserModel> students,
    required List<ExamModel> exams,
    required List<ExamResultModel> allResults,
    required List<OfflineTestModel> offlineTests,
    required String batch,
  }) async {
    final doc = pw.Document();
    final now = _fmt(DateTime.now());

    // Build per-student stats
    final Map<String, List<double>> studentScores = {};
    for (final r in allResults) {
      studentScores.putIfAbsent(r.studentId, () => []).add(r.percentage);
    }

    final studentStats = students.map((s) {
      final scores = studentScores[s.id] ?? [];
      final avg = scores.isEmpty ? 0.0
          : scores.reduce((a, b) => a + b) / scores.length;
      final best = scores.isEmpty ? 0.0
          : scores.reduce((a, b) => a > b ? a : b);
      return _StudentStat(id: s.id, name: s.name, avg: avg, best: best, count: scores.length);
    }).toList();

    final byAvg = [...studentStats.where((s) => s.count > 0)]
      ..sort((a, b) => b.avg.compareTo(a.avg));
    final top3Avg = byAvg.take(3).toList();

    final byBest = [...studentStats.where((s) => s.count > 0)]
      ..sort((a, b) => b.best.compareTo(a.best));
    final top3Best = byBest.take(3).toList();

    // Page header (page 2+)
    pw.Widget pageHeader() => pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 8),
      decoration: pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: _primary.shade(0.4), width: 0.8)),
      ),
      child: pw.Row(children: [
        pw.Text('$batch — Batch Report',
            style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: _primary)),
        pw.Spacer(),
        pw.Text(now, style: _small()),
      ]),
    );

    // Page footer
    pw.Widget pageFooter(pw.Context ctx) => pw.Container(
      padding: const pw.EdgeInsets.only(top: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: PdfColor.fromInt(0xFFE0E0E0), width: 0.6)),
      ),
      child: pw.Row(children: [
        pw.Text('PRAEPARATIO', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: _primary.shade(0.7))),
        pw.Spacer(),
        pw.Text('Page ${ctx.pageNumber} of ${ctx.pagesCount}', style: _small(const PdfColor.fromInt(0xFF9E9E9E))),
      ]),
    );

    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(44, 44, 44, 44),
      header: (ctx) => ctx.pageNumber == 1
          ? pw.SizedBox(height: 0)
          : pw.Padding(padding: const pw.EdgeInsets.only(bottom: 12), child: pageHeader()),
      footer: (ctx) => pw.Padding(padding: const pw.EdgeInsets.only(top: 10), child: pageFooter(ctx)),
      build: (ctx) => [
        _headerBand(
          title: '$batch — Batch Report',
          subtitle: '${students.length} Students  ·  ${exams.length} Online Exams  ·  ${offlineTests.length} Offline Tests',
          right: 'Generated $now',
        ),
        pw.SizedBox(height: 20),

        // ── Performance Leaders ──
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(vertical: 6),
          child: pw.Row(children: [
            pw.Container(width: 3, height: 16, color: _primary,
                margin: const pw.EdgeInsets.only(right: 8)),
            pw.Text('PERFORMANCE LEADERS', style: _h2()),
          ]),
        ),
        pw.SizedBox(height: 10),

        pw.Row(children: [
          pw.Expanded(child: _champSection(
            title: 'Most Consistent',
            subtitle: 'Highest average across all exams',
            entries: top3Avg,
            getValue: (s) => _pct(s.avg),
            color: _primary,
          )),
          pw.SizedBox(width: 14),
          pw.Expanded(child: _champSection(
            title: 'Top Scorer',
            subtitle: 'Highest single exam score',
            entries: top3Best,
            getValue: (s) => _pct(s.best),
            color: _gold,
          )),
        ]),

        pw.SizedBox(height: 20),
        _divider(),

        // ── Student performance table ──
        pw.SizedBox(height: 10),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(vertical: 6),
          child: pw.Row(children: [
            pw.Container(width: 3, height: 16, color: _primary,
                margin: const pw.EdgeInsets.only(right: 8)),
            pw.Text('STUDENT PERFORMANCE SUMMARY', style: _h2()),
          ]),
        ),
        pw.SizedBox(height: 8),
        _tableHeader(
          ['Rank', 'Name', 'Exams', 'Avg Score', 'Best Score', 'Rating'],
          [0.6, 2.5, 0.8, 1.1, 1.1, 1.0],
        ),
        ...studentStats.asMap().entries.map((e) {
          final s = e.value;
          final rank = e.key + 1;
          final isTop = top3Avg.any((t) => t.id == s.id) || top3Best.any((t) => t.id == s.id);
          return _tableRow(
            [
              '#$rank',
              _s(s.name),
              '${s.count}',
              _pct(s.avg),
              _pct(s.best),
              s.count == 0 ? 'No data' : s.avg >= 70 ? 'Excellent' : s.avg >= 50 ? 'Good' : s.avg >= 35 ? 'Average' : 'Needs work',
            ],
            [0.6, 2.5, 0.8, 1.1, 1.1, 1.0],
            shaded: e.key.isOdd,
            rowColor: isTop ? _gold.shade(0.07) : null,
          );
        }),

        // ── Offline tests section ──
        if (offlineTests.isNotEmpty) ...[
          pw.SizedBox(height: 20),
          _divider(),
          pw.SizedBox(height: 10),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 6),
            child: pw.Row(children: [
              pw.Container(width: 3, height: 16, color: _primary,
                  margin: const pw.EdgeInsets.only(right: 8)),
              pw.Text('OFFLINE TEST OVERVIEW', style: _h2()),
            ]),
          ),
          pw.SizedBox(height: 8),
          _tableHeader(
            ['Test Name', 'Date', 'Full Marks', 'Students Recorded'],
            [2.5, 1.5, 1.2, 1.5],
          ),
          ...offlineTests.asMap().entries.map((e) {
            final t = e.value;
            final recorded = t.studentMarks.values.where((v) => v != null).length;
            return _tableRow(
              [_s(t.name), _fmt(t.date), '${t.fullMarks}', '$recorded / ${students.length}'],
              [2.5, 1.5, 1.2, 1.5],
              shaded: e.key.isOdd,
            );
          }),
        ],

        pw.SizedBox(height: 20),
        _divider(),
        pw.SizedBox(height: 8),
        pw.Center(child: pw.Text(
          'PRAEPARATIO  ·  Examination is nothing but fine preparation.',
          style: _small(const PdfColor.fromInt(0xFF9E9E9E)),
        )),
      ],
    ));

    return doc.save();
  }

  static pw.Widget _champSection({
    required String title,
    required String subtitle,
    required List<_StudentStat> entries,
    required String Function(_StudentStat) getValue,
    required PdfColor color,
  }) {
    final ranks = ['1st', '2nd', '3rd'];
    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: color.shade(0.05),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
        border: pw.Border.all(color: color.shade(0.25)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: pw.BoxDecoration(
              color: color,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
            ),
            child: pw.Text(title,
                style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: _white)),
          ),
          pw.SizedBox(height: 4),
          pw.Text(subtitle, style: _small()),
          pw.SizedBox(height: 10),
          if (entries.isEmpty)
            pw.Text('No attempts recorded', style: _small())
          else
            ...entries.asMap().entries.map((e) => pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 6),
              padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: pw.BoxDecoration(
                color: _white,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                border: pw.Border.all(color: color.shade(0.2)),
              ),
              child: pw.Row(children: [
                pw.Container(
                  width: 28, height: 14,
                  decoration: pw.BoxDecoration(
                    color: color.shade(0.15),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                  ),
                  child: pw.Center(
                    child: pw.Text(ranks[e.key],
                        style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: _dark)),
                  ),
                ),
                pw.SizedBox(width: 8),
                pw.Expanded(child: pw.Text(_s(e.value.name), style: _body())),
                pw.Text(getValue(e.value),
                    style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: _dark)),
              ]),
            )),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // 3. STUDENT INDIVIDUAL REPORT PDF
  // ════════════════════════════════════════════════════════════
  static Future<Uint8List> studentReportPdf({
    required UserModel student,
    required List<ExamResultModel> onlineResults,
    required List<OfflineTestModel> offlineTests,
  }) async {
    final doc = pw.Document();
    final now = _fmt(DateTime.now());

    final avg = onlineResults.isEmpty
        ? 0.0
        : onlineResults.map((r) => r.percentage).reduce((a, b) => a + b) /
            onlineResults.length;
    final best = onlineResults.isEmpty
        ? 0.0
        : onlineResults.map((r) => r.percentage).reduce((a, b) => a > b ? a : b);

    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(44, 44, 44, 44),
      header: (ctx) => ctx.pageNumber == 1
          ? pw.SizedBox(height: 0)
          : pw.Padding(padding: const pw.EdgeInsets.only(bottom: 12),
              child: _pageHeader(student.name, now)),
      footer: (ctx) => pw.Padding(padding: const pw.EdgeInsets.only(top: 10),
          child: _pageFooter(ctx)),
      build: (ctx) => [
        _headerBand(
          title: student.name,
          subtitle: '${student.batch}  ·  Class ${student.studentClass}  ·  @${student.username}',
          right: 'Report · $now',
        ),

        pw.Padding(
          padding: const pw.EdgeInsets.only(top: 16),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Stats
              pw.Row(children: [
                _statBox('Online Exams', '${onlineResults.length}', _primary),
                _statBox('Avg Score', _pct(avg), _green),
                _statBox('Best Score', _pct(best), _gold),
                _statBox('PrepCoins', '${student.prepcoins}', const PdfColor.fromInt(0xFFFF6F00)),
              ]),

              pw.SizedBox(height: 20),

              // Online exams table
              if (onlineResults.isNotEmpty) ...[
                pw.Text('ONLINE EXAM HISTORY', style: _h2()),
                pw.SizedBox(height: 8),
                _tableHeader(
                  ['Exam', 'Score', 'Marks', 'Date'],
                  [3.0, 1.2, 1.2, 1.5],
                ),
                ...onlineResults.asMap().entries.map((e) {
                  final r = e.value;
                  return _tableRow(
                    [
                      _s(r.examTitle),
                      _pct(r.percentage),
                      '${r.neetScore}/${r.totalQuestions * 4}',
                      _fmt(r.submittedAt),
                    ],
                    [3.0, 1.2, 1.2, 1.5],
                    shaded: e.key.isOdd,
                    rowColor: r.percentage >= 70
                        ? _green.shade(0.08)
                        : r.percentage < 35
                            ? _red.shade(0.06)
                            : null,
                  );
                }),
                pw.SizedBox(height: 16),
              ],

              // Offline marks
              if (offlineTests.isNotEmpty) ...[
                _divider(),
                pw.Text('OFFLINE TEST MARKS', style: _h2()),
                pw.SizedBox(height: 8),
                _tableHeader(
                  ['Test Name', 'Date', 'Marks', 'Full Marks', 'Percent'],
                  [2.5, 1.5, 1.0, 1.2, 1.0],
                ),
                ...offlineTests
                    .where((t) => t.studentMarks.containsKey(student.id) &&
                        t.studentMarks[student.id] != null)
                    .toList()
                    .asMap()
                    .entries
                    .map((e) {
                  final t = e.value;
                  final marks = t.studentMarks[student.id]!;
                  final pct = t.fullMarks > 0 ? marks / t.fullMarks * 100 : 0.0;
                  return _tableRow(
                    [_s(t.name), _fmt(t.date), '$marks', '${t.fullMarks}', _pct(pct)],
                    [2.5, 1.5, 1.0, 1.2, 1.0],
                    shaded: e.key.isOdd,
                  );
                }),
              ],

              pw.SizedBox(height: 20),
              _divider(),
              pw.Center(
                child: pw.Text(
                  'PRAEPARATIO  ·  Examination is nothing but fine preparation.',
                  style: _small(const PdfColor.fromInt(0xFF9E9E9E)),
                ),
              ),
            ],
          ),
        ),
      ],
    ));

    return doc.save();
  }

  // ════════════════════════════════════════════════════════════
  // 4. QUESTION PAPER PDF (exam questions)
  // ════════════════════════════════════════════════════════════
  // ── Page header (shown on page 2+) ──────────────────────────
  static pw.Widget _qpHeader(String title, bool showAnswers) =>
      pw.Container(
        padding: const pw.EdgeInsets.only(bottom: 8),
        decoration: pw.BoxDecoration(
          border: pw.Border(
            bottom: pw.BorderSide(color: _primary.shade(0.4), width: 0.8),
          ),
        ),
        child: pw.Row(children: [
          pw.Text(title,
              style: pw.TextStyle(
                  fontSize: 9, fontWeight: pw.FontWeight.bold, color: _primary)),
          pw.Spacer(),
          pw.Text(showAnswers ? 'Answer Key' : 'Question Paper',
              style: _small(_dark)),
        ]),
      );

  // ── Page footer ───────────────────────────────────────────────
  static pw.Widget _qpFooter(pw.Context ctx) => pw.Container(
        padding: const pw.EdgeInsets.only(top: 8),
        decoration: const pw.BoxDecoration(
          border: pw.Border(
            top: pw.BorderSide(color: PdfColor.fromInt(0xFFE0E0E0), width: 0.6),
          ),
        ),
        child: pw.Row(children: [
          pw.Text('PRAEPARATIO',
              style: pw.TextStyle(
                  fontSize: 8, fontWeight: pw.FontWeight.bold,
                  color: _primary.shade(0.7))),
          pw.Spacer(),
          pw.Text('Page ${ctx.pageNumber} of ${ctx.pagesCount}',
              style: _small(const PdfColor.fromInt(0xFF9E9E9E))),
        ]),
      );

  // ── Single option cell (2-column layout) ────────────────────
  static pw.Widget _optionCell(
      String letter, String text, bool isCorrect) =>
      pw.Expanded(
        child: pw.Container(
          margin: const pw.EdgeInsets.only(right: 6, bottom: 6),
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: pw.BoxDecoration(
            color: isCorrect ? _green.shade(0.12) : _white,
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
            border: pw.Border.all(
              color: isCorrect ? _green : const PdfColor.fromInt(0xFFCCCCCC),
              width: isCorrect ? 1.5 : 0.8,
            ),
          ),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                width: 18, height: 18,
                margin: const pw.EdgeInsets.only(right: 6, top: 1),
                decoration: pw.BoxDecoration(
                  color: isCorrect ? _green : _primary,
                  shape: pw.BoxShape.circle,
                ),
                child: pw.Center(
                  child: pw.Text(letter,
                      style: pw.TextStyle(
                          fontSize: 8, color: _white,
                          fontWeight: pw.FontWeight.bold)),
                ),
              ),
              pw.Expanded(
                child: pw.Text(text,
                    style: pw.TextStyle(
                        fontSize: 10,
                        color: isCorrect ? _green : _dark,
                        height: 1.4)),
              ),
            ],
          ),
        ),
      );

  static Future<Uint8List> questionPaperPdf({
    required ExamModel exam,
    required List<QuestionModel> questions,
    required bool showAnswers,
  }) async {
    final doc = pw.Document();
    final now = _fmt(DateTime.now());
    // For large exams use a compact table layout to avoid OOM on mobile/web.
    // Compact mode: plain text rows instead of styled containers per question.
    final useCompact = questions.length > 60;

    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(44, 44, 44, 44),
      header: (ctx) => ctx.pageNumber == 1
          ? pw.SizedBox(height: 0)
          : pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 12),
              child: _qpHeader(exam.title, showAnswers)),
      footer: (ctx) => pw.Padding(
          padding: const pw.EdgeInsets.only(top: 10),
          child: _qpFooter(ctx)),
      build: (ctx) => [
        // ── Cover band ──
        _headerBand(
          title: exam.title,
          subtitle: showAnswers
              ? 'Answer Key'
              : 'Question Paper  ·  ${exam.durationMinutes} min',
          right: 'PRAEPARATIO · $now',
        ),
        pw.SizedBox(height: 20),

        // ── Stats + instructions (question paper only) ──
        if (!showAnswers) ...[
          pw.Row(children: [
            _statBox('Questions', '${questions.length}', _primary),
            _statBox('Duration', '${exam.durationMinutes} min', _green),
            _statBox('Difficulty', exam.difficulty, const PdfColor.fromInt(0xFFE65100)),
            _statBox('Max Marks', '${questions.length * 4}', _gold),
          ]),
          pw.SizedBox(height: 14),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: pw.BoxDecoration(
              color: _primary.shade(0.06),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              border: pw.Border.all(color: _primary.shade(0.18)),
            ),
            child: pw.Text(
              'Instructions:  +4 for each correct answer  |  -1 for each wrong answer  |  0 for unattempted',
              style: const pw.TextStyle(fontSize: 10, color: _dark, height: 1.5),
            ),
          ),
          pw.SizedBox(height: 20),
        ],

        // ── Questions ──
        // Compact mode (>60 Qs): lightweight plain-text rows — far less memory.
        // Rich mode (≤60 Qs): styled card per question.
        if (useCompact)
          pw.Table(
            border: pw.TableBorder.all(color: const PdfColor.fromInt(0xFFE2E4EE), width: 0.5),
            columnWidths: const {0: pw.FixedColumnWidth(24), 1: pw.FlexColumnWidth()},
            children: questions.asMap().entries.map((e) {
              final q = e.value;
              final qn = e.key + 1;
              final opts = 'A. ${_s(q.optionA)}   B. ${_s(q.optionB)}\nC. ${_s(q.optionC)}   D. ${_s(q.optionD)}';
              return pw.TableRow(
                decoration: pw.BoxDecoration(color: qn.isOdd ? _surface : PdfColors.white),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text('$qn', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: _primary)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.fromLTRB(4, 6, 6, 6),
                    child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                      pw.Text(_s(q.text), style: const pw.TextStyle(fontSize: 10, color: _dark, height: 1.4)),
                      pw.SizedBox(height: 4),
                      pw.Text(opts, style: const pw.TextStyle(fontSize: 9, color: PdfColor.fromInt(0xFF444455), height: 1.4)),
                    ]),
                  ),
                ],
              );
            }).toList(),
          )
        else
          ...questions.asMap().entries.map((e) {
            final q = e.value;
            final qNum = e.key + 1;
            final options = [q.optionA, q.optionB, q.optionC, q.optionD].map((o) => _s(o)).toList();

            return pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 18),
              padding: const pw.EdgeInsets.fromLTRB(14, 14, 14, 12),
              decoration: pw.BoxDecoration(
                color: PdfColors.white,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
                border: pw.Border.all(color: const PdfColor.fromInt(0xFFE2E4EE), width: 1),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Container(
                        width: 26, height: 26,
                        margin: const pw.EdgeInsets.only(right: 10, top: 1),
                        decoration: const pw.BoxDecoration(
                            color: _primary, shape: pw.BoxShape.circle),
                        child: pw.Center(
                          child: pw.Text('$qNum',
                              style: pw.TextStyle(
                                  fontSize: 10, color: _white,
                                  fontWeight: pw.FontWeight.bold)),
                        ),
                      ),
                      pw.Expanded(
                        child: pw.Text(_s(q.text),
                            style: const pw.TextStyle(
                                fontSize: 11, color: _dark, height: 1.5)),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 12),
                  pw.Row(children: [
                    _optionCell('A', options[0], false),
                    _optionCell('B', options[1], false),
                  ]),
                  pw.Row(children: [
                    _optionCell('C', options[2], false),
                    _optionCell('D', options[3], false),
                  ]),
                ],
              ),
            );
          }),

        // ── ANSWER KEY (separate section after all questions) ──
        if (showAnswers) ...[
          pw.SizedBox(height: 10),
          // Dark header bar
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const pw.BoxDecoration(
              color: _dark,
              borderRadius: pw.BorderRadius.only(
                topLeft: pw.Radius.circular(10),
                topRight: pw.Radius.circular(10),
              ),
            ),
            child: pw.Row(children: [
              pw.Container(
                  width: 3, height: 16, color: _gold,
                  margin: const pw.EdgeInsets.only(right: 10)),
              pw.Text('ANSWER KEY',
                  style: pw.TextStyle(
                      fontSize: 13, fontWeight: pw.FontWeight.bold, color: _white)),
              pw.Spacer(),
              pw.Text('${questions.length} Questions',
                  style: const pw.TextStyle(fontSize: 9, color: PdfColor.fromInt(0xFFAAAAAA))),
            ]),
          ),
          // Quick reference grid
          pw.Container(
            padding: const pw.EdgeInsets.all(14),
            decoration: pw.BoxDecoration(
              color: const PdfColor.fromInt(0xFFF4F4F8),
              border: pw.Border.all(color: const PdfColor.fromInt(0xFFDDDDE8)),
            ),
            child: pw.Wrap(
              spacing: 6, runSpacing: 6,
              children: questions.asMap().entries.map((e) {
                final q = e.value;
                return pw.Container(
                  width: 52,
                  padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                  decoration: const pw.BoxDecoration(
                    color: PdfColors.white,
                    // No borderRadius — non-uniform border triggers pdf package assertion
                    border: pw.Border(
                      left: pw.BorderSide(color: _green, width: 2.5),
                      top: pw.BorderSide(color: PdfColor.fromInt(0xFFDDDDE8), width: 0.5),
                      right: pw.BorderSide(color: PdfColor.fromInt(0xFFDDDDE8), width: 0.5),
                      bottom: pw.BorderSide(color: PdfColor.fromInt(0xFFDDDDE8), width: 0.5),
                    ),
                  ),
                  child: pw.Row(children: [
                    pw.Text('Q${e.key + 1}',
                        style: const pw.TextStyle(
                            fontSize: 8, color: PdfColor.fromInt(0xFF888888))),
                    pw.Spacer(),
                    pw.Text(q.correctOption,
                        style: pw.TextStyle(
                            fontSize: 10, fontWeight: pw.FontWeight.bold,
                            color: _green)),
                  ]),
                );
              }).toList(),
            ),
          ),
          // Explanations — skipped for large exams to prevent OOM on device
          if (!useCompact && questions.any((q) => q.explanation != null && q.explanation!.isNotEmpty)) ...[
            pw.Container(
              padding: const pw.EdgeInsets.fromLTRB(14, 12, 14, 12),
              decoration: pw.BoxDecoration(
                color: const PdfColor.fromInt(0xFFF4F4F8),
                borderRadius: const pw.BorderRadius.only(
                  bottomLeft: pw.Radius.circular(10),
                  bottomRight: pw.Radius.circular(10),
                ),
                border: pw.Border.all(color: const PdfColor.fromInt(0xFFDDDDE8)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('EXPLANATIONS',
                      style: pw.TextStyle(
                          fontSize: 9, fontWeight: pw.FontWeight.bold,
                          color: const PdfColor.fromInt(0xFF555566))),
                  pw.SizedBox(height: 10),
                  ...questions.asMap().entries
                      .where((e) => e.value.explanation != null && e.value.explanation!.isNotEmpty)
                      .map((e) {
                    final q = e.value;
                    return pw.Container(
                      margin: const pw.EdgeInsets.only(bottom: 8),
                      padding: const pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.white,
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                        border: pw.Border.all(color: const PdfColor.fromInt(0xFFE8E8F0)),
                      ),
                      child: pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Container(
                            width: 38,
                            margin: const pw.EdgeInsets.only(right: 10),
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.center,
                              children: [
                                pw.Text('Q${e.key + 1}',
                                    style: pw.TextStyle(
                                        fontSize: 9, fontWeight: pw.FontWeight.bold,
                                        color: _dark)),
                                pw.SizedBox(height: 4),
                                pw.Container(
                                  padding: const pw.EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 4),
                                  decoration: pw.BoxDecoration(
                                    color: PdfColors.white,
                                    borderRadius: const pw.BorderRadius.all(
                                        pw.Radius.circular(5)),
                                    border: pw.Border.all(color: _green, width: 1.5),
                                  ),
                                  child: pw.Center(
                                    child: pw.Text(q.correctOption,
                                        style: pw.TextStyle(
                                            fontSize: 11,
                                            fontWeight: pw.FontWeight.bold,
                                            color: _green)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          pw.Container(
                              width: 0.8, color: const PdfColor.fromInt(0xFFE0E0E8),
                              margin: const pw.EdgeInsets.only(right: 10)),
                          pw.Expanded(
                            child: pw.Text(_s(q.explanation!),
                                style: const pw.TextStyle(
                                    fontSize: 9.5,
                                    color: PdfColor.fromInt(0xFF444455),
                                    height: 1.55)),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ] else if (useCompact && questions.any((q) => q.explanation != null && q.explanation!.isNotEmpty)) ...[
            // Compact explanation list for large exams
            pw.SizedBox(height: 10),
            pw.Text('EXPLANATIONS',
                style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold,
                    color: const PdfColor.fromInt(0xFF555566))),
            pw.SizedBox(height: 6),
            pw.Table(
              border: pw.TableBorder.all(color: const PdfColor.fromInt(0xFFE2E4EE), width: 0.5),
              columnWidths: const {0: pw.FixedColumnWidth(30), 1: pw.FixedColumnWidth(20), 2: pw.FlexColumnWidth()},
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: _dark),
                  children: ['Q#', 'Ans', 'Explanation']
                      .map((h) => pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                            child: pw.Text(h, style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: _white)),
                          ))
                      .toList(),
                ),
                ...questions.asMap().entries
                    .where((e) => e.value.explanation != null && e.value.explanation!.isNotEmpty)
                    .map((e) => pw.TableRow(
                          decoration: pw.BoxDecoration(color: e.key.isOdd ? _surface : PdfColors.white),
                          children: [
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(4),
                              child: pw.Text('Q${e.key + 1}', style: const pw.TextStyle(fontSize: 8, color: _dark)),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(4),
                              child: pw.Text(e.value.correctOption,
                                  style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: _green)),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(4),
                              child: pw.Text(
                                _s(e.value.explanation!).length > 300
                                    ? '${_s(e.value.explanation!).substring(0, 297)}...'
                                    : _s(e.value.explanation!),
                                style: const pw.TextStyle(fontSize: 8, color: _dark, height: 1.4),
                              ),
                            ),
                          ],
                        )),
              ],
            ),
          ] else ...[
            pw.Container(
              height: 10,
              decoration: pw.BoxDecoration(
                color: const PdfColor.fromInt(0xFFF4F4F8),
                borderRadius: const pw.BorderRadius.only(
                  bottomLeft: pw.Radius.circular(10),
                  bottomRight: pw.Radius.circular(10),
                ),
                border: pw.Border.all(color: const PdfColor.fromInt(0xFFDDDDE8)),
              ),
            ),
          ],
        ],
      ],
    ));

    return doc.save();
  }

  // ════════════════════════════════════════════════════════════
  // QUESTION PAPER — RTF FORMAT (opens in Word / LibreOffice)
  // ════════════════════════════════════════════════════════════
  static Uint8List questionPaperRtf({
    required ExamModel exam,
    required List<QuestionModel> questions,
    required bool showAnswers,
  }) {
    String _rtf(String s) => s
        .replaceAll('\\', '\\\\')
        .replaceAll('{', '\\{')
        .replaceAll('}', '\\}')
        .replaceAll('\n', '\\par ');

    final b = StringBuffer();

    // RTF header
    b.write('{\\rtf1\\ansi\\deff0\n');
    b.write('{\\fonttbl{\\f0\\froman\\fcharset0 Times New Roman;}'
        '{\\f1\\fswiss\\fcharset0 Arial;}'
        '{\\f2\\fmodern\\fcharset0 Courier New;}}\n');
    b.write('{\\colortbl ;\\red108\\green99\\blue255;'   // color1 = primary purple
        '\\red67\\green160\\blue71;'                     // color2 = green
        '\\red26\\green26\\blue46;'                      // color3 = dark navy
        '\\red255\\green179\\blue0;}\n');                // color4 = gold

    // Cover
    b.write('\\pard\\sb240\\sa60\\qc{\\f1\\b\\fs40\\cf3 ${_rtf(exam.title)}}\\par\n');
    b.write('\\pard\\sb0\\sa120\\qc{\\f1\\fs20\\cf3 '
        '${showAnswers ? 'ANSWER KEY' : 'QUESTION PAPER  ·  ${exam.durationMinutes} min'}'
        '}\\par\n');

    // Stats
    b.write('\\pard\\sb120\\sa80\\qc{\\f1\\fs18\\cf3 '
        '${questions.length} Questions  |  ${exam.durationMinutes} min  |  '
        '${exam.difficulty}  |  Max ${questions.length * 4} Marks}\\par\n');

    if (!showAnswers) {
      b.write('\\pard\\sb60\\sa200\\qc{\\f0\\fs17\\cf3 '
          'Instructions: +4 correct  |  \\u8722?1 wrong  |  0 unattempted}\\par\n');
    }

    // Section divider
    b.write('\\pard\\sb120\\sa80{\\f1\\b\\fs22\\cf1  QUESTIONS}\\par\n');

    // Questions
    for (int i = 0; i < questions.length; i++) {
      final q = questions[i];
      b.write('\\pard\\sb180\\sa60\\li0\\fi0'
          '{\\f1\\b\\fs22\\cf3 Q${i + 1}.}  '
          '{\\f0\\fs22\\cf3 ${_rtf(_s(q.text))}}\\par\n');

      final opts = [
        ('A', _s(q.optionA ?? '')), ('B', _s(q.optionB ?? '')),
        ('C', _s(q.optionC ?? '')), ('D', _s(q.optionD ?? '')),
      ];
      for (final o in opts) {
        b.write('\\pard\\li600\\sb40\\sa0'
            '{\\f0\\b\\fs20\\cf1  ${o.$1}.}  '
            '{\\f0\\fs20\\cf3 ${_rtf(o.$2)}}\\par\n');
      }
      b.write('\\pard\\sb40\\sa0{\\f0\\fs10  }\\par\n');
    }

    if (showAnswers) {
      // Answer Key section header
      b.write('\\pard\\sb320\\sa80\\brdrb\\brdrs\\brdrw10\\brsp20'
          '{\\f1\\b\\fs26\\cf3  ANSWER KEY}\\par\n');

      // Quick reference
      b.write('\\pard\\sb80\\sa20{\\f1\\b\\fs18\\cf3 Quick Reference:}\\par\n');
      for (int i = 0; i < questions.length; i++) {
        if (i % 5 == 0 && i > 0) b.write('\\par\n');
        b.write('{\\f2\\fs20\\cf2  Q${i + 1}:${questions[i].correctOption}   }');
      }
      b.write('\\par\n');

      // Explanations
      final withExpl = questions.asMap().entries
          .where((e) => e.value.explanation != null && e.value.explanation!.isNotEmpty)
          .toList();
      if (withExpl.isNotEmpty) {
        b.write('\\pard\\sb160\\sa40{\\f1\\b\\fs18\\cf3 Explanations:}\\par\n');
        for (final e in withExpl) {
          final q = e.value;
          b.write('\\pard\\sb100\\sa40\\li0'
              '{\\f1\\b\\fs20\\cf3 Q${e.key + 1} }  '
              '{\\f1\\b\\fs20\\cf2 (${q.correctOption})}  '
              '{\\f0\\fs20\\cf3 ${_rtf(_s(q.explanation ?? ""))}}\\par\n');
        }
      }
    }

    b.write('\\pard\\sb300\\sa0\\qc'
        '{\\f1\\fs16\\cf3 PRAEPARATIO — Examination is nothing but fine preparation.}\\par\n');
    b.write('}');

    return Uint8List.fromList(utf8.encode(b.toString()));
  }

  // ════════════════════════════════════════════════════════════
  // 5. OFFLINE TEST PROGRESS PDF
  // ════════════════════════════════════════════════════════════
  static Future<Uint8List> testProgressPdf({
    required List<OfflineTestModel> tests,
    required List<UserModel> students,
    required String batch,
  }) async {
    final doc = pw.Document();
    final now = _fmt(DateTime.now());

    // Top 3 students by avg offline score
    final studentAvgs = students.map((s) {
      final scores = tests
          .where((t) => t.studentMarks.containsKey(s.id) && t.studentMarks[s.id] != null)
          .map((t) {
        final marks = t.studentMarks[s.id]!;
        return t.fullMarks > 0 ? marks / t.fullMarks * 100.0 : 0.0;
      }).toList();
      final avg = scores.isEmpty ? 0.0 : scores.reduce((a, b) => a + b) / scores.length;
      return _StudentStat(id: s.id, name: s.name, avg: avg, best: avg, count: scores.length);
    }).where((s) => s.count > 0).toList()
      ..sort((a, b) => b.avg.compareTo(a.avg));
    final top3 = studentAvgs.take(3).toList();
    final medals = ['1st', '2nd', '3rd'];

    // Compute table columns before widget tree
    final cols = ['Name', ...tests.map((t) =>
        t.name.length > 10 ? '${t.name.substring(0, 9)}…' : t.name)];
    final flex = [2.0, ...List.filled(tests.length, 1.0)];

    // Build student rows before widget tree
    final studentRows = students.asMap().entries.map((e) {
      final s = e.value;
      final isTop = top3.any((t) => t.id == s.id);
      final cells = [
        s.name,
        ...tests.map((t) {
          final m = t.studentMarks[s.id];
          if (m == null) return '—';
          final pct = t.fullMarks > 0 ? m / t.fullMarks * 100 : 0.0;
          return '$m (${pct.toStringAsFixed(0)}%)';
        }),
      ];
      // Pad cells to match cols length
      while (cells.length < cols.length) cells.add('—');
      return _tableRow(cells, flex,
          shaded: e.key.isOdd,
          rowColor: isTop ? _gold.shade(0.08) : null);
    }).toList();

    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(44, 44, 44, 44),
      header: (ctx) => ctx.pageNumber == 1
          ? pw.SizedBox(height: 0)
          : pw.Padding(padding: const pw.EdgeInsets.only(bottom: 12),
              child: _pageHeader('$batch — Offline Test Report', now)),
      footer: (ctx) => pw.Padding(padding: const pw.EdgeInsets.only(top: 10),
          child: _pageFooter(ctx)),
      build: (ctx) => [
        _headerBand(
          title: '$batch — Offline Test Report',
          subtitle: '${students.length} Students  ·  ${tests.length} Tests',
          right: 'Generated $now',
        ),

        pw.Padding(
          padding: const pw.EdgeInsets.only(top: 16),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (top3.isNotEmpty) ...[
                pw.Center(child: pw.Text('TOP PERFORMERS', style: _h2(_primary))),
                pw.SizedBox(height: 10),
                pw.Row(
                  children: top3.asMap().entries.map((e) => pw.Expanded(
                    child: pw.Container(
                      margin: const pw.EdgeInsets.symmetric(horizontal: 4),
                      padding: const pw.EdgeInsets.all(12),
                      decoration: pw.BoxDecoration(
                        color: [_gold, _silver, _bronze][e.key].shade(0.1),
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
                        border: pw.Border.all(color: [_gold, _silver, _bronze][e.key].shade(0.4)),
                      ),
                      child: pw.Column(children: [
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: const pw.BoxDecoration(
                            color: _dark,
                            borderRadius: pw.BorderRadius.all(pw.Radius.circular(5)),
                          ),
                          child: pw.Text(medals[e.key],
                              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: _white)),
                        ),
                        pw.SizedBox(height: 6),
                        pw.Text(_s(e.value.name), style: _h3(), textAlign: pw.TextAlign.center, maxLines: 2),
                        pw.SizedBox(height: 4),
                        pw.Text(_pct(e.value.avg),
                            style: pw.TextStyle(fontSize: 16,
                                fontWeight: pw.FontWeight.bold,
                                color: _dark)),
                        pw.Text('avg across ${e.value.count} test${e.value.count == 1 ? "" : "s"}',
                            style: _small()),
                      ]),
                    ),
                  )).toList(),
                ),
                pw.SizedBox(height: 20),
                _divider(),
              ],

              pw.Text('MARKS TABLE', style: _h2()),
              pw.SizedBox(height: 8),
              _tableHeader(cols, flex),
              ...studentRows,

              pw.SizedBox(height: 20),
              _divider(),
              pw.Center(
                child: pw.Text(
                  'PRAEPARATIO  ·  Examination is nothing but fine preparation.',
                  style: _small(const PdfColor.fromInt(0xFF9E9E9E)),
                ),
              ),
            ],
          ),
        ),
      ],
    ));

    return doc.save();
  }

  // ════════════════════════════════════════════════════════════
  // 6. STUDENT TEST REPORT PDF (first attempt vs last attempt)
  // ════════════════════════════════════════════════════════════
  static pw.Widget _attemptBlock(String label, ExamResultModel r, PdfColor color) =>
      pw.Container(
        padding: const pw.EdgeInsets.all(14),
        decoration: pw.BoxDecoration(
          color: color.shade(0.08),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
          border: pw.Border.all(color: color.shade(0.3)),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(label, style: _h3(color)),
            pw.SizedBox(height: 8),
            pw.Row(children: [
              _statBox('NEET Score', '${r.neetScore}', color),
              _statBox('Correct', '${r.correctCount}', _green),
              _statBox('Wrong', '${r.incorrectCount}', _red),
            ]),
            pw.SizedBox(height: 8),
            pw.Row(children: [
              _statBox('Skipped', '${r.unattemptedCount}', _silver),
              _statBox('Percentage', _pct(r.percentage), color),
              _statBox('Date', _fmt(r.submittedAt), _dark),
            ]),
          ],
        ),
      );

  static Future<Uint8List> studentTestReportPdf({
    required ExamModel exam,
    required ExamResultModel firstAttempt,
    required ExamResultModel lastAttempt,
    required String studentName,
    required String batch,
    List<QuestionModel> questions = const [],
  }) async {
    final doc = pw.Document();
    final now = _fmt(DateTime.now());
    final isSame = firstAttempt.id == lastAttempt.id;

    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(44, 44, 44, 44),
      header: (ctx) => ctx.pageNumber == 1
          ? pw.SizedBox(height: 0)
          : pw.Padding(padding: const pw.EdgeInsets.only(bottom: 12),
              child: _pageHeader(exam.title, now)),
      footer: (ctx) => pw.Padding(padding: const pw.EdgeInsets.only(top: 10),
          child: _pageFooter(ctx)),
      build: (ctx) => [
        _headerBand(
          title: exam.title,
          subtitle: '$studentName  ·  $batch',
          right: 'Test Report · $now',
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.fromLTRB(0, 16, 0, 0),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (isSame) ...[
                pw.Center(child: pw.Text('Single Attempt',
                    style: _h2(_primary))),
                pw.SizedBox(height: 12),
                _attemptBlock('Your Attempt', firstAttempt, _primary),
              ] else ...[
                pw.Center(child: pw.Text('Attempt Comparison', style: _h2(_primary))),
                pw.SizedBox(height: 8),
                pw.Text('Showing your first and most recent attempt.',
                    style: _small()),
                pw.SizedBox(height: 12),
                _attemptBlock('First Attempt', firstAttempt, _primary),
                pw.SizedBox(height: 12),
                _attemptBlock('Latest Attempt', lastAttempt,
                    lastAttempt.neetScore >= firstAttempt.neetScore ? _green : _red),
                pw.SizedBox(height: 16),
                // Improvement summary
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: (lastAttempt.neetScore >= firstAttempt.neetScore
                            ? _green : _red).shade(0.08),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
                  ),
                  child: pw.Row(children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.all(6),
                      decoration: pw.BoxDecoration(
                        color: lastAttempt.neetScore >= firstAttempt.neetScore ? _green : _red,
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                      ),
                      child: pw.Text(
                        lastAttempt.neetScore >= firstAttempt.neetScore ? '+' : '-',
                        style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: _white),
                      ),
                    ),
                    pw.SizedBox(width: 12),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          lastAttempt.neetScore >= firstAttempt.neetScore
                              ? 'Improved by ${lastAttempt.neetScore - firstAttempt.neetScore} marks'
                              : 'Dropped by ${firstAttempt.neetScore - lastAttempt.neetScore} marks',
                          style: _h3(lastAttempt.neetScore >= firstAttempt.neetScore
                              ? _green : _red),
                        ),
                        pw.Text(
                          'Accuracy: ${firstAttempt.percentage.toStringAsFixed(1)}% > ${lastAttempt.percentage.toStringAsFixed(1)}%',
                          style: _small(),
                        ),
                      ],
                    ),
                  ]),
                ),
              ],
              // Chapter-wise analysis
              if (questions.isNotEmpty) ...[
                pw.SizedBox(height: 20),
                _chapterBreakdownSection(questions, firstAttempt.answers),
              ],
              pw.SizedBox(height: 20),
              _divider(),
              pw.Center(child: pw.Text(
                'PRAEPARATIO  ·  Examination is nothing but fine preparation.',
                style: _small(const PdfColor.fromInt(0xFF9E9E9E)),
              )),
            ],
          ),
        ),
      ],
    ));

    return doc.save();
  }

  // ════════════════════════════════════════════════════════════
  // 7. STUDENT PROGRESS REPORT PDF (all exams + offline)
  // ════════════════════════════════════════════════════════════
  static Future<Uint8List> studentProgressReportPdf({
    required UserModel student,
    required List<ExamResultModel> onlineResults,
    required Map<String, ExamModel> examMap,
    required Map<String, ({int topScore, int tiedCount})> topScores,
    required List<OfflineTestModel> offlineTests,
  }) async {
    final doc = pw.Document();
    final now = _fmt(DateTime.now());

    final avg = onlineResults.isEmpty ? 0.0
        : onlineResults.map((r) => r.percentage).reduce((a, b) => a + b) /
            onlineResults.length;

    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(44, 44, 44, 44),
      header: (ctx) => ctx.pageNumber == 1
          ? pw.SizedBox(height: 0)
          : pw.Padding(padding: const pw.EdgeInsets.only(bottom: 12),
              child: _pageHeader('${student.name} — Progress Report', now)),
      footer: (ctx) => pw.Padding(padding: const pw.EdgeInsets.only(top: 10),
          child: _pageFooter(ctx)),
      build: (ctx) => [
        _headerBand(
          title: student.name,
          subtitle: '${student.batch}  ·  Class ${student.studentClass}  ·  Progress Report',
          right: now,
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.fromLTRB(0, 16, 0, 0),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Summary stats
              pw.Row(children: [
                _statBox('Online Exams', '${onlineResults.length}', _primary),
                _statBox('Avg Score', _pct(avg), _green),
                _statBox('Offline Tests', '${offlineTests.length}', const PdfColor.fromInt(0xFF0288D1)),
                _statBox('PrepCoins', '${student.prepcoins}', _gold),
              ]),

              if (onlineResults.isNotEmpty) ...[
                pw.SizedBox(height: 20),
                pw.Text('ONLINE EXAM PERFORMANCE', style: _h2()),
                pw.SizedBox(height: 8),
                _tableHeader(
                  ['Exam', 'My Score', 'Top Score', 'Percentile', 'Date'],
                  [3.0, 1.2, 1.8, 1.2, 1.5],
                ),
                ...onlineResults.asMap().entries.map((e) {
                  final r = e.value;
                  final exam = examMap[r.examId];
                  final ts = topScores[r.examId];
                  final topLabel = ts == null ? '—'
                      : ts.tiedCount > 1
                          ? '${ts.topScore} (${ts.tiedCount} tied)'
                          : '${ts.topScore}';
                  return _tableRow(
                    [
                      _s(exam?.title ?? r.examTitle),
                      '${r.neetScore} (${_pct(r.percentage)})',
                      topLabel,
                      r.neetScore == (ts?.topScore ?? -1) ? 'Top!' : '—',
                      _fmt(r.submittedAt),
                    ],
                    [3.0, 1.2, 1.8, 1.2, 1.5],
                    shaded: e.key.isOdd,
                    rowColor: r.neetScore == (ts?.topScore ?? -1)
                        ? _gold.shade(0.1) : null,
                  );
                }),
              ],

              if (offlineTests.isNotEmpty) ...[
                pw.SizedBox(height: 20),
                _divider(),
                pw.Text('OFFLINE TEST MARKS', style: _h2()),
                pw.SizedBox(height: 8),
                _tableHeader(
                  ['Test', 'My Marks', 'Full Marks', 'Percentage'],
                  [3.0, 1.2, 1.2, 1.2],
                ),
                ...offlineTests
                    .where((t) => t.studentMarks.containsKey(student.id)
                        && t.studentMarks[student.id] != null)
                    .toList()
                    .asMap()
                    .entries
                    .map((e) {
                  final t = e.value;
                  final m = t.studentMarks[student.id]!;
                  final pct = t.fullMarks > 0 ? m / t.fullMarks * 100 : 0.0;
                  return _tableRow(
                    [_s(t.name), '$m', '${t.fullMarks}', _pct(pct)],
                    [3.0, 1.2, 1.2, 1.2],
                    shaded: e.key.isOdd,
                  );
                }),
              ],

              pw.SizedBox(height: 20),
              _divider(),
              pw.Center(child: pw.Text(
                'PRAEPARATIO  ·  Examination is nothing but fine preparation.',
                style: _small(const PdfColor.fromInt(0xFF9E9E9E)),
              )),
            ],
          ),
        ),
      ],
    ));

    return doc.save();
  }
  // ── Chapter-wise breakdown section (used in test report PDF) ─────────────
  static pw.Widget _chapterBreakdownSection(
      List<QuestionModel> questions, Map<String, String> answers) {
    // Compute stats per chapter
    final stats = <String, List<int>>{}; // chapter → [total, correct]
    for (final q in questions) {
      final ch = q.chapter.isEmpty ? 'General' : q.chapter;
      stats.putIfAbsent(ch, () => [0, 0]);
      stats[ch]![0]++;
      final sel = answers[q.id];
      if (sel != null && sel.toUpperCase() == q.correctOption.toUpperCase()) {
        stats[ch]![1]++;
      }
    }
    var sorted = stats.entries.toList()
      ..sort((a, b) => b.value[0].compareTo(a.value[0]));
    // Cap at 20 rows to prevent OOM on large multi-chapter exams
    if (sorted.length > 20) sorted = sorted.take(20).toList();

    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: _primary.shade(0.05),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
        border: pw.Border.all(color: _primary.shade(0.2)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Chapter-wise Analysis', style: _h3(_primary)),
          pw.SizedBox(height: 10),
          pw.Table(
            columnWidths: {
              0: const pw.FlexColumnWidth(4),
              1: const pw.FlexColumnWidth(1.5),
              2: const pw.FlexColumnWidth(1.5),
              3: const pw.FlexColumnWidth(1.5),
            },
            children: [
              // Header row
              pw.TableRow(
                decoration: pw.BoxDecoration(color: _primary.shade(0.12)),
                children: ['Chapter', 'Total', 'Correct', 'Score%']
                    .map((h) => pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                          child: pw.Text(h,
                              style: pw.TextStyle(
                                  fontSize: 9,
                                  fontWeight: pw.FontWeight.bold,
                                  color: _primary)),
                        ))
                    .toList(),
              ),
              // Data rows
              ...sorted.map((e) {
                final total = e.value[0], correct = e.value[1];
                final pct = total > 0 ? (correct / total * 100).round() : 0;
                final rowColor = pct >= 70 ? _green : pct >= 40 ? _gold : _red;
                return pw.TableRow(children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: pw.Text(e.key,
                        style: const pw.TextStyle(fontSize: 8),
                        maxLines: 2),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: pw.Text('$total',
                        style: const pw.TextStyle(fontSize: 9)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: pw.Text('$correct',
                        style: pw.TextStyle(fontSize: 9, color: rowColor,
                            fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: pw.Text('$pct%',
                        style: pw.TextStyle(fontSize: 9, color: rowColor,
                            fontWeight: pw.FontWeight.bold)),
                  ),
                ]);
              }),
            ],
          ),
        ],
      ),
    );
  }

  // ── Chatbot answer PDF ────────────────────────────────────────

  static Future<Uint8List> chatbotAnswerPdf({
    required String question,
    required String answer,
    required String studentName,
  }) async {
    final doc = pw.Document();
    final now = DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now());

    // MultiPage so long answers flow across pages instead of being clipped
    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(36),
      footer: (ctx) => pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('PRAEPARATIO — NEET Biology Preparation',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500)),
          pw.Text('Page ${ctx.pageNumber} of ${ctx.pagesCount}',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500)),
        ],
      ),
      build: (ctx) => [
        // Header
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: pw.BoxDecoration(
            color: _primary,
            borderRadius: pw.BorderRadius.circular(10),
          ),
          child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Text('PRAEPARATIO', style: pw.TextStyle(color: PdfColors.white, fontSize: 18, fontWeight: pw.FontWeight.bold, letterSpacing: 2)),
            pw.SizedBox(height: 3),
            pw.Text('Biology Doubt Solver — Answer Sheet',
                style: const pw.TextStyle(color: PdfColors.white, fontSize: 11)),
          ]),
        ),
        pw.SizedBox(height: 20),

        // Meta row
        pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
          pw.Text('Student: $studentName', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
          pw.Text(now, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
        ]),
        pw.SizedBox(height: 16),
        pw.Divider(color: PdfColors.grey300),
        pw.SizedBox(height: 14),

        // Question — no borderRadius: pdf package forbids borderRadius + non-uniform border
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(14),
          decoration: const pw.BoxDecoration(
            color: PdfColor.fromInt(0xFFEEF2FF),
            border: pw.Border(left: pw.BorderSide(color: _primary, width: 4)),
          ),
          child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Text('QUESTION', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: _primary, letterSpacing: 1.5)),
            pw.SizedBox(height: 6),
            pw.Text(_s(question), style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: _dark, lineSpacing: 1.4)),
          ]),
        ),
        pw.SizedBox(height: 16),

        // Answer — no borderRadius: same reason; MultiPage handles long answers across pages
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(14),
          decoration: const pw.BoxDecoration(
            color: PdfColor.fromInt(0xFFF0FFF4),
            border: pw.Border(left: pw.BorderSide(color: _green, width: 4)),
          ),
          child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Text('ANSWER', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: _green, letterSpacing: 1.5)),
            pw.SizedBox(height: 8),
            pw.Text(_s(answer), style: const pw.TextStyle(fontSize: 12, lineSpacing: 1.6)),
          ]),
        ),
        pw.SizedBox(height: 24),
        pw.Divider(color: PdfColors.grey200),
        pw.SizedBox(height: 6),
        pw.Text('Note: Chats are not saved. This PDF is your only record.',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500)),
      ],
    ));

    return doc.save();
  }

} // end PdfService

// ── Internal helper ───────────────────────────────────────────
class _StudentStat {
  final String id;
  final String name;
  final double avg;
  final double best;
  final int count;
  const _StudentStat({
    required this.id,
    required this.name,
    required this.avg,
    required this.best,
    required this.count,
  });
}
