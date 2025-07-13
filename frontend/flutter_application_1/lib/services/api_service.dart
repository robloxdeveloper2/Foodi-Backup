import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../utils/app_constants.dart';

class ApiService {
  late final Dio _dio;

  ApiService() {
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
        // This will be handled by the AuthProvider
        handler.next(options);
      },
      onError: (error, handler) {
        debugPrint('API Error: ${error.message}');
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

  // Register user
  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    String? firstName,
    String? lastName,
  }) async {
    try {
      final response = await _dio.post(
        '/api/v1/users/register',
        data: {
          'username': username,
          'email': email,
          'password': password,
          if (firstName != null) 'first_name': firstName,
          if (lastName != null) 'last_name': lastName,
        },
      );

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // Login user
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/api/v1/users/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // Social login
  Future<Map<String, dynamic>> socialLogin({
    required String provider,
    required String accessToken,
    String? email,
    String? firstName,
    String? lastName,
  }) async {
    try {
      final response = await _dio.post(
        '/api/v1/users/social-login',
        data: {
          'provider': provider,
          'access_token': accessToken,
          if (email != null) 'email': email,
          if (firstName != null) 'first_name': firstName,
          if (lastName != null) 'last_name': lastName,
        },
      );

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // Verify email
  Future<Map<String, dynamic>> verifyEmail(String token) async {
    try {
      final response = await _dio.post(
        '/api/v1/users/verify-email',
        data: {
          'token': token,
        },
      );

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // Get user profile
  Future<Map<String, dynamic>> getUserProfile(String token) async {
    try {
      final response = await _dio.get(
        '/api/v1/users/profile',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // Create test user
  Future<Map<String, dynamic>> createTestUser() async {
    try {
      final response = await _dio.post('/api/v1/users/test-user');
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // Resend verification email
  Future<Map<String, dynamic>> resendVerificationEmail(String email) async {
    try {
      final response = await _dio.post(
        '/api/v1/users/resend-verification',
        data: {
          'email': email,
        },
      );

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // Reset password request
  Future<Map<String, dynamic>> requestPasswordReset(String email) async {
    try {
      final response = await _dio.post(
        '/api/v1/users/reset-password',
        data: {
          'email': email,
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