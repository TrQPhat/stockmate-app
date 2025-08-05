import 'package:stock_mate/core/config/app_config.dart';
import '../core/network/dio_client.dart';
import 'package:stock_mate/models/note.dart';

class NoteRepository {
  final DioClient _dioClient;

  NoteRepository(this._dioClient);

  final baseUrl = "${AppConfig.baseUrl}/notes";

  // Lấy danh sách ghi chú cho một món ăn (dish)
  Future<List<Note>> getNotesByDishId(int dishId) async {
    try {
      final response = await _dioClient.get('$baseUrl/$dishId');
      final List<dynamic> data = response.data ?? [];
      return data.map((json) => Note.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Không thể tải ghi chú: ${e.toString()}');
    }
  }

  // Thêm ghi chú
  Future<Note> createNote(Note note) async {
    try {
      final response = await _dioClient.post(
        '$baseUrl/',
        data: note.toJson(),
      );

      return Note.fromJson(response.data);
    } catch (e) {
      throw Exception('Không thể thêm ghi chú: ${e.toString()}');
    }
  }

  // Xoá ghi chú
  Future<void> deleteNote(int noteId) async {
    try {
      await _dioClient.delete('$baseUrl/$noteId');
    } catch (e) {
      throw Exception('Không thể xoá ghi chú: ${e.toString()}');
    }
  }
}
