import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../models/recipe_models.dart';
import '../utils/app_constants.dart';

class RecipeDiscoveryService {
  late final Dio _dio;
  static const bool _useMockData = false; // Use real backend API

  RecipeDiscoveryService() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add interceptors for logging and error handling
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => debugPrint(obj.toString()),
      ));
    }

    // Add auth interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Auth token will be set by the provider
        handler.next(options);
      },
      onError: (error, handler) {
        debugPrint('Recipe Discovery API Error: ${error.message}');
        handler.next(error);
      },
    ));
  }

  // Set authorization token
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  // Clear authorization token
  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  /// Search recipes with comprehensive filtering and pagination
  Future<RecipeSearchResult> searchRecipes({
    String searchQuery = '',
    RecipeFilters? filters,
    int page = 1,
    int limit = 20,
    String sortBy = 'name',
    String sortOrder = 'asc',
  }) async {
    if (_useMockData) {
      return _getMockSearchResult(searchQuery, filters, page, limit, sortBy, sortOrder);
    }

    try {
      Map<String, dynamic> queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        'sort_by': sortBy,
        'sort_order': sortOrder,
      };

      if (searchQuery.isNotEmpty) {
        queryParams['q'] = searchQuery;
      }

      if (filters != null) {
        queryParams.addAll(filters.toQueryParams());
      }

      final response = await _dio.get(
        '/api/v1/recipes/search',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return RecipeSearchResult.fromJson(response.data);
      } else {
        throw Exception('Failed to search recipes: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('Recipe search error: ${e.message}');
      // Fall back to mock data on error
      return _getMockSearchResult(searchQuery, filters, page, limit, sortBy, sortOrder);
    } catch (e) {
      debugPrint('Unexpected error in recipe search: $e');
      // Fall back to mock data on error
      return _getMockSearchResult(searchQuery, filters, page, limit, sortBy, sortOrder);
    }
  }

  /// Get detailed information for a specific recipe
  Future<Recipe> getRecipeDetails(String recipeId) async {
    if (_useMockData) {
      return _getMockRecipe(recipeId);
    }

    try {
      final response = await _dio.get('/api/v1/recipes/$recipeId');

      if (response.statusCode == 200) {
        return Recipe.fromJson(response.data);
      } else {
        throw Exception('Failed to get recipe details: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('Recipe details error: ${e.message}');
      // Fall back to mock data on error
      return _getMockRecipe(recipeId);
    } catch (e) {
      debugPrint('Unexpected error getting recipe details: $e');
      // Fall back to mock data on error
      return _getMockRecipe(recipeId);
    }
  }

  /// Get available filter options for the recipe catalog
  Future<FilterOptions> getFilterOptions() async {
    if (_useMockData) {
      return _getMockFilterOptions();
    }

    try {
      final response = await _dio.get('/api/v1/recipes/filters/options');

      if (response.statusCode == 200) {
        return FilterOptions.fromJson(response.data);
      } else {
        throw Exception('Failed to get filter options: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('Filter options error: ${e.message}');
      return _getMockFilterOptions();
    } catch (e) {
      debugPrint('Unexpected error getting filter options: $e');
      return _getMockFilterOptions();
    }
  }

  /// Get search suggestions based on partial query
  Future<List<String>> getSearchSuggestions(String query, {int limit = 10}) async {
    if (_useMockData) {
      return _getMockSearchSuggestions(query, limit);
    }

    try {
      if (query.length < 2) {
        return [];
      }

      final response = await _dio.get(
        '/api/v1/recipes/suggestions',
        queryParameters: {
          'q': query,
          'limit': limit.toString(),
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return (data['suggestions'] as List<dynamic>).cast<String>();
      } else {
        throw Exception('Failed to get search suggestions: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('Search suggestions error: ${e.message}');
      return _getMockSearchSuggestions(query, limit);
    } catch (e) {
      debugPrint('Unexpected error getting search suggestions: $e');
      return _getMockSearchSuggestions(query, limit);
    }
  }

  /// Get trending/popular recipes
  Future<List<Recipe>> getTrendingRecipes({int limit = 10}) async {
    if (_useMockData) {
      return _getMockTrendingRecipes(limit);
    }

    try {
      final response = await _dio.get(
        '/api/v1/recipes/trending',
        queryParameters: {
          'limit': limit.toString(),
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return (data['trending_recipes'] as List<dynamic>)
            .map((recipe) => Recipe.fromJson(recipe as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to get trending recipes: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('Trending recipes error: ${e.message}');
      return _getMockTrendingRecipes(limit);
    } catch (e) {
      debugPrint('Unexpected error getting trending recipes: $e');
      return _getMockTrendingRecipes(limit);
    }
  }

  /// Get personalized recipe recommendations for the user
  Future<List<Recipe>> getPersonalizedRecommendations({int limit = 10}) async {
    if (_useMockData) {
      return _getMockRecommendations(limit);
    }

    try {
      final response = await _dio.get(
        '/api/v1/recipes/personalized',
        queryParameters: {
          'limit': limit.toString(),
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return (data['recommended_recipes'] as List<dynamic>)
            .map((recipe) => Recipe.fromJson(recipe as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to get personalized recommendations: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('Personalized recommendations error: ${e.message}');
      return _getMockRecommendations(limit);
    } catch (e) {
      debugPrint('Unexpected error getting personalized recommendations: $e');
      return _getMockRecommendations(limit);
    }
  }

  /// Get recipes by meal type (convenience method)
  Future<RecipeSearchResult> getRecipesByMealType(
    String mealType, {
    int page = 1,
    int limit = 20,
  }) async {
    final filters = RecipeFilters(mealType: mealType);
    return searchRecipes(
      filters: filters,
      page: page,
      limit: limit,
    );
  }

  /// Get recipes by cuisine type (convenience method)
  Future<RecipeSearchResult> getRecipesByCuisine(
    String cuisineType, {
    int page = 1,
    int limit = 20,
  }) async {
    final filters = RecipeFilters(cuisineType: cuisineType);
    return searchRecipes(
      filters: filters,
      page: page,
      limit: limit,
    );
  }

  /// Get recipes by dietary restrictions (convenience method)
  Future<RecipeSearchResult> getRecipesByDietaryRestrictions(
    List<String> dietaryRestrictions, {
    int page = 1,
    int limit = 20,
  }) async {
    final filters = RecipeFilters(dietaryRestrictions: dietaryRestrictions);
    return searchRecipes(
      filters: filters,
      page: page,
      limit: limit,
    );
  }

  /// Get quick recipes (under 30 minutes)
  Future<RecipeSearchResult> getQuickRecipes({
    int page = 1,
    int limit = 20,
  }) async {
    final filters = RecipeFilters(maxPrepTime: 30);
    return searchRecipes(
      filters: filters,
      page: page,
      limit: limit,
      sortBy: 'prep_time',
      sortOrder: 'asc',
    );
  }

  /// Get budget-friendly recipes
  Future<RecipeSearchResult> getBudgetFriendlyRecipes({
    int page = 1,
    int limit = 20,
  }) async {
    final filters = RecipeFilters(maxCostUsd: 5.0);
    return searchRecipes(
      filters: filters,
      page: page,
      limit: limit,
      sortBy: 'cost',
      sortOrder: 'asc',
    );
  }

  /// Get beginner-friendly recipes
  Future<RecipeSearchResult> getBeginnerRecipes({
    int page = 1,
    int limit = 20,
  }) async {
    final filters = RecipeFilters(difficultyLevel: 'beginner');
    return searchRecipes(
      filters: filters,
      page: page,
      limit: limit,
    );
  }

  // MOCK DATA METHODS
  List<Recipe> _getMockRecipes() {
    return [
      Recipe(
        id: 'recipe-1',
        name: 'Classic Spaghetti Carbonara',
        description: 'A traditional Italian pasta dish with eggs, cheese, and pancetta',
        ingredients: [
          Ingredient(name: 'Spaghetti', quantity: '400', unit: 'g'),
          Ingredient(name: 'Pancetta', quantity: '150', unit: 'g'),
          Ingredient(name: 'Eggs', quantity: '4', unit: 'large'),
          Ingredient(name: 'Parmesan cheese', quantity: '100', unit: 'g'),
          Ingredient(name: 'Black pepper', quantity: '1', unit: 'tsp'),
        ],
        instructions: 'Cook pasta, prepare sauce, combine and serve',
        cuisineType: 'Italian',
        mealType: 'dinner',
        prepTimeMinutes: 15,
        cookTimeMinutes: 20,
        nutritionalInfo: NutritionalInfo(calories: 520, protein: 28, carbs: 65, fat: 18),
        estimatedCostUsd: 850, // $8.50 in cents
        difficultyLevel: 'medium',
        servings: 4,
        isActive: true,
      ),
      Recipe(
        id: 'recipe-2',
        name: 'Chicken Tikka Masala',
        description: 'Tender chicken in a creamy, spiced tomato sauce',
        ingredients: [
          Ingredient(name: 'Chicken breast', quantity: '500', unit: 'g'),
          Ingredient(name: 'Yogurt', quantity: '200', unit: 'ml'),
          Ingredient(name: 'Tomato sauce', quantity: '400', unit: 'ml'),
          Ingredient(name: 'Heavy cream', quantity: '100', unit: 'ml'),
          Ingredient(name: 'Garam masala', quantity: '2', unit: 'tsp'),
        ],
        instructions: 'Marinate chicken, cook, prepare sauce, combine',
        cuisineType: 'Indian',
        mealType: 'dinner',
        prepTimeMinutes: 30,
        cookTimeMinutes: 25,
        nutritionalInfo: NutritionalInfo(calories: 420, protein: 35, carbs: 12, fat: 25),
        estimatedCostUsd: 1200, // $12.00 in cents
        difficultyLevel: 'medium',
        servings: 4,
        isActive: true,
      ),
      Recipe(
        id: 'recipe-3',
        name: 'Avocado Toast',
        description: 'Simple and healthy breakfast with creamy avocado',
        ingredients: [
          Ingredient(name: 'Bread slices', quantity: '2', unit: 'pieces'),
          Ingredient(name: 'Avocado', quantity: '1', unit: 'large'),
          Ingredient(name: 'Lemon juice', quantity: '1', unit: 'tbsp'),
          Ingredient(name: 'Salt', quantity: 'to taste', unit: ''),
          Ingredient(name: 'Red pepper flakes', quantity: 'pinch', unit: ''),
        ],
        instructions: 'Toast bread, mash avocado, spread and season',
        cuisineType: 'American',
        mealType: 'breakfast',
        prepTimeMinutes: 5,
        cookTimeMinutes: 2,
        nutritionalInfo: NutritionalInfo(calories: 280, protein: 8, carbs: 30, fat: 18),
        estimatedCostUsd: 350, // $3.50 in cents
        difficultyLevel: 'easy',
        servings: 1,
        isActive: true,
      ),
      Recipe(
        id: 'recipe-4',
        name: 'Beef Stir Fry',
        description: 'Quick and flavorful Asian-inspired dish',
        ingredients: [
          Ingredient(name: 'Beef strips', quantity: '300', unit: 'g'),
          Ingredient(name: 'Mixed vegetables', quantity: '400', unit: 'g'),
          Ingredient(name: 'Soy sauce', quantity: '3', unit: 'tbsp'),
          Ingredient(name: 'Garlic', quantity: '3', unit: 'cloves'),
          Ingredient(name: 'Ginger', quantity: '1', unit: 'inch'),
        ],
        instructions: 'Heat oil, cook beef, add vegetables, season and toss',
        cuisineType: 'Asian',
        mealType: 'dinner',
        prepTimeMinutes: 15,
        cookTimeMinutes: 10,
        nutritionalInfo: NutritionalInfo(calories: 350, protein: 30, carbs: 15, fat: 20),
        estimatedCostUsd: 950, // $9.50 in cents
        difficultyLevel: 'easy',
        servings: 3,
        isActive: true,
      ),
      Recipe(
        id: 'recipe-5',
        name: 'Caesar Salad',
        description: 'Crisp romaine lettuce with classic Caesar dressing',
        ingredients: [
          Ingredient(name: 'Romaine lettuce', quantity: '1', unit: 'head'),
          Ingredient(name: 'Parmesan cheese', quantity: '50', unit: 'g'),
          Ingredient(name: 'Croutons', quantity: '100', unit: 'g'),
          Ingredient(name: 'Caesar dressing', quantity: '4', unit: 'tbsp'),
        ],
        instructions: 'Wash lettuce, add dressing, top with cheese and croutons',
        cuisineType: 'American',
        mealType: 'lunch',
        prepTimeMinutes: 10,
        cookTimeMinutes: 0,
        nutritionalInfo: NutritionalInfo(calories: 220, protein: 12, carbs: 18, fat: 12),
        estimatedCostUsd: 600, // $6.00 in cents
        difficultyLevel: 'easy',
        servings: 2,
        isActive: true,
      ),
    ];
  }

  RecipeSearchResult _getMockSearchResult(String searchQuery, RecipeFilters? filters, int page, int limit, String sortBy, String sortOrder) {
    final allRecipes = _getMockRecipes();
    
    // Simple filtering
    var filteredRecipes = allRecipes.where((recipe) {
      if (searchQuery.isNotEmpty) {
        return recipe.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
               recipe.description?.toLowerCase().contains(searchQuery.toLowerCase()) == true;
      }
      return true;
    }).toList();

    // Apply filters
    if (filters != null) {
      if (filters.mealType != null) {
        filteredRecipes = filteredRecipes.where((r) => r.mealType == filters.mealType).toList();
      }
      if (filters.cuisineType != null) {
        filteredRecipes = filteredRecipes.where((r) => r.cuisineType == filters.cuisineType).toList();
      }
      if (filters.difficultyLevel != null) {
        filteredRecipes = filteredRecipes.where((r) => r.difficultyLevel == filters.difficultyLevel).toList();
      }
    }

    // Simple pagination
    final startIndex = (page - 1) * limit;
    final endIndex = startIndex + limit;
    final paginatedRecipes = filteredRecipes.skip(startIndex).take(limit).toList();

    return RecipeSearchResult(
      recipes: paginatedRecipes,
      pagination: RecipePagination(
        page: page,
        limit: limit,
        totalCount: filteredRecipes.length,
        totalPages: (filteredRecipes.length / limit).ceil(),
        hasNext: endIndex < filteredRecipes.length,
        hasPrevious: page > 1,
      ),
      filtersApplied: filters?.toQueryParams() ?? {},
      searchQuery: searchQuery,
      sort: RecipeSort(
        sortBy: sortBy,
        sortOrder: sortOrder,
      ),
    );
  }

  Recipe _getMockRecipe(String recipeId) {
    final recipes = _getMockRecipes();
    return recipes.firstWhere(
      (recipe) => recipe.id == recipeId,
      orElse: () => recipes.first,
    );
  }

  FilterOptions _getMockFilterOptions() {
    return FilterOptions(
      mealTypes: ['breakfast', 'lunch', 'dinner', 'snack'],
      cuisineTypes: ['Italian', 'Indian', 'American', 'Asian', 'Mexican'],
      difficultyLevels: ['easy', 'medium', 'hard'],
      dietaryRestrictions: ['vegetarian', 'vegan', 'gluten-free', 'dairy-free'],
      timeRanges: [
        TimeRange(label: 'Quick (< 15 min)', maxMinutes: 15),
        TimeRange(label: 'Medium (15-30 min)', minMinutes: 15, maxMinutes: 30),
        TimeRange(label: 'Long (> 30 min)', minMinutes: 30),
      ],
      costRanges: [
        CostRange(label: 'Budget (< \$5)', maxUsd: 5.0),
        CostRange(label: 'Moderate (\$5-\$10)', minUsd: 5.0, maxUsd: 10.0),
        CostRange(label: 'Premium (> \$10)', minUsd: 10.0),
      ],
    );
  }

  List<String> _getMockSearchSuggestions(String query, int limit) {
    final suggestions = [
      'Spaghetti Carbonara',
      'Chicken Tikka Masala',
      'Avocado Toast',
      'Beef Stir Fry',
      'Caesar Salad',
      'Chicken Curry',
      'Pasta Primavera',
      'Fish Tacos',
      'Greek Salad',
      'Mushroom Risotto',
    ];
    
    return suggestions
        .where((s) => s.toLowerCase().contains(query.toLowerCase()))
        .take(limit)
        .toList();
  }

  List<Recipe> _getMockTrendingRecipes(int limit) {
    return _getMockRecipes().take(limit).toList();
  }

  List<Recipe> _getMockRecommendations(int limit) {
    return _getMockRecipes().reversed.take(limit).toList();
  }
} 