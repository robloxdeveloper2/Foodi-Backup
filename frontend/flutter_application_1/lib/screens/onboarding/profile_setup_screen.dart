import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/profile_setup_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/profile_models.dart';
import '../../services/profile_service.dart';
import '../../utils/app_constants.dart';
import '../../utils/app_routes.dart';
import 'steps/welcome_step.dart';
import 'steps/dietary_restrictions_step.dart';
import 'steps/budget_step.dart';
import 'steps/cooking_experience_step.dart';
import 'steps/nutritional_goals_step.dart';
import 'steps/confirmation_step.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  late ProfileSetupProvider _profileProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeProfileSetup();
    });
  }

  void _initializeProfileSetup() async {
    _profileProvider = Provider.of<ProfileSetupProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Set auth token for profile service
    if (authProvider.token != null) {
      print('ProfileSetup: Setting auth token for ProfileService');
      ProfileService.setAuthToken(authProvider.token!);
      await _profileProvider.initializeProfileSetup();
    } else {
      print('ProfileSetup: Warning - No auth token available');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileSetupProvider>(
      builder: (context, profileProvider, child) {
        if (profileProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return Scaffold(
          appBar: _buildAppBar(context, profileProvider),
          body: Column(
            children: [
              _buildProgressIndicator(profileProvider),
              Expanded(
                child: _buildCurrentStep(profileProvider),
              ),
              _buildNavigationButtons(context, profileProvider),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, ProfileSetupProvider provider) {
    return AppBar(
      title: Text(provider.currentStep.title),
      centerTitle: true,
      leading: provider.currentStep != OnboardingStep.welcome
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => provider.previousStep(),
            )
          : null,
      actions: [
        if (provider.currentStep != OnboardingStep.confirmation)
          TextButton(
            onPressed: () => _skipToEnd(context, provider),
            child: const Text('Skip'),
          ),
      ],
    );
  }

  Widget _buildProgressIndicator(ProfileSetupProvider provider) {
    final totalSteps = OnboardingStep.values.length;
    final currentStepIndex = provider.currentStep.stepNumber;
    final progress = (currentStepIndex + 1) / totalSteps;

    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Step ${currentStepIndex + 1} of $totalSteps',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                '${(progress * 100).round()}% Complete',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.smallPadding),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep(ProfileSetupProvider provider) {
    return AnimatedSwitcher(
      duration: AppConstants.mediumAnimation,
      child: _getCurrentStepWidget(provider.currentStep),
    );
  }

  Widget _getCurrentStepWidget(OnboardingStep step) {
    switch (step) {
      case OnboardingStep.welcome:
        return const WelcomeStep();
      case OnboardingStep.dietaryRestrictions:
        return const DietaryRestrictionsStep();
      case OnboardingStep.budget:
        return const BudgetStep();
      case OnboardingStep.cookingExperience:
        return const CookingExperienceStep();
      case OnboardingStep.nutritionalGoals:
        return const NutritionalGoalsStep();
      case OnboardingStep.confirmation:
        return const ConfirmationStep();
    }
  }

  Widget _buildNavigationButtons(BuildContext context, ProfileSetupProvider provider) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (provider.currentStep != OnboardingStep.welcome)
            Expanded(
              child: OutlinedButton(
                onPressed: provider.previousStep,
                child: const Text('Previous'),
              ),
            ),
          if (provider.currentStep != OnboardingStep.welcome)
            const SizedBox(width: AppConstants.defaultPadding),
          Expanded(
            child: _buildNextButton(context, provider),
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton(BuildContext context, ProfileSetupProvider provider) {
    final isLastStep = provider.currentStep == OnboardingStep.confirmation;
    final isSubmitting = provider.isSubmitting;

    return ElevatedButton(
      onPressed: isSubmitting ? null : () => _handleNextButton(context, provider),
      child: isSubmitting
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(isLastStep ? 'Complete Setup' : 'Continue'),
    );
  }

  void _handleNextButton(BuildContext context, ProfileSetupProvider provider) async {
    if (provider.currentStep == OnboardingStep.confirmation) {
      _completeSetup(context, provider);
    } else {
      await provider.nextStep();
    }
  }

  void _completeSetup(BuildContext context, ProfileSetupProvider provider) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    try {
      // Add debug logging
      print('ProfileSetup: Starting profile setup submission...');
      
      final user = await provider.submitProfileSetup();
      if (user != null) {
        print('ProfileSetup: Profile setup successful, updating auth and navigating...');
        
        // Update user in auth provider
        authProvider.updateUser(user);
        
        // Navigate to home screen
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRoutes.home,
            (route) => false,
          );
        }
      } else {
        print('ProfileSetup: Profile setup returned null, showing error...');
        
        // Show error with fallback option
        if (mounted) {
          _showErrorWithFallback(context, provider.error ?? 'Profile setup failed');
        }
      }
    } catch (e) {
      print('ProfileSetup: Exception during profile setup: $e');
      
      // Show error with fallback option
      if (mounted) {
        _showErrorWithFallback(context, 'Profile setup failed: $e');
      }
    }
  }

  void _showErrorWithFallback(BuildContext context, String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Setup Error'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(error),
            const SizedBox(height: 16),
            const Text(
              'You can continue to the app and complete your profile setup later in settings.',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Retry'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _bypassBackendAndContinue(context);
            },
            child: const Text('Skip Backend'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to home despite the error
              Navigator.of(context).pushNamedAndRemoveUntil(
                AppRoutes.home,
                (route) => false,
              );
            },
            child: const Text('Continue to App'),
          ),
        ],
      ),
    );
  }

  void _bypassBackendAndContinue(BuildContext context) {
    print('ProfileSetup: Bypassing backend, continuing to home screen...');
    
    // Simply navigate to home without backend call
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.home,
      (route) => false,
    );
  }

  void _skipToEnd(BuildContext context, ProfileSetupProvider provider) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Skip Profile Setup?'),
        content: const Text(
          'You can complete your profile setup later in settings. '
          'However, providing this information helps us give you better recommendations.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Skip'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Navigate directly to home
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.home,
          (route) => false,
        );
      }
    }
  }
} 