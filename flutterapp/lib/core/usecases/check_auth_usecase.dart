import '../models/user_model.dart';
import '../repositories/auth_repository_interface.dart';

/// Use case for checking existing authentication
/// Used on app startup to restore user session
class CheckAuthUseCase {
  final IAuthRepository _repository;

  CheckAuthUseCase(this._repository);

  /// Execute check auth use case
  /// Returns UserModel if valid token exists, null otherwise
  Future<UserModel?> execute() async {
    return await _repository.checkAuth();
  }
}
