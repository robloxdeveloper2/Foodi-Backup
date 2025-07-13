import 'package:flutter/foundation.dart';
import 'dart:async';

import '../models/recipe_models.dart';
import '../services/recipe_discovery_service.dart';

class RecipeDiscoveryProvider with ChangeNotifier {
  final RecipeDiscoveryService _recipeService = RecipeDiscoveryService();

  // Search state
  List<Recipe> _recipes = [];
  RecipePagination? _pagination;
  String _searchQuery = '';
  RecipeFilters _filters = RecipeFilters();
  String _sortBy = 'name';
  String _sortOrder = 'asc';
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;

  // Filter options
  FilterOptions? _filterOptions;
  bool _isLoadingFilterOptions = false;

  // Search suggestions
  List<String> _searchSuggestions = [];
  bool _isLoadingSuggestions = false;
  Timer? _searchDebounceTimer;

  // Trending and recommendations
  List<Recipe> _trendingRecipes = [];
  List<Recipe> _personalizedRecommendations = [];
  bool _isLoadingTrending = false;
  bool _isLoadingRecommendations = false;

  // Selected recipe details
  Recipe? _selectedRecipe;
  bool _isLoadingRecipeDetails = false;

  // Getters
  List<Recipe> get recipes => _recipes;
  RecipePagination? get pagination => _pagination;
  String get searchQuery => _searchQuery;
  RecipeFilters get filters => _filters;
  String get sortBy => _sortBy;
  String get sortOrder => _sortOrder;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;

  FilterOptions? get filterOptions => _filterOptions;
  bool get isLoadingFilterOptions => _isLoadingFilterOptions;

  List<String> get searchSuggestions => _searchSuggestions;
  bool get isLoadingSuggestions => _isLoadingSuggestions;

  List<Recipe> get trendingRecipes => _trendingRecipes;
  List<Recipe> get personalizedRecommendations => _personalizedRecommendations;
  bool get isLoadingTrending => _isLoadingTrending;
  bool get isLoadingRecommendations => _isLoadingRecommendations;

  Recipe? get selectedRecipe => _selectedRecipe;
  bool get isLoadingRecipeDetails => _isLoadingRecipeDetails;

  bool get hasActiveFilters => _filters.hasActiveFilters;
  bool get hasNextPage => _pagination?.hasNext ?? false;
  bool get hasPreviousPage => _pagination?.hasPrevious ?? false;

  // Set auth token
  void setAuthToken(String token) {
    _recipeService.setAuthToken(token);
  }

  // Clear auth token
  void clearAuthToken() {
    _recipeService.clearAuthToken();
  }

  /// Initialize the provider by loading filter options and trending recipes
  Future<void> initialize() async {
    await Future.wait([
      loadFilterOptions(),
      loadTrendingRecipes(),
      loadPersonalizedRecommendations(),
    ]);
  }

  /// Search recipes with current filters and query
  Future<void> searchRecipes({bool resetPage = true}) async {
    if (resetPage) {
      _isLoading = true;
      _error = null;
      _recipes.clear();
    } else {
      _isLoadingMore = true;
    }
    notifyListeners();

    try {
      final page = resetPage ? 1 : (_pagination?.page ?? 1) + 1;
      
      final result = await _recipeService.searchRecipes(
        searchQuery: _searchQuery,
        filters: _filters,
        page: page,
        limit: 20,
        sortBy: _sortBy,
        sortOrder: _sortOrder,
      );

      if (resetPage) {
        _recipes = result.recipes;
      } else {
        _recipes.addAll(result.recipes);
      }
      
      _pagination = result.pagination;
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error searching recipes: $e');
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Update search query and trigger search with debouncing
  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();

    // Cancel previous timer
    _searchDebounceTimer?.cancel();

    // Set new timer for debounced search
    _searchDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      searchRecipes(resetPage: true);
    });

