class NoteModel {
  final String id;
  final String name;
  final String link;
  final String visibility;
  final String sectionId;
  final String sectionName;
  final DateTime createdAt;
  final bool isLink;
  final bool isPrivate;
  final int sortOrder; // controls display order; lower = shown first

  NoteModel({
    required this.id,
    required this.name,
    required this.link,
    this.visibility = 'all',
    required this.sectionId,
    required this.sectionName,
    required this.createdAt,
    this.isLink = false,
    this.isPrivate = false,
    this.sortOrder = 0,
  });

  NoteModel copyWith({
    String? visibility,
    int? sortOrder,
    String? sectionName,
    String? sectionId,
    bool? isPrivate,
  }) =>
      NoteModel(
        id: id, name: name, link: link,
        visibility: visibility ?? this.visibility,
        sectionId: sectionId ?? this.sectionId,
        sectionName: sectionName ?? this.sectionName,
        createdAt: createdAt, isLink: isLink,
        isPrivate: isPrivate ?? this.isPrivate,
        sortOrder: sortOrder ?? this.sortOrder,
      );

  Map<String, dynamic> toMap() => {
        'id': id, 'name': name, 'link': link, 'visibility': visibility,
        'sectionId': sectionId, 'sectionName': sectionName,
        'createdAt': createdAt.toIso8601String(),
        'isLink': isLink, 'isPrivate': isPrivate,
        'sortOrder': sortOrder,
      };

  factory NoteModel.fromMap(Map<String, dynamic> map) => NoteModel(
        id: map['id'], name: map['name'], link: map['link'],
        visibility: map['visibility'] ?? 'all',
        sectionId: map['sectionId'] ?? '', sectionName: map['sectionName'] ?? '',
        createdAt: DateTime.parse(map['createdAt']),
        isLink: map['isLink'] ?? false,
        isPrivate: map['isPrivate'] ?? false,
        sortOrder: map['sortOrder'] ?? 0,
      );
}
