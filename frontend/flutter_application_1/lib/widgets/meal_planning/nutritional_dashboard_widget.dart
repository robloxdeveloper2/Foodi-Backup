import 'package:flutter/material.dart';
import '../../models/nutritional_analysis.dart';

class NutritionalDashboardWidget extends StatelessWidget {
  final NutritionalAnalysis analysis;
  final int? selectedDay;

  const NutritionalDashboardWidget({
    super.key,
    required this.analysis,
    this.selectedDay,
  });

  @override
  Widget build(BuildContext context) {
    final dailyAnalysis = selectedDay != null 
        ? analysis.dailyAnalyses.firstWhere(
            (da) => da.date.endsWith('day_$selectedDay'),
            orElse: () => analysis.dailyAnalyses.first,
          )
        : null;

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
                  Icons.analytics,
                  color: Colors.blue[600],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  selectedDay != null ? 'Day $selectedDay Nutrition' : 'Nutritional Overview',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Macronutrient Summary
            if (dailyAnalysis != null) ...[
              _buildDailyMacros(dailyAnalysis),
            ] else ...[
              _buildOverallMacros(),
            ],

            const SizedBox(height: 20),

            // Goal Progress
            const Text(
              'Goal Progress',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            if (dailyAnalysis != null) ...[
              _buildGoalProgress(dailyAnalysis.goalAdherence),
            ] else ...[
              _buildGoalProgress(analysis.overallSummary.avgGoalAdherence),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDailyMacros(DailyNutritionAnalysis dailyAnalysis) {
    return Column(
      children: [
        // Calorie Display
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[400]!, Colors.blue[600]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              const Text(
                'Daily Calories',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                dailyAnalysis.calories.toStringAsFixed(0),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
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
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Macronutrient Breakdown
        Row(
          children: [
            Expanded(
              child: _buildMacroCard(
                'Protein',
                '${dailyAnalysis.protein.toStringAsFixed(1)}g',
                '${dailyAnalysis.proteinPercentage.toStringAsFixed(0)}%',
                Colors.red[400]!,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMacroCard(
                'Carbs',
                '${dailyAnalysis.carbs.toStringAsFixed(1)}g',
                '${dailyAnalysis.carbsPercentage.toStringAsFixed(0)}%',
                Colors.orange[400]!,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMacroCard(
                'Fat',
                '${dailyAnalysis.fat.toStringAsFixed(1)}g',
                '${dailyAnalysis.fatPercentage.toStringAsFixed(0)}%',
                Colors.yellow[600]!,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Additional Nutrients
        Row(
          children: [
            Expanded(
              child: _buildNutrientInfo('Fiber', '${dailyAnalysis.fiber.toStringAsFixed(1)}g'),
            ),
            Expanded(
              child: _buildNutrientInfo('Sodium', '${dailyAnalysis.sodium.toStringAsFixed(0)}mg'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOverallMacros() {
    final summary = analysis.overallSummary;
    return Column(
      children: [
        // Average Calorie Display
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green[400]!, Colors.green[600]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              const Text(
                'Average Daily Calories',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                summary.avgDailyCalories.toStringAsFixed(0),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
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
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Average Macronutrient Breakdown
        Row(
          children: [
            Expanded(
              child: _buildMacroCard(
                'Protein',
                '${summary.avgDailyProtein.toStringAsFixed(1)}g',
                '${summary.avgProteinPercentage.toStringAsFixed(0)}%',
                Colors.red[400]!,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMacroCard(
                'Carbs',
                '${summary.avgDailyCarbs.toStringAsFixed(1)}g',
                '${summary.avgCarbsPercentage.toStringAsFixed(0)}%',
                Colors.orange[400]!,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMacroCard(
                'Fat',
                '${summary.avgDailyFat.toStringAsFixed(1)}g',
                '${summary.avgFatPercentage.toStringAsFixed(0)}%',
                Colors.yellow[600]!,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMacroCard(String name, String amount, String percentage, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color.withValues(alpha: 0.8),
            ),
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
        ],
      ),
    );
  }

  Widget _buildNutrientInfo(String name, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalProgress(Map<String, double> goalAdherence) {
    final nutrients = ['calories', 'protein', 'carbs', 'fat'];
    
    return Column(
      children: nutrients.map((nutrient) {
        final progress = goalAdherence[nutrient] ?? 0.0;
        final isOnTarget = progress >= 90 && progress <= 110;
        final color = isOnTarget ? Colors.green : (progress < 90 ? Colors.orange : Colors.red);
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
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
      }).toList(),
    );
  }
} 