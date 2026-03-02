import 'package:flutter/material.dart';
import '../../core/models/genre_model.dart';
import '../theme/app_colors.dart';

/// Custom chip widget for genre selection
/// Shows selected/unselected state with different colors
class GenreChip extends StatelessWidget {
  final GenreModel genre;
  final bool isSelected;
  final VoidCallback onTap;

  const GenreChip({
    super.key,
    required this.genre,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(genre.name),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: AppColors.chipUnselected,
      selectedColor: AppColors.chipSelected,
      labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: isSelected
                ? AppColors.chipTextSelected
                : AppColors.chipTextUnselected,
            fontWeight: FontWeight.w500,
          ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? AppColors.primaryOrange : AppColors.border,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      showCheckmark: false,
    );
  }
}
