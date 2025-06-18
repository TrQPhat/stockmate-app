import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:stock_mate/core/theme/app_theme.dart';
import 'package:stock_mate/features/home/widgets/custom_app_bar.dart';
import 'package:stock_mate/features/home/widgets/error_widget.dart';
import 'package:stock_mate/features/home/widgets/loading_widget.dart';
import 'package:stock_mate/features/shopping/bloc/shopping_bloc.dart';
import 'package:stock_mate/features/shopping/models/shopping_list.dart';
import 'package:stock_mate/features/shopping/models/shopping_list_item.dart';

class ShoppingListDetailPage extends StatefulWidget {
  final String listId;
  const ShoppingListDetailPage({super.key, required this.listId});

  @override
  State<ShoppingListDetailPage> createState() => _ShoppingListDetailPageState();
}

class _ShoppingListDetailPageState extends State<ShoppingListDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<ShoppingBloc>().add(LoadShoppingListDetails(widget.listId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ShoppingBloc, ShoppingState>(
        listener: (context, state) {
      if (state is ShoppingError && state is! ShoppingListDetailsLoaded) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.message), backgroundColor: Colors.red),
        );
      }
      if (state is ShoppingOperationSuccess) {
        context.pop();
        context.read<ShoppingBloc>().add(LoadShoppingLists());
      }
    }, builder: (context, state) {
      // Trường hợp 1: Đã tải dữ liệu thành công
      if (state is ShoppingListDetailsLoaded) {
        final list = state.listDetails;
        return Scaffold(
          appBar: CustomAppBar(
            title: 'Chi tiết danh sách',
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _showEditListDialog(context, list),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () =>
                    _showDeleteListConfirmDialog(context, widget.listId),
              ),
            ],
          ),
          body: Column(
            children: [
              if (state.isLoading) const LinearProgressIndicator(),
              Expanded(child: _buildDetailsView(list)),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddItemDialog(context, widget.listId),
            backgroundColor: AppTheme.primaryGreen,
            child: const Icon(Icons.add_shopping_cart, color: Colors.white),
          ),
        );
      }

      // Các trạng thái loading và lỗi ban đầu
      return Scaffold(
        appBar: const CustomAppBar(title: 'Chi tiết danh sách'),
        body: () {
          if (state is ShoppingLoading) {
            return const LoadingWidget(message: 'Đang tải chi tiết...');
          }
          if (state is ShoppingError) {
            return CustomErrorWidget(
                message: state.message,
                onRetry: () {
                  context
                      .read<ShoppingBloc>()
                      .add(LoadShoppingListDetails(widget.listId));
                });
          }
          // Fallback an toàn
          return const LoadingWidget(message: 'Đang chuẩn bị...');
        }(),
      );
    });
  }

  Widget _buildDetailsView(ShoppingList list) {
    final purchasedItems =
        list.items?.where((i) => i.isPurchased).toList() ?? [];
    final pendingItems =
        list.items?.where((i) => !i.isPurchased).toList() ?? [];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            color: AppTheme.primaryGreen.withOpacity(0.1),
            child: ListTile(
              title: Text(list.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 20)),
              subtitle: Text(
                  'Tổng tiền đã mua: ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(list.totalCost)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w500, fontSize: 16)),
              trailing: const Icon(Icons.monetization_on,
                  color: AppTheme.primaryGreen),
            ),
          ),
        ),
        Expanded(
          child: list.items == null || list.items!.isEmpty
              ? const Center(
                  child: Text('Chưa có sản phẩm nào trong danh sách.'))
              : ListView(
                  children: [
                    if (pendingItems.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Text('Cần mua',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      ...pendingItems.map((item) => _buildItemTile(item)),
                    ],
                    if (purchasedItems.isNotEmpty) ...[
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                        child: Text('Đã mua',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[600])),
                      ),
                      ...purchasedItems.map((item) => _buildItemTile(item)),
                    ],
                  ],
                ),
        )
      ],
    );
  }

  Widget _buildItemTile(ShoppingListItem item) {
    return ListTile(
      leading: Checkbox(
        value: item.isPurchased,
        onChanged: (bool? value) {
          if (value != null) {
            context.read<ShoppingBloc>().add(
                  UpdateItemInList(
                      widget.listId, item.copyWith(isPurchased: value)),
                );
          }
        },
        activeColor: AppTheme.primaryGreen,
      ),
      title: Text(
        item.itemName,
        style: TextStyle(
          decoration: item.isPurchased ? TextDecoration.lineThrough : null,
          color: item.isPurchased ? Colors.grey : null,
        ),
      ),
      subtitle: Text(
        'SL: ${item.quantity} ${item.unit ?? ''} - Giá: ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(item.price)}',
        style: TextStyle(
          decoration: item.isPurchased ? TextDecoration.lineThrough : null,
        ),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete, color: Colors.redAccent),
        onPressed: () => _showDeleteItemConfirmDialog(context, item),
      ),
    );
  }

  void _showAddItemDialog(BuildContext context, String listId) {
    final nameController = TextEditingController();
    final quantityController = TextEditingController(text: '1');
    final unitController = TextEditingController();
    final priceController = TextEditingController(text: '0');

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Thêm sản phẩm'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: nameController,
                    decoration:
                        const InputDecoration(labelText: 'Tên sản phẩm'),
                    autofocus: true),
                TextField(
                    controller: quantityController,
                    decoration: const InputDecoration(labelText: 'Số lượng'),
                    keyboardType: TextInputType.number),
                TextField(
                    controller: unitController,
                    decoration: const InputDecoration(
                        labelText: 'Đơn vị (vd: kg, hộp)')),
                TextField(
                    controller: priceController,
                    decoration: const InputDecoration(labelText: 'Giá tiền'),
                    keyboardType: TextInputType.number),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Hủy')),
            ElevatedButton(
              onPressed: () {
                final itemName = nameController.text.trim();
                final quantity = int.tryParse(quantityController.text) ?? 1;
                final price = double.tryParse(priceController.text) ?? 0.0;
                if (itemName.isNotEmpty) {
                  context.read<ShoppingBloc>().add(AddItemToList(
                        listId: listId,
                        itemName: itemName,
                        quantity: quantity,
                        unit: unitController.text.trim(),
                        price: price,
                      ));
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('Thêm'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteItemConfirmDialog(
      BuildContext context, ShoppingListItem item) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa "${item.itemName}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              context
                  .read<ShoppingBloc>()
                  .add(DeleteItemFromList(widget.listId, item.id));
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeleteListConfirmDialog(BuildContext context, String listId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xóa danh sách'),
        content: const Text(
            'Bạn có chắc chắn muốn xóa toàn bộ danh sách này không? Thao tác này không thể hoàn tác.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              context.read<ShoppingBloc>().add(DeleteShoppingList(listId));
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditListDialog(BuildContext context, ShoppingList currentList) {
    final nameController = TextEditingController(text: currentList.name);
    DateTime selectedDate = currentList.purchaseDate ?? DateTime.now();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Chỉnh sửa danh sách'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration:
                          const InputDecoration(labelText: 'Tên danh sách'),
                      autofocus: true,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Tên danh sách không được để trống';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
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
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      context.read<ShoppingBloc>().add(
                            UpdateShoppingList(
                              listId: currentList.id,
                              newName: nameController.text.trim(),
                              newPurchaseDate: selectedDate,
                            ),
                          );
                      Navigator.pop(dialogContext);
                    }
                  },
                  child: const Text('Lưu'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
