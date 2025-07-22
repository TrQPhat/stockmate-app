import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:stock_mate/core/theme/app_theme.dart';
import 'package:stock_mate/models/waste_stats.dart';

class WastePieChartPainter extends CustomPainter {
  final List<CategoryWasteDetail> data;
  final List<Color> colors;

  WastePieChartPainter({required this.data, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 10;
    final total = data.fold<int>(0, (sum, item) => sum + item.wasted);
    if (total == 0) return;

    double startAngle = -math.pi / 2;

    for (int i = 0; i < data.length; i++) {
      final item = data[i];
      if (item.wasted == 0) continue;

      final sweepAngle = (item.wasted / total) * 2 * math.pi;
      final color = colors[i % colors.length];

      final paint = Paint()..color = color..style = PaintingStyle.fill;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle, sweepAngle, true, paint,
      );

      final borderPaint = Paint()
        ..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle, sweepAngle, true, borderPaint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class WastePieChartWidget extends StatelessWidget {
  final List<CategoryWasteDetail> data;
  final double height;

  const WastePieChartWidget({
    super.key,
    required this.data,
    this.height = 220,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty || data.every((d) => d.wasted == 0)) {
      return _buildEmptyChart();
    }

    final chartData = data.where((detail) => detail.wasted > 0).take(8).toList();
    chartData.sort((a, b) => b.wasted.compareTo(a.wasted));

    return Container(
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1, blurRadius: 8, offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: AspectRatio(
              aspectRatio: 1,
              child: CustomPaint(
                painter: WastePieChartPainter(data: chartData, colors: _getColors()),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(flex: 3, child: _buildLegend(chartData)),
        ],
      ),
    );
  }

  List<Color> _getColors() => [
    AppTheme.errorRed, AppTheme.warningOrange, AppTheme.primaryGreen,
    Colors.blue.shade600, Colors.purple.shade600, Colors.teal.shade600,
    Colors.indigo.shade600, Colors.pink.shade600,
  ];

  Widget _buildLegend(List<CategoryWasteDetail> chartData) {
    final colors = _getColors();
    final total = chartData.fold<int>(0, (sum, item) => sum + item.wasted);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Danh mục lãng phí', 
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: chartData.asMap().entries.map((entry) {
                final index = entry.key;
                final detail = entry.value;
                final color = colors[index % colors.length];
                final percentage = total > 0 ? (detail.wasted / total * 100) : 0.0;

                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Container(
                        width: 12, height: 12,
                        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(detail.categoryName, 
                        style: const TextStyle(fontSize: 11), overflow: TextOverflow.ellipsis)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${detail.wasted}', 
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          Text('${percentage.toStringAsFixed(1)}%', 
                            style: TextStyle(fontSize: 9, color: Colors.grey.shade600)),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyChart() {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pie_chart_outline, size: 32, color: AppTheme.primaryGreen),
            const SizedBox(height: 12),
            Text('Chưa có dữ liệu biểu đồ', 
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}