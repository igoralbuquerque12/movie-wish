import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/movies_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/movie_card.dart';
import '../widgets/section_header.dart';

/// New Home Screen with TMDB Integration
class NewHomeScreen extends StatefulWidget {
  const NewHomeScreen({super.key});

  @override
  State<NewHomeScreen> createState() => _NewHomeScreenState();
}

class _NewHomeScreenState extends State<NewHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  void _loadMovies() {
    final authProvider = context.read<AuthProvider>();
    final moviesProvider = context.read<MoviesProvider>();
    final userGenres = authProvider.currentUser?.favoriteGenres ?? [];
    moviesProvider.loadHomeData(userGenres);
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
      });
      context.read<MoviesProvider>().clearSearch();
      return;
    }

    setState(() {
      _isSearching = true;
    });

    // Debounce search with 0.75s delay
    EasyDebounce.debounce(
      'movie-search',
      const Duration(milliseconds: 750),
      () {
        if (mounted) {
          context.read<MoviesProvider>().search(query);
        }
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    EasyDebounce.cancelAll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('WishMovies'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primaryOrange,
              child: Text(
                user?.name.isNotEmpty == true
                    ? user!.name.substring(0, 1).toUpperCase()
                    : 'U',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            onPressed: () {
              // Navigate to profile screen
              context.push('/profile');
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Buscar filmes...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
              ),
            ),
          ),

          // Content
          Expanded(
            child: _isSearching
                ? _buildSearchResults()
                : _buildHomeContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return Consumer<MoviesProvider>(
      builder: (context, provider, child) {
        if (provider.isSearching) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.searchResults.isEmpty) {
          return const Center(
            child: Text('Nenhum resultado encontrado'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.searchResults.length,
          itemBuilder: (context, index) {
            final movie = provider.searchResults[index];
            return ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  movie.fullPosterPath,
                  width: 50,
                  height: 75,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 50,
                      height: 75,
                      color: Colors.grey[300],
                      child: const Icon(Icons.movie),
                    );
                  },
                ),
              ),
              title: Text(movie.title),
              subtitle: Text(movie.releaseYear),
              onTap: () {
                context.push('/movie-details', extra: movie);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildHomeContent() {
    return Consumer<MoviesProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingHome) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () async {
            _loadMovies();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Popular Movies
                if (provider.popularMovies.isNotEmpty) ...[
                  const SectionHeader(title: 'Populares'),
                  SizedBox(
                    height: 280,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: provider.popularMovies.length,
                      itemBuilder: (context, index) {
                        final movie = provider.popularMovies[index];
                        return MovieCard(
                          movie: movie,
                          onTap: () {
                            context.push('/movie-details', extra: movie);
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Upcoming Movies
                if (provider.upcomingMovies.isNotEmpty) ...[
                  const SectionHeader(title: 'Em Breve'),
                  SizedBox(
                    height: 280,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: provider.upcomingMovies.length,
                      itemBuilder: (context, index) {
                        final movie = provider.upcomingMovies[index];
                        return MovieCard(
                          movie: movie,
                          onTap: () {
                            context.push('/movie-details', extra: movie);
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Recommended Movies
                if (provider.recommendedMovies.isNotEmpty) ...[
                  const SectionHeader(title: 'Recomendados para Você'),
                  SizedBox(
                    height: 280,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: provider.recommendedMovies.length,
                      itemBuilder: (context, index) {
                        final movie = provider.recommendedMovies[index];
                        return MovieCard(
                          movie: movie,
                          onTap: () {
                            context.push('/movie-details', extra: movie);
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
