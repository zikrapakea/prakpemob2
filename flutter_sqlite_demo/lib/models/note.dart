class Note {
  final int? id;
  final String title;
  final String content;
  final String? createdAt;
  final String category;
  final int color;

  Note({
    this.id,
    required this.title,
    required this.content,
    this.createdAt,
    this.category = 'Pribadi',
    this.color = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'created_at': createdAt,
      'category': category,
      'color': color,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as int?,
      title: map['title'] as String,
      content: map['content'] as String,
      createdAt: map['created_at'] as String?,
      category: (map['category'] as String?) ?? 'Pribadi',
      color: (map['color'] as int?) ?? 0,
    );
  }
}
