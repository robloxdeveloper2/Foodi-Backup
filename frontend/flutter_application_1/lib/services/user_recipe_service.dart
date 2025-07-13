import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/user_recipe_models.dart';
import '../models/recipe_models.dart';
import '../utils/app_constants.dart';
import 'recipe_discovery_service.dart';

class UserRecipeService {
  late final Dio _dio;
  static const bool _useMockData = false; // Use real backend API
  
  // Static mock data to prevent duplicates (only used as fallback)
  static List<UserRecipe>? _staticMockRecipes;
  static List<UserRecipeCategory>? _staticMockCategories;
  static Set<String> _mockFavorites = {};
  
  // Recipe discovery service for looking up catalog recipes
  late final RecipeDiscoveryService _recipeDiscoveryService;

  UserRecipeService() {
    _recipeDiscoveryService = RecipeDiscoveryService();
    
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
        debugPrint('User Recipe API Error: ${error.message}');
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

  /// Get user's recipe collection with filtering and pagination
  Future<UserRecipeCollection> getUserRecipes({
    RecipeCollectionFilters? filters,
    int page = 1,
    int pageSize = 20,
    String sortBy = 'created_at',
    String sortOrder = 'desc',
  }) async {
    if (_useMockData) {
      return _getMockUserRecipeCollection(filters, page, pageSize, sortBy, sortOrder);
    }

    try {
      Map<String, dynamic> queryParams = {
        'page': page.toString(),
        'page_size': pageSize.toString(),
        'sort_by': sortBy,
        'sort_order': sortOrder,
      };

      if (filters != null) {
        queryParams.addAll(filters.toQueryParams());
      }

      final response = await _dio.get(
        '/api/v1/user-recipes',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return UserRecipeCollection.fromJson(response.data);
      } else {
        throw Exception('Failed to get user recipes: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('User recipes error: ${e.message}');
      return _getMockUserRecipeCollection(filters, page, pageSize, sortBy, sortOrder);
    } catch (e) {
      debugPrint('Unexpected error getting user recipes: $e');
      return _getMockUserRecipeCollection(filters, page, pageSize, sortBy, sortOrder);
    }
  }

  /// Get a specific user recipe by ID
  Future<UserRecipe> getUserRecipe(String userRecipeId) async {
    if (_useMockData) {
      return _getMockUserRecipe(userRecipeId);
    }

    try {
      final response = await _dio.get('/api/v1/user-recipes/$userRecipeId');

      if (response.statusCode == 200) {
        return UserRecipe.fromJson(response.data);
      } else {
        throw Exception('Failed to get user recipe: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('User recipe details error: ${e.message}');
      return _getMockUserRecipe(userRecipeId);
    } catch (e) {
      debugPrint('Unexpected error getting user recipe: $e');
      return _getMockUserRecipe(userRecipeId);
    }
  }

  /// Check if a recipe is favorited by the user
  Future<bool> checkRecipeFavorited(String recipeId) async {
    if (_useMockData) {
      return _mockFavorites.contains(recipeId);
    }

    try {
      final response = await _dio.get('/api/v1/user-recipes/favorite-status/$recipeId');

      if (response.statusCode == 200) {
        // Backend returns wrapped response: {success: true, data: {recipe_id: "1", favorited: true}, message: "..."}
        return response.data['data']['favorited'] ?? false;
      } else {
        return false;
      }
    } on DioException catch (e) {
      debugPrint('Check favorite status error: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('Unexpected error checking favorite status: $e');
      return false;
    }
  }

  /// Static method to get mock recipes directly (similar to RecipeDiscoveryService)
  static List<Recipe> _getAvailableRecipes() {
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
        estimatedCostUsd: 850,
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
        estimatedCostUsd: 1200,
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
        estimatedCostUsd: 350,
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
        estimatedCostUsd: 950,
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
        estimatedCostUsd: 600,
        difficultyLevel: 'easy',
        servings: 2,
        isActive: true,
      ),
    ];
  }

  UserRecipe _getMockFavoriteRecipe(String recipeId) {
    // Look up the recipe directly from our static data
    final availableRecipes = _getAvailableRecipes();
    final catalogRecipe = availableRecipes.firstWhere(
      (recipe) => recipe.id == recipeId,
      orElse: () => Recipe(
        id: recipeId,
        name: 'Unknown Recipe',
        description: 'Recipe not found in catalog',
        ingredients: [],
        instructions: 'Recipe details not available',
        servings: 4,
        isActive: true,
      ),
    );

    // Convert Recipe to UserRecipe
    return UserRecipe(
      id: 'user_recipe_$recipeId',
      userId: 'user1',
      originalRecipeId: recipeId,
      name: catalogRecipe.name,
      description: catalogRecipe.description,
      ingredients: catalogRecipe.ingredients,
      instructions: catalogRecipe.instructions,
      servings: catalogRecipe.servings,
      prepTimeMinutes: catalogRecipe.prepTimeMinutes,
      cookTimeMinutes: catalogRecipe.cookTimeMinutes,
      difficultyLevel: catalogRecipe.difficultyLevel,
      cuisineType: catalogRecipe.cuisineType,
      mealType: catalogRecipe.mealType,
      nutritionalInfo: catalogRecipe.nutritionalInfo,
      imageUrl: catalogRecipe.imageUrl,
      isCustom: false,
      categories: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Add a catalog recipe to user's favorites
  Future<UserRecipe> favoriteRecipe(String recipeId) async {
    if (_useMockData) {
      _mockFavorites.add(recipeId);
      // Now this will work reliably with the direct lookup
      return _getMockFavoriteRecipe(recipeId);
    }

    try {
      final response = await _dio.post('/api/v1/user-recipes/favorite/$recipeId');

      if (response.statusCode == 201) {
        // Backend returns wrapped response: {success: true, data: userRecipe, message: "..."}
        return UserRecipe.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to favorite recipe: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('Favorite recipe error: ${e.message}');
      throw Exception('Failed to favorite recipe: ${e.response?.data['message'] ?? e.message}');
    } catch (e) {
      debugPrint('Unexpected error favoriting recipe: $e');
      throw Exception('Failed to favorite recipe');
    }
  }

  /// Remove a favorited recipe from user's collection
  Future<bool> unfavoriteRecipe(String recipeId) async {
    if (_useMockData) {
      _mockFavorites.remove(recipeId);
      return true;
    }

    try {
      final response = await _dio.delete('/api/v1/user-recipes/favorite/$recipeId');

      return response.statusCode == 200;
    } on DioException catch (e) {
      debugPrint('Unfavorite recipe error: ${e.message}');
      throw Exception('Failed to unfavorite recipe: ${e.response?.data['message'] ?? e.message}');
    } catch (e) {
      debugPrint('Unexpected error unfavoriting recipe: $e');
      throw Exception('Failed to unfavorite recipe');
    }
  }

  /// Create a new custom recipe
  Future<UserRecipe> createCustomRecipe(CreateRecipeRequest request) async {
    if (_useMockData) {
      return _getMockCreateCustomRecipe(request);
    }

    try {
      final response = await _dio.post(
        '/api/v1/user-recipes/custom',
        data: request.toJson(),
      );

      if (response.statusCode == 201) {
        // Backend returns wrapped response: {success: true, data: userRecipe, message: "..."}
        return UserRecipe.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to create custom recipe: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('Create custom recipe error: ${e.message}');
      throw Exception('Failed to create recipe: ${e.response?.data['message'] ?? e.message}');
    } catch (e) {
      debugPrint('Unexpected error creating custom recipe: $e');
      throw Exception('Failed to create recipe');
    }
  }

  /// Update an existing custom recipe
  Future<UserRecipe> updateCustomRecipe(String userRecipeId, UpdateRecipeRequest request) async {
    if (_useMockData) {
      return _getMockUpdateCustomRecipe(userRecipeId, request);
    }

    try {
      final response = await _dio.put(
        '/api/v1/user-recipes/$userRecipeId',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        // Backend returns wrapped response: {success: true, data: userRecipe, message: "..."}
        return UserRecipe.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to update custom recipe: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('Update custom recipe error: ${e.message}');
      throw Exception('Failed to update recipe: ${e.response?.data['message'] ?? e.message}');
    } catch (e) {
      debugPrint('Unexpected error updating custom recipe: $e');
      throw Exception('Failed to update recipe');
    }
  }

  /// Delete a user recipe (custom or favorited)
  Future<bool> deleteUserRecipe(String userRecipeId) async {
    if (_useMockData) {
      return true;
    }

    try {
      final response = await _dio.delete('/api/v1/user-recipes/$userRecipeId');

      return response.statusCode == 200;
    } on DioException catch (e) {
      debugPrint('Delete user recipe error: ${e.message}');
      throw Exception('Failed to delete recipe: ${e.response?.data['message'] ?? e.message}');
    } catch (e) {
      debugPrint('Unexpected error deleting user recipe: $e');
      throw Exception('Failed to delete recipe');
    }
  }

  /// Scale a recipe's ingredients and servings
  Future<Map<String, dynamic>> scaleRecipe(String userRecipeId, double scaleFactor) async {
    if (_useMockData) {
      return _getMockScaleRecipe(userRecipeId, scaleFactor);
    }

    try {
      final response = await _dio.post(
        '/api/v1/user-recipes/$userRecipeId/scale',
        data: {'scale_factor': scaleFactor},
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to scale recipe: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('Scale recipe error: ${e.message}');
      throw Exception('Failed to scale recipe: ${e.response?.data['message'] ?? e.message}');
    } catch (e) {
      debugPrint('Unexpected error scaling recipe: $e');
      throw Exception('Failed to scale recipe');
    }
  }

  /// Get all categories for the user
  Future<List<UserRecipeCategory>> getCategories() async {
    if (_useMockData) {
      return _getMockCategories();
    }

    try {
      final response = await _dio.get('/api/v1/user-recipes/categories');

      if (response.statusCode == 200) {
        // Backend returns wrapped response: {success: true, data: categories, message: "..."}
        final List<dynamic> categoriesJson = response.data['data'];
        return categoriesJson.map((json) => UserRecipeCategory.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get categories: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('Get categories error: ${e.message}');
      return _getMockCategories();
    } catch (e) {
      debugPrint('Unexpected error getting categories: $e');
      return _getMockCategories();
    }
  }

  /// Create a new category
  Future<UserRecipeCategory> createCategory(String name, String? description, String? color) async {
    if (_useMockData) {
      return _getMockCreateCategory(name, description, color);
    }

    try {
      final response = await _dio.post(
        '/api/v1/user-recipes/categories',
        data: {
          'name': name,
          if (description != null) 'description': description,
          if (color != null) 'color': color,
        },
      );

      if (response.statusCode == 201) {
        // Backend returns wrapped response: {success: true, data: category, message: "..."}
        return UserRecipeCategory.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to create category: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('Create category error: ${e.message}');
      throw Exception('Failed to create category: ${e.response?.data['message'] ?? e.message}');
    } catch (e) {
      debugPrint('Unexpected error creating category: $e');
      throw Exception('Failed to create category');
    }
  }

  /// Update an existing category
  Future<UserRecipeCategory> updateCategory(String categoryId, String? name, String? description, String? color) async {
    if (_useMockData) {
      return _getMockUpdateCategory(categoryId, name, description, color);
    }

    try {
      final Map<String, dynamic> data = {};
      if (name != null) data['name'] = name;
      if (description != null) data['description'] = description;
      if (color != null) data['color'] = color;

      final response = await _dio.put(
        '/api/v1/user-recipes/categories/$categoryId',
        data: data,
      );

      if (response.statusCode == 200) {
        return UserRecipeCategory.fromJson(response.data);
      } else {
        throw Exception('Failed to update category: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('Update category error: ${e.message}');
      throw Exception('Failed to update category: ${e.response?.data['message'] ?? e.message}');
    } catch (e) {
      debugPrint('Unexpected error updating category: $e');
      throw Exception('Failed to update category');
    }
  }

  /// Delete a category
  Future<bool> deleteCategory(String categoryId) async {
    if (_useMockData) {
      return true;
    }

    try {
      final response = await _dio.delete('/api/v1/user-recipes/categories/$categoryId');

      return response.statusCode == 200;
    } on DioException catch (e) {
      debugPrint('Delete category error: ${e.message}');
      throw Exception('Failed to delete category: ${e.response?.data['message'] ?? e.message}');
    } catch (e) {
      debugPrint('Unexpected error deleting category: $e');
      throw Exception('Failed to delete category');
    }
  }

  /// Assign categories to a recipe
  Future<bool> assignCategoriesToRecipe(String userRecipeId, List<String> categoryIds) async {
    if (_useMockData) {
      return true;
    }

    try {
      final response = await _dio.post(
        '/api/v1/user-recipes/$userRecipeId/categories',
        data: {'category_ids': categoryIds},
      );

      return response.statusCode == 200;
    } on DioException catch (e) {
      debugPrint('Assign categories error: ${e.message}');
      throw Exception('Failed to assign categories: ${e.response?.data['message'] ?? e.message}');
    } catch (e) {
      debugPrint('Unexpected error assigning categories: $e');
      throw Exception('Failed to assign categories');
    }
  }

  /// Get recipes in a specific category
  Future<UserRecipeCollection> getRecipesByCategory(String categoryId, {int page = 1, int pageSize = 20}) async {
    if (_useMockData) {
      return _getMockRecipesByCategory(categoryId, page, pageSize);
    }

    try {
      final response = await _dio.get(
        '/api/v1/user-recipes/categories/$categoryId/recipes',
        queryParameters: {
          'page': page.toString(),
          'page_size': pageSize.toString(),
        },
      );

      if (response.statusCode == 200) {
        return UserRecipeCollection.fromJson(response.data);
      } else {
        throw Exception('Failed to get category recipes: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('Get category recipes error: ${e.message}');
      return _getMockRecipesByCategory(categoryId, page, pageSize);
    } catch (e) {
      debugPrint('Unexpected error getting category recipes: $e');
      return _getMockRecipesByCategory(categoryId, page, pageSize);
    }
  }

  /// Create default categories for a new user
  Future<List<UserRecipeCategory>> createDefaultCategories() async {
    if (_useMockData) {
      return _getMockDefaultCategories();
    }

    try {
      final response = await _dio.post('/api/v1/user-recipes/categories/defaults');

      if (response.statusCode == 201) {
        final List<dynamic> categoriesJson = response.data;
        return categoriesJson.map((json) => UserRecipeCategory.fromJson(json)).toList();
      } else {
        throw Exception('Failed to create default categories: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('Create default categories error: ${e.message}');
      return _getMockDefaultCategories();
    } catch (e) {
      debugPrint('Unexpected error creating default categories: $e');
      return _getMockDefaultCategories();
    }
  }

  /// Export a recipe in specified format
  Future<String> exportRecipe(String userRecipeId, RecipeExportFormat format) async {
    if (_useMockData) {
      return _getMockExportRecipe(userRecipeId, format);
    }

    try {
      final response = await _dio.get(
        '/api/v1/user-recipes/$userRecipeId/export',
        queryParameters: {'format': format.name},
      );

      if (response.statusCode == 200) {
        return response.data['export_data'];
      } else {
        throw Exception('Failed to export recipe: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('Export recipe error: ${e.message}');
      return _getMockExportRecipe(userRecipeId, format);
    } catch (e) {
      debugPrint('Unexpected error exporting recipe: $e');
      return _getMockExportRecipe(userRecipeId, format);
    }
  }

  /// Share a recipe and get share data
  Future<Map<String, dynamic>> shareRecipe(String userRecipeId) async {
    if (_useMockData) {
      return _getMockShareRecipe(userRecipeId);
    }

    try {
      final response = await _dio.post('/api/v1/user-recipes/$userRecipeId/share');

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to share recipe: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('Share recipe error: ${e.message}');
      return _getMockShareRecipe(userRecipeId);
    } catch (e) {
      debugPrint('Unexpected error sharing recipe: $e');
      return _getMockShareRecipe(userRecipeId);
    }
  }

  /// Get user recipe statistics
  Future<Map<String, dynamic>> getUserRecipeStats() async {
    if (_useMockData) {
      return _getMockUserRecipeStats();
    }

    try {
      final response = await _dio.get('/api/v1/user-recipes/stats');

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to get user recipe stats: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('Get user recipe stats error: ${e.message}');
      return _getMockUserRecipeStats();
    } catch (e) {
      debugPrint('Unexpected error getting user recipe stats: $e');
      return _getMockUserRecipeStats();
    }
  }

  // Mock data methods (to be implemented for testing)
  
  UserRecipeCollection _getMockUserRecipeCollection(RecipeCollectionFilters? filters, int page, int pageSize, String sortBy, String sortOrder) {
    // Initialize static mock data only once with some basic recipes
    _staticMockRecipes ??= [
      // Custom recipe example
      UserRecipe(
        id: 'recipe2',
        userId: 'user1',
        name: 'Homemade Pizza',
        description: 'My custom pizza recipe',
        ingredients: [
          Ingredient(name: 'Flour', quantity: '500g'),
          Ingredient(name: 'Yeast', quantity: '7g'),
          Ingredient(name: 'Tomato sauce', quantity: '200ml'),
          Ingredient(name: 'Mozzarella', quantity: '250g'),
        ],
        instructions: '1. Make dough\n2. Add toppings\n3. Bake at 220°C',
        servings: 2,
        isCustom: true,
        categories: [],
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];

    // Create a working copy and add favorited recipes
    List<UserRecipe> mockRecipes = List.from(_staticMockRecipes!);
    
    // Add all favorited recipes to the collection
    for (String recipeId in _mockFavorites) {
      // Check if this favorited recipe is already in the list
      bool alreadyExists = mockRecipes.any((recipe) => recipe.originalRecipeId == recipeId);
      if (!alreadyExists) {
        // Create the favorited recipe and add it
        final favoritedRecipe = _getMockFavoriteRecipe(recipeId);
        mockRecipes.add(favoritedRecipe);
      }
    }

    // Apply basic filtering
    if (filters?.searchQuery != null && filters!.searchQuery!.isNotEmpty) {
      mockRecipes = mockRecipes.where((recipe) => 
        recipe.name.toLowerCase().contains(filters.searchQuery!.toLowerCase())
      ).toList();
    }

    if (filters?.isCustomOnly != null) {
      if (filters!.isCustomOnly == true) {
        mockRecipes = mockRecipes.where((recipe) => recipe.isCustom).toList();
      } else {
        mockRecipes = mockRecipes.where((recipe) => !recipe.isCustom).toList();
      }
    }

    return UserRecipeCollection(
      recipes: mockRecipes,
      categories: [],
      totalCount: mockRecipes.length,
      pagination: RecipePagination(
        page: page, 
        limit: pageSize, 
        totalCount: mockRecipes.length, 
        totalPages: (mockRecipes.length / pageSize).ceil(),
        hasNext: page < (mockRecipes.length / pageSize).ceil(),
        hasPrevious: page > 1,
      ),
    );
  }

  UserRecipe _getMockUserRecipe(String userRecipeId) {
    // Mock implementation for testing
    return UserRecipe(
      id: userRecipeId,
      userId: 'user1',
      name: 'Mock Recipe',
      description: 'A mock recipe for testing',
      ingredients: [],
      instructions: 'Mock instructions',
      servings: 4,
      isCustom: true,
      categories: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  UserRecipe _getMockCreateCustomRecipe(CreateRecipeRequest request) {
    return UserRecipe(
      id: 'new_recipe_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'user1',
      name: request.name,
      description: request.description,
      ingredients: request.ingredients ?? [],
      instructions: request.instructions ?? '',
      servings: request.servings ?? 4,
      isCustom: true,
      categories: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  UserRecipe _getMockUpdateCustomRecipe(String userRecipeId, UpdateRecipeRequest request) {
    return UserRecipe(
      id: userRecipeId,
      userId: 'user1',
      name: request.name ?? 'Updated Recipe',
      description: request.description,
      ingredients: request.ingredients ?? [],
      instructions: request.instructions ?? '',
      servings: request.servings ?? 4,
      isCustom: true,
      categories: [],
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> _getMockScaleRecipe(String userRecipeId, double scaleFactor) {
    return {
      'servings': (4 * scaleFactor).round(),
      'ingredients': [],
      'nutritional_info': {},
    };
  }

  List<UserRecipeCategory> _getMockCategories() {
    // Initialize static categories only once
    _staticMockCategories ??= [
      UserRecipeCategory(
        id: 'cat1',
        userId: 'user1',
        name: 'Favorites',
        description: 'My favorite recipes',
        color: const Color(0xFFFF6B6B),
        createdAt: DateTime.now(),
      ),
      UserRecipeCategory(
        id: 'cat2',
        userId: 'user1',
        name: 'Quick & Easy',
        description: 'Fast meals under 30 minutes',
        color: const Color(0xFF4ECDC4),
        createdAt: DateTime.now(),
      ),
      UserRecipeCategory(
        id: 'cat3',
        userId: 'user1',
        name: 'Healthy',
        description: 'Nutritious and wholesome meals',
        color: const Color(0xFF45B7D1),
        createdAt: DateTime.now(),
      ),
    ];
    
    return List.from(_staticMockCategories!);
  }

  UserRecipeCategory _getMockCreateCategory(String name, String? description, String? color) {
    Color? parsedColor;
    if (color != null) {
      // Parse hex color string to Color
      try {
        parsedColor = Color(int.parse(color.substring(1), radix: 16) + 0xFF000000);
      } catch (e) {
        parsedColor = null;
      }
    }
    
    return UserRecipeCategory(
      id: 'new_cat_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'user1',
      name: name,
      description: description,
      color: parsedColor,
      createdAt: DateTime.now(),
    );
  }

  UserRecipeCategory _getMockUpdateCategory(String categoryId, String? name, String? description, String? color) {
    Color? parsedColor;
    if (color != null) {
      try {
        parsedColor = Color(int.parse(color.substring(1), radix: 16) + 0xFF000000);
      } catch (e) {
        parsedColor = null;
      }
    }
    
    return UserRecipeCategory(
      id: categoryId,
      userId: 'user1',
      name: name ?? 'Updated Category',
      description: description,
      color: parsedColor,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    );
  }

  UserRecipeCollection _getMockRecipesByCategory(String categoryId, int page, int pageSize) {
    return UserRecipeCollection(
      recipes: [],
      categories: [],
      totalCount: 0,
      pagination: RecipePagination(
        page: page, 
        limit: pageSize, 
        totalCount: 0, 
        totalPages: 0,
        hasNext: false,
        hasPrevious: false,
      ),
    );
  }

  List<UserRecipeCategory> _getMockDefaultCategories() {
    return [
      UserRecipeCategory(
        id: 'def1', 
        userId: 'user1',
        name: 'Favorites', 
        description: 'My favorite recipes', 
        color: const Color(0xFFFF6B6B), 
        createdAt: DateTime.now(),
      ),
      UserRecipeCategory(
        id: 'def2', 
        userId: 'user1',
        name: 'Quick & Easy', 
        description: 'Fast meals under 30 minutes', 
        color: const Color(0xFF4ECDC4), 
        createdAt: DateTime.now(),
      ),
      UserRecipeCategory(
        id: 'def3', 
        userId: 'user1',
        name: 'Healthy', 
        description: 'Nutritious and wholesome meals', 
        color: const Color(0xFF45B7D1), 
        createdAt: DateTime.now(),
      ),
    ];
  }

  String _getMockExportRecipe(String userRecipeId, RecipeExportFormat format) {
    switch (format) {
      case RecipeExportFormat.json:
        return '{"name": "Mock Recipe", "ingredients": [], "instructions": "Mock instructions"}';
      case RecipeExportFormat.text:
        return 'Mock Recipe\n\nIngredients:\n- Mock ingredient\n\nInstructions:\n1. Mock instruction';
      case RecipeExportFormat.pdf:
        return 'PDF export not implemented in mock';
    }
  }

  Map<String, dynamic> _getMockShareRecipe(String userRecipeId) {
    return {
      'recipe_id': userRecipeId,
      'share_url': 'https://foodi.app/shared/recipe/$userRecipeId',
      'shared_at': DateTime.now().toIso8601String(),
    };
  }

  Map<String, dynamic> _getMockUserRecipeStats() {
    return {
      'total_recipes': 12,
      'custom_recipes': 8,
      'favorited_recipes': 4,
      'cuisine_distribution': {
        'Italian': 3,
        'Mexican': 2,
        'Asian': 4,
        'American': 3,
      },
      'meal_distribution': {
        'breakfast': 2,
        'lunch': 4,
        'dinner': 5,
        'snack': 1,
      },
    };
  }
} 