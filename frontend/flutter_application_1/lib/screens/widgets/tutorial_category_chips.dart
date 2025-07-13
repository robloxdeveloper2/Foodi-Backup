import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/tutorial_provider.dart';
import '../../models/tutorial_models.dart';

class TutorialCategoryChips extends StatelessWidget {
  const TutorialCategoryChips({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TutorialProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingCategories) {
          return const SizedBox(
            height: 50,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (provider.categories.isEmpty) {
          return const SizedBox.shrink();
        }

        // Use different layouts based on screen width
        return LayoutBuilder(
          builder: (context, constraints) {
            final isWideScreen = constraints.maxWidth > 600;
            
            if (isWideScreen) {
              // Wide screen: use horizontal scrolling ListView
              return _buildHorizontalChips(context, provider);
            } else {
              // Mobile: use wrapping chips
              return _buildWrappingChips(context, provider);
            }
          },
        );
      },
    );
  }

  Widget _buildHorizontalChips(BuildContext context, TutorialProvider provider) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: provider.categories.length + 1,
        itemBuilder: (context, index) => _buildChip(context, provider, index),
      ),
    );
  }

  Widget _buildWrappingChips(BuildContext context, TutorialProvider provider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: List.generate(
          provider.categories.length + 1,
          (index) => _buildChip(context, provider, index),
        ),
      ),
    );
  }

  Widget _buildChip(BuildContext context, TutorialProvider provider, int index) {
    if (index == 0) {
      // "All" chip
      final isSelected = provider.filters.category == null;
      return FilterChip(
        label: const Text('All'),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            final newFilters = TutorialFilters(
              difficulty: provider.filters.difficulty,
              durationMaxMinutes: provider.filters.durationMaxMinutes,
              beginnerFriendly: provider.filters.beginnerFriendly,
            );
            provider.updateFilters(newFilters);
          }
        },
        backgroundColor: Colors.grey[200],
        selectedColor: Theme.of(context).primaryColor,
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.grey[700],
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      );
    }

    final category = provider.categories[index - 1];
    final isSelected = provider.filters.category == category.category;

    return FilterChip(
      label: Text(_formatCategoryName(category.category)),
      selected: isSelected,
      onSelected: (selected) {
        final newFilters = TutorialFilters(
          category: selected ? category.category : null,
          difficulty: provider.filters.difficulty,
          durationMaxMinutes: provider.filters.durationMaxMinutes,
          beginnerFriendly: provider.filters.beginnerFriendly,
        );
        provider.updateFilters(newFilters);
      },
      backgroundColor: Colors.grey[200],
      selectedColor: Theme.of(context).primaryColor,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      avatar: isSelected ? null : CircleAvatar(
        backgroundColor: _getCategoryColor(category.category),
        radius: 6,
        child: Icon(
          _getCategoryIcon(category.category),
          size: 10,
          color: Colors.white,
        ),
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }

  String _formatCategoryName(String category) {
    switch (category) {
      case 'knife_skills':
        return 'Knife Skills';
      case 'food_safety':
        return 'Food Safety';
      case 'cooking_methods':
        return 'Cooking Methods';
      case 'baking_basics':
        return 'Baking Basics';
      case 'kitchen_basics':
        return 'Kitchen Basics';
      default:
        return category.split('_').map((word) => 
          word[0].toUpperCase() + word.substring(1)
        ).join(' ');
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'knife_skills':
        return Colors.red;
      case 'food_safety':
        return Colors.green;
      case 'cooking_methods':
        return Colors.orange;
      case 'baking_basics':
        return Colors.purple;
      case 'kitchen_basics':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'knife_skills':
        return Icons.content_cut;
      case 'food_safety':
        return Icons.health_and_safety;
      case 'cooking_methods':
        return Icons.local_fire_department;
      case 'baking_basics':
        return Icons.cake;
      case 'kitchen_basics':
        return Icons.kitchen;
      default:
        return Icons.school;
    }
  }
} 