import 'package:flutter/material.dart';
import '../../models/nutritional_analysis.dart';

class DailyNutritionSummaryWidget extends StatelessWidget {
  final DailyNutritionAnalysis dailyAnalysis;
  final int day;

  const DailyNutritionSummaryWidget({
    super.key,
    required this.dailyAnalysis,
    required this.day,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.restaurant_menu,
                  color: Colors.teal[600],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Day $day Nutrition Summary',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const Spacer(),
                Text(
                  '\$${dailyAnalysis.costUsd.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Main Calories Display
            _buildCaloriesDisplay(),

            const SizedBox(height: 16),

            // Macronutrients
            _buildMacronutrients(),

            const SizedBox(height: 16),

            // Additional Nutrients
            _buildAdditionalNutrients(),

            const SizedBox(height: 16),

            // Goal Progress
            _buildGoalProgress(),

            // Daily Insights
            if (dailyAnalysis.insights.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildDailyInsights(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCaloriesDisplay() {
    final goalAdherence = dailyAnalysis.goalAdherence['calories'] ?? 0.0;
    final isOnTarget = goalAdherence >= 90 && goalAdherence <= 110;
    final color = isOnTarget ? Colors.green[600]! : 
                 goalAdherence < 90 ? Colors.orange[600]! : Colors.red[600]!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.7), color],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            'Daily Calories',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            dailyAnalysis.calories.toStringAsFixed(0),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'kcal',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${goalAdherence.toStringAsFixed(0)}% of goal',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacronutrients() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Macronutrients',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMacroCard(
                'Protein',
                '${dailyAnalysis.protein.toStringAsFixed(1)}g',
                '${dailyAnalysis.proteinPercentage.toStringAsFixed(0)}%',
                Colors.red[500]!,
                dailyAnalysis.goalAdherence['protein'] ?? 0.0,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMacroCard(
                'Carbs',
                '${dailyAnalysis.carbs.toStringAsFixed(1)}g',
                '${dailyAnalysis.carbsPercentage.toStringAsFixed(0)}%',
                Colors.orange[500]!,
                dailyAnalysis.goalAdherence['carbs'] ?? 0.0,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMacroCard(
                'Fat',
                '${dailyAnalysis.fat.toStringAsFixed(1)}g',
                '${dailyAnalysis.fatPercentage.toStringAsFixed(0)}%',
                Colors.yellow[700]!,
                dailyAnalysis.goalAdherence['fat'] ?? 0.0,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMacroCard(String name, String amount, String percentage, Color color, double goalAdherence) {
    final isOnTarget = goalAdherence >= 90 && goalAdherence <= 110;
    final borderColor = isOnTarget ? Colors.green[400]! : color.withValues(alpha: 0.3);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: isOnTarget ? 2 : 1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
              if (isOnTarget)
                Icon(
                  Icons.check_circle,
                  size: 12,
                  color: Colors.green[600],
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            percentage,
            style: TextStyle(
              fontSize: 11,
              color: color.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${goalAdherence.toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: isOnTarget ? Colors.green[600] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalNutrients() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Additional Nutrients',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildNutrientItem(
                  'Fiber',
                  '${dailyAnalysis.fiber.toStringAsFixed(1)}g',
                  Icons.grass,
                  Colors.green[600]!,
                ),
              ),
              Container(
                height: 40,
                width: 1,
                color: Colors.grey[300],
              ),
              Expanded(
                child: _buildNutrientItem(
                  'Sodium',
                  '${dailyAnalysis.sodium.toStringAsFixed(0)}mg',
                  Icons.opacity,
                  Colors.blue[600]!,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNutrientItem(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGoalProgress() {
    final nutrients = ['calories', 'protein', 'carbs', 'fat'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Goal Progress',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 12),
        ...nutrients.map((nutrient) {
          final progress = dailyAnalysis.goalAdherence[nutrient] ?? 0.0;
          final isOnTarget = progress >= 90 && progress <= 110;
          final color = isOnTarget ? Colors.green[600]! : 
                       progress < 90 ? Colors.orange[600]! : Colors.red[600]!;
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      nutrient.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Row(
                      children: [
                        if (isOnTarget)
                          Icon(
                            Icons.check_circle,
                            size: 14,
                            color: Colors.green[600],
                          ),
                        const SizedBox(width: 4),
                        Text(
                          '${progress.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: (progress / 100).clamp(0.0, 1.5),
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 6,
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildDailyInsights() {
    // Filter for high priority insights only
    final highPriorityInsights = dailyAnalysis.insights
        .where((insight) => insight.priority <= 2)
        .take(3)
        .toList();

    if (highPriorityInsights.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daily Insights',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        ...highPriorityInsights.map((insight) =>
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getInsightColor(insight.type).withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: _getInsightColor(insight.type).withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    _getInsightIcon(insight.type),
                    size: 14,
                    color: _getInsightColor(insight.type),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          insight.message,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          insight.suggestion,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
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
      ],
    );
  }

  Color _getInsightColor(String type) {
    switch (type.toLowerCase()) {
      case 'achievement':
        return Colors.green[600]!;
      case 'warning':
        return Colors.orange[600]!;
      case 'suggestion':
        return Colors.blue[600]!;
      case 'info':
        return Colors.grey[600]!;
      default:
        return Colors.grey[600]!;
    }
  }

  IconData _getInsightIcon(String type) {
    switch (type.toLowerCase()) {
      case 'achievement':
        return Icons.emoji_events;
      case 'warning':
        return Icons.warning_rounded;
      case 'suggestion':
        return Icons.lightbulb;
      case 'info':
        return Icons.info;
      default:
        return Icons.info;
    }
  }
} 