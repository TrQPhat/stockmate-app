class RecipeIngredient {
  final String id;
  final String dishId;
  final String productId;
  final String productName;
  final double quantity;
  final String unit;

  RecipeIngredient({
    required this.id,
    required this.dishId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unit,
  });

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) {
    return RecipeIngredient(
      id: json['id'] ?? '',
      dishId: json['dish_id'] ?? '',
      productId: json['product_id'] ?? '',
      productName: json['Ingredient']?['name'] ?? 'Chưa rõ',
      quantity: double.tryParse(json['quantity'].toString()) ?? 0.0,
      unit: json['unit'] ?? '',
    );
  }
}
