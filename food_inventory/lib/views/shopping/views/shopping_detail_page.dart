import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:stock_mate/bloc/category/categories_bloc.dart';
import 'package:stock_mate/bloc/shopping-item/shopping_item_bloc.dart';
import 'package:stock_mate/models/category.dart';
import 'package:stock_mate/models/shopping_list.dart';
import 'package:stock_mate/models/shopping_item.dart';
import 'package:stock_mate/views/home/widgets/error_widget.dart';
import 'package:stock_mate/views/home/widgets/loading_widget.dart';

class ShoppingDetailPage extends StatefulWidget {
  final int listId;
  const ShoppingDetailPage({super.key, required this.listId});

  @override
  State<ShoppingDetailPage> createState() => _ShoppingDetailPageState();
}

class _ShoppingDetailPageState extends State<ShoppingDetailPage> {
  // Food-themed color palette
  static const Color primaryGreen = Color(0xFF2E7D32); // Dark green
  static const Color lightGreen = Color(0xFF4CAF50); // Medium green
  static const Color accentGreen = Color(0xFF81C784); // Light green
  static const Color backgroundGreen = Color(0xFFE8F5E8); // Very light green
  static const Color freshGreen = Color(0xFF66BB6A); // Fresh green
  static const Color leafGreen = Color(0xFF388E3C); // Leaf green
  bool isDisabled = false;

