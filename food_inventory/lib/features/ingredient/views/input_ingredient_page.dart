import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stock_mate/features/ingredient/bloc/ingredients_bloc.dart';

import '../../../core/config/app_config.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_theme.dart';
import '../models/category.dart';
import '../models/ingredient.dart';

class AddEditIngredientPage extends StatefulWidget {
  final Ingredient? ingredient;
  final bool isEdit;

  const AddEditIngredientPage({
    super.key,
    this.ingredient,
    this.isEdit = false,
  });

  @override
  State<AddEditIngredientPage> createState() => _AddEditIngredientPageState();
}

class _AddEditIngredientPageState extends State<AddEditIngredientPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitController = TextEditingController();
  final _noteController = TextEditingController();

  String? selectedCategoryId;
  DateTime? importDate;
  DateTime? expireDate;
  IngredientStatus selectedStatus = IngredientStatus.conDung;
  File? selectedImage;
  String? currentImagePath;

  final ImagePicker _picker = ImagePicker();
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  List<Category> categories = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _loadCategories();
  }

  void _initializeData() {
    if (widget.isEdit && widget.ingredient != null) {
      final ingredient = widget.ingredient!;
      _nameController.text = ingredient.name;
      _quantityController.text = ingredient.quantity.toString();
      _unitController.text = ingredient.unit ?? '';
      _noteController.text = ingredient.note ?? '';
      selectedCategoryId = ingredient.categoryId;
      importDate = ingredient.importDate;
      expireDate = ingredient.expireDate;
      selectedStatus = ingredient.status;
      currentImagePath = ingredient.imagePath;
    }
  }

  void _loadCategories() {
    // TODO: Load categories from BLoC
    // For now, using mock data
    setState(() {
      categories = [
        Category(
          id: '1',
          name: 'Rau củ',
          description: 'Các loại rau củ quả',
          createdAt: DateTime.now(),
        ),
        Category(
          id: '2',
          name: 'Thịt cá',
          description: 'Thịt, cá, hải sản',
          createdAt: DateTime.now(),
        ),
        Category(
          id: '3',
          name: 'Gia vị',
          description: 'Các loại gia vị, đồ khô',
          createdAt: DateTime.now(),
        ),
        Category(
          id: '4',
          name: 'Sữa và trứng',
          description: 'Sữa, trứng, sản phẩm từ sữa',
          createdAt: DateTime.now(),
        ),
      ];
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Sửa nguyên liệu' : 'Thêm nguyên liệu'),
        actions: [
          TextButton(
            onPressed: _saveIngredient,
            child: Text(
              'Lưu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      body: BlocListener<ProductsBloc, IngredientsState>(
        listener: (context, state) {
          if (state is IngredientssError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.errorColor,
              ),
            );
            setState(() {
              isLoading = false;
            });
          } else if (state is IngredientsLoaded) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(widget.isEdit
                    ? 'Cập nhật nguyên liệu thành công'
                    : 'Thêm nguyên liệu thành công'),
                backgroundColor: AppTheme.primaryGreen,
              ),
            );
            Navigator.pop(context);
          }
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image section
                _buildImageSection(),
                SizedBox(height: 24.h),

                // Basic info section
                _buildSectionTitle('Thông tin cơ bản'),
                SizedBox(height: 12.h),
                _buildNameField(),
                SizedBox(height: 16.h),
                _buildCategoryField(),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Expanded(child: _buildQuantityField()),
                    SizedBox(width: 16.w),
                    Expanded(child: _buildUnitField()),
                  ],
                ),
                SizedBox(height: 24.h),

                // Date section
                _buildSectionTitle('Thông tin ngày tháng'),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(child: _buildImportDateField()),
                    SizedBox(width: 16.w),
                    Expanded(child: _buildExpireDateField()),
                  ],
                ),
                SizedBox(height: 24.h),

                // Status section
                _buildSectionTitle('Trạng thái'),
                SizedBox(height: 12.h),
                _buildStatusField(),
                SizedBox(height: 24.h),

                // Note section
                _buildSectionTitle('Ghi chú'),
                SizedBox(height: 12.h),
                _buildNoteField(),
                SizedBox(height: 32.h),

                // Save button
                _buildSaveButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Container(
      width: double.infinity,
      height: 200.h,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: selectedImage != null
          ? Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Image.file(
                    selectedImage!,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8.h,
                  right: 8.w,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedImage = null;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 16.w,
                      ),
                    ),
                  ),
                ),
              ],
            )
          : currentImagePath != null
              ? Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: Image.network(
                        currentImagePath!,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildImagePlaceholder();
                        },
                      ),
                    ),
                    Positioned(
                      top: 8.h,
                      right: 8.w,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            currentImagePath = null;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.all(4.w),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16.w,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : _buildImagePlaceholder(),
    );
  }

  Widget _buildImagePlaceholder() {
    return GestureDetector(
      onTap: _showImagePickerOptions,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_a_photo,
            size: 48.w,
            color: Colors.grey[400],
          ),
          SizedBox(height: 8.h),
          Text(
            'Thêm ảnh nguyên liệu',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
        color: AppTheme.primaryGreen,
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: const InputDecoration(
        labelText: 'Tên nguyên liệu *',
        hintText: 'Nhập tên nguyên liệu...',
        prefixIcon: Icon(Icons.inventory),
      ),
      validator: (value) {
        if (value?.isEmpty ?? true) {
          return 'Vui lòng nhập tên nguyên liệu';
        }
        return null;
      },
    );
  }

  Widget _buildCategoryField() {
    return DropdownButtonFormField<String>(
      value: selectedCategoryId,
      decoration: const InputDecoration(
        labelText: 'Danh mục',
        hintText: 'Chọn danh mục...',
        prefixIcon: Icon(Icons.category),
      ),
      items: [
        const DropdownMenuItem<String>(
          value: null,
          child: Text('Không có danh mục'),
        ),
        ...categories.map((category) => DropdownMenuItem<String>(
              value: category.id,
              child: Text(category.name),
            )),
      ],
      onChanged: (value) {
        setState(() {
          selectedCategoryId = value;
        });
      },
    );
  }

  Widget _buildQuantityField() {
    return TextFormField(
      controller: _quantityController,
      decoration: const InputDecoration(
        labelText: 'Số lượng *',
        hintText: '0',
        prefixIcon: Icon(Icons.numbers),
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value?.isEmpty ?? true) {
          return 'Vui lòng nhập số lượng';
        }
        if (int.tryParse(value!) == null) {
          return 'Số lượng không hợp lệ';
        }
        if (int.parse(value) < 0) {
          return 'Số lượng phải lớn hơn 0';
        }
        return null;
      },
    );
  }

  Widget _buildUnitField() {
    return TextFormField(
      controller: _unitController,
      decoration: const InputDecoration(
        labelText: 'Đơn vị',
        hintText: 'kg, lít, gói...',
        prefixIcon: Icon(Icons.straighten),
      ),
    );
  }

  Widget _buildImportDateField() {
    return GestureDetector(
      onTap: () => _selectDate(context, true),
      child: AbsorbPointer(
        child: TextFormField(
          decoration: const InputDecoration(
            labelText: 'Ngày nhập',
            hintText: 'Chọn ngày nhập...',
            prefixIcon: Icon(Icons.calendar_today),
          ),
          controller: TextEditingController(
            text: importDate != null ? _dateFormat.format(importDate!) : '',
          ),
        ),
      ),
    );
  }

  Widget _buildExpireDateField() {
    return GestureDetector(
      onTap: () => _selectDate(context, false),
      child: AbsorbPointer(
        child: TextFormField(
          decoration: const InputDecoration(
            labelText: 'Ngày hết hạn',
            hintText: 'Chọn ngày hết hạn...',
            prefixIcon: Icon(Icons.event_busy),
          ),
          controller: TextEditingController(
            text: expireDate != null ? _dateFormat.format(expireDate!) : '',
          ),
        ),
      ),
    );
  }

  Widget _buildStatusField() {
    return DropdownButtonFormField<IngredientStatus>(
      value: selectedStatus,
      decoration: const InputDecoration(
        labelText: 'Trạng thái',
        prefixIcon: Icon(Icons.info),
      ),
      items: IngredientStatus.values.map((status) {
        return DropdownMenuItem<IngredientStatus>(
          value: status,
          child: Row(
            children: [
              Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  color: _getStatusColor(status),
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 8.w),
              Text(_getStatusName(status)),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            selectedStatus = value;
          });
        }
      },
    );
  }

  Widget _buildNoteField() {
    return TextFormField(
      controller: _noteController,
      decoration: const InputDecoration(
        labelText: 'Ghi chú',
        hintText: 'Nhập ghi chú về nguyên liệu...',
        prefixIcon: Icon(Icons.note),
      ),
      maxLines: 3,
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 48.h,
      child: ElevatedButton(
        onPressed: isLoading ? null : _saveIngredient,
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                widget.isEdit ? 'Cập nhật' : 'Thêm nguyên liệu',
                style: TextStyle(fontSize: 16.sp),
              ),
      ),
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
          currentImagePath = null; // Clear current image if selecting new one
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

  Future<void> _selectDate(BuildContext context, bool isImportDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isImportDate
          ? (importDate ?? DateTime.now())
          : (expireDate ?? DateTime.now().add(const Duration(days: 30))),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryGreen,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isImportDate) {
          importDate = picked;
        } else {
          expireDate = picked;
        }
      });
    }
  }

  void _saveIngredient() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final prefs = getIt<SharedPreferences>();
      final storageId = prefs.getString(AppConfig.currentStorageKey);

      if (storageId == null) {
        throw Exception('Không tìm thấy kho hiện tại');
      }

      // TODO: Upload image if selected
      String? imagePath = currentImagePath;
      if (selectedImage != null) {
        // imagePath = await _uploadImage(selectedImage!);
      }

      final ingredient = Ingredient(
        id: widget.isEdit ? widget.ingredient!.id : '',
        storageId: storageId,
        name: _nameController.text.trim(),
        categoryId: selectedCategoryId,
        quantity: int.parse(_quantityController.text),
        unit: _unitController.text.trim().isEmpty
            ? null
            : _unitController.text.trim(),
        importDate: importDate,
        expireDate: expireDate,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
        status: selectedStatus,
        imagePath: imagePath,
        createdAt:
            widget.isEdit ? widget.ingredient!.createdAt : DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.isEdit) {
        context.read<ProductsBloc>().add(UpdateIngredient(ingredient));
      } else {
        context.read<ProductsBloc>().add(CreateIngredient(ingredient));
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString()}'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  Color _getStatusColor(IngredientStatus status) {
    switch (status) {
      case IngredientStatus.conDung:
        return Colors.green;
      case IngredientStatus.hetHan:
        return Colors.red;
      case IngredientStatus.daDung:
        return Colors.orange;
      case IngredientStatus.huy:
        return Colors.grey;
    }
  }

  String _getStatusName(IngredientStatus status) {
    switch (status) {
      case IngredientStatus.conDung:
        return 'Còn dùng';
      case IngredientStatus.hetHan:
        return 'Hết hạn';
      case IngredientStatus.daDung:
        return 'Đã dùng';
      case IngredientStatus.huy:
        return 'Hủy';
    }
  }
}
