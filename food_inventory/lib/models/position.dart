class Position {
  final int id;
  final String name;
  final String? description;

  Position({
    required this.id,
    required this.name,
    this.description,
  });

  // Factory constructor để tạo từ JSON
  factory Position.fromJson(Map<String, dynamic> json) {
    return Position(
      id: json['id'],
      name: json['name'],
      description: json['description'],
    );
  }

  // Chuyển đối tượng thành JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }

  // Clone with
  Position copyWith({
    int? id,
    String? name,
    String? description,
  }) {
    return Position(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }
}
