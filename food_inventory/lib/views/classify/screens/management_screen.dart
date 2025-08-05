import 'package:flutter/material.dart';
import 'package:stock_mate/core/theme/app_theme.dart';
import 'package:stock_mate/models/category.dart';
import 'package:stock_mate/models/position.dart';
import '../widgets/category_form.dart';
import '../widgets/position_form.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stock_mate/bloc/category/categories_bloc.dart';
import 'package:stock_mate/bloc/position/position_bloc.dart';

class ManagementClassifyScreen extends StatefulWidget {
  const ManagementClassifyScreen({super.key});

  @override
  State<ManagementClassifyScreen> createState() =>
      _ManagementClassifyScreenState();
}

class _ManagementClassifyScreenState extends State<ManagementClassifyScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Load data when screen initializes
    context.read<CategoriesBloc>().add(LoadCategories());
    context.read<PositionBloc>().add(LoadPosition());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _addCategory() {
    showDialog(
      context: context,
      builder: (context) => CategoryForm(
        onSave: (category) {
          context.read<CategoriesBloc>().add(AddCategory(category));
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _editCategory(Category category) {
    showDialog(
      context: context,
      builder: (context) => CategoryForm(
        category: category,
        onSave: (updatedCategory) {
          if (updatedCategory.id == -1) return;
          context.read<CategoriesBloc>().add(UpdateCategory(updatedCategory));
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _deleteCategory(Category category) {
    if (category.id == -1) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa danh mục "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<CategoriesBloc>().add(DeleteCategory(category.id));
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  void _addPosition() {
    showDialog(
      context: context,
      builder: (context) => PositionForm(
        onSave: (position) {
          context.read<PositionBloc>().add(AddPosition(position));
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _editPosition(Position position) {
    showDialog(
      context: context,
      builder: (context) => PositionForm(
        position: position,
        onSave: (updatedPosition) {
          if (updatedPosition.id == -1) return;
          context.read<PositionBloc>().add(UpdatePosition(updatedPosition));
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _deletePosition(Position position) {
    if (position.id == -1) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa vị trí "${position.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<PositionBloc>().add(DeletePosition(position.id));
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  // void _showSuccessSnackBar(String message) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text(message),
  //       backgroundColor: AppTheme.successGreen,
  //       behavior: SnackBarBehavior.floating,
  //     ),
  //   );
  // }

  // void _showErrorSnackBar(String message) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text(message),
  //       backgroundColor: AppTheme.errorRed,
  //       behavior: SnackBarBehavior.floating,
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Quản lý danh mục & vị trí'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(
              icon: Icon(Icons.category),
              text: 'Danh mục',
            ),
            Tab(
              icon: Icon(Icons.location_on),
              text: 'Vị trí',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCategoriesTab(),
          _buildPositionsTab(),
        ],
      ),
    );
  }

  Widget _buildCategoriesTab() {
    return BlocBuilder<CategoriesBloc, CategoriesState>(
      builder: (context, state) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Danh mục thực phẩm${state is CategoriesLoaded ? ' (${state.categories.length})' : ''}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: state is CategoriesLoaded ? _addCategory : null,
                    icon: const Icon(Icons.add),
                    label: const Text('Thêm'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _buildCategoriesContent(state),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategoriesContent(CategoriesState state) {
    if (state is CategoriesInitial) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppTheme.primaryGreen,
        ),
      );
    } else if (state is CategoriesLoaded) {
      if (state.categories.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.category_outlined,
                size: 64,
                color: AppTheme.textLight,
              ),
              SizedBox(height: 16),
              Text(
                'Chưa có danh mục nào',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () async {
          context.read<CategoriesBloc>().add(LoadCategories());
        },
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: state.categories.length,
          itemBuilder: (context, index) {
            final category = state.categories[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppTheme.accentGreen,
                  child: Icon(
                    Icons.category,
                    color: Colors.white,
                  ),
                ),
                title: Text(
                  category.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (category.description != null)
                      Text(
                        category.description!,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                  ],
                ),
                trailing: PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Sửa'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete,
                              size: 20, color: AppTheme.errorRed),
                          SizedBox(width: 8),
                          Text('Xóa',
                              style: TextStyle(color: AppTheme.errorRed)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      _editCategory(category);
                    } else if (value == 'delete') {
                      _deleteCategory(category);
                    }
                  },
                ),
              ),
            );
          },
        ),
      );
    } else if (state is CategoriesError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.errorRed,
            ),
            const SizedBox(height: 16),
            Text(
              'Lỗi: ${state.message}',
              style: const TextStyle(
                fontSize: 16,
                color: AppTheme.errorRed,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<CategoriesBloc>().add(LoadCategories());
              },
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildPositionsTab() {
    return BlocBuilder<PositionBloc, PositionState>(
      builder: (context, state) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Vị trí lưu trữ${state is PositionLoaded ? ' (${state.positions.length})' : ''}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: state is PositionLoaded ? _addPosition : null,
                    icon: const Icon(Icons.add),
                    label: const Text('Thêm'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _buildPositionsContent(state),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPositionsContent(PositionState state) {
    if (state is PositionInitial) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppTheme.primaryGreen,
        ),
      );
    } else if (state is PositionLoaded) {
      if (state.positions.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 64,
                color: AppTheme.textLight,
              ),
              SizedBox(height: 16),
              Text(
                'Chưa có vị trí nào',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () async {
          context.read<PositionBloc>().add(LoadPosition());
        },
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: state.positions.length,
          itemBuilder: (context, index) {
            final position = state.positions[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppTheme.primaryOrange,
                  child: Icon(
                    Icons.location_on,
                    color: Colors.white,
                  ),
                ),
                title: Text(
                  position.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                subtitle: position.description != null
                    ? Text(
                        position.description!,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                        ),
                      )
                    : null,
                trailing: PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Sửa'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete,
                              size: 20, color: AppTheme.errorRed),
                          SizedBox(width: 8),
                          Text('Xóa',
                              style: TextStyle(color: AppTheme.errorRed)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      _editPosition(position);
                    } else if (value == 'delete') {
                      _deletePosition(position);
                    }
                  },
                ),
              ),
            );
          },
        ),
      );
    } else if (state is PositionError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.errorRed,
            ),
            const SizedBox(height: 16),
            Text(
              'Lỗi: ${state.message}',
              style: const TextStyle(
                fontSize: 16,
                color: AppTheme.errorRed,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<PositionBloc>().add(LoadPosition());
              },
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
