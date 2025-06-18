import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:stock_mate/features/home/widgets/custom_app_bar.dart';
import 'package:stock_mate/features/ingredient/bloc/ingredients_bloc.dart';
import 'package:stock_mate/features/ingredient/models/ingredient.dart';

import '../bloc/recipe_bloc.dart';

class AddEditRecipePage extends StatefulWidget {
  const AddEditRecipePage({super.key});

  @override
  State<AddEditRecipePage> createState() => _AddEditRecipePageState();
}

class _TempRecipeIngredient {
  final String productId;
  final String productName;
  final double quantity;
  final String unit;

  _TempRecipeIngredient({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unit,
  });
}

class _AddEditRecipePageState extends State<AddEditRecipePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _cookTimeController = TextEditingController();
  final _servingSizeController = TextEditingController();

  final List<_TempRecipeIngredient> _ingredients = [];

  @override
  void initState() {
    super.initState();
    // Tải danh sách sản phẩm để người dùng chọn
    context.read<ProductsBloc>().add(const LoadIngredients());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _instructionsController.dispose();
    _cookTimeController.dispose();
    _servingSizeController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final recipeData = {
        "name": _nameController.text,
        "description": _descriptionController.text,
        "instructions": _instructionsController.text,
        "cook_time_minutes": int.tryParse(_cookTimeController.text),
        "serving_size": int.tryParse(_servingSizeController.text),
        "ingredients": _ingredients
            .map((ing) => {
                  "product_id": ing.productId,
                  "quantity": ing.quantity,
                  "unit": ing.unit
                })
            .toList()
      };
      context.read<RecipeBloc>().add(CreateRecipe(recipeData));
    }
  }

  void _showAddIngredientDialog() {
    final productsState = context.read<ProductsBloc>().state;
    if (productsState is! IngredientsLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Danh sách sản phẩm chưa sẵn sàng, vui lòng thử lại."),
      ));
      return;
    }

    final availableProducts = productsState.ingredients;
    Ingredient? selectedProduct;
    final quantityController = TextEditingController();
    final unitController = TextEditingController();
    final dialogFormKey = GlobalKey<FormState>();

    showDialog(
        context: context,
        builder: (dialogContext) {
          return StatefulBuilder(builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Thêm nguyên liệu"),
              content: Form(
                key: dialogFormKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<Ingredient>(
                        value: selectedProduct,
                        hint: const Text("Chọn sản phẩm"),
                        items: availableProducts
                            .map((p) =>
                                DropdownMenuItem(value: p, child: Text(p.name)))
                            .toList(),
                        onChanged: (value) {
                          setDialogState(() => selectedProduct = value);
                        },
                        validator: (v) =>
                            v == null ? "Vui lòng chọn sản phẩm" : null,
                      ),
                      TextFormField(
                        controller: quantityController,
                        decoration:
                            const InputDecoration(labelText: 'Số lượng'),
                        keyboardType: TextInputType.number,
                        validator: (v) => v == null || v.isEmpty
                            ? "Vui lòng nhập số lượng"
                            : null,
                      ),
                      TextFormField(
                          controller: unitController,
                          decoration: const InputDecoration(
                              labelText: 'Đơn vị (kg, quả, ...)')),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text("Hủy")),
                ElevatedButton(
                    onPressed: () {
                      if (dialogFormKey.currentState!.validate()) {
                        setState(() {
                          _ingredients.add(_TempRecipeIngredient(
                            productId: selectedProduct!.id,
                            productName: selectedProduct!.name,
                            quantity: double.parse(quantityController.text),
                            unit: unitController.text,
                          ));
                        });
                        Navigator.pop(dialogContext);
                      }
                    },
                    child: const Text("Thêm")),
              ],
            );
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Tạo công thức mới"),
      body: BlocListener<RecipeBloc, RecipeState>(
        listener: (context, state) {
          if (state is RecipeOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ));
            context.go('/recipes');
          }
          if (state is RecipeError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ));
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: "Tên món ăn"),
                  validator: (v) => v!.isEmpty ? "Không được bỏ trống" : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: "Mô tả ngắn")),
                const SizedBox(height: 16),
                TextFormField(
                    controller: _instructionsController,
                    decoration:
                        const InputDecoration(labelText: "Hướng dẫn thực hiện"),
                    maxLines: 5,
                    validator: (v) =>
                        v!.isEmpty ? "Không được bỏ trống" : null),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(
                      child: TextFormField(
                    controller: _cookTimeController,
                    decoration: const InputDecoration(
                        labelText: "Thời gian nấu (phút)"),
                    keyboardType: TextInputType.number,
                  )),
                  const SizedBox(width: 16),
                  Expanded(
                      child: TextFormField(
                    controller: _servingSizeController,
                    decoration:
                        const InputDecoration(labelText: "Khẩu phần (người)"),
                    keyboardType: TextInputType.number,
                  )),
                ]),
                const SizedBox(height: 24),

                // --- PHẦN QUẢN LÝ NGUYÊN LIỆU ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Danh sách nguyên liệu",
                        style: Theme.of(context).textTheme.titleLarge),
                    IconButton.filled(
                        onPressed: _showAddIngredientDialog,
                        icon: const Icon(Icons.add))
                  ],
                ),
                const Divider(),
                _ingredients.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child:
                            Center(child: Text("Vui lòng thêm nguyên liệu.")))
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _ingredients.length,
                        itemBuilder: (context, index) {
                          final ing = _ingredients[index];
                          return ListTile(
                            title: Text(ing.productName),
                            subtitle: Text("${ing.quantity} ${ing.unit}"),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _ingredients.removeAt(index);
                                });
                              },
                            ),
                          );
                        },
                      ),
                const SizedBox(height: 24),
                SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                        onPressed: _submitForm,
                        child: const Text("Lưu công thức")))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
