import '../models/user_model.dart';
import '../repositories/auth_repository_interface.dart';

/// Use case for user registration
/// Encapsulates business logic for creating new accounts
class RegisterUseCase {
  final IAuthRepository _repository;

  RegisterUseCase(this._repository);

  /// Execute register use case
  /// Returns UserModel on success
  /// Throws exception on failure
  Future<UserModel> execute({
    required String name,
    required String email,
    required String password,
    required List<int> favoriteGenres,
  }) async {
    // Validate inputs
    if (name.isEmpty) {
      throw Exception('Nome não pode estar vazio');
    }
    if (email.isEmpty) {
      throw Exception('Email não pode estar vazio');
    }
    if (password.isEmpty) {
      throw Exception('Senha não pode estar vazia');
    }
    if (password.length < 6) {
      throw Exception('Senha deve ter no mínimo 6 caracteres');
    }
    if (!_isValidEmail(email)) {
      throw Exception('Email inválido');
    }
    if (favoriteGenres.isEmpty) {
      throw Exception('Selecione pelo menos 1 gênero favorito');
    }

    // Call repository to perform registration
    final result = await _repository.register(
      name: name,
      email: email,
      password: password,
      favoriteGenres: favoriteGenres,
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
