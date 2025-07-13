import 'package:flutter/foundation.dart';
import 'dart:async';

import '../models/tutorial_models.dart';
import '../services/tutorial_service.dart';

class TutorialProvider with ChangeNotifier {
  final TutorialService _tutorialService = TutorialService();

  // Search state
  List<Tutorial> _tutorials = [];
  TutorialPagination? _pagination;
  String _searchQuery = '';
  TutorialFilters _filters = TutorialFilters();
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;

  // Filter options
  TutorialFilterOptions? _filterOptions;
  bool _isLoadingFilterOptions = false;

  // Categories
  List<TutorialCategory> _categories = [];
  bool _isLoadingCategories = false;

  // Featured and recommendations
  List<Tutorial> _featuredTutorials = [];
  List<Tutorial> _beginnerTutorials = [];
  List<Tutorial> _recommendations = [];
  bool _isLoadingFeatured = false;
  bool _isLoadingBeginner = false;
  bool _isLoadingRecommendations = false;

  // Selected tutorial details
  Tutorial? _selectedTutorial;
  bool _isLoadingTutorialDetails = false;

  // Tutorial progress
  Map<int, TutorialProgress> _tutorialProgress = {};
  UserProgressSummary? _progressSummary;
  bool _isLoadingProgress = false;
  bool _isUpdatingProgress = false;

  // Getters
  List<Tutorial> get tutorials => _tutorials;
  TutorialPagination? get pagination => _pagination;
  String get searchQuery => _searchQuery;
  TutorialFilters get filters => _filters;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;

  TutorialFilterOptions? get filterOptions => _filterOptions;
  bool get isLoadingFilterOptions => _isLoadingFilterOptions;

  List<TutorialCategory> get categories => _categories;
  bool get isLoadingCategories => _isLoadingCategories;

  List<Tutorial> get featuredTutorials => _featuredTutorials;
  List<Tutorial> get beginnerTutorials => _beginnerTutorials;
  List<Tutorial> get recommendations => _recommendations;
  bool get isLoadingFeatured => _isLoadingFeatured;
  bool get isLoadingBeginner => _isLoadingBeginner;
  bool get isLoadingRecommendations => _isLoadingRecommendations;

  Tutorial? get selectedTutorial => _selectedTutorial;
  bool get isLoadingTutorialDetails => _isLoadingTutorialDetails;

  Map<int, TutorialProgress> get tutorialProgress => _tutorialProgress;
  UserProgressSummary? get progressSummary => _progressSummary;
  bool get isLoadingProgress => _isLoadingProgress;
  bool get isUpdatingProgress => _isUpdatingProgress;

  bool get hasActiveFilters => _filters.category != null || 
      _filters.difficulty != null || 
      _filters.durationMaxMinutes != null || 
      _filters.beginnerFriendly != null;
  bool get hasNextPage => _pagination?.hasNext ?? false;
  bool get hasPreviousPage => _pagination?.hasPrevious ?? false;

  // Set auth token
  void setAuthToken(String token) {
    _tutorialService.setAuthToken(token);
  }

  // Clear auth token
  void clearAuthToken() {
    _tutorialService.clearAuthToken();
  }

  /// Initialize the provider by loading initial data
  Future<void> initialize() async {
    await Future.wait([
      loadFilterOptions(),
      loadCategories(),
      loadFeaturedTutorials(),
      loadBeginnerTutorials(),
      loadRecommendations(),
      loadProgressSummary(),
      searchTutorials(resetPage: true), // Load all tutorials for the "All" tab
    ]);
  }

