class Dish {
  final int? id;
  final String name;
  final String description;
  final String instructions;
  final String? imageUrl;
  final int cookTimeMinutes;
  final int storageId;
  final bool isAISuggested;
  bool isFavorited;

  Dish({
    this.id,
    required this.name,
    required this.description,
    required this.instructions,
    this.imageUrl,
    required this.cookTimeMinutes,
    this.storageId = 19,
    this.isAISuggested = false,
    this.isFavorited = false,
  });

  factory Dish.fromJson(Map<String, dynamic> json) {
    return Dish(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      instructions: json['instructions'] ?? '',
      imageUrl: json['image_url'] ?? '',
      cookTimeMinutes: int.tryParse(json['cook_time_minutes'].toString()) ?? 0,
      storageId: int.tryParse(json['storage_id'].toString()) ?? 0,
      isAISuggested: json['is_ai_suggested'] as bool? ?? false,
      isFavorited: json['is_favorited'] as bool? ?? false,
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
    };
  }

  Dish copyWith({
    int? id,
    String? name,
    String? description,
    String? instructions,
    String? imageUrl,
    int? cookTimeMinutes,
    int? storageId,
    bool? isAISuggested,
    bool? isFavorited,
  }) {
    return Dish(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      instructions: instructions ?? this.instructions,
      imageUrl: imageUrl ?? this.imageUrl,
      cookTimeMinutes: cookTimeMinutes ?? this.cookTimeMinutes,
      storageId: storageId ?? this.storageId,
      isAISuggested: isAISuggested ?? this.isAISuggested,
      isFavorited: isFavorited ?? this.isFavorited,
    );
  }
}
