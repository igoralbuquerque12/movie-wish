import '../models/user_model.dart';

/// Abstract repository interface for authentication operations
/// This follows Dependency Inversion Principle from Clean Architecture
abstract class IAuthRepository {
  /// Login with email and password
  /// Returns UserModel and authentication token on success
  /// Throws exception on failure
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  });

  /// Register new user with name, email, password, and favorite genres
  /// Returns UserModel and authentication token on success
  /// Throws exception on failure
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required List<int> favoriteGenres,
  });

  /// Logout current user
  /// Clears authentication token and user data
  Future<void> logout();

  /// Check if user is already authenticated
  /// Returns UserModel if valid token exists, null otherwise
  Future<UserModel?> checkAuth();

  /// Get current authentication token
  Future<String?> getToken();

  /// Save authentication token
  Future<void> saveToken(String token);
}
