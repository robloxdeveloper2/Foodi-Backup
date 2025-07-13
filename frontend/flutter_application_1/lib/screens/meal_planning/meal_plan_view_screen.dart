import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../providers/meal_planning_provider.dart';
import '../../providers/meal_substitution_provider.dart';
import '../../providers/grocery_list_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/meal_plan.dart';
import '../../models/nutritional_analysis.dart';
import '../../widgets/meal_planning/meal_plan_calendar_widget.dart';
import '../../widgets/meal_planning/nutritional_dashboard_widget.dart';
import '../../widgets/meal_planning/daily_nutrition_summary_widget.dart';
import '../../widgets/meal_planning/weekly_trends_widget.dart';
import '../../widgets/meal_planning/cost_tracking_widget.dart';
import '../../widgets/meal_planning/nutrition_insights_card.dart';
import '../../widgets/meal_planning/meal_card_widget.dart';
import '../meal_planning/meal_substitution_screen.dart';
import '../meal_planning/grocery_list_screen.dart';

class MealPlanViewScreen extends StatefulWidget {
  final String mealPlanId;

  const MealPlanViewScreen({
    super.key,
    required this.mealPlanId,
  });

  @override
  State<MealPlanViewScreen> createState() => _MealPlanViewScreenState();
}

class _MealPlanViewScreenState extends State<MealPlanViewScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  MealPlan? _mealPlan;
  NutritionalAnalysis? _analysis;
  WeeklyTrends? _weeklyTrends;
  bool _isLoading = true;
  String? _error;
  int _selectedDay = 1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // Set up authentication and load meal plan data after the frame is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final mealPlanningProvider = context.read<MealPlanningProvider>();
      
      // Set auth token if user is authenticated
      if (authProvider.isAuthenticated && authProvider.token != null) {
        mealPlanningProvider.setAuthToken(authProvider.token!);
      }
      
      _loadMealPlanData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadMealPlanData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final mealPlanningProvider = context.read<MealPlanningProvider>();

      // Ensure auth token is set (backup check)
      if (authProvider.isAuthenticated && authProvider.token != null) {
        mealPlanningProvider.setAuthToken(authProvider.token!);
        debugPrint('Auth token set for meal plan loading');
      } else {
        debugPrint('Warning: User not authenticated or no token available');
        throw Exception('Please log in to view meal plans');
      }

      // Load meal plan
      debugPrint('Loading meal plan: ${widget.mealPlanId}');
      final mealPlanResponse = await mealPlanningProvider.getMealPlanData(widget.mealPlanId);
      if (mealPlanResponse['success'] == true) {
        _mealPlan = MealPlan.fromJson(mealPlanResponse['meal_plan']);
        debugPrint('Meal plan loaded successfully');
        debugPrint('Meal plan has ${_mealPlan!.meals.length} meals');
        // Log each meal for debugging
        for (int i = 0; i < _mealPlan!.meals.length; i++) {
          final meal = _mealPlan!.meals[i];
          debugPrint('Meal $i: Day ${meal.day}, ${meal.mealType}, Recipe: ${meal.recipeId}, Name: ${meal.recipeName}');
        }
      } else {
        final errorMessage = mealPlanResponse['error'] != null 
          ? (mealPlanResponse['error'] as Map<String, dynamic>)['message'] as String? ?? 'Failed to load meal plan'
          : 'Failed to load meal plan';
        debugPrint('Failed to load meal plan: $errorMessage');
        throw Exception(errorMessage);
      }

      // Load nutritional analysis
      final analysisResponse = await mealPlanningProvider.getMealPlanAnalysis(widget.mealPlanId);
      if (analysisResponse['success'] == true) {
        _analysis = NutritionalAnalysis.fromJson(analysisResponse['analysis']);
        debugPrint('Nutritional analysis loaded successfully');
      } else {
        // Analysis is optional, so we don't throw an error
        debugPrint('Failed to load analysis: ${analysisResponse['error']?['message']}');
      }

      // Load weekly trends
      final trendsResponse = await mealPlanningProvider.getWeeklyTrends();
      if (trendsResponse['success'] == true) {
        _weeklyTrends = WeeklyTrends.fromJson(trendsResponse['trends']);
        debugPrint('Weekly trends loaded successfully');
      } else {
        // Trends are optional, so we don't throw an error
        debugPrint('Failed to load trends: ${trendsResponse['error']?['message']}');
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading meal plan data: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          _mealPlan != null 
            ? 'Meal Plan - ${DateFormat('MMM dd').format(_mealPlan!.planDate)}'
            : 'Meal Plan',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green[600],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadMealPlanData,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: _shareMealPlan,
            tooltip: 'Share',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.calendar_today), text: 'Overview'),
            Tab(icon: Icon(Icons.analytics), text: 'Nutrition'),
            Tab(icon: Icon(Icons.trending_up), text: 'Trends'),
            Tab(icon: Icon(Icons.attach_money), text: 'Budget'),
          ],
        ),
      ),
      body: _buildBody(),
      floatingActionButton: _mealPlan != null 
          ? FloatingActionButton.extended(
              onPressed: _generateGroceryList,
              backgroundColor: Colors.blue[600],
              icon: const Icon(Icons.shopping_cart, color: Colors.white),
              label: const Text(
                'Grocery List',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            )
          : null,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading meal plan analysis...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading meal plan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadMealPlanData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_mealPlan == null) {
      return const Center(
        child: Text('Meal plan not found'),
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildOverviewTab(),
        _buildNutritionTab(),
        _buildTrendsTab(),
        _buildBudgetTab(),
      ],
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nutritional Achievements
          if (_analysis?.nutritionalAchievements.isNotEmpty == true)
            Card(
              elevation: 2,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [Colors.green[400]!, Colors.green[600]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.emoji_events, color: Colors.white, size: 24),
                        SizedBox(width: 8),
                        Text(
                          'Achievements',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ..._analysis!.nutritionalAchievements.map((achievement) =>
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.white, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                achievement,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  shadows: [
                                    Shadow(
                                      offset: Offset(0, 1),
                                      blurRadius: 2,
                                      color: Colors.black26,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 16),

          // Meal Plan Calendar
          MealPlanCalendarWidget(
            mealPlan: _mealPlan!,
            selectedDay: _selectedDay,
            onDaySelected: (day) {
              setState(() {
                _selectedDay = day;
              });
            },
          ),

          const SizedBox(height: 16),

          // Daily Meals
          Text(
            'Day $_selectedDay Meals',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[900],
            ),
          ),
          const SizedBox(height: 12),

          ..._mealPlan!.getMealsForDay(_selectedDay).asMap().entries.map((entry) {
            final index = entry.key;
            final meal = entry.value;
            final mealIndex = _mealPlan!.meals.indexWhere((m) => 
              m.day == meal.day && 
              m.mealType == meal.mealType && 
              m.recipeId == meal.recipeId
            );
            
            debugPrint('Meal card for Day ${meal.day} ${meal.mealType}: index in full list = $mealIndex');
            
            return MealCardWidget(
              meal: meal,
              onTap: () => _showRecipeDetails(context, meal),
              onSubstitute: mealIndex >= 0 ? () => _openSubstitution(context, mealIndex) : null,
            );
          }),

          const SizedBox(height: 16),

          // Daily Nutrition Summary
          if (_analysis != null)
            DailyNutritionSummaryWidget(
              dailyAnalysis: _analysis!.dailyAnalyses.firstWhere(
                (da) => da.date.endsWith('day_$_selectedDay'),
                orElse: () => _analysis!.dailyAnalyses.first,
              ),
              day: _selectedDay,
            ),
        ],
      ),
    );
  }

  Widget _buildNutritionTab() {
    if (_analysis == null) {
      return const Center(
        child: Text('Nutritional analysis not available'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nutritional Dashboard
          NutritionalDashboardWidget(
            analysis: _analysis!,
          ),

          const SizedBox(height: 16),

          // Insights
          NutritionInsightsCard(
            insights: _analysis!.insights.where((insight) => insight.isHighPriority).toList(),
            title: 'High Priority Insights',
          ),

          const SizedBox(height: 16),

          // Recommendations
          if (_analysis!.recommendations.isNotEmpty) ...[
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.lightbulb, color: Colors.orange),
                        SizedBox(width: 8),
                        Text(
                          'Personalized Recommendations',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ..._analysis!.recommendations.map((recommendation) =>
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.arrow_right, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(recommendation),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTrendsTab() {
    if (_weeklyTrends == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.trending_up, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Weekly trends not available',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Create more meal plans to see trends',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Weekly Trends
          WeeklyTrendsWidget(
            weeklyTrends: _weeklyTrends!,
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetTab() {
    if (_analysis == null) {
      return const Center(
        child: Text('Cost analysis not available'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cost Tracking
          CostTrackingWidget(
            costAnalysis: _analysis!.costAnalysis,
          ),
        ],
      ),
    );
  }

  void _shareMealPlan() {
    // TODO: Implement meal plan sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sharing functionality coming soon!'),
      ),
    );
  }

  void _showRecipeDetails(BuildContext context, Meal meal) {
    // Navigate to the full recipe detail screen instead of showing modal
    Navigator.pushNamed(
      context,
      '/recipe-details',
      arguments: meal.recipeId,
    );
  }

  void _openSubstitution(BuildContext context, int mealIndex) async {
    if (mealIndex < 0 || _mealPlan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to find meal for substitution'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    debugPrint('Opening substitution for meal index: $mealIndex');
    debugPrint('Total meals in plan: ${_mealPlan!.meals.length}');
    if (mealIndex < _mealPlan!.meals.length) {
      final targetMeal = _mealPlan!.meals[mealIndex];
      debugPrint('Target meal: Day ${targetMeal.day}, ${targetMeal.mealType}, Recipe: ${targetMeal.recipeId}');
    } else {
      debugPrint('ERROR: Meal index $mealIndex is out of bounds!');
    }

    try {
      final authProvider = context.read<AuthProvider>();
      final substitutionProvider = context.read<MealSubstitutionProvider>();

      // Set auth token for substitution service
      if (authProvider.isAuthenticated && authProvider.token != null) {
        substitutionProvider.setAuthToken(authProvider.token!);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please log in to use substitution feature'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Navigate to substitution screen
      final result = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => MealSubstitutionScreen(
            mealPlan: _mealPlan!,
            mealIndex: mealIndex,
          ),
        ),
      );

      // If substitution was successful, update the meal plan
      if (result != null && result is MealPlan) {
        final originalMeal = _mealPlan!.meals[mealIndex];
        final newMeal = result.meals[mealIndex];
        
        debugPrint('Substitution result: ${originalMeal.recipeId} -> ${newMeal.recipeId}');
        debugPrint('Target meal: Day ${originalMeal.day} ${originalMeal.mealType}');
        debugPrint('Result meal: Day ${newMeal.day} ${newMeal.mealType}');
        debugPrint('Meal changed: ${originalMeal.recipeId != newMeal.recipeId}');
        
        // Check if substitution happened to the correct meal
        if (originalMeal.day != newMeal.day || originalMeal.mealType != newMeal.mealType) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error: Substitution affected wrong meal slot'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
          return;
        }
        
        // Update local meal plan immediately
        setState(() {
          _mealPlan = result;
        });
        
        // Also reload from backend to ensure consistency
        await _loadMealPlanData();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(originalMeal.recipeId != newMeal.recipeId 
                ? 'Meal substituted: ${newMeal.recipeName}' 
                : 'Backend substitution failed - meal unchanged despite API success'),
            backgroundColor: originalMeal.recipeId != newMeal.recipeId ? Colors.green : Colors.red,
            duration: Duration(seconds: 4),
            action: originalMeal.recipeId == newMeal.recipeId ? SnackBarAction(
              label: 'Report Bug',
              textColor: Colors.white,
              onPressed: () {
                debugPrint('SUBSTITUTION BUG: Meal index $mealIndex (${originalMeal.day} ${originalMeal.mealType}) not changed');
              },
            ) : null,
          ),
        );
      } else {
        debugPrint('Substitution result was null or not a MealPlan: $result');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Substitution may not have been applied correctly'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening substitution: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _generateGroceryList() async {
    if (_mealPlan == null) return;

    try {
      final authProvider = context.read<AuthProvider>();
      final groceryListProvider = context.read<GroceryListProvider>();

      // Set auth token for grocery list service
      if (authProvider.isAuthenticated && authProvider.token != null) {
        groceryListProvider.setAuthToken(authProvider.token!);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please log in to access grocery lists'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // First, load existing grocery lists to check if one exists for this meal plan
      await groceryListProvider.loadGroceryListHistory();
      
      // Check if there's already a grocery list for this meal plan
      final existingLists = groceryListProvider.groceryListHistory
          .where((list) => list.mealPlanId == _mealPlan!.id);
      final existingList = existingLists.isNotEmpty ? existingLists.first : null;

      if (existingList != null) {
        // Show dialog asking what the user wants to do
        final choice = await showDialog<String>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Grocery List Options'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('A grocery list already exists for this meal plan:'),
                const SizedBox(height: 8),
                Text(
                  '"${existingList.name}"',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text('What would you like to do?'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, 'view'),
                child: const Text('View Existing'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, 'new'),
                child: const Text('Create New'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, 'cancel'),
                child: const Text('Cancel'),
              ),
            ],
          ),
        );

        if (choice == 'view') {
          // Navigate to existing grocery list
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GroceryListScreen(
                groceryListId: existingList.id,
              ),
            ),
          );
          return;
        } else if (choice != 'new') {
          // User cancelled
          return;
        }
      }

      // Generate new grocery list
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Generating grocery list...'),
            ],
          ),
        ),
      );

      // Generate grocery list
      final success = await groceryListProvider.generateGroceryListFromMealPlan(
        _mealPlan!.id,
        listName: 'Grocery List - ${DateFormat('MMM dd').format(_mealPlan!.planDate)}',
      );

      // Close loading dialog
      if (mounted) {
        Navigator.pop(context);
      }

      if (success) {
        final groceryList = groceryListProvider.currentGroceryList;
        if (groceryList != null && mounted) {
          // Navigate to grocery list screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GroceryListScreen(
                groceryListId: groceryList.groceryList.id,
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(groceryListProvider.error ?? 'Failed to generate grocery list'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Close loading dialog if still open
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error with grocery list: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
} 