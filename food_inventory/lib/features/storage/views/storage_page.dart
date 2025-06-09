import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_theme.dart';

class StoragePage extends StatelessWidget {
  const StoragePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý kho'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showCreateStorageDialog(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current storage
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
                border:
                    Border.all(color: AppTheme.primaryGreen.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.storage,
                        color: AppTheme.primaryGreen,
                        size: 24.w,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Kho hiện tại',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Kho gia đình',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '156 sản phẩm • 3 thành viên',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),

            // Storage list
            Text(
              'Danh sách kho',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12.h),
            Expanded(
              child: ListView.builder(
                itemCount: 5, // Mock data
                itemBuilder: (context, index) {
                  return _buildStorageCard(index);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showJoinStorageDialog(context);
        },
        backgroundColor: AppTheme.lightGreen,
        icon: const Icon(Icons.group_add, color: Colors.white),
        label: const Text(
          'Tham gia kho',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildStorageCard(int index) {
    final isOwner = index == 0;
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
          // Storage icon
          Container(
            width: 50.w,
            height: 50.w,
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              Icons.storage,
              color: AppTheme.primaryGreen,
              size: 24.w,
            ),
          ),
          SizedBox(width: 12.w),

          // Storage info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Kho ${index == 0 ? 'gia đình' : 'công ty ${index}'}',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (isOwner) ...[
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text(
                          'Chủ kho',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  '${(index + 1) * 50} sản phẩm • ${(index + 1) * 2} thành viên',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // Actions
          PopupMenuButton(
            icon: Icon(Icons.more_vert, size: 20.w),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'select',
                child: Text('Chọn kho này'),
              ),
              if (isOwner) ...[
                const PopupMenuItem(
                  value: 'manage',
                  child: Text('Quản lý thành viên'),
                ),
                const PopupMenuItem(
                  value: 'settings',
                  child: Text('Cài đặt kho'),
                ),
              ] else ...[
                const PopupMenuItem(
                  value: 'leave',
                  child: Text('Rời khỏi kho'),
                ),
              ],
            ],
            onSelected: (value) {
              // TODO: Handle actions
            },
          ),
        ],
      ),
    );
  }

  void _showCreateStorageDialog(BuildContext context) {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tạo kho mới'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Tên kho',
            hintText: 'Nhập tên kho...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Create storage
              Navigator.pop(context);
            },
            child: const Text('Tạo'),
          ),
        ],
      ),
    );
  }

  void _showJoinStorageDialog(BuildContext context) {
    final codeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tham gia kho'),
        content: TextField(
          controller: codeController,
          decoration: const InputDecoration(
            labelText: 'Mã kho',
            hintText: 'Nhập mã kho để tham gia...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Join storage
              Navigator.pop(context);
            },
            child: const Text('Tham gia'),
          ),
        ],
      ),
    );
  }
}
