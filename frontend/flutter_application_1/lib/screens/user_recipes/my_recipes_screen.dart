import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/user_recipe_provider.dart';
import '../recipe_detail/recipe_detail_screen.dart';

class MyRecipesScreen extends StatefulWidget {
  const MyRecipesScreen({super.key});

  @override
  State<MyRecipesScreen> createState() => _MyRecipesScreenState();
}

class _MyRecipesScreenState extends State<MyRecipesScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    });

    // Initialize provider data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserRecipeProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Recipes',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.background,
        foregroundColor: Theme.of(context).colorScheme.onBackground,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.restaurant_menu),
              text: 'All Recipes',
            ),
            Tab(
              icon: Icon(Icons.edit),
              text: 'Custom',
            ),
            Tab(
              icon: Icon(Icons.category),
              text: 'Categories',
            ),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(context),
            tooltip: 'Search recipes',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) => _handleMenuAction(context, value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'refresh',
                child: ListTile(
                  leading: Icon(Icons.refresh),
                  title: Text('Refresh'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'filter',
                child: ListTile(
                  leading: Icon(Icons.filter_list),
                  title: Text('Filters'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'stats',
                child: ListTile(
                  leading: Icon(Icons.analytics),
                  title: Text('Statistics'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _RecipeCollectionTab(),
          _RecipeCollectionTab(showCustomOnly: true),
          _CategoriesTab(),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  Widget? _buildFloatingActionButton(BuildContext context) {
    // Show FAB only on All Recipes and Custom tabs
    if (_currentTabIndex == 0 || _currentTabIndex == 1) {
      return FloatingActionButton.extended(
        onPressed: () => _navigateToCreateRecipe(context),
        icon: const Icon(Icons.add),
        label: const Text('Create Recipe'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      );
    }
    
    // Show different FAB for Categories tab
    if (_currentTabIndex == 2) {
      return FloatingActionButton.extended(
        onPressed: () => _showCreateCategoryDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Category'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      );
    }
    
    return null;
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _SearchDialog(),
    );
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'refresh':
        _refreshData(context);
        break;
      case 'filter':
        _showFilterDialog(context);
        break;
      case 'stats':
        _showStatsDialog(context);
        break;
    }
  }

  void _refreshData(BuildContext context) {
    final provider = context.read<UserRecipeProvider>();
    provider.loadUserRecipes(refresh: true);
    provider.loadCategories();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Refreshing recipes...'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _FilterDialog(),
    );
  }

  void _showStatsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _StatsDialog(),
    );
  }

  void _navigateToCreateRecipe(BuildContext context) {
    // TODO: Navigate to create recipe screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Create Recipe screen not implemented yet'),
      ),
    );
  }

  void _showCreateCategoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _CreateCategoryDialog(),
    );
  }
}

// Search Dialog Widget
class _SearchDialog extends StatefulWidget {
  @override
  State<_SearchDialog> createState() => _SearchDialogState();
}

class _SearchDialogState extends State<_SearchDialog> {
  late TextEditingController _searchController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    final provider = context.read<UserRecipeProvider>();
    _searchQuery = provider.filters.searchQuery ?? '';
    _searchController = TextEditingController(text: _searchQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Search Recipes'),
      content: TextField(
        controller: _searchController,
        decoration: const InputDecoration(
          hintText: 'Enter recipe name or ingredient...',
          prefixIcon: Icon(Icons.search),
        ),
        autofocus: true,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        onSubmitted: (value) => _performSearch(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _searchQuery.trim().isEmpty ? null : _performSearch,
          child: const Text('Search'),
        ),
        if (_searchQuery.isNotEmpty)
          TextButton(
            onPressed: _clearSearch,
            child: const Text('Clear'),
          ),
      ],
    );
  }

  void _performSearch() {
    final provider = context.read<UserRecipeProvider>();
    provider.searchRecipes(_searchQuery.trim());
    Navigator.of(context).pop();
  }

  void _clearSearch() {
    final provider = context.read<UserRecipeProvider>();
    provider.searchRecipes('');
    Navigator.of(context).pop();
  }
}

