import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/meal_plan.dart';

class MealPlanDetailView extends StatelessWidget {
  final MealPlan mealPlan;

  const MealPlanDetailView({
    super.key,
    required this.mealPlan,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('${mealPlan.durationDays} Day Meal Plan'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: Implement share functionality
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Plan Overview Card
            _buildPlanOverviewCard(),
            const SizedBox(height: 20),
            
            // Daily Meal Plans
            _buildDailyMealPlans(),
            
            const SizedBox(height: 20),
            
            // Nutritional Summary
            _buildNutritionalSummary(),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanOverviewCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[600]!, Colors.blue[400]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Meal Plan',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${DateFormat('MMM dd').format(mealPlan.planDate)} - ${DateFormat('MMM dd, yyyy').format(mealPlan.endDate)}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildOverviewStat(
                  icon: Icons.restaurant_menu,
                  label: 'Total Meals',
                  value: '${mealPlan.meals.length}',
                ),
                const SizedBox(width: 20),
                _buildOverviewStat(
                  icon: Icons.attach_money,
                  label: 'Total Cost',
                  value: '\$${mealPlan.estimatedTotalCostUsd.toStringAsFixed(2)}',
                ),
                const SizedBox(width: 20),
                _buildOverviewStat(
                  icon: Icons.local_fire_department,
                  label: 'Daily Calories',
                  value: '${(mealPlan.totalNutritionSummary.calories / mealPlan.durationDays).round()}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewStat({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildDailyMealPlans() {
    // Group meals by day
    Map<int, List<Meal>> mealsByDay = {};
    for (var meal in mealPlan.meals) {
      if (!mealsByDay.containsKey(meal.day)) {
        mealsByDay[meal.day] = [];
      }
      mealsByDay[meal.day]!.add(meal);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Daily Meal Plan',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...mealsByDay.entries.map((entry) {
          final day = entry.key;
          final meals = entry.value;
          
          // Sort meals by meal type order
          meals.sort((a, b) {
            const order = ['breakfast', 'lunch', 'dinner', 'snack'];
            return order.indexOf(a.mealType).compareTo(order.indexOf(b.mealType));
          });
          
          return _buildDayCard(day, meals);
        }),
      ],
    );
  }

  Widget _buildDayCard(int day, List<Meal> meals) {
    final date = mealPlan.planDate.add(Duration(days: day - 1));
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Day Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Day $day',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  DateFormat('EEEE, MMM dd').format(date),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Meals for this day
            ...meals.map((meal) => Builder(
              builder: (context) => _buildMealCard(context, meal),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildMealCard(BuildContext context, Meal meal) {
    IconData mealIcon;
    Color mealColor;
    
    switch (meal.mealType.toLowerCase()) {
      case 'breakfast':
        mealIcon = Icons.free_breakfast;
        mealColor = Colors.orange;
        break;
      case 'lunch':
        mealIcon = Icons.lunch_dining;
        mealColor = Colors.green;
        break;
      case 'dinner':
        mealIcon = Icons.dinner_dining;
        mealColor = Colors.red;
        break;
      case 'snack':
        mealIcon = Icons.cookie;
        mealColor = Colors.purple;
        break;
      default:
        mealIcon = Icons.restaurant;
        mealColor = Colors.grey;
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: mealColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: mealColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          // Meal Type Icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: mealColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(mealIcon, color: mealColor, size: 24),
          ),
          
          const SizedBox(width: 16),
          
          // Meal Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.mealType.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: mealColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  meal.recipeName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Score: ${meal.score.toStringAsFixed(1)}/1.0',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          
          // Quick Actions
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              _showRecipeDetails(context, meal);
            },
            tooltip: 'Recipe Details',
          ),
        ],
      ),
    );
  }

  void _showRecipeDetails(BuildContext context, Meal meal) {
    // TODO: Implement recipe details modal
  }

  Widget _buildNutritionalSummary() {
    final nutrition = mealPlan.totalNutritionSummary;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nutritional Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Daily averages
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'Daily Averages',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNutritionStat(
                        'Calories',
                        '${(nutrition.calories / mealPlan.durationDays).round()}',
                        'kcal',
                        Colors.orange,
                      ),
                      _buildNutritionStat(
                        'Protein',
                        '${(nutrition.protein / mealPlan.durationDays).round()}g',
                        '${nutrition.proteinPercentage.round()}%',
                        Colors.red,
                      ),
                      _buildNutritionStat(
                        'Carbs',
                        '${(nutrition.carbs / mealPlan.durationDays).round()}g',
                        '${nutrition.carbsPercentage.round()}%',
                        Colors.blue,
                      ),
                      _buildNutritionStat(
                        'Fat',
                        '${(nutrition.fat / mealPlan.durationDays).round()}g',
                        '${nutrition.fatPercentage.round()}%',
                        Colors.purple,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Total nutrition
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'Total for ${mealPlan.durationDays} Days',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue[800],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNutritionStat(
                        'Calories',
                        '${nutrition.calories.round()}',
                        'kcal',
                        Colors.orange,
                      ),
                      _buildNutritionStat(
                        'Protein',
                        '${nutrition.protein.round()}g',
                        '',
                        Colors.red,
                      ),
                      _buildNutritionStat(
                        'Carbs',
                        '${nutrition.carbs.round()}g',
                        '',
                        Colors.blue,
                      ),
                      _buildNutritionStat(
                        'Fat',
                        '${nutrition.fat.round()}g',
                        '',
                        Colors.purple,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionStat(String label, String value, String subtitle, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        if (subtitle.isNotEmpty)
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[500],
            ),
          ),
      ],
    );
  }
} 