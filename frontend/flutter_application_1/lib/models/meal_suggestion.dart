class MealSuggestion {
  final String id;
  final String name;
  final String? description;
  final List<Map<String, dynamic>> ingredients;
  final String instructions;
  final String? cuisineType;
  final String? mealType;
  final int? prepTimeMinutes;
  final int? cookTimeMinutes;
  final int? totalTimeMinutes;
  final Map<String, dynamic>? nutritionalInfo;
  final int? estimatedCostUsd;
  final double? costPerServingUsd;
  final String? difficultyLevel;
  final String? sourceUrl;
  final String? imageUrl;
  final int servings;
  final double? caloriesPerServing;
  final bool isActive;
  final String? createdAt;
  final String? updatedAt;
  final String? previousSwipe;
  final double? userRating;

  MealSuggestion({
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
    this.previousSwipe,
    this.userRating,
  });

  factory MealSuggestion.fromJson(Map<String, dynamic> json) {
    return MealSuggestion(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      ingredients: List<Map<String, dynamic>>.from(json['ingredients'] ?? []),
      instructions: json['instructions'] ?? '',
      cuisineType: json['cuisine_type'],
      mealType: json['meal_type'],
      prepTimeMinutes: json['prep_time_minutes'],
      cookTimeMinutes: json['cook_time_minutes'],
      totalTimeMinutes: json['total_time_minutes'],
      nutritionalInfo: json['nutritional_info'],
      estimatedCostUsd: json['estimated_cost_usd'],
      costPerServingUsd: json['cost_per_serving_usd']?.toDouble(),
      difficultyLevel: json['difficulty_level'],
      sourceUrl: json['source_url'],
      imageUrl: json['image_url'],
      servings: json['servings'] ?? 1,
      caloriesPerServing: json['calories_per_serving']?.toDouble(),
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      previousSwipe: json['previous_swipe'],
      userRating: json['user_rating']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'ingredients': ingredients,
      'instructions': instructions,
      'cuisine_type': cuisineType,
      'meal_type': mealType,
      'prep_time_minutes': prepTimeMinutes,
      'cook_time_minutes': cookTimeMinutes,
      'total_time_minutes': totalTimeMinutes,
      'nutritional_info': nutritionalInfo,
      'estimated_cost_usd': estimatedCostUsd,
      'cost_per_serving_usd': costPerServingUsd,
      'difficulty_level': difficultyLevel,
      'source_url': sourceUrl,
      'image_url': imageUrl,
      'servings': servings,
      'calories_per_serving': caloriesPerServing,
      'is_active': isActive,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'previous_swipe': previousSwipe,
      'user_rating': userRating,
    };
  }

  String get displayTime {
    if (totalTimeMinutes != null) {
      return '${totalTimeMinutes}min';
    } else if (prepTimeMinutes != null) {
      return '${prepTimeMinutes}min prep';
    }
    return 'Time varies';
  }

  String get displayCost {
    if (costPerServingUsd != null) {
      return '\$${costPerServingUsd!.toStringAsFixed(2)}';
    }
    return 'Cost varies';
  }

  String get displayCalories {
    if (caloriesPerServing != null) {
      return '${caloriesPerServing!.round()} cal';
    }
    return 'Calories vary';
  }

  String get displayDifficulty {
    switch (difficultyLevel?.toLowerCase()) {
      case 'easy':
        return 'Easy';
      case 'medium':
        return 'Medium';
      case 'hard':
        return 'Hard';
      default:
        return 'Medium';
    }
  }
} 