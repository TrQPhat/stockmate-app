import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_theme.dart';

class ShoppingPage extends StatelessWidget {
  const ShoppingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách mua sắm'),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            onPressed: () {
              _showSuggestionDialog(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress indicator
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tiến độ mua sắm',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        LinearProgressIndicator(
                          value: 0.6,
                          backgroundColor: Colors.grey[300],
                          valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '6/10 mục đã mua',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '60%',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            
            // Shopping list
            Text(
              'Danh sách mua sắm',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12.h),
            Expanded(
              child: ListView.builder(
                itemCount: 10, // Mock data
                itemBuilder: (context, index) {
                  return _buildShoppingItem(index);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddItemDialog(context);
        },
        backgroundColor: AppTheme.primaryGreen,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildShoppingItem(int index) {
    final isPurchased = index < 6; // Mock purchased items
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
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
          // Checkbox
          Checkbox(
            value: isPurchased,
            onChanged: (value) {
              // TODO: Toggle purchase status
            },
            activeColor: AppTheme.primaryGreen,
          ),
          SizedBox(width: 12.w),
          
          // Item info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cà chua ${index + 1}',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    decoration: isPurchased ? TextDecoration.lineThrough : null,
                    color: isPurchased ? Colors.grey : null,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Số lượng: ${index + 1} kg',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                    decoration: isPurchased ? TextDecoration.lineThrough : null,
                  ),
                ),
              ],
            ),
          ),
          
          // Actions
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red, size: 20.w),
            onPressed: () {
              // TODO: Delete item
            },
          ),
        ],
      ),
    );
  }

  void _showAddItemDialog(BuildContext context) {
    final nameController = TextEditingController();
    final quantityController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm mục mua sắm'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Tên sản phẩm',
                hintText: 'Nhập tên sản phẩm...',
              ),
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: quantityController,
              decoration: const InputDecoration(
                labelText: 'Số lượng',
                hintText: 'Nhập số lượng...',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Add item
              Navigator.pop(context);
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }

  void _showSuggestionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đề xuất mua sắm'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dựa trên kho hiện tại, chúng tôi đề xuất:',
              style: TextStyle(fontSize: 14.sp),
            ),
            SizedBox(height: 12.h),
            _buildSuggestionItem('Cà chua', 'Sắp hết (còn 1 kg)'),
            _buildSuggestionItem('Thịt bò', 'Đã hết hạn'),
            _buildSuggestionItem('Gạo', 'Sắp hết (còn 2 kg)'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Add all suggestions
              Navigator.pop(context);
            },
            child: const Text('Thêm tất cả'),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionItem(String name, String reason) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Icon(Icons.lightbulb, color: AppTheme.warningColor, size: 16.w),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  reason,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
