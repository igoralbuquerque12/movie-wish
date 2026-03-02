import '../../core/models/user_model.dart';
import '../../core/repositories/auth_repository_interface.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

/// Concrete implementation of IAuthRepository
/// Handles authentication operations with API and local storage
class AuthRepositoryImpl implements IAuthRepository {
  final ApiService _apiService;
  final StorageService _storageService;

  AuthRepositoryImpl({
    required ApiService apiService,
    required StorageService storageService,
  })  : _apiService = apiService,
        _storageService = storageService;

  @override
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.login(
        email: email,
        password: password,
      );

      final user = UserModel.fromJson(response['user'] as Map<String, dynamic>);

      // CORREÇÃO 4: Mudou de 'token' para 'access_token' conforme sua API
      final token = response['access_token'] as String;

      await _storageService.saveUserData(
        userId: user.id,
        name: user.name,
        email: user.email,
      );

      _apiService.setAuthToken(token);

      return {
        'user': user,
        'token': token,
      };
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required List<int> favoriteGenres,
  }) async {
    try {
      // Call API to register
      final response = await _apiService.register(
        name: name,
        email: email,
        password: password,
        favoriteGenres: favoriteGenres,
      );

      // Extract user and token from response
      final user = UserModel.fromJson(response['user'] as Map<String, dynamic>);
      final token = response['token'] as String;

      // Save user data locally
      await _storageService.saveUserData(
        userId: user.id,
        name: user.name,
        email: user.email,
      );

      // Set token in API service
      _apiService.setAuthToken(token);

      return {
        'user': user,
        'token': token,
      };
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> logout() async {
    try {
      // Clear token from API service
      _apiService.setAuthToken(null);

      // Clear all local storage
      await _storageService.clearAll();
    } catch (e) {
      throw Exception('Erro ao fazer logout: ${e.toString()}');
    }
  }

  @override
  Future<UserModel?> checkAuth() async {
    try {
      // Get token from storage
      final token = await _storageService.getToken();

      if (token == null || token.isEmpty) {
        return null;
      }

      // Set token in API service
      _apiService.setAuthToken(token);

      // Verify token with API
      final response = await _apiService.verifyToken();

      // Extract and return user
      final user = UserModel.fromJson(response['user'] as Map<String, dynamic>);

      // Update local user data
      await _storageService.saveUserData(
        userId: user.id,
        name: user.name,
        email: user.email,
      );

      return user;
    } catch (e) {
      // If token is invalid, clear it
      await logout();
      return null;
    }
  }

  @override
  Future<String?> getToken() async {
    return await _storageService.getToken();
  }

  @override
  Future<void> saveToken(String token) async {
    await _storageService.saveToken(token);
  }
}
