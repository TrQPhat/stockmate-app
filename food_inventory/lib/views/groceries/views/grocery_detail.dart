import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:stock_mate/bloc/category/categories_bloc.dart';
import 'package:stock_mate/bloc/grocery/groceries_bloc.dart';
import 'package:stock_mate/core/config/app_config.dart';
import 'package:stock_mate/models/category.dart';
import 'package:stock_mate/models/grocery.dart';
import 'package:stock_mate/views/groceries/views/input_grocery_page.dart';

class GroceryDetailPage extends StatefulWidget {
  final Grocery grocery;

  const GroceryDetailPage({
    super.key,
    required this.grocery,
  });

  @override
  State<GroceryDetailPage> createState() => _GroceryDetailPageState();
}

class _GroceryDetailPageState extends State<GroceryDetailPage> {
  late Grocery currentGrocery;
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  List<Category> categories = [];

  // Enhanced green color palette
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color lightGreen = Color(0xFF4CAF50);
  static const Color accentGreen = Color(0xFF81C784);
  static const Color backgroundGreen = Color(0xFFE8F5E8);
  static const Color darkGreen = Color(0xFF1B5E20);
  static const Color mintGreen = Color(0xFF66BB6A);
  static const Color leafGreen = Color(0xFF388E3C);

  @override
  void initState() {
    super.initState();
    currentGrocery = widget.grocery;
    _loadCategories();
  }

