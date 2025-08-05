class Position {
  final int id;
  final String name;
  final String? description;
  final int? storageId;

  Position({
    required this.id,
    required this.name,
    this.description,
    this.storageId,
  });

  // Factory constructor để tạo từ JSON
  factory Position.fromJson(Map<String, dynamic> json) {
    return Position(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      storageId: json['storage_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'storage_id': storageId,
    };
  }

  Position copyWith({
    int? id,
    String? name,
    String? description,
    int? storageId,
  }) {
    return Position(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      storageId: storageId ?? this.storageId,
    );
  }
}