// Filter Dialog Widget  
class _FilterDialog extends StatefulWidget {
  @override
  State<_FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<_FilterDialog> {
  late String? _selectedCategoryId;
  late String? _selectedMealType;
  late String? _selectedCuisineType;
  late bool? _isCustomOnly;

  @override
  void initState() {
    super.initState();
    final filters = context.read<UserRecipeProvider>().filters;
    _selectedCategoryId = filters.categoryId;
    _selectedMealType = filters.mealType;
    _selectedCuisineType = filters.cuisineType;
    _isCustomOnly = filters.isCustomOnly;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserRecipeProvider>(
      builder: (context, provider, child) {
        return AlertDialog(
          title: const Text('Filter Recipes'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Category', style: TextStyle(fontWeight: FontWeight.bold)),
                DropdownButtonFormField<String?>(
                  value: _selectedCategoryId,
                  decoration: const InputDecoration(
                    hintText: 'Select category',
                  ),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('All categories'),
                    ),
                    ...provider.categories.map((category) => DropdownMenuItem<String?>(
                      value: category.id,
                      child: Text(category.name),
                    )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedCategoryId = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                const Text('Recipe Type', style: TextStyle(fontWeight: FontWeight.bold)),
                DropdownButtonFormField<bool?>(
                  value: _isCustomOnly,
                  decoration: const InputDecoration(
                    hintText: 'Select type',
                  ),
                  items: const [
                    DropdownMenuItem<bool?>(
                      value: null,
                      child: Text('All recipes'),
                    ),
                    DropdownMenuItem<bool?>(
                      value: true,
                      child: Text('Custom recipes only'),
                    ),
                    DropdownMenuItem<bool?>(
                      value: false,
                      child: Text('Favorited recipes only'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _isCustomOnly = value;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: _clearFilters,
              child: const Text('Clear All'),
            ),
            TextButton(
              onPressed: _applyFilters,
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }

  void _applyFilters() {
    final provider = context.read<UserRecipeProvider>();
    final newFilters = provider.filters.copyWith(
      categoryId: _selectedCategoryId,
      mealType: _selectedMealType,
      cuisineType: _selectedCuisineType,
      isCustomOnly: _isCustomOnly,
    );
    provider.updateFilters(newFilters);
    Navigator.of(context).pop();
  }

  void _clearFilters() {
    final provider = context.read<UserRecipeProvider>();
    provider.clearFilters();
    Navigator.of(context).pop();
  }
}

// Statistics Dialog Widget
class _StatsDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserRecipeProvider>(
      builder: (context, provider, child) {
        final totalRecipes = provider.totalCount;
        final customRecipes = provider.customRecipes.length;
        final favoritedRecipes = provider.favoritedRecipes.length;
        final totalCategories = provider.categories.length;

        return AlertDialog(
          title: const Text('Recipe Statistics'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _StatRow(label: 'Total Recipes', value: totalRecipes.toString()),
              _StatRow(label: 'Custom Recipes', value: customRecipes.toString()),
              _StatRow(label: 'Favorited Recipes', value: favoritedRecipes.toString()),
              _StatRow(label: 'Categories', value: totalCategories.toString()),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

// Create Category Dialog Widget
class _CreateCategoryDialog extends StatefulWidget {
  @override
  State<_CreateCategoryDialog> createState() => _CreateCategoryDialogState();
}

class _CreateCategoryDialogState extends State<_CreateCategoryDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  Color _selectedColor = Colors.blue;
  bool _isCreating = false;

  final List<Color> _availableColors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.teal,
    Colors.amber,
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Category'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Category Name',
                hintText: 'e.g., Quick & Easy',
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                hintText: 'Brief description of this category',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            const Text('Color', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableColors.map((color) {
                final isSelected = color == _selectedColor;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = color;
                    });
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: Colors.black, width: 3)
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isCreating ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _isCreating || _nameController.text.trim().isEmpty
              ? null
              : _createCategory,
          child: _isCreating
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create'),
        ),
      ],
    );
  }

  Future<void> _createCategory() async {
    if (_nameController.text.trim().isEmpty) return;

    setState(() {
      _isCreating = true;
    });

    try {
      final provider = context.read<UserRecipeProvider>();
      await provider.createCategory(
        _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        color: _selectedColor,
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Category "${_nameController.text.trim()}" created'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating category: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }
}

// Placeholder widgets (to be replaced with actual implementations)
class _RecipeCollectionTab extends StatelessWidget {
  final bool showCustomOnly;

  const _RecipeCollectionTab({this.showCustomOnly = false});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserRecipeProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red[300],
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading recipes',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  provider.error!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.loadUserRecipes(refresh: true),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final recipes = showCustomOnly ? provider.customRecipes : provider.recipes;

        if (recipes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  showCustomOnly ? Icons.edit : Icons.favorite_border,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  showCustomOnly 
                      ? 'No custom recipes yet'
                      : 'No recipes in your collection',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  showCustomOnly
                      ? 'Create your first custom recipe!'
                      : 'Start by favoriting recipes or creating custom ones.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.loadUserRecipes(refresh: true),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: recipes.length + (provider.hasNextPage ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= recipes.length) {
                // Load more indicator
                if (!provider.isLoadingMore) {
                  provider.loadMoreRecipes();
                }
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final recipe = recipes[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 56,
                      height: 56,
                      color: Colors.grey[200],
                      child: recipe.imageUrl != null
                          ? Image.network(
                              recipe.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.restaurant,
                                  color: Colors.grey[400],
                                );
                              },
                            )
                          : Icon(
                              Icons.restaurant,
                              color: Colors.grey[400],
                            ),
                    ),
                  ),
                  title: Text(
                    recipe.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (recipe.description != null)
                        Text(
                          recipe.description!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (recipe.isCustom)
                            const Chip(
                              label: Text('Custom'),
                              backgroundColor: Colors.blue,
                              labelStyle: TextStyle(color: Colors.white, fontSize: 12),
                            )
                          else
                            const Chip(
                              label: Text('Favorited'),
                              backgroundColor: Colors.red,
                              labelStyle: TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          const SizedBox(width: 8),
                          Text('${recipe.servings} servings'),
                        ],
                      ),
                    ],
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'view',
                        child: ListTile(
                          leading: Icon(Icons.visibility),
                          title: Text('View'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      if (recipe.isCustom)
                        const PopupMenuItem(
                          value: 'edit',
                          child: ListTile(
                            leading: Icon(Icons.edit),
                            title: Text('Edit'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      const PopupMenuItem(
                        value: 'share',
                        child: ListTile(
                          leading: Icon(Icons.share),
                          title: Text('Share'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(Icons.delete),
                          title: Text('Delete'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      _handleRecipeAction(context, recipe, value);
                    },
                  ),
                  onTap: () {
                    _navigateToRecipeDetail(context, recipe);
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _handleRecipeAction(BuildContext context, dynamic recipe, String action) {
    switch (action) {
      case 'view':
        _navigateToRecipeDetail(context, recipe);
        break;
      case 'edit':
        if (recipe.isCustom) {
          _navigateToEditRecipe(context, recipe);
        }
        break;
      case 'share':
        _shareRecipe(context, recipe);
        break;
      case 'delete':
        _showDeleteConfirmation(context, recipe);
        break;
    }
  }

  void _navigateToRecipeDetail(BuildContext context, dynamic recipe) {
    if (recipe.isCustom) {
      // For custom recipes, show our own detail view since RecipeDetailScreen 
      // can't load custom recipes from the user_recipes table
      _showCustomRecipeDetail(context, recipe);
    } else {
      // For favorited recipes, use the full RecipeDetailScreen with original recipe ID
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => RecipeDetailScreen(recipeId: recipe.originalRecipeId!),
        ),
      );
    }
  }

  void _showCustomRecipeDetail(BuildContext context, dynamic recipe) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(recipe.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _navigateToEditRecipe(context, recipe),
                tooltip: 'Edit Recipe',
              ),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () => _shareRecipe(context, recipe),
                tooltip: 'Share Recipe',
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'delete') {
                    _showDeleteConfirmation(context, recipe);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete Recipe'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Recipe image
                if (recipe.imageUrl != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      recipe.imageUrl!,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.restaurant,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Recipe title and basic info
                Text(
                  recipe.name,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                
                if (recipe.description != null) ...[
                  Text(
                    recipe.description!,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Recipe metadata
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Chip(
                      label: const Text('Custom Recipe'),
                      backgroundColor: Colors.blue,
                      labelStyle: const TextStyle(color: Colors.white),
                      avatar: const Icon(Icons.edit, color: Colors.white, size: 18),
                    ),
                    Chip(
                      label: Text('${recipe.servings} servings'),
                      backgroundColor: Colors.grey[200],
                    ),
                    if (recipe.prepTimeMinutes != null)
                      Chip(
                        label: Text('${recipe.prepTimeMinutes} min prep'),
                        backgroundColor: Colors.green[100],
                      ),
                    if (recipe.cookTimeMinutes != null)
                      Chip(
                        label: Text('${recipe.cookTimeMinutes} min cook'),
                        backgroundColor: Colors.orange[100],
                      ),
                    if (recipe.difficultyLevel != null)
                      Chip(
                        label: Text(recipe.difficultyLevel!),
                        backgroundColor: Colors.purple[100],
                      ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Ingredients section
                const Text(
                  'Ingredients',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...recipe.ingredients.map<Widget>((ingredient) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.only(top: 8, right: 12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '${ingredient.quantity} ${ingredient.unit} ${ingredient.name}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                )).toList(),
                
                const SizedBox(height: 24),
                
                // Instructions section
                const Text(
                  'Instructions',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Text(
                    recipe.instructions,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Categories if any
                if (recipe.categories.isNotEmpty) ...[
                  const Text(
                    'Categories',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: recipe.categories.map<Widget>((category) => Chip(
                      label: Text(category.name),
                      backgroundColor: category.color ?? Colors.blue,
                      labelStyle: const TextStyle(color: Colors.white),
                    )).toList(),
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Nutritional info if available
                if (recipe.nutritionalInfo != null) ...[
                  const Text(
                    'Nutrition (per serving)',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Calories'),
                              Text('${recipe.nutritionalInfo!.calories}'),
                            ],
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Protein'),
                              Text('${recipe.nutritionalInfo!.proteinGrams}g'),
                            ],
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Carbs'),
                              Text('${recipe.nutritionalInfo!.carbsGrams}g'),
                            ],
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Fat'),
                              Text('${recipe.nutritionalInfo!.fatGrams}g'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToEditRecipe(BuildContext context, dynamic recipe) {
    Navigator.of(context).pushNamed(
      '/custom-recipe-form',
      arguments: recipe,
    );
  }

  void _shareRecipe(BuildContext context, dynamic recipe) {
    final String recipeText = '''
${recipe.name}

${recipe.description ?? ''}

Servings: ${recipe.servings}

Ingredients:
${recipe.ingredients.map((i) => '• ${i.name} - ${i.quantity} ${i.unit}').join('\n')}

Instructions:
${recipe.instructions}
''';

    // For now, show in a dialog - in a real app you'd use Share plugin
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share Recipe'),
        content: SingleChildScrollView(
          child: Text(recipeText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, dynamic recipe) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Recipe'),
        content: Text('Are you sure you want to delete "${recipe.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteRecipe(context, recipe);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteRecipe(BuildContext context, dynamic recipe) {
    final provider = context.read<UserRecipeProvider>();
    
    if (recipe.isCustom) {
      provider.deleteUserRecipe(recipe.id);
    } else {
      provider.unfavoriteRecipe(recipe.id);
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${recipe.name} deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            // TODO: Implement undo functionality
          },
        ),
      ),
    );
  }
}

class _CategoriesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserRecipeProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingCategories) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (provider.categoriesError != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red[300],
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading categories',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  provider.categoriesError!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.loadCategories(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (provider.categories.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.category,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No categories yet',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Create categories to organize your recipes.',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.loadCategories(),
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
            ),
            itemCount: provider.categories.length,
            itemBuilder: (context, index) {
              final category = provider.categories[index];
              final recipeCount = provider.getRecipesByCategory(category.id).length;

              return Card(
                elevation: 2,
                child: InkWell(
                  onTap: () {
                    provider.filterByCategory(category.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Filtered by ${category.name}'),
                        action: SnackBarAction(
                          label: 'Clear',
                          onPressed: () => provider.filterByCategory(null),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          category.color ?? Colors.blue,
                          (category.color ?? Colors.blue).withOpacity(0.7),
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  category.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert, color: Colors.white),
                                onSelected: (value) {
                                  // TODO: Handle category actions
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('$value action not implemented yet')),
                                  );
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: ListTile(
                                      leading: Icon(Icons.edit),
                                      title: Text('Edit'),
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: ListTile(
                                      leading: Icon(Icons.delete),
                                      title: Text('Delete'),
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Spacer(),
                          if (category.description != null)
                            Text(
                              category.description!,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          const SizedBox(height: 8),
                          Text(
                            '$recipeCount ${recipeCount == 1 ? 'recipe' : 'recipes'}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
} 