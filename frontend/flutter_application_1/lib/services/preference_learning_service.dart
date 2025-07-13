import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/meal_suggestion.dart';
import '../utils/app_constants.dart';

class PreferenceLearningService {
  static const String baseUrl = 'http://localhost:5000/api/v1';
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  PreferenceLearningService() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);

    // Add auth interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        print('API Error: ${error.message}');
        handler.next(error);
      },
    ));
  }

  Future<List<MealSuggestion>> getMealSuggestions({int sessionLength = 20}) async {
    try {
      final response = await _dio.get(
        '/preferences/recommendations/meals',
        queryParameters: {'session_length': sessionLength},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final suggestions = data['suggestions'] as List;
        return suggestions.map((json) => MealSuggestion.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get meal suggestions: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Authentication failed. Please log in again.');
      } else if (e.response?.statusCode == 404) {
        throw Exception('User not found.');
      } else {
        throw Exception('Failed to get meal suggestions: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<bool> recordSwipeFeedback(String recipeId, String action) async {
    try {
      final response = await _dio.post(
        '/preferences/user-preferences/meal-feedback',
        data: {
          'recipe_id': recipeId,
          'action': action,
        },
      );

      return response.statusCode == 201;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Authentication failed. Please log in again.');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Recipe not found.');
      } else if (e.response?.statusCode == 400) {
        throw Exception('Invalid swipe action.');
      } else {
        throw Exception('Failed to record swipe feedback: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<bool> setRecipeRating(String recipeId, double rating) async {
    try {
      final response = await _dio.post(
        '/preferences/user-preferences/recipe-ratings',
        data: {
          'recipe_id': recipeId,
          'rating': rating,
        },
      );

      return response.statusCode == 201;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Authentication failed. Please log in again.');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Recipe not found.');
      } else if (e.response?.statusCode == 400) {
        throw Exception('Invalid rating value.');
      } else {
        throw Exception('Failed to set recipe rating: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<bool> updateIngredientPreference(String ingredient, String preference) async {
    try {
      final response = await _dio.post(
        '/preferences/user-preferences/ingredients',
        data: {
          'ingredient': ingredient,
          'preference': preference,
        },
      );

      return response.statusCode == 201;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Authentication failed. Please log in again.');
      } else if (e.response?.statusCode == 400) {
        throw Exception('Invalid ingredient preference.');
      } else {
        throw Exception('Failed to update ingredient preference: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<bool> setCuisinePreference(String cuisine, int rating) async {
    try {
      final response = await _dio.post(
        '/preferences/user-preferences/cuisines',
        data: {
          'cuisine': cuisine,
          'rating': rating,
        },
      );

      return response.statusCode == 201;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Authentication failed. Please log in again.');
      } else if (e.response?.statusCode == 400) {
        throw Exception('Invalid cuisine preference.');
      } else {
        throw Exception('Failed to set cuisine preference: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<Map<String, dynamic>> getPreferenceStats() async {
    try {
      final response = await _dio.get('/preferences/user-preferences/stats');

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to get preference stats: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Authentication failed. Please log in again.');
      } else if (e.response?.statusCode == 404) {
        throw Exception('User preferences not found.');
      } else {
        throw Exception('Failed to get preference stats: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
} 