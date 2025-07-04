import 'package:intl/intl.dart';

class AppFormat {
  static String formatCurrency(int amount) {
    String formatted = amount.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
    return "$formattedđ";
  }

  static String formatFriendlyTime(DateTime dateTime) {
    try {
      final now = DateTime.now();
      final localTime = dateTime.toLocal();
      final difference = now.difference(localTime);

      final isToday = now.day == localTime.day &&
          now.month == localTime.month &&
          now.year == localTime.year;

      final isYesterday = now
                  .subtract(
                    const Duration(days: 1),
                  )
                  .day ==
              localTime.day &&
          now
                  .subtract(
                    const Duration(days: 1),
                  )
                  .month ==
              localTime.month &&
          now
                  .subtract(
                    const Duration(days: 1),
                  )
                  .year ==
              localTime.year;

      if (isToday) {
        return DateFormat('HH:mm').format(localTime);
      } else if (isYesterday) {
        return 'Hôm qua';
      } else if (difference.inDays < 7) {
        // Tự định nghĩa tên thứ tiếng Việt thay vì dùng 'EEEE' với locale 'vi'
        const weekdays = [
          'Chủ Nhật',
          'Thứ Hai',
          'Thứ Ba',
          'Thứ Tư',
          'Thứ Năm',
          'Thứ Sáu',
          'Thứ Bảy'
        ];
        return weekdays[localTime.weekday % 7]; // weekday 1=Monday, 7=Sunday
      } else if (now.year == localTime.year) {
        return DateFormat('dd/MM').format(localTime);
      } else {
        return DateFormat('dd/MM/yyyy').format(localTime);
      }
    } catch (e) {
      print('Error formatting date: $e');
      return 'Không rõ';
    }
  }
}
