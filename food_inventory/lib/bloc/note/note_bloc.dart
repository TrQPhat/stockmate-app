import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stock_mate/models/note.dart';
import 'note_event.dart';
import 'note_state.dart';
import 'package:stock_mate/repositories/note_repository.dart';

class NotesBloc extends Bloc<NotesEvent, NotesState> {
  final NoteRepository noteRepository;

  NotesBloc(this.noteRepository) : super(NotesInitial()) {
    on<LoadNotes>(_onLoadNotes);
    on<PostNote>(_onPostNote);
    on<DeleteNote>(_onDeleteNote);
  }

  Future<void> _onLoadNotes(LoadNotes event, Emitter<NotesState> emit) async {
    emit(NotesLoading());
    try {
      final notes = await noteRepository.getNotesByDishId(event.dishId);
      emit(NotesLoaded(notes));
    } catch (e) {
      emit(const NotesError('Không thể tải ghi chú'));
    }
  }

  Future<void> _onPostNote(PostNote event, Emitter<NotesState> emit) async {
    if (state is! NotesLoaded) return;

    final currentNotes = List<Note>.from((state as NotesLoaded).notes);

    try {
      final newNote = await noteRepository.createNote(event.note);
      currentNotes.insert(0, newNote); // Thêm note mới vào đầu danh sách
    } catch (e) {
      print('Gửi ghi chú thất bại: $e');
    }

    // Dù thành công hay thất bại, vẫn emit lại danh sách (cũ hoặc đã thêm)
    emit(NotesLoaded(currentNotes));
  }

  Future<void> _onDeleteNote(DeleteNote event, Emitter<NotesState> emit) async {
    if (state is! NotesLoaded) return;

    final currentNotes = List<Note>.from((state as NotesLoaded).notes);

    try {
      // Gọi API xoá
      await noteRepository.deleteNote(event.noteId);

      // Cập nhật danh sách nếu xoá thành công
      currentNotes.removeWhere((note) => note.id == event.noteId);
    } catch (e) {
      print("Lỗi khi xoá ghi chú: ${e.toString()}");
    }

    // Dù thành công hay thất bại, vẫn emit danh sách cũ (nếu thất bại thì không thay đổi gì)
    emit(NotesLoaded(currentNotes));
  }
}
