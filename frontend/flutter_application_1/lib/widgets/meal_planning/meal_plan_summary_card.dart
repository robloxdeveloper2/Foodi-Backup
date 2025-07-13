import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/meal_plan.dart';

class MealPlanSummaryCard extends StatelessWidget {
  final MealPlan mealPlan;
  final VoidCallback? onRegeneratePressed;
  final VoidCallback? onViewDetailsPressed;

  const MealPlanSummaryCard({
    super.key,
    required this.mealPlan,
    this.onRegeneratePressed,
    this.onViewDetailsPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[600]!, Colors.blue[400]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${mealPlan.durationDays} ${mealPlan.durationDays == 1 ? 'Day' : 'Days'} Meal Plan',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${DateFormat('MMM dd').format(mealPlan.planDate)} - ${DateFormat('MMM dd, yyyy').format(mealPlan.endDate)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    (mealPlan.isWithinBudget ?? false) ? Icons.check_circle : 
                    (mealPlan.isWithinBudget == null) ? Icons.info : Icons.warning,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quick Stats Row
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.restaurant,
                        label: 'Meals',
                        value: '${mealPlan.meals.length}',
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.local_fire_department,
                        label: 'Avg Calories',
                        value: '${(mealPlan.totalNutritionSummary.calories / mealPlan.durationDays).round()}',
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.attach_money,
                        label: 'Total Cost',
                        value: '\$${mealPlan.estimatedTotalCostUsd.toStringAsFixed(2)}',
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Budget Status
                if (mealPlan.budgetTargetUsd != null) ...[
                  const Text(
                    'Budget Status',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildBudgetStatus(),
                  const SizedBox(height: 20),
                ],

                // Nutrition Overview
                const Text(
                  'Nutrition Overview',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                _buildNutritionOverview(),

                const SizedBox(height: 20),

                // Today's Meals Preview (if plan is active)
                if (mealPlan.isActive) ...[
                  const Text(
                    'Today\'s Meals',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildTodaysMeals(),
                  const SizedBox(height: 20),
                ] else ...[
                  const Text(
                    'Meal Preview',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildMealPreview(),
                  const SizedBox(height: 20),
                ],

                // Dietary Restrictions
                if (mealPlan.dietaryRestrictionsUsed.isNotEmpty) ...[
                  const Text(
                    'Dietary Restrictions',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: mealPlan.dietaryRestrictionsUsed.map((restriction) {
                      return Chip(
                        label: Text(
                          restriction.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        backgroundColor: Colors.green[100],
                        side: BorderSide(color: Colors.green[300]!),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                ],

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onRegeneratePressed,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Regenerate'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(color: Colors.blue[600]!),
                          foregroundColor: Colors.blue[600],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onViewDetailsPressed,
                        icon: const Icon(Icons.visibility),
                        label: const Text('View Details'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetStatus() {
    final targetBudget = mealPlan.budgetTargetUsd!;
    final actualCost = mealPlan.estimatedTotalCostUsd;
    final percentage = (actualCost / targetBudget) * 100;
    final isOverBudget = percentage > 110; // 10% tolerance
    final isNearBudget = percentage > 90 && percentage <= 110;

    Color statusColor;
    String statusText;
    
    if (isOverBudget) {
      statusColor = Colors.red;
      statusText = 'Over Budget';
    } else if (isNearBudget) {
      statusColor = Colors.orange;
      statusText = 'Near Budget';
    } else {
      statusColor = Colors.green;
      statusText = 'Under Budget';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            isOverBudget ? Icons.warning : Icons.check_circle,
            color: statusColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
                Text(
                  '\$${actualCost.toStringAsFixed(2)} of \$${targetBudget.toStringAsFixed(2)} (${percentage.round()}%)',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionOverview() {
    final nutrition = mealPlan.totalNutritionSummary;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNutritionItem(
                'Calories',
                '${nutrition.calories.round()}',
                'kcal',
                Colors.orange,
              ),
              _buildNutritionItem(
                'Protein',
                '${nutrition.protein.round()}g',
                '${nutrition.proteinPercentage.round()}%',
                Colors.red,
              ),
              _buildNutritionItem(
                'Carbs',
                '${nutrition.carbs.round()}g',
                '${nutrition.carbsPercentage.round()}%',
                Colors.blue,
              ),
              _buildNutritionItem(
                'Fat',
                '${nutrition.fat.round()}g',
                '${nutrition.fatPercentage.round()}%',
                Colors.purple,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionItem(String label, String value, String subtitle, Color color) {
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

  Widget _buildTodaysMeals() {
    // Calculate which day of the plan we're currently on
    final now = DateTime.now();
    final daysSinceStart = now.difference(mealPlan.planDate).inDays + 1;
    
    // If we're past the plan, show the last day's meals
    final currentDay = daysSinceStart > mealPlan.durationDays 
        ? mealPlan.durationDays 
        : (daysSinceStart < 1 ? 1 : daysSinceStart);
    
    final todaysMeals = mealPlan.getMealsForDay(currentDay);
    
    if (todaysMeals.isEmpty) {
      return _buildMealPreview(); // Fallback to preview if no meals found
    }
    
    // Sort meals by meal type order
    todaysMeals.sort((a, b) {
      const order = ['breakfast', 'lunch', 'dinner', 'snack'];
      return order.indexOf(a.mealType).compareTo(order.indexOf(b.mealType));
    });

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.today, color: Colors.blue[700], size: 20),
              const SizedBox(width: 8),
              Text(
                'Day $currentDay - ${DateFormat('EEEE, MMM dd').format(mealPlan.planDate.add(Duration(days: currentDay - 1)))}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...todaysMeals.map((meal) => _buildMealPreviewItem(meal)),
        ],
      ),
    );
  }

  Widget _buildMealPreview() {
    // Show first day's meals as preview
    final firstDayMeals = mealPlan.getMealsForDay(1);
    
    if (firstDayMeals.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            'No meals available for preview',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }
    
    // Sort meals by meal type order
    firstDayMeals.sort((a, b) {
      const order = ['breakfast', 'lunch', 'dinner', 'snack'];
      return order.indexOf(a.mealType).compareTo(order.indexOf(b.mealType));
    });

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.preview, color: Colors.grey[700], size: 20),
              const SizedBox(width: 8),
              Text(
                'Day 1 Preview',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...firstDayMeals.map((meal) => _buildMealPreviewItem(meal)),
        ],
      ),
    );
  }

  Widget _buildMealPreviewItem(Meal meal) {
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
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: mealColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: mealColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(mealIcon, color: mealColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.mealType.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: mealColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  meal.recipeName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              meal.score.toStringAsFixed(1),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 