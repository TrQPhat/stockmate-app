// Cập nhật để sử dụng BLoC
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
                              return GestureDetector(
                                child: GroceryCard(grocery: groceries[index]),
                                onTap: () {
                                  context.push('/grocery-detail',
                                      extra: groceries[index]);
                                },
                              );
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
