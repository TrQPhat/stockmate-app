class Note {
  final int id;
  final int dishId;
  final String content;
  final int userId;
  final String author;
  final DateTime createdAt;

  Note({
    required this.id,
    required this.dishId,
    required this.content,
    required this.userId,
    required this.author,
    required this.createdAt,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      dishId: json['dish_id'],
      content: json['content'] ?? '',
      userId: json['user_id'],
      author: json['author'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dish_id': dishId,
      'content': content,
      'user_id': userId,
      'author': author,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
