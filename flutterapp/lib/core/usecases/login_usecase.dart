import '../models/user_model.dart';
import '../repositories/auth_repository_interface.dart';

/// Use case for user login
/// Encapsulates business logic for authentication
class LoginUseCase {
  final IAuthRepository _repository;

  LoginUseCase(this._repository);

  /// Execute login use case
  /// Returns UserModel on success
  /// Throws exception on failure
  Future<UserModel> execute({
    required String email,
    required String password,
  }) async {
    // Validate inputs
    if (email.isEmpty) {
      throw Exception('Email não pode estar vazio');
    }
    if (password.isEmpty) {
      throw Exception('Senha não pode estar vazia');
    }
    if (!_isValidEmail(email)) {
      throw Exception('Email inválido');
    }

    // Call repository to perform login
    final result = await _repository.login(
      email: email,
      password: password,
    );

    // Save token
    await _repository.saveToken(result['token'] as String);

    // Return user model
    return result['user'] as UserModel;
  }

  /// Validate email format
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }
}
