// Cập nhật để sử dụng BLoC
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stock_mate/bloc/category/categories_bloc.dart';
import 'package:stock_mate/bloc/grocery/groceries_bloc.dart';
import 'package:stock_mate/views/groceries/views/input_grocery_page.dart';
import 'package:stock_mate/views/groceries/widgets/category_chip.dart';
import 'package:stock_mate/views/groceries/widgets/grocery_cart.dart';
import '../../../core/theme/app_theme.dart';

class GroceriesPage extends StatefulWidget {
  const GroceriesPage({super.key});

  @override
  State<GroceriesPage> createState() => _GroceriesPageState();
}

class _GroceriesPageState extends State<GroceriesPage> {
  int? selectedCategoryId;

  @override
  void initState() {
    super.initState();
    context.read<CategoriesBloc>().add(LoadCategories());
    context.read<GroceriesBloc>().add(const LoadGroceries());
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
      body: BlocBuilder<GroceriesBloc, GroceriesState>(
        builder: (context, state) {
          if (state is GroceriesLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is GroceriesError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  ElevatedButton(
                    onPressed: () {
                      context.read<GroceriesBloc>().add(const LoadGroceries());
                    },
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          if (state is GroceriesLoaded) {
            final groceries = selectedCategoryId == null
                ? state.groceries
                : state.groceries
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
                        if (categoriesState.categories.isNotEmpty) {
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
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  // Groceries list
                  Expanded(
                    child: groceries.isEmpty
                        ? const Center(child: Text('Chưa có sản phẩm nào'))
                        : ListView.builder(
                            itemCount: groceries.length,
                            itemBuilder: (context, index) {
                              return GroceryCard(grocery: groceries[index]);
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
          _showAddGroceryDialog(context);
        },
        backgroundColor: AppTheme.primaryGreen,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // Widget _buildGroceryCard(Grocery grocery) {
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
  //         // Grocery image
  //         Container(
  //           width: 60.w,
  //           height: 60.w,
  //           decoration: BoxDecoration(
  //             color: Colors.grey[200],
  //             borderRadius: BorderRadius.circular(8.r),
  //           ),
  //           child: grocery.imagePath != null
  //               ? ClipRRect(
  //                   borderRadius: BorderRadius.circular(8.r),
  //                   child: Image.network(
  //                     grocery.imagePath!,
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

  //         // Grocery info
  //         Expanded(
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text(
  //                 grocery.name,
  //                 style: TextStyle(
  //                   fontSize: 16.sp,
  //                   fontWeight: FontWeight.w500,
  //                 ),
  //               ),
  //               SizedBox(height: 4.h),
  //               Text(
  //                 'Số lượng: ${grocery.quantity} ${grocery.unit ?? ''}',
  //                 style: TextStyle(
  //                   fontSize: 14.sp,
  //                   color: Colors.grey[600],
  //                 ),
  //               ),
  //               if (grocery.expireDate != null) ...[
  //                 SizedBox(height: 4.h),
  //                 Row(
  //                   children: [
  //                     Icon(
  //                       Icons.access_time,
  //                       size: 14.w,
  //                       color: _getExpireColor(grocery.expireDate!),
  //                     ),
  //                     SizedBox(width: 4.w),
  //                     Text(
  //                       'Hết hạn: ${_formatDate(grocery.expireDate!)}',
  //                       style: TextStyle(
  //                         fontSize: 12.sp,
  //                         color: _getExpireColor(grocery.expireDate!),
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
  //               _showDeleteConfirmDialog(context, grocery);
  //             } else if (value == 'edit') {
  //               _showEditGroceryDialog(context, grocery);
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
                context.read<GroceriesBloc>().add(
                      SearchGroceries(searchController.text),
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

  void _showAddGroceryDialog(BuildContext context) {
    // Thêm mới
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const InputGroceryPage(),
      ),
    );
  }
}
