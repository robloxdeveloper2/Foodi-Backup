class Recipe {
  final String id;
  final String name;
  final String? description;
  final List<Ingredient> ingredients;
  final String instructions;
  final String? cuisineType;
  final String? mealType;
  final int? prepTimeMinutes;
  final int? cookTimeMinutes;
  final int? totalTimeMinutes;
  final NutritionalInfo? nutritionalInfo;
  final int? estimatedCostUsd;
  final double? costPerServingUsd;
  final String? difficultyLevel;
  final String? sourceUrl;
  final String? imageUrl;
  final int servings;
  final double? caloriesPerServing;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Recipe({
    required this.id,
    required this.name,
    this.description,
    required this.ingredients,
    required this.instructions,
    this.cuisineType,
    this.mealType,
    this.prepTimeMinutes,
    this.cookTimeMinutes,
    this.totalTimeMinutes,
    this.nutritionalInfo,
    this.estimatedCostUsd,
    this.costPerServingUsd,
    this.difficultyLevel,
    this.sourceUrl,
    this.imageUrl,
    required this.servings,
    this.caloriesPerServing,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      ingredients: (json['ingredients'] as List<dynamic>?)
              ?.map((ingredient) => Ingredient.fromJson(ingredient as Map<String, dynamic>))
              .toList() ??
          [],
      instructions: json['instructions'] as String,
      cuisineType: json['cuisine_type'] as String?,
      mealType: json['meal_type'] as String?,
      prepTimeMinutes: json['prep_time_minutes'] as int?,
      cookTimeMinutes: json['cook_time_minutes'] as int?,
      totalTimeMinutes: json['total_time_minutes'] as int?,
      nutritionalInfo: json['nutritional_info'] != null
          ? NutritionalInfo.fromJson(json['nutritional_info'] as Map<String, dynamic>)
          : null,
      estimatedCostUsd: json['estimated_cost_usd'] as int?,
      costPerServingUsd: _safeToDouble(json['cost_per_serving_usd']),
      difficultyLevel: json['difficulty_level'] as String?,
      sourceUrl: json['source_url'] as String?,
      imageUrl: json['image_url'] as String?,
      servings: json['servings'] as int? ?? 1,
      caloriesPerServing: _safeToDouble(json['calories_per_serving']),
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  static double? _safeToDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'ingredients': ingredients.map((ingredient) => ingredient.toJson()).toList(),
      'instructions': instructions,
      'cuisine_type': cuisineType,
      'meal_type': mealType,
      'prep_time_minutes': prepTimeMinutes,
      'cook_time_minutes': cookTimeMinutes,
      'total_time_minutes': totalTimeMinutes,
      'nutritional_info': nutritionalInfo?.toJson(),
      'estimated_cost_usd': estimatedCostUsd,
      'cost_per_serving_usd': costPerServingUsd,
      'difficulty_level': difficultyLevel,
      'source_url': sourceUrl,
      'image_url': imageUrl,
      'servings': servings,
      'calories_per_serving': caloriesPerServing,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Helper getters
  String get displayName => name;
  
  String get timeDisplay {
    if (totalTimeMinutes != null) {
      return '${totalTimeMinutes}min';
    } else if (prepTimeMinutes != null) {
      return '${prepTimeMinutes}min prep';
    }
    return 'Time not specified';
  }

  String get costDisplay {
    if (costPerServingUsd != null) {
      return '\$${costPerServingUsd!.toStringAsFixed(2)}';
    }
    return 'Cost not available';
  }

  String get difficultyDisplay => difficultyLevel?.capitalize() ?? 'Unknown';

  String get caloriesDisplay {
    if (caloriesPerServing != null) {
      return '${caloriesPerServing!.round()} cal';
    }
    return 'Calories not available';
  }

  List<String> get dietaryTags {
    List<String> tags = [];
    
    // Simple dietary restriction detection based on ingredients
    final ingredientText = ingredients.map((i) => i.name.toLowerCase()).join(' ');
    
    if (!ingredientText.contains('meat') && 
        !ingredientText.contains('chicken') && 
        !ingredientText.contains('beef') && 
        !ingredientText.contains('pork') && 
        !ingredientText.contains('fish')) {
      if (!ingredientText.contains('dairy') && 
          !ingredientText.contains('milk') && 
          !ingredientText.contains('cheese') && 
          !ingredientText.contains('egg')) {
        tags.add('Vegan');
      } else {
        tags.add('Vegetarian');
      }
    }
    
    if (!ingredientText.contains('gluten') && 
        !ingredientText.contains('wheat') && 
        !ingredientText.contains('flour')) {
      tags.add('Gluten-Free');
    }
    
    return tags;
  }

  bool matchesDietaryRestrictions(List<String> restrictions) {
    if (restrictions.isEmpty) return true;
    
    final tags = dietaryTags.map((tag) => tag.toLowerCase()).toList();
    
    for (String restriction in restrictions) {
      if (!tags.contains(restriction.toLowerCase())) {
        return false;
      }
    }
    
    return true;
  }
}

class Ingredient {
  final String name;
  final String quantity;
  final String? unit;

  Ingredient({
    required this.name,
    required this.quantity,
    this.unit,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      name: json['name'] as String,
      quantity: json['quantity'] as String,
      unit: json['unit'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'unit': unit,
    };
  }

  String get displayText {
    if (unit != null && unit!.isNotEmpty) {
      return '$quantity $unit $name';
    }
    return '$quantity $name';
  }
}

class NutritionalInfo {
  final double calories;
  final double? protein;
  final double? carbs;
  final double? fat;
  final double? fiber;
  final double? sugar;
  final double? sodium;

  NutritionalInfo({
    required this.calories,
    this.protein,
    this.carbs,
    this.fat,
    this.fiber,
    this.sugar,
    this.sodium,
  });

  factory NutritionalInfo.fromJson(Map<String, dynamic> json) {
    return NutritionalInfo(
      calories: Recipe._safeToDouble(json['calories']) ?? 0.0,
      protein: Recipe._safeToDouble(json['protein']),
      carbs: Recipe._safeToDouble(json['carbs']),
      fat: Recipe._safeToDouble(json['fat']),
      fiber: Recipe._safeToDouble(json['fiber']),
      sugar: Recipe._safeToDouble(json['sugar']),
      sodium: Recipe._safeToDouble(json['sodium']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'fiber': fiber,
      'sugar': sugar,
      'sodium': sodium,
    };
  }
}

class RecipeSearchResult {
  final List<Recipe> recipes;
  final RecipePagination pagination;
  final Map<String, dynamic> filtersApplied;
  final String searchQuery;
  final RecipeSort sort;

  RecipeSearchResult({
    required this.recipes,
    required this.pagination,
    required this.filtersApplied,
    required this.searchQuery,
    required this.sort,
  });

  factory RecipeSearchResult.fromJson(Map<String, dynamic> json) {
    return RecipeSearchResult(
      recipes: (json['recipes'] as List<dynamic>)
          .map((recipe) => Recipe.fromJson(recipe as Map<String, dynamic>))
          .toList(),
      pagination: RecipePagination.fromJson(json['pagination'] as Map<String, dynamic>),
      filtersApplied: json['filters_applied'] as Map<String, dynamic>,
      searchQuery: json['search_query'] as String,
      sort: RecipeSort.fromJson(json['sort'] as Map<String, dynamic>),
    );
  }
}

class RecipePagination {
  final int page;
  final int limit;
  final int totalCount;
  final int totalPages;
  final bool hasNext;
  final bool hasPrevious;

  RecipePagination({
    required this.page,
    required this.limit,
    required this.totalCount,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrevious,
  });

  factory RecipePagination.fromJson(Map<String, dynamic> json) {
    return RecipePagination(
      page: json['page'] as int,
      limit: json['limit'] as int,
      totalCount: json['total_count'] as int,
      totalPages: json['total_pages'] as int,
      hasNext: json['has_next'] as bool,
      hasPrevious: json['has_previous'] as bool,
    );
  }
}

class RecipeSort {
  final String sortBy;
  final String sortOrder;

  RecipeSort({
    required this.sortBy,
    required this.sortOrder,
  });

  factory RecipeSort.fromJson(Map<String, dynamic> json) {
    return RecipeSort(
      sortBy: json['sort_by'] as String,
      sortOrder: json['sort_order'] as String,
    );
  }
}

class RecipeFilters {
  final String? mealType;
  final String? cuisineType;
  final List<String> dietaryRestrictions;
  final String? difficultyLevel;
  final int? maxPrepTime;
  final double? minCostUsd;
  final double? maxCostUsd;

  RecipeFilters({
    this.mealType,
    this.cuisineType,
    this.dietaryRestrictions = const [],
    this.difficultyLevel,
    this.maxPrepTime,
    this.minCostUsd,
    this.maxCostUsd,
  });

  Map<String, dynamic> toQueryParams() {
    Map<String, dynamic> params = {};
    
    if (mealType != null) params['meal_type'] = mealType;
    if (cuisineType != null) params['cuisine_type'] = cuisineType;
    if (dietaryRestrictions.isNotEmpty) {
      params['dietary_restrictions'] = dietaryRestrictions.join(',');
    }
    if (difficultyLevel != null) params['difficulty_level'] = difficultyLevel;
    if (maxPrepTime != null) params['max_prep_time'] = maxPrepTime.toString();
    if (minCostUsd != null) params['min_cost_usd'] = minCostUsd.toString();
    if (maxCostUsd != null) params['max_cost_usd'] = maxCostUsd.toString();
    
    return params;
  }

  bool get hasActiveFilters {
    return mealType != null ||
        cuisineType != null ||
        dietaryRestrictions.isNotEmpty ||
        difficultyLevel != null ||
        maxPrepTime != null ||
        minCostUsd != null ||
        maxCostUsd != null;
  }

  RecipeFilters copyWith({
    String? mealType,
    String? cuisineType,
    List<String>? dietaryRestrictions,
    String? difficultyLevel,
    int? maxPrepTime,
    double? minCostUsd,
    double? maxCostUsd,
    bool clearMealType = false,
    bool clearCuisineType = false,
    bool clearDifficultyLevel = false,
    bool clearMaxPrepTime = false,
    bool clearMinCostUsd = false,
    bool clearMaxCostUsd = false,
  }) {
    return RecipeFilters(
      mealType: clearMealType ? null : (mealType ?? this.mealType),
      cuisineType: clearCuisineType ? null : (cuisineType ?? this.cuisineType),
      dietaryRestrictions: dietaryRestrictions ?? this.dietaryRestrictions,
      difficultyLevel: clearDifficultyLevel ? null : (difficultyLevel ?? this.difficultyLevel),
      maxPrepTime: clearMaxPrepTime ? null : (maxPrepTime ?? this.maxPrepTime),
      minCostUsd: clearMinCostUsd ? null : (minCostUsd ?? this.minCostUsd),
      maxCostUsd: clearMaxCostUsd ? null : (maxCostUsd ?? this.maxCostUsd),
    );
  }

  RecipeFilters clear() {
    return RecipeFilters();
  }
}

class FilterOptions {
  final List<String> mealTypes;
  final List<String> cuisineTypes;
  final List<String> difficultyLevels;
  final List<String> dietaryRestrictions;
  final List<TimeRange> timeRanges;
  final List<CostRange> costRanges;

  FilterOptions({
    required this.mealTypes,
    required this.cuisineTypes,
    required this.difficultyLevels,
    required this.dietaryRestrictions,
    required this.timeRanges,
    required this.costRanges,
  });

  factory FilterOptions.fromJson(Map<String, dynamic> json) {
    return FilterOptions(
      mealTypes: (json['meal_types'] as List<dynamic>).cast<String>(),
      cuisineTypes: (json['cuisine_types'] as List<dynamic>).cast<String>(),
      difficultyLevels: (json['difficulty_levels'] as List<dynamic>).cast<String>(),
      dietaryRestrictions: (json['dietary_restrictions'] as List<dynamic>).cast<String>(),
      timeRanges: (json['time_ranges'] as List<dynamic>)
          .map((range) => TimeRange.fromJson(range as Map<String, dynamic>))
          .toList(),
      costRanges: (json['cost_ranges'] as List<dynamic>)
          .map((range) => CostRange.fromJson(range as Map<String, dynamic>))
          .toList(),
    );
  }
}

class TimeRange {
  final String label;
  final int? minMinutes;
  final int? maxMinutes;

  TimeRange({
    required this.label,
    this.minMinutes,
    this.maxMinutes,
  });

  factory TimeRange.fromJson(Map<String, dynamic> json) {
    return TimeRange(
      label: json['label'] as String,
      minMinutes: json['min_minutes'] as int?,
      maxMinutes: json['max_minutes'] as int?,
    );
  }
}

class CostRange {
  final String label;
  final double? minUsd;
  final double? maxUsd;

  CostRange({
    required this.label,
    this.minUsd,
    this.maxUsd,
  });

  factory CostRange.fromJson(Map<String, dynamic> json) {
    return CostRange(
      label: json['label'] as String,
      minUsd: Recipe._safeToDouble(json['min_usd']),
      maxUsd: Recipe._safeToDouble(json['max_usd']),
    );
  }
}

// Extension for string capitalization
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
} 