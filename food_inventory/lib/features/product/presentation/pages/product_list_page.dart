import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../domain/entities/product.dart';
import '../bloc/product_bloc.dart';
import '../widgets/product_card.dart';

class ProductListPage extends StatefulWidget {
  final String storageId;

  const ProductListPage({
    super.key,
    required this.storageId,
  });

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  late ProductBloc _productBloc;
  String _selectedCategory = 'Tất cả';
  
  final List<String> _categories = [
    'Tất cả',
    'Thịt',
    'Rau củ',
    'Trái cây',
    'Gia vị',
    'Đồ khô',
    'Đồ uống',
    'Khác',
  ];

  @override
  void initState() {
    super.initState();
    _productBloc = getIt<ProductBloc>();
    _productBloc.add(ProductLoadRequested(widget.storageId));
  }

  @override
  void dispose() {
    _productBloc.close();
    super.dispose();
  }

  List<Product> _filterProducts(List<Product> products) {
    if (_selectedCategory == 'Tất cả') {
      return products;
    }
    return products.where((product) => product.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Danh sách sản phẩm',
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implement search
            },
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'sort_name',
                child: Text('Sắp xếp theo tên'),
              ),
              const PopupMenuItem(
                value: 'sort_date',
                child: Text('Sắp xếp theo ngày'),
              ),
              const PopupMenuItem(
                value: 'sort_expire',
                child: Text('Sắp xếp theo hạn sử dụng'),
              ),
            ],
          ),
        ],
      ),
      body: BlocProvider.value(
        value: _productBloc,
        child: Column(
          children: [
            // Category Filter
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = category == _selectedCategory;
                  
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            
            // Product List
            Expanded(
              child: BlocBuilder<ProductBloc, ProductState>(
                builder: (context, state) {
                  if (state is ProductLoading) {
                    return const LoadingWidget(message: 'Đang tải sản phẩm...');
                  }

                  if (state is ProductError) {
                    return CustomErrorWidget(
                      message: state.message,
                      onRetry: () {
                        _productBloc.add(ProductLoadRequested(widget.storageId));
                      },
                    );
                  }

                  if (state is ProductLoaded) {
                    final filteredProducts = _filterProducts(state.products);
                    
                    if (filteredProducts.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Không có sản phẩm nào',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Thêm sản phẩm mới vào kho',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
                        return ProductCard(
                          product: product,
                          onTap: () {
                            // Navigate to product detail
                          },
                        );
                      },
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/storage/${widget.storageId}/add-product'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