  @override
  void initState() {
    super.initState();
    context.read<CategoriesBloc>().add(LoadCategories());
    context.read<ShoppingItemBloc>().add(LoadShoppingList(widget.listId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ShoppingItemBloc, ShoppingItemState>(
      listener: (context, state) {
        if (state is ShoppingError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        } else if (state is ShoppingOperationSuccess) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pop();
          });
        }

        // Bạn có thể xử lý thêm các trạng thái như chuyển trang ở đây
      },
      child: BlocBuilder<ShoppingItemBloc, ShoppingItemState>(
        builder: (context, state) {
          return switch (state) {
            ShoppingLoading() => _buildLoadingView(),
            ShoppingError() => _buildErrorView(state.message),
            ShoppingListLoaded() => _buildLoadedView(state.listDetails),
            _ => _buildFallbackView(),
          };
        },
      ),
    );
  }

  Widget _buildLoadingView() {
    return Scaffold(
      backgroundColor: backgroundGreen,
      appBar: _buildCustomAppBar('Danh sách thực phẩm'),
      body: const LoadingWidget(message: 'Đang tải danh sách...'),
    );
  }

  Widget _buildErrorView(String message) {
    return Scaffold(
      backgroundColor: backgroundGreen,
      appBar: _buildCustomAppBar('Danh sách thực phẩm'),
      body: CustomErrorWidget(
        message: message,
        onRetry: () => context
            .read<ShoppingItemBloc>()
            .add(LoadShoppingList(widget.listId)),
      ),
    );
  }

  Widget _buildFallbackView() {
    return Scaffold(
      backgroundColor: backgroundGreen,
      appBar: _buildCustomAppBar('Danh sách thực phẩm'),
      body: const Center(
        child: CircularProgressIndicator(color: primaryGreen),
      ),
    );
  }

  PreferredSizeWidget _buildCustomAppBar(String title, [ShoppingList? list]) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: primaryGreen,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      actions: list != null
          ? [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => _showEditListDialog(context, list),
                tooltip: 'Chỉnh sửa danh sách',
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () =>
                    _showDeleteListConfirmDialog(context, widget.listId),
                tooltip: 'Xóa danh sách',
              ),
            ]
          : null,
    );
  }

  Widget _buildLoadedView(ShoppingList list) {
    return Scaffold(
      backgroundColor: backgroundGreen,
      appBar: _buildCustomAppBar('Danh sách thực phẩm', list),
      body: _buildDetailsView(list),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () => _showAddItemDialog(context, widget.listId),
      backgroundColor: lightGreen,
      foregroundColor: Colors.white,
      elevation: 4,
      child: const Icon(Icons.add_shopping_cart),
    );
  }

  Widget _buildDetailsView(ShoppingList list) {
    final purchasedItems =
        list.items?.where((i) => i.isPurchased).toList() ?? [];
    final pendingItems =
        list.items?.where((i) => !i.isPurchased).toList() ?? [];

    return Column(
      children: [
        _buildSummaryCard(list, purchasedItems.length, pendingItems.length),
        Expanded(
          child: list.items == null || list.items!.isEmpty
              ? _buildEmptyState()
              : _buildItemsList(pendingItems, purchasedItems),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
      ShoppingList list, int purchasedCount, int pendingCount) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [lightGreen, freshGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryGreen.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.shopping_basket,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        list.name,
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 24,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Mục đích: ${list.purpose}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatChip(
                    'Đã mua', purchasedCount, Icons.check_circle, Colors.white),
                const SizedBox(width: 12),
                _buildStatChip('Cần mua', pendingCount, Icons.shopping_cart,
                    Colors.white70),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(String label, int count, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(
              '$count $label',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: accentGreen.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shopping_basket_outlined,
              size: 64,
              color: primaryGreen,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Chưa có thực phẩm nào',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: primaryGreen,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hãy thêm thực phẩm vào danh sách của bạn',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList(
      List<ShoppingItem> pendingItems, List<ShoppingItem> purchasedItems) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        if (pendingItems.isNotEmpty) ...[
          _buildSectionHeader('🛒 Cần mua', pendingItems.length, primaryGreen),
          ...pendingItems.map((item) => _buildItemTile(item, false)),
          const SizedBox(height: 16),
        ],
        if (purchasedItems.isNotEmpty) ...[
          _buildSectionHeader(
              '✅ Đã mua', purchasedItems.length, Colors.grey[600]!),
          ...purchasedItems.map((item) => _buildItemTile(item, true)),
        ],
        const SizedBox(height: 80), // Space for FAB
      ],
    );
  }

  Widget _buildSectionHeader(String title, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemTile(ShoppingItem item, bool isPurchased) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPurchased ? Colors.grey[300]! : accentGreen.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Transform.scale(
          scale: 1.2,
          child: Checkbox(
            value: item.isPurchased,
            onChanged: (bool? value) async {
              if (isDisabled) {
                // Nếu đang bị disable, thông báo lỗi
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text("Bạn thao tác quá nhanh. Vui lòng đợi một chút."),
                    duration: Duration(seconds: 1),
                  ),
                );
                return;
              }

              // Bắt đầu giới hạn thao tác
              setState(() => isDisabled = true);

              if (value != null) {
                context.read<ShoppingItemBloc>().add(
                      PurchaseStatusChangedEvent(item.id),
                    );
              }

              // Đợi 3 giây trước khi cho phép thao tác tiếp
              await Future.delayed(const Duration(seconds: 1));
              if (mounted) setState(() => isDisabled = false);
            },
            activeColor: lightGreen,
            checkColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        title: Text(
          _getFoodEmoji(item.itemName) + item.itemName,
          style: TextStyle(
            decoration: isPurchased ? TextDecoration.lineThrough : null,
            color: isPurchased ? Colors.grey[600] : primaryGreen,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: _buildInfoChip(
            '${item.quantity} ${item.unit ?? ''}',
            Icons.scale,
            isPurchased,
          ),
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.delete_outline,
            color: Colors.red[400],
          ),
          onPressed: () => _showDeleteItemConfirmDialog(context, item),
          tooltip: 'Xóa thực phẩm',
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text, IconData icon, bool isPurchased) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isPurchased ? Colors.grey[200] : accentGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: isPurchased ? Colors.grey[600] : leafGreen,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: isPurchased ? Colors.grey[600] : leafGreen,
              decoration: isPurchased ? TextDecoration.lineThrough : null,
            ),
          ),
        ],
      ),
    );
  }

  String _getFoodEmoji(String itemName) {
    final name = itemName.toLowerCase();
    if (name.contains('rau') ||
        name.contains('xà lách') ||
        name.contains('cải')) {
      return '🥬 ';
    }
    if (name.contains('cà chua') || name.contains('cà rốt')) return '🥕 ';
    if (name.contains('táo') || name.contains('cam') || name.contains('quả')) {
      return '🍎 ';
    }
    if (name.contains('thịt') || name.contains('gà') || name.contains('heo')) {
      return '🥩 ';
    }
    if (name.contains('cá') || name.contains('tôm')) return '🐟 ';
    if (name.contains('sữa') || name.contains('phô mai')) return '🥛 ';
    if (name.contains('bánh') || name.contains('mì')) return '🍞 ';
    if (name.contains('gạo') || name.contains('cơm')) return '🍚 ';
    return '🥘 ';
  }

  // Dialog methods remain the same but with updated styling
  void _showAddItemDialog(BuildContext context, int listId) {
    final nameController = TextEditingController();
    final quantityController = TextEditingController(text: '1');
    final unitController = TextEditingController();
    int? selectedCategoryId;
    DateTime expiredDate = DateTime.now().add(const Duration(days: 30));

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: lightGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.add_shopping_cart, color: primaryGreen),
              ),
              const SizedBox(width: 12),
              const Text('Thêm thực phẩm'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDialogTextField(
                    nameController, 'Tên thực phẩm', Icons.fastfood,
                    autofocus: true),
                const SizedBox(height: 16),
                _buildCategoryField(
                  selectedCategoryId: selectedCategoryId,
                  onChanged: (value) {
                    setState(() {
                      selectedCategoryId = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                _buildDialogTextField(
                    quantityController, 'Số lượng', Icons.scale,
                    keyboardType: TextInputType.number),
                const SizedBox(height: 16),
                _buildDialogTextField(
                    unitController, 'Đơn vị (vd: kg, hộp)', Icons.straighten),
                const SizedBox(height: 16),
                _buildPurchaseDatePicker(
                  selectedDate: expiredDate,
                  onDateSelected: (date) {
                    setState(() {
                      expiredDate = date;
                    });
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Hủy', style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              onPressed: () {
                final itemName = nameController.text.trim();
                final quantityText = quantityController.text.trim();
                final unit = unitController.text.trim();

                // Validate tên sản phẩm
                if (itemName.isEmpty) {
                  showDialog(
                    context: context,
                    builder: (_) => const AlertDialog(
                      title: Text("Lỗi"),
                      content: Text("Vui lòng nhập tên sản phẩm."),
                    ),
                  );
                  return;
                }

                // Validate category
                if (selectedCategoryId == null) {
                  showDialog(
                    context: context,
                    builder: (_) => const AlertDialog(
                      title: Text("Lỗi"),
                      content: Text("Vui lòng chọn danh mục."),
                    ),
                  );
                  return;
                }

                // Parse quantity
                final quantity = int.tryParse(quantityText);
                if (quantity == null || quantity <= 0) {
                  showDialog(
                    context: context,
                    builder: (_) => const AlertDialog(
                      title: Text("Lỗi"),
                      content: Text("Số lượng phải là số nguyên dương."),
                    ),
                  );
                  return;
                }

                if (unit.isEmpty || unit.length > 10) {
                  showDialog(
                    context: context,
                    builder: (_) => const AlertDialog(
                      title: Text("Lỗi"),
                      content: Text(
                          "Vui lòng nhập đơn vị hợp lệ (tối đa 10 ký tự)."),
                    ),
                  );
                  return;
                }

                // Nếu tất cả OK → Gửi sự kiện
                context.read<ShoppingItemBloc>().add(
                      AddItemEvent(
                        listId: listId,
                        itemName: itemName,
                        quantity: quantity,
                        unit: unit,
                        expiredDate: expiredDate,
                        categoryId: selectedCategoryId!,
                      ),
                    );

                Navigator.pop(dialogContext);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: lightGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Thêm'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategoryField({
    required int? selectedCategoryId,
    required ValueChanged<int?> onChanged,
  }) {
    return BlocBuilder<CategoriesBloc, CategoriesState>(
      builder: (context, state) {
        List<Category> categories =
            state is CategoriesLoaded ? state.categories : [];
        int? effectiveValue = selectedCategoryId;

        if (categories.isNotEmpty &&
            (effectiveValue == null ||
                !categories.any((c) => c.id == effectiveValue))) {
          effectiveValue = categories.first.id;
          // Gọi callback để thông báo thay đổi
          WidgetsBinding.instance.addPostFrameCallback((_) {
            onChanged(effectiveValue);
          });
        }

        return DropdownButtonFormField<int>(
          value: categories.isNotEmpty ? effectiveValue : null,
          decoration: const InputDecoration(
            labelText: 'Danh mục',
            hintText: 'Chọn danh mục...',
            prefixIcon: Icon(Icons.category, color: primaryGreen),
            border:
                OutlineInputBorder(), // Thêm border cho rõ ràng trong Dialog
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          ),
          items: categories.isEmpty
              ? [
                  const DropdownMenuItem<int>(
                    value: null,
                    child: Text('Không có danh mục'),
                  )
                ]
              : categories
                  .map((category) => DropdownMenuItem<int>(
                        value: category.id,
                        child: Text(
                          category.name,
                          overflow: TextOverflow.ellipsis, // Tránh tràn text
                        ),
                      ))
                  .toList(),
          onChanged: onChanged,
          borderRadius: BorderRadius.circular(12), // Bo góc dropdown
          dropdownColor: Theme.of(context)
              .dialogBackgroundColor, // Màu nền phù hợp với Dialog
          menuMaxHeight: 300, // Giới hạn chiều cao
          isExpanded: true, // Quan trọng để tránh bể giao diện trong Dialog
          icon: const Icon(Icons.arrow_drop_down),
          style: Theme.of(context).textTheme.bodyMedium,
        );
      },
    );
  }

  Widget _buildPurchaseDatePicker({
    required DateTime selectedDate,
    required Function(DateTime) onDateSelected,
  }) {
    return Builder(
      builder: (context) {
        return InkWell(
          onTap: () async {
            final pickedDate = await showDatePicker(
              context: context,
              initialDate: selectedDate,
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
            );
            if (pickedDate != null) {
              onDateSelected(pickedDate);
            }
          },
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: 'Ngày mua',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 16,
              ),
              suffixIcon: const Icon(Icons.calendar_today),
            ),
            child: Text(
              DateFormat('dd/MM/yyyy').format(selectedDate),
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDialogTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType? keyboardType,
    bool autofocus = false,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: primaryGreen),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accentGreen),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightGreen, width: 2),
        ),
      ),
      keyboardType: keyboardType,
      autofocus: autofocus,
    );
  }

  void _showDeleteItemConfirmDialog(BuildContext context, ShoppingItem item) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange[600]),
            const SizedBox(width: 12),
            const Text('Xác nhận xóa'),
          ],
        ),
        content:
            Text('Bạn có chắc muốn xóa "${item.itemName}" khỏi danh sách?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Hủy', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<ShoppingItemBloc>().add(DeleteItemEvent(item.id));
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  void _showDeleteListConfirmDialog(BuildContext context, int listId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.delete_forever, color: Colors.red[600]),
            const SizedBox(width: 12),
            const Text('Xóa danh sách'),
          ],
        ),
        content: const Text(
          'Bạn có chắc chắn muốn xóa toàn bộ danh sách này không? Thao tác này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Hủy', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<ShoppingItemBloc>().add(DeleteListEvent(listId));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Xóa'),
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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: lightGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.edit, color: primaryGreen),
                  ),
                  const SizedBox(width: 12),
                  const Text('Chỉnh sửa'),
                ],
              ),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Tên danh sách',
                        prefixIcon:
                            const Icon(Icons.list_alt, color: primaryGreen),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: lightGreen, width: 2),
                        ),
                      ),
                      autofocus: true,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Tên danh sách không được để trống';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: primaryGreen,
                                  onPrimary: Colors.white,
                                  surface: Colors.white,
                                  onSurface: Colors.black,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (pickedDate != null) {
                          setDialogState(() {
                            selectedDate = pickedDate;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[400]!),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today,
                                color: primaryGreen),
                            const SizedBox(width: 12),
                            Text(
                              'Ngày mua: ${DateFormat('dd/MM/yyyy').format(selectedDate)}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text('Hủy', style: TextStyle(color: Colors.grey[600])),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      context.read<ShoppingItemBloc>().add(
                            UpdateListEvent(
                              listId: currentList.id,
                              newName: nameController.text.trim(),
                              newPurchaseDate: selectedDate,
                            ),
                          );
                      Navigator.pop(dialogContext);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: lightGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
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
