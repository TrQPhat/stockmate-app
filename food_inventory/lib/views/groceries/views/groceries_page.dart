// // Cập nhật để sử dụng BLoC
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:go_router/go_router.dart';
// import 'package:stock_mate/bloc/category/categories_bloc.dart';
// import 'package:stock_mate/bloc/grocery/groceries_bloc.dart';
// import 'package:stock_mate/views/groceries/views/input_grocery_page.dart';
// import 'package:stock_mate/views/groceries/widgets/category_chip.dart';
// import 'package:stock_mate/views/groceries/widgets/grocery_cart.dart';
// import '../../../core/theme/app_theme.dart';

// class GroceriesPage extends StatefulWidget {
//   const GroceriesPage({super.key});

//   @override
//   State<GroceriesPage> createState() => _GroceriesPageState();
// }

// class _GroceriesPageState extends State<GroceriesPage> {
//   int? selectedCategoryId;

//   @override
//   void initState() {
//     super.initState();
//     context.read<CategoriesBloc>().add(LoadCategories());
//     context.read<GroceriesBloc>().add(const LoadGroceries());
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Quản lý sản phẩm'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.search),
//             onPressed: () {
//               _showSearchDialog(context);
//             },
//           ),
//           IconButton(
//             icon: const Icon(Icons.filter_list),
//             onPressed: () {
//               // TODO: Implement filter
//             },
//           ),
//         ],
//       ),
//       body: BlocBuilder<GroceriesBloc, GroceriesState>(
//         builder: (context, state) {
//           if (state is GroceriesLoading) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (state is GroceriesError) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(state.message),
//                   ElevatedButton(
//                     onPressed: () {
//                       context.read<GroceriesBloc>().add(const LoadGroceries());
//                     },
//                     child: const Text('Thử lại'),
//                   ),
//                 ],
//               ),
//             );
//           }

//           if (state is GroceriesLoaded) {
//             final groceries = selectedCategoryId == null
//                 ? state.groceries
//                 : state.groceries
//                     .where((i) => i.categoryId == selectedCategoryId)
//                     .toList();
//             return Padding(
//               padding: EdgeInsets.all(16.w),
//               child: Column(
//                 children: [
//                   // Category tabs
//                   BlocBuilder<CategoriesBloc, CategoriesState>(
//                     builder: (context, categoriesState) {
//                       if (categoriesState is CategoriesLoaded) {
//                         if (categoriesState.categories.isNotEmpty) {
//                           return SingleChildScrollView(
//                             scrollDirection: Axis.horizontal,
//                             child: Row(
//                               children: [
//                                 CategoryChip(
//                                   label: 'Tất cả',
//                                   isSelected: selectedCategoryId == null,
//                                   onTap: () {
//                                     setState(() {
//                                       selectedCategoryId = null;
//                                     });
//                                   },
//                                 ),
//                                 SizedBox(width: 8.w),
//                                 ...categoriesState.categories.map((category) {
//                                   final isSelected =
//                                       selectedCategoryId == category.id;
//                                   return CategoryChip(
//                                     label: category.name,
//                                     isSelected: isSelected,
//                                     onTap: () {
//                                       setState(() {
//                                         selectedCategoryId = category.id;
//                                       });
//                                     },
//                                   );
//                                 }),
//                               ],
//                             ),
//                           );
//                         }
//                       }
//                       return const SizedBox.shrink();
//                     },
//                   ),
//                   // Groceries list
//                   Expanded(
//                     child: groceries.isEmpty
//                         ? const Center(child: Text('Chưa có sản phẩm nào'))
//                         : ListView.builder(
//                             itemCount: groceries.length,
//                             itemBuilder: (context, index) {
//                               return GestureDetector(
//                                 child: GroceryCard(grocery: groceries[index]),
//                                 onTap: () {
//                                   context.push('/grocery-detail',
//                                       extra: groceries[index]);
//                                 },
//                               );
//                             },
//                           ),
//                   ),
//                 ],
//               ),
//             );
//           }

//           return const Center(child: Text('Không có dữ liệu'));
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           _showAddGroceryDialog(context);
//         },
//         backgroundColor: AppTheme.primaryGreen,
//         child: const Icon(Icons.add, color: Colors.white),
//       ),
//     );
//   }

//   void _showSearchDialog(BuildContext context) {
//     final searchController = TextEditingController();

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Tìm kiếm sản phẩm'),
//         content: TextField(
//           controller: searchController,
//           decoration: const InputDecoration(
//             labelText: 'Tên sản phẩm',
//             hintText: 'Nhập tên sản phẩm...',
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Hủy'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               if (searchController.text.isNotEmpty) {
//                 context.read<GroceriesBloc>().add(
//                       SearchGroceries(searchController.text),
//                     );
//               }
//               Navigator.pop(context);
//             },
//             child: const Text('Tìm kiếm'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showAddGroceryDialog(BuildContext context) {
//     // Thêm mới
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => const InputGroceryPage(),
//       ),
//     );
//   }
// }

