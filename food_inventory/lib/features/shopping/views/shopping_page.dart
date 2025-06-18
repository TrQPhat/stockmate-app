import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:stock_mate/core/theme/app_theme.dart';
import 'package:stock_mate/features/home/widgets/custom_app_bar.dart';
import 'package:stock_mate/features/home/widgets/error_widget.dart'; // THÊM IMPORT
import 'package:stock_mate/features/home/widgets/loading_widget.dart';
import 'package:stock_mate/features/shopping/bloc/shopping_bloc.dart';
import 'package:stock_mate/features/shopping/models/shopping_list.dart';

class ShoppingListPage extends StatefulWidget {
  const ShoppingListPage({super.key});

  @override
  State<ShoppingListPage> createState() => _ShoppingListPageState();
}

class _ShoppingListPageState extends State<ShoppingListPage> {
  @override
  void initState() {
    super.initState();
    final currentState = context.read<ShoppingBloc>().state;
    if (currentState is! ShoppingListsLoaded ||
        (currentState.lists.isEmpty && !currentState.isLoading)) {
      context.read<ShoppingBloc>().add(LoadShoppingLists());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Danh sách mua sắm'),
      body: BlocConsumer<ShoppingBloc, ShoppingState>(
        listener: (context, state) {
          if (state is ShoppingError && state is! ShoppingListsLoaded) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        buildWhen: (previous, current) {
          return current is ShoppingListsLoaded ||
              current is ShoppingLoading ||
              current is ShoppingInitial ||
              current is ShoppingError;
        },
        builder: (context, state) {
          if (state is ShoppingLoading) {
            return const LoadingWidget(message: 'Đang tải danh sách...');
          }
          if (state is ShoppingError) {
            return CustomErrorWidget(
              message: state.message,
              onRetry: () =>
                  context.read<ShoppingBloc>().add(LoadShoppingLists()),
            );
          }
          if (state is ShoppingListsLoaded) {
            if (state.lists.isEmpty && !state.isLoading) {
              return const Center(
                  child: Text('Chưa có danh sách nào. Hãy tạo một cái!'));
            }
            return Column(
              children: [
                if (state.isLoading) const LinearProgressIndicator(),
                Expanded(
                    child: RefreshIndicator(
                  onRefresh: () async {
                    context.read<ShoppingBloc>().add(LoadShoppingLists());
                  },
                  child: _buildListsView(state.lists),
                )),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateListDialog(context),
        backgroundColor: AppTheme.primaryGreen,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildListsView(List<ShoppingList> lists) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: lists.length,
      itemBuilder: (context, index) {
        final list = lists[index];
        final shoppingBloc = context.read<ShoppingBloc>();
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
                child: const Icon(Icons.list_alt, color: AppTheme.primaryGreen),
              ),
              title: Text(list.name,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                'Ngày mua: ${list.purchaseDate != null ? DateFormat('dd/MM/yyyy').format(list.purchaseDate!) : 'N/A'}\nTổng tiền: ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(list.totalCost)}',
              ),
              isThreeLine: true,
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () async {
                await context.push('/shopping/${list.id}');
                shoppingBloc.add(LoadShoppingLists());
              }),
        );
      },
    );
  }

  void _showCreateListDialog(BuildContext context) {
    final nameController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Tạo danh sách mới'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration:
                        const InputDecoration(labelText: 'Tên danh sách'),
                    autofocus: true,
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: Text(
                        'Ngày mua: ${DateFormat('dd/MM/yyyy').format(selectedDate)}'),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (pickedDate != null) {
                        setDialogState(() {
                          selectedDate = pickedDate;
                        });
                      }
                    },
                  )
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.trim().isNotEmpty) {
                      context.read<ShoppingBloc>().add(
                            CreateShoppingList(
                                nameController.text.trim(), selectedDate),
                          );
                      Navigator.pop(dialogContext);
                    }
                  },
                  child: const Text('Tạo'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
