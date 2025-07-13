class SubstitutionCandidate {
  final String recipeId;
  final String recipeName;
  final String? cuisineType;
  final int? prepTimeMinutes;
  final int? cookTimeMinutes;
  final int? totalTimeMinutes;
  final Map<String, dynamic>? nutritionalInfo;
  final double? estimatedCostUsd;
  final String? difficultyLevel;
  
  // Scoring information
  final double totalScore;
  final double nutritionalSimilarity;
  final double userPreference;
  final double costEfficiency;
  final double prepTimeMatch;
  
  // Impact information
  final SubstitutionImpact substitutionImpact;

  SubstitutionCandidate({
    required this.recipeId,
    required this.recipeName,
    this.cuisineType,
    this.prepTimeMinutes,
    this.cookTimeMinutes,
    this.totalTimeMinutes,
    this.nutritionalInfo,
    this.estimatedCostUsd,
    this.difficultyLevel,
    required this.totalScore,
    required this.nutritionalSimilarity,
    required this.userPreference,
    required this.costEfficiency,
    required this.prepTimeMatch,
    required this.substitutionImpact,
  });

  factory SubstitutionCandidate.fromJson(Map<String, dynamic> json) {
    return SubstitutionCandidate(
      recipeId: json['recipe_id'] as String,
      recipeName: json['recipe_name'] as String,
      cuisineType: json['cuisine_type'] as String?,
      prepTimeMinutes: json['prep_time_minutes'] as int?,
      cookTimeMinutes: json['cook_time_minutes'] as int?,
      totalTimeMinutes: json['total_time_minutes'] as int?,
      nutritionalInfo: json['nutritional_info'] as Map<String, dynamic>?,
      estimatedCostUsd: json['estimated_cost_usd'] != null 
          ? (json['estimated_cost_usd'] as num).toDouble() 
          : null,
      difficultyLevel: json['difficulty_level'] as String?,
      totalScore: (json['total_score'] as num).toDouble(),
      nutritionalSimilarity: (json['nutritional_similarity'] as num).toDouble(),
      userPreference: (json['user_preference'] as num).toDouble(),
      costEfficiency: (json['cost_efficiency'] as num).toDouble(),
      prepTimeMatch: (json['prep_time_match'] as num).toDouble(),
      substitutionImpact: SubstitutionImpact.fromJson(
          json['substitution_impact'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recipe_id': recipeId,
      'recipe_name': recipeName,
      'cuisine_type': cuisineType,
      'prep_time_minutes': prepTimeMinutes,
      'cook_time_minutes': cookTimeMinutes,
      'total_time_minutes': totalTimeMinutes,
      'nutritional_info': nutritionalInfo,
      'estimated_cost_usd': estimatedCostUsd,
      'difficulty_level': difficultyLevel,
      'total_score': totalScore,
      'nutritional_similarity': nutritionalSimilarity,
      'user_preference': userPreference,
      'cost_efficiency': costEfficiency,
      'prep_time_match': prepTimeMatch,
      'substitution_impact': substitutionImpact.toJson(),
    };
  }

  double get calories => _safeToDouble(nutritionalInfo?['calories']) ?? 0.0;
  double get protein => _safeToDouble(nutritionalInfo?['protein']) ?? 0.0;
  double get carbs => _safeToDouble(nutritionalInfo?['carbs']) ?? 0.0;
  double get fat => _safeToDouble(nutritionalInfo?['fat']) ?? 0.0;

  // Helper method to safely convert various numeric types to double
  static double? _safeToDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  String get scoreGrade {
    if (totalScore >= 0.8) return 'A';
    if (totalScore >= 0.6) return 'B';
    if (totalScore >= 0.4) return 'C';
    return 'D';
  }

  String get timeDisplay {
    if (totalTimeMinutes != null) {
      return '${totalTimeMinutes}min';
    } else if (prepTimeMinutes != null) {
      return '${prepTimeMinutes}min prep';
    }
    return 'Time not specified';
  }
}

class SubstitutionImpact {
  final Map<String, double> changes;
  final Map<String, double> newTotals;
  final String impactLevel;
  final double costChangeUsd;

  SubstitutionImpact({
    required this.changes,
    required this.newTotals,
    required this.impactLevel,
    required this.costChangeUsd,
  });

  factory SubstitutionImpact.fromJson(Map<String, dynamic> json) {
    return SubstitutionImpact(
      changes: Map<String, double>.from(
          (json['changes'] as Map<String, dynamic>).map(
              (key, value) => MapEntry(key, (value as num).toDouble()))),
      newTotals: Map<String, double>.from(
          (json['new_totals'] as Map<String, dynamic>).map(
              (key, value) => MapEntry(key, (value as num).toDouble()))),
      impactLevel: json['impact_level'] as String,
      costChangeUsd: (json['cost_change_usd'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'changes': changes,
      'new_totals': newTotals,
      'impact_level': impactLevel,
      'cost_change_usd': costChangeUsd,
    };
  }

  double get calorieChange => changes['calories'] ?? 0.0;
  double get proteinChange => changes['protein'] ?? 0.0;
  double get carbChange => changes['carbs'] ?? 0.0;
  double get fatChange => changes['fat'] ?? 0.0;

  bool get isSignificant => impactLevel == 'significant';
  bool get isModerate => impactLevel == 'moderate';
  bool get isMinimal => impactLevel == 'minimal';

  String get impactDescription {
    if (isSignificant) {
      return 'Significant nutritional change';
    } else if (isModerate) {
      return 'Moderate nutritional change';
    } else {
      return 'Minimal nutritional change';
    }
  }
}

class SubstitutionRequest {
  final String mealPlanId;
  final int mealIndex;
  final int maxAlternatives;
  final double nutritionalTolerance;

  SubstitutionRequest({
    required this.mealPlanId,
    required this.mealIndex,
    this.maxAlternatives = 5,
    this.nutritionalTolerance = 0.15,
  });

  Map<String, dynamic> toJson() {
    return {
      'meal_plan_id': mealPlanId,
      'meal_index': mealIndex,
      'max_alternatives': maxAlternatives,
      'nutritional_tolerance': nutritionalTolerance,
    };
  }
}

class SubstitutionResponse {
  final String mealPlanId;
  final int mealIndex;
  final Map<String, dynamic> originalRecipe;
  final List<SubstitutionCandidate> alternatives;
  final int totalFound;

  SubstitutionResponse({
    required this.mealPlanId,
    required this.mealIndex,
    required this.originalRecipe,
    required this.alternatives,
    required this.totalFound,
  });

  factory SubstitutionResponse.fromJson(Map<String, dynamic> json) {
    return SubstitutionResponse(
      mealPlanId: json['meal_plan_id'] as String,
      mealIndex: json['meal_index'] as int,
      originalRecipe: json['original_recipe'] as Map<String, dynamic>,
      alternatives: (json['alternatives'] as List<dynamic>)
          .map((alt) => SubstitutionCandidate.fromJson(alt as Map<String, dynamic>))
          .toList(),
      totalFound: json['total_found'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'meal_plan_id': mealPlanId,
      'meal_index': mealIndex,
      'original_recipe': originalRecipe,
      'alternatives': alternatives.map((alt) => alt.toJson()).toList(),
      'total_found': totalFound,
    };
  }

  String get originalRecipeName => originalRecipe['name'] as String? ?? 'Unknown Recipe';
  
  bool get hasAlternatives => alternatives.isNotEmpty;
  
  List<SubstitutionCandidate> get topAlternatives => 
      alternatives.take(3).toList();
}

class SubstitutionHistory {
  final String mealPlanId;
  final List<SubstitutionHistoryItem> substitutionHistory;
  final bool canUndo;

  SubstitutionHistory({
    required this.mealPlanId,
    required this.substitutionHistory,
    required this.canUndo,
  });

  factory SubstitutionHistory.fromJson(Map<String, dynamic> json) {
    return SubstitutionHistory(
      mealPlanId: json['meal_plan_id'] as String,
      substitutionHistory: (json['substitution_history'] as List<dynamic>)
          .map((item) => SubstitutionHistoryItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      canUndo: json['can_undo'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'meal_plan_id': mealPlanId,
      'substitution_history': substitutionHistory.map((item) => item.toJson()).toList(),
      'can_undo': canUndo,
    };
  }

  SubstitutionHistoryItem? get mostRecent => 
      substitutionHistory.isNotEmpty ? substitutionHistory.last : null;
}

class SubstitutionHistoryItem {
  final int mealIndex;
  final String originalRecipeId;
  final String newRecipeId;
  final DateTime timestamp;
  final String userId;

  SubstitutionHistoryItem({
    required this.mealIndex,
    required this.originalRecipeId,
    required this.newRecipeId,
    required this.timestamp,
    required this.userId,
  });

  factory SubstitutionHistoryItem.fromJson(Map<String, dynamic> json) {
    return SubstitutionHistoryItem(
      mealIndex: json['meal_index'] as int,
      originalRecipeId: json['original_recipe_id'] as String,
      newRecipeId: json['new_recipe_id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      userId: json['user_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'meal_index': mealIndex,
      'original_recipe_id': originalRecipeId,
      'new_recipe_id': newRecipeId,
      'timestamp': timestamp.toIso8601String(),
      'user_id': userId,
    };
  }
} 