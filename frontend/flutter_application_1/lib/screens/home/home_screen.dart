import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/meal_planning_provider.dart';
import '../../providers/social_provider.dart';
import '../../providers/recipe_discovery_provider.dart';
import '../../providers/user_recipe_provider.dart';
import '../../providers/tutorial_provider.dart';
import '../../providers/pantry_provider.dart';
import '../../widgets/meal_plan_selector.dart';
import '../../utils/app_routes.dart';
import '../../utils/app_constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Check authentication state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (!authProvider.isAuthenticated) {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      } else {
        // Initialize meal planning data
        _initializeMealPlanning();
      }
    });
  }

  Future<void> _initializeMealPlanning() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final mealPlanningProvider = Provider.of<MealPlanningProvider>(context, listen: false);
    final socialProvider = Provider.of<SocialProvider>(context, listen: false);
    final recipeDiscoveryProvider = Provider.of<RecipeDiscoveryProvider>(context, listen: false);
    final userRecipeProvider = Provider.of<UserRecipeProvider>(context, listen: false);
    final tutorialProvider = Provider.of<TutorialProvider>(context, listen: false);
    final pantryProvider = Provider.of<PantryProvider>(context, listen: false);
    
    if (authProvider.isAuthenticated && authProvider.token != null) {
      mealPlanningProvider.setAuthToken(authProvider.token!);
      // Load meal plan history and auto-select most recent
      await mealPlanningProvider.loadMealPlanHistoryWithAutoSelect();
      
      // Initialize social provider
      socialProvider.setAuthToken(authProvider.token!);
      await socialProvider.initialize();
      
      // Initialize recipe discovery provider
      recipeDiscoveryProvider.setAuthToken(authProvider.token!);
      await recipeDiscoveryProvider.initialize();
      
      // Initialize user recipe provider
      userRecipeProvider.setAuthToken(authProvider.token!);
      await userRecipeProvider.initialize();
      
      // Initialize tutorial provider
      tutorialProvider.setAuthToken(authProvider.token!);
      await tutorialProvider.initialize();
      
      // Initialize pantry provider
      pantryProvider.setAuthToken(authProvider.token!);
      await pantryProvider.loadPantryItems();
    }
  }

  Future<void> _handleLogout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final mealPlanningProvider = Provider.of<MealPlanningProvider>(context, listen: false);
    final recipeDiscoveryProvider = Provider.of<RecipeDiscoveryProvider>(context, listen: false);
    
    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await authProvider.logout();
      await userProvider.clearUserData();
      mealPlanningProvider.reset(); // Clear meal planning state
      recipeDiscoveryProvider.reset(); // Clear recipe discovery state
      
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.user;
          
          if (user == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return CustomScrollView(
            slivers: [
              // Modern App Bar with Profile
              SliverAppBar(
                expandedHeight: 140,
                floating: false,
                pinned: true,
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                title: const Text(
                  'Foodi',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.primary.withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          top: 60, // Account for the collapsed app bar height
                          bottom: 16,
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.white.withOpacity(0.2),
                              child: Text(
                                user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : 'U',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Welcome back!',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    user.displayName,
                                    style: theme.textTheme.headlineSmall?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                                 actions: [
                   Consumer<UserProvider>(
                     builder: (context, userProvider, child) {
                       return IconButton(
                         onPressed: userProvider.toggleTheme,
                         icon: Icon(
                           userProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                           color: Colors.white,
                         ),
                       );
                     },
                   ),
                   IconButton(
                     onPressed: () {
                       Navigator.pushNamed(context, AppRoutes.profileManagement);
                     },
                     icon: const Icon(Icons.settings, color: Colors.white),
                   ),
                   IconButton(
                     onPressed: _handleLogout,
                     icon: const Icon(Icons.logout, color: Colors.white),
                   ),
                 ],
              ),

              // Main Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Email Verification Banner (if needed)
                      if (!user.emailVerified) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppConstants.defaultPadding),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                            border: Border.all(color: Colors.orange.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.warning_amber, color: Colors.orange),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Email not verified',
                                      style: theme.textTheme.titleSmall?.copyWith(
                                        color: Colors.orange,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Please verify your email to unlock all features',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: Colors.orange.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, AppRoutes.emailVerification);
                                },
                                child: Text('Verify'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Primary Actions - Hero Section
                      _buildHeroSection(context),
                      
                      const SizedBox(height: 32),

                      // Today's Meal Plan
                      _buildTodaysMealPlan(context),
                      
                      const SizedBox(height: 32),

                      // Quick Actions
                      _buildQuickActions(context),
                      
                      const SizedBox(height: 32),

                      // Discovery Section
                      _buildDiscoverySection(context),
                      
                      const SizedBox(height: 32),

                      // More Features
                      _buildMoreFeatures(context),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          _handleBottomNavTap(index);
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.6),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Meal Plans',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'My Recipes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.kitchen),
            label: 'Pantry',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Groceries',
          ),
        ],
      ),
    );
  }

  void _handleBottomNavTap(int index) {
    switch (index) {
      case 0:
        // Home - already here, do nothing
        break;
      case 1:
        Navigator.pushNamed(context, AppRoutes.mealPlanning);
        break;
      case 2:
        Navigator.pushNamed(context, AppRoutes.myRecipes);
        break;
      case 3:
        Navigator.pushNamed(context, AppRoutes.pantry);
        break;
      case 4:
        Navigator.pushNamed(context, AppRoutes.groceries);
        break;
    }
  }

  Widget _buildHeroSection(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withOpacity(0.1),
            theme.colorScheme.primary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.restaurant_menu,
                size: 32,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ready to plan your meals?',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Discover new recipes and create personalized meal plans',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.mealPlanning);
                  },
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Create Meal Plan'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.mealSwiping);
                  },
                  icon: const Icon(Icons.favorite_border),
                  label: const Text('Discover Meals'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTodaysMealPlan(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Today\'s Meals',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.mealPlanning);
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        MealPlanSelector(
          onCreateNew: () {
            Navigator.pushNamed(context, AppRoutes.mealPlanning);
          },
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                context,
                'Pantry',
                Icons.kitchen,
                'Manage ingredients',
                () {
                  Navigator.pushNamed(context, AppRoutes.pantry);
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildQuickActionCard(
                context,
                'Groceries',
                Icons.shopping_cart,
                'Shopping lists',
                () {
                  Navigator.pushNamed(context, AppRoutes.groceries);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDiscoverySection(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Discover & Learn',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildDiscoveryCard(
                context,
                'Recipe Library',
                Icons.menu_book,
                'Browse thousands of recipes',
                () {
                  Navigator.pushNamed(context, AppRoutes.recipeDiscovery);
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDiscoveryCard(
                context,
                'Cooking Tutorials',
                Icons.school,
                'Learn new techniques',
                () {
                  Navigator.pushNamed(context, AppRoutes.tutorials);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }



  Widget _buildMoreFeatures(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'More Features',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildFeaturesList(context),
      ],
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context,
    String title,
    IconData icon,
    String subtitle,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDiscoveryCard(
    BuildContext context,
    String title,
    IconData icon,
    String description,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturesList(BuildContext context) {
    final theme = Theme.of(context);
    
    final features = [
      {
        'title': 'My Recipes',
        'subtitle': 'Your saved and created recipes',
        'icon': Icons.favorite,
        'route': AppRoutes.myRecipes,
      },
      {
        'title': 'Activity Feed',
        'subtitle': 'See what your friends are cooking',
        'icon': Icons.dynamic_feed,
        'route': AppRoutes.activityFeed,
      },
      {
        'title': 'Find Friends',
        'subtitle': 'Connect with other food lovers',
        'icon': Icons.people_alt,
        'route': AppRoutes.userSearch,
      },
      {
        'title': 'Social Profile',
        'subtitle': 'Your public profile and social settings',
        'icon': Icons.person,
        'route': AppRoutes.socialProfile,
      },
    ];

    return Card(
      elevation: 1,
      child: Column(
        children: features.asMap().entries.map((entry) {
          final index = entry.key;
          final feature = entry.value;
          final isLast = index == features.length - 1;
          
          return Column(
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    feature['icon'] as IconData,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                ),
                title: Text(
                  feature['title'] as String,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  feature['subtitle'] as String,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: theme.colorScheme.onSurface.withOpacity(0.4),
                ),
                onTap: () {
                  Navigator.pushNamed(context, feature['route'] as String);
                },
              ),
              if (!isLast) const Divider(height: 1),
            ],
          );
        }).toList(),
      ),
    );
  }
} 