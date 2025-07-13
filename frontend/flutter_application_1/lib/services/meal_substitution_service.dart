import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/meal_substitution.dart';
import '../models/meal_plan.dart';
import '../utils/app_constants.dart';

class MealSubstitutionService {
  late final Dio _dio;

  MealSubstitutionService() {
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
  }

  // Set authorization token
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Get substitute meal suggestions for a specific meal in a meal plan
  /// AC 2.4.2: System suggests 3-5 alternative meals using smart matching algorithm
  Future<SubstitutionResponse> getSubstitutes({
    required String mealPlanId,
    required int mealIndex,
    int maxAlternatives = 5,
    double nutritionalTolerance = 0.15,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v1/meal-plans/$mealPlanId/substitutes/$mealIndex',
        queryParameters: {
          'max_alternatives': maxAlternatives,
          'nutritional_tolerance': nutritionalTolerance,
        },
      );

      if (response.statusCode == 200) {
        return SubstitutionResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to get substitutes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting substitutes: $e');
    }
  }

  /// Preview the impact of a meal substitution without applying it
  /// AC 2.4.7: User can preview and confirm substitution before applying
  /// AC 2.4.5: System shows impact of substitution on daily/weekly nutritional goals
  Future<Map<String, dynamic>> previewSubstitution({
    required String mealPlanId,
    required int mealIndex,
    required String newRecipeId,
  }) async {
    try {
      final response = await _dio.post(
        '/api/v1/meal-plans/$mealPlanId/substitution-preview',
        data: {
          'meal_index': mealIndex,
          'new_recipe_id': newRecipeId,
        },
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to preview substitution: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error previewing substitution: $e');
    }
  }

  /// Apply a meal substitution to a meal plan
  /// AC 2.4.7: User can preview and confirm substitution before applying
  Future<MealPlan> applySubstitution({
    required String mealPlanId,
    required int mealIndex,
    required String newRecipeId,
  }) async {
    try {
      final response = await _dio.put(
        '/api/v1/meal-plans/$mealPlanId/substitute',
        data: {
          'meal_index': mealIndex,
          'new_recipe_id': newRecipeId,
        },
      );

      if (response.statusCode == 200) {
        return MealPlan.fromJson(response.data['meal_plan']);
      } else {
        throw Exception('Failed to apply substitution: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error applying substitution: $e');
    }
  }

  /// Undo the most recent meal substitution in a meal plan
  /// AC 2.4.8: User can undo recent substitutions
  Future<MealPlan> undoSubstitution({
    required String mealPlanId,
  }) async {
    try {
      final response = await _dio.post(
        '/api/v1/meal-plans/$mealPlanId/undo-substitution',
        data: {},
      );

      if (response.statusCode == 200) {
        return MealPlan.fromJson(response.data['meal_plan']);
      } else {
        throw Exception('Failed to undo substitution: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error undoing substitution: $e');
    }
  }

  /// Get the substitution history for a meal plan
  Future<SubstitutionHistory> getSubstitutionHistory({
    required String mealPlanId,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v1/meal-plans/$mealPlanId/substitution-history',
      );

      if (response.statusCode == 200) {
        return SubstitutionHistory.fromJson(response.data);
      } else {
        throw Exception('Failed to get substitution history: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting substitution history: $e');
    }
  }

  /// Check if a meal plan has any substitutions that can be undone
  Future<bool> canUndoSubstitution({
    required String mealPlanId,
  }) async {
    try {
      final history = await getSubstitutionHistory(mealPlanId: mealPlanId);
      return history.canUndo;
    } catch (e) {
      // If we can't get history, assume no undo available
      return false;
    }
  }

  /// Get detailed substitution analytics for a meal plan
  Future<Map<String, dynamic>> getSubstitutionAnalytics({
    required String mealPlanId,
  }) async {
    try {
      final history = await getSubstitutionHistory(mealPlanId: mealPlanId);
      
      return {
        'total_substitutions': history.substitutionHistory.length,
        'can_undo': history.canUndo,
        'most_recent': history.mostRecent?.toJson(),
        'substitution_frequency': _calculateSubstitutionFrequency(history),
      };
    } catch (e) {
      return {
        'total_substitutions': 0,
        'can_undo': false,
        'most_recent': null,
        'substitution_frequency': 0.0,
      };
    }
  }

  double _calculateSubstitutionFrequency(SubstitutionHistory history) {
    if (history.substitutionHistory.isEmpty) return 0.0;
    
    // Calculate substitutions per day based on time span
    final now = DateTime.now();
    final earliest = history.substitutionHistory
        .map((item) => item.timestamp)
        .reduce((a, b) => a.isBefore(b) ? a : b);
    
    final daysDiff = now.difference(earliest).inDays;
    if (daysDiff == 0) return history.substitutionHistory.length.toDouble();
    
    return history.substitutionHistory.length / daysDiff;
  }
} 