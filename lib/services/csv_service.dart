import 'dart:convert';
import 'dart:typed_data';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../models/exam_model.dart';
import '../models/exam_result_model.dart';
import '../models/offline_test_model.dart';
import '../models/user_model.dart';
import '../models/pyq_model.dart';
import '../services/auth_service.dart';
import 'package:uuid/uuid.dart';

class CsvService {
  static const _uuid = Uuid();

  static Future<Uint8List?> pickCsvFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
      withData: true,
    );
    return result?.files.single.bytes;
  }

  static List<List<dynamic>> parseCsv(Uint8List bytes) {
    // Decode as UTF-8 so special chars (α β °C → etc.) survive intact.
    // allowMalformed: true prevents a crash on slightly mis-encoded files.
    final content = utf8.decode(bytes, allowMalformed: true);
    // Normalise Windows (\r\n) and old Mac (\r) line endings → Unix (\n)
    // so the CSV parser's eol: '\n' works for ALL CSV exports.
    final normalised = content.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    return const CsvToListConverter(
      eol: '\n',
      shouldParseNumbers: false, // keep year as string; we parse it ourselves
    ).convert(normalised);
  }

  /// Import students from CSV.
  /// Expected columns: name, username, password, class, batch
  static List<UserModel> parseStudentsCsv(Uint8List bytes) {
    final rows = parseCsv(bytes);
    if (rows.isEmpty) return [];
    final header = rows[0].map((e) => e.toString().trim().toLowerCase()).toList();
    final nameIdx = header.indexOf('name');
    final usernameIdx = header.indexOf('username');
    final passwordIdx = header.indexOf('password');
    final classIdx = header.indexOf('class');
    final batchIdx = header.indexOf('batch');

    final users = <UserModel>[];
    for (int i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.length < 3) continue;
      final name = nameIdx >= 0 ? row[nameIdx].toString() : row[0].toString();
      final username = usernameIdx >= 0 ? row[usernameIdx].toString() : row[1].toString();
      final password = passwordIdx >= 0 ? row[passwordIdx].toString() : row[2].toString();
      final cls = classIdx >= 0 && classIdx < row.length ? row[classIdx].toString() : '11';
      final batch = batchIdx >= 0 && batchIdx < row.length ? row[batchIdx].toString() : '11 NEET';

      if (username.isEmpty || password.isEmpty) continue;
      users.add(UserModel(
        id: _uuid.v4(),
        name: name,
        username: username.toLowerCase().trim(),
        passwordHash: AuthService.hashPassword(password),
        passwordPlain: password, // store plain text for admin visibility
        studentClass: cls.trim(),
        batch: batch.trim(),
        createdAt: DateTime.now(),
      ));
    }
    return users;
  }

  /// Import PYQ from CSV.
  /// Required columns (in order): year (ignored/overwritten by yearName), chapter, question, optionA, optionB, optionC, optionD, correct
  /// Optional columns:            imageUrl, explanation
  static List<PYQModel> parsePYQCsv(Uint8List bytes, String yearName) {
    final rows = parseCsv(bytes);
    if (rows.isEmpty) return [];
    final pyq  = <PYQModel>[];
    int skipped = 0;

    for (int i = 1; i < rows.length; i++) {
      final row = rows[i];

      // Trim every cell to remove stray \r or whitespace
      final cells = row.map((e) => e.toString().trim()).toList();

      // Need at least 8 non-empty columns (year..correct)
      if (cells.length < 8) { skipped++; continue; }

      // Skip completely blank rows (often trailing newlines at EOF)
      if (cells.every((c) => c.isEmpty)) continue;

      // The question text and correct option are mandatory
      if (cells[2].isEmpty || cells[7].isEmpty) { skipped++; continue; }

      // Correct option must be A/B/C/D (guard against header row being re-read)
      final correct = cells[7].toUpperCase();
      if (!['A', 'B', 'C', 'D'].contains(correct)) { skipped++; continue; }

      try {
        pyq.add(PYQModel.fromCsvRow(cells, i, yearName));
      } catch (e) {
        skipped++;
        debugPrint('[PYQ CSV] row $i skipped: $e');
      }
    }

    if (skipped > 0) {
      debugPrint('[PYQ CSV] Parsed ${pyq.length} valid rows, $skipped skipped.');
    }
    return pyq;
  }

  /// Export students list as CSV bytes (includes plain password column)
  static Uint8List exportStudentsCsv(List<UserModel> users) {
    final rows = <List<dynamic>>[
      ['Name', 'Username', 'Password', 'Class', 'Batch', 'Prepcoins', 'Banned'],
      ...users.map((u) => [
            u.name, u.username, u.passwordPlain,
            u.studentClass, u.batch, u.prepcoins, u.isBanned
          ]),
    ];
    final csv = const ListToCsvConverter().convert(rows);
    return Uint8List.fromList(csv.codeUnits);
  }

  /// Export exam questions as CSV bytes
  static Uint8List exportQuestionsCsv(List<dynamic> questions) {
    final rows = <List<dynamic>>[
      ['Question', 'Option A', 'Option B', 'Option C', 'Option D', 'Correct', 'Chapter', 'Difficulty', 'Explanation'],
      ...questions.map((q) => [q.text, q.optionA, q.optionB, q.optionC, q.optionD, q.correctOption, q.chapter, q.difficulty, q.explanation ?? '']),
    ];
    final csv = const ListToCsvConverter().convert(rows);
    return Uint8List.fromList(csv.codeUnits);
  }

  // ── Reporting CSVs ────────────────────────────────────────────

  // Date format that Excel CANNOT auto-convert to a date serial number.
  // "15-May-2026 at 10:30" — the word "at" prevents Excel date detection.
  static String _fmtDate(DateTime dt) =>
      DateFormat("dd-MMM-yyyy 'at' HH:mm").format(dt.toLocal());
  static String _fmtDateOnly(DateTime dt) =>
      DateFormat("dd-MMM-yyyy").format(dt.toLocal());

  /// Exam Analytics: all student first-attempt results for one online exam
  static Uint8List exportExamResults(
      ExamModel exam, List<ExamResultModel> results, Map<String, UserModel> studentMap) {
    final rows = <List<dynamic>>[
      ['Student Name', 'Batch', 'NEET Score', 'Score %', 'Correct', 'Wrong', 'Skipped', 'Time Taken', 'Submitted On'],
      ...results.map((r) {
        final s = studentMap[r.studentId];
        final m = r.timeTakenSeconds ~/ 60;
        final sec = r.timeTakenSeconds % 60;
        return [
          s?.name ?? r.studentId,
          s?.batch ?? '',
          r.neetScore,
          '${r.percentage.toStringAsFixed(1)}%',
          r.correctCount,
          r.incorrectCount,
          r.unattemptedCount,
          '${m}m ${sec}s',
          _fmtDate(r.submittedAt),  // "15-May-2026 at 10:30" — Excel-safe
        ];
      }),
    ];
    return _toCsv(rows);
  }

  /// Test Progress Report: all offline test marks for a batch
  static Uint8List exportTestProgressReport(
      List<OfflineTestModel> tests, List<UserModel> students) {
    // Header row: Name, Batch, [Test Name (Date, /FullMarks)], ..., Total
    final testHeaders = tests
        .map((t) => '${t.name}\n(${_fmtDateOnly(t.date)}, /${t.fullMarks})')
        .toList();
    final header = ['Student Name', 'Batch', ...testHeaders, 'Total Scored', 'Total Marks'];

    // Separate date row for clarity
    final dateRow = ['', '', ...tests.map((t) => _fmtDateOnly(t.date)), '', ''];

    final rows = <List<dynamic>>[
      ['PRAEPARATIO — Test Progress Report'],
      ['Batch report — generated ${_fmtDateOnly(DateTime.now())}'],
      [],
      header,
      dateRow,
    ];

    for (final s in students) {
      int totalScored = 0, totalMarks = 0;
      final marks = tests.map((t) {
        final m = t.studentMarks[s.id];
        if (m != null) {
          totalScored += m;
          totalMarks += t.fullMarks;
        }
        return m != null ? m : 'Absent';
      }).toList();
      rows.add([s.name, s.batch, ...marks, totalScored, totalMarks]);
    }
    return _toCsv(rows);
  }

  /// Student Report: one student's online first-attempts + offline marks
  static Uint8List exportStudentReport(UserModel student,
      List<ExamResultModel> onlineResults, List<OfflineTestModel> offlineTests) {
    final rows = <List<dynamic>>[
      // Header
      ['PRAEPARATIO — Student Progress Report'],
      ['Name: ${student.name}', 'Batch: ${student.batch}', 'Username: ${student.username}'],
      [],
      // Online exams section
      ['--- ONLINE EXAMS (First Attempt) ---'],
      ['Exam Name', 'Date Attempted', 'NEET Score', 'Score %', 'Correct', 'Wrong', 'Skipped'],
      ...onlineResults.map((r) => [
        r.examTitle.isEmpty ? 'Online Exam' : r.examTitle,
        _fmtDate(r.submittedAt),        // Excel-safe format
        r.neetScore,
        '${r.percentage.toStringAsFixed(1)}%',
        r.correctCount,
        r.incorrectCount,
        r.unattemptedCount,
      ]),
      [],
      ['--- OFFLINE TESTS ---'],
      ['Test Name', 'Test Date', 'Full Marks', 'Score', 'Percentage'],
      ...offlineTests.map((t) {
        final score = t.studentMarks[student.id];
        final pct = (score != null && t.fullMarks > 0)
            ? '${(score / t.fullMarks * 100).toStringAsFixed(1)}%'
            : '—';
        return [t.name, _fmtDateOnly(t.date), t.fullMarks, score ?? 'Absent', pct];
      }),
    ];
    return _toCsv(rows);
  }

  /// Batch Report: all students, all online (first attempt) + offline marks
  static Uint8List exportBatchReport(
      List<UserModel> students,
      List<ExamModel> exams,
      List<ExamResultModel> allResults, // all first-attempt results for batch
      List<OfflineTestModel> offlineTests) {
    // Column headers: Name, Batch, [Exam1 NEET], [Exam2 NEET], ..., [Test1 Score], ...
    final examHeaders = exams.map((e) => 'Online: ${e.title.length > 20 ? "${e.title.substring(0, 20)}…" : e.title}').toList();
    final testHeaders = offlineTests.map((t) => 'Offline: ${t.name}\n(${_fmtDateOnly(t.date)}, /${t.fullMarks})').toList();

    final rows = <List<dynamic>>[
      ['PRAEPARATIO — Batch Report'],
      ['Batch Report — Generated ${_fmtDateOnly(DateTime.now())}'],
      [],
      ['Student Name', 'Batch', ...examHeaders, ...testHeaders],
    ];

    // Build a lookup: studentId → examId → result
    final resultLookup = <String, Map<String, ExamResultModel>>{};
    for (final r in allResults) {
      if (!resultLookup.containsKey(r.studentId)) {
        resultLookup[r.studentId] = {};
      }
      resultLookup[r.studentId]![r.examId] = r;
    }

    for (final s in students) {
      final onlineScores = exams.map((e) {
        final r = resultLookup[s.id]?[e.id];
        return r != null ? '${r.neetScore}' : 'N/A';
      }).toList();
      final offlineScores = offlineTests.map((t) {
        final m = t.studentMarks[s.id];
        return m != null ? '$m' : 'Absent';
      }).toList();
      rows.add([s.name, s.batch, ...onlineScores, ...offlineScores]);
    }
    return _toCsv(rows);
  }

  static Uint8List _toCsv(List<List<dynamic>> rows) {
    final csv = const ListToCsvConverter().convert(rows);
    return Uint8List.fromList(csv.codeUnits);
  }
}
