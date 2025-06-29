import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:stock_mate/core/theme/app_theme.dart';
import 'package:stock_mate/bloc/shopping-list/shopping_list_bloc.dart';
import 'package:stock_mate/models/shopping_list.dart';
import 'package:stock_mate/views/home/widgets/custom_app_bar.dart';
import 'package:stock_mate/views/home/widgets/error_widget.dart';
import 'package:stock_mate/views/home/widgets/loading_widget.dart';
import 'package:stock_mate/views/shopping/widgets/list/shopping_list_item.dart';
import 'package:stock_mate/views/shopping/widgets/list/create_list_dialog.dart';
import 'package:stock_mate/views/shopping/widgets/list/empty_state_widget.dart';

class ShoppingPage extends StatefulWidget {
  const ShoppingPage({super.key});

  @override
  State<ShoppingPage> createState() => _ShoppingPageState();
}

class _ShoppingPageState extends State<ShoppingPage> {
  @override
  void initState() {
    super.initState();
    _loadShoppingListsIfNeeded();
  }

  void _loadShoppingListsIfNeeded() {
    final currentState = context.read<ShoppingListBloc>().state;
    if (currentState is! ShoppingListsLoaded || currentState.lists.isEmpty) {
      context.read<ShoppingListBloc>().add(LoadShoppingLists());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: const CustomAppBar(
        title: '🛒 Danh sách thực phẩm',
        backgroundColor: AppTheme.primaryGreen,
      ),
      body: BlocConsumer<ShoppingListBloc, ShoppingListState>(
        listener: _handleStateChanges,
        buildWhen: _shouldRebuild,
        builder: _buildBody,
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  void _handleStateChanges(BuildContext context, ShoppingListState state) {
    if (state is ShoppingError && state is! ShoppingListsLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(state.message)),
            ],
          ),
          backgroundColor: AppTheme.errorRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  bool _shouldRebuild(ShoppingListState previous, ShoppingListState current) {
    return current is ShoppingListsLoaded ||
        current is ShoppingLoading ||
        current is ShoppingInitial ||
        current is ShoppingError;
  }

  Widget _buildBody(BuildContext context, ShoppingListState state) {
    if (state is ShoppingLoading) {
      return const LoadingWidget(
        message: '🥕 Đang tải danh sách thực phẩm...',
        // color: AppTheme.primaryOrange,
      );
    }

    if (state is ShoppingError) {
      return CustomErrorWidget(
        message: state.message,
        //   icon: Icons.restaurant_menu,
        onRetry: () =>
            context.read<ShoppingListBloc>().add(LoadShoppingLists()),
      );
    }

    if (state is ShoppingListsLoaded) {
      return state.lists.isEmpty
          ? const EmptyStateWidget()
          : _buildShoppingListsView(state.lists);
    }

    return const SizedBox.shrink();
  }

  Widget _buildShoppingListsView(List<ShoppingList> lists) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: AppTheme.primaryGreen,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        itemCount: lists.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) => ShoppingListItem(
          shoppingList: lists[index],
          onTap: () => context.go('/shopping/${lists[index].id}'),
          onDelete: () => _handleDelete(lists[index]),
          onComplete: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Xác nhận hoàn thành'),
                content: Text(
                    'Bạn có chắc chắn danh sách "${lists[index].name}" đã hoàn thành?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Hủy'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                    ),
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Xác nhận',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );

            if (confirmed == true && mounted) {
              _handleComplete(lists[index]);
            }
          },
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () => _showCreateListDialog(),
      backgroundColor: AppTheme.lightGreen,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.add_shopping_cart),
      label: const Text('Thêm danh sách'),
    );
  }

  Future<void> _handleRefresh() async {
    context.read<ShoppingListBloc>().add(LoadShoppingLists());
  }

  void _handleDelete(ShoppingList list) {
    context.read<ShoppingListBloc>().add(DeleteShoppingList(list.id));
  }

  void _handleComplete(ShoppingList list) {
    context.read<ShoppingListBloc>().add(CompleteShoppingListEvent(list.id));
  }

  void _showCreateListDialog() {
    showDialog(
      context: context,
      builder: (context) => CreateListDialog(
        onCreateList: (name, purpose, date) {
          context.read<ShoppingListBloc>().add(
                CreateShoppingList(name, purpose, date),
              );
        },
      ),
    );
  }
}
