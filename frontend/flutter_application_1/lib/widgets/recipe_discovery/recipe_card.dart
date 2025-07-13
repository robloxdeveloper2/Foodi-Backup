import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';

import '../../models/recipe_models.dart';
import '../../providers/user_recipe_provider.dart';
import '../../screens/widgets/user_recipes/favorite_button.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback? onTap;
  final bool showFavoriteButton;
  final bool isCompact;

  const RecipeCard({
    Key? key,
    required this.recipe,
    this.onTap,
    this.showFavoriteButton = false,
    this.isCompact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recipe image
            Expanded(
              flex: isCompact ? 2 : 3,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      color: Colors.grey[200],
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: recipe.imageUrl != null
                          ? CachedNetworkImage(
                              imageUrl: recipe.imageUrl!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey[200],
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey[200],
                                child: Icon(
                                  Icons.restaurant_menu,
                                  size: isCompact ? 30 : 40,
                                  color: Colors.grey[400],
                                ),
                              ),
                            )
                          : Container(
                              color: Colors.grey[200],
                              child: Icon(
                                Icons.restaurant_menu,
                                size: isCompact ? 30 : 40,
                                color: Colors.grey[400],
                              ),
                            ),
                    ),
                  ),
                  
                  // Difficulty badge
                  if (recipe.difficultyLevel != null)
                    Positioned(
                      top: isCompact ? 4 : 8,
                      left: isCompact ? 4 : 8,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isCompact ? 4 : 8,
                          vertical: isCompact ? 2 : 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getDifficultyColor(recipe.difficultyLevel!),
                          borderRadius: BorderRadius.circular(isCompact ? 8 : 12),
                        ),
                        child: Text(
                          recipe.difficultyDisplay,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isCompact ? 8 : 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  
                  // Favorite button
                  if (showFavoriteButton)
                    Positioned(
                      top: isCompact ? 4 : 8,
                      right: isCompact ? 4 : 8,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: Consumer<UserRecipeProvider>(
                          builder: (context, provider, child) {
                            return FutureBuilder<bool>(
                              future: provider.checkRecipeFavorited(recipe.id),
                              builder: (context, snapshot) {
                                final isFavorited = snapshot.data ?? false;
                                return FavoriteButton(
                                  recipeId: recipe.id,
                                  isFavorited: isFavorited,
                                  size: isCompact ? 16 : 20,
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // Recipe details
            Expanded(
              flex: isCompact ? 3 : 2,
              child: Padding(
                padding: EdgeInsets.all(isCompact ? 6 : (isMobile ? 10 : 12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Recipe name
                    Flexible(
                      child: Text(
                        recipe.displayName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isCompact ? 11 : (isMobile ? 13 : 14),
                          height: 1.2,
                        ),
                        maxLines: isCompact ? 1 : 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(height: isCompact ? 2 : 4),
                    
                    // Cuisine type
                    if (recipe.cuisineType != null)
                      Flexible(
                        child: Text(
                          recipe.cuisineType!,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: isCompact ? 9 : (isMobile ? 11 : 12),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    
                    const Spacer(),
                    
                    // Recipe stats
                    Row(
                      children: [
                        // Time
                        Icon(
                          Icons.access_time,
                          size: isCompact ? 10 : (isMobile ? 12 : 14),
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            recipe.timeDisplay,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: isCompact ? 9 : (isMobile ? 11 : 12),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    
                    // Only show dietary tags if there's space and not too compact
                    if (!isCompact && recipe.dietaryTags.isNotEmpty) ...[
                      SizedBox(height: isMobile ? 4 : 6),
                      Flexible(
                        child: Wrap(
                          spacing: 4,
                          runSpacing: 2,
                          children: recipe.dietaryTags.take(isMobile ? 1 : 2).map((tag) {
                            return Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isMobile ? 4 : 6,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: Colors.green[200]!,
                                  width: 0.5,
                                ),
                              ),
                              child: Text(
                                tag,
                                style: TextStyle(
                                  color: Colors.green[700],
                                  fontSize: isMobile ? 9 : 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
      case 'easy':
        return Colors.green;
      case 'intermediate':
      case 'medium':
        return Colors.orange;
      case 'advanced':
      case 'hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
} 