import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stock_mate/bloc/dish/dish_bloc.dart';
import 'package:stock_mate/bloc/dish/dish_event.dart';
import 'package:stock_mate/bloc/dish/dish_state.dart';
import 'package:stock_mate/core/di/injection_container.dart';
import 'package:stock_mate/core/theme/app_theme.dart';
import 'package:stock_mate/models/dish.dart';
import '../widgets/dish_card.dart';
import '../widgets/add_dish_dialog.dart';
import 'dish_detail_screen.dart';

class DishesScreen extends StatefulWidget {
  const DishesScreen({super.key});

  @override
  State<DishesScreen> createState() => _DishesScreenState();
}

class _DishesScreenState extends State<DishesScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  late final DishBloc _userDishBloc;
  late final DishBloc _suggestedDishBloc;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _userDishBloc = getIt<DishBloc>();
    _suggestedDishBloc = getIt<DishBloc>();

    // Load initial data
    _userDishBloc.add(LoadYourDishes());
    _suggestedDishBloc.add(LoadSuggestDishes());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _userDishBloc.close();
    _suggestedDishBloc.close();
    super.dispose();
  }

  void _toggleFavorite(int dishId, bool isUserDish) {
    if (isUserDish) {
      _userDishBloc.add(ToggleFavoriteDish(dishId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _userDishBloc),
        BlocProvider.value(value: _suggestedDishBloc),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.restaurant_menu, color: AppTheme.primaryOrange),
              SizedBox(width: 8),
              Text('🍳 Món Ăn Ngon',
                  style: TextStyle(color: AppTheme.textPrimary)),
            ],
          ),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: AppTheme.primaryOrange,
            labelColor: AppTheme.primaryOrange,
            unselectedLabelColor: AppTheme.textSecondary,
            tabs: const [
              Tab(icon: Icon(Icons.book), text: 'Món Của Tôi'),
              Tab(icon: Icon(Icons.auto_awesome), text: 'Gợi ý'),
            ],
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFFF8F0),
                Color(0xFFFFFBF5),
              ],
            ),
          ),
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildUserDishesTab(),
              _buildAISuggestionsTab(),
            ],
          ),
        ),
        floatingActionButton: _tabController.index == 0
            ? FloatingActionButton(
                backgroundColor: AppTheme.primaryOrange,
                onPressed: _showAddDishDialog,
                child: const Icon(Icons.add, color: Colors.white),
              )
            : null,
      ),
    );
  }

  Widget _buildAISuggestionsTab() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Column(
            children: [
              Text('✨ Món ăn gợi ý',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary)),
              SizedBox(height: 8),
              Text(
                'Những món ăn đề xuất dành riêng cho bạn',
                style: TextStyle(fontSize: 16, color: AppTheme.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        Expanded(
          child: BlocConsumer<DishBloc, DishState>(
            bloc: _suggestedDishBloc,
            listener: (context, state) {
              if (state is DishError) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi: ${state.message}')));
              }
            },
            builder: (context, state) {
              if (state is DishLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              final dishes = state is DishLoaded ? state.dishes : <Dish>[];
              return _buildDishGrid(
                dishes,
                canEdit: false,
                isUserDish: false,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUserDishesTab() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Column(
            children: [
              Text('📖 Món Ăn Của Tôi',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary)),
              SizedBox(height: 8),
              Text(
                'Quản lý các công thức nấu ăn cá nhân',
                style: TextStyle(fontSize: 16, color: AppTheme.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        Expanded(
          child: BlocConsumer<DishBloc, DishState>(
            bloc: _userDishBloc,
            listener: (context, state) {
              if (state is DishError) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi: ${state.message}')));
              }
            },
            builder: (context, state) {
              if (state is DishLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              final dishes = state is DishLoaded ? state.dishes : <Dish>[];
              return _buildDishGrid(
                dishes,
                canEdit: true,
                isUserDish: true,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDishGrid(List<Dish> dishes,
      {required bool canEdit, required bool isUserDish}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (dishes.isEmpty) {
          return SingleChildScrollView(
            child: Container(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryOrange.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.restaurant_menu,
                          size: 60, color: AppTheme.primaryOrange),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      canEdit ? '🍽️ Chưa có món ăn nào' : '🤖 Chưa có gợi ý',
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      canEdit
                          ? 'Hãy thêm món ăn đầu tiên của bạn!'
                          : 'Đang tải thêm các gợi ý dành cho bạn',
                      style: const TextStyle(
                          fontSize: 16, color: AppTheme.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    if (canEdit) ...[
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _showAddDishDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryOrange,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Thêm Món Mới'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: constraints.maxWidth > 600 ? 3 : 2,
            childAspectRatio: 0.6,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: dishes.length,
          itemBuilder: (context, index) => DishCard(
            dish: dishes[index],
            canEdit: canEdit,
            onTap: () => _navigateToDishDetail(dishes[index]),
            onDelete: canEdit
                ? () => _userDishBloc.add(DeleteDish(dishes[index].id!))
                : () => _userDishBloc.add(AddDish(
                    dishes[index])), //canEdit is true thì xoá ngược lại thì lưu
            onToggleFavorite: () =>
                _toggleFavorite(dishes[index].id!, isUserDish),
          ),
        );
      },
    );
  }

  void _navigateToDishDetail(Dish dish) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: _userDishBloc,
          child: DishDetailScreen(dish: dish),
        ),
        fullscreenDialog: true,
      ),
    );
  }

  void _showAddDishDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: AddDishDialog(onAddDish: (Dish dish) {
          _userDishBloc.add(AddDish(dish));
          Navigator.of(context).pop();
        }),
      ),
    );
  }
}
