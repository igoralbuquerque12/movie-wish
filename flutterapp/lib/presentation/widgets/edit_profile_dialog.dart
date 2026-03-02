import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/models/genre_model.dart';
import '../providers/profile_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_button.dart';
import '../widgets/genre_chip.dart';
import '../widgets/movie_card.dart';

/// Edit Profile Dialog
class EditProfileDialog extends StatefulWidget {
  final String currentName;
  final List<int> currentGenres;

  const EditProfileDialog({
    super.key,
    required this.currentName,
    required this.currentGenres,
  });

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  late TextEditingController _nameController;
  late Set<int> _selectedGenres;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _selectedGenres = widget.currentGenres.toSet();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _toggleGenre(int genreId) {
    setState(() {
      if (_selectedGenres.contains(genreId)) {
        _selectedGenres.remove(genreId);
      } else {
        _selectedGenres.add(genreId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title
            Text(
              'Editar Perfil',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),

            // Name Field
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nome',
                hintText: 'Digite seu nome',
              ),
            ),
            const SizedBox(height: 24),

            // Genres Section
            Text(
              'Gêneros Favoritos',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Selecione pelo menos 1 gênero',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 16),

            // Genre Selection
            Expanded(
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: GenreModel.allGenres.map((genre) {
                    final isSelected = _selectedGenres.contains(genre.id);
                    return GenreChip(
                      genre: genre,
                      isSelected: isSelected,
                      onTap: () => _toggleGenre(genre.id),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => context.pop(),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: Consumer<ProfileProvider>(
                    builder: (context, provider, child) {
                      return CustomButton(
                        text: 'Salvar',
                        isLoading: provider.isSaving,
                        onPressed: () async {
                          if (_nameController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Nome é obrigatório'),
                                backgroundColor: AppColors.error,
                              ),
                            );
                            return;
                          }

                          if (_selectedGenres.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Selecione pelo menos 1 gênero'),
                                backgroundColor: AppColors.error,
                              ),
                            );
                            return;
                          }

                          final success = await provider.updateProfile(
                            _nameController.text.trim(),
                            _selectedGenres.toList(),
                          );

                          if (context.mounted) {
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Perfil atualizado!'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                              context.pop();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(provider.errorMessage ??
                                      'Erro ao salvar'),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
