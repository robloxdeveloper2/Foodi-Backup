import 'package:flutter/material.dart';
import '../../models/recipe_detail_models.dart';
import '../../utils/app_constants.dart';

class RecipeHeaderSection extends StatelessWidget {
  final RecipeDetail recipe;

  const RecipeHeaderSection({
    Key? key,
    required this.recipe,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.3),
            Colors.black.withOpacity(0.7),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recipe image placeholder
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                image: recipe.baseRecipe.imageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(recipe.baseRecipe.imageUrl!),
                        fit: BoxFit.cover,
                        onError: (exception, stackTrace) {
                          // Handle image loading error
                        },
                      )
                    : null,
              ),
              child: recipe.baseRecipe.imageUrl == null
                  ? const Center(
                      child: Icon(
                        Icons.restaurant,
                        size: 64,
                        color: Colors.grey,
                      ),
                    )
                  : null,
            ),
          ),
          
          // Recipe info overlay
          Container(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Recipe title
                Text(
                  recipe.baseRecipe.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                
                const SizedBox(height: AppConstants.smallPadding),
                
                // Recipe description
                if (recipe.baseRecipe.description != null) ...[
                  Text(
                    recipe.baseRecipe.description!,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppConstants.smallPadding),
                ],
                
                // Recipe metadata
                Row(
                  children: [
                    // Prep time
                    if (recipe.baseRecipe.prepTimeMinutes != null) ...[
                      const Icon(Icons.schedule, color: Colors.white70, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${recipe.baseRecipe.prepTimeMinutes}min prep',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(width: 16),
                    ],
                    
                    // Cook time
                    if (recipe.baseRecipe.cookTimeMinutes != null) ...[
                      const Icon(Icons.local_fire_department, color: Colors.white70, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${recipe.baseRecipe.cookTimeMinutes}min cook',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(width: 16),
                    ],
                    
                    // Servings
                    const Icon(Icons.people, color: Colors.white70, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${recipe.scaledServings} servings',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
                
                const SizedBox(height: AppConstants.smallPadding),
                
                // Difficulty and cuisine
                Row(
                  children: [
                    // Difficulty
                    if (recipe.baseRecipe.difficultyLevel != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getDifficultyColor(recipe.baseRecipe.difficultyLevel!),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          recipe.baseRecipe.difficultyLevel!.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    
                    // Cuisine type
                    if (recipe.baseRecipe.cuisineType != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          recipe.baseRecipe.cuisineType!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
} 