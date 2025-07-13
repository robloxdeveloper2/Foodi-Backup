import 'package:flutter/foundation.dart';
import '../models/meal_substitution.dart';
import '../models/meal_plan.dart';
import '../services/meal_substitution_service.dart';

class MealSubstitutionProvider with ChangeNotifier {
  final MealSubstitutionService _substitutionService;

  MealSubstitutionProvider(this._substitutionService);

  // Current state
  bool _isLoading = false;
  bool _isApplying = false;
  String? _error;
  SubstitutionResponse? _currentSubstitutes;
  Map<String, dynamic>? _previewData;
  SubstitutionHistory? _substitutionHistory;
  bool _canUndo = false;

  // Getters
  bool get isLoading => _isLoading;
  bool get isApplying => _isApplying;
  String? get error => _error;
  SubstitutionResponse? get currentSubstitutes => _currentSubstitutes;
  Map<String, dynamic>? get previewData => _previewData;
  SubstitutionHistory? get substitutionHistory => _substitutionHistory;
  bool get canUndo => _canUndo;
  bool get hasSubstitutes => _currentSubstitutes?.hasAlternatives ?? false;

  // Set auth token
  void setAuthToken(String token) {
    _substitutionService.setAuthToken(token);
  }

  // Clear current state
  void clearState() {
    _currentSubstitutes = null;
    _previewData = null;
    _substitutionHistory = null;
    _canUndo = false;
    _error = null;
    notifyListeners();
  }

  // Load substitute options for a meal
  /// AC 2.4.2: System suggests 3-5 alternative meals using smart matching algorithm
  Future<bool> loadSubstituteOptions({
    required String mealPlanId,
    required int mealIndex,
    int maxAlternatives = 5,
    double nutritionalTolerance = 0.15,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _substitutionService.getSubstitutes(
        mealPlanId: mealPlanId,
        mealIndex: mealIndex,
        maxAlternatives: maxAlternatives,
        nutritionalTolerance: nutritionalTolerance,
      );

      _currentSubstitutes = response;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to load substitute options: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Preview substitution impact
  /// AC 2.4.7: User can preview and confirm substitution before applying
  /// AC 2.4.5: System shows impact of substitution on daily/weekly nutritional goals
  Future<bool> previewSubstitution({
    required String mealPlanId,
    required int mealIndex,
    required String newRecipeId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _substitutionService.previewSubstitution(
        mealPlanId: mealPlanId,
        mealIndex: mealIndex,
        newRecipeId: newRecipeId,
      );

      _previewData = response;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to preview substitution: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Apply a meal substitution
  /// AC 2.4.7: User can preview and confirm substitution before applying
  Future<MealPlan?> applySubstitution({
    required String mealPlanId,
    required int mealIndex,
    required String newRecipeId,
  }) async {
    _isApplying = true;
    _error = null;
    notifyListeners();

    try {
      final updatedMealPlan = await _substitutionService.applySubstitution(
        mealPlanId: mealPlanId,
        mealIndex: mealIndex,
        newRecipeId: newRecipeId,
      );

      // Refresh substitution history and undo status
      await _refreshSubstitutionStatus(mealPlanId);

      _isApplying = false;
      notifyListeners();
      return updatedMealPlan;
    } catch (e) {
      _error = 'Failed to apply substitution: ${e.toString()}';
      _isApplying = false;
      notifyListeners();
      return null;
    }
  }

  // Undo the most recent substitution
  /// AC 2.4.8: User can undo recent substitutions
  Future<MealPlan?> undoSubstitution({
    required String mealPlanId,
  }) async {
    _isApplying = true;
    _error = null;
    notifyListeners();

    try {
      final updatedMealPlan = await _substitutionService.undoSubstitution(
        mealPlanId: mealPlanId,
      );

      // Refresh substitution history and undo status
      await _refreshSubstitutionStatus(mealPlanId);

      _isApplying = false;
      notifyListeners();
      return updatedMealPlan;
    } catch (e) {
      _error = 'Failed to undo substitution: ${e.toString()}';
      _isApplying = false;
      notifyListeners();
      return null;
    }
  }

  // Load substitution history
  Future<bool> loadSubstitutionHistory({
    required String mealPlanId,
  }) async {
    try {
      final history = await _substitutionService.getSubstitutionHistory(
        mealPlanId: mealPlanId,
      );

      _substitutionHistory = history;
      _canUndo = history.canUndo;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Failed to load substitution history: ${e.toString()}');
      return false;
    }
  }

  // Check if undo is available
  Future<bool> checkCanUndo({
    required String mealPlanId,
  }) async {
    try {
      final canUndo = await _substitutionService.canUndoSubstitution(
        mealPlanId: mealPlanId,
      );

      _canUndo = canUndo;
      notifyListeners();
      return canUndo;
    } catch (e) {
      debugPrint('Failed to check undo status: ${e.toString()}');
      return false;
    }
  }

  // Get substitution analytics
  Future<Map<String, dynamic>?> getSubstitutionAnalytics({
    required String mealPlanId,
  }) async {
    try {
      return await _substitutionService.getSubstitutionAnalytics(
        mealPlanId: mealPlanId,
      );
    } catch (e) {
      debugPrint('Failed to get substitution analytics: ${e.toString()}');
      return null;
    }
  }

  // Helper method to refresh substitution status
  Future<void> _refreshSubstitutionStatus(String mealPlanId) async {
    await loadSubstitutionHistory(mealPlanId: mealPlanId);
    await checkCanUndo(mealPlanId: mealPlanId);
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Get substitute by recipe ID
  SubstitutionCandidate? getSubstituteByRecipeId(String recipeId) {
    if (_currentSubstitutes == null) return null;
    
    try {
      return _currentSubstitutes!.alternatives
          .firstWhere((candidate) => candidate.recipeId == recipeId);
    } catch (e) {
      return null;
    }
  }

  // Get top scoring substitutes
  List<SubstitutionCandidate> getTopSubstitutes({int limit = 3}) {
    if (_currentSubstitutes == null) return [];
    
    final sorted = List<SubstitutionCandidate>.from(_currentSubstitutes!.alternatives)
      ..sort((a, b) => b.totalScore.compareTo(a.totalScore));
    
    return sorted.take(limit).toList();
  }

  // Get substitutes by score grade
  Map<String, List<SubstitutionCandidate>> getSubstitutesByGrade() {
    if (_currentSubstitutes == null) return {};
    
    final Map<String, List<SubstitutionCandidate>> gradeMap = {
      'A': [],
      'B': [],
      'C': [],
      'D': [],
    };
    
    for (final candidate in _currentSubstitutes!.alternatives) {
      gradeMap[candidate.scoreGrade]?.add(candidate);
    }
    
    return gradeMap;
  }

  // Get nutritional impact summary
  Map<String, dynamic>? getNutritionalImpactSummary() {
    if (_previewData == null) return null;
    
    final impact = _previewData!['substitution_impact'];
    if (impact == null) return null;
    
    return {
      'calorie_change': impact['changes']['calories'] ?? 0.0,
      'protein_change': impact['changes']['protein'] ?? 0.0,
      'cost_change': impact['cost_change_usd'] ?? 0.0,
      'impact_level': impact['impact_level'] ?? 'minimal',
      'impact_description': _getImpactDescription(impact['impact_level']),
    };
  }

  String _getImpactDescription(String? impactLevel) {
    switch (impactLevel) {
      case 'significant':
        return 'Significant nutritional change';
      case 'moderate':
        return 'Moderate nutritional change';
      case 'minimal':
      default:
        return 'Minimal nutritional change';
    }
  }
} 