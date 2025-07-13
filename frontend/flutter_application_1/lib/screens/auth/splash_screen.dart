import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/profile_setup_provider.dart';
import '../../services/profile_service.dart';
import '../../utils/app_routes.dart';
import '../../utils/app_constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    
    // Defer initialization to after the first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: AppConstants.mediumAnimation,
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));
    
    _animationController.forward();
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize providers
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      
      // Initialize user preferences
      await userProvider.initializePreferences();
      
      // Initialize authentication state
      await authProvider.initializeAuth();
      
      // Wait minimum splash duration for better UX
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Navigate based on authentication state
      if (mounted) {
        if (authProvider.isAuthenticated) {
          // Set auth token for profile service
          ProfileService.setAuthToken(authProvider.token!);
          
          // Check if user needs to complete profile setup
          await _checkProfileSetupStatus(authProvider);
        } else {
          Navigator.pushReplacementNamed(context, AppRoutes.login);
        }
      }
    } catch (e) {
      debugPrint('Error initializing app: $e');
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    }
  }

  Future<void> _checkProfileSetupStatus(AuthProvider authProvider) async {
    try {
      // Get onboarding status
      final onboardingStatus = await ProfileService.getOnboardingStatus();
      
      if (onboardingStatus.profileSetupCompleted) {
        // Profile setup is complete, go to home
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      } else {
        // Profile setup is not complete, go to onboarding
        Navigator.pushReplacementNamed(context, AppRoutes.profileSetup);
      }
    } catch (e) {
      // If we can't check onboarding status, assume profile setup is needed
      debugPrint('Error checking profile setup status: $e');
      Navigator.pushReplacementNamed(context, AppRoutes.profileSetup);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.restaurant_menu,
                  size: 60,
                  color: Color(0xFF4CAF50),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // App Name
              Text(
                AppConstants.appName,
                style: theme.textTheme.displayMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // App Tagline
              Text(
                'Your personal meal planning companion',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 48),
              
              // Loading Indicator
              const SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 