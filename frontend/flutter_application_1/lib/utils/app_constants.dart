class AppConstants {
  // API Configuration
  static const String baseUrl = 'http://localhost:5000'; // Backend API base URL
  static const String apiVersion = 'v1';
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language_code';
  
  // App Configuration
  static const String appName = 'Foodi';
  static const String appVersion = '1.0.0';
  
  // Social Login Configuration
  static const String googleClientId = 'your-google-client-id'; // Replace with actual Google Client ID
  static const String appleClientId = 'your-apple-client-id'; // Replace with actual Apple Client ID
  
  // Validation Constants
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 30;
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double buttonHeight = 48.0;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // Network Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Error Messages
  static const String networkErrorMessage = 'Please check your internet connection and try again.';
  static const String serverErrorMessage = 'Something went wrong. Please try again later.';
  static const String validationErrorMessage = 'Please check your input and try again.';
  
  // Success Messages
  static const String registrationSuccessMessage = 'Account created successfully! Please check your email for verification.';
  static const String loginSuccessMessage = 'Welcome back!';
  static const String emailVerificationSuccessMessage = 'Email verified successfully!';
  
  // Regular Expressions
  static const String emailRegex = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String passwordRegex = r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d@$!%*?&]{8,}$';
  static const String usernameRegex = r'^[a-zA-Z0-9_]{3,30}$';
  
  // Asset Paths
  static const String logoPath = 'assets/images/logo.png';
  static const String placeholderImagePath = 'assets/images/placeholder.png';
  static const String googleIconPath = 'assets/icons/google.svg';
  static const String appleIconPath = 'assets/icons/apple.svg';
  
  // Environment Configuration
  static const bool isProduction = bool.fromEnvironment('dart.vm.product');
  static const bool enableLogging = !isProduction;
  
  // Feature Flags
  static const bool enableSocialLogin = true;
  static const bool enableEmailVerification = true;
  static const bool enableTestUser = true;
  static const bool enableBiometricAuth = false; // Future feature
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Cache Configuration
  static const Duration cacheExpiration = Duration(hours: 24);
  static const int maxCacheSize = 100; // MB
} 