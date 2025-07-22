import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stock_mate/bloc/waste_stats/waste_stats_bloc.dart';
import 'package:stock_mate/bloc/waste_stats/waste_stats_event.dart';
import 'package:stock_mate/bloc/waste_stats/waste_stats_state.dart';
import 'package:stock_mate/core/theme/app_theme.dart';
import 'package:stock_mate/models/waste_stats.dart';
import 'package:stock_mate/core/di/injection_container.dart';
import './waste_pie_chart_widget.dart';

class WasteStatsTab extends StatefulWidget {
  const WasteStatsTab({super.key});

  @override
  State<WasteStatsTab> createState() => _WasteStatsTabState();
}

class _WasteStatsTabState extends State<WasteStatsTab>
    with AutomaticKeepAliveClientMixin {
  late final WasteStatsBloc _wasteStatsBloc;

  @override
  bool get wantKeepAlive => true; // Giữ state khi chuyển tab

  @override
  void initState() {
    super.initState();
    _wasteStatsBloc = getIt<WasteStatsBloc>();
    // Tự động load dữ liệu lần đầu
    _wasteStatsBloc.add(LoadWasteStats());
  }

  @override
  void dispose() {
    _wasteStatsBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return BlocProvider.value(
      value: _wasteStatsBloc,
      child: BlocConsumer<WasteStatsBloc, WasteStatsState>(
        listener: (context, state) {
          if (state is WasteStatsError) {
            _showErrorSnackbar(context, state.message);
          }
        },
        builder: (context, state) {
          return _buildContent(context, state);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, WasteStatsState state) {
    if (state is WasteStatsLoading) {
      return _buildLoadingState();
    }

    if (state is WasteStatsError) {
      return _buildErrorState(context, state.message);
    }

    if (state is WasteStatsLoaded) {
      return _buildLoadedState(context, state.stats);
    }

    // Initial state
    return _buildLoadingState();
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
          ),
          SizedBox(height: 16),
          Text(
            'Đang tải thống kê lãng phí...',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.errorRed.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 48,
                color: AppTheme.errorRed,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Không thể tải dữ liệu',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _refreshData(),
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadedState(BuildContext context, WasteStats stats) {
    return RefreshIndicator(
      onRefresh: _refreshData,
      color: AppTheme.primaryGreen,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Cards
            _buildSummaryCards(stats),
            const SizedBox(height: 20),

            // Total Summary Card
            _buildTotalSummaryCard(stats),
            const SizedBox(height: 20),

            // Waste by Category Chart
            _buildSectionTitle('Lãng phí theo danh mục'),
            const SizedBox(height: 12),
            _buildWastePieChart(stats.detailByCategory),
            const SizedBox(height: 20),

            // Waste List
            _buildSectionTitle('Chi tiết lãng phí'),
            const SizedBox(height: 12),
            _buildWasteList(stats.detailByCategory),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(WasteStats stats) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Tổng lãng phí',
            value: '${stats.totalWaste}',
            subtitle: 'nguyên liệu',
            color: AppTheme.errorRed,
            icon: Icons.delete_outline,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'Tỉ lệ lãng phí',
            value: '${stats.wasteRate.toStringAsFixed(1)}%',
            subtitle: 'tổng nguyên liệu',
            color: AppTheme.warningOrange,
            icon: Icons.pie_chart,
          ),
        ),
      ],
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
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
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 10,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalSummaryCard(WasteStats stats) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryGreen.withOpacity(0.1),
            AppTheme.primaryGreen.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryGreen.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              color: AppTheme.primaryGreen,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tổng nguyên liệu',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${stats.total}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          _buildWasteRateBadge(stats.wasteRate),
        ],
      ),
    );
  }

  Widget _buildWasteRateBadge(double wasteRate) {
    Color badgeColor;
    if (wasteRate > 20) {
      badgeColor = AppTheme.errorRed;
    } else if (wasteRate > 10) {
      badgeColor = AppTheme.warningOrange;
    } else {
      badgeColor = AppTheme.primaryGreen;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '${wasteRate.toStringAsFixed(1)}%',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: badgeColor,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppTheme.textPrimary,
      ),
    );
  }

  // Widget _buildWastePieChart(List<CategoryWasteDetail> details) {
  //   if (details.isEmpty || details.every((d) => d.wasted == 0)) {
  //     return _buildEmptyChart();
  //   }

  //   final chartData = details
  //       .where((detail) => detail.wasted > 0)
  //       .take(5) // Chỉ hiển thị top 5
  //       .toList();

  //   return Container(
  //     height: 200,
  //     padding: const EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(12),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.grey.withOpacity(0.1),
  //           spreadRadius: 1,
  //           blurRadius: 4,
  //           offset: const Offset(0, 2),
  //         ),
  //       ],
  //     ),
  //     child: Row(
  //       children: [
  //         // Pie chart placeholder
  //         Expanded(
  //           flex: 2,
  //           child: Container(
  //             decoration: BoxDecoration(
  //               color: Colors.grey.shade100,
  //               shape: BoxShape.circle,
  //             ),
  //             child: Center(
  //               child: Column(
  //                 mainAxisAlignment: MainAxisAlignment.center,
  //                 children: [
  //                   const Icon(
  //                     Icons.pie_chart,
  //                     size: 32,
  //                     color: AppTheme.primaryGreen,
  //                   ),
  //                   const SizedBox(height: 4),
  //                   Text(
  //                     'Biểu đồ',
  //                     style: TextStyle(
  //                       color: Colors.grey.shade600,
  //                       fontSize: 12,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //         ),
  //         const SizedBox(width: 16),
  //         // Legend
  //         Expanded(
  //           flex: 3,
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: _buildChartLegend(chartData),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  Widget _buildWastePieChart(List<CategoryWasteDetail> details) {
    return WastePieChartWidget(
      data: details,
      height: 220,
    );
  }

  List<Widget> _buildChartLegend(List<CategoryWasteDetail> chartData) {
    final colors = [
      AppTheme.errorRed,
      AppTheme.warningOrange,
      AppTheme.primaryGreen,
      Colors.blue,
      Colors.purple,
    ];

    return chartData.asMap().entries.map((entry) {
      final index = entry.key;
      final detail = entry.value;
      final color = colors[index % colors.length];

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
                detail.categoryName,
                style: const TextStyle(fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '${detail.wasted}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildEmptyChart() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pie_chart_outline,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 8),
            Text(
              'Chưa có dữ liệu biểu đồ',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWasteList(List<CategoryWasteDetail> details) {
    if (details.isEmpty) {
      return _buildEmptyWasteState();
    }

    return Column(
      children: details.map((detail) => _buildWasteItem(detail)).toList(),
    );
  }

  Widget _buildWasteItem(CategoryWasteDetail detail) {
    final wastePercentage = detail.wasteRate;
    final statusData = _getWasteStatus(wastePercentage);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusData['color'].withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              statusData['icon'],
              color: statusData['color'],
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detail.categoryName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tổng: ${detail.total} • Lãng phí: ${detail.wasted}',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${wastePercentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: statusData['color'],
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusData['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${detail.wasted}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: statusData['color'],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getWasteStatus(double wastePercentage) {
    if (wastePercentage > 20) {
      return {
        'color': AppTheme.errorRed,
        'icon': Icons.trending_up,
      };
    } else if (wastePercentage > 10) {
      return {
        'color': AppTheme.warningOrange,
        'icon': Icons.trending_flat,
      };
    } else {
      return {
        'color': AppTheme.primaryGreen,
        'icon': Icons.trending_down,
      };
    }
  }

  Widget _buildEmptyWasteState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: const Center(
        child: Column(
          children: [
            Icon(
              Icons.eco_outlined,
              size: 48,
              color: AppTheme.primaryGreen,
            ),
            SizedBox(height: 16),
            Text(
              'Không có lãng phí!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Tuyệt vời! Bạn đang quản lý nguyên liệu rất hiệu quả.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshData() async {
    _wasteStatsBloc.add(LoadWasteStats());
    // Đợi một chút để animation refresh hoàn thành
    await Future.delayed(const Duration(milliseconds: 500));
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text('Lỗi: $message')),
          ],
        ),
        backgroundColor: AppTheme.errorRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
