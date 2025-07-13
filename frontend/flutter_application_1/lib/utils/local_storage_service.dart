import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _cookingSessionPrefix = 'cooking_session_';

  /// Save cooking session for a recipe
  Future<void> saveCookingSession(String recipeId, Map<String, dynamic> sessionData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_cookingSessionPrefix$recipeId';
      final jsonString = json.encode(sessionData);
      await prefs.setString(key, jsonString);
    } catch (e) {
      throw Exception('Failed to save cooking session: $e');
    }
  }

  /// Get cooking session for a recipe
  Future<Map<String, dynamic>?> getCookingSession(String recipeId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_cookingSessionPrefix$recipeId';
      final jsonString = prefs.getString(key);
      
      if (jsonString != null) {
        return json.decode(jsonString) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get cooking session: $e');
    }
  }

  /// Clear cooking session for a recipe
  Future<void> clearCookingSession(String recipeId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_cookingSessionPrefix$recipeId';
      await prefs.remove(key);
    } catch (e) {
      throw Exception('Failed to clear cooking session: $e');
    }
  }

  /// Get all cooking sessions
  Future<Map<String, Map<String, dynamic>>> getAllCookingSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => key.startsWith(_cookingSessionPrefix));
      final sessions = <String, Map<String, dynamic>>{};
      
      for (final key in keys) {
        final recipeId = key.substring(_cookingSessionPrefix.length);
        final jsonString = prefs.getString(key);
        if (jsonString != null) {
          sessions[recipeId] = json.decode(jsonString) as Map<String, dynamic>;
        }
      }
      
      return sessions;
    } catch (e) {
      throw Exception('Failed to get all cooking sessions: $e');
    }
  }

  /// Clear all cooking sessions
  Future<void> clearAllCookingSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => key.startsWith(_cookingSessionPrefix));
      
      for (final key in keys) {
        await prefs.remove(key);
      }
    } catch (e) {
      throw Exception('Failed to clear all cooking sessions: $e');
    }
  }
} 