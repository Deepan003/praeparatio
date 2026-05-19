class OfflineTestModel {
  final String id;
  final String name;
  final DateTime date;
  final int fullMarks;
  final String batch;
  Map<String, int?> studentMarks;  // studentId -> marks (null = absent)

  OfflineTestModel({
    required this.id,
    required this.name,
    required this.date,
    required this.fullMarks,
    required this.batch,
    Map<String, int?>? studentMarks,
  }) : studentMarks = studentMarks ?? {};

  Map<String, dynamic> toMap() => {
        'id': id, 'name': name, 'date': date.toIso8601String(),
        'fullMarks': fullMarks, 'batch': batch, 'studentMarks': studentMarks,
      };

  factory OfflineTestModel.fromMap(Map<String, dynamic> map) => OfflineTestModel(
        id: map['id'], name: map['name'],
        date: DateTime.parse(map['date']),
        fullMarks: map['fullMarks'],
        batch: map['batch'],
        studentMarks: Map<String, int?>.from(map['studentMarks'] ?? {}),
      );
}
