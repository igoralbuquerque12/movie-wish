import 'package:flutter/foundation.dart';
import '../../core/models/movie_model.dart';
import '../../core/models/user_model.dart';
import '../../data/services/api_service.dart';
import '../../data/services/tmdb_service.dart';

class ProfileProvider extends ChangeNotifier {
  final ApiService _apiService;
  final TmdbService _tmdbService;

  ProfileProvider({
    required ApiService apiService,
    required TmdbService tmdbService,
  })  : _apiService = apiService,
        _tmdbService = tmdbService;

  // State
  UserModel? _user;
  List<MovieModel> _wishlistMovies = [];
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;

  // Getters
  UserModel? get user => _user;
  List<MovieModel> get wishlistMovies => _wishlistMovies;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  /// Load complete user profile and wishlist movies
  Future<void> loadProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Get user profile from backend
      final profileData = await _apiService.getUserProfile();
      _user = UserModel.fromJson(profileData);

      // 2. Load wishlist movies from TMDB in parallel
      if (_user!.wishMovies.isNotEmpty) {
        final movieFutures = _user!.wishMovies.map((movieId) {
          return _tmdbService.getMovieDetails(movieId);
        }).toList();

        final movies = await Future.wait(movieFutures);
        
        // Filter out null values (movies that failed to load)
        _wishlistMovies = movies.whereType<MovieModel>().toList();
      } else {
        _wishlistMovies = [];
      }
    } catch (e) {
      _errorMessage = 'Erro ao carregar perfil: $e';
      debugPrint('Error loading profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update user profile (name and/or genres)
  Future<bool> updateProfile(String name, List<int> genres) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Call API to update profile
      final updatedData = await _apiService.updateUserProfile(
        name: name,
        favoriteGenres: genres,
      );

      // Update local user data
      _user = UserModel.fromJson(updatedData);
      
      _isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Erro ao atualizar perfil: $e';
      debugPrint('Error updating profile: $e');
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
