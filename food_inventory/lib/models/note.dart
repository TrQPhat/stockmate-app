class Note {
  final String id;
  final String dishId;
  final String content;
  final int quantity;
  final String author;
  final DateTime createdAt;

  Note({
    required this.id,
    required this.dishId,
    required this.content,
    required this.quantity,
    required this.author,
    required this.createdAt,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'].toString(),
      dishId: json['dish_id'].toString(),
      content: json['content'] ?? '',
      quantity: json['quantity']?.toInt() ?? 1,
      author: json['author'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dish_id': dishId,
      'content': content,
      'quantity': quantity,
      'author': author,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
