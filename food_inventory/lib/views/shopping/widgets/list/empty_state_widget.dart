import 'package:flutter/material.dart';
import 'package:stock_mate/core/theme/app_theme.dart';

class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.primaryOrange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_cart_outlined,
                size: 60,
                color: AppTheme.primaryOrange,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '🛒 Chưa có danh sách nào',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Hãy tạo danh sách thực phẩm đầu tiên của bạn!\nBắt đầu lên kế hoạch cho bữa ăn ngon.',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _buildSuggestionCards(),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionCards() {
    return Column(
      children: [
        const Text(
          'Gợi ý danh sách:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildSuggestionChip('🥗 Salad tươi', AppTheme.primaryGreen),
            _buildSuggestionChip('🍝 Pasta Ý', AppTheme.primaryOrange),
            _buildSuggestionChip('🍲 Lẩu gia đình', AppTheme.errorRed),
            _buildSuggestionChip('🥘 Cơm tối', AppTheme.accentYellow),
          ],
        ),
      ],
    );
  }

  Widget _buildSuggestionChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
