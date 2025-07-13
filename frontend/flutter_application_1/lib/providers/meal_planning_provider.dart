import 'package:flutter/foundation.dart';
import '../models/meal_plan.dart';
import '../services/meal_planning_service.dart';

class MealPlanningProvider with ChangeNotifier {
  final MealPlanningService _mealPlanningService;

  MealPlanningProvider(this._mealPlanningService);

  // Current state
  bool _isGenerating = false;
  bool _isLoading = false;
  String? _error;
  MealPlan? _currentMealPlan;
  List<MealPlanListItem> _mealPlanHistory = [];
  Map<String, dynamic>? _stats;
  
  // Currently selected/active meal plan for nutrition tracking etc.
  String? _selectedMealPlanId;

  // Getters
  bool get isGenerating => _isGenerating;
  bool get isLoading => _isLoading;
  String? get error => _error;
  MealPlan? get currentMealPlan => _currentMealPlan;
  List<MealPlanListItem> get mealPlanHistory => _mealPlanHistory;
  Map<String, dynamic>? get stats => _stats;
  bool get hasMealPlan => _currentMealPlan != null;
  String? get selectedMealPlanId => _selectedMealPlanId;
  bool get hasSelectedMealPlan => _selectedMealPlanId != null;
  
  // Get the currently selected meal plan from history
  MealPlanListItem? get selectedMealPlan {
    if (_selectedMealPlanId == null) return null;
    try {
      return _mealPlanHistory.firstWhere((plan) => plan.id == _selectedMealPlanId);
    } catch (e) {
      return null;
    }
  }

  // Set auth token
  void setAuthToken(String token) {
    _mealPlanningService.setAuthToken(token);
  }

  // Clear auth token
  void clearAuthToken() {
    _mealPlanningService.clearAuthToken();
  }

  // Generate a new meal plan
  Future<bool> generateMealPlan({
    required int durationDays,
    String? planDate,
    double? budgetUsd,
    bool includeSnacks = false,
    bool forceRegenerate = false,
  }) async {
    _isGenerating = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _mealPlanningService.generateMealPlan(
        durationDays: durationDays,
        planDate: planDate,
        budgetUsd: budgetUsd,
        includeSnacks: includeSnacks,
        forceRegenerate: forceRegenerate,
      );

      if (response['success'] == true) {
        _currentMealPlan = MealPlan.fromJson(response['meal_plan']);
        await _refreshMealPlanHistory(); // Refresh history to include new plan
        _isGenerating = false;
        notifyListeners();
        return true;
      } else {
        _error = response['error']?['message'] ?? 'Failed to generate meal plan';
        _isGenerating = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'An unexpected error occurred: ${e.toString()}';
      _isGenerating = false;
      notifyListeners();
      return false;
    }
  }

