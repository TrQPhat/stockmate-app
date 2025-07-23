import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stock_mate/core/config/app_config.dart';
import 'package:stock_mate/core/di/injection_container.dart';
import 'package:stock_mate/bloc/auth/auth_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../bloc/storage/storage_bloc.dart';
import 'package:stock_mate/bloc/home/home_event.dart';
import 'package:stock_mate/bloc/home/home_bloc.dart';
import 'package:stock_mate/bloc/home/home_state.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int? currentStorageId;
  String? storageName = "Kho của tôi";

  @override
  void initState() {
    super.initState();
    // Kiểm tra storage hiện tại khi vào trang
    _loadStorageData();
    context.read<HomeBloc>().add(LoadHomeStats());
  }

  Future<void> _loadStorageData() async {
    try {
      final prefs = getIt<SharedPreferences>();

      final currentStorage = prefs.getInt(AppConfig.storageIdKey) ?? -1;
      final nameStorage = prefs.getString(AppConfig.nameStorageKey) ?? '';

      if (!mounted) return;

      setState(() {
        currentStorageId = currentStorage != -1 ? currentStorage : null;
        storageName = nameStorage.isNotEmpty ? nameStorage : "Kho của tôi";
      });
    } catch (e) {
      debugPrint('Error loading storage: $e');
      setState(() {
        currentStorageId = null;
        storageName = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Đảm bảo ScreenUtil được khởi tạo nếu chưa
    // ScreenUtil.init(context, designSize: const Size(360, 690)); // Chỉ cần gọi 1 lần ở MaterialApp

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Stock Mate',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: (currentStorageId == null ||
              currentStorageId == -1 ||
              currentStorageId! <= 0)
          ? _buildNoStorageView()
          : _buildMainView(),
      floatingActionButton: (currentStorageId == null ||
              currentStorageId == -1 ||
              currentStorageId! <= 0)
          ? FloatingActionButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                  builder: (context) => Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .cardColor, // Sử dụng màu card từ theme
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(16.r)),
                    ),
                    padding: EdgeInsets.fromLTRB(
                        16.w, 24.h, 16.w, 16.h), // Tăng padding trên
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Chọn hành động',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: AppTheme.textPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        SizedBox(height: 20.h),
                        SizedBox(
                          width: double.infinity,
                          height: 50.h, // Tăng chiều cao nút
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context); // Đóng bottom sheet
                              _showCreateStorageDialog();
                            },
                            icon: const Icon(
                                Icons.add_circle_outline), // Icon mới
                            label: Text(
                              'Tạo kho mới',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(
                                    color: Colors.white,
                                  ),
                            ),
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 16.h),
                        SizedBox(
                          width: double.infinity,
                          height: 50.h, // Tăng chiều cao nút
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context); // Đóng bottom sheet
                              _showJoinStorageDialog();
                            },
                            icon: const Icon(
                                Icons.group_add_outlined), // Icon mới
                            label: Text(
                              'Tham gia kho',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(
                                    color: AppTheme.primaryGreen,
                                  ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.primaryGreen,
                              side: const BorderSide(
                                  color: AppTheme.primaryGreen),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
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
              child: const Icon(Icons.add_rounded), // Đổi icon thành dấu cộng
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildNoStorageView() {
    return Center(
      // Đặt Center để căn giữa nội dung
      child: SingleChildScrollView(
        // Thêm SingleChildScrollView để tránh overflow khi bàn phím hiện lên
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
                Icons.inventory_2_outlined, // Icon mới, hiện đại hơn
                size: 60.w,
                color: AppTheme.primaryGreen,
              ),
            ),
            SizedBox(height: 32.h),

            // Title
            Text(
              'Chưa có kho nào',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.primaryGreen,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: 12.h),

            // Description
            Text(
              'Bạn cần tạo mới hoặc tham gia một kho để bắt đầu quản lý nguyên liệu',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
            SizedBox(height: 48.h),
          ],
        ),
      ),
    );
  }

  Widget _buildMainView() {
    return SingleChildScrollView(
      // Thêm SingleChildScrollView cho phép cuộn nội dung
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
              boxShadow: [
                // Thêm shadow cho card
                BoxShadow(
                  color: AppTheme.primaryGreen.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
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
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                  color: Colors.white.withOpacity(0.9),
                                ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            storageName ?? "Kho của tôi",
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Image.asset(
                      'assets/images/market.png', // Đường dẫn đến ảnh trong thư mục assets
                      width: 50.0,
                      height: 50.0,
                      fit: BoxFit.contain, // Tùy chỉnh cách ảnh co giãn
                    )
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  'Quản lý nguyên liệu một cách hiệu quả',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
          ),
          SizedBox(height: 12.h),
          BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              if (state.isLoading) {
                return const CircularProgressIndicator();
              }

              return Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.inventory_2_outlined,
                      title: 'Sản phẩm',
                      value: state.totalProducts.toString(),
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.warning_amber_rounded,
                      title: 'Sắp hết hạn',
                      value: state.nearExpiry.toString(),
                      color: AppTheme.accentYellow,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.cancel_outlined,
                      title: 'Đã hết hạn',
                      value: state.expired.toString(),
                      color: AppTheme.errorRed, // chọn màu cảnh báo
                    ),
                  ),
                ],
              );
            },
          ),
          SizedBox(height: 24.h),

          // Quick actions
          Text(
            'Thao tác nhanh',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
          ),
          SizedBox(height: 12.h),
          // Bọc GridView trong Container với BoxDecoration để tạo khung
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppTheme.cardBackground,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: GridView.count(
              physics:
                  const NeverScrollableScrollPhysics(), // Vô hiệu hóa cuộn GridView
              shrinkWrap:
                  true, // Cho phép GridView chỉ chiếm không gian cần thiết
              crossAxisCount: 3, // 3 cột để bố cục đẹp hơn
              crossAxisSpacing: 16.w, // Tăng khoảng cách ngang
              mainAxisSpacing: 16.h, // Tăng khoảng cách dọc
              childAspectRatio: 0.9, // Tỷ lệ khung hình cho mỗi item
              children: [
                _buildActionCard(
                  icon: Image.asset(
                    'assets/icons/groceries.png',
                    width: 32,
                    height: 32,
                    color: AppTheme.primaryGreen,
                  ),
                  title: 'Thực phẩm',
                  onTap: () => context.push('/grocery'),
                ),
                _buildActionCard(
                  icon: Icon(Icons.shopping_cart_outlined,
                      color: AppTheme.primaryGreen, size: 32.w), // Icon mới
                  title: 'Mua sắm',
                  onTap: () => context.push('/shopping'),
                ),
                _buildActionCard(
                  icon: Icon(Icons.group_outlined,
                      color: AppTheme.primaryGreen,
                      size: 32.w), // Icon mới cho quản lý thành viên
                  title: 'Thành viên',
                  onTap: () => context.push('/storage'),
                ),
                _buildActionCard(
                  icon: Icon(Icons.calendar_month,
                      color: AppTheme.primaryGreen, size: 32.w), // Icon mới
                  title: 'Nhắc nhở',
                  onTap: () => context.push('/reminder'),
                ),
                _buildActionCard(
                  icon: Icon(Icons.flatware_outlined,
                      color: AppTheme.primaryGreen, size: 32.w), // Icon mới
                  title: 'Món ăn',
                  onTap: () => context.push('/dish'),
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
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16.r), // Tăng bo tròn cho card
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
          Icon(icon, color: color, size: 32.w), // Tăng kích thước icon
          SizedBox(height: 8.h),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.black,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required Widget icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        // Sử dụng Card từ theme
        elevation:
            0, // Đặt elevation về 0 vì đã có shadow ở Container bọc ngoài
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        color: Colors
            .transparent, // Đặt màu nền trong suốt để shadow từ Container bọc ngoài hiển thị
        child: InkWell(
          // Sử dụng InkWell để có hiệu ứng splash
          borderRadius: BorderRadius.circular(12.r),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(8.w), // Giảm padding nội bộ để fit 3 cột
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 40.w,
                  width: 40.w,
                  child: Center(child: icon),
                ),
                SizedBox(height: 8.h), // Giảm khoảng cách
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                  maxLines: 2, // Giới hạn 2 dòng để tránh overflow
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
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
            child: const Text('Hủy',
                style: TextStyle(color: AppTheme.textSecondary)),
          ),
          BlocListener<StorageBloc, StorageState>(
            listener: (context, state) {
              if (state is StorageSuccess) {
                final storage = state.storage;
                setState(() {
                  currentStorageId = storage.id;
                  storageName = storage.name;
                });

                Navigator.pop(context); // Đóng dialog sau khi tạo xong
                ScaffoldMessenger.of(context).showSnackBar(
                  // Thông báo thành công
                  const SnackBar(content: Text('Tạo kho thành công!')),
                );
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
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Tên kho không được để trống!')),
                  );
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
            child: const Text('Hủy',
                style: TextStyle(color: AppTheme.textSecondary)),
          ),
          BlocListener<StorageBloc, StorageState>(
            listener: (context, state) {
              if (state is StorageSuccess) {
                final storage = state.storage;
                setState(() {
                  currentStorageId = storage.id;
                  storageName = storage.name;
                });

                Navigator.pop(context); // Đóng dialog sau khi tham gia xong
                ScaffoldMessenger.of(context).showSnackBar(
                  // Thông báo thành công
                  const SnackBar(content: Text('Tham gia kho thành công!')),
                );
              } else if (state is StorageError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
            child: ElevatedButton(
              onPressed: () {
                if (codeController.text.trim().isNotEmpty) {
                  context
                      .read<StorageBloc>()
                      .add(StorageJoinRequested(codeController.text.trim()));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Mã kho không được để trống!')),
                  );
                }
              },
              child: const Text('Tham gia'),
            ),
          )
        ],
      ),
    );
  }
}
