import 'package:equatable/equatable.dart';
import 'package:stock_mate/models/note.dart';

abstract class NotesEvent extends Equatable {
  const NotesEvent();

  @override
  List<Object> get props => [];
}

class LoadNotes extends NotesEvent {
  final int dishId;

  const LoadNotes(this.dishId);

  @override
  List<Object> get props => [dishId];
}

class PostNote extends NotesEvent {
  final Note note;

  const PostNote(this.note);

  @override
  List<Object> get props => [note];
}

class DeleteNote extends NotesEvent {
  final int noteId;

  const DeleteNote(this.noteId);

  @override
  List<Object> get props => [noteId];
}
