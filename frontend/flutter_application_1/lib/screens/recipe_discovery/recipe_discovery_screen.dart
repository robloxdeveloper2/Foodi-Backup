import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/recipe_discovery_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/recipe_discovery/recipe_search_bar.dart';
import '../../widgets/recipe_discovery/recipe_filter_sheet.dart';
import '../../widgets/recipe_discovery/recipe_grid.dart';
import '../../widgets/recipe_discovery/trending_recipes_section.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_message.dart';
import '../../widgets/common/empty_state.dart';
import '../../providers/auth_provider.dart';

class RecipeDiscoveryScreen extends StatefulWidget {
  const RecipeDiscoveryScreen({Key? key}) : super(key: key);

  @override
  State<RecipeDiscoveryScreen> createState() => _RecipeDiscoveryScreenState();
}

class _RecipeDiscoveryScreenState extends State<RecipeDiscoveryScreen>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    // Initialize the provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final provider = context.read<RecipeDiscoveryProvider>();
      
      // Ensure auth token is set
      if (authProvider.isAuthenticated && authProvider.token != null) {
        provider.setAuthToken(authProvider.token!);
      }
      
      provider.initialize();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Load more recipes when near the bottom
      final provider = context.read<RecipeDiscoveryProvider>();
      provider.loadMoreRecipes();
    }
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const RecipeFilterSheet(),
    );
  }

  void _showSortOptions() {
    final provider = context.read<RecipeDiscoveryProvider>();
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar for mobile
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Text(
              'Sort By',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSortOption('Name (A-Z)', 'name', 'asc', provider),
            _buildSortOption('Name (Z-A)', 'name', 'desc', provider),
            _buildSortOption('Prep Time (Low to High)', 'prep_time', 'asc', provider),
            _buildSortOption('Prep Time (High to Low)', 'prep_time', 'desc', provider),
            _buildSortOption('Cost (Low to High)', 'cost', 'asc', provider),
            _buildSortOption('Cost (High to Low)', 'cost', 'desc', provider),
            _buildSortOption('Difficulty (Easy to Hard)', 'difficulty', 'asc', provider),
            _buildSortOption('Difficulty (Hard to Easy)', 'difficulty', 'desc', provider),
            _buildSortOption('Newest First', 'created_at', 'desc', provider),
            _buildSortOption('Oldest First', 'created_at', 'asc', provider),
            // Bottom padding for mobile safe area
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(String label, String sortBy, String sortOrder, RecipeDiscoveryProvider provider) {
    final isSelected = provider.sortBy == sortBy && provider.sortOrder == sortOrder;
    
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        label,
        style: TextStyle(
          fontSize: 16,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      trailing: isSelected ? const Icon(Icons.check, color: Colors.green) : null,
      onTap: () {
        provider.updateSort(sortBy, sortOrder);
        Navigator.pop(context);
      },
    );
  }

  // Get responsive padding based on screen size
  EdgeInsets _getResponsivePadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 600) {
      return const EdgeInsets.symmetric(horizontal: 12, vertical: 8); // Mobile
    } else {
      return const EdgeInsets.all(16); // Tablet/Desktop
    }
  }

  // Get responsive horizontal padding
  double _getHorizontalPadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 600) {
      return 12; // Mobile
    } else {
      return 16; // Tablet/Desktop
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          'Discover Recipes',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: isMobile ? 18 : 20,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black87),
        elevation: 1,
        shadowColor: Colors.grey.withOpacity(0.1),
        actions: [
          // Sort button - smaller on mobile
          IconButton(
            icon: Icon(
              Icons.sort, 
              color: Colors.black87,
              size: isMobile ? 22 : 24,
            ),
            onPressed: _showSortOptions,
            tooltip: 'Sort recipes',
          ),
          // Filter button with indicator
          Consumer<RecipeDiscoveryProvider>(
            builder: (context, provider, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.filter_list, 
                      color: Colors.black87,
                      size: isMobile ? 22 : 24,
                    ),
                    onPressed: _showFilterSheet,
                    tooltip: 'Filter recipes',
                  ),
                  if (provider.hasActiveFilters)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          SizedBox(width: isMobile ? 4 : 8),
        ],
      ),
      body: Column(
        children: [
          // Search bar section - responsive padding
          Container(
            padding: _getResponsivePadding(context),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: RecipeSearchBar(
              controller: _searchController,
              onChanged: (query) {
                context.read<RecipeDiscoveryProvider>().updateSearchQuery(query);
              },
              onClear: () {
                _searchController.clear();
                context.read<RecipeDiscoveryProvider>().updateSearchQuery('');
              },
            ),
          ),
          
          // Content
          Expanded(
            child: Consumer<RecipeDiscoveryProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.recipes.isEmpty) {
                  return const Center(child: LoadingIndicator());
                }

                if (provider.error != null && provider.recipes.isEmpty) {
                  return ErrorMessage(
                    message: provider.error!,
                    onRetry: () => provider.searchRecipes(),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => provider.searchRecipes(resetPage: true),
                  child: CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      // Show trending recipes if no search/filters - responsive spacing
                      if (provider.searchQuery.isEmpty && !provider.hasActiveFilters) ...[
                        const SliverToBoxAdapter(
                          child: TrendingRecipesSection(),
                        ),
                        SliverToBoxAdapter(
                          child: SizedBox(height: isMobile ? 12 : 16),
                        ),
                      ],

                      // Active filters display - mobile optimized
                      if (provider.hasActiveFilters)
                        SliverToBoxAdapter(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: _getHorizontalPadding(context), 
                              vertical: isMobile ? 6 : 8,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Active filters:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey[600],
                                        fontSize: isMobile ? 13 : 14,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: provider.clearFilters,
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: isMobile ? 8 : 12,
                                          vertical: 4,
                                        ),
                                        minimumSize: Size.zero,
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: Text(
                                        'Clear All',
                                        style: TextStyle(
                                          fontSize: isMobile ? 12 : 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                // Mobile-friendly filter chips with wrapping
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: _buildActiveFilterChips(provider, isMobile),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Results count - responsive text size
                      if (provider.pagination != null)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: _getHorizontalPadding(context), 
                              vertical: isMobile ? 6 : 8,
                            ),
                            child: Text(
                              '${provider.pagination!.totalCount} recipes found',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: isMobile ? 13 : 14,
                              ),
                            ),
                          ),
                        ),

                      // Recipe grid - responsive cross axis count
                      if (provider.recipes.isEmpty && !provider.isLoading)
                        const SliverFillRemaining(
                          hasScrollBody: false,
                          child: EmptyState(
                            icon: Icons.restaurant_menu,
                            title: 'No recipes found',
                            message: 'Try adjusting your search or filters',
                          ),
                        )
                      else
                        RecipeGrid(
                          recipes: provider.recipes,
                          showFavoriteButtons: true,
                          crossAxisCount: isMobile ? 1 : 2, // Single column on mobile for better readability
                          onRecipeTap: (recipe) {
                            Navigator.pushNamed(
                              context,
                              '/recipe-details',
                              arguments: recipe.id,
                            );
                          },
                        ),

                      // Loading more indicator
                      if (provider.isLoadingMore)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.all(isMobile ? 12 : 16),
                            child: const Center(child: LoadingIndicator()),
                          ),
                        ),

                      // Bottom padding - responsive
                      SliverToBoxAdapter(
                        child: SizedBox(height: isMobile ? 16 : 24),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildActiveFilterChips(RecipeDiscoveryProvider provider, bool isMobile) {
    List<Widget> chips = [];
    final filters = provider.filters;

    if (filters.mealType != null) {
      chips.add(_buildFilterChip('Meal: ${filters.mealType}', () {
        provider.updateFilters(filters.copyWith(clearMealType: true));
      }, isMobile));
    }

    if (filters.cuisineType != null) {
      chips.add(_buildFilterChip('Cuisine: ${filters.cuisineType}', () {
        provider.updateFilters(filters.copyWith(clearCuisineType: true));
      }, isMobile));
    }

    if (filters.difficultyLevel != null) {
      chips.add(_buildFilterChip('Difficulty: ${filters.difficultyLevel}', () {
        provider.updateFilters(filters.copyWith(clearDifficultyLevel: true));
      }, isMobile));
    }

    if (filters.maxPrepTime != null) {
      chips.add(_buildFilterChip('Max time: ${filters.maxPrepTime}min', () {
        provider.updateFilters(filters.copyWith(clearMaxPrepTime: true));
      }, isMobile));
    }

    if (filters.dietaryRestrictions.isNotEmpty) {
      for (String restriction in filters.dietaryRestrictions) {
        chips.add(_buildFilterChip(restriction, () {
          final newRestrictions = List<String>.from(filters.dietaryRestrictions);
          newRestrictions.remove(restriction);
          provider.updateFilters(filters.copyWith(dietaryRestrictions: newRestrictions));
        }, isMobile));
      }
    }

    return chips;
  }

  Widget _buildFilterChip(String label, VoidCallback onRemove, bool isMobile) {
    return Chip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: isMobile ? 11 : 12,
        ),
      ),
      deleteIcon: Icon(
        Icons.close, 
        size: isMobile ? 14 : 16,
      ),
      onDeleted: onRemove,
      backgroundColor: Colors.blue[50],
      deleteIconColor: Colors.blue[700],
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: isMobile ? VisualDensity.compact : VisualDensity.standard,
    );
  }
} 