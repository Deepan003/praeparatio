class BatchModel {
  final String name;
  final String classLevel; // '11', '12', 'neet'
  final int displayOrder;

  const BatchModel({
    required this.name,
    required this.classLevel,
    this.displayOrder = 0,
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'class_level': classLevel,
    'display_order': displayOrder,
  };

  factory BatchModel.fromMap(Map<String, dynamic> r) => BatchModel(
    name: r['name'] as String,
    classLevel: r['class_level'] as String? ?? '11',
    displayOrder: r['display_order'] as int? ?? 0,
  );

  String get classLevelLabel {
    switch (classLevel) {
      case '12': return 'Class 12';
      case 'neet': return 'NEET';
      default: return 'Class 11';
    }
  }
}
