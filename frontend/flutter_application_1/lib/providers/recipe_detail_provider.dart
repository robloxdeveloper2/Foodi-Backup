import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/recipe_detail_models.dart';
import '../services/recipe_detail_service.dart';
import '../utils/local_storage_service.dart';

class RecipeDetailProvider extends ChangeNotifier {
  final RecipeDetailService _recipeService = RecipeDetailService();
  final LocalStorageService _localStorage = LocalStorageService();
  
  // Recipe state
  RecipeDetail? _recipe;
  bool _isLoading = false;
  bool _hasError = false;
  String? _error;
  
  // Scaling state
  double _currentScaleFactor = 1.0;
  bool _isScaling = false;
  Timer? _scaleDebouncer;
  
  // Cooking session state
  CookingSession? _currentSession;
  List<RecipeStep> _steps = [];
  
  // Getters
  RecipeDetail? get recipe => _recipe;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String? get error => _error;
  double get currentScaleFactor => _currentScaleFactor;
  bool get isScaling => _isScaling;
  CookingSession? get currentSession => _currentSession;
  List<RecipeStep> get steps => _steps;
  bool get isCookingSessionActive => _currentSession != null && _currentSession!.endTime == null;
  double get cookingProgress => _currentSession?.progressPercentage ?? 0.0;

  /// Load recipe details from API
  Future<void> loadRecipeDetails(String recipeId, String token) async {
    _setLoading(true);
    _clearError();
    
    try {
      // Load recipe details
      final recipeDetail = await _recipeService.getRecipeDetails(recipeId, token);
      
      if (recipeDetail == null) {
        _setError('Recipe not found');
        return;
      }
      
      _recipe = recipeDetail;
      _steps = recipeDetail.steps.map((step) => step.copyWith()).toList();
      _currentScaleFactor = 1.0;
      
      // Try to restore cooking session if exists
      await _restoreCookingSession(recipeId);
      
    } catch (e) {
      _setError('Failed to load recipe: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Scale recipe by the given factor
  Future<void> scaleRecipe(double scaleFactor, String token) async {
    if (_recipe == null || scaleFactor == _currentScaleFactor) return;
    
    _setScaling(true);
    
    // Debounce scaling requests
    _scaleDebouncer?.cancel();
    _scaleDebouncer = Timer(const Duration(milliseconds: 500), () async {
      try {
        final scaling = await _recipeService.scaleRecipe(
          _recipe!.baseRecipe.id,
          scaleFactor,
          token,
        );
        
        _currentScaleFactor = scaleFactor;
        _recipe = _recipe!.copyWithScale(scaleFactor);
        
      } catch (e) {
        _setError('Failed to scale recipe: ${e.toString()}');
      } finally {
        _setScaling(false);
      }
    });
  }

  /// Start a cooking session
  Future<void> startCookingSession() async {
    if (_recipe == null) return;
    
    final session = CookingSession(
      recipeId: _recipe!.baseRecipe.id,
      stepCompletions: List.filled(_steps.length, false),
      startTime: DateTime.now(),
    );
    
    _currentSession = session;
    await _saveCookingSession();
    notifyListeners();
  }

  /// Pause the current cooking session
  Future<void> pauseCookingSession() async {
    if (_currentSession == null) return;
    
    _currentSession = _currentSession!.copyWith(isPaused: true);
    await _saveCookingSession();
    notifyListeners();
  }

  /// Resume the current cooking session
  Future<void> resumeCookingSession() async {
    if (_currentSession == null) return;
    
    _currentSession = _currentSession!.copyWith(isPaused: false);
    await _saveCookingSession();
    notifyListeners();
  }

  /// End the current cooking session
  Future<void> endCookingSession() async {
    if (_currentSession == null) return;
    
    _currentSession = _currentSession!.copyWith(endTime: DateTime.now());
    await _localStorage.clearCookingSession(_currentSession!.recipeId);
    
    // Reset step completions
    _steps = _steps.map((step) => step.copyWith(isCompleted: false)).toList();
    _currentSession = null;
    
    notifyListeners();
  }

  /// Mark a step as completed
  Future<void> completeStep(int index) async {
    if (index < 0 || index >= _steps.length) return;
    
    _steps[index] = _steps[index].copyWith(isCompleted: true);
    
    if (_currentSession != null) {
      final newCompletions = List<bool>.from(_currentSession!.stepCompletions);
      if (index < newCompletions.length) {
        newCompletions[index] = true;
      }
      _currentSession = _currentSession!.copyWith(stepCompletions: newCompletions);
      await _saveCookingSession();
    }
    
    notifyListeners();
  }

  /// Mark a step as uncompleted
  Future<void> uncompleteStep(int index) async {
    if (index < 0 || index >= _steps.length) return;
    
    _steps[index] = _steps[index].copyWith(isCompleted: false);
    
    if (_currentSession != null) {
      final newCompletions = List<bool>.from(_currentSession!.stepCompletions);
      if (index < newCompletions.length) {
        newCompletions[index] = false;
      }
      _currentSession = _currentSession!.copyWith(stepCompletions: newCompletions);
      await _saveCookingSession();
    }
    
    notifyListeners();
  }

  /// Get shareable text for the recipe
  String getShareText() {
    if (_recipe == null) return '';
    return _recipeService.buildShareText(_recipe!);
  }

  /// Get equipment grouped by type
  Map<String, List<String>> getEquipmentByType() {
    if (_recipe == null) return {};
    return _recipeService.getEquipmentByType(_recipe!.equipmentNeeded);
  }

  /// Get cooking tips grouped by category
  Map<String, List<CookingTip>> getCookingTipsByCategory() {
    if (_recipe == null) return {};
    return _recipeService.getCookingTipsByCategory(_recipe!.cookingTips);
  }

  /// Restore cooking session from local storage
  Future<void> _restoreCookingSession(String recipeId) async {
    try {
      final sessionData = await _localStorage.getCookingSession(recipeId);
      if (sessionData != null) {
        _currentSession = CookingSession.fromJson(sessionData);
        
        // Restore step completions
        final completions = _currentSession!.stepCompletions;
        for (int i = 0; i < _steps.length && i < completions.length; i++) {
          _steps[i] = _steps[i].copyWith(isCompleted: completions[i]);
        }
      }
    } catch (e) {
      debugPrint('Failed to restore cooking session: $e');
    }
  }

  /// Save cooking session to local storage
  Future<void> _saveCookingSession() async {
    if (_currentSession == null) return;
    
    try {
      await _localStorage.saveCookingSession(
        _currentSession!.recipeId,
        _currentSession!.toJson(),
      );
    } catch (e) {
      debugPrint('Failed to save cooking session: $e');
    }
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set scaling state
  void _setScaling(bool scaling) {
    _isScaling = scaling;
    notifyListeners();
  }

  /// Set error state
  void _setError(String errorMessage) {
    _hasError = true;
    _error = errorMessage;
    notifyListeners();
  }

  /// Clear error state
  void _clearError() {
    _hasError = false;
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _scaleDebouncer?.cancel();
    super.dispose();
  }
} 