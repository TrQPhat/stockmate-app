// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
// import 'package:intl/intl.dart';
// import 'package:stock_mate/core/theme/app_theme.dart';
// import 'package:stock_mate/bloc/shopping-list/shopping_list_bloc.dart';
// import 'package:stock_mate/models/shopping_list.dart';
// import 'package:stock_mate/views/home/widgets/custom_app_bar.dart';
// import 'package:stock_mate/views/home/widgets/error_widget.dart';
// import 'package:stock_mate/views/home/widgets/loading_widget.dart';

// class ShoppingPage extends StatefulWidget {
//   const ShoppingPage({super.key});

//   @override
//   State<ShoppingPage> createState() => _ShoppingPageState();
// }

// class _ShoppingPageState extends State<ShoppingPage> {
//   @override
//   void initState() {
//     super.initState();
//     final currentState = context.read<ShoppingListBloc>().state;
//     if (currentState is! ShoppingListsLoaded || (currentState.lists.isEmpty)) {
//       context.read<ShoppingListBloc>().add(LoadShoppingLists());
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: const CustomAppBar(title: 'Danh sách mua sắm'),
//       body: BlocConsumer<ShoppingListBloc, ShoppingListState>(
//         listener: (context, state) {
//           if (state is ShoppingError && state is! ShoppingListsLoaded) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                   content: Text(state.message), backgroundColor: Colors.red),
//             );
//           }
//         },
//         buildWhen: (previous, current) {
//           return current is ShoppingListsLoaded ||
//               current is ShoppingLoading ||
//               current is ShoppingInitial ||
//               current is ShoppingError;
//         },
//         builder: (context, state) {
//           if (state is ShoppingLoading) {
//             return const LoadingWidget(message: 'Đang tải danh sách...');
//           }
//           if (state is ShoppingError) {
//             return CustomErrorWidget(
//               message: state.message,
//               onRetry: () =>
//                   context.read<ShoppingListBloc>().add(LoadShoppingLists()),
//             );
//           }
//           if (state is ShoppingListsLoaded) {
//             if (state.lists.isEmpty) {
//               return const Center(
//                   child: Text('Chưa có danh sách nào. Hãy tạo một cái!'));
//             }
//             return Column(
//               children: [
//                 Expanded(
//                     child: RefreshIndicator(
//                   onRefresh: () async {
//                     context.read<ShoppingListBloc>().add(LoadShoppingLists());
//                   },
//                   child: _buildListsView(state.lists),
//                 )),
//               ],
//             );
//           }
//           return const SizedBox.shrink();
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => _showCreateListDialog(context),
//         backgroundColor: AppTheme.primaryGreen,
//         child: const Icon(Icons.add, color: Colors.white),
//       ),
//     );
//   }

//   Widget _buildListsView(List<ShoppingList> lists) {
//     return ListView.separated(
//       padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
//       physics: const BouncingScrollPhysics(),
//       itemCount: lists.length,
//       separatorBuilder: (context, index) => const Divider(
//         height: 1,
//         thickness: 0.5,
//         color: Colors.grey,
//       ),
//       itemBuilder: (context, index) {
//         final list = lists[index];
//         return Dismissible(
//           key: Key(list.id.toString()), // Sử dụng id làm key duy nhất
//           direction: DismissDirection
//               .endToStart, // Chỉ cho phép vuốt từ phải sang trái
//           background: _buildSwipeBackground(), // Widget nền khi vuốt
//           onDismissed: (direction) {
//             // Xử lý khi vuốt hoàn tất
//             _handleSwipeDelete(list);
//           },
//           child: InkWell(
//             borderRadius: BorderRadius.circular(12),
//             onTap: () => context.go('/shopping/${list.id}'),
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(12),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.grey.withOpacity(0.1),
//                     blurRadius: 6,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               padding: const EdgeInsets.all(12),
//               child: Row(
//                 children: [
//                   // Giữ nguyên phần nội dung như cũ
//                   Container(
//                       width: 48,
//                       height: 48,
//                       decoration: BoxDecoration(
//                         color: AppTheme.primaryGreen.withOpacity(0.1),
//                         shape: BoxShape.circle,
//                       ),
//                       child: Checkbox(
//                         value:
//                             false, // giá trị mặc định, bạn có thể truyền từ biến trạng thái
//                         onChanged: (bool? value) {
//                           if (value == true) {
//                             context
//                                 .read<ShoppingListBloc>()
//                                 .add(CompleteShoppingListEvent(list.id));
//                           }
//                           // Không cần xử lý uncheck nếu chỉ dùng một chiều
//                         },
//                         activeColor: AppTheme.primaryGreen,
//                       )),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           list.name,
//                           style: const TextStyle(
//                             fontWeight: FontWeight.w600,
//                             fontSize: 16,
//                           ),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           list.purpose,
//                           style: TextStyle(
//                             color: Colors.grey[600],
//                             fontSize: 14,
//                           ),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                         const SizedBox(height: 4),
//                         Row(
//                           children: [
//                             Icon(
//                               Icons.calendar_today,
//                               size: 14,
//                               color: Colors.grey[500],
//                             ),
//                             const SizedBox(width: 4),
//                             Text(
//                               list.purchaseDate != null
//                                   ? DateFormat('dd/MM/yyyy')
//                                       .format(list.purchaseDate!)
//                                   : 'Chưa đặt ngày',
//                               style: TextStyle(
//                                 color: list.purchaseDate != null
//                                     ? Colors.grey[700]
//                                     : Colors.grey[400],
//                                 fontSize: 13,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                   Icon(
//                     Icons.chevron_right,
//                     color: Colors.grey[400],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

