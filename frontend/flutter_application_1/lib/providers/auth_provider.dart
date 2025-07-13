import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
//import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../models/user_model.dart';
import '../services/api_service.dart';
import '../utils/app_constants.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  // final GoogleSignIn _googleSignIn = GoogleSignIn(
  //   scopes: ['email', 'profile'],
  // );

  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;

  // Getters
  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _token != null && _user != null;

  // Initialize auth state from storage
  Future<void> initializeAuth() async {
    _setLoading(true);
    try {
      _token = await _secureStorage.read(key: AppConstants.tokenKey);
      if (_token != null) {
        // Validate token and get user profile
        await _getUserProfile();
      }
    } catch (e) {
      debugPrint('Error initializing auth: $e');
      await logout();
    } finally {
      _setLoading(false);
    }
  }

  // Register with email and password
  Future<bool> register({
    required String username,
    required String email,
    required String password,
    String? firstName,
    String? lastName,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.register(
        username: username,
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );

      if (response['success'] == true) {
        _token = response['access_token'];
        _user = User.fromJson(response['user']);
        
        await _secureStorage.write(key: AppConstants.tokenKey, value: _token);
        notifyListeners();
        return true;
      } else {
        _setError(response['error']['message'] ?? 'Registration failed');
        return false;
      }
    } catch (e) {
      _setError('Registration failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Login with email and password
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.login(
        email: email,
        password: password,
      );

      if (response['success'] == true) {
        _token = response['access_token'];
        _user = User.fromJson(response['user']);
        
        await _secureStorage.write(key: AppConstants.tokenKey, value: _token);
        notifyListeners();
        return true;
      } else {
        _setError(response['error']['message'] ?? 'Login failed');
        return false;
      }
    } catch (e) {
      _setError('Login failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Google Sign In

  // Apple Sign In
  Future<bool> signInWithApple() async {
    _setLoading(true);
    _clearError();

    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final response = await _apiService.socialLogin(
        provider: 'apple',
        accessToken: credential.identityToken!,
        email: credential.email,
        firstName: credential.givenName,
        lastName: credential.familyName,
      );

      if (response['success'] == true) {
        _token = response['access_token'];
        _user = User.fromJson(response['user']);
        
        await _secureStorage.write(key: AppConstants.tokenKey, value: _token);
        notifyListeners();
        return true;
      } else {
        _setError(response['error']['message'] ?? 'Apple sign in failed');
        return false;
      }
    } catch (e) {
      _setError('Apple sign in failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Verify email
  Future<bool> verifyEmail(String token) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.verifyEmail(token);
      
      if (response['success'] == true) {
        // Update user email verification status
        if (_user != null) {
          _user = _user!.copyWith(emailVerified: true);
          notifyListeners();
        }
        return true;
      } else {
        _setError(response['error']['message'] ?? 'Email verification failed');
        return false;
      }
    } catch (e) {
      _setError('Email verification failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get user profile
  Future<void> _getUserProfile() async {
    try {
      final response = await _apiService.getUserProfile(_token!);
      
      if (response['success'] == true) {
        _user = User.fromJson(response['user']);
        notifyListeners();
      } else {
        // Token might be invalid
        await logout();
      }
    } catch (e) {
      debugPrint('Error getting user profile: $e');
      await logout();
    }
  }

  // Logout
  Future<void> logout() async {
    _setLoading(true);
    
    try {
      // Sign out from Google if signed in
      // if (await _googleSignIn.isSignedIn()) {
      //   await _googleSignIn.signOut();
      // }
      
      // Clear stored data
      await _secureStorage.delete(key: AppConstants.tokenKey);
      
      _user = null;
      _token = null;
      _clearError();
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error during logout: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Create test user
  Future<bool> createTestUser() async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.createTestUser();
      
      if (response['success'] == true) {
        _token = response['access_token'];
        // Create user from credentials
        final credentials = response['credentials'];
        _user = User(
          id: 'test-user',
          username: credentials['username'],
          email: credentials['email'],
          emailVerified: true,
          firstName: 'Test',
          lastName: 'User',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        await _secureStorage.write(key: AppConstants.tokenKey, value: _token);
        notifyListeners();
        return true;
      } else {
        _setError(response['error']['message'] ?? 'Test user creation failed');
        return false;
      }
    } catch (e) {
      _setError('Test user creation failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update user data
  void updateUser(User user) {
    _user = user;
    notifyListeners();
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }
} 