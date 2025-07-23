class WasteStats {
  final int total;
  final int totalWaste;
  final double wasteRate;
  final List<CategoryWasteDetail> detailByCategory;

  WasteStats({
    required this.total,
    required this.totalWaste,
    required this.wasteRate,
    required this.detailByCategory,
  });

  factory WasteStats.fromJson(Map<String, dynamic> json) {
    return WasteStats(
      total: json['total'],
      totalWaste: json['totalWaste'],
      wasteRate: json['wasteRate'].toDouble(),
      detailByCategory: (json['detailByCategory'] as List)
          .map((e) => CategoryWasteDetail.fromJson(e))
          .toList(),
    );
  }
}

class CategoryWasteDetail {
  final int categoryId;
  final String categoryName;
  final int total;
  final int wasted;
  final double wasteRate;

  CategoryWasteDetail({
    required this.categoryId,
    required this.categoryName,
    required this.total,
    required this.wasted,
    required this.wasteRate,
  });

  factory CategoryWasteDetail.fromJson(Map<String, dynamic> json) {
    return CategoryWasteDetail(
      //categoryId: json['category_id'] as int,
      categoryId: json['category_id'] ?? 0,
      categoryName: json['category_name'] as String,
      total: json['total'] as int,
      wasted: json['wasted'] as int,
      wasteRate: (json['wasteRate'] as num).toDouble(),
    );
  }
}
