import 'package:flutter/material.dart';
import '../../models/meal_plan.dart';

class MealCardWidget extends StatelessWidget {
  final Meal meal;
  final VoidCallback? onTap;
  final VoidCallback? onSubstitute;
  final bool showScore;
  final bool isCompleted;
  final Function(bool)? onCompletionChanged;
  final bool showSubstituteButton;

  const MealCardWidget({
    super.key,
    required this.meal,
    this.onTap,
    this.onSubstitute,
    this.showScore = true,
    this.isCompleted = false,
    this.onCompletionChanged,
    this.showSubstituteButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with meal type and completion
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getMealTypeColor(meal.mealType).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: _getMealTypeColor(meal.mealType).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getMealTypeIcon(meal.mealType),
                            size: 14,
                            color: _getMealTypeColor(meal.mealType),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            meal.mealType.toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: _getMealTypeColor(meal.mealType),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    if (onCompletionChanged != null)
                      GestureDetector(
                        onTap: () => onCompletionChanged!(!isCompleted),
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: isCompleted ? Colors.green : Colors.transparent,
                            border: Border.all(
                              color: isCompleted ? Colors.green : Colors.grey[400]!,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: isCompleted
                              ? const Icon(
                                  Icons.check,
                                  size: 16,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 12),

                // Recipe name
                Text(
                  meal.recipeName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 8),

                // Cost and Recipe ID Row
                Row(
                  children: [
                    // Cost information on the left
                    if (meal.estimatedCostUsd != null) ...[
                      Icon(
                        Icons.attach_money,
                        size: 16,
                        color: Colors.green[600],
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '\$${meal.estimatedCostUsd!.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.green[700],
                        ),
                      ),
                    ] else ...[
                      Icon(
                        Icons.help_outline,
                        size: 16,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(width: 2),
                      Text(
                        'No cost',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                    const SizedBox(width: 16),
                    // Recipe ID
                    Icon(
                      Icons.receipt,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Recipe: ${meal.recipeId}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Score and Day Row
                Row(
                  children: [
                    if (showScore) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getScoreColor(meal.score).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: _getScoreColor(meal.score).withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              size: 12,
                              color: _getScoreColor(meal.score),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              meal.score.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: _getScoreColor(meal.score),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Day ${meal.day}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Substitute button
                    if (showSubstituteButton && onSubstitute != null)
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: onSubstitute,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.blue[300]!,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.swap_horiz,
                                  size: 16,
                                  color: Colors.blue[700],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Substitute',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getMealTypeColor(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return Colors.orange[600]!;
      case 'lunch':
        return Colors.blue[600]!;
      case 'dinner':
        return Colors.purple[600]!;
      case 'snack':
        return Colors.green[600]!;
      default:
        return Colors.grey[600]!;
    }
  }

  IconData _getMealTypeIcon(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return Icons.free_breakfast;
      case 'lunch':
        return Icons.lunch_dining;
      case 'dinner':
        return Icons.dinner_dining;
      case 'snack':
        return Icons.cookie;
      default:
        return Icons.restaurant;
    }
  }

  Color _getScoreColor(double score) {
    if (score >= 0.8) {
      return Colors.green[600]!;
    } else if (score >= 0.6) {
      return Colors.orange[600]!;
    } else {
      return Colors.red[600]!;
    }
  }
} 