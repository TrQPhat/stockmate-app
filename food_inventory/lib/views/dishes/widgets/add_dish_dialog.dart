import 'package:flutter/material.dart';
import 'package:stock_mate/core/theme/app_theme.dart';
import 'package:stock_mate/models/dish.dart';

class AddDishDialog extends StatefulWidget {
  final Function(Dish) onAddDish;

  const AddDishDialog({
    super.key,
    required this.onAddDish,
  });

  @override
  State<AddDishDialog> createState() => _AddDishDialogState();
}

class _AddDishDialogState extends State<AddDishDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _cookTimeController = TextEditingController();
  final _imageUrlController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _instructionsController.dispose();
    _cookTimeController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Expanded(
              child: _buildForm(),
            ),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppTheme.primaryOrange,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: const Row(
        children: [
          Icon(Icons.add_circle, color: Colors.white),
          SizedBox(width: 12),
          Text(
            '🍳 Thêm Món Ăn Mới',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(
              controller: _nameController,
              label: 'Tên món ăn *',
              hint: 'VD: Phở Bò Hà Nội',
              icon: Icons.restaurant_menu,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập tên món ăn';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _descriptionController,
              label: 'Mô tả',
              hint: 'Mô tả ngắn gọn về món ăn...',
              icon: Icons.description,
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _instructionsController,
              label: 'Hướng dẫn nấu ăn *',
              hint: '1. Bước đầu tiên...\n2. Bước thứ hai...',
              icon: Icons.list_alt,
              maxLines: 4,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập hướng dẫn nấu ăn';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _cookTimeController,
              label: 'Thời gian nấu (phút)',
              hint: '30',
              icon: Icons.access_time,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _imageUrlController,
              label: 'URL hình ảnh',
              hint: 'https://example.com/image.jpg',
              icon: Icons.image,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppTheme.primaryOrange),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primaryOrange),
        ),
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: _handleSubmit,
            child: const Text('Thêm Món Ăn'),
          ),
        ],
      ),
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final dish = Dish(
        id: 'user-${DateTime.now().millisecondsSinceEpoch}',
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        instructions: _instructionsController.text.trim(),
        imageUrl: _imageUrlController.text.trim().isEmpty
            ? 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=400'
            : _imageUrlController.text.trim(),
        cookTimeMinutes: int.tryParse(_cookTimeController.text) ?? 0,
        storageId: 1,
        isAISuggested: false,
      );

      widget.onAddDish(dish);
      Navigator.pop(context);
    }
  }
}
