class Dish {
  final String id;
  final String name;
  final String description;
  final String instructions;
  final String imageUrl;
  final int cookTimeMinutes;
  final int storageId;
  final bool isAISuggested;
  bool isFavorited;

  Dish({
    required this.id,
    required this.name,
    required this.description,
    required this.instructions,
    required this.imageUrl,
    required this.cookTimeMinutes,
    this.storageId = 19,
    this.isAISuggested = false,
    this.isFavorited = false,
  });

  factory Dish.fromJson(Map<String, dynamic> json) {
    return Dish(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      instructions: json['instructions'] ?? '',
      imageUrl: json['image_url'] ?? '',
      cookTimeMinutes: json['cook_time_minutes'] ?? 0,
      storageId: json['storage_id'] ?? 0,
      isAISuggested: json['is_ai_suggested'] ?? false,
      isFavorited: json['is_favorited'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'instructions': instructions,
      'image_url': imageUrl,
      'cook_time_minutes': cookTimeMinutes,
      'storage_id': storageId,
      'is_ai_suggested': isAISuggested,
      'is_favorited': isFavorited,
    };
  }
}
