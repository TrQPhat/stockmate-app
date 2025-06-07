import 'package:intl/intl.dart';

class AppDateUtils {
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }
  
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }
  
  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Hôm nay';
    } else if (difference.inDays == 1) {
      return 'Hôm qua';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks tuần trước';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months tháng trước';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years năm trước';
    }
  }
  
  static int getDaysUntilExpire(DateTime expireDate) {
    final now = DateTime.now();
    return expireDate.difference(now).inDays;
  }
  
  static bool isExpired(DateTime expireDate) {
    return DateTime.now().isAfter(expireDate);
  }
  
  static bool isExpiringSoon(DateTime expireDate, {int days = 3}) {
    final daysUntilExpire = getDaysUntilExpire(expireDate);
    return daysUntilExpire >= 0 && daysUntilExpire <= days;
  }
}
