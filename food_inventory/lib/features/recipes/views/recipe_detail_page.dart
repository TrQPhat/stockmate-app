import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:stock_mate/features/home/widgets/custom_app_bar.dart';
import 'package:stock_mate/features/home/widgets/error_widget.dart';
import 'package:stock_mate/features/home/widgets/loading_widget.dart';

import '../bloc/recipe_bloc.dart';
import '../models/recipe.dart';

class RecipeDetailPage extends StatefulWidget {
  final String recipeId;
  const RecipeDetailPage({super.key, required this.recipeId});

  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<RecipeBloc>().add(LoadRecipeDetails(widget.recipeId));
  }

  void _showDeleteDialog(BuildContext context, Recipe recipe) {
    // Lấy bloc ra trước khi vào dialog
    final recipeBloc = context.read<RecipeBloc>();
    showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
              title: const Text('Xác nhận xóa'),
              content: Text('Bạn có chắc muốn xóa công thức "${recipe.name}"?'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Hủy')),
                ElevatedButton(
                  onPressed: () {
                    recipeBloc.add(DeleteRecipe(recipe.id));
                    Navigator.pop(dialogContext);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child:
                      const Text('Xóa', style: TextStyle(color: Colors.white)),
                )
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RecipeBloc, RecipeState>(
      listener: (context, state) {
        if (state is RecipeOperationSuccess && state.message.contains("Xóa")) {
          context.pop(); // Quay về trang list sau khi xóa thành công
        }
        if (state is RecipeError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.message),
            backgroundColor: Colors.red,
          ));
          context.pop();
        }
      },
      builder: (context, state) {
        // Cấu trúc lại để an toàn hơn
        // 1. Xử lý trạng thái đã tải thành công
        if (state is RecipeDetailsLoaded) {
          final recipe = state.recipe;
          return Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 250.0,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(recipe.name,
                        style: const TextStyle(
                            color: Colors.white,
                            shadows: [Shadow(blurRadius: 10)])),
                    background: recipe.imageUrl != null
                        ? Image.network(
                            recipe.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(color: Colors.grey),
                          )
                        : Container(color: Colors.grey),
                  ),
                  actions: [
                    IconButton(
                        onPressed: () {
                          // TODO: Chuyển sang trang Edit
                        },
                        icon: const Icon(Icons.edit)),
                    IconButton(
                        onPressed: () => _showDeleteDialog(context, recipe),
                        icon:
                            const Icon(Icons.delete, color: Colors.redAccent)),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(recipe.description ?? 'Không có mô tả',
                            style: Theme.of(context).textTheme.bodyLarge),
                        const SizedBox(height: 16),
                        Text('Nguyên liệu',
                            style: Theme.of(context).textTheme.titleLarge),
                        const Divider(),
                        if (recipe.ingredients?.isNotEmpty ?? false)
                          ...recipe.ingredients!.map((ing) => ListTile(
                                leading: const Icon(Icons.double_arrow_sharp,
                                    size: 16),
                                title: Text(ing.productName),
                                trailing: Text('${ing.quantity} ${ing.unit}'),
                              ))
                        else
                          const Text('Không có thông tin nguyên liệu.'),
                        const SizedBox(height: 16),
                        Text('Hướng dẫn thực hiện',
                            style: Theme.of(context).textTheme.titleLarge),
                        const Divider(),
                        Text(recipe.instructions,
                            style: const TextStyle(height: 1.5)),
                      ],
                    ),
                  ),
                )
              ],
            ),
          );
        }

        // 2. Xử lý các trạng thái khác (Loading, Error, Initial)
        return Scaffold(
          appBar: const CustomAppBar(title: "Chi tiết công thức"),
          body: () {
            if (state is RecipeError) {
              return CustomErrorWidget(
                  message: state.message,
                  onRetry: () => context
                      .read<RecipeBloc>()
                      .add(LoadRecipeDetails(widget.recipeId)));
            }
            // Mặc định cho RecipeInitial và RecipeLoading
            return const Center(child: LoadingWidget());
          }(),
        );
      },
    );
  }
}
