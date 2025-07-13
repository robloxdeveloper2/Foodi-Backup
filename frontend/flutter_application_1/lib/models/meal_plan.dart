class MealPlan {
  final String id;
  final String userId;
  final DateTime planDate;
  final int durationDays;
  final List<Meal> meals;
  final NutritionSummary totalNutritionSummary;
  final Map<int, NutritionSummary> dailyNutritionBreakdown;
  final double estimatedTotalCostUsd;
  final double? budgetTargetUsd;
  final bool? isWithinBudget;
  final List<String> dietaryRestrictionsUsed;
  final String algorithmVersion;
  final int? userRating;
  final String? userFeedback;
  final DateTime createdAt;
  final DateTime? updatedAt;

  MealPlan({
    required this.id,
    required this.userId,
    required this.planDate,
    required this.durationDays,
    required this.meals,
    required this.totalNutritionSummary,
    required this.dailyNutritionBreakdown,
    required this.estimatedTotalCostUsd,
    this.budgetTargetUsd,
    this.isWithinBudget,
    required this.dietaryRestrictionsUsed,
    required this.algorithmVersion,
    this.userRating,
    this.userFeedback,
    required this.createdAt,
    this.updatedAt,
  });

  factory MealPlan.fromJson(Map<String, dynamic> json) {
    final totalCost = MealPlan._safeToDouble(json['estimated_total_cost_usd']) ?? 0.0;
    final mealsData = json['meals'] as List<dynamic>;
    
    return MealPlan(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      planDate: DateTime.parse(json['plan_date'] as String),
      durationDays: json['duration_days'] as int,
      meals: mealsData
          .map((meal) => Meal.fromJson(meal as Map<String, dynamic>))
          .toList(),
      totalNutritionSummary: NutritionSummary.fromJson(
          json['total_nutrition_summary'] as Map<String, dynamic>),
      dailyNutritionBreakdown: _parseDailyNutrition(json['daily_nutrition_breakdown']),
      estimatedTotalCostUsd: totalCost,
      budgetTargetUsd: json['budget_target_usd'] != null
          ? MealPlan._safeToDouble(json['budget_target_usd'])
          : null,
      isWithinBudget: json['is_within_budget'] as bool?,
      dietaryRestrictionsUsed: (json['dietary_restrictions_used'] as List<dynamic>)
          .map((item) => item as String)
          .toList(),
      algorithmVersion: json['algorithm_version'] as String,
      userRating: json['user_rating'] as int?,
      userFeedback: json['user_feedback'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
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

  static Map<int, NutritionSummary> _parseDailyNutrition(dynamic dailyNutrition) {
    if (dailyNutrition == null || dailyNutrition is! Map<String, dynamic>) {
      return {};
    }
    
    return dailyNutrition.map((key, value) {
      if (value is Map<String, dynamic>) {
        return MapEntry(
          int.parse(key),
          NutritionSummary.fromJson(value),
        );
      }
      return MapEntry(int.parse(key), NutritionSummary(calories: 0, protein: 0, carbs: 0, fat: 0));
    });
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'plan_date': planDate.toIso8601String(),
      'duration_days': durationDays,
      'meals': meals.map((meal) => meal.toJson()).toList(),
      'total_nutrition_summary': totalNutritionSummary.toJson(),
      'daily_nutrition_breakdown': dailyNutritionBreakdown
          .map((key, value) => MapEntry(key.toString(), value.toJson())),
      'estimated_total_cost_usd': estimatedTotalCostUsd,
      'budget_target_usd': budgetTargetUsd,
      'is_within_budget': isWithinBudget,
      'dietary_restrictions_used': dietaryRestrictionsUsed,
      'algorithm_version': algorithmVersion,
      'user_rating': userRating,
      'user_feedback': userFeedback,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  DateTime get endDate => planDate.add(Duration(days: durationDays - 1));

  bool get isActive => DateTime.now().isBefore(endDate.add(const Duration(days: 1)));

  List<Meal> getMealsForDay(int day) {
    return meals.where((meal) => meal.day == day).toList();
  }

  double get averageDailyCost => estimatedTotalCostUsd / durationDays;

  bool get hasUserFeedback => userRating != null || userFeedback != null;
}

class Meal {
  final int day;
  final String mealType;
  final String recipeId;
  final String recipeName;
  final double score;
  final double? estimatedCostUsd;

  Meal({
    required this.day,
    required this.mealType,
    required this.recipeId,
    required this.recipeName,
    required this.score,
    this.estimatedCostUsd,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      day: json['day'] as int,
      mealType: json['meal_type'] as String,
      recipeId: json['recipe_id'] as String,
      recipeName: json['recipe_name'] as String,
      score: MealPlan._safeToDouble(json['score']) ?? 0.0,
      estimatedCostUsd: json['estimated_cost_usd'] != null 
          ? MealPlan._safeToDouble(json['estimated_cost_usd'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'meal_type': mealType,
      'recipe_id': recipeId,
      'recipe_name': recipeName,
      'score': score,
      if (estimatedCostUsd != null) 'estimated_cost_usd': estimatedCostUsd,
    };
  }

  bool get isBreakfast => mealType == 'breakfast';
  bool get isLunch => mealType == 'lunch';
  bool get isDinner => mealType == 'dinner';
  bool get isSnack => mealType == 'snack';
}

class NutritionSummary {
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double? cost;

  NutritionSummary({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.cost,
  });

  factory NutritionSummary.fromJson(Map<String, dynamic> json) {
    return NutritionSummary(
      calories: MealPlan._safeToDouble(json['calories']) ?? 0.0,
      protein: MealPlan._safeToDouble(json['protein']) ?? 0.0,
      carbs: MealPlan._safeToDouble(json['carbs']) ?? 0.0,
      fat: MealPlan._safeToDouble(json['fat']) ?? 0.0,
      cost: json['cost'] != null ? MealPlan._safeToDouble(json['cost']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      if (cost != null) 'cost': cost,
    };
  }

  double get totalMacros => protein + carbs + fat;

  double get proteinPercentage => totalMacros > 0 ? (protein / totalMacros) * 100 : 0;
  double get carbsPercentage => totalMacros > 0 ? (carbs / totalMacros) * 100 : 0;
  double get fatPercentage => totalMacros > 0 ? (fat / totalMacros) * 100 : 0;
}

class MealPlanListItem {
  final String id;
  final DateTime planDate;
  final int durationDays;
  final int mealsCount;
  final double estimatedTotalCostUsd;
  final bool? isWithinBudget;
  final int? userRating;
  final DateTime createdAt;

  MealPlanListItem({
    required this.id,
    required this.planDate,
    required this.durationDays,
    required this.mealsCount,
    required this.estimatedTotalCostUsd,
    this.isWithinBudget,
    this.userRating,
    required this.createdAt,
  });

  factory MealPlanListItem.fromJson(Map<String, dynamic> json) {
    return MealPlanListItem(
      id: json['id'] as String,
      planDate: DateTime.parse(json['plan_date'] as String),
      durationDays: json['duration_days'] as int,
      mealsCount: json['meals_count'] as int,
      estimatedTotalCostUsd: MealPlan._safeToDouble(json['estimated_total_cost_usd']) ?? 0.0,
      isWithinBudget: json['is_within_budget'] as bool?,
      userRating: json['user_rating'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  DateTime get endDate => planDate.add(Duration(days: durationDays - 1));
  double get averageDailyCost => estimatedTotalCostUsd / durationDays;
} 