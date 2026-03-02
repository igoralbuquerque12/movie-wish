import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Storage service for managing local data
/// Uses flutter_secure_storage for sensitive data (JWT tokens)
/// Uses shared_preferences for non-sensitive data
class StorageService {
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';

  final FlutterSecureStorage _secureStorage;
  final SharedPreferences _prefs;

  StorageService({
    required SharedPreferences prefs,
    FlutterSecureStorage? secureStorage,
  })  : _prefs = prefs,
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  // ===== JWT Token Management (Secure) =====

  /// Save authentication token securely
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  /// Get authentication token
  Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  /// Delete authentication token
  Future<void> deleteToken() async {
    await _secureStorage.delete(key: _tokenKey);
  }

  // ===== User Data Management (Non-sensitive) =====

  /// Save user data
  Future<void> saveUserData({
    required String userId,
    required String name,
    required String email,
  }) async {
    await Future.wait([
      _prefs.setString(_userIdKey, userId),
      _prefs.setString(_userNameKey, name),
      _prefs.setString(_userEmailKey, email),
    ]);
  }

  /// Get user ID
  String? getUserId() {
    return _prefs.getString(_userIdKey);
  }

  /// Get user name
  String? getUserName() {
    return _prefs.getString(_userNameKey);
  }

  /// Get user email
  String? getUserEmail() {
    return _prefs.getString(_userEmailKey);
  }

  /// Delete all user data
  Future<void> deleteUserData() async {
    await Future.wait([
      _prefs.remove(_userIdKey),
      _prefs.remove(_userNameKey),
      _prefs.remove(_userEmailKey),
    ]);
  }

  /// Clear all stored data (logout)
  Future<void> clearAll() async {
    await Future.wait([
      deleteToken(),
      deleteUserData(),
    ]);
  }
}
