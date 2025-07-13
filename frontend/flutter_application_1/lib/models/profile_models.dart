// Profile Setup Data Models

class ProfileSetupData {
  List<String> dietaryRestrictions;
  List<String> customDietaryRestrictions;
  List<String> allergies;
  String? budgetPeriod;
  double? budgetAmount;
  String currency;
  double? pricePerMealMin;
  double? pricePerMealMax;
  String? cookingExperienceLevel;
  String? cookingFrequency;
  List<String> kitchenEquipment;
  String? weightGoal;
  int? dailyCalorieTarget;
  double? proteinTargetPct;
  double? carbTargetPct;
  double? fatTargetPct;
  String? dietaryProgram;

  ProfileSetupData({
    this.dietaryRestrictions = const [],
    this.customDietaryRestrictions = const [],
    this.allergies = const [],
    this.budgetPeriod,
    this.budgetAmount,
    this.currency = 'USD',
    this.pricePerMealMin,
    this.pricePerMealMax,
    this.cookingExperienceLevel,
    this.cookingFrequency,
    this.kitchenEquipment = const [],
    this.weightGoal,
    this.dailyCalorieTarget,
    this.proteinTargetPct,
    this.carbTargetPct,
    this.fatTargetPct,
    this.dietaryProgram,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    
    if (dietaryRestrictions.isNotEmpty) {
      data['dietary_restrictions'] = dietaryRestrictions;
    }
    if (customDietaryRestrictions.isNotEmpty) {
      data['custom_dietary_restrictions'] = customDietaryRestrictions;
    }
    if (allergies.isNotEmpty) {
      data['allergies'] = allergies;
    }
    if (budgetPeriod != null) {
      data['budget_period'] = budgetPeriod;
    }
    if (budgetAmount != null) {
      data['budget_amount'] = budgetAmount;
    }
    data['currency'] = currency;
    if (pricePerMealMin != null) {
      data['price_per_meal_min'] = pricePerMealMin;
    }
    if (pricePerMealMax != null) {
      data['price_per_meal_max'] = pricePerMealMax;
    }
    if (cookingExperienceLevel != null) {
      data['cooking_experience_level'] = cookingExperienceLevel;
    }
    if (cookingFrequency != null) {
      data['cooking_frequency'] = cookingFrequency;
    }
    if (kitchenEquipment.isNotEmpty) {
      data['kitchen_equipment'] = kitchenEquipment;
    }
    if (weightGoal != null) {
      data['weight_goal'] = weightGoal;
    }
    if (dailyCalorieTarget != null) {
      data['daily_calorie_target'] = dailyCalorieTarget;
    }
    if (proteinTargetPct != null) {
      data['protein_target_pct'] = proteinTargetPct;
    }
    if (carbTargetPct != null) {
      data['carb_target_pct'] = carbTargetPct;
    }
    if (fatTargetPct != null) {
      data['fat_target_pct'] = fatTargetPct;
    }
    if (dietaryProgram != null) {
      data['dietary_program'] = dietaryProgram;
    }
    
    return data;
  }

  factory ProfileSetupData.fromJson(Map<String, dynamic> json) {
    return ProfileSetupData(
      dietaryRestrictions: List<String>.from(json['dietary_restrictions'] ?? []),
      customDietaryRestrictions: List<String>.from(json['custom_dietary_restrictions'] ?? []),
      allergies: List<String>.from(json['allergies'] ?? []),
      budgetPeriod: json['budget_period'],
      budgetAmount: json['budget_amount']?.toDouble(),
      currency: json['currency'] ?? 'USD',
      pricePerMealMin: json['price_per_meal_min']?.toDouble(),
      pricePerMealMax: json['price_per_meal_max']?.toDouble(),
      cookingExperienceLevel: json['cooking_experience_level'],
      cookingFrequency: json['cooking_frequency'],
      kitchenEquipment: List<String>.from(json['kitchen_equipment'] ?? []),
      weightGoal: json['weight_goal'],
      dailyCalorieTarget: json['daily_calorie_target'],
      proteinTargetPct: json['protein_target_pct']?.toDouble(),
      carbTargetPct: json['carb_target_pct']?.toDouble(),
      fatTargetPct: json['fat_target_pct']?.toDouble(),
      dietaryProgram: json['dietary_program'],
    );
  }

  ProfileSetupData copyWith({
    List<String>? dietaryRestrictions,
    List<String>? customDietaryRestrictions,
    List<String>? allergies,
    String? budgetPeriod,
    double? budgetAmount,
    String? currency,
    double? pricePerMealMin,
    double? pricePerMealMax,
    String? cookingExperienceLevel,
    String? cookingFrequency,
    List<String>? kitchenEquipment,
    String? weightGoal,
    int? dailyCalorieTarget,
    double? proteinTargetPct,
    double? carbTargetPct,
    double? fatTargetPct,
    String? dietaryProgram,
  }) {
    return ProfileSetupData(
      dietaryRestrictions: dietaryRestrictions ?? this.dietaryRestrictions,
      customDietaryRestrictions: customDietaryRestrictions ?? this.customDietaryRestrictions,
      allergies: allergies ?? this.allergies,
      budgetPeriod: budgetPeriod ?? this.budgetPeriod,
      budgetAmount: budgetAmount ?? this.budgetAmount,
      currency: currency ?? this.currency,
      pricePerMealMin: pricePerMealMin ?? this.pricePerMealMin,
      pricePerMealMax: pricePerMealMax ?? this.pricePerMealMax,
      cookingExperienceLevel: cookingExperienceLevel ?? this.cookingExperienceLevel,
      cookingFrequency: cookingFrequency ?? this.cookingFrequency,
      kitchenEquipment: kitchenEquipment ?? this.kitchenEquipment,
      weightGoal: weightGoal ?? this.weightGoal,
      dailyCalorieTarget: dailyCalorieTarget ?? this.dailyCalorieTarget,
      proteinTargetPct: proteinTargetPct ?? this.proteinTargetPct,
      carbTargetPct: carbTargetPct ?? this.carbTargetPct,
      fatTargetPct: fatTargetPct ?? this.fatTargetPct,
      dietaryProgram: dietaryProgram ?? this.dietaryProgram,
    );
  }
}

// Predefined Options Models

class CookingExperienceLevel {
  final String value;
  final String label;
  final String description;

