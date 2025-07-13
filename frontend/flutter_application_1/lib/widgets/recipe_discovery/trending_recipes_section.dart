import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/recipe_discovery_provider.dart';
import '../../models/recipe_models.dart';
import 'recipe_card.dart';
import '../common/loading_indicator.dart';

class TrendingRecipesSection extends StatelessWidget {
  const TrendingRecipesSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    
    return Consumer<RecipeDiscoveryProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: isMobile ? 12 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16),
                child: Row(
                  children: [
                    Icon(
                      Icons.trending_up,
                      color: Colors.orange[600],
                      size: isMobile ? 20 : 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Trending Recipes',
                      style: TextStyle(
                        fontSize: isMobile ? 18 : 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        // Navigate to see all trending recipes
                        provider.updateSort('created_at', 'desc');
                        provider.searchRecipes(resetPage: true);
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 8 : 12,
                          vertical: 4,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'See All',
                        style: TextStyle(
                          fontSize: isMobile ? 13 : 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: isMobile ? 8 : 12),
              
              // Trending recipes list
              SizedBox(
                height: isMobile ? 220 : 260,
                child: provider.isLoadingTrending
                    ? const Center(child: LoadingIndicator(size: 30))
                    : provider.trendingRecipes.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.restaurant_menu,
                                  size: isMobile ? 40 : 48,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'No trending recipes available',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: isMobile ? 13 : 14,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16),
                            itemCount: provider.trendingRecipes.length,
                            itemBuilder: (context, index) {
                              final recipe = provider.trendingRecipes[index];
                              // Responsive card width
                              final cardWidth = isMobile ? 130.0 : 150.0;
                              
                              return Container(
                                width: cardWidth,
                                margin: EdgeInsets.only(right: isMobile ? 8 : 12),
                                child: RecipeCard(
                                  recipe: recipe,
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/recipe-details',
                                      arguments: recipe.id,
                                    );
                                  },
                                  showFavoriteButton: true,
                                  isCompact: true,
                                ),
                              );
                            },
                          ),
              ),
              
              // Quick filter chips
              SizedBox(height: isMobile ? 12 : 16),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Filters',
                      style: TextStyle(
                        fontSize: isMobile ? 15 : 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: isMobile ? 6 : 8),
                    // Use Wrap instead of SingleChildScrollView for mobile
                    isMobile 
                        ? Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              _buildQuickFilterChip(
                                context,
                                'Quick Meals',
                                Icons.flash_on,
                                Colors.orange,
                                () => provider.searchQuickRecipes(),
                                isMobile,
                              ),
                              _buildQuickFilterChip(
                                context,
                                'Budget-Friendly',
                                Icons.attach_money,
                                Colors.green,
                                () => provider.searchBudgetFriendlyRecipes(),
                                isMobile,
                              ),
                              _buildQuickFilterChip(
                                context,
                                'Beginner',
                                Icons.school,
                                Colors.blue,
                                () => provider.searchBeginnerRecipes(),
                                isMobile,
                              ),
                              _buildQuickFilterChip(
                                context,
                                'Vegetarian',
                                Icons.eco,
                                Colors.green,
                                () => provider.searchVegetarianRecipes(),
                                isMobile,
                              ),
                              _buildQuickFilterChip(
                                context,
                                'Vegan',
                                Icons.local_florist,
                                Colors.green[700]!,
                                () => provider.searchVeganRecipes(),
                                isMobile,
                              ),
                            ],
                          )
                        : SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildQuickFilterChip(
                                  context,
                                  'Quick Meals',
                                  Icons.flash_on,
                                  Colors.orange,
                                  () => provider.searchQuickRecipes(),
                                  isMobile,
                                ),
                                _buildQuickFilterChip(
                                  context,
                                  'Budget-Friendly',
                                  Icons.attach_money,
                                  Colors.green,
                                  () => provider.searchBudgetFriendlyRecipes(),
                                  isMobile,
                                ),
                                _buildQuickFilterChip(
                                  context,
                                  'Beginner',
                                  Icons.school,
                                  Colors.blue,
                                  () => provider.searchBeginnerRecipes(),
                                  isMobile,
                                ),
                                _buildQuickFilterChip(
                                  context,
                                  'Vegetarian',
                                  Icons.eco,
                                  Colors.green,
                                  () => provider.searchVegetarianRecipes(),
                                  isMobile,
                                ),
                                _buildQuickFilterChip(
                                  context,
                                  'Vegan',
                                  Icons.local_florist,
                                  Colors.green[700]!,
                                  () => provider.searchVeganRecipes(),
                                  isMobile,
                                ),
                              ],
                            ),
                          ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickFilterChip(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
    bool isMobile,
  ) {
    return Container(
      margin: EdgeInsets.only(right: isMobile ? 0 : 8), // No right margin for mobile wrap
      child: ActionChip(
        avatar: Icon(
          icon,
          size: isMobile ? 16 : 18,
          color: color,
        ),
        label: Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w500,
            fontSize: isMobile ? 12 : 14,
          ),
        ),
        onPressed: onTap,
        backgroundColor: color.withOpacity(0.1),
        side: BorderSide(color: color.withOpacity(0.3)),
        materialTapTargetSize: isMobile ? MaterialTapTargetSize.shrinkWrap : MaterialTapTargetSize.padded,
        visualDensity: isMobile ? VisualDensity.compact : VisualDensity.standard,
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 8 : 12,
          vertical: isMobile ? 4 : 6,
        ),
      ),
    );
  }
} 