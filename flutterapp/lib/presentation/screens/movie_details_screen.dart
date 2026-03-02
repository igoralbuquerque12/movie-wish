import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/models/genre_model.dart';
import '../../core/models/movie_model.dart';
import '../../data/services/tmdb_service.dart';
import '../providers/movies_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_button.dart';
import '../widgets/movie_card.dart';
import '../widgets/section_header.dart';

/// Movie Details Screen
class MovieDetailsScreen extends StatefulWidget {
  final MovieModel movie;

  const MovieDetailsScreen({
    super.key,
    required this.movie,
  });

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  final TmdbService _tmdbService = TmdbService();
  List<MovieModel> _recommendations = [];
  bool _isLoadingRecommendations = false;

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    setState(() {
      _isLoadingRecommendations = true;
    });

    try {
      final recommendations =
          await _tmdbService.getMovieRecommendations(widget.movie.id);
      setState(() {
        _recommendations = recommendations;
      });
    } catch (e) {
      debugPrint('Error loading recommendations: $e');
    } finally {
      setState(() {
        _isLoadingRecommendations = false;
      });
    }
  }

  String _getGenreName(int genreId) {
    try {
      return GenreModel.allGenres
          .firstWhere((genre) => genre.id == genreId)
          .name;
    } catch (e) {
      return 'Gênero $genreId';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar with Backdrop
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: widget.movie.fullBackdropPath,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[800],
                      child: const Icon(
                        Icons.movie,
                        size: 100,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.8),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Year
                  Text(
                    widget.movie.title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (widget.movie.releaseDate != null &&
                          widget.movie.releaseDate!.isNotEmpty) ...[
                        Text(
                          widget.movie.releaseYear,
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                        ),
                        const SizedBox(width: 16),
                      ],
                      // Rating
                      const Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.movie.voteAverage.toStringAsFixed(1),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Genres
                  if (widget.movie.genreIds.isNotEmpty) ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.movie.genreIds.map((genreId) {
                        return Chip(
                          label: Text(_getGenreName(genreId)),
                          backgroundColor:
                              AppColors.primaryOrangeLight.withValues(alpha: 0.2),
                          labelStyle:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.primaryOrangeDark,
                                    fontWeight: FontWeight.w500,
                                  ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Synopsis
                  Text(
                    'Sinopse',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.movie.overview.isNotEmpty
                        ? widget.movie.overview
                        : 'Sem sinopse disponível.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),

                  // Favorite Button
                  Consumer<MoviesProvider>(
                    builder: (context, provider, child) {
                      final isFavorite = provider.isFavorite(widget.movie.id);
                      return CustomButton(
                        text: isFavorite
                            ? 'Remover dos Favoritos'
                            : 'Adicionar aos Favoritos',
                        icon: isFavorite ? Icons.favorite : Icons.favorite_border,
                        onPressed: () async {
                          try {
                            await provider.toggleFavorite(widget.movie.id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isFavorite
                                        ? 'Removido dos favoritos'
                                        : 'Adicionado aos favoritos',
                                  ),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Erro ao atualizar favorito'),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          }
                        },
                        backgroundColor: isFavorite
                            ? AppColors.textSecondary
                            : AppColors.primaryOrange,
                      );
                    },
                  ),
                  const SizedBox(height: 32),

                  // Recommendations Section
                  if (!_isLoadingRecommendations &&
                      _recommendations.isNotEmpty) ...[
                    const SectionHeader(title: 'Filmes Relacionados'),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 280,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _recommendations.length,
                        itemBuilder: (context, index) {
                          final movie = _recommendations[index];
                          return MovieCard(
                            movie: movie,
                            onTap: () {
                              // Navigate to the new movie details
                              context.pushReplacement('/movie-details',
                                  extra: movie);
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  if (_isLoadingRecommendations)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
