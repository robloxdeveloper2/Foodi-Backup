import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import '../models/user_recipe_models.dart';
import '../services/user_recipe_service.dart';

class UserRecipeProvider with ChangeNotifier {
  final UserRecipeService _userRecipeService = UserRecipeService();

  // Recipe Collection State
  UserRecipeCollection? _collection;
  RecipeCollectionFilters _filters = const RecipeCollectionFilters();
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;

  // Categories State
  List<UserRecipeCategory> _categories = [];
  bool _isLoadingCategories = false;
  String? _categoriesError;

  // Selected Recipe State
  UserRecipe? _selectedRecipe;
  bool _isLoadingRecipe = false;

  // Recipe Creation/Editing State
  bool _isCreatingRecipe = false;
  bool _isUpdatingRecipe = false;
  String? _creationError;

  // Favorites State
  Map<String, bool> _favoriteStatus = {};
  Set<String> _loadingFavorites = {};

  // Initialization State
  bool _isInitialized = false;

  // Getters
  UserRecipeCollection? get collection => _collection;
  List<UserRecipe> get recipes => _collection?.recipes ?? [];
  List<UserRecipeCategory> get categories => _categories;
  RecipeCollectionFilters get filters => _filters;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get isLoadingCategories => _isLoadingCategories;
  String? get error => _error;
  String? get categoriesError => _categoriesError;

  UserRecipe? get selectedRecipe => _selectedRecipe;
  bool get isLoadingRecipe => _isLoadingRecipe;

  bool get isCreatingRecipe => _isCreatingRecipe;
  bool get isUpdatingRecipe => _isUpdatingRecipe;
  String? get creationError => _creationError;

  bool get hasNextPage => _collection?.pagination.hasNext ?? false;
  bool get hasPreviousPage => _collection?.pagination.hasPrevious ?? false;
  int get currentPage => _collection?.pagination.page ?? 1;
  int get totalCount => _collection?.totalCount ?? 0;

  // Custom recipes only
  List<UserRecipe> get customRecipes => recipes.where((recipe) => recipe.isCustom).toList();
  
  // Favorited recipes only
  List<UserRecipe> get favoritedRecipes => recipes.where((recipe) => !recipe.isCustom).toList();

  // Check if recipe has active filters
  bool get hasActiveFilters => _filters.hasActiveFilters;

  // Set auth token
  void setAuthToken(String token) {
    _userRecipeService.setAuthToken(token);
  }

  // Clear auth token
  void clearAuthToken() {
    _userRecipeService.clearAuthToken();
  }

  /// Initialize the provider by loading categories and recipes
  Future<void> initialize() async {
    if (_isInitialized) {
      return; // Already initialized
    }
    
    _isInitialized = true;
    await Future.wait([
      loadCategories(),
      loadUserRecipes(),
    ]);
  }