// // Widget nền khi vuốt
//   Widget _buildSwipeBackground() {
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 8),
//       decoration: BoxDecoration(
//         color: Colors.red[400],
//         borderRadius: BorderRadius.circular(12),
//       ),
//       alignment: Alignment.centerRight,
//       padding: const EdgeInsets.only(right: 20),
//       child: const Icon(
//         Icons.delete,
//         color: Colors.white,
//         size: 24,
//       ),
//     );
//   }

//   Future<void> _handleSwipeDelete(ShoppingList list) async {
//     final context = this.context;
//     final bloc = context.read<ShoppingListBloc>();

//     // Hiển thị dialog xác nhận
//     final confirm = await showDialog<bool>(
//       context: context,
//       barrierDismissible: false, // Ngăn tap outside để đóng dialog
//       builder: (context) => AlertDialog(
//         title: const Text('Xác nhận xóa'),
//         content: Text('Bạn chắc chắn muốn xóa "${list.name}"?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context, true),
//             child: const Text('Xóa', style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );

//     // Nếu người dùng xác nhận xóa
//     if (confirm == true) {
//       bloc.add(DeleteShoppingList(list.id));
//     }
//   }

//   void _showCreateListDialog(BuildContext context) {
//     final nameController = TextEditingController();
//     final purposeController = TextEditingController();
//     DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
//     showDialog(
//       context: context,
//       builder: (dialogContext) {
//         return StatefulBuilder(
//           builder: (context, setDialogState) {
//             return AlertDialog(
//               title: const Text('Tạo danh sách mới'),
//               content: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   TextField(
//                     controller: nameController,
//                     decoration:
//                         const InputDecoration(labelText: 'Tên danh sách'),
//                     autofocus: true,
//                   ),
//                   const SizedBox(height: 16),
//                   TextField(
//                     controller: purposeController,
//                     decoration: const InputDecoration(labelText: 'Mục đích'),
//                   ),
//                   const SizedBox(height: 16),
//                   buildPurchaseDatePicker(
//                     selectedDate: selectedDate,
//                     onDateSelected: (date) {
//                       setState(() {
//                         selectedDate = date;
//                       });
//                     },
//                   )
//                 ],
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.pop(dialogContext),
//                   child: const Text('Hủy'),
//                 ),
//                 ElevatedButton(
//                   onPressed: () {
//                     if (nameController.text.trim().isNotEmpty) {
//                       context.read<ShoppingListBloc>().add(
//                             CreateShoppingList(nameController.text.trim(),
//                                 purposeController.text.trim(), selectedDate),
//                           );
//                       Navigator.pop(dialogContext);
//                     }
//                   },
//                   child: const Text('Tạo'),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }

//   Widget buildPurchaseDatePicker({
//     required DateTime selectedDate,
//     required Function(DateTime) onDateSelected,
//   }) {
//     return Builder(
//       builder: (context) {
//         return InkWell(
//           onTap: () async {
//             final pickedDate = await showDatePicker(
//               context: context,
//               initialDate: selectedDate,
//               firstDate: DateTime(2020),
//               lastDate: DateTime(2030),
//             );
//             if (pickedDate != null) {
//               onDateSelected(pickedDate);
//             }
//           },
//           child: InputDecorator(
//             decoration: InputDecoration(
//               labelText: 'Ngày mua',
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               contentPadding: const EdgeInsets.symmetric(
//                 vertical: 14,
//                 horizontal: 16,
//               ),
//               suffixIcon: const Icon(Icons.calendar_today),
//             ),
//             child: Text(
//               DateFormat('dd/MM/yyyy').format(selectedDate),
//               style: const TextStyle(
//                 fontSize: 16,
//                 color: Colors.black87,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

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
        backgroundColor: AppTheme.primaryOrange,
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
      color: AppTheme.primaryOrange,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        itemCount: lists.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) => ShoppingListItem(
          shoppingList: lists[index],
          onTap: () => context.go('/shopping/${lists[index].id}'),
          onDelete: () => _handleDelete(lists[index]),
          onComplete: () => _handleComplete(lists[index]),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () => _showCreateListDialog(),
      backgroundColor: AppTheme.primaryOrange,
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