// Cập nhật để sử dụng BLoC với chức năng chọn và xóa nhanh
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
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
  bool isSelectionMode = false;
  Set<int> selectedGroceryIds = <int>{};

  @override
  void initState() {
    super.initState();
    context.read<CategoriesBloc>().add(LoadCategories());
    context.read<GroceriesBloc>().add(const LoadGroceries());
  }

  void _toggleSelectionMode() {
    setState(() {
      isSelectionMode = !isSelectionMode;
      if (!isSelectionMode) {
        selectedGroceryIds.clear();
      }
    });
  }

  void _toggleGrocerySelection(int groceryId) {
    setState(() {
      if (selectedGroceryIds.contains(groceryId)) {
        selectedGroceryIds.remove(groceryId);
      } else {
        selectedGroceryIds.add(groceryId);
      }
    });
  }

  void _selectAllGroceries(List groceries) {
    setState(() {
      if (selectedGroceryIds.length == groceries.length) {
        selectedGroceryIds.clear();
      } else {
        selectedGroceryIds = groceries.map((g) => g.id as int).toSet();
      }
    });
  }

  void _deleteSelectedGroceries() {
    if (selectedGroceryIds.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text(
          'Bạn có chắc chắn muốn xóa ${selectedGroceryIds.length} sản phẩm đã chọn?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              // Thêm event xóa nhiều item vào BLoC
              context.read<GroceriesBloc>().add(
                    DeleteMultipleGroceries(selectedGroceryIds.toList()),
                  );
              setState(() {
                selectedGroceryIds.clear();
                isSelectionMode = false;
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isSelectionMode
            ? '${selectedGroceryIds.length} đã chọn'
            : 'Quản lý sản phẩm'),
        leading: isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: _toggleSelectionMode,
              )
            : null,
        actions: isSelectionMode
            ? [
                if (selectedGroceryIds.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: _deleteSelectedGroceries,
                  ),
              ]
            : [
                IconButton(
                  icon: const Icon(Icons.checklist),
                  onPressed: _toggleSelectionMode,
                ),
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

            return Column(
              children: [
                // Selection controls
                if (isSelectionMode && groceries.isNotEmpty)
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withOpacity(0.1),
                      border: Border(
                        bottom: BorderSide(
                          color: AppTheme.primaryGreen.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Checkbox(
                          value:
                              selectedGroceryIds.length == groceries.length &&
                                  groceries.isNotEmpty,
                          tristate: true,
                          onChanged: (_) => _selectAllGroceries(groceries),
                        ),
                        Text(
                          selectedGroceryIds.length == groceries.length &&
                                  groceries.isNotEmpty
                              ? 'Bỏ chọn tất cả'
                              : 'Chọn tất cả',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                        const Spacer(),
                        if (selectedGroceryIds.isNotEmpty)
                          TextButton.icon(
                            onPressed: _deleteSelectedGroceries,
                            icon: const Icon(Icons.delete, color: Colors.red),
                            label: const Text(
                              'Xóa đã chọn',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                      ],
                    ),
                  ),

                // Category tabs
                if (!isSelectionMode)
                  Padding(
                    padding: EdgeInsets.all(16.w),
                    child: BlocBuilder<CategoriesBloc, CategoriesState>(
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
                  ),

                // Groceries list
                Expanded(
                  child: groceries.isEmpty
                      ? const Center(child: Text('Chưa có sản phẩm nào'))
                      : ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          itemCount: groceries.length,
                          itemBuilder: (context, index) {
                            final grocery = groceries[index];
                            final isSelected =
                                selectedGroceryIds.contains(grocery.id);

                            return GestureDetector(
                              onTap: () {
                                if (isSelectionMode) {
                                  _toggleGrocerySelection(grocery.id);
                                } else {
                                  context.push('/grocery-detail',
                                      extra: grocery);
                                }
                              },
                              onLongPress: () {
                                if (!isSelectionMode) {
                                  _toggleSelectionMode();
                                  _toggleGrocerySelection(grocery.id);
                                }
                              },
                              child: Container(
                                margin: EdgeInsets.only(bottom: 8.h),
                                decoration: BoxDecoration(
                                  border: isSelected
                                      ? Border.all(
                                          color: AppTheme.primaryGreen,
                                          width: 2,
                                        )
                                      : null,
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Stack(
                                  children: [
                                    GroceryCard(grocery: grocery),
                                    if (isSelectionMode)
                                      Positioned(
                                        top: 8.h,
                                        right: 8.w,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.1),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Checkbox(
                                            value: isSelected,
                                            onChanged: (_) =>
                                                _toggleGrocerySelection(
                                                    grocery.id),
                                            activeColor: AppTheme.primaryGreen,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          }
          return const Center(child: Text('Không có dữ liệu'));
        },
      ),
      floatingActionButton: isSelectionMode
          ? null
          : FloatingActionButton(
              onPressed: () {
                _showAddGroceryDialog(context);
              },
              backgroundColor: AppTheme.primaryGreen,
              child: const Icon(Icons.add, color: Colors.white),
            ),
    );
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
