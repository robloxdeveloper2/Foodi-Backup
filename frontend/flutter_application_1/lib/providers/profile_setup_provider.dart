import 'package:flutter/material.dart';
import '../models/profile_models.dart';
import '../models/user_model.dart';
import '../services/profile_service.dart';

class ProfileSetupProvider with ChangeNotifier {
  // Current profile setup data
  ProfileSetupData _profileData = ProfileSetupData();
  ProfileSetupData get profileData => _profileData;

  // Available options from backend
  ProfileSetupOptions? _setupOptions;
  ProfileSetupOptions? get setupOptions => _setupOptions;

  // Onboarding state
  OnboardingStatus? _onboardingStatus;
  OnboardingStatus? get onboardingStatus => _onboardingStatus;
  
  OnboardingStep _currentStep = OnboardingStep.welcome;
  OnboardingStep get currentStep => _currentStep;

  // Loading and error states
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  String? _error;
  String? get error => _error;

  // Initialize profile setup
  Future<void> initializeProfileSetup() async {
    _setLoading(true);
    _clearError();

    try {
      // Load setup options and onboarding status in parallel
      await Future.wait([
        _loadSetupOptions(),
        _loadOnboardingStatus(),
      ]);
    } catch (e) {
      _setError('Failed to initialize profile setup: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load predefined setup options
  Future<void> _loadSetupOptions() async {
    try {
      _setupOptions = await ProfileService.getProfileSetupData();
    } catch (e) {
      _setError('Failed to load setup options: $e');
      rethrow;
    }
  }

  // Load user's onboarding status
  Future<void> _loadOnboardingStatus() async {
    try {
      _onboardingStatus = await ProfileService.getOnboardingStatus();
      if (_onboardingStatus != null) {
        _currentStep = OnboardingStep.fromStepNumber(_onboardingStatus!.currentStep);
      }
    } catch (e) {
      // Don't rethrow here - this is optional data
      _setError('Failed to load onboarding status: $e');
    }
  }

  // Update dietary restrictions
  void updateDietaryRestrictions(List<String> restrictions) {
    _profileData = _profileData.copyWith(dietaryRestrictions: restrictions);
    notifyListeners();
  }

  // Add custom dietary restriction
  void addCustomDietaryRestriction(String restriction) {
    final current = List<String>.from(_profileData.customDietaryRestrictions);
    if (!current.contains(restriction.toLowerCase())) {
      current.add(restriction.toLowerCase());
      _profileData = _profileData.copyWith(customDietaryRestrictions: current);
      notifyListeners();
    }
  }

  // Remove custom dietary restriction
  void removeCustomDietaryRestriction(String restriction) {
    final current = List<String>.from(_profileData.customDietaryRestrictions);
    current.remove(restriction);
    _profileData = _profileData.copyWith(customDietaryRestrictions: current);
    notifyListeners();
  }

  // Update allergies
  void updateAllergies(List<String> allergies) {
    _profileData = _profileData.copyWith(allergies: allergies);
    notifyListeners();
  }

  // Update budget information
  void updateBudgetInfo({
    String? period,
    double? amount,
    String? currency,
    double? priceMin,
    double? priceMax,
  }) {
    _profileData = _profileData.copyWith(
      budgetPeriod: period,
      budgetAmount: amount,
      currency: currency,
      pricePerMealMin: priceMin,
      pricePerMealMax: priceMax,
    );
    notifyListeners();
  }

  // Update cooking experience
  void updateCookingExperience({
    String? level,
    String? frequency,
    List<String>? equipment,
  }) {
    _profileData = _profileData.copyWith(
      cookingExperienceLevel: level,
      cookingFrequency: frequency,
      kitchenEquipment: equipment,
    );
    notifyListeners();
  }

  // Update nutritional goals
  void updateNutritionalGoals({
    String? weightGoal,
    int? dailyCalories,
    double? protein,
    double? carbs,
    double? fat,
    String? dietaryProgram,
  }) {
    _profileData = _profileData.copyWith(
      weightGoal: weightGoal,
      dailyCalorieTarget: dailyCalories,
      proteinTargetPct: protein,
      carbTargetPct: carbs,
      fatTargetPct: fat,
      dietaryProgram: dietaryProgram,
    );
    notifyListeners();
  }

  // Navigate to specific step
  Future<void> goToStep(OnboardingStep step) async {
    _currentStep = step;
    notifyListeners();

    // Update backend with current step
    try {
      await ProfileService.updateOnboardingStep(step.stepNumber);
    } catch (e) {
      // Don't fail the UI update if backend update fails
      debugPrint('Failed to update onboarding step: $e');
    }
  }

  // Navigate to next step
  Future<void> nextStep() async {
    final nextStepNumber = _currentStep.stepNumber + 1;
    final nextStep = OnboardingStep.values
        .where((step) => step.stepNumber == nextStepNumber)
        .firstOrNull;
    
    if (nextStep != null) {
      await goToStep(nextStep);
    }
  }

  // Navigate to previous step
  Future<void> previousStep() async {
    final prevStepNumber = _currentStep.stepNumber - 1;
    final prevStep = OnboardingStep.values
        .where((step) => step.stepNumber == prevStepNumber)
        .firstOrNull;
    
    if (prevStep != null) {
      await goToStep(prevStep);
    }
  }

  // Check if current step is valid/complete
  bool get isCurrentStepValid {
    switch (_currentStep) {
      case OnboardingStep.welcome:
        return true; // Welcome step is always valid
      case OnboardingStep.dietaryRestrictions:
        return true; // This step is optional
      case OnboardingStep.budget:
        return true; // This step is optional
      case OnboardingStep.cookingExperience:
        return true; // This step is optional
      case OnboardingStep.nutritionalGoals:
        return true; // This step is optional
      case OnboardingStep.confirmation:
        return true; // Confirmation step is always valid
    }
  }

  // Submit complete profile setup
  Future<User?> submitProfileSetup() async {
    _setSubmitting(true);
    _clearError();

    try {
      // Add debug logging
      print('ProfileSetupProvider: Attempting to submit profile setup...');
      print('ProfileSetupProvider: Profile data: ${_profileData.toJson()}');
      
      final user = await ProfileService.setupProfile(_profileData);
      
      print('ProfileSetupProvider: Profile setup successful');
      
      // Mark onboarding as complete
      await goToStep(OnboardingStep.confirmation);
      
      return user;
    } catch (e) {
      print('ProfileSetupProvider: Error during profile setup: $e');
      
      // Check if it's a network error and provide more helpful message
      String errorMessage = 'Failed to complete profile setup';
      if (e.toString().contains('Network error') || 
          e.toString().contains('Connection failed') ||
          e.toString().contains('SocketException')) {
        errorMessage = 'Cannot connect to server. Your profile data will be saved locally and synced when connection is restored.';
      } else {
        errorMessage = 'Failed to complete profile setup: $e';
      }
      
      _setError(errorMessage);
      return null;
    } finally {
      _setSubmitting(false);
    }
  }

  // Reset profile data (for starting over)
  void resetProfileData() {
    _profileData = ProfileSetupData();
    _currentStep = OnboardingStep.welcome;
    _clearError();
    notifyListeners();
  }

  // Calculate setup completion percentage
  double get completionPercentage {
    double progress = 0.0;
    
    // Each major section worth 20%
    if (_profileData.dietaryRestrictions.isNotEmpty || _profileData.allergies.isNotEmpty) {
      progress += 0.2;
    }
    
    if (_profileData.budgetAmount != null || _profileData.budgetPeriod != null) {
      progress += 0.2;
    }
    
    if (_profileData.cookingExperienceLevel != null || _profileData.kitchenEquipment.isNotEmpty) {
      progress += 0.2;
    }
    
    if (_profileData.weightGoal != null || _profileData.dailyCalorieTarget != null) {
      progress += 0.2;
    }
    
    // Base progress for starting
    progress += 0.2;
    
    return progress;
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setSubmitting(bool submitting) {
    _isSubmitting = submitting;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
} 