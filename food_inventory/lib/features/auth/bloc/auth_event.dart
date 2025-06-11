part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  final bool rememberMe;

  const LoginRequested(
      {required this.email, required this.password, required this.rememberMe});

  @override
  List<Object> get props => [email, password];
}

class RegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String fullName;
  final String? phone;
  final String gender;

  const RegisterRequested({
    required this.email,
    required this.password,
    required this.fullName,
    required this.gender,
    this.phone,
  });

  @override
  List<Object?> get props => [email, password, fullName, phone];
}

class LogoutRequested extends AuthEvent {}

// Thêm event mới
class CheckAuthStatus extends AuthEvent {}
