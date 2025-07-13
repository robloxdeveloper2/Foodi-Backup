import 'package:dio/dio.dart';
import '../models/profile_models.dart';
import '../models/user_model.dart';
import '../utils/app_constants.dart';

class ProfileService {
  static final Dio _dio = Dio();
  static const String _baseUrl = AppConstants.baseUrl;

  static void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  static void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  /// Get predefined profile setup options
  static Future<ProfileSetupOptions> getProfileSetupData() async {
    try {
      final response = await _dio.get('$_baseUrl/api/v1/users/profile/setup-data');
      
      if (response.statusCode == 200) {
        final data = response.data['data'];
        return ProfileSetupOptions.fromJson(data);
      } else {
        throw Exception('Failed to get profile setup data: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final error = e.response!.data['error'];
        throw Exception(error['message'] ?? 'Failed to get profile setup data');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Submit comprehensive profile setup
  static Future<User> setupProfile(ProfileSetupData profileData) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/api/v1/users/profile/setup',
        data: profileData.toJson(),
      );
      
      if (response.statusCode == 200) {
        final userData = response.data['user'];
        return User.fromJson(userData);
      } else {
        throw Exception('Failed to setup profile: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final error = e.response!.data['error'];
        throw Exception(error['message'] ?? 'Failed to setup profile');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Get user's onboarding status
  static Future<OnboardingStatus> getOnboardingStatus() async {
    try {
      final response = await _dio.get('$_baseUrl/api/v1/users/onboarding/status');
      
      if (response.statusCode == 200) {
        final statusData = response.data['status'];
        return OnboardingStatus.fromJson(statusData);
      } else {
        throw Exception('Failed to get onboarding status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final error = e.response!.data['error'];
        throw Exception(error['message'] ?? 'Failed to get onboarding status');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Update user's current onboarding step
  static Future<void> updateOnboardingStep(int step) async {
    try {
      final response = await _dio.put(
        '$_baseUrl/api/v1/users/onboarding/step',
        data: {'step': step},
      );
      
      if (response.statusCode != 200) {
        throw Exception('Failed to update onboarding step: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final error = e.response!.data['error'];
        throw Exception(error['message'] ?? 'Failed to update onboarding step');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
} 