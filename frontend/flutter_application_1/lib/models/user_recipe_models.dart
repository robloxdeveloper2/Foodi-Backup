import 'package:flutter/material.dart';
import 'recipe_detail_models.dart';
import 'recipe_models.dart';

/// Models for Personal Recipe Collection functionality
/// Follows established patterns from recipe_models.dart and recipe_detail_models.dart

class UserRecipe {
  final String id;
  final String userId;
  final String? originalRecipeId; // Null for custom recipes
  final String name;
  final String? description;
  final List<Ingredient> ingredients;
  final String instructions;
  final String? cuisineType;
  final String? mealType;
  final int? prepTimeMinutes;
  final int? cookTimeMinutes;
  final String? difficultyLevel;
  final int servings;
  final NutritionalInfo? nutritionalInfo;
  final String? imageUrl;
  final bool isCustom;
  final bool isPublic;
  final List<UserRecipeCategory> categories;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserRecipe({
    required this.id,
    required this.userId,
    this.originalRecipeId,
    required this.name,
    this.description,
    required this.ingredients,
    required this.instructions,
    this.cuisineType,
    this.mealType,
    this.prepTimeMinutes,
    this.cookTimeMinutes,
    this.difficultyLevel,
    this.servings = 4,
    this.nutritionalInfo,
    this.imageUrl,
    this.isCustom = false,
    this.isPublic = false,
    this.categories = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserRecipe.fromJson(Map<String, dynamic> json) {
    return UserRecipe(
      id: json['id']?.toString() ?? '', // Convert int to string
      userId: json['user_id']?.toString() ?? '', // Convert UUID to string
      originalRecipeId: json['recipe_id']?.toString(), // Backend uses 'recipe_id', convert int to string
      name: json['title'] as String? ?? json['name'] as String? ?? '', // Backend uses 'title'
      description: json['description'] as String?,
      ingredients: (json['ingredients'] as List<dynamic>?)
              ?.map((e) => Ingredient.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      instructions: json['instructions'] as String? ?? '',
      cuisineType: json['cuisine_type'] as String?,
      mealType: json['meal_type'] as String?,
      prepTimeMinutes: json['prep_time_minutes'] as int?,
      cookTimeMinutes: json['cook_time_minutes'] as int?,
      difficultyLevel: json['difficulty_level'] as String?,
      servings: json['servings'] as int? ?? 4,
      nutritionalInfo: json['nutritional_info'] != null
          ? NutritionalInfo.fromJson(json['nutritional_info'] as Map<String, dynamic>)
          : null,
      imageUrl: json['image_url'] as String?,
      isCustom: json['is_custom'] as bool? ?? false,
      isPublic: json['is_public'] as bool? ?? false,
      categories: (json['categories'] as List<dynamic>?)
              ?.map((e) => UserRecipeCategory.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'original_recipe_id': originalRecipeId,
      'name': name,
      'description': description,
      'ingredients': ingredients.map((e) => e.toJson()).toList(),
      'instructions': instructions,
      'cuisine_type': cuisineType,
      'meal_type': mealType,
      'prep_time_minutes': prepTimeMinutes,
      'cook_time_minutes': cookTimeMinutes,
      'difficulty_level': difficultyLevel,
      'servings': servings,
      'nutritional_info': nutritionalInfo?.toJson(),
      'image_url': imageUrl,
      'is_custom': isCustom,
      'is_public': isPublic,
      'categories': categories.map((e) => e.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create UserRecipe from a regular Recipe (when favoriting from catalog)
  factory UserRecipe.fromRecipe(Recipe recipe, String userId) {
    return UserRecipe(
      id: '', // Will be assigned by backend
      userId: userId,
      originalRecipeId: recipe.id,
      name: recipe.name,
      description: recipe.description,
      ingredients: recipe.ingredients,
      instructions: recipe.instructions,
      cuisineType: recipe.cuisineType,
      mealType: recipe.mealType,
      prepTimeMinutes: recipe.prepTimeMinutes,
      cookTimeMinutes: recipe.cookTimeMinutes,
      difficultyLevel: recipe.difficultyLevel,
      servings: recipe.servings,
      nutritionalInfo: recipe.nutritionalInfo,
      imageUrl: recipe.imageUrl,
      isCustom: false,
      isPublic: false,
      categories: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Convert to regular Recipe for compatibility
  Recipe toRecipe() {
    return Recipe(
      id: originalRecipeId ?? id,
      name: name,
      description: description,
      ingredients: ingredients,
      instructions: instructions,
      cuisineType: cuisineType,
      mealType: mealType,
      prepTimeMinutes: prepTimeMinutes,
      cookTimeMinutes: cookTimeMinutes,
      difficultyLevel: difficultyLevel,
      servings: servings,
      nutritionalInfo: nutritionalInfo,
      imageUrl: imageUrl,
      estimatedCostUsd: null, // Not stored in user recipes
      costPerServingUsd: null, // Not stored in user recipes
      sourceUrl: null, // Not applicable for user recipes
      isActive: true,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Get total cooking time
  int? get totalTimeMinutes {
    if (prepTimeMinutes != null && cookTimeMinutes != null) {
      return prepTimeMinutes! + cookTimeMinutes!;
    }
    return null;
  }

  /// Check if this is a favorited recipe from catalog
  bool get isFavorited => originalRecipeId != null;

  UserRecipe copyWith({
    String? id,
    String? userId,
    String? originalRecipeId,
    String? name,
    String? description,
    List<Ingredient>? ingredients,
    String? instructions,
    String? cuisineType,
    String? mealType,
    int? prepTimeMinutes,
    int? cookTimeMinutes,
    String? difficultyLevel,
    int? servings,
    NutritionalInfo? nutritionalInfo,
    String? imageUrl,
    bool? isCustom,
    bool? isPublic,
    List<UserRecipeCategory>? categories,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserRecipe(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      originalRecipeId: originalRecipeId ?? this.originalRecipeId,
      name: name ?? this.name,
      description: description ?? this.description,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
      cuisineType: cuisineType ?? this.cuisineType,
      mealType: mealType ?? this.mealType,
      prepTimeMinutes: prepTimeMinutes ?? this.prepTimeMinutes,
      cookTimeMinutes: cookTimeMinutes ?? this.cookTimeMinutes,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      servings: servings ?? this.servings,
      nutritionalInfo: nutritionalInfo ?? this.nutritionalInfo,
      imageUrl: imageUrl ?? this.imageUrl,
      isCustom: isCustom ?? this.isCustom,
      isPublic: isPublic ?? this.isPublic,
      categories: categories ?? this.categories,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserRecipe && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'UserRecipe(id: $id, name: $name, isCustom: $isCustom)';
}

class UserRecipeCategory {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final Color? color;
  final DateTime createdAt;

  const UserRecipeCategory({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    this.color,
    required this.createdAt,
  });

  factory UserRecipeCategory.fromJson(Map<String, dynamic> json) {
    return UserRecipeCategory(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      color: json['color'] != null ? Color(int.parse(json['color'].substring(1), radix: 16) + 0xFF000000) : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'description': description,
      'color': color != null ? '#${color!.value.toRadixString(16).substring(2)}' : null,
      'created_at': createdAt.toIso8601String(),
    };
  }

  UserRecipeCategory copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    Color? color,
    DateTime? createdAt,
  }) {
    return UserRecipeCategory(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserRecipeCategory && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'UserRecipeCategory(id: $id, name: $name)';
}

class UserRecipeCollection {
  final List<UserRecipe> recipes;
  final List<UserRecipeCategory> categories;
  final int totalCount;
  final RecipePagination pagination;

  const UserRecipeCollection({
    required this.recipes,
    required this.categories,
    required this.totalCount,
    required this.pagination,
  });

  factory UserRecipeCollection.fromJson(Map<String, dynamic> json) {
    return UserRecipeCollection(
      recipes: (json['recipes'] as List<dynamic>?)
              ?.map((e) => UserRecipe.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      categories: (json['categories'] as List<dynamic>?)
              ?.map((e) => UserRecipeCategory.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      totalCount: json['total_count'] as int? ?? 0,
      pagination: RecipePagination.fromJson(json['pagination'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recipes': recipes.map((e) => e.toJson()).toList(),
      'categories': categories.map((e) => e.toJson()).toList(),
      'total_count': totalCount,
      'pagination': {
        'page': pagination.page,
        'limit': pagination.limit,
        'total_count': pagination.totalCount,
        'total_pages': pagination.totalPages,
        'has_next': pagination.hasNext,
        'has_previous': pagination.hasPrevious,
      },
    };
  }

  UserRecipeCollection copyWith({
    List<UserRecipe>? recipes,
    List<UserRecipeCategory>? categories,
    int? totalCount,
    RecipePagination? pagination,
  }) {
    return UserRecipeCollection(
      recipes: recipes ?? this.recipes,
      categories: categories ?? this.categories,
      totalCount: totalCount ?? this.totalCount,
      pagination: pagination ?? this.pagination,
    );
  }

  /// Get recipes by category
  List<UserRecipe> getRecipesByCategory(String categoryId) {
    return recipes.where((recipe) => recipe.categories.any((cat) => cat.id == categoryId)).toList();
  }

  /// Get custom recipes only
  List<UserRecipe> get customRecipes => recipes.where((recipe) => recipe.isCustom).toList();

  /// Get favorited recipes only
  List<UserRecipe> get favoritedRecipes => recipes.where((recipe) => !recipe.isCustom).toList();

  @override
  String toString() => 'UserRecipeCollection(recipes: ${recipes.length}, categories: ${categories.length})';
}

class RecipeCollectionFilters {
  final String? categoryId;
  final String? mealType;
  final String? cuisineType;
  final bool? isCustomOnly;
  final String? searchQuery;
  final String sortBy;
  final String sortOrder;

  const RecipeCollectionFilters({
    this.categoryId,
    this.mealType,
    this.cuisineType,
    this.isCustomOnly,
    this.searchQuery,
    this.sortBy = 'name',
    this.sortOrder = 'asc',
  });

  factory RecipeCollectionFilters.fromJson(Map<String, dynamic> json) {
    return RecipeCollectionFilters(
      categoryId: json['category_id'] as String?,
      mealType: json['meal_type'] as String?,
      cuisineType: json['cuisine_type'] as String?,
      isCustomOnly: json['is_custom_only'] as bool?,
      searchQuery: json['search_query'] as String?,
      sortBy: json['sort_by'] as String? ?? 'name',
      sortOrder: json['sort_order'] as String? ?? 'asc',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category_id': categoryId,
      'meal_type': mealType,
      'cuisine_type': cuisineType,
      'is_custom_only': isCustomOnly,
      'search_query': searchQuery,
      'sort_by': sortBy,
      'sort_order': sortOrder,
    };
  }

  /// Convert to query parameters for API calls
  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};
    
    if (categoryId != null) params['category_id'] = categoryId;
    if (mealType != null) params['meal_type'] = mealType;
    if (cuisineType != null) params['cuisine_type'] = cuisineType;
    if (isCustomOnly != null) params['is_custom_only'] = isCustomOnly;
    if (searchQuery != null && searchQuery!.isNotEmpty) params['q'] = searchQuery;
    params['sort_by'] = sortBy;
    params['sort_order'] = sortOrder;
    
    return params;
  }

  RecipeCollectionFilters copyWith({
    String? categoryId,
    String? mealType,
    String? cuisineType,
    bool? isCustomOnly,
    String? searchQuery,
    String? sortBy,
    String? sortOrder,
  }) {
    return RecipeCollectionFilters(
      categoryId: categoryId ?? this.categoryId,
      mealType: mealType ?? this.mealType,
      cuisineType: cuisineType ?? this.cuisineType,
      isCustomOnly: isCustomOnly ?? this.isCustomOnly,
      searchQuery: searchQuery ?? this.searchQuery,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  /// Check if any filters are active
  bool get hasActiveFilters {
    return categoryId != null ||
        mealType != null ||
        cuisineType != null ||
        isCustomOnly != null ||
        (searchQuery != null && searchQuery!.isNotEmpty);
  }

  /// Clear all filters
  RecipeCollectionFilters clear() {
    return const RecipeCollectionFilters();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecipeCollectionFilters &&
          runtimeType == other.runtimeType &&
          categoryId == other.categoryId &&
          mealType == other.mealType &&
          cuisineType == other.cuisineType &&
          isCustomOnly == other.isCustomOnly &&
          searchQuery == other.searchQuery &&
          sortBy == other.sortBy &&
          sortOrder == other.sortOrder;

  @override
  int get hashCode => Object.hash(
        categoryId,
        mealType,
        cuisineType,
        isCustomOnly,
        searchQuery,
        sortBy,
        sortOrder,
      );

  @override
  String toString() => 'RecipeCollectionFilters(categoryId: $categoryId, searchQuery: $searchQuery)';
}

/// Request model for creating custom recipes
class CreateRecipeRequest {
  final String name;
  final String? description;
  final List<Ingredient> ingredients;
  final String instructions;
  final String? cuisineType;
  final String? mealType;
  final int? prepTimeMinutes;
  final int? cookTimeMinutes;
  final String? difficultyLevel;
  final int servings;
  final NutritionalInfo? nutritionalInfo;
  final String? imageUrl;
  final bool isPublic;
  final List<String> categoryIds;

  const CreateRecipeRequest({
    required this.name,
    this.description,
    required this.ingredients,
    required this.instructions,
    this.cuisineType,
    this.mealType,
    this.prepTimeMinutes,
    this.cookTimeMinutes,
    this.difficultyLevel,
    this.servings = 4,
    this.nutritionalInfo,
    this.imageUrl,
    this.isPublic = false,
    this.categoryIds = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'ingredients': ingredients.map((e) => e.toJson()).toList(),
      'instructions': instructions,
      'cuisine_type': cuisineType,
      'meal_type': mealType,
      'prep_time_minutes': prepTimeMinutes,
      'cook_time_minutes': cookTimeMinutes,
      'difficulty_level': difficultyLevel,
      'servings': servings,
      'nutritional_info': nutritionalInfo?.toJson(),
      'image_url': imageUrl,
      'is_public': isPublic,
      'category_ids': categoryIds,
    };
  }
}

/// Request model for updating custom recipes
class UpdateRecipeRequest extends CreateRecipeRequest {
  const UpdateRecipeRequest({
    required super.name,
    super.description,
    required super.ingredients,
    required super.instructions,
    super.cuisineType,
    super.mealType,
    super.prepTimeMinutes,
    super.cookTimeMinutes,
    super.difficultyLevel,
    super.servings = 4,
    super.nutritionalInfo,
    super.imageUrl,
    super.isPublic = false,
    super.categoryIds = const [],
  });
}

/// Model for recipe export formats
enum RecipeExportFormat {
  json,
  text,
  pdf,
}

extension RecipeExportFormatExtension on RecipeExportFormat {
  String get value {
    switch (this) {
      case RecipeExportFormat.json:
        return 'json';
      case RecipeExportFormat.text:
        return 'text';
      case RecipeExportFormat.pdf:
        return 'pdf';
    }
  }

  String get displayName {
    switch (this) {
      case RecipeExportFormat.json:
        return 'JSON';
      case RecipeExportFormat.text:
        return 'Text';
      case RecipeExportFormat.pdf:
        return 'PDF';
    }
  }

  String get description {
    switch (this) {
      case RecipeExportFormat.json:
        return 'Machine-readable format for importing to other apps';
      case RecipeExportFormat.text:
        return 'Simple text format for sharing or printing';
      case RecipeExportFormat.pdf:
        return 'Formatted document for printing or sharing';
    }
  }
} 