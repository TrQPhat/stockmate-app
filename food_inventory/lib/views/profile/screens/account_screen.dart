import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stock_mate/bloc/auth/auth_bloc.dart';
import 'package:stock_mate/core/config/app_config.dart';
import 'package:stock_mate/core/di/injection_container.dart';
import 'package:stock_mate/core/theme/app_theme.dart';
import 'package:stock_mate/models/user.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final User? _user;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = getIt<SharedPreferences>();
    final name = prefs.getString(AppConfig.userNameKey);
    final email = prefs.getString(AppConfig.userEmailKey);
    final userJson = prefs.getString(AppConfig.userKey);
    if (userJson != null) {
      _user = User.fromJson(jsonDecode(userJson));
    } else {
      print("user null");
      _user = null;
    }

    setState(() {
      _nameController.text = name ?? "Người dùng ẩn danh";
      _emailController.text = email ?? "Không xác định";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Tài khoản'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              _buildProfileSection(_user!),
              const SizedBox(height: 20),
              _buildSettingsSection(context),
            ],
          ),
        ));
  }

  Widget _buildProfileSection(User user) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.transparent,
      child: Column(
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage('assets/images/placeholder_avatar.png'),
          ),
          const SizedBox(height: 16),
          Text(
            user.fullName!,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            user.email,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _showEditProfileDialog(context, user),
            child: const Text('Chỉnh sửa hồ sơ'),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chỉnh sửa hồ sơ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Họ tên'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              // TODO: Cập nhật user vào SharedPreferences
              Navigator.pop(context);
              setState(() {});
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Column(
      children: [
        _buildSettingItem(
          context,
          icon: Icons.notifications,
          title: 'Thông báo',
          onTap: () {
            // TODO: Navigate to notifications settings screen
          },
        ),
        _buildSettingItem(
          context,
          icon: Icons.security,
          title: 'Bảo mật',
          onTap: () {
            // TODO: Navigate to security settings screen
          },
        ),
        _buildSettingItem(
          context,
          icon: Icons.language,
          title: 'Ngôn ngữ',
          onTap: () {
            // TODO: Show language selection dialog
          },
        ),
        _buildSettingItem(
          context,
          icon: Icons.help,
          title: 'Trung tâm hỗ trợ',
          onTap: () {
            // TODO: Navigate to help center screen
          },
        ),
        _buildSettingItem(
          context,
          icon: Icons.info,
          title: 'Về chúng tôi',
          onTap: () {
            // TODO: Navigate to about screen
          },
        ),
        _buildSettingItem(
          context,
          icon: Icons.logout,
          title: 'Đăng xuất',
          onTap: () {
            _showLogoutConfirmDialog(context);
          },
          textColor: Colors.red,
        ),
      ],
    );
  }

  // Hiển thị dialog xác nhận đăng xuất
  void _showLogoutConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy',
                style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              // Gọi event đăng xuất
              context.read<AuthBloc>().add(LogoutRequested());

              // Điều hướng về trang login
              context.go('/login');
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed, // Sử dụng màu từ theme
              foregroundColor: Colors.white,
            ),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title, style: TextStyle(color: textColor)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