  const CookingExperienceLevel({
    required this.value,
    required this.label,
    required this.description,
  });

  factory CookingExperienceLevel.fromJson(Map<String, dynamic> json) {
    return CookingExperienceLevel(
      value: json['value'],
      label: json['label'],
      description: json['description'],
    );
  }
}

class DietaryProgram {
  final String value;
  final String label;
  final String description;

  const DietaryProgram({
    required this.value,
    required this.label,
    required this.description,
  });

  factory DietaryProgram.fromJson(Map<String, dynamic> json) {
    return DietaryProgram(
      value: json['value'],
      label: json['label'],
      description: json['description'],
    );
  }
}

class ProfileSetupOptions {
  final List<String> dietaryRestrictions;
  final List<String> allergies;
  final List<CookingExperienceLevel> cookingExperienceLevels;
  final List<String> kitchenEquipment;
  final List<DietaryProgram> dietaryPrograms;
  final List<String> currencies;

  const ProfileSetupOptions({
    required this.dietaryRestrictions,
    required this.allergies,
    required this.cookingExperienceLevels,
    required this.kitchenEquipment,
    required this.dietaryPrograms,
    required this.currencies,
  });

  factory ProfileSetupOptions.fromJson(Map<String, dynamic> json) {
    return ProfileSetupOptions(
      dietaryRestrictions: List<String>.from(json['dietary_restrictions'] ?? []),
      allergies: List<String>.from(json['allergies'] ?? []),
      cookingExperienceLevels: (json['cooking_experience_levels'] as List?)
          ?.map((item) => CookingExperienceLevel.fromJson(item))
          .toList() ?? [],
      kitchenEquipment: List<String>.from(json['kitchen_equipment'] ?? []),
      dietaryPrograms: (json['dietary_programs'] as List?)
          ?.map((item) => DietaryProgram.fromJson(item))
          .toList() ?? [],
      currencies: List<String>.from(json['currencies'] ?? []),
    );
  }
}

// Onboarding Status Model

class OnboardingStatus {
  final String userId;
  final bool emailVerified;
  final bool profileSetupCompleted;
  final int currentStep;

  const OnboardingStatus({
    required this.userId,
    required this.emailVerified,
    required this.profileSetupCompleted,
    required this.currentStep,
  });

  factory OnboardingStatus.fromJson(Map<String, dynamic> json) {
    return OnboardingStatus(
      userId: json['user_id'],
      emailVerified: json['email_verified'],
      profileSetupCompleted: json['profile_setup_completed'],
      currentStep: json['current_step'],
    );
  }
}

// Onboarding Step Enum

enum OnboardingStep {
  welcome(0, 'Welcome'),
  dietaryRestrictions(1, 'Dietary Restrictions'),
  budget(2, 'Budget Information'),
  cookingExperience(3, 'Cooking Experience'),
  nutritionalGoals(4, 'Nutritional Goals'),
  confirmation(5, 'Confirmation');

  const OnboardingStep(this.stepNumber, this.title);

  final int stepNumber;
  final String title;

  static OnboardingStep fromStepNumber(int stepNumber) {
    return OnboardingStep.values.firstWhere(
      (step) => step.stepNumber == stepNumber,
      orElse: () => OnboardingStep.welcome,
    );
  }
} 