class HomeStats {
  final int totalProducts;
  final int nearExpiry;
  final int expired;

  HomeStats({
    required this.totalProducts,
    required this.nearExpiry,
    required this.expired,
  });

  factory HomeStats.fromJson(Map<String, dynamic> json) {
    return HomeStats(
      totalProducts: json['totalProducts'] ?? 0,
      nearExpiry: json['nearExpiry'] ?? 0,
      expired: json['expired'] ?? 0,
    );
  }
}
