import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stock_mate/core/theme/app_theme.dart';
import 'dart:math' as math;

import 'package:stock_mate/views/statistics/widgets/waste_stats_tab.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  // Mock data
  final Map<String, int> wasteData = {
    'Rau củ': 15,
    'Trái cây': 8,
    'Thịt': 3,
    'Sữa': 5,
    'Ngũ cốc': 2,
    'Đồ ăn vặt': 7,
  };

  final Map<String, double> usageEfficiency = {
    'Rau củ': 85.5,
    'Trái cây': 92.3,
    'Thịt': 78.9,
    'Sữa': 88.7,
    'Ngũ cốc': 95.2,
    'Đồ ăn vặt': 73.4,
  };

  final List<Map<String, dynamic>> topUsedIngredients = [
    {'name': 'Gạo', 'category': 'grains', 'count': 45, 'percentage': 18.2},
    {'name': 'Thịt gà', 'category': 'meat', 'count': 38, 'percentage': 15.4},
    {
      'name': 'Cà chua',
      'category': 'vegetables',
      'count': 32,
      'percentage': 13.0
    },
    {'name': 'Sữa tươi', 'category': 'dairy', 'count': 28, 'percentage': 11.3},
    {'name': 'Chuối', 'category': 'fruits', 'count': 25, 'percentage': 10.1},
  ];

  final List<Map<String, dynamic>> weeklyAdditions = [
    {'day': 'T2', 'count': 12},
    {'day': 'T3', 'count': 8},
    {'day': 'T4', 'count': 15},
    {'day': 'T5', 'count': 10},
    {'day': 'T6', 'count': 18},
    {'day': 'T7', 'count': 22},
    {'day': 'CN', 'count': 25},
  ];

  final List<Map<String, dynamic>> alerts = [
    {
      'type': 'expiry',
      'title': 'Sắp hết hạn',
      'items': ['Sữa tươi (2 ngày)', 'Thịt bò (1 ngày)', 'Cà chua (3 ngày)'],
      'count': 3,
    },
    {
      'type': 'low_stock',
      'title': 'Tồn kho thấp',
      'items': ['Gạo (< 1kg)', 'Dầu ăn (< 500ml)', 'Muối (< 200g)'],
      'count': 3,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppTheme.primaryGreen,
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.analytics,
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Thống kê thực phẩm',
                            style: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Phân tích chi tiết việc sử dụng thực phẩm',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: AppTheme.accentGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Tab Bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: AppTheme.primaryGreen,
              unselectedLabelColor: AppTheme.textSecondary,
              indicatorColor: AppTheme.primaryGreen,
              labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
              tabs: const [
                Tab(text: '🟥 Lãng phí'),
                Tab(text: '🟩 Hiệu suất'),
                Tab(text: '🟨 Tần suất'),
                Tab(text: '🟦 Cảnh báo'),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                const WasteStatsTab(),
                _buildEfficiencyTab(),
                _buildFrequencyTab(),
                _buildAlertsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildWasteTab() {
  //   final totalWaste = wasteData.values.reduce((a, b) => a + b);
  //   const wastePercentage = 23.5; // Mock percentage

  //   return SingleChildScrollView(
  //     padding: const EdgeInsets.all(16),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         // Summary Cards
  //         Row(
  //           children: [
  //             Expanded(
  //               child: _buildStatCard(
  //                 title: 'Tổng lãng phí',
  //                 value: '$totalWaste',
  //                 subtitle: 'nguyên liệu',
  //                 color: AppTheme.errorRed,
  //                 icon: Icons.delete_outline,
  //               ),
  //             ),
  //             const SizedBox(width: 12),
  //             Expanded(
  //               child: _buildStatCard(
  //                 title: 'Tỉ lệ lãng phí',
  //                 value: '${wastePercentage.toStringAsFixed(1)}%',
  //                 subtitle: 'tổng nguyên liệu',
  //                 color: AppTheme.warningOrange,
  //                 icon: Icons.pie_chart,
  //               ),
  //             ),
  //           ],
  //         ),
  //         const SizedBox(height: 20),

  //         // Waste by Category Chart
  //         _buildSectionTitle('Lãng phí theo danh mục'),
  //         const SizedBox(height: 12),
  //         _buildWastePieChart(),
  //         const SizedBox(height: 20),

  //         // Waste List
  //         _buildSectionTitle('Chi tiết lãng phí'),
  //         const SizedBox(height: 12),
  //         ...wasteData.entries
  //             .map((entry) => _buildWasteItem(entry.key, entry.value)),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildEfficiencyTab() {
    final totalUsed = 247; // Mock data
    final averageEfficiency =
        usageEfficiency.values.reduce((a, b) => a + b) / usageEfficiency.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Tổng đã sử dụng',
                  value: '$totalUsed',
                  subtitle: 'nguyên liệu',
                  color: AppTheme.successGreen,
                  icon: Icons.check_circle_outline,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: 'Hiệu suất TB',
                  value: '${averageEfficiency.toStringAsFixed(1)}%',
                  subtitle: 'sử dụng hiệu quả',
                  color: AppTheme.primaryGreen,
                  icon: Icons.trending_up,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Efficiency Bar Chart
          _buildSectionTitle('Hiệu suất theo danh mục'),
          const SizedBox(height: 12),
          _buildEfficiencyBarChart(),
          const SizedBox(height: 20),

          // Top Used Ingredients
          _buildSectionTitle('Nguyên liệu dùng nhiều nhất'),
          const SizedBox(height: 12),
          ...topUsedIngredients.map((item) => _buildTopUsedItem(item)),
        ],
      ),
    );
  }

  Widget _buildFrequencyTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Weekly Additions Chart
          _buildSectionTitle('Tần suất thêm nguyên liệu (tuần)'),
          const SizedBox(height: 12),
          _buildWeeklyChart(),
          const SizedBox(height: 20),

          // Usage Heatmap
          _buildSectionTitle('Lịch sử sử dụng (heatmap)'),
          const SizedBox(height: 12),
          _buildUsageHeatmap(),
          const SizedBox(height: 20),

          // Statistics
          _buildSectionTitle('Thống kê tần suất'),
          const SizedBox(height: 12),
          _buildFrequencyStats(),
        ],
      ),
    );
  }

  Widget _buildAlertsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...alerts.map((alert) => _buildAlertCard(alert)),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: AppTheme.shadowColor,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: AppTheme.textLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppTheme.textPrimary,
      ),
    );
  }

  Widget _buildWastePieChart() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: AppTheme.shadowColor,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Pie Chart (simplified representation)
          Expanded(
            flex: 2,
            child: CustomPaint(
              painter: PieChartPainter(wasteData),
              child: const SizedBox(height: 150, width: 150),
            ),
          ),
          // Legend
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: wasteData.entries.map((entry) {
                final color =
                    AppTheme.categoryColors[_getCategoryKey(entry.key)] ??
                        Colors.grey;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${entry.key}: ${entry.value}',
                          style: GoogleFonts.inter(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWasteItem(String category, int count) {
    final color =
        AppTheme.categoryColors[_getCategoryKey(category)] ?? Colors.grey;
    final icon =
        AppTheme.categoryIcons[_getCategoryKey(category)] ?? Icons.help;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              category,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.errorRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.errorRed,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEfficiencyBarChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: AppTheme.shadowColor,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: usageEfficiency.entries.map((entry) {
          final color = AppTheme.categoryColors[_getCategoryKey(entry.key)] ??
              Colors.grey;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.key,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${entry.value.toStringAsFixed(1)}%',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: entry.value / 100,
                  backgroundColor: color.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTopUsedItem(Map<String, dynamic> item) {
    final color = AppTheme.categoryColors[item['category']] ?? Colors.grey;
    final icon = AppTheme.categoryIcons[item['category']] ?? Icons.help;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'],
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  '${item['count']} lần sử dụng',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${item['percentage']}%',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart() {
    final maxCount =
        weeklyAdditions.map((e) => e['count'] as int).reduce(math.max);

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: AppTheme.shadowColor,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: weeklyAdditions.map((data) {
                final height = (data['count'] as int) / maxCount * 120;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 24,
                      height: height,
                      decoration: BoxDecoration(
                        color: AppTheme.accentYellow,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data['day'],
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageHeatmap() {
    return Container(
      height: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: AppTheme.shadowColor,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Heatmap sử dụng (7 ngày qua)',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: 35,
              itemBuilder: (context, index) {
                final intensity = math.Random().nextDouble();
                return Container(
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withOpacity(intensity),
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFrequencyStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: AppTheme.shadowColor,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildFrequencyStatItem(
              'Trung bình thêm mới/ngày', '12.3', 'nguyên liệu'),
          const Divider(),
          _buildFrequencyStatItem(
              'Trung bình sử dụng/ngày', '8.7', 'nguyên liệu'),
          const Divider(),
          _buildFrequencyStatItem(
              'Ngày hoạt động cao nhất', 'Chủ nhật', '25 nguyên liệu'),
        ],
      ),
    );
  }

  Widget _buildFrequencyStatItem(String title, String value, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppTheme.textPrimary,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryGreen,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(Map<String, dynamic> alert) {
    final isExpiry = alert['type'] == 'expiry';
    final color = isExpiry ? AppTheme.errorRed : AppTheme.warningOrange;
    final icon = isExpiry ? Icons.schedule : Icons.inventory_2;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: const [
          BoxShadow(
            color: AppTheme.shadowColor,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  alert['title'],
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${alert['count']}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...((alert['items'] as List<String>).map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ))),
        ],
      ),
    );
  }

  String _getCategoryKey(String categoryName) {
    switch (categoryName) {
      case 'Rau củ':
        return 'vegetables';
      case 'Trái cây':
        return 'fruits';
      case 'Thịt':
        return 'meat';
      case 'Sữa':
        return 'dairy';
      case 'Ngũ cốc':
        return 'grains';
      case 'Đồ ăn vặt':
        return 'snacks';
      default:
        return 'vegetables';
    }
  }
}

class PieChartPainter extends CustomPainter {
  final Map<String, int> data;

  PieChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 10;
    final total = data.values.reduce((a, b) => a + b);

    double startAngle = -math.pi / 2;

    data.entries.forEach((entry) {
      final sweepAngle = (entry.value / total) * 2 * math.pi;
      final color =
          AppTheme.categoryColors[_getCategoryKeyFromName(entry.key)] ??
              Colors.grey;

      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      startAngle += sweepAngle;
    });
  }

  String _getCategoryKeyFromName(String categoryName) {
    switch (categoryName) {
      case 'Rau củ':
        return 'vegetables';
      case 'Trái cây':
        return 'fruits';
      case 'Thịt':
        return 'meat';
      case 'Sữa':
        return 'dairy';
      case 'Ngũ cốc':
        return 'grains';
      case 'Đồ ăn vặt':
        return 'snacks';
      default:
        return 'vegetables';
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