  // Get a specific meal plan
  Future<bool> getMealPlan(String planId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _mealPlanningService.getMealPlan(planId);

      if (response['success'] == true) {
        _currentMealPlan = MealPlan.fromJson(response['meal_plan']);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['error']?['message'] ?? 'Failed to load meal plan';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'An unexpected error occurred: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Regenerate current meal plan with feedback
  Future<bool> regenerateMealPlan({
    int? rating,
    String? feedback,
  }) async {
    if (_currentMealPlan == null) {
      _error = 'No meal plan to regenerate';
      notifyListeners();
      return false;
    }

    _isGenerating = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _mealPlanningService.regenerateMealPlan(
        _currentMealPlan!.id,
        rating: rating,
        feedback: feedback,
      );

      if (response['success'] == true) {
        _currentMealPlan = MealPlan.fromJson(response['meal_plan']);
        await _refreshMealPlanHistory(); // Refresh history
        _isGenerating = false;
        notifyListeners();
        return true;
      } else {
        _error = response['error']?['message'] ?? 'Failed to regenerate meal plan';
        _isGenerating = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'An unexpected error occurred: ${e.toString()}';
      _isGenerating = false;
      notifyListeners();
      return false;
    }
  }

  // Load meal plan history
  Future<bool> loadMealPlanHistory({int limit = 10, int offset = 0}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _mealPlanningService.getUserMealPlans(
        limit: limit,
        offset: offset,
      );

      if (response['success'] == true) {
        final mealPlansData = response['meal_plans'] as List<dynamic>;
        _mealPlanHistory = mealPlansData
            .map((data) => MealPlanListItem.fromJson(data as Map<String, dynamic>))
            .toList();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['error']?['message'] ?? 'Failed to load meal plan history';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'An unexpected error occurred: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Load statistics
  Future<bool> loadStats() async {
    try {
      final response = await _mealPlanningService.getMealPlanStats();

      if (response['success'] == true) {
        _stats = response['stats'];
        notifyListeners();
        return true;
      } else {
        debugPrint('Failed to load stats: ${response['error']?['message']}');
        return false;
      }
    } catch (e) {
      debugPrint('Error loading stats: ${e.toString()}');
      return false;
    }
  }

  // Get nutritional analysis for a meal plan
  Future<Map<String, dynamic>> getMealPlanAnalysis(String planId) async {
    try {
      final response = await _mealPlanningService.getMealPlanAnalysis(planId);
      return response;
    } catch (e) {
      return {
        'success': false,
        'error': {'message': 'An unexpected error occurred: ${e.toString()}'}
      };
    }
  }

  // Get weekly nutritional trends
  Future<Map<String, dynamic>> getWeeklyTrends({int weeks = 4}) async {
    try {
      final response = await _mealPlanningService.getWeeklyTrends(weeks: weeks);
      return response;
    } catch (e) {
      return {
        'success': false,
        'error': {'message': 'An unexpected error occurred: ${e.toString()}'}
      };
    }
  }

  // Get meal plan data (returns the response for direct use)
  Future<Map<String, dynamic>> getMealPlanData(String planId) async {
    try {
      final response = await _mealPlanningService.getMealPlan(planId);
      return response;
    } catch (e) {
      return {
        'success': false,
        'error': {'message': 'An unexpected error occurred: ${e.toString()}'}
      };
    }
  }

  // Refresh meal plan history (internal method)
  Future<void> _refreshMealPlanHistory() async {
    try {
      final response = await _mealPlanningService.getUserMealPlans(limit: 10);
      if (response['success'] == true) {
        final mealPlansData = response['meal_plans'] as List<dynamic>;
        _mealPlanHistory = mealPlansData
            .map((data) => MealPlanListItem.fromJson(data as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('Error refreshing meal plan history: ${e.toString()}');
    }
  }

  // Clear current meal plan
  void clearCurrentMealPlan() {
    _currentMealPlan = null;
    notifyListeners();
  }

  // Update current meal plan (used after substitutions)
  void updateCurrentMealPlan(MealPlan updatedMealPlan) {
    _currentMealPlan = updatedMealPlan;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Reset all state
  void reset() {
    _isGenerating = false;
    _isLoading = false;
    _error = null;
    _currentMealPlan = null;
    _mealPlanHistory = [];
    _stats = null;
    notifyListeners();
  }

  // Get meals for a specific day
  List<Meal> getMealsForDay(int day) {
    if (_currentMealPlan == null) return [];
    return _currentMealPlan!.getMealsForDay(day);
  }

  // Get nutrition for a specific day
  NutritionSummary? getNutritionForDay(int day) {
    if (_currentMealPlan == null) return null;
    return _currentMealPlan!.dailyNutritionBreakdown[day];
  }

  // Check if meal plan is within budget
  bool get isWithinBudget => _currentMealPlan?.isWithinBudget ?? true;

  // Get budget utilization percentage
  double get budgetUtilization {
    if (_currentMealPlan?.budgetTargetUsd == null) return 0.0;
    final target = _currentMealPlan!.budgetTargetUsd!;
    final actual = _currentMealPlan!.estimatedTotalCostUsd;
    return target > 0 ? (actual / target) * 100 : 0.0;
  }

  // Select a meal plan as the current active one
  void selectMealPlan(String planId) {
    _selectedMealPlanId = planId;
    notifyListeners();
  }

  // Auto-select the most recent meal plan
  void autoSelectRecentMealPlan() {
    if (_mealPlanHistory.isNotEmpty) {
      // Sort by creation date (most recent first) and select the first one
      final sortedPlans = List<MealPlanListItem>.from(_mealPlanHistory)
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _selectedMealPlanId = sortedPlans.first.id;
      notifyListeners();
    }
  }

  // Clear selected meal plan
  void clearSelectedMealPlan() {
    _selectedMealPlanId = null;
    notifyListeners();
  }

  // Get detailed meal plan for selected plan
  Future<MealPlan?> getSelectedMealPlanDetails() async {
    if (_selectedMealPlanId == null) return null;
    
    final success = await getMealPlan(_selectedMealPlanId!);
    return success ? _currentMealPlan : null;
  }

  // Load meal plan history and auto-select if none selected
  Future<bool> loadMealPlanHistoryWithAutoSelect({int limit = 10, int offset = 0}) async {
    final success = await loadMealPlanHistory(limit: limit, offset: offset);
    
    if (success && _selectedMealPlanId == null && _mealPlanHistory.isNotEmpty) {
      autoSelectRecentMealPlan();
    }
    
    return success;
  }
} 