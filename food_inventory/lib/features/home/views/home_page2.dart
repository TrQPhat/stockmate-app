import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stock_mate/core/config/app_config.dart';
import 'package:stock_mate/core/di/injection_container.dart';
import 'package:stock_mate/features/storage/models/storage.dart';

import '../../../core/theme/app_theme.dart';
import '../../storage/bloc/storage_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? currentStorageId;

  @override
  void initState() {
    super.initState();
    // Kiểm tra storage hiện tại khi vào trang
    //context.read<StorageBloc>().add(CheckCurrentStorage());
    checkCurrentStorage();
  }

  void checkCurrentStorage() async {
    currentStorageId =
        getIt<SharedPreferences>().getString(AppConfig.currentStorageKey);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Mate'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // TODO: Handle notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              // TODO: Handle profile
            },
          ),
        ],
      ),
      body: currentStorageId != null ? _buildMainView() : _buildNoStorageView(),

      // Thêm floating action button
      floatingActionButton: currentStorageId != null
          ? _buildStorageOptionsButton()
          : const SizedBox.shrink(),
    );
  }

  Widget _buildNoStorageView() {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 120.w,
            height: 120.w,
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.storage,
              size: 60.w,
              color: AppTheme.primaryGreen,
            ),
          ),
          SizedBox(height: 32.h),

          // Title
          Text(
            'Chưa có kho nào',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryGreen,
            ),
          ),
          SizedBox(height: 12.h),

          // Description
          Text(
            'Bạn cần tạo mới hoặc tham gia một kho để bắt đầu quản lý nguyên liệu',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 48.h),

          // Create storage button
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: ElevatedButton.icon(
              onPressed: () => _showCreateStorageDialog(),
              icon: const Icon(Icons.add),
              label: Text(
                'Tạo kho mới',
                style: TextStyle(fontSize: 16.sp),
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // Join storage button
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: OutlinedButton.icon(
              onPressed: () => _showJoinStorageDialog(),
              icon: const Icon(Icons.group_add),
              label: Text(
                'Tham gia kho',
                style: TextStyle(fontSize: 16.sp),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryGreen,
                side: const BorderSide(color: AppTheme.primaryGreen),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainView() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current storage info
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primaryGreen, AppTheme.lightGreen],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kho hiện tại',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            "storage.name",
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => context.go('/storage'),
                      icon: const Icon(
                        Icons.settings,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  'Quản lý nguyên liệu một cách hiệu quả',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),

          // Quick stats
          Text(
            'Thống kê nhanh',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.inventory,
                  title: 'Tổng sản phẩm',
                  value: '156',
                  color: AppTheme.primaryGreen,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.warning,
                  title: 'Sắp hết hạn',
                  value: '12',
                  color: AppTheme.warningColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),

          // Quick actions
          Text(
            'Thao tác nhanh',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12.h),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              children: [
                _buildActionCard(
                  icon: Icons.add_box,
                  title: 'Thêm sản phẩm',
                  onTap: () => context.go('/products'),
                ),
                _buildActionCard(
                  icon: Icons.shopping_cart,
                  title: 'Danh sách mua sắm',
                  onTap: () => context.go('/shopping'),
                ),
                _buildActionCard(
                  icon: Icons.storage,
                  title: 'Quản lý kho',
                  onTap: () => context.go('/storage'),
                ),
                _buildActionCard(
                  icon: Icons.analytics,
                  title: 'Thống kê',
                  onTap: () => context.go('/statistics'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24.w),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48.w,
              color: AppTheme.primaryGreen,
            ),
            SizedBox(height: 12.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateStorageDialog() {
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
          // ElevatedButton(
          //       onPressed: state is StorageLoading
          //           ? null
          //           : () {
          //               // if (nameController.text.trim().isNotEmpty) {
          //               //   context.read<StorageBloc>().add(
          //               //         CreateStorage(nameController.text.trim()),
          //               //       );
          //               //   Navigator.pop(context);
          //               // }
          //             },
          //       child: state is StorageLoading
          //           ? const SizedBox(
          //               width: 16,
          //               height: 16,
          //               child: CircularProgressIndicator(strokeWidth: 2),
          //             )
          //           : const Text('Tạo'),
          //     );
        ],
      ),
    );
  }

  void _showJoinStorageDialog() {
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
          // BlocBuilder<StorageBloc, StorageState>(
          //   builder: (context, state) {
          //     return ElevatedButton(
          //       onPressed: state is StorageLoading
          //           ? null
          //           : () {
          //               // if (codeController.text.trim().isNotEmpty) {
          //               //   context.read<StorageBloc>().add(
          //               //         JoinStorage(codeController.text.trim()),
          //               //       );
          //               //   Navigator.pop(context);
          //               // }
          //             },
          //       child: state is StorageLoading
          //           ? const SizedBox(
          //               width: 16,
          //               height: 16,
          //               child: CircularProgressIndicator(strokeWidth: 2),
          //             )
          //           : const Text('Tham gia'),
          //     );
          //   },
          // ),
        ],
      ),
    );
  }

  Widget _buildStorageOptionsButton() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Tạo kho mới
        FloatingActionButton.extended(
          onPressed: () => _showCreateStorageDialog(),
          heroTag: "create_storage",
          backgroundColor: AppTheme.primaryGreen,
          icon: const Icon(Icons.add, color: Colors.white),
          label: Text(
            'Tạo kho mới',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(height: 12.h),

        // Tham gia kho
        FloatingActionButton.extended(
          onPressed: () => _showJoinStorageDialog(),
          heroTag: "join_storage",
          backgroundColor: AppTheme.lightGreen,
          icon: const Icon(Icons.group_add, color: Colors.white),
          label: Text(
            'Tham gia kho',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
