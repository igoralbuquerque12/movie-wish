import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../core/constants/tmdb_constants.dart';
import '../../core/models/movie_model.dart';

/// TMDB API Service for external movie data
class TmdbService {
  late final Dio _dio;

  TmdbService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: TmdbConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Authorization': 'Bearer ${TmdbConstants.apiToken}',
          'Content-Type': 'application/json',
        },
      ),
    );
  }

  /// Get popular movies (random page 1-15)
  Future<List<MovieModel>> getPopularMovies() async {
    try {
      final random = Random();
      final page = random.nextInt(15) + 1;

      final response = await _dio.get(
        '/movie/popular',
        queryParameters: {'page': page, 'language': 'pt-BR'},
      );

      final results = response.data['results'] as List<dynamic>;
      return results.map((json) => MovieModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar filmes populares: $e');
    }
  }

  /// Get upcoming movies (random page 1-15)
  Future<List<MovieModel>> getUpcomingMovies() async {
    try {
      final random = Random();
      final page = random.nextInt(15) + 1;

      final response = await _dio.get(
        '/movie/upcoming',
        queryParameters: {'page': page, 'language': 'pt-BR'},
      );

      final results = response.data['results'] as List<dynamic>;
      return results.map((json) => MovieModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar filmes em breve: $e');
    }
  }

  /// Get movies by genres (random page 1-5)
  Future<List<MovieModel>> getMoviesByGenres(List<int> genreIds) async {
    try {
      if (genreIds.isEmpty) {
        return [];
      }

      final random = Random();
      final page = random.nextInt(5) + 1;
      final genresString = genreIds.join(',');

      final response = await _dio.get(
        '/discover/movie',
        queryParameters: {
          'with_genres': genresString,
          'sort_by': 'vote_count.desc',
          'page': page,
          'language': 'pt-BR',
        },
      );

      final results = response.data['results'] as List<dynamic>;
      return results.map((json) => MovieModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar filmes por gênero: $e');
    }
  }

  /// Search movies by query
  Future<List<MovieModel>> searchMovies(String query) async {
    try {
      if (query.trim().isEmpty) {
        return [];
      }

      final response = await _dio.get(
        '/search/movie',
        queryParameters: {
          'query': query,
          'language': 'pt-BR',
        },
      );

      final results = response.data['results'] as List<dynamic>;
      return results.map((json) => MovieModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar filmes: $e');
    }
  }

  /// Get movie recommendations
  Future<List<MovieModel>> getMovieRecommendations(int movieId) async {
    try {
      final response = await _dio.get(
        '/movie/$movieId/recommendations',
        queryParameters: {'language': 'pt-BR'},
      );

      final results = response.data['results'] as List<dynamic>;
      return results.map((json) => MovieModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar recomendações: $e');
    }
  }

  /// Get movie details by ID (for wishlist)
  Future<MovieModel?> getMovieDetails(int movieId) async {
    try {
      final response = await _dio.get(
        '/movie/$movieId',
        queryParameters: {'language': 'pt-BR'},
      );

      return MovieModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      // Return null if movie not found (404 or other error)
      debugPrint('Error loading movie $movieId: $e');
      return null;
    }
  }
}