  /// Load user's recipe collection
  Future<void> loadUserRecipes({bool refresh = false}) async {
    if (refresh) {
      _isLoading = true;
      _error = null;
    } else if (_isLoading) {
      return; // Already loading
    } else {
      _isLoadingMore = true;
    }
    
    notifyListeners();

    try {
      final page = refresh ? 1 : currentPage + 1;
      
      final result = await _userRecipeService.getUserRecipes(
        filters: _filters,
        page: page,
        pageSize: 20,
        sortBy: _filters.sortBy,
        sortOrder: _filters.sortOrder,
      );

      if (refresh) {
        _collection = result;
      } else {
        // Append to existing collection
        if (_collection != null) {
          final updatedRecipes = [..._collection!.recipes, ...result.recipes];
          _collection = _collection!.copyWith(
            recipes: updatedRecipes,
            pagination: result.pagination,
          );
        } else {
          _collection = result;
        }
      }
      
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading user recipes: $e');
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Load more recipes (pagination)
  Future<void> loadMoreRecipes() async {
    if (!hasNextPage || _isLoadingMore) return;
    await loadUserRecipes(refresh: false);
  }

  /// Update filters and refresh recipes
  void updateFilters(RecipeCollectionFilters newFilters) {
    _filters = newFilters;
    notifyListeners();
    loadUserRecipes(refresh: true);
  }

  /// Clear all filters
  void clearFilters() {
    _filters = const RecipeCollectionFilters();
    notifyListeners();
    loadUserRecipes(refresh: true);
  }

  /// Search recipes with query
  void searchRecipes(String query) {
    final newFilters = _filters.copyWith(searchQuery: query);
    updateFilters(newFilters);
  }

  /// Filter by category
  void filterByCategory(String? categoryId) {
    final newFilters = _filters.copyWith(categoryId: categoryId);
    updateFilters(newFilters);
  }

  /// Filter by recipe type (custom vs favorited)
  void filterByType(bool? isCustomOnly) {
    final newFilters = _filters.copyWith(isCustomOnly: isCustomOnly);
    updateFilters(newFilters);
  }

  /// Load a specific recipe
  Future<void> loadRecipe(String recipeId) async {
    _isLoadingRecipe = true;
    _selectedRecipe = null;
    notifyListeners();

    try {
      _selectedRecipe = await _userRecipeService.getUserRecipe(recipeId);
    } catch (e) {
      debugPrint('Error loading recipe: $e');
      _error = e.toString();
    } finally {
      _isLoadingRecipe = false;
      notifyListeners();
    }
  }

  /// Check if a catalog recipe is favorited
  Future<bool> checkRecipeFavorited(String recipeId) async {
    // Check cache first
    if (_favoriteStatus.containsKey(recipeId)) {
      return _favoriteStatus[recipeId]!;
    }

    try {
      final isFavorited = await _userRecipeService.checkRecipeFavorited(recipeId);
      _favoriteStatus[recipeId] = isFavorited;
      return isFavorited;
    } catch (e) {
      debugPrint('Error checking favorite status: $e');
      return false;
    }
  }

  /// Add a catalog recipe to favorites
  Future<void> favoriteRecipe(String recipeId) async {
    if (_loadingFavorites.contains(recipeId)) return;

    _loadingFavorites.add(recipeId);
    notifyListeners();

    try {
      final userRecipe = await _userRecipeService.favoriteRecipe(recipeId);
      
      // Update cache
      _favoriteStatus[recipeId] = true;
      
      // Add to current collection if loaded
      if (_collection != null) {
        final updatedRecipes = [..._collection!.recipes, userRecipe];
        _collection = _collection!.copyWith(
          recipes: updatedRecipes,
          totalCount: _collection!.totalCount + 1,
        );
      }
      
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error favoriting recipe: $e');
      rethrow; // Restore error propagation so UI can react
    } finally {
      _loadingFavorites.remove(recipeId);
      notifyListeners();
    }
  }

  /// Remove a recipe from favorites
  Future<void> unfavoriteRecipe(String recipeId) async {
    if (_loadingFavorites.contains(recipeId)) return;

    _loadingFavorites.add(recipeId);
    notifyListeners();

    try {
      final success = await _userRecipeService.unfavoriteRecipe(recipeId);
      
      if (success) {
        // Update cache
        _favoriteStatus[recipeId] = false;
        
        // Remove from current collection if loaded
        if (_collection != null) {
          final updatedRecipes = _collection!.recipes
              .where((recipe) => recipe.originalRecipeId != recipeId)
              .toList();
          _collection = _collection!.copyWith(
            recipes: updatedRecipes,
            totalCount: _collection!.totalCount - 1,
          );
        }
      }
      
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error unfavoriting recipe: $e');
      rethrow;
    } finally {
      _loadingFavorites.remove(recipeId);
      notifyListeners();
    }
  }

  /// Check if a recipe is currently being favorited/unfavorited
  bool isLoadingFavorite(String recipeId) {
    return _loadingFavorites.contains(recipeId);
  }

  /// Create a new custom recipe
  Future<void> createCustomRecipe(CreateRecipeRequest request) async {
    _isCreatingRecipe = true;
    _creationError = null;
    notifyListeners();

    try {
      final userRecipe = await _userRecipeService.createCustomRecipe(request);
      
      // Add to current collection if loaded
      if (_collection != null) {
        final updatedRecipes = [userRecipe, ..._collection!.recipes];
        _collection = _collection!.copyWith(
          recipes: updatedRecipes,
          totalCount: _collection!.totalCount + 1,
        );
      }
      
      _creationError = null;
    } catch (e) {
      _creationError = e.toString();
      debugPrint('Error creating custom recipe: $e');
      rethrow;
    } finally {
      _isCreatingRecipe = false;
      notifyListeners();
    }
  }

  /// Update an existing custom recipe
  Future<void> updateCustomRecipe(String recipeId, UpdateRecipeRequest request) async {
    _isUpdatingRecipe = true;
    _creationError = null;
    notifyListeners();

    try {
      final updatedRecipe = await _userRecipeService.updateCustomRecipe(recipeId, request);
      
      // Update in current collection if loaded
      if (_collection != null) {
        final updatedRecipes = _collection!.recipes.map((recipe) {
          return recipe.id == recipeId ? updatedRecipe : recipe;
        }).toList();
        
        _collection = _collection!.copyWith(recipes: updatedRecipes);
      }
      
      // Update selected recipe if it's the same one
      if (_selectedRecipe?.id == recipeId) {
        _selectedRecipe = updatedRecipe;
      }
      
      _creationError = null;
    } catch (e) {
      _creationError = e.toString();
      debugPrint('Error updating custom recipe: $e');
      rethrow;
    } finally {
      _isUpdatingRecipe = false;
      notifyListeners();
    }
  }

  /// Delete a user recipe
  Future<void> deleteUserRecipe(String recipeId) async {
    try {
      final success = await _userRecipeService.deleteUserRecipe(recipeId);
      
      if (success) {
        // Remove from current collection if loaded
        if (_collection != null) {
          final updatedRecipes = _collection!.recipes
              .where((recipe) => recipe.id != recipeId)
              .toList();
          _collection = _collection!.copyWith(
            recipes: updatedRecipes,
            totalCount: _collection!.totalCount - 1,
          );
        }
        
        // Clear selected recipe if it's the same one
        if (_selectedRecipe?.id == recipeId) {
          _selectedRecipe = null;
        }
      }
      
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error deleting user recipe: $e');
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  /// Load user categories
  Future<void> loadCategories() async {
    _isLoadingCategories = true;
    _categoriesError = null;
    notifyListeners();

    try {
      _categories = await _userRecipeService.getCategories();
      _categoriesError = null;
    } catch (e) {
      _categoriesError = e.toString();
      debugPrint('Error loading categories: $e');
    } finally {
      _isLoadingCategories = false;
      notifyListeners();
    }
  }

  /// Create a new category
  Future<void> createCategory(String name, {String? description, Color? color}) async {
    try {
      final colorString = color != null ? '#${color.value.toRadixString(16).substring(2)}' : null;
      final category = await _userRecipeService.createCategory(name, description, colorString);
      
      _categories = [..._categories, category];
      _categoriesError = null;
      notifyListeners();
    } catch (e) {
      _categoriesError = e.toString();
      debugPrint('Error creating category: $e');
      rethrow;
    }
  }

  /// Update an existing category
  Future<void> updateCategory(String categoryId, String? name, {String? description, Color? color}) async {
    try {
      final colorString = color != null ? '#${color.value.toRadixString(16).substring(2)}' : null;
      final updatedCategory = await _userRecipeService.updateCategory(categoryId, name, description, colorString);
      
      _categories = _categories.map((cat) {
        return cat.id == categoryId ? updatedCategory : cat;
      }).toList();
      
      _categoriesError = null;
      notifyListeners();
    } catch (e) {
      _categoriesError = e.toString();
      debugPrint('Error updating category: $e');
      rethrow;
    }
  }

  /// Delete a category
  Future<void> deleteCategory(String categoryId) async {
    try {
      final success = await _userRecipeService.deleteCategory(categoryId);
      
      if (success) {
        _categories = _categories.where((cat) => cat.id != categoryId).toList();
        
        // Clear category filter if it was the deleted category
        if (_filters.categoryId == categoryId) {
          updateFilters(_filters.copyWith(categoryId: null));
        }
      }
      
      _categoriesError = null;
      notifyListeners();
    } catch (e) {
      _categoriesError = e.toString();
      debugPrint('Error deleting category: $e');
      rethrow;
    }
  }

  /// Create default categories for new users
  Future<void> createDefaultCategories() async {
    try {
      final defaultCategories = await _userRecipeService.createDefaultCategories();
      _categories = [..._categories, ...defaultCategories];
      _categoriesError = null;
      notifyListeners();
    } catch (e) {
      _categoriesError = e.toString();
      debugPrint('Error creating default categories: $e');
      rethrow;
    }
  }

  /// Export a recipe
  Future<String> exportRecipe(String recipeId, RecipeExportFormat format) async {
    try {
      return await _userRecipeService.exportRecipe(recipeId, format);
    } catch (e) {
      debugPrint('Error exporting recipe: $e');
      rethrow;
    }
  }

  /// Share a recipe
  Future<Map<String, dynamic>> shareRecipe(String recipeId) async {
    try {
      return await _userRecipeService.shareRecipe(recipeId);
    } catch (e) {
      debugPrint('Error sharing recipe: $e');
      rethrow;
    }
  }

  /// Get recipes by category
  List<UserRecipe> getRecipesByCategory(String categoryId) {
    return recipes.where((recipe) => 
      recipe.categories.any((cat) => cat.id == categoryId)
    ).toList();
  }

  /// Get category by ID
  UserRecipeCategory? getCategoryById(String categoryId) {
    try {
      return _categories.firstWhere((cat) => cat.id == categoryId);
    } catch (e) {
      return null;
    }
  }

  /// Clear all data (for logout)
  void clear() {
    _collection = null;
    _categories = [];
    _filters = const RecipeCollectionFilters();
    _selectedRecipe = null;
    _favoriteStatus.clear();
    _loadingFavorites.clear();
    _isLoading = false;
    _isLoadingMore = false;
    _isLoadingCategories = false;
    _isLoadingRecipe = false;
    _isCreatingRecipe = false;
    _isUpdatingRecipe = false;
    _error = null;
    _categoriesError = null;
    _creationError = null;
    notifyListeners();
  }
} 