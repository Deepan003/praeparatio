class ExamModel {
  final String id;
  final String title;
  final String description;
  final List<String> targetBatches;
  int durationMinutes;
  List<String> questionIds;
  final String difficulty;
  final String type;
  List<String> chapters;
  bool isPublished;
  final DateTime createdAt;
  DateTime? publishedAt;
  DateTime? visibilityStart;
  DateTime? visibilityEnd;
  int expRequired;
  int expGained;
  String tag;
  String avatarId;
  bool isNew;
  final String? aiPrompt;
  final String createdBy;
  final int? selectedClass;

  /// When true, class ranking is visible to students.
  /// Admin publishes results only after all/most students have attempted,
  /// preventing rank fluctuation as more students submit.
  bool resultsPublished;

  /// Credit earning mode: 'none' | 'attempts' | 'time'
  /// 'none'     — coins awarded on any first attempt
  /// 'attempts' — student must answer ≥ creditThreshold% of questions
  /// 'time'     — student must spend ≥ creditThreshold% of allotted time
  String creditMode;

  /// Minimum percentage (0–100) required to earn credits. Default 30.
  int creditThreshold;

  /// When true, students can download the question paper + answer key
  /// after completing their first attempt.
  bool allowDownload;

  ExamModel({
    required this.id,
    required this.title,
    this.description = '',
    required this.targetBatches,
    required this.durationMinutes,
    List<String>? questionIds,
    this.difficulty = 'Medium',
    this.type = 'manual',
    List<String>? chapters,
    this.isPublished = false,
    required this.createdAt,
    this.publishedAt,
    this.visibilityStart,
    this.visibilityEnd,
    this.expRequired = 0,
    this.expGained = 100,
    this.tag = 'Practice',
    this.avatarId = 'av_01',
    this.isNew = true,
    this.aiPrompt,
    required this.createdBy,
    this.selectedClass,
    this.creditMode = 'none',
    this.creditThreshold = 30,
    this.resultsPublished = false,
    this.allowDownload = false,
  })  : questionIds = questionIds ?? [],
        chapters = chapters ?? [];

  bool get isActive {
    if (!isPublished) return false;
    final now = DateTime.now();
    if (visibilityStart != null && now.isBefore(visibilityStart!)) return false;
    if (visibilityEnd != null && now.isAfter(visibilityEnd!)) return false;
    return true;
  }

  bool get isExpired =>
      visibilityEnd != null && DateTime.now().isAfter(visibilityEnd!);

  /// Returns true if the student has met the credit threshold
  bool meetsThreshold({required int answeredCount, required int totalQuestions,
      required int elapsedSeconds}) {
    if (creditMode == 'none') return true;
    if (totalQuestions == 0) return true;
    final pct = creditMode == 'attempts'
        ? answeredCount / totalQuestions * 100
        : elapsedSeconds / (durationMinutes * 60) * 100;
    return pct >= creditThreshold;
  }

  Map<String, dynamic> toMap() => {
        'id': id, 'title': title, 'description': description,
        'targetBatches': targetBatches, 'durationMinutes': durationMinutes,
        'questionIds': questionIds, 'difficulty': difficulty, 'type': type,
        'chapters': chapters, 'isPublished': isPublished,
        'createdAt': createdAt.toIso8601String(),
        'publishedAt': publishedAt?.toIso8601String(),
        'visibilityStart': visibilityStart?.toIso8601String(),
        'visibilityEnd': visibilityEnd?.toIso8601String(),
        'expRequired': expRequired, 'expGained': expGained, 'tag': tag,
        'avatarId': avatarId, 'isNew': isNew, 'aiPrompt': aiPrompt,
        'createdBy': createdBy, 'selectedClass': selectedClass,
        'creditMode': creditMode, 'creditThreshold': creditThreshold,
        'resultsPublished': resultsPublished,
        'allowDownload': allowDownload,
      };

  factory ExamModel.fromMap(Map<String, dynamic> map) => ExamModel(
        id: map['id'],
        title: map['title'],
        description: map['description'] ?? '',
        targetBatches: List<String>.from(map['targetBatches'] ?? []),
        durationMinutes: map['durationMinutes'] ?? 60,
        questionIds: List<String>.from(map['questionIds'] ?? []),
        difficulty: map['difficulty'] ?? 'Medium',
        type: map['type'] ?? 'manual',
        chapters: List<String>.from(map['chapters'] ?? []),
        isPublished: map['isPublished'] ?? false,
        createdAt: DateTime.parse(map['createdAt']),
        publishedAt: map['publishedAt'] != null
            ? DateTime.parse(map['publishedAt'])
            : null,
        visibilityStart: map['visibilityStart'] != null
            ? DateTime.parse(map['visibilityStart'])
            : null,
        visibilityEnd: map['visibilityEnd'] != null
            ? DateTime.parse(map['visibilityEnd'])
            : null,
        expRequired: map['expRequired'] ?? 0,
        expGained: map['expGained'] ?? 100,
        tag: map['tag'] ?? 'Practice',
        avatarId: map['avatarId'] ?? 'av_01',
        isNew: map['isNew'] ?? true,
        aiPrompt: map['aiPrompt'],
        createdBy: map['createdBy'] ?? '',
        selectedClass: map['selectedClass'],
        creditMode: map['creditMode'] ?? 'none',
        creditThreshold: map['creditThreshold'] ?? 30,
        resultsPublished: map['resultsPublished'] ?? false,
        allowDownload: map['allowDownload'] ?? false,
      );

  ExamModel copyWith({
    String? title, String? description, List<String>? targetBatches,
    int? durationMinutes, List<String>? questionIds, List<String>? chapters,
    bool? isPublished, DateTime? visibilityStart, DateTime? visibilityEnd,
    int? expRequired, int? expGained, String? tag, String? avatarId, bool? isNew,
    String? creditMode, int? creditThreshold, bool? resultsPublished,
  }) =>
      ExamModel(
        id: id, title: title ?? this.title,
        description: description ?? this.description,
        targetBatches: targetBatches ?? List.from(this.targetBatches),
        durationMinutes: durationMinutes ?? this.durationMinutes,
        questionIds: questionIds ?? List.from(this.questionIds),
        difficulty: difficulty, type: type,
        chapters: chapters ?? List.from(this.chapters),
        isPublished: isPublished ?? this.isPublished,
        createdAt: createdAt, publishedAt: publishedAt,
        visibilityStart: visibilityStart ?? this.visibilityStart,
        visibilityEnd: visibilityEnd ?? this.visibilityEnd,
        expRequired: expRequired ?? this.expRequired,
        expGained: expGained ?? this.expGained,
        tag: tag ?? this.tag, avatarId: avatarId ?? this.avatarId,
        isNew: isNew ?? this.isNew, aiPrompt: aiPrompt,
        createdBy: createdBy, selectedClass: selectedClass,
        creditMode: creditMode ?? this.creditMode,
        creditThreshold: creditThreshold ?? this.creditThreshold,
        resultsPublished: resultsPublished ?? this.resultsPublished,
      );
}
