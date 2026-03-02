import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/models/genre_model.dart';
import '../providers/profile_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/edit_profile_dialog.dart';
import '../widgets/movie_card.dart';

/// Profile Screen - "Minha Conta"
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Load profile when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().loadProfile();
    });
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

  void _showEditDialog() {
    final provider = context.read<ProfileProvider>();
    if (provider.user == null) return;

    showDialog(
      context: context,
      builder: (context) => EditProfileDialog(
        currentName: provider.user!.name,
        currentGenres: provider.user!.favoriteGenres,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Minha Conta'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.user == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    provider.errorMessage ?? 'Erro ao carregar perfil',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => provider.loadProfile(),
                    child: const Text('Tentar Novamente'),
                  ),
                ],
              ),
            );
          }

          final user = provider.user!;

          return RefreshIndicator(
            onRefresh: () => provider.loadProfile(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Header
                  _buildProfileHeader(user.name, user.email),
                  const SizedBox(height: 32),

                  // My Genres Section
                  _buildGenresSection(user.favoriteGenres),
                  const SizedBox(height: 32),

                  // Wishlist Section
                  _buildWishlistSection(provider.wishlistMovies),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(String name, String email) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar
            CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.primaryOrange,
              child: Text(
                name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'U',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(height: 16),

            // Name
            Text(
              name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),

            // Email
            Text(
              email,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 20),

            // Edit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _showEditDialog,
                icon: const Icon(Icons.edit),
                label: const Text('Editar Perfil'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenresSection(List<int> genreIds) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Meus Gêneros',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: genreIds.map((genreId) {
            return Chip(
              label: Text(_getGenreName(genreId)),
              backgroundColor:
                  AppColors.primaryOrangeLight.withValues(alpha: 0.2),
              labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.primaryOrangeDark,
                    fontWeight: FontWeight.w500,
                  ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildWishlistSection(List wishlistMovies) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Minha Lista de Desejos',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),

        // Empty State
        if (wishlistMovies.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  Icon(
                    Icons.list_alt,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Sua lista está vazia',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Adicione filmes aos favoritos para vê-los aqui',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
          )
        else
          // Grid of Movies
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: wishlistMovies.length,
            itemBuilder: (context, index) {
              final movie = wishlistMovies[index];
              return MovieCard(
                movie: movie,
                onTap: () {
                  context.push('/movie-details', extra: movie);
                },
              );
            },
          ),
      ],
    );
  }
}
