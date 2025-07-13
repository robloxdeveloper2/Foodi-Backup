import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../providers/meal_planning_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_routes.dart';
import '../../widgets/meal_planning/meal_plan_generator_widget.dart';
import '../../widgets/meal_planning/generation_progress_indicator.dart';
import '../../widgets/meal_planning/meal_plan_summary_card.dart';

class MealPlanGenerationScreen extends StatefulWidget {
  const MealPlanGenerationScreen({super.key});

  @override
  State<MealPlanGenerationScreen> createState() => _MealPlanGenerationScreenState();
}

class _MealPlanGenerationScreenState extends State<MealPlanGenerationScreen> {
  @override
  void initState() {
    super.initState();
    // Set up authentication and load meal plan history when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final mealPlanningProvider = context.read<MealPlanningProvider>();
      
      // Set auth token if user is authenticated
      if (authProvider.isAuthenticated && authProvider.token != null) {
        mealPlanningProvider.setAuthToken(authProvider.token!);
      }
      
      // Load meal plan history
      mealPlanningProvider.loadMealPlanHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Meal Planning',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green[600],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.mealSwiping);
            },
            tooltip: 'Discover Meals',
          ),
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: () => _showMealPlanHistory(context),
          ),
          IconButton(
            icon: const Icon(Icons.analytics, color: Colors.white),
            onPressed: () => _showStats(context),
          ),
        ],
      ),
      body: Consumer<MealPlanningProvider>(
        builder: (context, mealPlanningProvider, child) {
          if (mealPlanningProvider.isGenerating) {
            return const Center(
              child: GenerationProgressIndicator(),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Card
                Card(
                  elevation: 4,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: [Colors.green[600]!, Colors.green[400]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.restaurant_menu,
                          color: Colors.white,
                          size: 32,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Smart Meal Planning',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Generate personalized meal plans based on your preferences, dietary restrictions, and budget',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Discover Meals Feature Card
                Card(
                  elevation: 2,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: [Colors.pink[400]!, Colors.purple[400]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Discover Meals',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Swipe through meals to teach us your preferences',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(context, AppRoutes.mealSwiping);
                          },
                          icon: const Icon(Icons.favorite, size: 18),
                          label: const Text('Start'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.purple[600],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Error Display
                if (mealPlanningProvider.error != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error, color: Colors.red[600]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            mealPlanningProvider.error!,
                            style: TextStyle(color: Colors.red[800]),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          color: Colors.red[600],
                          onPressed: () => mealPlanningProvider.clearError(),
                        ),
                      ],
                    ),
                  ),

                // Current Meal Plan or Generator
                if (mealPlanningProvider.hasMealPlan)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Your Current Meal Plan',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[900],
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () => _showGeneratorBottomSheet(context),
                            icon: const Icon(Icons.add),
                            label: const Text('New Plan'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      MealPlanSummaryCard(
                        mealPlan: mealPlanningProvider.currentMealPlan!,
                        onRegeneratePressed: () => _showRegenerateDialog(context),
                        onViewDetailsPressed: () => _navigateToMealPlanDetails(context),
                      ),
                    ],
                  ),

                const SizedBox(height: 24),

                // Recent Meal Plans
                if (mealPlanningProvider.mealPlanHistory.isNotEmpty) ...[
                  Text(
                    'Recent Meal Plans',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[900],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...mealPlanningProvider.mealPlanHistory.take(3).map(
                        (mealPlan) => Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.green[100],
                              child: Icon(
                                Icons.calendar_today,
                                color: Colors.green[600],
                              ),
                            ),
                            title: Text(
                              '${mealPlan.durationDays} ${mealPlan.durationDays == 1 ? 'Day' : 'Days'} Plan',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              '${DateFormat('MMM dd, yyyy').format(mealPlan.planDate)} • \$${mealPlan.estimatedTotalCostUsd.toStringAsFixed(2)}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (mealPlan.userRating != null)
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.star,
                                        size: 16,
                                        color: Colors.amber[600],
                                      ),
                                      Text('${mealPlan.userRating}'),
                                    ],
                                  ),
                                const SizedBox(width: 8),
                                Icon(
                                  (mealPlan.isWithinBudget ?? false)
                                      ? Icons.check_circle
                                      : (mealPlan.isWithinBudget == null) 
                                          ? Icons.info 
                                          : Icons.warning,
                                  color: (mealPlan.isWithinBudget ?? false)
                                      ? Colors.green
                                      : (mealPlan.isWithinBudget == null) 
                                          ? Colors.grey 
                                          : Colors.orange,
                                  size: 20,
                                ),
                              ],
                            ),
                            onTap: () => _loadMealPlan(mealPlan.id),
                          ),
                        ),
                      ),
                  if (mealPlanningProvider.mealPlanHistory.length > 3)
                    TextButton(
                      onPressed: () => _showMealPlanHistory(context),
                      child: const Text('View All Plans'),
                    ),
                  
                  const SizedBox(height: 24),
                ],

                // Generate Your Meal Plan (moved after recent plans)
                if (!mealPlanningProvider.hasMealPlan)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Generate Your Meal Plan',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[900],
                        ),
                      ),
                      const SizedBox(height: 16),
                      MealPlanGeneratorWidget(
                        onGeneratePressed: ({
                          required int durationDays,
                          String? planDate,
                          double? budgetUsd,
                          bool includeSnacks = false,
                        }) async {
                          await _generateMealPlan(
                            durationDays: durationDays,
                            planDate: planDate,
                            budgetUsd: budgetUsd,
                            includeSnacks: includeSnacks,
                          );
                        },
                      ),
                    ],
                  )
                else
                  // Show "Create New Plan" section when user has a current plan
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create New Meal Plan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[900],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue[100],
                            child: Icon(
                              Icons.add,
                              color: Colors.blue[600],
                            ),
                          ),
                          title: const Text(
                            'Generate New Plan',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: const Text(
                            'Create a fresh meal plan with new recipes',
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () => _showGeneratorBottomSheet(context),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _generateMealPlan({
    required int durationDays,
    String? planDate,
    double? budgetUsd,
    bool includeSnacks = false,
  }) async {
    final provider = context.read<MealPlanningProvider>();
    final success = await provider.generateMealPlan(
      durationDays: durationDays,
      planDate: planDate,
      budgetUsd: budgetUsd,
      includeSnacks: includeSnacks,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Meal plan generated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _loadMealPlan(String planId) async {
    // Navigate to meal plan view screen
    Navigator.pushNamed(
      context,
      '/meal-plan-view',
      arguments: planId,
    );
  }

  void _showGeneratorBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Generate New Meal Plan',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              MealPlanGeneratorWidget(
                onGeneratePressed: ({
                  required int durationDays,
                  String? planDate,
                  double? budgetUsd,
                  bool includeSnacks = false,
                }) async {
                  Navigator.pop(context);
                  await _generateMealPlan(
                    durationDays: durationDays,
                    planDate: planDate,
                    budgetUsd: budgetUsd,
                    includeSnacks: includeSnacks,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRegenerateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Regenerate Meal Plan'),
        content: const Text(
          'Would you like to regenerate your meal plan with different recipes? You can also provide feedback to help improve future suggestions.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final provider = context.read<MealPlanningProvider>();
              final success = await provider.regenerateMealPlan();
              
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Meal plan regenerated successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Regenerate'),
          ),
        ],
      ),
    );
  }

  void _showMealPlanHistory(BuildContext context) {
    // TODO: Navigate to meal plan history screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Meal plan history screen - Coming soon!')),
    );
  }

  void _showStats(BuildContext context) {
    // TODO: Navigate to statistics screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Statistics screen - Coming soon!')),
    );
  }

  void _navigateToMealPlanDetails(BuildContext context) {
    final mealPlan = context.read<MealPlanningProvider>().currentMealPlan;
    if (mealPlan != null) {
      Navigator.pushNamed(
        context,
        '/meal-plan-view',
        arguments: mealPlan.id,
      );
    }
  }
} 