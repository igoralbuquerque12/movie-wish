import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/genre_model.dart'; // <--- 1. Import necessário
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_button.dart';

/// Home Screen / Dashboard
/// Protected screen showing user information and logout button
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('WishMovies'),
            automaticallyImplyLeading: false,
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Welcome Card
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 32,
                                backgroundColor: AppColors.primaryOrange,
                                child: Text(
                                  user?.name.isNotEmpty == true
                                      ? user!.name.substring(0, 1).toUpperCase()
                                      : 'U',
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Bem-vindo!',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      user?.name.isNotEmpty == true ? user!.name : 'Usuário',
                                      style: Theme.of(context).textTheme.headlineSmall,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Divider(color: AppColors.divider),
                          const SizedBox(height: 16),
                          // User Info
                          _InfoRow(
                            icon: Icons.email_outlined,
                            label: 'Email',
                            value: user?.email ?? '',
                          ),
                          const SizedBox(height: 12),
                          _InfoRow(
                            icon: Icons.movie_outlined,
                            label: 'Gêneros Favoritos',
                            value: '${user?.favoriteGenres.length ?? 0} selecionados',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Favorite Genres Section
                  if (user != null && user.favoriteGenres.isNotEmpty) ...[
                    Text(
                      'Seus Gêneros Favoritos',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          // Agora genreId é um int, e _getGenreName aceita int
                          children: user.favoriteGenres.map((genreId) {
                            return Chip(
                              label: Text(_getGenreName(genreId)),
                              backgroundColor: AppColors.primaryOrangeLight.withValues(alpha: 0.2),
                              labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.primaryOrangeDark,
                                fontWeight: FontWeight.w500,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  const Spacer(),

                  // Logout Button
                  CustomButton(
                    text: 'Sair',
                    icon: Icons.logout,
                    onPressed: () async {
                      await authProvider.logout();
                      // Navigation is handled by GoRouter
                    },
                    backgroundColor: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // <--- 2. e 3. Atualizado para receber int e buscar na lista oficial
  String _getGenreName(int genreId) {
    try {
      return GenreModel.allGenres
          .firstWhere((genre) => genre.id == genreId)
          .name;
    } catch (e) {
      // Caso o ID não exista na lista (fallback)
      return 'Gênero $genreId';
    }
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.primaryOrange,
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}