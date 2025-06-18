import './recipe_ingredient.dart';

class Recipe {
  final String id;
  final String name;
  final String? description;
  final String instructions;
  final String? imageUrl;
  final int? cookTimeMinutes;
  final int? servingSize;
  final String createdByUserId;
  // Giả sử API trả về thông tin người tạo
  final String? createdByUserName;
  final String? createdByUserAvatar;
  final List<RecipeIngredient>? ingredients;

  Recipe({
    required this.id,
    required this.name,
    this.description,
    required this.instructions,
    this.imageUrl,
    this.cookTimeMinutes,
    this.servingSize,
    required this.createdByUserId,
    this.createdByUserName,
    this.createdByUserAvatar,
    this.ingredients,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Không có tên',
      description: json['description'],
      instructions: json['instructions'] ?? '',
      imageUrl: json['image_url'],
      cookTimeMinutes: json['cook_time_minutes'],
      servingSize: json['serving_size'],
      createdByUserId: json['created_by_user_id'] ?? '',
      createdByUserName: json['User']?['full_name'],
      createdByUserAvatar: json['User']?['avatar_url'],
      ingredients: (json['recipe_ingredients'] as List<dynamic>?)
          ?.map((itemJson) => RecipeIngredient.fromJson(itemJson))
          .toList(),
    );
  }
}
