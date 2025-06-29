import '../models/dish.dart';
import '../models/note.dart';

class MockData {
  static List<Dish> getAISuggestedDishes() {
    return [
      Dish(
        id: 'ai-1',
        name: 'Phở Bò Truyền Thống',
        description:
            'Món phở bò đậm đà với nước dùng ninh từ xương bò trong 12 tiếng',
        instructions: '''1. Ninh xương bò với hành tây, gừng trong 12 tiếng
2. Chuẩn bị bánh phở tươi, ngâm nước ấm
3. Thái thịt bò tái mỏng, luộc thịt chín
4. Chuẩn bị hành lá, ngò gai, giá đỗ
5. Trình bày tô phở và thưởng thức nóng''',
        imageUrl:
            'https://images.unsplash.com/photo-1555126634-323283e090fa?w=400',
        cookTimeMinutes: 180,
        storageId: 1,
        isAISuggested: true,
      ),
      Dish(
        id: 'ai-2',
        name: 'Bánh Mì Thịt Nướng',
        description:
            'Bánh mì giòn rụm với thịt nướng thơm lừng và rau sống tươi mát',
        instructions: '''1. Ướp thịt heo với gia vị trong 2 tiếng
2. Nướng thịt trên than hoa hoặc lò nướng
3. Chuẩn bị rau sống: dưa leo, cà rót, ngò
4. Nướng bánh mì cho giòn
5. Lắp ráp bánh mì và thưởng thức''',
        imageUrl:
            'https://images.unsplash.com/photo-1558030006-450675393462?w=400',
        cookTimeMinutes: 45,
        storageId: 1,
        isAISuggested: true,
      ),
      Dish(
        id: 'ai-3',
        name: 'Cơm Tấm Sài Gòn',
        description: 'Cơm tấm với sườn nướng, chả trứng và nước mắm chua ngọt',
        instructions: '''1. Ướp sườn heo với nước mắm, đường, tỏi
2. Nướng sườn trên than hoa
3. Làm chả trứng hấp
4. Pha nước mắm chua ngọt
5. Trình bày với dưa leo, cà rót''',
        imageUrl:
            'https://images.unsplash.com/photo-1559847844-d721426d6edc?w=400',
        cookTimeMinutes: 60,
        storageId: 1,
        isAISuggested: true,
      ),
      Dish(
        id: 'ai-4',
        name: 'Bún Bò Huế',
        description: 'Bún bò Huế cay nồng với hương vị đặc trưng miền Trung',
        instructions: '''1. Nấu nước dùng từ xương heo, bò
2. Thêm mắm ruốc, sa tế cho đậm đà
3. Chuẩn bị bún tươi
4. Thái thịt bò, chả cua
5. Trang trí với rau thơm, hành tây''',
        imageUrl:
            'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=400',
        cookTimeMinutes: 120,
        storageId: 1,
        isAISuggested: true,
      ),
    ];
  }

  static List<Dish> getUserDishes() {
    return [
      Dish(
        id: 'user-1',
        name: 'Canh Chua Cá Lóc',
        description: 'Canh chua cá lóc với dứa, đậu bắp và rau muống',
        instructions: '''1. Làm sạch cá lóc, cắt khúc vừa ăn
2. Nấu nước dùng từ xương cá
3. Thêm me, cà chua, dứa
4. Cho cá vào nấu chín
5. Thêm rau muống, đậu bắp
6. Nêm nếm vừa ăn''',
        imageUrl:
            'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=400',
        cookTimeMinutes: 30,
        storageId: 1,
        isAISuggested: false,
      ),
    ];
  }

  static List<Note> getDishNotes(String dishId) {
    return [
      Note(
        id: '1',
        dishId: dishId,
        content:
            'Mình đã thử làm theo công thức này và rất ngon! Nước dùng thật sự đậm đà. Lần sau sẽ thêm chút xương ống để ngọt hơn.',
        quantity: 4,
        author: 'Minh Anh',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Note(
        id: '2',
        dishId: dishId,
        content:
            'Có thể thay thế xương bò bằng xương heo không ạ? Gia đình mình không ăn thịt bò.',
        quantity: 2,
        author: 'Thu Hà',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Note(
        id: '3',
        dishId: dishId,
        content:
            'Mẹo nhỏ: rang gừng và hành tây trước khi ninh sẽ cho nước dùng thơm hơn nhé!',
        quantity: 6,
        author: 'Chef Tuấn',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];
  }
}
