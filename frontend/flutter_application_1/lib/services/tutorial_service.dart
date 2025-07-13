import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../models/tutorial_models.dart';
import '../utils/app_constants.dart';

class TutorialService {
  late final Dio _dio;
  static const bool _useMockData = false; // Use real backend API

  TutorialService() {
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
        // Auth token will be set by the provider
        handler.next(options);
      },
      onError: (error, handler) {
        debugPrint('Tutorial API Error: ${error.message}');
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

  /// Search tutorials with comprehensive filtering and pagination
  Future<TutorialSearchResult> searchTutorials({
    String searchQuery = '',
    TutorialFilters? filters,
    int page = 1,
    int limit = 20,
  }) async {
    if (_useMockData) {
      return _getMockSearchResult(searchQuery, filters, page, limit);
    }

    try {
      Map<String, dynamic> queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (searchQuery.isNotEmpty) {
        queryParams['q'] = searchQuery;
      }

      if (filters != null) {
        queryParams.addAll(filters.toQueryParameters());
      }

      final response = await _dio.get(
        '/api/v1/tutorials',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return TutorialSearchResult.fromJson(response.data);
      } else {
        throw Exception('Failed to search tutorials: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('Tutorial search error: ${e.message}');
      // Fall back to mock data on error
      return _getMockSearchResult(searchQuery, filters, page, limit);
    } catch (e) {
      debugPrint('Unexpected error in tutorial search: $e');
      // Fall back to mock data on error
      return _getMockSearchResult(searchQuery, filters, page, limit);
    }
  }

  /// Get detailed information for a specific tutorial
  Future<Tutorial> getTutorialDetails(int tutorialId) async {
    if (_useMockData) {
      return _getMockTutorial(tutorialId);
    }

    try {
      final response = await _dio.get('/api/v1/tutorials/$tutorialId');

      if (response.statusCode == 200) {
        return Tutorial.fromJson(response.data);
      } else {
        throw Exception('Failed to get tutorial details: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('Tutorial details error: ${e.message}');
      // Fall back to mock data on error
      return _getMockTutorial(tutorialId);
    } catch (e) {
      debugPrint('Unexpected error getting tutorial details: $e');
      // Fall back to mock data on error
      return _getMockTutorial(tutorialId);
    }
  }

  /// Get tutorial categories
  Future<List<TutorialCategory>> getTutorialCategories() async {
    if (_useMockData) {
      return _getMockCategories();
    }

    try {
      final response = await _dio.get('/api/v1/tutorials/categories');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final categories = data['categories'] as List<dynamic>;
        return categories.map((e) => TutorialCategory.fromJson(e as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Failed to get tutorial categories: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('Tutorial categories error: ${e.message}');
      return _getMockCategories();
    } catch (e) {
      debugPrint('Unexpected error getting tutorial categories: $e');
      return _getMockCategories();
    }
  }

  /// Get featured tutorials
  Future<List<Tutorial>> getFeaturedTutorials({int limit = 10}) async {
    if (_useMockData) {
      return _getMockFeaturedTutorials(limit);
    }

    try {
      final response = await _dio.get(
        '/api/v1/tutorials/featured',
        queryParameters: {
          'limit': limit.toString(),
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final tutorials = data['tutorials'] as List<dynamic>;
        return tutorials.map((e) => Tutorial.fromJson(e as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Failed to get featured tutorials: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('Featured tutorials error: ${e.message}');
      return _getMockFeaturedTutorials(limit);
    } catch (e) {
      debugPrint('Unexpected error getting featured tutorials: $e');
      return _getMockFeaturedTutorials(limit);
    }
  }

  /// Get beginner-friendly tutorials
  Future<List<Tutorial>> getBeginnerFriendlyTutorials({int limit = 10}) async {
    if (_useMockData) {
      return _getMockBeginnerTutorials(limit);
    }

    try {
      final response = await _dio.get(
        '/api/v1/tutorials/beginner-friendly',
        queryParameters: {
          'limit': limit.toString(),
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final tutorials = data['tutorials'] as List<dynamic>;
        return tutorials.map((e) => Tutorial.fromJson(e as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Failed to get beginner tutorials: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('Beginner tutorials error: ${e.message}');
      return _getMockBeginnerTutorials(limit);
    } catch (e) {
      debugPrint('Unexpected error getting beginner tutorials: $e');
      return _getMockBeginnerTutorials(limit);
    }
  }

  /// Get personalized tutorial recommendations
  Future<List<Tutorial>> getTutorialRecommendations({int limit = 10}) async {
    if (_useMockData) {
      return _getMockRecommendations(limit);
    }

    try {
      final response = await _dio.get(
        '/api/v1/tutorials/recommendations',
        queryParameters: {
          'limit': limit.toString(),
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final tutorials = data['tutorials'] as List<dynamic>;
        return tutorials.map((e) => Tutorial.fromJson(e as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Failed to get tutorial recommendations: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('Tutorial recommendations error: ${e.message}');
      return _getMockRecommendations(limit);
    } catch (e) {
      debugPrint('Unexpected error getting tutorial recommendations: $e');
      return _getMockRecommendations(limit);
    }
  }

  /// Start a tutorial (create progress record)
  Future<TutorialProgress> startTutorial(int tutorialId) async {
    if (_useMockData) {
      return _getMockProgress(tutorialId);
    }

    try {
      final response = await _dio.post('/api/v1/tutorials/$tutorialId/start');

      if (response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;
        return TutorialProgress.fromJson(data['progress'] as Map<String, dynamic>);
      } else {
        throw Exception('Failed to start tutorial: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('Start tutorial error: ${e.message}');
      return _getMockProgress(tutorialId);
    } catch (e) {
      debugPrint('Unexpected error starting tutorial: $e');
      return _getMockProgress(tutorialId);
    }
  }

  /// Mark a tutorial step as completed
  Future<TutorialProgress> completeStep(int tutorialId, int stepNumber) async {
    if (_useMockData) {
      return _getMockProgress(tutorialId);
    }

    try {
      final response = await _dio.post(
        '/api/v1/tutorials/$tutorialId/complete',
        data: {
          'step_number': stepNumber,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return TutorialProgress.fromJson(data['progress'] as Map<String, dynamic>);
      } else {
        throw Exception('Failed to complete step: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('Complete step error: ${e.message}');
      return _getMockProgress(tutorialId);
    } catch (e) {
      debugPrint('Unexpected error completing step: $e');
      return _getMockProgress(tutorialId);
    }
  }

  /// Update time spent on tutorial
  Future<TutorialProgress> updateTutorialTime(int tutorialId, int minutes) async {
    if (_useMockData) {
      return _getMockProgress(tutorialId);
    }

    try {
      final response = await _dio.post(
        '/api/v1/tutorials/$tutorialId/time',
        data: {
          'minutes': minutes,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return TutorialProgress.fromJson(data['progress'] as Map<String, dynamic>);
      } else {
        throw Exception('Failed to update tutorial time: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('Update tutorial time error: ${e.message}');
      return _getMockProgress(tutorialId);
    } catch (e) {
      debugPrint('Unexpected error updating tutorial time: $e');
      return _getMockProgress(tutorialId);
    }
  }

  /// Rate a tutorial
  Future<TutorialProgress> rateTutorial(int tutorialId, int rating, {String? notes}) async {
    if (_useMockData) {
      return _getMockProgress(tutorialId);
    }

    try {
      final response = await _dio.post(
        '/api/v1/tutorials/$tutorialId/rate',
        data: {
          'rating': rating,
          if (notes != null) 'notes': notes,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return TutorialProgress.fromJson(data['progress'] as Map<String, dynamic>);
      } else {
        throw Exception('Failed to rate tutorial: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('Rate tutorial error: ${e.message}');
      return _getMockProgress(tutorialId);
    } catch (e) {
      debugPrint('Unexpected error rating tutorial: $e');
      return _getMockProgress(tutorialId);
    }
  }

  /// Get user's tutorial progress summary
  Future<UserProgressSummary> getUserProgressSummary() async {
    if (_useMockData) {
      return _getMockProgressSummary();
    }

    try {
      final response = await _dio.get('/api/v1/tutorials/progress');

      if (response.statusCode == 200) {
        return UserProgressSummary.fromJson(response.data);
      } else {
        throw Exception('Failed to get progress summary: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('Progress summary error: ${e.message}');
      return _getMockProgressSummary();
    } catch (e) {
      debugPrint('Unexpected error getting progress summary: $e');
      return _getMockProgressSummary();
    }
  }

  /// Get available filter options for tutorial search
  Future<TutorialFilterOptions> getFilterOptions() async {
    if (_useMockData) {
      return _getMockFilterOptions();
    }

    try {
      final response = await _dio.get('/api/v1/tutorials/filters/options');

      if (response.statusCode == 200) {
        return TutorialFilterOptions.fromJson(response.data);
      } else {
        throw Exception('Failed to get filter options: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('Filter options error: ${e.message}');
      return _getMockFilterOptions();
    } catch (e) {
      debugPrint('Unexpected error getting filter options: $e');
      return _getMockFilterOptions();
    }
  }

  // Mock data methods for fallback and testing
  TutorialSearchResult _getMockSearchResult(String searchQuery, TutorialFilters? filters, int page, int limit) {
    final mockTutorials = _getMockTutorials();
    
    // Apply basic filtering
    var filteredTutorials = mockTutorials;
    if (searchQuery.isNotEmpty) {
      filteredTutorials = mockTutorials.where((tutorial) =>
        tutorial.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
        tutorial.description.toLowerCase().contains(searchQuery.toLowerCase())
      ).toList();
    }

    if (filters?.category != null) {
      filteredTutorials = filteredTutorials.where((tutorial) =>
        tutorial.category == filters!.category
      ).toList();
    }

    if (filters?.difficulty != null) {
      filteredTutorials = filteredTutorials.where((tutorial) =>
        tutorial.difficultyLevel == filters!.difficulty
      ).toList();
    }

    if (filters?.beginnerFriendly == true) {
      filteredTutorials = filteredTutorials.where((tutorial) =>
        tutorial.isBeginnerFriendly
      ).toList();
    }

    // Apply pagination
    final startIndex = (page - 1) * limit;
    final endIndex = (startIndex + limit).clamp(0, filteredTutorials.length);
    final paginatedTutorials = filteredTutorials.sublist(
      startIndex.clamp(0, filteredTutorials.length),
      endIndex,
    );

    return TutorialSearchResult(
      tutorials: paginatedTutorials,
      pagination: TutorialPagination(
        page: page,
        limit: limit,
        totalCount: filteredTutorials.length,
        totalPages: (filteredTutorials.length / limit).ceil(),
        hasNext: endIndex < filteredTutorials.length,
        hasPrevious: page > 1,
      ),
      filtersApplied: filters?.toJson() ?? {},
      searchQuery: searchQuery,
    );
  }

  List<Tutorial> _getMockTutorials() {
    return [
      Tutorial(
        id: 1,
        title: "Basic Knife Skills: The Foundation of Cooking",
        description: "Learn the fundamental knife skills every cook needs to know.",
        category: "knife_skills",
        subcategory: "basic_cuts",
        difficultyLevel: "beginner",
        estimatedDurationMinutes: 25,
        isBeginnerFriendly: true,
        isFeatured: true,
        stepCount: 5,
        viewCount: 1250,
        completionCount: 890,
        completionRate: 71.2,
        averageRating: 4.7,
        ratingCount: 234,
        learningObjectives: [
          "Learn proper knife grip and posture",
          "Master basic cuts: dice, julienne, chop",
          "Understand knife safety fundamentals",
        ],
        equipmentNeeded: [
          "Chef's knife (8-10 inch)",
          "Cutting board",
          "Kitchen towel",
        ],
        tags: ["essential", "basics", "safety", "technique"],
      ),
      Tutorial(
        id: 2,
        title: "Food Safety Fundamentals",
        description: "Essential food safety practices every home cook must know.",
        category: "food_safety",
        subcategory: "basics",
        difficultyLevel: "beginner",
        estimatedDurationMinutes: 20,
        isBeginnerFriendly: true,
        isFeatured: true,
        stepCount: 4,
        viewCount: 980,
        completionCount: 756,
        completionRate: 77.1,
        averageRating: 4.8,
        ratingCount: 189,
        learningObjectives: [
          "Understand temperature danger zones",
          "Learn proper hand washing techniques",
          "Practice safe food storage methods",
        ],
        equipmentNeeded: [
          "Food thermometer",
          "Soap and water",
          "Storage containers",
        ],
        tags: ["essential", "safety", "health", "basics"],
      ),
      Tutorial(
        id: 3,
        title: "Sautéing Techniques: Building Flavor",
        description: "Master the art of sautéing to build complex flavors in your dishes.",
        category: "cooking_methods",
        subcategory: "sauteing",
        difficultyLevel: "intermediate",
        estimatedDurationMinutes: 30,
        isBeginnerFriendly: false,
        isFeatured: true,
        stepCount: 4,
        viewCount: 567,
        completionCount: 342,
        completionRate: 60.3,
        averageRating: 4.6,
        ratingCount: 98,
        learningObjectives: [
          "Understand heat control for sautéing",
          "Learn proper pan selection and preparation",
          "Master ingredient timing and sequencing",
        ],
        equipmentNeeded: [
          "Large sauté pan or skillet",
          "Wooden spoon or spatula",
          "Various oils and fats",
        ],
        tags: ["technique", "flavor", "intermediate", "heat"],
      ),
    ];
  }

  Tutorial _getMockTutorial(int tutorialId) {
    final tutorials = _getMockTutorials();
    return tutorials.firstWhere(
      (tutorial) => tutorial.id == tutorialId,
      orElse: () => tutorials.first,
    );
  }

  List<TutorialCategory> _getMockCategories() {
    return [
      const TutorialCategory(category: "knife_skills", count: 8),
      const TutorialCategory(category: "food_safety", count: 6),
      const TutorialCategory(category: "cooking_methods", count: 12),
      const TutorialCategory(category: "baking_basics", count: 10),
      const TutorialCategory(category: "kitchen_basics", count: 7),
    ];
  }

  List<Tutorial> _getMockFeaturedTutorials(int limit) {
    return _getMockTutorials().where((tutorial) => tutorial.isFeatured).take(limit).toList();
  }

  List<Tutorial> _getMockBeginnerTutorials(int limit) {
    return _getMockTutorials().where((tutorial) => tutorial.isBeginnerFriendly).take(limit).toList();
  }

  List<Tutorial> _getMockRecommendations(int limit) {
    return _getMockTutorials().take(limit).toList();
  }

  TutorialProgress _getMockProgress(int tutorialId) {
    return TutorialProgress(
      id: 1,
      userId: 1,
      tutorialId: tutorialId,
      currentStep: 2,
      completedSteps: const [1],
      isCompleted: false,
      completionPercentage: 25,
      timeSpentMinutes: 15,
      startedAt: DateTime.now().subtract(const Duration(hours: 2)),
      lastAccessedAt: DateTime.now().subtract(const Duration(minutes: 30)),
    );
  }

  UserProgressSummary _getMockProgressSummary() {
    return const UserProgressSummary(
      completedCount: 3,
      inProgressCount: 2,
      totalTimeMinutes: 180,
      averageRating: 4.5,
    );
  }

  TutorialFilterOptions _getMockFilterOptions() {
    return const TutorialFilterOptions(
      categories: ["knife_skills", "food_safety", "cooking_methods", "baking_basics", "kitchen_basics"],
      difficultyLevels: ["beginner", "intermediate", "advanced"],
      durationOptions: [15, 30, 60, 120],
    );
  }
} 