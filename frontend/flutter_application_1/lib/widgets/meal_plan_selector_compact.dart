import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/meal_planning_provider.dart';
import '../models/meal_plan.dart';
import 'meal_plan_selector.dart';

class MealPlanSelectorCompact extends StatelessWidget {
  final bool showDate;
  final bool showCost;

  const MealPlanSelectorCompact({
    Key? key,
    this.showDate = true,
    this.showCost = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<MealPlanningProvider>(
      builder: (context, provider, child) {
        if (!provider.hasSelectedMealPlan) {
          return _buildNoSelectionChip(context, provider);
        }

        final selectedPlan = provider.selectedMealPlan!;
        return _buildSelectedPlanChip(context, provider, selectedPlan);
      },
    );
  }

  Widget _buildNoSelectionChip(BuildContext context, MealPlanningProvider provider) {
    return InkWell(
      onTap: () => _showMealPlanSelector(context),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.restaurant_menu,
              size: 16,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 6),
            Text(
              'Select meal plan',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              size: 20,
              color: Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedPlanChip(BuildContext context, MealPlanningProvider provider, MealPlanListItem selectedPlan) {
    return InkWell(
      onTap: () => _showMealPlanSelector(context),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.green[200]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              size: 16,
              color: Colors.green[600],
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatMealPlanTitle(selectedPlan),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.green[700],
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (showDate || showCost) ...[
                    const SizedBox(height: 2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (showDate) ...[
                          Text(
                            _formatCompactDate(selectedPlan.planDate),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green[600],
                            ),
                          ),
                          if (showCost && selectedPlan.estimatedTotalCostUsd > 0) 
                            Text(
                              ' • ',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green[600],
                              ),
                            ),
                        ],
                        if (showCost && selectedPlan.estimatedTotalCostUsd > 0)
                          Text(
                            '\$${selectedPlan.estimatedTotalCostUsd.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              size: 20,
              color: Colors.green[600],
            ),
          ],
        ),
      ),
    );
  }

  void _showMealPlanSelector(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const MealPlanSelectorModal(),
    );
  }

  String _formatMealPlanTitle(MealPlanListItem plan) {
    final date = plan.planDate;
    return '${date.month}/${date.day} Week';
  }

  String _formatCompactDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '${difference}d ago';
    } else {
      return '${date.month}/${date.day}';
    }
  }
}

class MealPlanSelectorButton extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final bool compact;

  const MealPlanSelectorButton({
    Key? key,
    this.label,
    this.icon,
    this.compact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<MealPlanningProvider>(
      builder: (context, provider, child) {
        final selectedPlan = provider.selectedMealPlan;
        final displayLabel = label ?? (selectedPlan != null 
            ? _formatMealPlanTitle(selectedPlan)
            : 'Select Meal Plan');

        if (compact) {
          return IconButton(
            onPressed: () => _showMealPlanSelector(context),
            icon: Icon(icon ?? Icons.restaurant_menu),
            tooltip: displayLabel,
          );
        }

        return TextButton.icon(
          onPressed: () => _showMealPlanSelector(context),
          icon: Icon(
            icon ?? (selectedPlan != null ? Icons.check_circle : Icons.restaurant_menu),
            size: 18,
            color: selectedPlan != null ? Colors.green[600] : null,
          ),
          label: Text(
            displayLabel,
            style: TextStyle(
              color: selectedPlan != null ? Colors.green[600] : null,
              fontWeight: selectedPlan != null ? FontWeight.w600 : null,
            ),
          ),
        );
      },
    );
  }

  void _showMealPlanSelector(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const MealPlanSelectorModal(),
    );
  }

  String _formatMealPlanTitle(MealPlanListItem plan) {
    final date = plan.planDate;
    return '${date.month}/${date.day} Week';
  }
}

class MealPlanStatusIndicator extends StatelessWidget {
  const MealPlanStatusIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<MealPlanningProvider>(
      builder: (context, provider, child) {
        if (!provider.hasSelectedMealPlan) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.warning_amber,
                  size: 14,
                  color: Colors.orange[600],
                ),
                const SizedBox(width: 4),
                Text(
                  'No plan selected',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle,
                size: 14,
                color: Colors.green[600],
              ),
              const SizedBox(width: 4),
              Text(
                'Plan active',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
} 