    // Also update search suggestions
    updateSearchSuggestions(query);
  }

  /// Update filters and trigger search
  void updateFilters(RecipeFilters newFilters) {
    _filters = newFilters;
    notifyListeners();
    searchRecipes(resetPage: true);
  }

  /// Clear all filters
  void clearFilters() {
    _filters = RecipeFilters();
    notifyListeners();
    searchRecipes(resetPage: true);
  }

  /// Update sorting and trigger search
  void updateSort(String sortBy, String sortOrder) {
    _sortBy = sortBy;
    _sortOrder = sortOrder;
    notifyListeners();
    searchRecipes(resetPage: true);
  }

  /// Load more recipes (pagination)
  Future<void> loadMoreRecipes() async {
    if (!hasNextPage || _isLoadingMore) return;
    await searchRecipes(resetPage: false);
  }

  /// Load filter options from the API
  Future<void> loadFilterOptions() async {
    _isLoadingFilterOptions = true;
    notifyListeners();

    try {
      _filterOptions = await _recipeService.getFilterOptions();
    } catch (e) {
      debugPrint('Error loading filter options: $e');
    } finally {
      _isLoadingFilterOptions = false;
      notifyListeners();
    }
  }

  /// Update search suggestions with debouncing
  void updateSearchSuggestions(String query) {
    if (query.length < 2) {
      _searchSuggestions.clear();
      notifyListeners();
      return;
    }

    _isLoadingSuggestions = true;
    notifyListeners();

    // Debounce suggestions
    Timer(const Duration(milliseconds: 300), () async {
      try {
        _searchSuggestions = await _recipeService.getSearchSuggestions(query);
      } catch (e) {
        debugPrint('Error loading search suggestions: $e');
        _searchSuggestions.clear();
      } finally {
        _isLoadingSuggestions = false;
        notifyListeners();
      }
    });
  }

  /// Clear search suggestions
  void clearSearchSuggestions() {
    _searchSuggestions.clear();
    notifyListeners();
  }

  /// Load trending recipes
  Future<void> loadTrendingRecipes() async {
    _isLoadingTrending = true;
    notifyListeners();

    try {
      _trendingRecipes = await _recipeService.getTrendingRecipes(limit: 10);
    } catch (e) {
      debugPrint('Error loading trending recipes: $e');
    } finally {
      _isLoadingTrending = false;
      notifyListeners();
    }
  }

  /// Load personalized recommendations
  Future<void> loadPersonalizedRecommendations() async {
    _isLoadingRecommendations = true;
    notifyListeners();

    try {
      _personalizedRecommendations = await _recipeService.getPersonalizedRecommendations(limit: 10);
    } catch (e) {
      debugPrint('Error loading personalized recommendations: $e');
    } finally {
      _isLoadingRecommendations = false;
      notifyListeners();
    }
  }

  /// Load recipe details
  Future<void> loadRecipeDetails(String recipeId) async {
    _isLoadingRecipeDetails = true;
    _selectedRecipe = null;
    notifyListeners();

    try {
      _selectedRecipe = await _recipeService.getRecipeDetails(recipeId);
    } catch (e) {
      debugPrint('Error loading recipe details: $e');
      _error = e.toString();
    } finally {
      _isLoadingRecipeDetails = false;
      notifyListeners();
    }
  }

  /// Clear selected recipe
  void clearSelectedRecipe() {
    _selectedRecipe = null;
    notifyListeners();
  }

  /// Quick filter methods
  void filterByMealType(String mealType) {
    updateFilters(_filters.copyWith(mealType: mealType));
  }

  void filterByCuisineType(String cuisineType) {
    updateFilters(_filters.copyWith(cuisineType: cuisineType));
  }

  void filterByDietaryRestrictions(List<String> restrictions) {
    updateFilters(_filters.copyWith(dietaryRestrictions: restrictions));
  }

  void filterByDifficulty(String difficulty) {
    updateFilters(_filters.copyWith(difficultyLevel: difficulty));
  }

  void filterByMaxTime(int maxTime) {
    updateFilters(_filters.copyWith(maxPrepTime: maxTime));
  }

  void filterByCostRange(double? minCost, double? maxCost) {
    updateFilters(_filters.copyWith(
      minCostUsd: minCost,
      maxCostUsd: maxCost,
    ));
  }

  /// Convenience methods for common searches
  Future<void> searchQuickRecipes() async {
    updateFilters(RecipeFilters(maxPrepTime: 30));
    updateSort('prep_time', 'asc');
  }

  Future<void> searchBudgetFriendlyRecipes() async {
    updateFilters(RecipeFilters(maxCostUsd: 5.0));
    updateSort('cost', 'asc');
  }

  Future<void> searchBeginnerRecipes() async {
    updateFilters(RecipeFilters(difficultyLevel: 'beginner'));
  }

  Future<void> searchVegetarianRecipes() async {
    updateFilters(RecipeFilters(dietaryRestrictions: ['vegetarian']));
  }

  Future<void> searchVeganRecipes() async {
    updateFilters(RecipeFilters(dietaryRestrictions: ['vegan']));
  }

  /// Reset all state
  void reset() {
    _recipes.clear();
    _pagination = null;
    _searchQuery = '';
    _filters = RecipeFilters();
    _sortBy = 'name';
    _sortOrder = 'asc';
    _isLoading = false;
    _isLoadingMore = false;
    _error = null;
    _searchSuggestions.clear();
    _selectedRecipe = null;
    _searchDebounceTimer?.cancel();
    notifyListeners();
  }

  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    super.dispose();
  }
} 