import 'package:flutter/material.dart';
import '../../models/recipe_models.dart';
import '../../utils/app_constants.dart';

class NutritionCard extends StatelessWidget {
  final NutritionalInfo? nutrition;
  final int servings;
  final double? costPerServing;

  const NutritionCard({
    Key? key,
    required this.nutrition,
    required this.servings,
    this.costPerServing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (nutrition == null) {
      return Container(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: const Center(
          child: Text(
            'Nutritional information not available',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Nutrition Facts',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Per serving ($servings total)',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppConstants.defaultPadding),
          
          // Calories (prominent)
          Container(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Calories',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Text(
                  '${nutrition!.calories.round()}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: AppConstants.defaultPadding),
          
          // Macronutrients
          Column(
            children: [
              if (nutrition!.protein != null)
                _buildNutrientRow(
                  context,
                  'Protein',
                  '${nutrition!.protein!.round()}g',
                  Icons.fitness_center,
                  Colors.red,
                ),
              if (nutrition!.carbs != null)
                _buildNutrientRow(
                  context,
                  'Carbohydrates',
                  '${nutrition!.carbs!.round()}g',
                  Icons.grain,
                  Colors.orange,
                ),
              if (nutrition!.fat != null)
                _buildNutrientRow(
                  context,
                  'Fat',
                  '${nutrition!.fat!.round()}g',
                  Icons.opacity,
                  Colors.yellow,
                ),
              if (nutrition!.fiber != null)
                _buildNutrientRow(
                  context,
                  'Fiber',
                  '${nutrition!.fiber!.round()}g',
                  Icons.eco,
                  Colors.green,
                ),
              if (nutrition!.sugar != null)
                _buildNutrientRow(
                  context,
                  'Sugar',
                  '${nutrition!.sugar!.round()}g',
                  Icons.cake,
                  Colors.pink,
                ),
              if (nutrition!.sodium != null)
                _buildNutrientRow(
                  context,
                  'Sodium',
                  '${nutrition!.sodium!.round()}mg',
                  Icons.water_drop,
                  Colors.blue,
                ),
            ],
          ),
          
          // Cost per serving
          if (costPerServing != null) ...[
            const SizedBox(height: AppConstants.defaultPadding),
            const Divider(),
            const SizedBox(height: AppConstants.smallPadding),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.attach_money,
                      size: 16,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Cost per serving',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
                Text(
                  '\$${costPerServing!.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNutrientRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: color,
          ),
          const SizedBox(width: AppConstants.smallPadding),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
} 