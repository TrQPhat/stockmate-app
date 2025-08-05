import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stock_mate/bloc/note/note_bloc.dart';
import 'package:stock_mate/bloc/note/note_event.dart';
import 'package:stock_mate/bloc/note/note_state.dart';
import 'package:stock_mate/core/config/app_config.dart';
import 'package:stock_mate/core/di/injection_container.dart';
import 'package:stock_mate/models/note.dart';
import 'package:stock_mate/core/theme/app_theme.dart';

class NotesSection extends StatefulWidget {
  final int dishId;

  const NotesSection({
    super.key,
    required this.dishId,
  });

  @override
  State<NotesSection> createState() => _NotesSectionState();
}

class _NotesSectionState extends State<NotesSection> {
  final _noteController = TextEditingController();
  late final int _currentUserId;

  @override
  void initState() {
    super.initState();
    // Gửi sự kiện load note khi widget được tạo
    context.read<NotesBloc>().add(LoadNotes(widget.dishId));

    _currentUserId =
        getIt<SharedPreferences>().getInt(AppConfig.userIdKey) ?? -1;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildAddNoteSection(),
              const SizedBox(height: 20),
              BlocBuilder<NotesBloc, NotesState>(
                builder: (context, state) {
                  if (state is NotesLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is NotesLoaded) {
                    return _buildNotesList(state.notes);
                  } else if (state is NotesError) {
                    return Center(
                      child: Text(
                        state.message,
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Row(
      children: [
        Icon(Icons.comment, color: AppTheme.primaryGreen),
        SizedBox(width: 8),
        Text(
          '💬 Ghi Chú & Bình Luận',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildAddNoteSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryOrange.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '✍️ Thêm ghi chú của bạn',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _noteController,
            decoration: InputDecoration(
              hintText: 'Chia sẻ kinh nghiệm, mẹo vặt hoặc câu hỏi của bạn...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppTheme.primaryOrange),
              ),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Spacer(),
              ElevatedButton(
                onPressed: _addNote,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryOrange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Đăng'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotesList(List<Note> notes) {
    if (notes.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: const Column(
          children: [
            Icon(
              Icons.comment_outlined,
              size: 48,
              color: AppTheme.textSecondary,
            ),
            SizedBox(height: 12),
            Text(
              'Chưa có ghi chú nào',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondary,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Hãy là người đầu tiên chia sẻ kinh nghiệm!',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: notes.map((note) => _buildNoteItem(note)).toList(),
    );
  }

  // Widget _buildNoteItem(Note note) {
  //   return Container(
  //     margin: const EdgeInsets.only(bottom: 16),
  //     padding: const EdgeInsets.all(12),
  //     decoration: BoxDecoration(
  //       color: Colors.grey.shade50,
  //       borderRadius: BorderRadius.circular(8),
  //       border: Border.all(color: Colors.grey.shade200),
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           children: [
  //             CircleAvatar(
  //               radius: 16,
  //               backgroundColor: AppTheme.primaryOrange.withOpacity(0.1),
  //               child: Text(
  //                 note.userId == _currentUserId
  //                     ? 'U'
  //                     : note.author.isEmpty
  //                         ? 'No'
  //                         : note.author[0].toUpperCase(),
  //                 style: const TextStyle(
  //                   color: AppTheme.primaryOrange,
  //                   fontWeight: FontWeight.bold,
  //                   fontSize: 14,
  //                 ),
  //               ),
  //             ),
  //             const SizedBox(width: 8),
  //             Expanded(
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Row(
  //                     children: [
  //                       Text(
  //                         note.userId == _currentUserId
  //                             ? 'Bạn'
  //                             : note.author.isEmpty
  //                                 ? "Không xác định"
  //                                 : note.author,
  //                         style: const TextStyle(
  //                           fontWeight: FontWeight.w600,
  //                           fontSize: 14,
  //                           color: AppTheme.textPrimary,
  //                         ),
  //                       ),
  //                       const SizedBox(width: 8),
  //                       Container(
  //                         padding: const EdgeInsets.symmetric(
  //                             horizontal: 6, vertical: 2),
  //                         decoration: BoxDecoration(
  //                           color: AppTheme.primaryGreen.withOpacity(0.1),
  //                           borderRadius: BorderRadius.circular(10),
  //                         ),
  //                         child: Text(
  //                           _formatDate(note.createdAt),
  //                           style: const TextStyle(
  //                             fontSize: 12,
  //                             color: AppTheme.textSecondary,
  //                           ),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         ),
  //         const SizedBox(height: 8),
  //         Text(
  //           note.content,
  //           style: const TextStyle(
  //             fontSize: 14,
  //             color: AppTheme.textPrimary,
  //             height: 1.4,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  Widget _buildNoteItem(Note note) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppTheme.primaryOrange.withOpacity(0.1),
                    child: Text(
                      note.userId == _currentUserId
                          ? 'U'
                          : note.author.isEmpty
                              ? 'No'
                              : note.author[0].toUpperCase(),
                      style: const TextStyle(
                        color: AppTheme.primaryOrange,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              note.userId == _currentUserId
                                  ? 'Bạn'
                                  : note.author.isEmpty
                                      ? "Không xác định"
                                      : note.author,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryGreen.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                _formatDate(note.createdAt),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (note.userId == _currentUserId)
                Positioned(
                  top: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () => _onDeleteNote(note), // Hàm xử lý xóa
                    child: const Icon(
                      Icons.close,
                      size: 20,
                      color: Colors.grey,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            note.content,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textPrimary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  void _addNote() {
    if (_noteController.text.trim().isEmpty) return;
    if (_currentUserId == -1) return;
    final note = Note(
      id: DateTime.now().millisecondsSinceEpoch,
      dishId: widget.dishId,
      content: _noteController.text.trim(),
      userId: _currentUserId,
      author: 'Bạn',
      createdAt: DateTime.now(),
    );

    context.read<NotesBloc>().add(PostNote(note));
    _noteController.clear();
  }

  void _onDeleteNote(Note note) {
    context.read<NotesBloc>().add(DeleteNote(note.id));
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }
}
