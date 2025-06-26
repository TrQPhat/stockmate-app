import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stock_mate/core/theme/app_theme.dart';

class CreateListDialog extends StatefulWidget {
  final Function(String name, String purpose, DateTime date) onCreateList;

  const CreateListDialog({
    super.key,
    required this.onCreateList,
  });

  @override
  State<CreateListDialog> createState() => _CreateListDialogState();
}

class _CreateListDialogState extends State<CreateListDialog> {
  final _nameController = TextEditingController();
  final _purposeController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _purposeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(
        children: [
          Icon(Icons.add_shopping_cart, color: AppTheme.primaryOrange),
          SizedBox(width: 8),
          Text('🥬 Tạo danh sách mới'),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildNameField(),
            const SizedBox(height: 16),
            _buildPurposeField(),
            const SizedBox(height: 16),
            _buildDatePicker(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy',
              style: TextStyle(color: AppTheme.textSecondary)),
        ),
        ElevatedButton(
          onPressed: _handleCreate,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryOrange,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('🛒 Tạo danh sách'),
        ),
      ],
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: 'Tên danh sách',
        hintText: 'VD: Mua sắm cuối tuần',
        prefixIcon: const Icon(Icons.list_alt, color: AppTheme.primaryOrange),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primaryOrange),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Vui lòng nhập tên danh sách';
        }
        return null;
      },
      autofocus: true,
    );
  }

  Widget _buildPurposeField() {
    return TextFormField(
      controller: _purposeController,
      decoration: InputDecoration(
        labelText: 'Mục đích',
        hintText: 'VD: Chuẩn bị bữa tối',
        prefixIcon:
            const Icon(Icons.restaurant_menu, color: AppTheme.primaryGreen),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primaryGreen),
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: _selectDate,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Ngày mua dự kiến',
          prefixIcon:
              const Icon(Icons.calendar_today, color: AppTheme.accentYellow),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
        child: Text(
          DateFormat('EEEE, dd/MM/yyyy', 'vi').format(_selectedDate),
          style: const TextStyle(
            fontSize: 16,
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppTheme.primaryOrange,
                ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  void _handleCreate() {
    if (_formKey.currentState!.validate()) {
      widget.onCreateList(
        _nameController.text.trim(),
        _purposeController.text.trim(),
        _selectedDate,
      );
      Navigator.pop(context);
    }
  }
}
