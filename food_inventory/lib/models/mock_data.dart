import '../models/note.dart';

class MockData {
  static List<Note> getDishNotes(int dishId) {
    return [
      Note(
        id: 1,
        dishId: dishId,
        content:
            'Mình đã thử làm theo công thức này và rất ngon! Nước dùng thật sự đậm đà. Lần sau sẽ thêm chút xương ống để ngọt hơn.',
        userId: 4,
        author: 'Minh Anh',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Note(
        id: 2,
        dishId: dishId,
        content:
            'Có thể thay thế xương bò bằng xương heo không ạ? Gia đình mình không ăn thịt bò.',
        userId: 2,
        author: 'Thu Hà',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Note(
        id: 3,
        dishId: dishId,
        content:
            'Mẹo nhỏ: rang gừng và hành tây trước khi ninh sẽ cho nước dùng thơm hơn nhé!',
        userId: 6,
        author: 'Chef Tuấn',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];
  }
}
