import 'package:flutter/material.dart';

import '../models/meal_suggestion.dart';
import '../services/preference_learning_service.dart';

class MealSwipingProvider with ChangeNotifier {
  final PreferenceLearningService _preferenceLearningService;

  MealSwipingProvider(this._preferenceLearningService);

  // State variables
  List<MealSuggestion> _suggestions = [];
  bool _isLoading = false;
  String? _error;
  int _currentIndex = 0;
  Map<String, String> _swipeHistory = {}; // recipe_id -> action
  Map<String, double> _ratingHistory = {}; // recipe_id -> rating
  bool _isSubmittingFeedback = false;

  // Getters
  List<MealSuggestion> get suggestions => _suggestions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentIndex => _currentIndex;
  Map<String, String> get swipeHistory => _swipeHistory;
  Map<String, double> get ratingHistory => _ratingHistory;
  bool get isSubmittingFeedback => _isSubmittingFeedback;
  bool get hasMoreSuggestions => _currentIndex < _suggestions.length;
  MealSuggestion? get currentSuggestion => 
      hasMoreSuggestions ? _suggestions[_currentIndex] : null;
  int get remainingCount => _suggestions.length - _currentIndex;
  int get swipedCount => _currentIndex;

  // Load meal suggestions
  Future<void> loadMealSuggestions({int sessionLength = 20}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _suggestions = await _preferenceLearningService.getMealSuggestions(
        sessionLength: sessionLength,
      );
      _currentIndex = 0;
      _swipeHistory.clear();
      _ratingHistory.clear();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Record swipe action
  Future<void> recordSwipe(String action) async {
    if (!hasMoreSuggestions) return;

    final suggestion = _suggestions[_currentIndex];
    
    _isSubmittingFeedback = true;
    notifyListeners();

    try {
      await _preferenceLearningService.recordSwipeFeedback(suggestion.id, action);
      
      // Update local state
      _swipeHistory[suggestion.id] = action;
      _currentIndex++;
      
    } catch (e) {
      _error = e.toString();
    } finally {
      _isSubmittingFeedback = false;
      notifyListeners();
    }
  }

  // Swipe left (dislike)
  Future<void> swipeLeft() async {
    await recordSwipe('dislike');
  }

  // Swipe right (like)
  Future<void> swipeRight() async {
    await recordSwipe('like');
  }

  // Set recipe rating
  Future<void> setRecipeRating(String recipeId, double rating) async {
    _isSubmittingFeedback = true;
    notifyListeners();

    try {
      await _preferenceLearningService.setRecipeRating(recipeId, rating);
      _ratingHistory[recipeId] = rating;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isSubmittingFeedback = false;
      notifyListeners();
    }
  }

  // Update ingredient preference
  Future<void> updateIngredientPreference(String ingredient, String preference) async {
    try {
      await _preferenceLearningService.updateIngredientPreference(ingredient, preference);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Set cuisine preference
  Future<void> setCuisinePreference(String cuisine, int rating) async {
    try {
      await _preferenceLearningService.setCuisinePreference(cuisine, rating);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Get preference statistics
  Future<Map<String, dynamic>?> getPreferenceStats() async {
    try {
      return await _preferenceLearningService.getPreferenceStats();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Reset session
  void resetSession() {
    _suggestions.clear();
    _currentIndex = 0;
    _swipeHistory.clear();
    _ratingHistory.clear();
    _error = null;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Go to previous suggestion (undo)
  void goToPrevious() {
    if (_currentIndex > 0) {
      _currentIndex--;
      notifyListeners();
    }
  }

  // Skip current suggestion
  void skipCurrent() {
    if (hasMoreSuggestions) {
      _currentIndex++;
      notifyListeners();
    }
  }

  // Get swipe action for a recipe
  String? getSwipeAction(String recipeId) {
    return _swipeHistory[recipeId];
  }

  // Get rating for a recipe
  double? getRating(String recipeId) {
    return _ratingHistory[recipeId];
  }

  // Check if recipe has been swiped
  bool hasBeenSwiped(String recipeId) {
    return _swipeHistory.containsKey(recipeId);
  }

  // Check if recipe has been rated
  bool hasBeenRated(String recipeId) {
    return _ratingHistory.containsKey(recipeId);
  }

  // Get session progress (0.0 to 1.0)
  double get sessionProgress {
    if (_suggestions.isEmpty) return 0.0;
    return _currentIndex / _suggestions.length;
  }

  // Get session summary
  Map<String, int> get sessionSummary {
    int likes = 0;
    int dislikes = 0;
    int ratings = 0;

    for (String action in _swipeHistory.values) {
      if (action == 'like') likes++;
      if (action == 'dislike') dislikes++;
    }

    ratings = _ratingHistory.length;

    return {
      'likes': likes,
      'dislikes': dislikes,
      'ratings': ratings,
      'total_swiped': _swipeHistory.length,
    };
  }
} 