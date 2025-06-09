import 'dart:async';

import 'package:stock_mate/core/di/injection_container.dart';
import 'package:stock_mate/features/auth/repositories/auth_repository.dart';

class TokenRefreshService {
  Timer? _refreshTimer;

  void startAutoRefresh() {
    // Hủy timer cũ nếu có
    _refreshTimer?.cancel();

    // Thiết lập timer mới
    _refreshTimer = Timer.periodic(const Duration(minutes: 59), (_) async {
      try {
        await getIt<AuthRepository>().refreshToken();
        print('Token refreshed successfully');
      } catch (e) {
        print('Failed to refresh token: $e');
      }
    });
  }

  void stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  void dispose() {
    stopAutoRefresh();
  }
}
