class FlashcardModel {
  final String id;
  final String chapter;
  final String front;
  final String back;
  final String? imageUrl;
  final String category;   // 'definition', 'fact', 'process', 'diagram'
  final String studentClass;

  const FlashcardModel({
    required this.id,
    required this.chapter,
    required this.front,
    required this.back,
    this.imageUrl,
    this.category = 'fact',
    required this.studentClass,
  });

  Map<String, dynamic> toMap() => {
        'id': id, 'chapter': chapter, 'front': front, 'back': back,
        'imageUrl': imageUrl, 'category': category, 'studentClass': studentClass,
      };

  factory FlashcardModel.fromMap(Map<String, dynamic> map) => FlashcardModel(
        id: map['id'], chapter: map['chapter'], front: map['front'], back: map['back'],
        imageUrl: map['imageUrl'], category: map['category'] ?? 'fact',
        studentClass: map['studentClass'] ?? '11',
      );
}
