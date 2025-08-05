// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:equatable/equatable.dart';

// import '../../models/user.dart';
// import '../../repositories/auth_repository.dart';

// part 'auth_event.dart';
// part 'auth_state.dart';

// class AuthBloc extends Bloc<AuthEvent, AuthState> {
//   final AuthRepository _authRepository;

//   AuthBloc(this._authRepository) : super(AuthInitial()) {
//     on<LoginRequested>(_onLoginRequested);
//     on<RegisterRequested>(_onRegisterRequested);
//     on<LogoutRequested>(_onLogoutRequested);
//     on<CheckAuthStatus>(_onCheckAuthStatus);
//     on<RefreshToken>(_onRefreshToken);
//   }

//   Future<void> _onLoginRequested(
//     LoginRequested event,
//     Emitter<AuthState> emit,
//   ) async {
//     emit(AuthLoading());

//     try {
//       final user = await _authRepository.login(
//           event.email, event.password, event.rememberMe);
//       emit(AuthSuccess(user));
//     } catch (e) {
//       emit(AuthFailure(e.toString()));
//     }
//   }

//   Future<void> _onRegisterRequested(
//     RegisterRequested event,
//     Emitter<AuthState> emit,
//   ) async {
//     emit(AuthLoading());

//     try {
//       final user = await _authRepository.register(
//         email: event.email,
//         password: event.password,
//         fullName: event.fullName,
//         phone: event.phone,
//         gender: event.gender,
//       );
//       emit(AuthSuccess(user));
//     } catch (e) {
//       emit(AuthFailure(e.toString()));
//     }
//   }

//   Future<void> _onLogoutRequested(
//     LogoutRequested event,
//     Emitter<AuthState> emit,
//   ) async {
//     await _authRepository.logout();
//     emit(AuthInitial());
//   }

//   Future<void> _onCheckAuthStatus(
//     CheckAuthStatus event,
//     Emitter<AuthState> emit,
//   ) async {
//     final isLoggedIn = await _authRepository.isLoggedIn();
//     if (isLoggedIn) {
//       final user = await _authRepository.getCurrentUser();
//       if (user != null) {
//         emit(AuthSuccess(user));
//       } else {
//         emit(AuthInitial());
//       }
//     } else {
//       emit(AuthInitial());
//     }
//   }

//   Future<void> _onRefreshToken(
//     RefreshToken event,
//     Emitter<AuthState> emit,
//   ) async {
//     final success = await _authRepository.refreshToken();

//     if (success) {
//       emit(AuthSuccess(User(
//         id: 0,
//         userId: "jadsaskhjalsdlka",
//         email: '',
//         createdAt: DateTime.now(),
//         updatedAt: DateTime.now(),
//       )));
//     } else {
//       emit(const AuthFailure("Không thành công"));
//     }
//   }
// }

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../models/user.dart';
import '../../repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<GoogleLoginRequested>(_onGoogleLoginRequested); // Thêm handler
    on<LogoutRequested>(_onLogoutRequested);
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<RefreshToken>(_onRefreshToken);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final user = await _authRepository.login(
          event.email, event.password, event.rememberMe);
      emit(AuthSuccess(user));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      await _authRepository.register(
        email: event.email,
        password: event.password,
        fullName: event.fullName,
        phone: event.phone,
        gender: event.gender,
      );
      // Sau khi đăng ký thành công, có thể chuyển sang trạng thái yêu cầu xác thực email
      emit(AuthInitial()); // Hoặc một state mới `RegistrationSuccess`
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  // Thêm handler cho Google Login
  Future<void> _onGoogleLoginRequested(
    GoogleLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.signInWithGoogle();
      emit(AuthSuccess(user));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.logout();
    emit(AuthInitial());
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    final isLoggedIn = await _authRepository.isLoggedIn();
    if (isLoggedIn) {
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        emit(AuthSuccess(user));
      } else {
        emit(AuthInitial());
      }
    } else {
      emit(AuthInitial());
    }
  }

  Future<void> _onRefreshToken(
    RefreshToken event,
    Emitter<AuthState> emit,
  ) async {
    final success = await _authRepository.refreshToken();

    if (success) {
      emit(AuthSuccess(User(
        id: 0,
        email: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      )));
    } else {
      emit(const AuthFailure("Không thành công"));
    }
  }
}
