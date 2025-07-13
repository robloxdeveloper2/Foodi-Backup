import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../utils/app_constants.dart';

class MealPlanningService {
  late final Dio _dio;

  MealPlanningService() {
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
        // Add auth token if available
        handler.next(options);
      },
      onError: (error, handler) {
        debugPrint('Meal Planning API Error: ${error.message}');
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

  // Generate a new meal plan
  Future<Map<String, dynamic>> generateMealPlan({
    required int durationDays,
    String? planDate,
    double? budgetUsd,
    bool includeSnacks = false,
    bool forceRegenerate = false,
  }) async {
    try {
      final data = {
        'duration_days': durationDays,
        'include_snacks': includeSnacks,
        'force_regenerate': forceRegenerate,
      };

      if (planDate != null) {
        data['plan_date'] = planDate;
      }

      if (budgetUsd != null) {
        data['budget_usd'] = budgetUsd;
      }

      final response = await _dio.post(
        '/api/v1/meal-plans/generate',
        data: data,
      );

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // Get a specific meal plan by ID
  Future<Map<String, dynamic>> getMealPlan(String planId) async {
    try {
      final response = await _dio.get(
        '/api/v1/meal-plans/$planId',
      );

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // Get all meal plans for the user
  Future<Map<String, dynamic>> getUserMealPlans({
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v1/meal-plans/user',
        queryParameters: {
          'limit': limit,
          'offset': offset,
        },
      );

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // Regenerate an existing meal plan with feedback
  Future<Map<String, dynamic>> regenerateMealPlan(
    String planId, {
    int? rating,
    String? feedback,
  }) async {
    try {
      final data = <String, dynamic>{};

      if (rating != null) {
        data['rating'] = rating;
      }

      if (feedback != null) {
        data['feedback'] = feedback;
      }

      final response = await _dio.put(
        '/api/v1/meal-plans/$planId/regenerate',
        data: data,
      );

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // Get meal plan statistics
  Future<Map<String, dynamic>> getMealPlanStats() async {
    try {
      final response = await _dio.get(
        '/api/v1/meal-plans/stats',
      );

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // Health check for meal plans service
  Future<Map<String, dynamic>> healthCheck() async {
    try {
      final response = await _dio.get(
        '/api/v1/meal-plans/health',
      );

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // Get nutritional analysis for a specific meal plan
  Future<Map<String, dynamic>> getMealPlanAnalysis(String planId) async {
    try {
      final response = await _dio.get(
        '/api/v1/meal-plans/$planId/analysis',
      );

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // Get weekly nutritional trends
  Future<Map<String, dynamic>> getWeeklyTrends({int weeks = 4}) async {
    try {
      final response = await _dio.get(
        '/api/v1/meal-plans/trends',
        queryParameters: {
          'weeks': weeks,
        },
      );

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // Handle successful response
  Map<String, dynamic> _handleResponse(Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      return response.data as Map<String, dynamic>;
    } else {
      return {
        'success': false,
        'error': {
          'message': 'Request failed with status: ${response.statusCode}',
          'status_code': response.statusCode,
        },
      };
    }
  }

  // Handle errors
  Map<String, dynamic> _handleError(dynamic error) {
    if (error is DioException) {
      if (error.response != null) {
        // Server responded with error
        final data = error.response!.data;
        if (data is Map<String, dynamic>) {
          return data;
        } else {
          return {
            'success': false,
            'error': {
              'message': 'Server error: ${error.response!.statusCode}',
              'status_code': error.response!.statusCode,
            },
          };
        }
      } else {
        // Network error
        return {
          'success': false,
          'error': {
            'message': _getNetworkErrorMessage(error.type),
            'type': 'network_error',
          },
        };
      }
    } else {
      // Other errors
      return {
        'success': false,
        'error': {
          'message': 'Unexpected error: ${error.toString()}',
          'type': 'unknown_error',
        },
      };
    }
  }

  // Get user-friendly network error messages
  String _getNetworkErrorMessage(DioExceptionType type) {
    switch (type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.sendTimeout:
        return 'Request timeout. Please try again.';
      case DioExceptionType.receiveTimeout:
        return 'Server response timeout. Please try again.';
      case DioExceptionType.connectionError:
        return 'Connection error. Please check your internet connection.';
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      default:
        return 'Network error. Please check your internet connection.';
    }
  }
} 