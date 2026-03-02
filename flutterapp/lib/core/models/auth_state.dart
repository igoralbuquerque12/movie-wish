import 'user_model.dart';

/// Authentication state enum
enum AuthStatus {
  authenticated,
  unauthenticated,
  loading,
}

/// Authentication state with user data
class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? errorMessage;

  const AuthState({
    required this.status,
    this.user,
    this.errorMessage,
  });

  /// Initial unauthenticated state
  factory AuthState.initial() {
    return const AuthState(status: AuthStatus.unauthenticated);
  }

  /// Loading state
  factory AuthState.loading() {
    return const AuthState(status: AuthStatus.loading);
  }

  /// Authenticated state with user data
  factory AuthState.authenticated(UserModel user) {
    return AuthState(
      status: AuthStatus.authenticated,
      user: user,
    );
  }

  /// Unauthenticated state with optional error
  factory AuthState.unauthenticated({String? errorMessage}) {
    return AuthState(
      status: AuthStatus.unauthenticated,
      errorMessage: errorMessage,
    );
  }

  /// Create a copy with updated fields
  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;
  bool get isUnauthenticated => status == AuthStatus.unauthenticated;
}
