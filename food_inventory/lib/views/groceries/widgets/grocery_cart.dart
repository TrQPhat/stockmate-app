import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stock_mate/bloc/grocery/groceries_bloc.dart';
import 'package:stock_mate/core/config/app_config.dart';
import 'package:stock_mate/models/grocery.dart';
// ignore: implementation_imports
import 'package:flutter_screenutil/src/size_extension.dart';
import 'package:stock_mate/views/groceries/views/input_grocery_page.dart';

class GroceryCard extends StatelessWidget {
  final Grocery grocery;

  const GroceryCard({
    super.key,
    required this.grocery,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
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
          // Grocery image
          Container(
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: grocery.imagePath != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: Image.network(
                      "${AppConfig.rootImagePath}/${grocery.imagePath!}",
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.image,
                          color: Colors.grey[400],
                          size: 30.w,
                        );
                      },
                    ),
                  )
                : Icon(
                    Icons.image,
                    color: Colors.grey[400],
                    size: 30.w,
                  ),
          ),
          SizedBox(width: 12.w),

          // Grocery info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  grocery.name,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Số lượng: ${grocery.quantity} ${grocery.unit ?? ''}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
                if (grocery.expireDate != null) ...[
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14.w,
                        color: _getExpireColor(grocery.expireDate!),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'Hết hạn: ${_formatDate(grocery.expireDate!)}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: _getExpireColor(grocery.expireDate!),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Actions
          PopupMenuButton(
            icon: Icon(Icons.more_vert, size: 20.w),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Text('Chỉnh sửa'),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Text('Xóa'),
              ),
            ],
            onSelected: (value) {
              if (value == 'delete') {
                _showDeleteConfirmDialog(context, grocery);
              } else if (value == 'edit') {
                _showEditProductDialog(context, grocery);
              }
            },
          ),
        ],
      ),
    );
  }

  Color _getExpireColor(DateTime expireDate) {
    final now = DateTime.now();
    final difference = expireDate.difference(now).inDays;

    if (difference < 0) {
      return Colors.red; // Đã hết hạn
    } else if (difference <= 7) {
      return Colors.orange; // Sắp hết hạn
    } else {
      return Colors.green; // Còn hạn
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _showEditProductDialog(BuildContext context, Grocery grocery) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InputGroceryPage(
          grocery: grocery,
          isEdit: true,
        ),
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, Grocery grocery) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa sản phẩm "${grocery.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<GroceriesBloc>().add(DeleteGrocery(grocery.id));
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
