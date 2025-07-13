class NutritionalAnalysis {
  final String mealPlanId;
  final DateTime analysisDate;
  final List<DailyNutritionAnalysis> dailyAnalyses;
  final OverallSummary overallSummary;
  final List<NutritionalInsight> insights;
  final CostAnalysis costAnalysis;
  final List<String> recommendations;
  final List<String> nutritionalAchievements;

  NutritionalAnalysis({
    required this.mealPlanId,
    required this.analysisDate,
    required this.dailyAnalyses,
    required this.overallSummary,
    required this.insights,
    required this.costAnalysis,
    required this.recommendations,
    required this.nutritionalAchievements,
  });

  factory NutritionalAnalysis.fromJson(Map<String, dynamic> json) {
    return NutritionalAnalysis(
      mealPlanId: json['meal_plan_id'] as String,
      analysisDate: DateTime.parse(json['analysis_date'] as String),
      dailyAnalyses: (json['daily_analyses'] as List<dynamic>)
          .map((analysis) => DailyNutritionAnalysis.fromJson(analysis as Map<String, dynamic>))
          .toList(),
      overallSummary: OverallSummary.fromJson(json['overall_summary'] as Map<String, dynamic>),
      insights: (json['insights'] as List<dynamic>)
          .map((insight) => NutritionalInsight.fromJson(insight as Map<String, dynamic>))
          .toList(),
      costAnalysis: CostAnalysis.fromJson(json['cost_analysis'] as Map<String, dynamic>),
      recommendations: (json['recommendations'] as List<dynamic>)
          .map((rec) => rec as String)
          .toList(),
      nutritionalAchievements: (json['nutritional_achievements'] as List<dynamic>)
          .map((achievement) => achievement as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'meal_plan_id': mealPlanId,
      'analysis_date': analysisDate.toIso8601String(),
      'daily_analyses': dailyAnalyses.map((analysis) => analysis.toJson()).toList(),
      'overall_summary': overallSummary.toJson(),
      'insights': insights.map((insight) => insight.toJson()).toList(),
      'cost_analysis': costAnalysis.toJson(),
      'recommendations': recommendations,
      'nutritional_achievements': nutritionalAchievements,
    };
  }
}

class DailyNutritionAnalysis {
  final String date;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final double sodium;
  final Map<String, double> goalAdherence;
  final List<NutritionalInsight> insights;
  final double costUsd;

  DailyNutritionAnalysis({
    required this.date,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
    required this.sodium,
    required this.goalAdherence,
    required this.insights,
    required this.costUsd,
  });

  factory DailyNutritionAnalysis.fromJson(Map<String, dynamic> json) {
    return DailyNutritionAnalysis(
      date: json['date'] as String,
      calories: (json['calories'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      fiber: (json['fiber'] as num).toDouble(),
      sodium: (json['sodium'] as num).toDouble(),
      goalAdherence: (json['goal_adherence'] as Map<String, dynamic>)
          .map((key, value) => MapEntry(key, (value as num).toDouble())),
      insights: (json['insights'] as List<dynamic>)
          .map((insight) => NutritionalInsight.fromJson(insight as Map<String, dynamic>))
          .toList(),
      costUsd: (json['cost_usd'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'fiber': fiber,
      'sodium': sodium,
      'goal_adherence': goalAdherence,
      'insights': insights.map((insight) => insight.toJson()).toList(),
      'cost_usd': costUsd,
    };
  }

  double get totalMacros => protein + carbs + fat;
  double get proteinPercentage => totalMacros > 0 ? (protein / totalMacros) * 100 : 0;
  double get carbsPercentage => totalMacros > 0 ? (carbs / totalMacros) * 100 : 0;
  double get fatPercentage => totalMacros > 0 ? (fat / totalMacros) * 100 : 0;
}

class NutritionalInsight {
  final String type; // 'achievement', 'warning', 'suggestion', 'info'
  final String message;
  final String suggestion;
  final int priority; // 1=high, 2=medium, 3=low

  NutritionalInsight({
    required this.type,
    required this.message,
    required this.suggestion,
    required this.priority,
  });

  factory NutritionalInsight.fromJson(Map<String, dynamic> json) {
    return NutritionalInsight(
      type: json['type'] as String,
      message: json['message'] as String,
      suggestion: json['suggestion'] as String,
      priority: json['priority'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'message': message,
      'suggestion': suggestion,
      'priority': priority,
    };
  }

  bool get isAchievement => type == 'achievement';
  bool get isWarning => type == 'warning';
  bool get isSuggestion => type == 'suggestion';
  bool get isInfo => type == 'info';
  bool get isHighPriority => priority == 1;
}

class OverallSummary {
  final double avgDailyCalories;
  final double avgDailyProtein;
  final double avgDailyCarbs;
  final double avgDailyFat;
  final double totalCost;
  final Map<String, double> avgGoalAdherence;

  OverallSummary({
    required this.avgDailyCalories,
    required this.avgDailyProtein,
    required this.avgDailyCarbs,
    required this.avgDailyFat,
    required this.totalCost,
    required this.avgGoalAdherence,
  });

  factory OverallSummary.fromJson(Map<String, dynamic> json) {
    return OverallSummary(
      avgDailyCalories: (json['avg_daily_calories'] as num).toDouble(),
      avgDailyProtein: (json['avg_daily_protein'] as num).toDouble(),
      avgDailyCarbs: (json['avg_daily_carbs'] as num).toDouble(),
      avgDailyFat: (json['avg_daily_fat'] as num).toDouble(),
      totalCost: (json['total_cost'] as num).toDouble(),
      avgGoalAdherence: (json['avg_goal_adherence'] as Map<String, dynamic>)
          .map((key, value) => MapEntry(key, (value as num).toDouble())),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'avg_daily_calories': avgDailyCalories,
      'avg_daily_protein': avgDailyProtein,
      'avg_daily_carbs': avgDailyCarbs,
      'avg_daily_fat': avgDailyFat,
      'total_cost': totalCost,
      'avg_goal_adherence': avgGoalAdherence,
    };
  }

  double get avgDailyMacros => avgDailyProtein + avgDailyCarbs + avgDailyFat;
  double get avgProteinPercentage => avgDailyMacros > 0 ? (avgDailyProtein / avgDailyMacros) * 100 : 0;
  double get avgCarbsPercentage => avgDailyMacros > 0 ? (avgDailyCarbs / avgDailyMacros) * 100 : 0;
  double get avgFatPercentage => avgDailyMacros > 0 ? (avgDailyFat / avgDailyMacros) * 100 : 0;
}

class CostAnalysis {
  final double totalCostUsd;
  final double dailyAverageCostUsd;
  final double budgetTargetUsd;
  final String budgetAdherence; // 'within_budget', 'over_budget'
  final double budgetVariancePercent;
  final double costPerCalorie;
  final String costEfficiencyRating; // 'excellent', 'good', 'fair', 'expensive'

  CostAnalysis({
    required this.totalCostUsd,
    required this.dailyAverageCostUsd,
    required this.budgetTargetUsd,
    required this.budgetAdherence,
    required this.budgetVariancePercent,
    required this.costPerCalorie,
    required this.costEfficiencyRating,
  });

  factory CostAnalysis.fromJson(Map<String, dynamic> json) {
    return CostAnalysis(
      totalCostUsd: (json['total_cost_usd'] as num).toDouble(),
      dailyAverageCostUsd: (json['daily_average_cost_usd'] as num).toDouble(),
      budgetTargetUsd: (json['budget_target_usd'] as num).toDouble(),
      budgetAdherence: json['budget_adherence'] as String,
      budgetVariancePercent: (json['budget_variance_percent'] as num).toDouble(),
      costPerCalorie: (json['cost_per_calorie'] as num).toDouble(),
      costEfficiencyRating: json['cost_efficiency_rating'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_cost_usd': totalCostUsd,
      'daily_average_cost_usd': dailyAverageCostUsd,
      'budget_target_usd': budgetTargetUsd,
      'budget_adherence': budgetAdherence,
      'budget_variance_percent': budgetVariancePercent,
      'cost_per_calorie': costPerCalorie,
      'cost_efficiency_rating': costEfficiencyRating,
    };
  }

  bool get isWithinBudget => budgetAdherence == 'within_budget';
  bool get isOverBudget => budgetAdherence == 'over_budget';
  bool get isExcellentValue => costEfficiencyRating == 'excellent';
  bool get isGoodValue => costEfficiencyRating == 'good';
}

class WeeklyTrends {
  final int weeksAnalyzed;
  final DateTime startDate;
  final DateTime endDate;
  final List<WeeklyData> weeklyData;
  final TrendAnalysis trends;
  final List<String> insights;

  WeeklyTrends({
    required this.weeksAnalyzed,
    required this.startDate,
    required this.endDate,
    required this.weeklyData,
    required this.trends,
    required this.insights,
  });

  factory WeeklyTrends.fromJson(Map<String, dynamic> json) {
    return WeeklyTrends(
      weeksAnalyzed: json['weeks_analyzed'] as int,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      weeklyData: (json['weekly_data'] as List<dynamic>)
          .map((data) => WeeklyData.fromJson(data as Map<String, dynamic>))
          .toList(),
      trends: TrendAnalysis.fromJson(json['trends'] as Map<String, dynamic>),
      insights: (json['insights'] as List<dynamic>)
          .map((insight) => insight as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'weeks_analyzed': weeksAnalyzed,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'weekly_data': weeklyData.map((data) => data.toJson()).toList(),
      'trends': trends.toJson(),
      'insights': insights,
    };
  }
}

class WeeklyData {
  final DateTime weekStart;
  final double avgCalories;
  final double avgProtein;
  final double avgCarbs;
  final double avgFat;
  final double totalCost;

  WeeklyData({
    required this.weekStart,
    required this.avgCalories,
    required this.avgProtein,
    required this.avgCarbs,
    required this.avgFat,
    required this.totalCost,
  });

  factory WeeklyData.fromJson(Map<String, dynamic> json) {
    return WeeklyData(
      weekStart: DateTime.parse(json['week_start'] as String),
      avgCalories: (json['avg_calories'] as num).toDouble(),
      avgProtein: (json['avg_protein'] as num).toDouble(),
      avgCarbs: (json['avg_carbs'] as num).toDouble(),
      avgFat: (json['avg_fat'] as num).toDouble(),
      totalCost: (json['total_cost'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'week_start': weekStart.toIso8601String(),
      'avg_calories': avgCalories,
      'avg_protein': avgProtein,
      'avg_carbs': avgCarbs,
      'avg_fat': avgFat,
      'total_cost': totalCost,
    };
  }
}

class TrendAnalysis {
  final double avgCalories;
  final double avgProtein;
  final double avgCarbs;
  final double avgFat;
  final double avgCost;
  final double calorieConsistency;
  final String proteinTrend; // 'increasing', 'decreasing', 'stable'
  final String costTrend;
  final String bestDay;
  final List<String> improvementAreas;

  TrendAnalysis({
    required this.avgCalories,
    required this.avgProtein,
    required this.avgCarbs,
    required this.avgFat,
    required this.avgCost,
    required this.calorieConsistency,
    required this.proteinTrend,
    required this.costTrend,
    required this.bestDay,
    required this.improvementAreas,
  });

  factory TrendAnalysis.fromJson(Map<String, dynamic> json) {
    return TrendAnalysis(
      avgCalories: (json['avg_calories'] as num).toDouble(),
      avgProtein: (json['avg_protein'] as num).toDouble(),
      avgCarbs: (json['avg_carbs'] as num).toDouble(),
      avgFat: (json['avg_fat'] as num).toDouble(),
      avgCost: (json['avg_cost'] as num).toDouble(),
      calorieConsistency: (json['calorie_consistency'] as num).toDouble(),
      proteinTrend: json['protein_trend'] as String,
      costTrend: json['cost_trend'] as String,
      bestDay: json['best_day'] as String,
      improvementAreas: (json['improvement_areas'] as List<dynamic>)
          .map((area) => area as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'avg_calories': avgCalories,
      'avg_protein': avgProtein,
      'avg_carbs': avgCarbs,
      'avg_fat': avgFat,
      'avg_cost': avgCost,
      'calorie_consistency': calorieConsistency,
      'protein_trend': proteinTrend,
      'cost_trend': costTrend,
      'best_day': bestDay,
      'improvement_areas': improvementAreas,
    };
  }

  bool get isProteinIncreasing => proteinTrend == 'increasing';
  bool get isProteinDecreasing => proteinTrend == 'decreasing';
  bool get isCostIncreasing => costTrend == 'increasing';
  bool get isCostDecreasing => costTrend == 'decreasing';
  bool get hasGoodConsistency => calorieConsistency >= 80;
} 