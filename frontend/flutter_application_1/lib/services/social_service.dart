import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../utils/app_constants.dart';
import '../models/social_models.dart';

class SocialService {
  late final Dio _dio;

  SocialService() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: AppConstants.connectionTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
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
        debugPrint('Social API Error: ${error.message}');
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

  // Get current user's social profile
  Future<Map<String, dynamic>> getCurrentUserProfile() async {
    try {
      final response = await _dio.get('/api/v1/social/users/me/profile');
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // Update current user's social profile
  Future<Map<String, dynamic>> updateUserProfile(UserSocialProfile profile) async {
    try {
      final data = {
        'display_name': profile.displayName,
        'bio': profile.bio,
        'profile_picture_url': profile.profilePictureUrl,
        'cover_photo_url': profile.coverPhotoUrl,
        'cooking_level': profile.cookingLevel,
        'favorite_cuisines': profile.favoriteCuisines,
        'cooking_goals': profile.cookingGoals,
        'dietary_preferences': profile.dietaryPreferences,
        'location': profile.location,
        'website_url': profile.websiteUrl,
        'is_public': profile.isPublic,
        'allow_friend_requests': profile.allowFriendRequests,
      };

      final response = await _dio.put('/api/v1/social/users/me/profile', data: data);
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // Get another user's profile
  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    try {
      final response = await _dio.get('/api/v1/social/users/$userId/profile');
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // Search for users
  Future<Map<String, dynamic>> searchUsers(String query, {int page = 1, int limit = 20}) async {
    try {
      final response = await _dio.get('/api/v1/social/users/search', queryParameters: {
        'q': query,
        'page': page,
        'limit': limit,
      });
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // Send connection request
  Future<Map<String, dynamic>> sendConnectionRequest(String userId, {String? message}) async {
    try {
      final data = message != null ? {'message': message} : <String, dynamic>{};
      final response = await _dio.post('/api/v1/social/users/$userId/connection-request', data: data);
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // Get connection requests
  Future<Map<String, dynamic>> getConnectionRequests(String type) async {
    try {
      final response = await _dio.get('/api/v1/social/users/me/connection-requests', queryParameters: {
        'type': type, // 'received' or 'sent'
      });
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // Respond to connection request
  Future<Map<String, dynamic>> respondToConnectionRequest(String requestId, String action) async {
    try {
      final data = {'action': action}; // 'accept' or 'decline'
      final response = await _dio.post('/api/v1/social/connection-requests/$requestId/respond', data: data);
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // Get user connections (friends)
  Future<Map<String, dynamic>> getUserConnections({int page = 1, int limit = 20}) async {
    try {
      final response = await _dio.get('/api/v1/social/users/me/connections', queryParameters: {
        'page': page,
        'limit': limit,
      });
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // Get activity feed
  Future<Map<String, dynamic>> getActivityFeed({int page = 1, int limit = 20}) async {
    try {
      final response = await _dio.get('/api/v1/social/users/me/activity-feed', queryParameters: {
        'page': page,
        'limit': limit,
      });
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // Handle successful response
  Map<String, dynamic> _handleResponse(Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      return {
        'success': true,
        'data': response.data,
      };
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
          return {
            'success': false,
            'error': data['error'] ?? {
              'message': 'Server error: ${error.response!.statusCode}',
              'status_code': error.response!.statusCode,
            },
          };
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