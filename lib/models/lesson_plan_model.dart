class LessonPlanModel {
  final String id;
  final String studentId;
  String title;
  final DateTime date;
  List<LessonTask> tasks;
  String? notes;
  bool isCompleted;
  final String color;

  LessonPlanModel({
    required this.id,
    required this.studentId,
    required this.title,
    required this.date,
    List<LessonTask>? tasks,
    this.notes,
    this.isCompleted = false,
    this.color = '#4C3FA0',
  }) : tasks = tasks ?? [];

  int get completedTasks => tasks.where((t) => t.isDone).length;
  double get progress => tasks.isEmpty ? 0 : completedTasks / tasks.length;

  Map<String, dynamic> toMap() => {
        'id': id, 'studentId': studentId, 'title': title,
        'date': date.toIso8601String(),
        'tasks': tasks.map((t) => t.toMap()).toList(),
        'notes': notes, 'isCompleted': isCompleted, 'color': color,
      };

  factory LessonPlanModel.fromMap(Map<String, dynamic> map) => LessonPlanModel(
        id: map['id'], studentId: map['studentId'], title: map['title'],
        date: DateTime.parse(map['date']),
        tasks: (map['tasks'] as List? ?? [])
            .map((t) => LessonTask.fromMap(Map<String, dynamic>.from(t)))
            .toList(),
        notes: map['notes'], isCompleted: map['isCompleted'] ?? false, color: map['color'] ?? '#4C3FA0',
      );
}

class LessonTask {
  final String id;
  String title;
  bool isDone;
  final String? chapter;
  final String type;  // 'study', 'practice', 'revision', 'test'

  LessonTask({
    required this.id,
    required this.title,
    this.isDone = false,
    this.chapter,
    this.type = 'study',
  });

  Map<String, dynamic> toMap() => {
        'id': id, 'title': title, 'isDone': isDone, 'chapter': chapter, 'type': type,
      };

  factory LessonTask.fromMap(Map<String, dynamic> map) => LessonTask(
        id: map['id'], title: map['title'], isDone: map['isDone'] ?? false,
        chapter: map['chapter'], type: map['type'] ?? 'study',
      );
}
