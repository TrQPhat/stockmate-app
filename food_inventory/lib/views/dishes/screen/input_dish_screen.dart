import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stock_mate/core/config/app_config.dart';
import 'package:stock_mate/core/di/injection_container.dart';
import 'package:stock_mate/core/theme/app_theme.dart';
import 'package:stock_mate/models/dish.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class InputDishScreen extends StatefulWidget {
  final Function(Dish) onEvent;
  final Dish? dish;

  const InputDishScreen({
    super.key,
    required this.onEvent,
    this.dish,
  });

  @override
  State<InputDishScreen> createState() => _InputDishScreenState();
}

class _InputDishScreenState extends State<InputDishScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _cookTimeController = TextEditingController();

  File? selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.dish != null) {
      _initializeFormWithDishData(widget.dish!);
    }
  }

  void _initializeFormWithDishData(Dish dish) {
    _nameController.text = dish.name;
    _descriptionController.text = dish.description;
    _instructionsController.text = dish.instructions;
    _cookTimeController.text = dish.cookTimeMinutes.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.dish == null ? 'Thêm Món Ăn Mới' : 'Chỉnh sửa món ăn'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildForm(),
            const SizedBox(height: 20),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          _buildSectionTitle("Tên món ăn"),
          const SizedBox(height: 10),
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
          _buildSectionTitle("Mô tả"),
          const SizedBox(height: 10),
          _buildTextField(
            controller: _descriptionController,
            label: 'Mô tả',
            hint: 'Mô tả ngắn gọn về món ăn...',
            icon: Icons.description,
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          _buildSectionTitle("Hướng dẫn nấu ăn"),
          const SizedBox(height: 10),
          _buildTextField(
            controller: _instructionsController,
            label: 'Hướng dẫn *',
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
          _buildSectionTitle("Thời gian nấu"),
          const SizedBox(height: 10),
          _buildTextField(
            controller: _cookTimeController,
            label: 'Thời gian nấu (phút)',
            hint: '30',
            icon: Icons.access_time,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          _buildImagePicker(),
        ],
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hình ảnh món ăn',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _showImagePickerOptions,
          child: Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey[400]!,
                width: 1,
              ),
            ),
            child: _buildImageContent(),
          ),
        ),
        if (widget.dish?.imageUrl != null && selectedImage == null)
          TextButton(
            onPressed: () {
              setState(() {
                selectedImage = null;
              });
            },
            child: const Text(
              'Xóa ảnh đã chọn',
              style: TextStyle(color: Colors.red),
            ),
          ),
      ],
    );
  }

  Widget _buildImageContent() {
    if (selectedImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          selectedImage!,
          width: double.infinity,
          height: 150,
          fit: BoxFit.cover,
        ),
      );
    } else if (widget.dish?.imageUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          "${AppConfig.rootImagePath}/${widget.dish!.imageUrl!}",
          width: double.infinity,
          height: 150,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
        ),
      );
    } else {
      return _buildPlaceholder();
    }
  }

  Widget _buildPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.image, size: 50, color: Colors.grey),
        const SizedBox(height: 8),
        Text(
          'Chọn ảnh từ thư viện',
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Chụp ảnh'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Chọn từ thư viện'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            if (widget.dish?.imageUrl != null || selectedImage != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title:
                    const Text('Xóa ảnh', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    selectedImage = null;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          selectedImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi chọn ảnh: ${e.toString()}'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
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
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16,
        ),
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppTheme.primaryGreen,
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: _handleSubmit,
        child: Text(
          widget.dish == null ? 'THÊM MÓN ĂN' : 'CẬP NHẬT',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final prefs = getIt<SharedPreferences>();
      final storageId = prefs.getInt(AppConfig.storageIdKey) ?? 0;

      if (storageId == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã có lỗi xảy ra, vui lòng thử lại.')),
        );
        return;
      }

      final String? imagePath = selectedImage?.path;
      final bool keepExistingImage =
          widget.dish?.imageUrl != null && selectedImage == null;

      final dish = Dish(
        id: widget.dish?.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        instructions: _instructionsController.text.trim(),
        imageUrl: keepExistingImage ? widget.dish!.imageUrl : imagePath,
        cookTimeMinutes: int.tryParse(_cookTimeController.text) ?? 0,
        storageId: storageId,
      );

      widget.onEvent(dish);
    }
  }
}
