import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/meal_planning_provider.dart';
import '../models/meal_plan.dart';

class MealPlanSelector extends StatelessWidget {
  final bool showCreateButton;
  final VoidCallback? onCreateNew;

  const MealPlanSelector({
    Key? key,
    this.showCreateButton = true,
    this.onCreateNew,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<MealPlanningProvider>(
      builder: (context, provider, child) {
        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.restaurant_menu,
                      color: Colors.green[600],
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Active Meal Plan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    if (showCreateButton)
                      TextButton.icon(
                        onPressed: onCreateNew,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('New'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.green[600],
                        ),
                      ),
                  ],
                ),
              ),
              
              const Divider(height: 1),
              
              // Current Selection or Empty State
              if (provider.hasSelectedMealPlan)
                _buildSelectedMealPlan(context, provider)
              else
                _buildEmptyState(context, provider),
              
              // Meal Plan List
              if (provider.mealPlanHistory.isNotEmpty) ...[
                const Divider(height: 1),
                _buildMealPlanList(context, provider),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildSelectedMealPlan(BuildContext context, MealPlanningProvider provider) {
    final selectedPlan = provider.selectedMealPlan;
    if (selectedPlan == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        border: Border(
          left: BorderSide(color: Colors.green[600]!, width: 4),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatMealPlanTitle(selectedPlan),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${selectedPlan.durationDays} days • Created ${_formatDate(selectedPlan.createdAt)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                if (selectedPlan.estimatedTotalCostUsd > 0) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Est. cost: \$${selectedPlan.estimatedTotalCostUsd.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.green[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Icon(
            Icons.check_circle,
            color: Colors.green[600],
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, MealPlanningProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.restaurant_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 12),
            Text(
              'No meal plan selected',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select a meal plan below or create a new one',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealPlanList(BuildContext context, MealPlanningProvider provider) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 300),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: provider.mealPlanHistory.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final plan = provider.mealPlanHistory[index];
          final isSelected = plan.id == provider.selectedMealPlanId;
          
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(
              _formatMealPlanTitle(plan),
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.green[700] : Colors.black87,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${plan.durationDays} days • ${_formatDate(plan.createdAt)}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                if (plan.estimatedTotalCostUsd > 0)
                  Text(
                    '\$${plan.estimatedTotalCostUsd.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Colors.green[600],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
            trailing: isSelected
                ? Icon(Icons.check_circle, color: Colors.green[600])
                : Icon(Icons.radio_button_unchecked, color: Colors.grey[400]),
            onTap: () {
              provider.selectMealPlan(plan.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Selected: ${_formatMealPlanTitle(plan)}'),
                  duration: const Duration(seconds: 2),
                  backgroundColor: Colors.green[600],
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatMealPlanTitle(MealPlanListItem plan) {
    final date = plan.planDate;
    final weekday = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][date.weekday - 1];
    return 'Week of $weekday ${date.month}/${date.day}';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }
}

class MealPlanSelectorModal extends StatefulWidget {
  const MealPlanSelectorModal({Key? key}) : super(key: key);

  @override
  State<MealPlanSelectorModal> createState() => _MealPlanSelectorModalState();
}

class _MealPlanSelectorModalState extends State<MealPlanSelectorModal> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMealPlans();
    });
  }

  Future<void> _loadMealPlans() async {
    final provider = Provider.of<MealPlanningProvider>(context, listen: false);
    await provider.loadMealPlanHistoryWithAutoSelect();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green[600],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.restaurant_menu,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Select Meal Plan',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            
            // Content
            Flexible(
              child: Consumer<MealPlanningProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (provider.mealPlanHistory.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          Icon(
                            Icons.restaurant_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No meal plans found',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Create your first meal plan to get started',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return MealPlanSelector(
                    showCreateButton: false,
                  );
                },
              ),
            ),
            
            // Footer
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/meal-planning');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[600],
                      ),
                      child: const Text('Create New'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 