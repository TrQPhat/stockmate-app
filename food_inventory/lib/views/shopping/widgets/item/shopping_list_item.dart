import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stock_mate/core/theme/app_theme.dart';
import 'package:stock_mate/models/shopping_list.dart';

class ShoppingListItem extends StatelessWidget {
  final ShoppingList shoppingList;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onComplete;

  const ShoppingListItem({
    super.key,
    required this.shoppingList,
    required this.onTap,
    required this.onDelete,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(shoppingList.id.toString()),
      direction: DismissDirection.endToStart,
      background: _buildSwipeBackground(),
      confirmDismiss: (direction) => _showDeleteConfirmation(context),
      onDismissed: (direction) => onDelete(),
      child: _buildCard(context),
    );
  }

  Widget _buildCard(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: AppTheme.cardShadow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildLeadingIcon(),
              const SizedBox(width: 16),
              Expanded(child: _buildContent()),
              _buildTrailingIcon(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeadingIcon() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppTheme.lightGreen.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: onComplete,
        icon: const Icon(
          Icons.shopping_cart,
          color: AppTheme.primaryOrange,
          size: 35,
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          shoppingList.name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: AppTheme.primaryGreen,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        if (shoppingList.purpose.isNotEmpty) ...[
          Text(
            shoppingList.purpose,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
        ],
        _buildDateInfo(),
      ],
    );
  }

  Widget _buildDateInfo() {
    return Row(
      children: [
        const Icon(
          Icons.schedule,
          size: 16,
          color: AppTheme.textLight,
        ),
        const SizedBox(width: 4),
        Text(
          shoppingList.purchaseDate != null
              ? DateFormat('dd/MM/yyyy').format(shoppingList.purchaseDate!)
              : 'Chưa đặt ngày',
          style: TextStyle(
            color: shoppingList.purchaseDate != null
                ? AppTheme.textSecondary
                : AppTheme.textLight,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTrailingIcon() {
    return const Icon(
      Icons.chevron_right,
      color: AppTheme.textLight,
      size: 24,
    );
  }

  Widget _buildSwipeBackground() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.errorRed,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 24),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.delete_outline, color: Colors.white, size: 28),
          SizedBox(height: 4),
          Text(
            'Xóa',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppTheme.warningOrange),
            SizedBox(width: 8),
            Text('Xác nhận xóa'),
          ],
        ),
        content: Text('Bạn chắc chắn muốn xóa "${shoppingList.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy',
                style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}
