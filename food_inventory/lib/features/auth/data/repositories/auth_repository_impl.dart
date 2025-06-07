import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<User> login(String email, String password) async {
    final result = await remoteDataSource.login(email, password);
    return result;
  }

  @override
  Future<User> register(String email, String password, String name) async {
    final result = await remoteDataSource.register(email, password, name);
    return result;
  }

  @override
  Future<void> logout() async {
    await remoteDataSource.logout();
  }

  @override
  Future<User?> getCurrentUser() async {
    final result = await remoteDataSource.getCurrentUser();
    return result;
  }

  @override
  Future<bool> isLoggedIn() async {
    return await remoteDataSource.isLoggedIn();
  }
}