  /// Search tutorials with current filters and query
  Future<void> searchTutorials({bool resetPage = true}) async {
    if (resetPage) {
      _isLoading = true;
      _error = null;
      _tutorials.clear();
    } else {
      _isLoadingMore = true;
    }
    notifyListeners();

    try {
      final page = resetPage ? 1 : (_pagination?.page ?? 1) + 1;
      
      final result = await _tutorialService.searchTutorials(
        searchQuery: _searchQuery,
        filters: _filters,
        page: page,
        limit: 20,
      );

      if (resetPage) {
        _tutorials = result.tutorials;
      } else {
        _tutorials.addAll(result.tutorials);
      }
      
      _pagination = result.pagination;
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error searching tutorials: $e');
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Update search query and trigger search
  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
    searchTutorials(resetPage: true);
  }

  /// Update filters and trigger search
  void updateFilters(TutorialFilters newFilters) {
    _filters = newFilters;
    notifyListeners();
    searchTutorials(resetPage: true);
  }

  /// Clear all filters
  void clearFilters() {
    _filters = TutorialFilters();
    notifyListeners();
    searchTutorials(resetPage: true);
  }

  /// Load more tutorials (pagination)
  Future<void> loadMoreTutorials() async {
    if (!hasNextPage || _isLoadingMore) return;
    await searchTutorials(resetPage: false);
  }

  /// Load filter options from the API
  Future<void> loadFilterOptions() async {
    _isLoadingFilterOptions = true;
    notifyListeners();

    try {
      _filterOptions = await _tutorialService.getFilterOptions();
    } catch (e) {
      debugPrint('Error loading filter options: $e');
    } finally {
      _isLoadingFilterOptions = false;
      notifyListeners();
    }
  }

  /// Load tutorial categories
  Future<void> loadCategories() async {
    _isLoadingCategories = true;
    notifyListeners();

    try {
      _categories = await _tutorialService.getTutorialCategories();
    } catch (e) {
      debugPrint('Error loading categories: $e');
    } finally {
      _isLoadingCategories = false;
      notifyListeners();
    }
  }

  /// Load featured tutorials
  Future<void> loadFeaturedTutorials({int limit = 10}) async {
    _isLoadingFeatured = true;
    notifyListeners();

    try {
      _featuredTutorials = await _tutorialService.getFeaturedTutorials(limit: limit);
    } catch (e) {
      debugPrint('Error loading featured tutorials: $e');
    } finally {
      _isLoadingFeatured = false;
      notifyListeners();
    }
  }

  /// Load beginner-friendly tutorials
  Future<void> loadBeginnerTutorials({int limit = 10}) async {
    _isLoadingBeginner = true;
    notifyListeners();

    try {
      _beginnerTutorials = await _tutorialService.getBeginnerFriendlyTutorials(limit: limit);
    } catch (e) {
      debugPrint('Error loading beginner tutorials: $e');
    } finally {
      _isLoadingBeginner = false;
      notifyListeners();
    }
  }

  /// Load personalized recommendations
  Future<void> loadRecommendations({int limit = 10}) async {
    _isLoadingRecommendations = true;
    notifyListeners();

    try {
      _recommendations = await _tutorialService.getTutorialRecommendations(limit: limit);
    } catch (e) {
      debugPrint('Error loading recommendations: $e');
    } finally {
      _isLoadingRecommendations = false;
      notifyListeners();
    }
  }

  /// Get detailed information for a specific tutorial
  Future<void> loadTutorialDetails(int tutorialId) async {
    _isLoadingTutorialDetails = true;
    _selectedTutorial = null;
    notifyListeners();

    try {
      _selectedTutorial = await _tutorialService.getTutorialDetails(tutorialId);
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading tutorial details: $e');
    } finally {
      _isLoadingTutorialDetails = false;
      notifyListeners();
    }
  }

  /// Start a tutorial
  Future<bool> startTutorial(int tutorialId) async {
    _isUpdatingProgress = true;
    notifyListeners();

    try {
      final progress = await _tutorialService.startTutorial(tutorialId);
      _tutorialProgress[tutorialId] = progress;
      await loadProgressSummary(); // Refresh summary
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error starting tutorial: $e');
      return false;
    } finally {
      _isUpdatingProgress = false;
      notifyListeners();
    }
  }

  /// Complete a tutorial step
  Future<bool> completeStep(int tutorialId, int stepNumber) async {
    _isUpdatingProgress = true;
    notifyListeners();

    try {
      final progress = await _tutorialService.completeStep(tutorialId, stepNumber);
      _tutorialProgress[tutorialId] = progress;
      await loadProgressSummary(); // Refresh summary
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error completing step: $e');
      return false;
    } finally {
      _isUpdatingProgress = false;
      notifyListeners();
    }
  }

  /// Update time spent on tutorial
  Future<bool> updateTutorialTime(int tutorialId, int minutes) async {
    try {
      final progress = await _tutorialService.updateTutorialTime(tutorialId, minutes);
      _tutorialProgress[tutorialId] = progress;
      await loadProgressSummary(); // Refresh summary
      return true;
    } catch (e) {
      debugPrint('Error updating tutorial time: $e');
      return false;
    }
  }

  /// Rate a tutorial
  Future<bool> rateTutorial(int tutorialId, int rating, {String? notes}) async {
    _isUpdatingProgress = true;
    notifyListeners();

    try {
      final progress = await _tutorialService.rateTutorial(tutorialId, rating, notes: notes);
      _tutorialProgress[tutorialId] = progress;
      await loadProgressSummary(); // Refresh summary
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error rating tutorial: $e');
      return false;
    } finally {
      _isUpdatingProgress = false;
      notifyListeners();
    }
  }

  /// Load user's progress summary
  Future<void> loadProgressSummary() async {
    _isLoadingProgress = true;
    notifyListeners();

    try {
      _progressSummary = await _tutorialService.getUserProgressSummary();
    } catch (e) {
      debugPrint('Error loading progress summary: $e');
    } finally {
      _isLoadingProgress = false;
      notifyListeners();
    }
  }

  /// Get progress for a specific tutorial
  TutorialProgress? getTutorialProgress(int tutorialId) {
    return _tutorialProgress[tutorialId];
  }

  /// Check if a tutorial is started
  bool isTutorialStarted(int tutorialId) {
    return _tutorialProgress.containsKey(tutorialId);
  }

  /// Check if a tutorial is completed
  bool isTutorialCompleted(int tutorialId) {
    final progress = _tutorialProgress[tutorialId];
    return progress?.isCompleted ?? false;
  }

  /// Get completion percentage for a tutorial
  double getTutorialCompletionPercentage(int tutorialId) {
    final progress = _tutorialProgress[tutorialId];
    return (progress?.completionPercentage ?? 0).toDouble();
  }

  /// Clear error state
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Reset selected tutorial
  void clearSelectedTutorial() {
    _selectedTutorial = null;
    notifyListeners();
  }

  /// Refresh all data
  Future<void> refresh() async {
    await initialize();
    if (_searchQuery.isNotEmpty || hasActiveFilters) {
      await searchTutorials(resetPage: true);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
} 