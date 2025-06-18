// Cập nhật để sử dụng BLoC
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stock_mate/bloc/category/categories_bloc.dart';
import 'package:stock_mate/views/ingredient/views/input_ingredient_page.dart';
import 'package:stock_mate/views/ingredient/widgets/category_chip.dart';
import 'package:stock_mate/views/ingredient/widgets/ingredient_cart.dart';

import '../../../core/theme/app_theme.dart';
import '../../../bloc/ingredient/ingredients_bloc.dart';

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
    context.read<CategoriesBloc>().add(LoadCategories());
    context.read<IngredientsBloc>().add(const LoadIngredients());
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
      body: BlocBuilder<IngredientsBloc, IngredientsState>(
        builder: (context, state) {
          if (state is IngredientsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is IngredientsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  ElevatedButton(
                    onPressed: () {
                      context
                          .read<IngredientsBloc>()
                          .add(const LoadIngredients());
                    },
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          if (state is IngredientsLoaded) {
            final ingredients = selectedCategoryId == null
                ? state.ingredients
                : state.ingredients
                    .where((i) => i.categoryId == selectedCategoryId)
                    .toList();
            return Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                children: [
                  // Category tabs
                  BlocBuilder<CategoriesBloc, CategoriesState>(
                    builder: (context, categoriesState) {
                      if (categoriesState is CategoriesLoaded) {
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              CategoryChip(
                                label: 'Tất cả',
                                isSelected: selectedCategoryId == null,
                                onTap: () {
                                  setState(() {
                                    selectedCategoryId = null;
                                  });
                                },
                              ),
                              SizedBox(width: 8.w),
                              ...categoriesState.categories.map((category) {
                                final isSelected =
                                    selectedCategoryId == category.id;
                                return CategoryChip(
                                  label: category.name,
                                  isSelected: isSelected,
                                  onTap: () {
                                    setState(() {
                                      selectedCategoryId = category.id;
                                    });
                                  },
                                );
                              }),
                            ],
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  // Products list
                  Expanded(
                    child: ingredients.isEmpty
                        ? const Center(child: Text('Chưa có sản phẩm nào'))
                        : ListView.builder(
                            itemCount: ingredients.length,
                            itemBuilder: (context, index) {
                              return IngredientCard(
                                  ingredient: ingredients[index]);
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

  // Widget _buildProductCard(Ingredient product) {
  //   return Container(
  //     margin: EdgeInsets.only(bottom: 12.h),
  //     padding: EdgeInsets.all(16.w),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(12.r),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.grey.withOpacity(0.1),
  //           spreadRadius: 1,
  //           blurRadius: 4,
  //           offset: const Offset(0, 2),
  //         ),
  //       ],
  //     ),
  //     child: Row(
  //       children: [
  //         // Product image
  //         Container(
  //           width: 60.w,
  //           height: 60.w,
  //           decoration: BoxDecoration(
  //             color: Colors.grey[200],
  //             borderRadius: BorderRadius.circular(8.r),
  //           ),
  //           child: product.imagePath != null
  //               ? ClipRRect(
  //                   borderRadius: BorderRadius.circular(8.r),
  //                   child: Image.network(
  //                     product.imagePath!,
  //                     fit: BoxFit.cover,
  //                     errorBuilder: (context, error, stackTrace) {
  //                       return Icon(
  //                         Icons.image,
  //                         color: Colors.grey[400],
  //                         size: 30.w,
  //                       );
  //                     },
  //                   ),
  //                 )
  //               : Icon(
  //                   Icons.image,
  //                   color: Colors.grey[400],
  //                   size: 30.w,
  //                 ),
  //         ),
  //         SizedBox(width: 12.w),

  //         // Product info
  //         Expanded(
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text(
  //                 product.name,
  //                 style: TextStyle(
  //                   fontSize: 16.sp,
  //                   fontWeight: FontWeight.w500,
  //                 ),
  //               ),
  //               SizedBox(height: 4.h),
  //               Text(
  //                 'Số lượng: ${product.quantity} ${product.unit ?? ''}',
  //                 style: TextStyle(
  //                   fontSize: 14.sp,
  //                   color: Colors.grey[600],
  //                 ),
  //               ),
  //               if (product.expireDate != null) ...[
  //                 SizedBox(height: 4.h),
  //                 Row(
  //                   children: [
  //                     Icon(
  //                       Icons.access_time,
  //                       size: 14.w,
  //                       color: _getExpireColor(product.expireDate!),
  //                     ),
  //                     SizedBox(width: 4.w),
  //                     Text(
  //                       'Hết hạn: ${_formatDate(product.expireDate!)}',
  //                       style: TextStyle(
  //                         fontSize: 12.sp,
  //                         color: _getExpireColor(product.expireDate!),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ],
  //             ],
  //           ),
  //         ),

  //         // Actions
  //         PopupMenuButton(
  //           icon: Icon(Icons.more_vert, size: 20.w),
  //           itemBuilder: (context) => [
  //             const PopupMenuItem(
  //               value: 'edit',
  //               child: Text('Chỉnh sửa'),
  //             ),
  //             const PopupMenuItem(
  //               value: 'delete',
  //               child: Text('Xóa'),
  //             ),
  //           ],
  //           onSelected: (value) {
  //             if (value == 'delete') {
  //               _showDeleteConfirmDialog(context, product);
  //             } else if (value == 'edit') {
  //               _showEditProductDialog(context, product);
  //             }
  //           },
  //         ),
  //       ],
  //     ),
  //   );
  // }

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
                context.read<IngredientsBloc>().add(
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
    // Thêm mới
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const InputIngredientPage(),
      ),
    );
  }
}
