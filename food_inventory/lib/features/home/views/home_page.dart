import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stock_mate/core/config/app_config.dart';
import 'package:stock_mate/core/di/injection_container.dart';
import 'package:stock_mate/features/auth/bloc/auth_bloc.dart';
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
  String? storageName =
      "Kho của tôi"; // Default name until we load the actual storage

  @override
  void initState() {
    super.initState();
    // Kiểm tra storage hiện tại khi vào trang
    checkCurrentStorage();
  }

  void checkCurrentStorage() async {
    final prefs = getIt<SharedPreferences>();
    setState(() {
      currentStorageId = prefs.getString(AppConfig.currentStorageKey);
    });
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
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle),
            onSelected: (value) {
              if (value == 'logout') {
                _showLogoutConfirmDialog(context);
              } else if (value == 'profile') {
                // TODO: Navigate to profile page
              } else if (value == 'settings') {
                // TODO: Navigate to settings page
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'profile',
                child: Row(
                  children: [
                    const Icon(Icons.person, color: AppTheme.primaryGreen),
                    SizedBox(width: 8.w),
                    const Text('Hồ sơ cá nhân'),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'settings',
                child: Row(
                  children: [
                    const Icon(Icons.settings, color: AppTheme.primaryGreen),
                    SizedBox(width: 8.w),
                    const Text('Cài đặt'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    const Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8.w),
                    const Text('Đăng xuất',
                        style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: currentStorageId == "" ? _buildNoStorageView() : _buildMainView(),

      // Thêm floating action button
      floatingActionButton: currentStorageId == ""
          ? FloatingActionButton(
              onPressed: () {
                // Hiển thị bottom sheet với 2 nút
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                  builder: (context) => Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(16.r)),
                    ),
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Create storage button
                        SizedBox(
                          width: double.infinity,
                          height: 48.h,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context); // Đóng bottom sheet
                              _showCreateStorageDialog();
                            },
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
                            onPressed: () {
                              Navigator.pop(context); // Đóng bottom sheet
                              _showJoinStorageDialog();
                            },
                            icon: const Icon(Icons.group_add),
                            label: Text(
                              'Tham gia kho',
                              style: TextStyle(fontSize: 16.sp),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.primaryGreen,
                              side: const BorderSide(
                                  color: AppTheme.primaryGreen),
                            ),
                          ),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).viewInsets.bottom),
                      ],
                    ),
                  ),
                );
              },
              backgroundColor: AppTheme.primaryGreen,
              child: const Icon(Icons.more_horiz),
            )
          : const SizedBox.shrink(),
    );
  }

  // Hiển thị dialog xác nhận đăng xuất
  void _showLogoutConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              // Gọi event đăng xuất
              context.read<AuthBloc>().add(LogoutRequested());

              // Điều hướng về trang login
              context.go('/login');
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
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
                            storageName ?? "Kho của tôi",
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
                      onPressed: () => context.push('/user'),
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
                  onTap: () => context.push('/products'),
                ),
                _buildActionCard(
                  icon: Icons.shopping_cart,
                  title: 'Danh sách mua sắm',
                  onTap: () => context.push('/shopping'),
                ),
                _buildActionCard(
                  icon: Icons.storage,
                  title: 'Quản lý kho',
                  onTap: () => context.push('/storage'),
                ),
                _buildActionCard(
                  icon: Icons.analytics,
                  title: 'Thống kê',
                  onTap: () => context.push('/statistics'),
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
          //   onPressed: () {
          //     if (nameController.text.trim().isNotEmpty) {
          //       setState(() {
          //         currentStorageId = 'temp_storage_id';
          //         storageName = nameController.text.trim();
          //       });
          //       Navigator.pop(context);
          //     }
          //   },
          //   child: const Text('Tạo'),
          // ),
          BlocListener<StorageBloc, StorageState>(
            listener: (context, state) {
              if (state is StorageSuccess) {
                setState(() {
                  currentStorageId = state.storageId;
                });

                Navigator.pop(context); // Đóng dialog sau khi tạo xong
              } else if (state is StorageError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
            child: ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isNotEmpty) {
                  context.read<StorageBloc>().add(StorageCreateRequested(name));
                }
              },
              child: const Text('Tạo'),
            ),
          )
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
          ElevatedButton(
            onPressed: () {
              if (codeController.text.trim().isNotEmpty) {
                // TODO: Implement storage joining
                // For now, just simulate storage joining
                final prefs = getIt<SharedPreferences>();
                prefs.setString(
                    AppConfig.currentStorageKey, 'joined_storage_id');
                setState(() {
                  currentStorageId = 'joined_storage_id';
                  storageName = 'Kho đã tham gia';
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Tham gia'),
          ),
        ],
      ),
    );
  }
}
