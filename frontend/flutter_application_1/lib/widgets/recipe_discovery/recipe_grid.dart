import 'package:flutter/material.dart';

import '../../models/recipe_models.dart';
import 'recipe_card.dart';

class RecipeGrid extends StatelessWidget {
  final List<Recipe> recipes;
  final Function(Recipe)? onRecipeTap;
  final bool showFavoriteButtons;
  final int crossAxisCount;

  const RecipeGrid({
    Key? key,
    required this.recipes,
    this.onRecipeTap,
    this.showFavoriteButtons = false,
    this.crossAxisCount = 2,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (recipes.isEmpty) {
      return const SliverToBoxAdapter(
        child: SizedBox.shrink(),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final responsiveCrossAxisCount = _getCrossAxisCount(context);

    return SliverPadding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 16,
      ),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: responsiveCrossAxisCount,
          childAspectRatio: _getChildAspectRatio(context, responsiveCrossAxisCount),
          crossAxisSpacing: isMobile ? 8 : 12,
          mainAxisSpacing: isMobile ? 8 : 12,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final recipe = recipes[index];
            return RecipeCard(
              recipe: recipe,
              onTap: () => onRecipeTap?.call(recipe),
              showFavoriteButton: showFavoriteButtons,
              isCompact: isMobile && responsiveCrossAxisCount > 1,
            );
          },
          childCount: recipes.length,
        ),
      ),
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Responsive grid based on screen width
    if (screenWidth > 1200) {
      return 4; // Desktop/large tablet
    } else if (screenWidth > 900) {
      return 3; // Large tablet
    } else if (screenWidth > 600) {
      return 2; // Small tablet
    } else if (screenWidth > 400) {
      return crossAxisCount == 1 ? 1 : 2; // Large phone - respect single column preference
    } else {
      return 1; // Small phone - always single column
    }
  }

  double _getChildAspectRatio(BuildContext context, int crossAxisCount) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (crossAxisCount == 1) {
      // Single column layout - wider cards
      if (screenWidth < 600) {
        return 1.2; // Mobile single column
      } else {
        return 1.5; // Tablet single column
      }
    } else if (crossAxisCount == 2) {
      // Two column layout
      if (screenWidth < 600) {
        return 0.8; // Mobile two column - taller cards
      } else {
        return 0.75; // Tablet two column
      }
    } else {
      // Three or more columns
      return 0.7; // Compact cards for multiple columns
    }
  }
} 