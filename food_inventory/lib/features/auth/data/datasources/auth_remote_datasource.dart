import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthRemoteDataSource {
  final SupabaseClient _supabase;

  AuthRemoteDataSource(this._supabase);

  Future<UserModel> login(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Đăng nhập thất bại');
      }

      return UserModel(
        id: response.user!.id,
        email: response.user!.email!,
        name: response.user!.userMetadata?['name'] ?? '',
        avatarUrl: response.user!.userMetadata?['avatar_url'],
      );
    } catch (e) {
      throw Exception('Lỗi đăng nhập: ${e.toString()}');
    }
  }

  Future<UserModel> register(String email, String password, String name) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );

      if (response.user == null) {
        throw Exception('Đăng ký thất bại');
      }

      return UserModel(
        id: response.user!.id,
        email: response.user!.email!,
        name: name,
        avatarUrl: response.user!.userMetadata?['avatar_url'],
      );
    } catch (e) {
      throw Exception('Lỗi đăng ký: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw Exception('Lỗi đăng xuất: ${e.toString()}');
    }
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      return UserModel(
        id: user.id,
        email: user.email!,
        name: user.userMetadata?['name'] ?? '',
        avatarUrl: user.userMetadata?['avatar_url'],
      );
    } catch (e) {
      return null;
    }
  }

  Future<bool> isLoggedIn() async {
    return _supabase.auth.currentUser != null;
  }
}
