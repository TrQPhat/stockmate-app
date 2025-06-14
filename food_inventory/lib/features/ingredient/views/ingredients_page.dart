// Cập nhật để sử dụng BLoC
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_theme.dart';
import '../bloc/ingredients_bloc.dart';
import '../models/ingredient.dart';
import '../models/category.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  String? selectedCategoryId;

  @override
  void initState() {
    super.initState();
    context.read<ProductsBloc>().add(const LoadIngredients());
    context.read<ProductsBloc>().add(LoadCategories());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý sản phẩm'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              _showSearchDialog(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Implement filter
            },
          ),
        ],
      ),
      body: BlocBuilder<ProductsBloc, IngredientsState>(
        builder: (context, state) {
          if (state is IngredientsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is IngredientssError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ProductsBloc>().add(const LoadIngredients());
                    },
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          if (state is IngredientsLoaded) {
            return Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                children: [
                  // Category tabs
                  if (state.categories != null) ...[
                    Container(
                      height: 40.h,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _buildCategoryChip(
                              'Tất cả', selectedCategoryId == null),
                          SizedBox(width: 8.w),
                          ...state.categories!.map(
                            (category) => Padding(
                              padding: EdgeInsets.only(right: 8.w),
                              child: _buildCategoryChip(
                                category.name,
                                selectedCategoryId == category.id,
                                onTap: () {
                                  setState(() {
                                    selectedCategoryId = category.id;
                                  });
                                  context.read<ProductsBloc>().add(
                                        FilterIngredientsByCategory(
                                            category.id),
                                      );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),
                  ],

                  // Products list
                  Expanded(
                    child: state.ingredients.isEmpty
                        ? const Center(child: Text('Chưa có sản phẩm nào'))
                        : ListView.builder(
                            itemCount: state.ingredients.length,
                            itemBuilder: (context, index) {
                              return _buildProductCard(
                                  state.ingredients[index]);
                            },
                          ),
                  ),
                ],
              ),
            );
          }

          return const Center(child: Text('Không có dữ liệu'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddProductDialog(context);
        },
        backgroundColor: AppTheme.primaryGreen,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected,
      {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap ??
          () {
            setState(() {
              selectedCategoryId = null;
            });
            context
                .read<ProductsBloc>()
                .add(const FilterIngredientsByCategory(null));
          },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryGreen : Colors.grey[200],
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontSize: 14.sp,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(Ingredient product) {
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
          // Product image
          Container(
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: product.imagePath != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: Image.network(
                      product.imagePath!,
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

          // Product info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Số lượng: ${product.quantity} ${product.unit ?? ''}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
                if (product.expireDate != null) ...[
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14.w,
                        color: _getExpireColor(product.expireDate!),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'Hết hạn: ${_formatDate(product.expireDate!)}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: _getExpireColor(product.expireDate!),
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
                _showDeleteConfirmDialog(context, product);
              } else if (value == 'edit') {
                _showEditProductDialog(context, product);
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

  void _showSearchDialog(BuildContext context) {
    final searchController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tìm kiếm sản phẩm'),
        content: TextField(
          controller: searchController,
          decoration: const InputDecoration(
            labelText: 'Tên sản phẩm',
            hintText: 'Nhập tên sản phẩm...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              if (searchController.text.isNotEmpty) {
                context.read<ProductsBloc>().add(
                      SearchIngredients(searchController.text),
                    );
              }
              Navigator.pop(context);
            },
            child: const Text('Tìm kiếm'),
          ),
        ],
      ),
    );
  }

  void _showAddProductDialog(BuildContext context) {
    // TODO: Implement add product dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Chức năng thêm sản phẩm đang được phát triển')),
    );
  }

  void _showEditProductDialog(BuildContext context, Ingredient product) {
    // TODO: Implement edit product dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Chức năng chỉnh sửa sản phẩm đang được phát triển')),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, Ingredient product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa sản phẩm "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<ProductsBloc>().add(DeleteIngredient(product.id));
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
