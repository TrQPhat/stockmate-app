import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stock_mate/bloc/dish/dish_bloc.dart';
import 'package:stock_mate/bloc/dish/dish_event.dart';
import 'package:stock_mate/bloc/note/note_bloc.dart';
import 'package:stock_mate/bloc/note/note_state.dart';
import 'package:stock_mate/core/config/app_config.dart';
import 'package:stock_mate/models/dish.dart';
import 'package:stock_mate/models/mock_data.dart';
import 'package:stock_mate/models/note.dart';
import '../widgets/notes_section.dart';
import 'package:stock_mate/core/theme/app_theme.dart';

class DishDetailScreen extends StatefulWidget {
  final Dish dish;

  const DishDetailScreen({
    super.key,
    required this.dish,
  });

  @override
  State<DishDetailScreen> createState() => _DishDetailScreenState();
}

class _DishDetailScreenState extends State<DishDetailScreen> {
  bool _isFavorited = false;

  @override
  void initState() {
    super.initState();
    _isFavorited = widget.dish.isFavorited;
  }

  void _toggleFavorite() {
    context.read<DishBloc>().add(ToggleFavoriteDish(widget.dish.id!));
    setState(() {
      _isFavorited = !_isFavorited;
    });
  }

  void _handleSaveDish() {
    context.read<DishBloc>().add(AddDish(widget.dish));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Đã lưu món ăn '${widget.dish.name}' vào danh sách."),
        backgroundColor: AppTheme.primaryGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDishInfo(),
                _buildInstructions(),
                if (!widget.dish.isAISuggested)
                  NotesSection(
                    dishId: widget.dish.id ?? 0,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            widget.dish.imageUrl != null && widget.dish.imageUrl!.isNotEmpty
                ? Image.network(
                    "${AppConfig.rootImagePath}/${widget.dish.imageUrl!}",
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppTheme.primaryOrange.withOpacity(0.1),
                        child: const Icon(
                          Icons.restaurant,
                          size: 80,
                          color: AppTheme.primaryOrange,
                        ),
                      );
                    },
                  )
                : Container(
                    color: AppTheme.primaryOrange.withOpacity(0.1),
                    child: const Icon(
                      Icons.restaurant,
                      size: 80,
                      color: AppTheme.primaryOrange,
                    ),
                  ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.dish.isAISuggested)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.purple, Colors.pink],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.auto_awesome,
                              size: 16, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'Gợi ý món ăn',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    widget.dish.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        if (widget.dish.isAISuggested)
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: _handleSaveDish,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF56ab2f), // Green lime sáng
                      Color(0xFFA8E063), // Light green pastel
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Text(
                  'SAVE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          )
        else
          IconButton(
            onPressed: _toggleFavorite,
            icon: Icon(
              _isFavorited ? Icons.favorite : Icons.favorite_border,
              color: _isFavorited ? Colors.red : Colors.white,
            ),
          ),
      ],
    );
  }

  Widget _buildDishInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.dish.description,
            style: const TextStyle(
              fontSize: 18,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildInfoChip(
                icon: Icons.access_time,
                label: '${widget.dish.cookTimeMinutes} phút',
                color: AppTheme.primaryOrange,
              ),
              if (!widget.dish.isAISuggested) ...[
                const SizedBox(width: 12),
                BlocBuilder<NotesBloc, NotesState>(
                  builder: (context, state) {
                    if (state is NotesLoaded) {
                      return _buildInfoChip(
                        icon: Icons.comment,
                        label: '${state.notes.length} bình luận',
                        color: AppTheme.primaryGreen,
                      );
                    } else {
                      return _buildInfoChip(
                        icon: Icons.comment,
                        label: '0 bình luận',
                        color: AppTheme.primaryGreen,
                      );
                    }
                  },
                ),
              ]
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions() {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.restaurant_menu, color: AppTheme.primaryOrange),
                  SizedBox(width: 8),
                  Text(
                    '🍳 Hướng Dẫn Nấu Ăn',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...(() {
                final indices = RegExp(r'(?=\d+\.\s+)')
                    .allMatches(widget.dish.instructions)
                    .map((match) => match.start)
                    .toList();
                indices.add(widget.dish.instructions.length);
                final steps = <String>[];
                for (int i = 0; i < indices.length - 1; i++) {
                  final start = indices[i];
                  final end = indices[i + 1];
                  steps.add(
                      widget.dish.instructions.substring(start, end).trim());
                }
                return steps.asMap().entries.map((entry) {
                  int index = entry.key;
                  String step = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryOrange,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            step.replaceFirst(RegExp(r'^\d+\.\s*'), ''),
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppTheme.textPrimary,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList();
              })()
            ],
          ),
        ),
      ),
    );
  }
}