  void _loadCategories() {
    context.read<GroceriesBloc>().add(const LoadGroceries());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGreen,
      body: MultiBlocListener(
        listeners: [
          BlocListener<GroceriesBloc, GroceriesState>(
            listener: (context, state) {
              if (state is GroceriesError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red[600],
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                );
              } else if (state is GroceriesLoaded) {
                final updatedGrocery = state.groceries
                    .where((ing) => ing.id == currentGrocery.id)
                    .firstOrNull;
                if (updatedGrocery != null) {
                  setState(() {
                    currentGrocery = updatedGrocery;
                  });
                }
              }
            },
          ),
          BlocListener<CategoriesBloc, CategoriesState>(
            listener: (context, state) {
              if (state is CategoriesLoaded) {
                setState(() {
                  categories = state.categories;
                });
              }
            },
          ),
        ],
        child: CustomScrollView(
          slivers: [
            _buildEnhancedSliverAppBar(),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeroCard(),
                    SizedBox(height: 20.h),
                    _buildQuickStatsRow(),
                    SizedBox(height: 24.h),
                    _buildBasicInfoSection(),
                    SizedBox(height: 20.h),
                    _buildQuantitySection(),
                    SizedBox(height: 20.h),
                    _buildDateSection(),
                    SizedBox(height: 20.h),
                    _buildStatusSection(),
                    if (currentGrocery.note != null) ...[
                      SizedBox(height: 20.h),
                      _buildNoteSection(),
                    ],
                    SizedBox(height: 20.h),
                    _buildMetadataSection(),
                    SizedBox(height: 32.h),
                    _buildEnhancedActionButtons(),
                    SizedBox(height: 100.h), // Extra space for floating buttons
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButtons(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
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

  Widget _buildEnhancedSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 320.h,
      pinned: true,
      elevation: 0,
      backgroundColor: primaryGreen,
      flexibleSpace: FlexibleSpaceBar(
        title: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text(
            currentGrocery.name,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            currentGrocery.imagePath != null
                ? Image.network(
                    "${AppConfig.rootImagePath}/${currentGrocery.imagePath!}",
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildEnhancedImagePlaceholder();
                    },
                  )
                : _buildEnhancedImagePlaceholder(),
            // Enhanced gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    primaryGreen.withOpacity(0.3),
                    primaryGreen.withOpacity(0.7),
                    Colors.black.withOpacity(0.8),
                  ],
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
      leading: Container(
        margin: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryGreen),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      actions: [
        Container(
          margin: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: primaryGreen),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  _editGrocery();
                  break;
                case 'delete':
                  _showDeleteConfirmDialog();
                  break;
                case 'share':
                  _shareGrocery();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, color: primaryGreen, size: 20.w),
                    SizedBox(width: 12.w),
                    const Text('Chỉnh sửa'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.red, size: 20.w),
                    SizedBox(width: 12.w),
                    const Text('Xóa'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedImagePlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentGreen.withOpacity(0.3),
            lightGreen.withOpacity(0.5),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.eco,
              size: 60.w,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Không có hình ảnh',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [lightGreen, mintGreen],
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: primaryGreen.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Icon(
                  Icons.inventory_2,
                  color: Colors.white,
                  size: 32.w,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentGrocery.name,
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      _getCategoryName(currentGrocery.categoryId) ??
                          'Chưa phân loại',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.inventory,
            label: 'Số lượng',
            value: '${currentGrocery.quantity}',
            unit: currentGrocery.unit ?? '',
            color: lightGreen,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildStatCard(
            icon: Icons.schedule,
            label: 'Trạng thái',
            value: _getStatusName(currentGrocery.status),
            unit: '',
            color: _getStatusColor(currentGrocery.status),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildStatCard(
            icon: Icons.event,
            label: 'Hạn sử dụng',
            value: _getDaysUntilExpiry(),
            unit: 'ngày',
            color: _getExpireDateColor(
                currentGrocery.expireDate ?? DateTime.now()),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required String unit,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24.w),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          if (unit.isNotEmpty)
            Text(
              unit,
              style: TextStyle(
                fontSize: 10.sp,
                color: Colors.grey[600],
              ),
            ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    final categoryName = _getCategoryName(currentGrocery.categoryId);

    return _buildEnhancedSection(
      title: 'Thông tin cơ bản',
      icon: Icons.info_outline,
      iconColor: primaryGreen,
      child: Column(
        children: [
          _buildEnhancedInfoRow(
            icon: Icons.label_outline,
            label: 'Tên nguyên liệu',
            value: currentGrocery.name,
            iconColor: leafGreen,
          ),
          if (categoryName != null) ...[
            SizedBox(height: 16.h),
            _buildEnhancedInfoRow(
              icon: Icons.category_outlined,
              label: 'Danh mục',
              value: categoryName,
              iconColor: accentGreen,
            ),
          ],
          if (currentGrocery.positionId != null) ...[
            SizedBox(height: 16.h),
            _buildEnhancedInfoRow(
              icon: Icons.location_on_outlined,
              label: 'Vị trí',
              value:
                  GroceryPosition.fromCode(currentGrocery.positionId!)?.label ??
                      'Không xác định',
              iconColor: mintGreen,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuantitySection() {
    return _buildEnhancedSection(
      title: 'Số lượng tồn kho',
      icon: Icons.inventory_2_outlined,
      iconColor: lightGreen,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              lightGreen.withOpacity(0.1),
              accentGreen.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: lightGreen.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  currentGrocery.quantity.toString(),
                  style: TextStyle(
                    fontSize: 48.sp,
                    fontWeight: FontWeight.bold,
                    color: lightGreen,
                  ),
                ),
                if (currentGrocery.unit != null) ...[
                  SizedBox(width: 8.w),
                  Text(
                    currentGrocery.unit!,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: lightGreen.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                'Số lượng hiện tại',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: darkGreen,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSection() {
    return _buildEnhancedSection(
      title: 'Thông tin ngày tháng',
      icon: Icons.calendar_today_outlined,
      iconColor: primaryGreen,
      child: Column(
        children: [
          if (currentGrocery.importDate != null) ...[
            _buildEnhancedInfoRow(
              icon: Icons.login_outlined,
              label: 'Ngày nhập kho',
              value: _dateFormat.format(currentGrocery.importDate!),
              valueColor: Colors.blue[600],
              iconColor: Colors.blue,
            ),
            SizedBox(height: 16.h),
          ],
          if (currentGrocery.expireDate != null) ...[
            _buildEnhancedInfoRow(
              icon: Icons.event_busy_outlined,
              label: 'Ngày hết hạn',
              value: _dateFormat.format(currentGrocery.expireDate!),
              valueColor: _getExpireDateColor(currentGrocery.expireDate!),
              iconColor: _getExpireDateColor(currentGrocery.expireDate!),
            ),
            SizedBox(height: 16.h),
            _buildExpiryWarning(),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusSection() {
    return _buildEnhancedSection(
      title: 'Trạng thái sản phẩm',
      icon: Icons.info_outlined,
      iconColor: _getStatusColor(currentGrocery.status),
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: _getStatusColor(currentGrocery.status).withOpacity(0.1),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: _getStatusColor(currentGrocery.status).withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: _getStatusColor(currentGrocery.status),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                _getStatusIcon(currentGrocery.status),
                color: Colors.white,
                size: 24.w,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getStatusName(currentGrocery.status),
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(currentGrocery.status),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    _getStatusDescription(currentGrocery.status),
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
      ),
    );
  }

  Widget _buildNoteSection() {
    return _buildEnhancedSection(
      title: 'Ghi chú',
      icon: Icons.note_outlined,
      iconColor: Colors.amber[700]!,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.amber[50],
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.amber[200]!),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.format_quote,
              color: Colors.amber[700],
              size: 20.w,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                currentGrocery.note!,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[700],
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetadataSection() {
    return _buildEnhancedSection(
      title: 'Thông tin hệ thống',
      icon: Icons.settings_outlined,
      iconColor: Colors.grey[600]!,
      child: Column(
        children: [
          _buildEnhancedInfoRow(
            icon: Icons.add_circle_outline,
            label: 'Ngày tạo',
            value: _dateFormat.format(currentGrocery.createdAt),
            iconColor: Colors.green,
          ),
          SizedBox(height: 16.h),
          _buildEnhancedInfoRow(
            icon: Icons.update_outlined,
            label: 'Cập nhật lần cuối',
            value: _dateFormat.format(currentGrocery.updatedAt),
            iconColor: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedSection({
    required String title,
    required IconData icon,
    required Widget child,
    required Color iconColor,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.r),
                topRight: Radius.circular(20.r),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 20.w,
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: iconColor,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20.w),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    Color? iconColor,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: (iconColor ?? Colors.grey[600]!).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            icon,
            size: 18.w,
            color: iconColor ?? Colors.grey[600],
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExpiryWarning() {
    if (currentGrocery.expireDate == null) return const SizedBox.shrink();

    final now = DateTime.now();
    final expireDate = currentGrocery.expireDate!;
    final difference = expireDate.difference(now).inDays;

    String message;
    Color color;
    IconData icon;

    if (difference < 0) {
      message = 'Đã hết hạn ${(-difference)} ngày';
      color = Colors.red;
      icon = Icons.error_outline;
    } else if (difference <= 7) {
      message = 'Sắp hết hạn trong $difference ngày';
      color = Colors.orange;
      icon = Icons.warning_outlined;
    } else {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20.w),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 14.sp,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedActionButtons() {
    return Column(
      children: [
        // Primary action button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _editGrocery,
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Chỉnh sửa thông tin'),
            style: ElevatedButton.styleFrom(
              backgroundColor: lightGreen,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              elevation: 4,
            ),
          ),
        ),
        SizedBox(height: 16.h),

        // Secondary actions
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _shareGrocery,
                icon: const Icon(Icons.share_outlined),
                label: const Text('Chia sẻ'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryGreen,
                  side: BorderSide(color: primaryGreen, width: 2),
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _showDeleteConfirmDialog,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Xóa'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red, width: 2),
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFloatingActionButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton.extended(
          heroTag: "quick_edit",
          onPressed: _updateQuantity,
          backgroundColor: lightGreen,
          icon: const Icon(Icons.edit, color: Colors.white),
          label: const Text('Sửa nhanh', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  // Helper methods
  String? _getCategoryName(int? categoryId) {
    if (categoryId == null) return null;
    final category =
        categories.where((cat) => cat.id == categoryId).firstOrNull;
    return category?.name;
  }

  String _getDaysUntilExpiry() {
    if (currentGrocery.expireDate == null) return 'N/A';
    final difference =
        currentGrocery.expireDate!.difference(DateTime.now()).inDays;
    if (difference < 0) return 'Hết hạn';
    return difference.toString();
  }

  Color _getExpireDateColor(DateTime expireDate) {
    final now = DateTime.now();
    final difference = expireDate.difference(now).inDays;

    if (difference < 0) {
      return Colors.red;
    } else if (difference <= 7) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  Color _getStatusColor(GroceryStatus status) {
    switch (status) {
      case GroceryStatus.conDung:
        return lightGreen;
      case GroceryStatus.hetHan:
        return Colors.red;
      case GroceryStatus.daDung:
        return Colors.orange;
      case GroceryStatus.huy:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(GroceryStatus status) {
    switch (status) {
      case GroceryStatus.conDung:
        return Icons.check_circle;
      case GroceryStatus.hetHan:
        return Icons.error;
      case GroceryStatus.daDung:
        return Icons.inventory;
      case GroceryStatus.huy:
        return Icons.cancel;
    }
  }

  String _getStatusName(GroceryStatus status) {
    switch (status) {
      case GroceryStatus.conDung:
        return 'Còn dùng';
      case GroceryStatus.hetHan:
        return 'Hết hạn';
      case GroceryStatus.daDung:
        return 'Đã dùng';
      case GroceryStatus.huy:
        return 'Hủy';
    }
  }

  String _getStatusDescription(GroceryStatus status) {
    switch (status) {
      case GroceryStatus.conDung:
        return 'Sản phẩm vẫn còn tốt và có thể sử dụng';
      case GroceryStatus.hetHan:
        return 'Sản phẩm đã quá hạn sử dụng';
      case GroceryStatus.daDung:
        return 'Sản phẩm đã được sử dụng hết';
      case GroceryStatus.huy:
        return 'Sản phẩm đã bị hủy bỏ';
    }
  }

  // Action methods remain the same but with enhanced dialogs
  void _editGrocery() async {
    _showEditProductDialog(context, widget.grocery);
  }

  void _updateQuantity() {
    final quantityController = TextEditingController(
      text: currentGrocery.quantity.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: lightGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(Icons.inventory, color: lightGreen),
            ),
            SizedBox(width: 12.w),
            const Text('Cập nhật số lượng'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: quantityController,
              decoration: InputDecoration(
                labelText: 'Số lượng mới',
                hintText: 'Nhập số lượng...',
                suffixText: currentGrocery.unit,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: lightGreen, width: 2),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () {
              final newQuantity = int.tryParse(quantityController.text);
              if (newQuantity != null && newQuantity >= 0) {
                final updatedGrocery = Grocery(
                  id: currentGrocery.id,
                  storageId: currentGrocery.storageId,
                  name: currentGrocery.name,
                  categoryId: currentGrocery.categoryId,
                  quantity: newQuantity,
                  unit: currentGrocery.unit,
                  importDate: currentGrocery.importDate,
                  expireDate: currentGrocery.expireDate,
                  note: currentGrocery.note,
                  status: currentGrocery.status,
                  positionId: currentGrocery.positionId,
                  imagePath: currentGrocery.imagePath,
                  createdAt: currentGrocery.createdAt,
                  updatedAt: DateTime.now(),
                );

                context
                    .read<GroceriesBloc>()
                    .add(UpdateGrocery(updatedGrocery, null));
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: lightGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child:
                const Text('Cập nhật', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _shareGrocery() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Chức năng chia sẻ đang được phát triển'),
        backgroundColor: lightGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }

  void _showDeleteConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red[600]),
            SizedBox(width: 12.w),
            const Text('Xác nhận xóa'),
          ],
        ),
        content: Text(
          'Bạn có chắc chắn muốn xóa nguyên liệu "${currentGrocery.name}"?\n\nHành động này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () {
              context
                  .read<GroceriesBloc>()
                  .add(DeleteGrocery(currentGrocery.id));
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
