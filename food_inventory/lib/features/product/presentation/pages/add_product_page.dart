import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../../../core/di/injection.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../bloc/product_bloc.dart';

class AddProductPage extends StatefulWidget {
  final String storageId;

  const AddProductPage({
    super.key,
    required this.storageId,
  });

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  late ProductBloc _productBloc;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitController = TextEditingController();
  final _noteController = TextEditingController();
  
  String? _selectedCategory;
  DateTime? _importDate;
  DateTime? _expireDate;
  File? _selectedImage;
  
  final List<String> _categories = [
    'Thịt',
    'Rau củ',
    'Trái cây',
    'Gia vị',
    'Đồ khô',
    'Đồ uống',
    'Khác',
  ];

  @override
  void initState() {
    super.initState();
    _productBloc = getIt<ProductBloc>();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _noteController.dispose();
    _productBloc.close();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _selectDate(BuildContext context, bool isExpireDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    
    if (picked != null) {
      setState(() {
        if (isExpireDate) {
          _expireDate = picked;
        } else {
          _importDate = picked;
        }
      });
    }
  }

  void _saveProduct() {
    if (_formKey.currentState!.validate()) {
      final data = {
        'name': _nameController.text.trim(),
        'category': _selectedCategory,
        'quantity': int.parse(_quantityController.text),
        'unit': _unitController.text.trim().isEmpty ? null : _unitController.text.trim(),
        'import_date': _importDate?.toIso8601String().split('T')[0],
        'expire_date': _expireDate?.toIso8601String().split('T')[0],
        'note': _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
        'status': 'con_dung',
      };

      _productBloc.add(ProductCreateRequested(widget.storageId, data));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Thêm sản phẩm',
        actions: [
          TextButton(
            onPressed: _saveProduct,
            child: const Text('Lưu'),
          ),
        ],
      ),
      body: BlocProvider.value(
        value: _productBloc,
        child: BlocListener<ProductBloc, ProductState>(
          listener: (context, state) {
            if (state is ProductLoaded) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã thêm sản phẩm thành công')),
              );
              Navigator.of(context).pop();
            } else if (state is ProductError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          child: BlocBuilder<ProductBloc, ProductState>(
            builder: (context, state) {
              if (state is ProductLoading) {
                return const LoadingWidget(message: 'Đang thêm sản phẩm...');
              }

              return Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Image Picker
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: _selectedImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  _selectedImage!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_a_photo,
                                    size: 48,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Thêm ảnh sản phẩm',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Product Name
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Tên sản phẩm *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập tên sản phẩm';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Category
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Danh mục',
                        border: OutlineInputBorder(),
                      ),
                      items: _categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Quantity and Unit
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _quantityController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Số lượng *',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Vui lòng nhập số lượng';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Số lượng không hợp lệ';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _unitController,
                            decoration: const InputDecoration(
                              labelText: 'Đơn vị',
                              border: OutlineInputBorder(),
                              hintText: 'kg, lít, cái...',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Import Date
                    InkWell(
                      onTap: () => _selectDate(context, false),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Ngày nhập kho',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          _importDate != null
                              ? '${_importDate!.day}/${_importDate!.month}/${_importDate!.year}'
                              : 'Chọn ngày nhập kho',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Expire Date
                    InkWell(
                      onTap: () => _selectDate(context, true),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Hạn sử dụng',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          _expireDate != null
                              ? '${_expireDate!.day}/${_expireDate!.month}/${_expireDate!.year}'
                              : 'Chọn hạn sử dụng',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Note
                    TextFormField(
                      controller: _noteController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Ghi chú',
                        border: OutlineInputBorder(),
                        hintText: 'Thêm ghi chú về sản phẩm...',
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Save Button
                    ElevatedButton(
                      onPressed: _saveProduct,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Thêm sản phẩm'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
