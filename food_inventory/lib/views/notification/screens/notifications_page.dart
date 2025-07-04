import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stock_mate/core/theme/app_theme.dart';

enum NotificationType { success, warning, error, info }

class FoodNotification {
  final String id;
  final NotificationType type;
  final String? category;
  final String title;
  final String message;
  final String time;
  bool isRead;

  FoodNotification({
    required this.id,
    required this.type,
    this.category,
    required this.title,
    required this.message,
    required this.time,
    this.isRead = false,
  });
}

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  String _filter = 'all'; // 'all' or 'unread'

  final List<FoodNotification> _notifications = [
    FoodNotification(
      id: '1',
      type: NotificationType.warning,
      category: 'dairy',
      title: 'Sữa sắp hết hạn',
      message:
          'Hộp sữa tươi trong tủ lạnh sẽ hết hạn vào ngày mai. Hãy sử dụng sớm!',
      time: '2 giờ trước',
      isRead: false,
    ),
    FoodNotification(
      id: '2',
      type: NotificationType.success,
      category: 'vegetables',
      title: 'Công thức mới được thêm',
      message:
          'Salad rau củ tươi ngon đã được thêm vào danh sách yêu thích của bạn.',
      time: '4 giờ trước',
      isRead: false,
    ),
    FoodNotification(
      id: '3',
      type: NotificationType.error,
      category: 'meat',
      title: 'Thịt đã hết hạn',
      message:
          'Thịt bò trong tủ lạnh đã quá hạn sử dụng. Vui lòng kiểm tra và loại bỏ.',
      time: '6 giờ trước',
      isRead: true,
    ),
    FoodNotification(
      id: '4',
      type: NotificationType.info,
      category: 'fruits',
      title: 'Mùa trái cây mới',
      message:
          'Xoài, vải và nhãn đang trong mùa. Đây là thời điểm tốt để mua sắm!',
      time: '1 ngày trước',
      isRead: false,
    ),
    FoodNotification(
      id: '5',
      type: NotificationType.warning,
      category: 'grains',
      title: 'Gạo sắp hết',
      message:
          'Lượng gạo trong nhà chỉ còn đủ dùng 3 ngày. Cần mua thêm gạo mới.',
      time: '1 ngày trước',
      isRead: true,
    ),
    FoodNotification(
      id: '6',
      type: NotificationType.success,
      category: 'snacks',
      title: 'Đặt hàng thành công',
      message:
          'Đơn hàng bánh kẹo của bạn đã được xác nhận và sẽ giao trong 2 ngày.',
      time: '2 ngày trước',
      isRead: false,
    ),
  ];

  List<FoodNotification> get _filteredNotifications {
    if (_filter == 'unread') {
      return _notifications.where((n) => !n.isRead).toList();
    }
    return _notifications;
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  void _markAsRead(String id) {
    setState(() {
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        _notifications[index].isRead = true;
      }
    });
  }

  void _deleteNotification(String id) {
    setState(() {
      _notifications.removeWhere((n) => n.id == id);
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification.isRead = true;
      }
    });
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return Icons.check_circle;
      case NotificationType.warning:
        return Icons.warning;
      case NotificationType.error:
        return Icons.error;
      case NotificationType.info:
        return Icons.info;
    }
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return AppTheme.successGreen;
      case NotificationType.warning:
        return AppTheme.warningOrange;
      case NotificationType.error:
        return AppTheme.errorRed;
      case NotificationType.info:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppTheme.primaryGreen,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(0),
                bottomRight: Radius.circular(0),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.notifications,
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Thông báo thực phẩm',
                            style: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Quản lý thông báo về thực phẩm của bạn',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: AppTheme.accentGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_unreadCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryOrange,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$_unreadCount mới',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Filter and Actions
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SingleChildScrollView(
                  // Thêm cuộn ngang
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterButton(
                          'Tất cả (${_notifications.length})', 'all'),
                      const SizedBox(width: 8),
                      _buildFilterButton('Chưa đọc ($_unreadCount)', 'unread'),
                      if (_unreadCount > 0)
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: TextButton(
                            onPressed: _markAllAsRead,
                            style: TextButton.styleFrom(
                              foregroundColor: AppTheme.primaryGreen,
                            ),
                            child: Text(
                              'Đánh dấu tất cả đã đọc',
                              style: GoogleFonts.inter(fontSize: 12),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Notifications List
          Expanded(
            child: _filteredNotifications.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredNotifications.length,
                    itemBuilder: (context, index) {
                      final notification = _filteredNotifications[index];
                      return _buildNotificationCard(notification);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String text, String value) {
    final isSelected = _filter == value;
    return ElevatedButton(
      onPressed: () => setState(() => _filter = value),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? AppTheme.primaryGreen : Colors.white,
        foregroundColor: isSelected ? Colors.white : AppTheme.primaryGreen,
        side: const BorderSide(color: AppTheme.primaryGreen),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(text, style: GoogleFonts.inter(fontSize: 12)),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.notifications_none,
            size: 64,
            color: AppTheme.textLight,
          ),
          const SizedBox(height: 16),
          Text(
            'Không có thông báo',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _filter == 'unread'
                ? 'Bạn đã đọc hết tất cả thông báo!'
                : 'Chưa có thông báo nào.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(FoodNotification notification) {
    final notificationColor = _getNotificationColor(notification.type);
    final notificationIcon = _getNotificationIcon(notification.type);
    final categoryColor = notification.category != null
        ? AppTheme.categoryColors[notification.category!]
        : null;
    final categoryIcon = notification.category != null
        ? AppTheme.categoryIcons[notification.category!]
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: !notification.isRead
            ? const Border(
                left: BorderSide(color: AppTheme.primaryOrange, width: 4))
            : null,
        boxShadow: const [
          BoxShadow(
            color: AppTheme.shadowColor,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notification Type Icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: notificationColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                notificationIcon,
                color: notificationColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: !notification.isRead
                                ? AppTheme.textPrimary
                                : AppTheme.textSecondary,
                          ),
                        ),
                      ),
                      if (categoryIcon != null && categoryColor != null)
                        Container(
                          padding: const EdgeInsets.all(4),
                          margin: const EdgeInsets.only(left: 8),
                          decoration: BoxDecoration(
                            color: categoryColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Icon(
                            categoryIcon,
                            color: categoryColor,
                            size: 16,
                          ),
                        ),
                      if (!notification.isRead)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryOrange,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: !notification.isRead
                          ? AppTheme.textPrimary
                          : AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    notification.time,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppTheme.textLight,
                    ),
                  ),
                ],
              ),
            ),

            // Actions
            Column(
              children: [
                if (!notification.isRead)
                  IconButton(
                    onPressed: () => _markAsRead(notification.id),
                    icon: const Icon(Icons.check, size: 20),
                    color: AppTheme.primaryGreen,
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                IconButton(
                  onPressed: () => _deleteNotification(notification.id),
                  icon: const Icon(Icons.close, size: 20),
                  color: AppTheme.errorRed,
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
