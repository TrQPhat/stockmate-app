class Storage {
  final int id;
  final String name;
  final int ownerId; // 👈 Đổi từ String sang int
  final String key;
  final DateTime createdAt;

  const Storage({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.key,
    required this.createdAt,
  });

  factory Storage.fromJson(Map<String, dynamic> json) {
    return Storage(
      id: json['id'] ?? -1,
      name: json['name'] ?? '',
      ownerId: json['owner_id'] ?? -1, // 👈 vẫn là int
      key: json['key'] ?? '',
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'owner_id': ownerId,
      'key': key,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
