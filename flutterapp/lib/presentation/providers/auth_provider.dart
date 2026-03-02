import 'package:flutter/foundation.dart';
import '../../core/models/auth_state.dart';
import '../../core/models/user_model.dart';
import '../../core/usecases/check_auth_usecase.dart';
import '../../core/usecases/login_usecase.dart';
import '../../core/usecases/logout_usecase.dart';
import '../../core/usecases/register_usecase.dart';

class AuthProvider extends ChangeNotifier {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutUseCase _logoutUseCase;
  final CheckAuthUseCase _checkAuthUseCase;

  AuthState _authState = AuthState.initial();

  AuthProvider({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required LogoutUseCase logoutUseCase,
    required CheckAuthUseCase checkAuthUseCase,
  })  : _loginUseCase = loginUseCase,
        _registerUseCase = registerUseCase,
        _logoutUseCase = logoutUseCase,
        _checkAuthUseCase = checkAuthUseCase;

  AuthState get authState => _authState;

  UserModel? get currentUser => _authState.user;

  bool get isAuthenticated => _authState.isAuthenticated;

  bool get isLoading => _authState.isLoading;

  String? get errorMessage => _authState.errorMessage;

  Future<void> checkAuth() async {
    try {
      _authState = AuthState.loading();
      notifyListeners();

      final user = await _checkAuthUseCase.execute();

      if (user != null) {
        _authState = AuthState.authenticated(user);
      } else {
        _authState = AuthState.unauthenticated();
      }
    } catch (e) {
      _authState = AuthState.unauthenticated(
        errorMessage: 'Erro ao verificar autenticação',
      );
    } finally {
      notifyListeners();
    }
  }

  /// Login with email and password
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      _authState = AuthState.loading();
      notifyListeners();

      final user = await _loginUseCase.execute(
        email: email,
        password: password,
      );

      _authState = AuthState.authenticated(user);
      notifyListeners();
      return true;
    } catch (e) {
      _authState = AuthState.unauthenticated(
        errorMessage: _extractErrorMessage(e),
      );
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required List<int> favoriteGenres,
  }) async {
    try {
      _authState = AuthState.loading();
      notifyListeners();

      final user = await _registerUseCase.execute(
        name: name,
        email: email,
        password: password,
        favoriteGenres: favoriteGenres,
      );

      // Automatic login after registration
      _authState = AuthState.authenticated(user);
      notifyListeners();
      return true;
    } catch (e) {
      _authState = AuthState.unauthenticated(
        errorMessage: _extractErrorMessage(e),
      );
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _logoutUseCase.execute();
      _authState = AuthState.unauthenticated();
      notifyListeners();
    } catch (e) {
      // Even if logout fails, reset to unauthenticated state
      _authState = AuthState.unauthenticated(
        errorMessage: 'Erro ao fazer logout',
      );
      notifyListeners();
    }
  }

  void clearError() {
    if (_authState.errorMessage != null) {
      _authState = AuthState.unauthenticated();
      notifyListeners();
    }
  }

  String _extractErrorMessage(dynamic error) {
    if (error is Exception) {
      final message = error.toString();
      // Remove "Exception: " prefix
      return message.replaceFirst('Exception: ', '');
    }
    return error.toString();
  }
}
