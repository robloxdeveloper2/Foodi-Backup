import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/recipe_discovery_provider.dart';
import '../../models/recipe_models.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_message.dart';

class RecipeDetailsScreen extends StatefulWidget {
  final String recipeId;

  const RecipeDetailsScreen({
    Key? key,
    required this.recipeId,
  }) : super(key: key);

  @override
  State<RecipeDetailsScreen> createState() => _RecipeDetailsScreenState();
}

class _RecipeDetailsScreenState extends State<RecipeDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecipeDiscoveryProvider>().loadRecipeDetails(widget.recipeId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Consumer<RecipeDiscoveryProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingRecipeDetails) {
            return const Scaffold(
              body: Center(child: LoadingIndicator()),
            );
          }

          if (provider.error != null) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Recipe Details'),
                backgroundColor: Colors.white,
                iconTheme: const IconThemeData(color: Colors.black87),
              ),
              body: ErrorMessage(
                message: provider.error!,
                onRetry: () => provider.loadRecipeDetails(widget.recipeId),
              ),
            );
          }

          final recipe = provider.selectedRecipe;
          if (recipe == null) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Recipe Details'),
                backgroundColor: Colors.white,
                iconTheme: const IconThemeData(color: Colors.black87),
              ),
              body: const Center(
                child: Text('Recipe not found'),
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              // App bar with recipe image
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                iconTheme: const IconThemeData(color: Colors.black87),
                flexibleSpace: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    // Calculate how much the app bar is collapsed
                    final top = constraints.biggest.height;
                    final isCollapsed = top <= kToolbarHeight + MediaQuery.of(context).padding.top;
                    
                    return FlexibleSpaceBar(
                      titlePadding: const EdgeInsets.only(left: 16, bottom: 16, right: 60),
                      title: isCollapsed 
                          ? Text(
                              recipe.name,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            )
                          : Text(
                              recipe.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                shadows: [
                                  Shadow(
                                    offset: Offset(0, 1),
                                    blurRadius: 6,
                                    color: Colors.black87,
                                  ),
                                  Shadow(
                                    offset: Offset(1, 0),
                                    blurRadius: 6,
                                    color: Colors.black87,
                                  ),
                                ],
                              ),
                            ),
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          recipe.imageUrl != null
                              ? Image.network(
                                  recipe.imageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Theme.of(context).primaryColor,
                                            Theme.of(context).primaryColor.withOpacity(0.8),
                                          ],
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.restaurant_menu,
                                        size: 80,
                                        color: Colors.white.withOpacity(0.7),
                                      ),
                                    );
                                  },
                                )
                              : Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Theme.of(context).primaryColor,
                                        Theme.of(context).primaryColor.withOpacity(0.8),
                                      ],
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.restaurant_menu,
                                    size: 80,
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                ),
                          // Strong gradient overlay for better text contrast
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withOpacity(0.2),
                                  Colors.black.withOpacity(0.4),
                                  Colors.black.withOpacity(0.8),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                // Custom back button that adapts to the collapsed state
                leading: Builder(
                  builder: (context) {
                    return Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    );
                  },
                ),
              ),

              // Recipe content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Recipe stats
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem(Icons.access_time, 'Prep Time', recipe.timeDisplay),
                              _buildStatItem(Icons.people, 'Servings', '${recipe.servings}'),
                              _buildStatItem(Icons.speed, 'Difficulty', recipe.difficultyDisplay),
                              _buildStatItem(Icons.attach_money, 'Cost', recipe.costDisplay),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Description
                      if (recipe.description != null) ...[
                        const Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          recipe.description!,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Dietary tags
                      if (recipe.dietaryTags.isNotEmpty) ...[
                        const Text(
                          'Dietary Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: recipe.dietaryTags.map((tag) {
                            return Chip(
                              label: Text(tag),
                              backgroundColor: Colors.green[50],
                              side: BorderSide(color: Colors.green[200]!),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Ingredients
                      const Text(
                        'Ingredients',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: recipe.ingredients.map((ingredient) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        ingredient.displayText,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Instructions
                      const Text(
                        'Instructions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            recipe.instructions,
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ),

                      // Nutritional info
                      if (recipe.nutritionalInfo != null) ...[
                        const SizedBox(height: 24),
                        const Text(
                          'Nutritional Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildNutritionItem('Calories', '${recipe.nutritionalInfo!.calories.round()}'),
                                    if (recipe.nutritionalInfo!.protein != null)
                                      _buildNutritionItem('Protein', '${recipe.nutritionalInfo!.protein!.round()}g'),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    if (recipe.nutritionalInfo!.carbs != null)
                                      _buildNutritionItem('Carbs', '${recipe.nutritionalInfo!.carbs!.round()}g'),
                                    if (recipe.nutritionalInfo!.fat != null)
                                      _buildNutritionItem('Fat', '${recipe.nutritionalInfo!.fat!.round()}g'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildNutritionItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
} 