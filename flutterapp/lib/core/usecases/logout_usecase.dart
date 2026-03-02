import '../repositories/auth_repository_interface.dart';

/// Use case for user logout
/// Clears authentication token and user data
class LogoutUseCase {
  final IAuthRepository _repository;

  LogoutUseCase(this._repository);

  /// Execute logout use case
  /// Clears all authentication data
  Future<void> execute() async {
    await _repository.logout();
  }
}
