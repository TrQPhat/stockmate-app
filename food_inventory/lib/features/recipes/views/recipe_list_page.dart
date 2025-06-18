import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:stock_mate/features/home/widgets/custom_app_bar.dart';

import '../../home/widgets/error_widget.dart';
import '../../home/widgets/loading_widget.dart';
import '../bloc/recipe_bloc.dart';
import '../models/recipe.dart';

class RecipeListPage extends StatefulWidget {
  const RecipeListPage({super.key});

  @override
  State<RecipeListPage> createState() => _RecipeListPageState();
}

class _RecipeListPageState extends State<RecipeListPage> {
  @override
  void initState() {
    super.initState();
    final currentState = context.read<RecipeBloc>().state;
    if (currentState is! AllRecipesLoaded) {
      context.read<RecipeBloc>().add(LoadAllRecipes());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Sổ tay công thức'),
      body: BlocConsumer<RecipeBloc, RecipeState>(
        listener: (context, state) {
          if (state is RecipeError && state is! AllRecipesLoaded) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message), backgroundColor: Colors.red),
            );
          }
          if (state is RecipeOperationSuccess &&
              state.message.contains("Xóa")) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ));
          }
        },
        buildWhen: (previous, current) {
          return current is RecipeLoading ||
              current is AllRecipesLoaded ||
              current is RecipeError;
        },
        builder: (context, state) {
          if (state is RecipeLoading) {
            return const LoadingWidget(message: 'Đang tải công thức...');
          }
          if (state is RecipeError && state is! AllRecipesLoaded) {
            return CustomErrorWidget(
              message: state.message,
              onRetry: () => context.read<RecipeBloc>().add(LoadAllRecipes()),
            );
          }
          if (state is AllRecipesLoaded) {
            if (state.recipes.isEmpty) {
              return const Center(child: Text('Chưa có công thức nào.'));
            }
            return RefreshIndicator(
              onRefresh: () async {
                context.read<RecipeBloc>().add(LoadAllRecipes());
              },
              child: _buildRecipesView(state.recipes),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/recipes/add'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildRecipesView(List<Recipe> recipes) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        final recipe = recipes[index];
        final recipeBloc = context.read<RecipeBloc>();
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () async {
              await context.push('/recipes/${recipe.id}');
              recipeBloc.add(LoadAllRecipes());
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (recipe.imageUrl != null)
                  Image.network(
                    recipe.imageUrl!,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox(
                      height: 150,
                      child: Center(
                          child: Icon(Icons.image_not_supported,
                              color: Colors.grey)),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(recipe.name,
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 4),
                      Text(recipe.description ?? '',
                          maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.timer_outlined,
                              size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text('${recipe.cookTimeMinutes ?? '?'} phút'),
                          const SizedBox(width: 16),
                          const Icon(Icons.person_outline,
                              size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text('${recipe.servingSize ?? '?'} người ăn'),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
