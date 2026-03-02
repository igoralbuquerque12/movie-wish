import 'package:flutter/foundation.dart';
import '../../core/models/movie_model.dart';
import '../../data/services/api_service.dart';
import '../../data/services/tmdb_service.dart';

class MoviesProvider extends ChangeNotifier {
  final TmdbService _tmdbService;
  final ApiService _apiService;

  MoviesProvider({
    required TmdbService tmdbService,
    required ApiService apiService,
  })  : _tmdbService = tmdbService,
        _apiService = apiService;

  List<MovieModel> _popularMovies = [];
  List<MovieModel> _upcomingMovies = [];
  List<MovieModel> _recommendedMovies = [];
  List<MovieModel> _searchResults = [];

  bool _isLoadingHome = false;
  bool _isSearching = false;

  final Set<int> _favoriteMovieIds = {};

  List<MovieModel> get popularMovies => _popularMovies;
  List<MovieModel> get upcomingMovies => _upcomingMovies;
  List<MovieModel> get recommendedMovies => _recommendedMovies;
  List<MovieModel> get searchResults => _searchResults;
  bool get isLoadingHome => _isLoadingHome;
  bool get isSearching => _isSearching;

  bool isFavorite(int movieId) => _favoriteMovieIds.contains(movieId);

  Future<void> loadHomeData(List<int> userGenreIds) async {
    _isLoadingHome = true;
    notifyListeners();

    try {
      // Load all 3 APIs in parallel
      final results = await Future.wait([
        _tmdbService.getPopularMovies(),
        _tmdbService.getUpcomingMovies(),
        _tmdbService.getMoviesByGenres(userGenreIds),
      ]);

      _popularMovies = results[0];
      _upcomingMovies = results[1];
      _recommendedMovies = results[2];
    } catch (e) {
      // Handle error silently or expose error state
      debugPrint('Error loading home data: $e');
    } finally {
      _isLoadingHome = false;
      notifyListeners();
    }
  }

  /// Search movies
  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _isSearching = true;
    notifyListeners();

    try {
      _searchResults = await _tmdbService.searchMovies(query);
    } catch (e) {
      debugPrint('Error searching movies: $e');
      _searchResults = [];
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  /// Clear search results
  void clearSearch() {
    _searchResults = [];
    notifyListeners();
  }

  /// Toggle favorite status (optimistic update)
  Future<void> toggleFavorite(int movieId) async {
    final wasFavorite = _favoriteMovieIds.contains(movieId);

    // Optimistic update
    if (wasFavorite) {
      _favoriteMovieIds.remove(movieId);
    } else {
      _favoriteMovieIds.add(movieId);
    }
    notifyListeners();

    try {
      // Call backend API
      if (wasFavorite) {
        await _apiService.removeFavoriteMovie(movieId);
      } else {
        await _apiService.addFavoriteMovie(movieId);
      }
    } catch (e) {
      // Revert on error
      if (wasFavorite) {
        _favoriteMovieIds.add(movieId);
      } else {
        _favoriteMovieIds.remove(movieId);
      }
      notifyListeners();
      debugPrint('Error toggling favorite: $e');
      rethrow;
    }
  }
}
