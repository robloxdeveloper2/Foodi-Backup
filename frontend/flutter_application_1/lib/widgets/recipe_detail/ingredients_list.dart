import 'package:flutter/material.dart';
import '../../models/recipe_detail_models.dart';
import '../../utils/app_constants.dart';

class IngredientsList extends StatelessWidget {
  final List<IngredientWithSubstitutions> ingredients;
  final int originalServings;
  final int scaledServings;

  const IngredientsList({
    Key? key,
    required this.ingredients,
    required this.originalServings,
    required this.scaledServings,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with serving info
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Ingredients',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (scaledServings != originalServings)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Scaled for $scaledServings servings',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
        
        const SizedBox(height: AppConstants.defaultPadding),
        
        // Ingredients list
        ...ingredients.asMap().entries.map((entry) {
          final index = entry.key;
          final ingredient = entry.value;
          
          return Container(
            margin: const EdgeInsets.only(bottom: AppConstants.smallPadding),
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
                // Main ingredient
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppConstants.smallPadding),
                    Expanded(
                      child: Text(
                        ingredient.displayText,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                
                // Substitutions
                if (ingredient.hasSubstitutions) ...[
                  const SizedBox(height: AppConstants.smallPadding),
                  Text(
                    'Substitutions:',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: ingredient.substitutions.map((substitution) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          substitution,
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
} 