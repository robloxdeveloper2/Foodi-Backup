class Tutorial {
  final int id;
  final String title;
  final String description;
  final String category;
  final String? subcategory;
  final String difficultyLevel;
  final int estimatedDurationMinutes;
  final String? skillLevelRequired;
  final String? thumbnailUrl;
  final String? videoUrl;
  final List<String> learningObjectives;
  final List<String> prerequisites;
  final List<String> equipmentNeeded;
  final List<String> tags;
  final List<String> keywords;
  final bool isBeginnerFriendly;
  final bool isFeatured;
  final bool isActive;
  final int stepCount;
  final int viewCount;
  final int completionCount;
  final double completionRate;
  final double? averageRating;
  final int ratingCount;
  final List<TutorialStep>? steps;
  final TutorialProgress? userProgress;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Tutorial({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.subcategory,
    required this.difficultyLevel,
    required this.estimatedDurationMinutes,
    this.skillLevelRequired,
    this.thumbnailUrl,
    this.videoUrl,
    this.learningObjectives = const [],
    this.prerequisites = const [],
    this.equipmentNeeded = const [],
    this.tags = const [],
    this.keywords = const [],
    this.isBeginnerFriendly = false,
    this.isFeatured = false,
    this.isActive = true,
    this.stepCount = 0,
    this.viewCount = 0,
    this.completionCount = 0,
    this.completionRate = 0.0,
    this.averageRating,
    this.ratingCount = 0,
    this.steps,
    this.userProgress,
    this.createdAt,
    this.updatedAt,
  });

  factory Tutorial.fromJson(Map<String, dynamic> json) {
    return Tutorial(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      subcategory: json['subcategory'] as String?,
      difficultyLevel: json['difficulty_level'] as String,
      estimatedDurationMinutes: json['estimated_duration_minutes'] as int,
      skillLevelRequired: json['skill_level_required'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      videoUrl: json['video_url'] as String?,
      learningObjectives: (json['learning_objectives'] as List<dynamic>?)?.cast<String>() ?? [],
      prerequisites: (json['prerequisites'] as List<dynamic>?)?.cast<String>() ?? [],
      equipmentNeeded: (json['equipment_needed'] as List<dynamic>?)?.cast<String>() ?? [],
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      keywords: (json['keywords'] as List<dynamic>?)?.cast<String>() ?? [],
      isBeginnerFriendly: json['is_beginner_friendly'] as bool? ?? false,
      isFeatured: json['is_featured'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      stepCount: json['step_count'] as int? ?? 0,
      viewCount: json['view_count'] as int? ?? 0,
      completionCount: json['completion_count'] as int? ?? 0,
      completionRate: (json['completion_rate'] as num?)?.toDouble() ?? 0.0,
      averageRating: (json['average_rating'] as num?)?.toDouble(),
      ratingCount: json['rating_count'] as int? ?? 0,
      steps: (json['steps'] as List<dynamic>?)?.map((e) => TutorialStep.fromJson(e as Map<String, dynamic>)).toList(),
      userProgress: json['user_progress'] != null ? TutorialProgress.fromJson(json['user_progress'] as Map<String, dynamic>) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'subcategory': subcategory,
      'difficulty_level': difficultyLevel,
      'estimated_duration_minutes': estimatedDurationMinutes,
      'skill_level_required': skillLevelRequired,
      'thumbnail_url': thumbnailUrl,
      'video_url': videoUrl,
      'learning_objectives': learningObjectives,
      'prerequisites': prerequisites,
      'equipment_needed': equipmentNeeded,
      'tags': tags,
      'keywords': keywords,
      'is_beginner_friendly': isBeginnerFriendly,
      'is_featured': isFeatured,
      'is_active': isActive,
      'step_count': stepCount,
      'view_count': viewCount,
      'completion_count': completionCount,
      'completion_rate': completionRate,
      'average_rating': averageRating,
      'rating_count': ratingCount,
      'steps': steps?.map((e) => e.toJson()).toList(),
      'user_progress': userProgress?.toJson(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

class TutorialStep {
  final int step;
  final String title;
  final String description;
  final String? imageUrl;
  final String? videoUrl;
  final int? durationMinutes;
  final String? tips;

  const TutorialStep({
    required this.step,
    required this.title,
    required this.description,
    this.imageUrl,
    this.videoUrl,
    this.durationMinutes,
    this.tips,
  });

  factory TutorialStep.fromJson(Map<String, dynamic> json) {
    return TutorialStep(
      step: json['step'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['image_url'] as String?,
      videoUrl: json['video_url'] as String?,
      durationMinutes: json['duration_minutes'] as int?,
      tips: json['tips'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'step': step,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'video_url': videoUrl,
      'duration_minutes': durationMinutes,
      'tips': tips,
    };
  }
}

class TutorialProgress {
  final int id;
  final int userId;
  final int tutorialId;
  final int currentStep;
  final List<int> completedSteps;
  final bool isCompleted;
  final int completionPercentage;
  final int timeSpentMinutes;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? lastAccessedAt;
  final int? userRating;
  final String? userNotes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const TutorialProgress({
    required this.id,
    required this.userId,
    required this.tutorialId,
    this.currentStep = 1,
    this.completedSteps = const [],
    this.isCompleted = false,
    this.completionPercentage = 0,
    this.timeSpentMinutes = 0,
    this.startedAt,
    this.completedAt,
    this.lastAccessedAt,
    this.userRating,
    this.userNotes,
    this.createdAt,
    this.updatedAt,
  });

  factory TutorialProgress.fromJson(Map<String, dynamic> json) {
    return TutorialProgress(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      tutorialId: json['tutorial_id'] as int,
      currentStep: json['current_step'] as int? ?? 1,
      completedSteps: (json['completed_steps'] as List<dynamic>?)?.cast<int>() ?? [],
      isCompleted: json['is_completed'] as bool? ?? false,
      completionPercentage: json['completion_percentage'] as int? ?? 0,
      timeSpentMinutes: json['time_spent_minutes'] as int? ?? 0,
      startedAt: json['started_at'] != null ? DateTime.parse(json['started_at'] as String) : null,
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at'] as String) : null,
      lastAccessedAt: json['last_accessed_at'] != null ? DateTime.parse(json['last_accessed_at'] as String) : null,
      userRating: json['user_rating'] as int?,
      userNotes: json['user_notes'] as String?,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'tutorial_id': tutorialId,
      'current_step': currentStep,
      'completed_steps': completedSteps,
      'is_completed': isCompleted,
      'completion_percentage': completionPercentage,
      'time_spent_minutes': timeSpentMinutes,
      'started_at': startedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'last_accessed_at': lastAccessedAt?.toIso8601String(),
      'user_rating': userRating,
      'user_notes': userNotes,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

class TutorialCategory {
  final String category;
  final int count;

  const TutorialCategory({
    required this.category,
    required this.count,
  });

  factory TutorialCategory.fromJson(Map<String, dynamic> json) {
    return TutorialCategory(
      category: json['category'] as String,
      count: json['count'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'count': count,
    };
  }
}

class TutorialSearchResult {
  final List<Tutorial> tutorials;
  final TutorialPagination pagination;
  final Map<String, dynamic> filtersApplied;
  final String searchQuery;

  const TutorialSearchResult({
    required this.tutorials,
    required this.pagination,
    required this.filtersApplied,
    required this.searchQuery,
  });

  factory TutorialSearchResult.fromJson(Map<String, dynamic> json) {
    return TutorialSearchResult(
      tutorials: (json['tutorials'] as List<dynamic>).map((e) => Tutorial.fromJson(e as Map<String, dynamic>)).toList(),
      pagination: TutorialPagination.fromJson(json['pagination'] as Map<String, dynamic>),
      filtersApplied: json['filters_applied'] as Map<String, dynamic>,
      searchQuery: json['search_query'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tutorials': tutorials.map((e) => e.toJson()).toList(),
      'pagination': pagination.toJson(),
      'filters_applied': filtersApplied,
      'search_query': searchQuery,
    };
  }
}

class TutorialPagination {
  final int page;
  final int limit;
  final int totalCount;
  final int totalPages;
  final bool hasNext;
  final bool hasPrevious;

  const TutorialPagination({
    required this.page,
    required this.limit,
    required this.totalCount,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrevious,
  });

  factory TutorialPagination.fromJson(Map<String, dynamic> json) {
    return TutorialPagination(
      page: json['page'] as int,
      limit: json['limit'] as int,
      totalCount: json['total_count'] as int,
      totalPages: json['total_pages'] as int,
      hasNext: json['has_next'] as bool,
      hasPrevious: json['has_previous'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'limit': limit,
      'total_count': totalCount,
      'total_pages': totalPages,
      'has_next': hasNext,
      'has_previous': hasPrevious,
    };
  }
}

class TutorialFilters {
  final String? category;
  final String? difficulty;
  final int? durationMaxMinutes;
  final bool? beginnerFriendly;

  const TutorialFilters({
    this.category,
    this.difficulty,
    this.durationMaxMinutes,
    this.beginnerFriendly,
  });

  factory TutorialFilters.fromJson(Map<String, dynamic> json) {
    return TutorialFilters(
      category: json['category'] as String?,
      difficulty: json['difficulty'] as String?,
      durationMaxMinutes: json['duration_max_minutes'] as int?,
      beginnerFriendly: json['beginner_friendly'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'difficulty': difficulty,
      'duration_max_minutes': durationMaxMinutes,
      'beginner_friendly': beginnerFriendly,
    };
  }

  Map<String, dynamic> toQueryParameters() {
    final Map<String, dynamic> params = {};
    
    if (category != null) params['category'] = category;
    if (difficulty != null) params['difficulty'] = difficulty;
    if (durationMaxMinutes != null) params['duration_max_minutes'] = durationMaxMinutes.toString();
    if (beginnerFriendly != null) params['beginner_friendly'] = beginnerFriendly.toString();
    
    return params;
  }
}

class TutorialFilterOptions {
  final List<String> categories;
  final List<String> difficultyLevels;
  final List<int> durationOptions;

  const TutorialFilterOptions({
    this.categories = const [],
    this.difficultyLevels = const [],
    this.durationOptions = const [],
  });

  factory TutorialFilterOptions.fromJson(Map<String, dynamic> json) {
    return TutorialFilterOptions(
      categories: (json['categories'] as List<dynamic>?)?.cast<String>() ?? [],
      difficultyLevels: (json['difficulty_levels'] as List<dynamic>?)?.cast<String>() ?? [],
      durationOptions: (json['duration_options'] as List<dynamic>?)?.cast<int>() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categories': categories,
      'difficulty_levels': difficultyLevels,
      'duration_options': durationOptions,
    };
  }
}

class UserProgressSummary {
  final int completedCount;
  final int inProgressCount;
  final int totalTimeMinutes;
  final double? averageRating;
  final List<TutorialProgress> completedTutorials;
  final List<TutorialProgress> inProgressTutorials;

  const UserProgressSummary({
    required this.completedCount,
    required this.inProgressCount,
    required this.totalTimeMinutes,
    this.averageRating,
    this.completedTutorials = const [],
    this.inProgressTutorials = const [],
  });

  factory UserProgressSummary.fromJson(Map<String, dynamic> json) {
    return UserProgressSummary(
      completedCount: json['completed_count'] as int,
      inProgressCount: json['in_progress_count'] as int,
      totalTimeMinutes: json['total_time_minutes'] as int,
      averageRating: (json['average_rating'] as num?)?.toDouble(),
      completedTutorials: (json['completed_tutorials'] as List<dynamic>?)?.map((e) => TutorialProgress.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      inProgressTutorials: (json['in_progress_tutorials'] as List<dynamic>?)?.map((e) => TutorialProgress.fromJson(e as Map<String, dynamic>)).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'completed_count': completedCount,
      'in_progress_count': inProgressCount,
      'total_time_minutes': totalTimeMinutes,
      'average_rating': averageRating,
      'completed_tutorials': completedTutorials.map((e) => e.toJson()).toList(),
      'in_progress_tutorials': inProgressTutorials.map((e) => e.toJson()).toList(),
    };
  }
} 