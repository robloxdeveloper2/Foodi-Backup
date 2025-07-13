import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';
import 'providers/profile_setup_provider.dart';
import 'providers/meal_planning_provider.dart';
import 'providers/meal_swiping_provider.dart';
import 'providers/meal_substitution_provider.dart';
import 'providers/grocery_list_provider.dart';
import 'providers/social_provider.dart';
import 'providers/recipe_discovery_provider.dart';
import 'providers/recipe_detail_provider.dart';
import 'providers/user_recipe_provider.dart';
import 'providers/tutorial_provider.dart';
import 'providers/pantry_provider.dart';
import 'services/meal_planning_service.dart';
import 'services/meal_substitution_service.dart';
import 'services/preference_learning_service.dart';
import 'services/grocery_list_service.dart';
import 'services/social_service.dart';
import 'models/social_models.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/email_verification_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/onboarding/profile_setup_screen.dart';
import 'screens/profile/profile_management_screen.dart';
import 'screens/meal_planning/meal_plan_generation_screen.dart';
import 'screens/meal_planning/meal_swiping_screen.dart';
import 'screens/meal_planning/meal_plan_view_screen.dart';
import 'screens/social/profile_screen.dart';
import 'screens/social/edit_profile_screen.dart';
import 'screens/social/activity_feed_screen.dart';
import 'screens/social/user_search_screen.dart';
import 'screens/recipe_discovery/recipe_discovery_screen.dart';
import 'screens/recipe_detail/recipe_detail_screen.dart';
import 'screens/user_recipes/my_recipes_screen.dart';
import 'screens/tutorials/tutorials_screen.dart';
import 'screens/pantry/pantry_screen.dart';
import 'screens/pantry/add_pantry_item_screen.dart';
import 'screens/meal_planning/grocery_lists_screen.dart';
import 'screens/meal_planning/delivery_demo_screen.dart';
import 'utils/app_theme.dart';
import 'utils/app_routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  //
  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(const FoodiApp());
}

class FoodiApp extends StatelessWidget {
  const FoodiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ProfileSetupProvider()),
        ChangeNotifierProvider(create: (_) => MealPlanningProvider(MealPlanningService())),
        ChangeNotifierProvider(create: (_) => MealSwipingProvider(PreferenceLearningService())),
        ChangeNotifierProvider(create: (_) => MealSubstitutionProvider(MealSubstitutionService())),
        ChangeNotifierProvider(create: (_) => GroceryListProvider(GroceryListService())),
        ChangeNotifierProvider(create: (_) => SocialProvider()),
        ChangeNotifierProvider(create: (_) => RecipeDetailProvider()),
        ChangeNotifierProxyProvider<AuthProvider, UserRecipeProvider>(
          create: (_) => UserRecipeProvider(),
          update: (_, authProvider, userRecipeProvider) {
            if (authProvider.token != null) {
              userRecipeProvider?.setAuthToken(authProvider.token!);
            } else {
              userRecipeProvider?.clearAuthToken();
            }
            return userRecipeProvider ?? UserRecipeProvider();
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, RecipeDiscoveryProvider>(
          create: (_) => RecipeDiscoveryProvider(),
          update: (_, authProvider, recipeProvider) {
            if (authProvider.token != null) {
              recipeProvider?.setAuthToken(authProvider.token!);
            } else {
              recipeProvider?.clearAuthToken();
            }
            return recipeProvider ?? RecipeDiscoveryProvider();
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, TutorialProvider>(
          create: (_) => TutorialProvider(),
          update: (_, authProvider, tutorialProvider) {
            if (authProvider.token != null) {
              tutorialProvider?.setAuthToken(authProvider.token!);
            } else {
              tutorialProvider?.clearAuthToken();
            }
            return tutorialProvider ?? TutorialProvider();
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, PantryProvider>(
          create: (_) => PantryProvider(),
          update: (_, authProvider, pantryProvider) {
            if (authProvider.token != null) {
              pantryProvider?.setAuthToken(authProvider.token!);
            } else {
              pantryProvider?.clearAuthToken();
            }
            return pantryProvider ?? PantryProvider();
          },
        ),
      ],
      child: MaterialApp(
        title: 'Foodi',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        initialRoute: AppRoutes.splash,
        routes: {
          AppRoutes.splash: (context) => const SplashScreen(),
          AppRoutes.login: (context) => const LoginScreen(),
          AppRoutes.register: (context) => const RegisterScreen(),
          AppRoutes.emailVerification: (context) => const EmailVerificationScreen(),
          AppRoutes.home: (context) => const HomeScreen(),
          AppRoutes.profileSetup: (context) => const ProfileSetupScreen(),
          AppRoutes.profileManagement: (context) => const ProfileManagementScreen(),
          AppRoutes.mealPlanning: (context) => const MealPlanGenerationScreen(),
          AppRoutes.mealSwiping: (context) => const MealSwipingScreen(),
          AppRoutes.socialProfile: (context) => const ProfileScreen(),
          AppRoutes.activityFeed: (context) => const ActivityFeedScreen(),
          AppRoutes.userSearch: (context) => const UserSearchScreen(),
          AppRoutes.recipeDiscovery: (context) => const RecipeDiscoveryScreen(),
          AppRoutes.myRecipes: (context) => const MyRecipesScreen(),
          AppRoutes.tutorials: (context) => const TutorialsScreen(),
          AppRoutes.pantry: (context) => const PantryScreen(),
          AppRoutes.addPantryItem: (context) => const AddPantryItemScreen(),
          AppRoutes.groceries: (context) => const GroceryListsScreen(),
        AppRoutes.deliveryDemo: (context) => const DeliveryDemoScreen(),
        },
        onGenerateRoute: (settings) {
          // Handle dynamic routes if needed
          switch (settings.name) {
            case '/meal-plan-view':
              final mealPlanId = settings.arguments as String?;
              return MaterialPageRoute(
                builder: (context) => MealPlanViewScreen(
                  mealPlanId: mealPlanId ?? '',
                ),
              );
            case '/social-profile':
              final userId = settings.arguments as String?;
              return MaterialPageRoute(
                builder: (context) => ProfileScreen(
                  userId: userId,
                ),
              );
            case '/edit-social-profile':
              final profile = settings.arguments as UserSocialProfile?;
              if (profile == null) {
                return MaterialPageRoute(
                  builder: (context) => const SplashScreen(),
                );
              }
              return MaterialPageRoute(
                builder: (context) => EditProfileScreen(
                  profile: profile,
                ),
              );
            case '/recipe-details':
              final recipeId = settings.arguments as String?;
              if (recipeId == null) {
                return MaterialPageRoute(
                  builder: (context) => const RecipeDiscoveryScreen(),
                );
              }
              return MaterialPageRoute(
                builder: (context) => RecipeDetailScreen(recipeId: recipeId),
              );
            default:
              return MaterialPageRoute(
                builder: (context) => const SplashScreen(),
              );
          }
        },
      ),
    );
  }
}