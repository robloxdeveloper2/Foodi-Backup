import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import '../utils/app_constants.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  bool _isDarkMode = false;
  String _languageCode = 'en';
  bool _notificationsEnabled = true;
  bool _isLoading = false;

  // Getters
  User? get user => _user;
  bool get isDarkMode => _isDarkMode;
  String get languageCode => _languageCode;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get isLoading => _isLoading;

  // Initialize user preferences from storage
  Future<void> initializePreferences() async {
    _setLoading(true);
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load theme preference
      _isDarkMode = prefs.getBool(AppConstants.themeKey) ?? false;
      
      // Load language preference
      _languageCode = prefs.getString(AppConstants.languageKey) ?? 'en';
      
      // Load notification preference
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing preferences: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Set user data
  void setUser(User? user) {
    _user = user;
    notifyListeners();
  }

  // Update user profile
  Future<void> updateUserProfile({
    String? firstName,
    String? lastName,
    String? profilePictureUrl,
  }) async {
    if (_user == null) return;

    _setLoading(true);
    try {
      _user = _user!.copyWith(
        firstName: firstName ?? _user!.firstName,
        lastName: lastName ?? _user!.lastName,
        profilePictureUrl: profilePictureUrl ?? _user!.profilePictureUrl,
        updatedAt: DateTime.now(),
      );
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating user profile: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Toggle theme mode
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.themeKey, _isDarkMode);
    } catch (e) {
      debugPrint('Error saving theme preference: $e');
    }
  }

  // Set theme mode
  Future<void> setThemeMode(bool isDark) async {
    if (_isDarkMode == isDark) return;
    
    _isDarkMode = isDark;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.themeKey, _isDarkMode);
    } catch (e) {
      debugPrint('Error saving theme preference: $e');
    }
  }

  // Set language
  Future<void> setLanguage(String languageCode) async {
    if (_languageCode == languageCode) return;
    
    _languageCode = languageCode;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.languageKey, _languageCode);
    } catch (e) {
      debugPrint('Error saving language preference: $e');
    }
  }

  // Toggle notifications
  Future<void> toggleNotifications() async {
    _notificationsEnabled = !_notificationsEnabled;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notifications_enabled', _notificationsEnabled);
    } catch (e) {
      debugPrint('Error saving notification preference: $e');
    }
  }

  // Set notifications enabled
  Future<void> setNotificationsEnabled(bool enabled) async {
    if (_notificationsEnabled == enabled) return;
    
    _notificationsEnabled = enabled;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notifications_enabled', _notificationsEnabled);
    } catch (e) {
      debugPrint('Error saving notification preference: $e');
    }
  }

  // Clear user data (on logout)
  Future<void> clearUserData() async {
    _user = null;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.userKey);
    } catch (e) {
      debugPrint('Error clearing user data: $e');
    }
  }

  // Reset all preferences to defaults
  Future<void> resetPreferences() async {
    _setLoading(true);
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Reset to defaults
      _isDarkMode = false;
      _languageCode = 'en';
      _notificationsEnabled = true;
      
      // Clear from storage
      await prefs.remove(AppConstants.themeKey);
      await prefs.remove(AppConstants.languageKey);
      await prefs.remove('notifications_enabled');
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error resetting preferences: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Get user display name
  String get userDisplayName {
    if (_user == null) return 'Guest';
    return _user!.displayName;
  }

  // Check if user email is verified
  bool get isEmailVerified {
    return _user?.emailVerified ?? false;
  }

  // Get user initials for avatar
  String get userInitials {
    if (_user == null) return 'G';
    
    final firstName = _user!.firstName;
    final lastName = _user!.lastName;
    
    if (firstName != null && lastName != null) {
      return '${firstName[0].toUpperCase()}${lastName[0].toUpperCase()}';
    } else if (firstName != null) {
      return firstName[0].toUpperCase();
    } else if (lastName != null) {
      return lastName[0].toUpperCase();
    } else {
      return _user!.username[0].toUpperCase();
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
} 