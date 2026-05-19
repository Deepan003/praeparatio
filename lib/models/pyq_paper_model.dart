class PYQPaperModel {
  final String id;
  final String yearName;
  final String pdfUrl;
  final DateTime createdAt;

  const PYQPaperModel({
    required this.id,
    required this.yearName,
    required this.pdfUrl,
    required this.createdAt,
  });

  factory PYQPaperModel.fromJson(Map<String, dynamic> j) => PYQPaperModel(
        id: j['id'] as String,
        yearName: j['year_name'] as String,
        pdfUrl: j['pdf_url'] as String,
        createdAt: DateTime.parse(j['created_at'] as String),
      );
}
