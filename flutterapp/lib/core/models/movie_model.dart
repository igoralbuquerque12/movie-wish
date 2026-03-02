import '../constants/tmdb_constants.dart';

/// Movie model from TMDB API
class MovieModel {
  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final String? releaseDate;
  final double voteAverage;
  final double popularity;
  final List<int> genreIds;

  MovieModel({
    required this.id,
    required this.title,
    required this.overview,
    this.posterPath,
    this.backdropPath,
    this.releaseDate,
    required this.voteAverage,
    required this.popularity,
    required this.genreIds,
  });

  /// Get full poster URL with placeholder fallback
  String get fullPosterPath {
    if (posterPath == null || posterPath!.isEmpty) {
      return TmdbConstants.placeholderImage;
    }
    return TmdbConstants.imageBaseUrl + posterPath!;
  }

  /// Get full backdrop URL with placeholder fallback
  String get fullBackdropPath {
    if (backdropPath == null || backdropPath!.isEmpty) {
      return TmdbConstants.placeholderImage;
    }
    return TmdbConstants.backdropBaseUrl + backdropPath!;
  }

  /// Get release year from date
  String get releaseYear {
    if (releaseDate == null || releaseDate!.isEmpty) {
      return 'N/A';
    }
    return releaseDate!.split('-').first;
  }

  /// Create MovieModel from JSON
  factory MovieModel.fromJson(Map<String, dynamic> json) {
    return MovieModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? 'Sem título',
      overview: json['overview'] as String? ?? '',
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      releaseDate: json['release_date'] as String?,
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      popularity: (json['popularity'] as num?)?.toDouble() ?? 0.0,
      genreIds: (json['genre_ids'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
    );
  }

  /// Convert MovieModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'overview': overview,
      'poster_path': posterPath,
      'backdrop_path': backdropPath,
      'release_date': releaseDate,
      'vote_average': voteAverage,
      'popularity': popularity,
      'genre_ids': genreIds,
    };
  }
}
