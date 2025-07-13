import 'package:flutter/material.dart';
import '../../models/nutritional_analysis.dart';

class CostTrackingWidget extends StatelessWidget {
  final CostAnalysis costAnalysis;

  const CostTrackingWidget({
    super.key,
    required this.costAnalysis,
  });

  @override
  Widget build(BuildContext context) {
    // Debug output to check values
    debugPrint('=== Cost Analysis Debug ===');
    debugPrint('Total Cost: \$${costAnalysis.totalCostUsd}');
    debugPrint('Budget Target: \$${costAnalysis.budgetTargetUsd}');
    debugPrint('Budget Adherence: ${costAnalysis.budgetAdherence}');
    debugPrint('Budget Variance: ${costAnalysis.budgetVariancePercent}%');
    debugPrint('Cost Efficiency: ${costAnalysis.costEfficiencyRating}');
    debugPrint('Is Within Budget: ${costAnalysis.isWithinBudget}');
    debugPrint('===========================');

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
                  Icons.attach_money,
                  color: Colors.green[600],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Cost Analysis',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getBudgetStatusColor() == Colors.green ? Colors.green[50] : Colors.red[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getBudgetStatusColor() == Colors.green ? Colors.green[200]! : Colors.red[200]!,
                    ),
                  ),
                  child: Text(
                    _getBudgetStatusText(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _getBudgetStatusColor() == Colors.green ? Colors.green[700] : Colors.red[700],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Budget Overview
            _buildBudgetOverview(),

            const SizedBox(height: 16),

            // Cost Breakdown
            _buildCostBreakdown(),

            const SizedBox(height: 16),

            // Cost Efficiency
            _buildCostEfficiency(),
          ],
        ),
      ),
    );
  }

  // Helper method to determine budget status with more robust logic
  Color _getBudgetStatusColor() {
    // Use multiple checks for better accuracy
    if (costAnalysis.budgetTargetUsd <= 0) {
      // No budget set, consider it fine
      return Colors.green;
    }
    
    // Check if total cost is actually within budget
    final isWithinActualBudget = costAnalysis.totalCostUsd <= costAnalysis.budgetTargetUsd;
    
    // Also check the budget adherence string
    final adherenceWithinBudget = costAnalysis.budgetAdherence.toLowerCase() == 'within_budget';
    
    // Use actual calculation if there's a discrepancy
    if (isWithinActualBudget && !adherenceWithinBudget) {
      debugPrint('BUDGET LOGIC MISMATCH: Actual within budget but adherence says over budget');
      return Colors.green; // Trust the actual calculation
    }
    
    return isWithinActualBudget ? Colors.green : Colors.red;
  }

  String _getBudgetStatusText() {
    if (costAnalysis.budgetTargetUsd <= 0) {
      return 'No Budget Set';
    }
    
    final isWithinActualBudget = costAnalysis.totalCostUsd <= costAnalysis.budgetTargetUsd;
    return isWithinActualBudget ? 'Within Budget' : 'Over Budget';
  }

  Widget _buildBudgetOverview() {
    final statusColor = _getBudgetStatusColor();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: statusColor == Colors.green
              ? [Colors.green[400]!, Colors.green[600]!]
              : [Colors.red[400]!, Colors.red[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Cost',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                costAnalysis.budgetTargetUsd > 0 
                    ? 'Budget: \$${costAnalysis.budgetTargetUsd.toStringAsFixed(2)}'
                    : 'No Budget Set',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '\$${costAnalysis.totalCostUsd.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (costAnalysis.budgetTargetUsd > 0) ...[
            Text(
              _getBudgetVarianceText(),
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 12,
              ),
            ),
          ] else ...[
            Text(
              'Set a budget to track spending',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getBudgetVarianceText() {
    if (costAnalysis.budgetTargetUsd <= 0) return '';
    
    final actualVariance = ((costAnalysis.totalCostUsd - costAnalysis.budgetTargetUsd) / costAnalysis.budgetTargetUsd) * 100;
    
    if (actualVariance.abs() < 0.1) {
      return 'On budget';
    } else if (actualVariance > 0) {
      return '+${actualVariance.toStringAsFixed(1)}% over budget';
    } else {
      return '${actualVariance.toStringAsFixed(1)}% under budget';
    }
  }

  Widget _buildCostBreakdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cost Breakdown',
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
          child: Column(
            children: [
              _buildCostItem(
                'Daily Average',
                '\$${costAnalysis.dailyAverageCostUsd.toStringAsFixed(2)}',
                Icons.calendar_today,
                Colors.blue[600]!,
              ),
              const SizedBox(height: 8),
              _buildCostItem(
                'Cost per Calorie',
                '\$${(costAnalysis.costPerCalorie * 1000).toStringAsFixed(3)}/1000 cal',
                Icons.local_fire_department,
                Colors.orange[600]!,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCostItem(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildCostEfficiency() {
    final efficiency = _getActualCostEfficiency();
    final color = _getEfficiencyColor(efficiency);
    final icon = _getEfficiencyIcon(efficiency);

    // Debug cost efficiency
    debugPrint('=== Cost Efficiency Debug ===');
    debugPrint('Backend Efficiency Rating: ${costAnalysis.costEfficiencyRating}');
    debugPrint('Cost Per Calorie: ${costAnalysis.costPerCalorie}');
    debugPrint('Daily Average Cost: \$${costAnalysis.dailyAverageCostUsd}');
    debugPrint('Calculated Efficiency: $efficiency');
    debugPrint('==============================');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cost Efficiency',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getEfficiencyLabel(efficiency),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getEfficiencyDescription(efficiency),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  efficiency.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Tips based on efficiency
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.lightbulb,
                size: 16,
                color: Colors.blue[600],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _getEfficiencyTip(efficiency),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue[800],
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Calculate actual cost efficiency based on cost per calorie
  String _getActualCostEfficiency() {
    final costPerCalorie = costAnalysis.costPerCalorie;
    final dailyAverage = costAnalysis.dailyAverageCostUsd;
    
    // First, let's use daily average as a more reliable metric
    // Adjusted to make only $15+ per day expensive
    if (dailyAverage > 0) {
      if (dailyAverage <= 7.0) {
        return 'excellent';
      } else if (dailyAverage <= 11.0) {
        return 'good';
      } else if (dailyAverage <= 15.0) {
        return 'fair';
      } else {
        return 'expensive';
      }
    }
    
    // Fallback to cost per calorie with more flexible thresholds
    // Adjusted thresholds to be more realistic
    if (costPerCalorie <= 0.0) {
      // Invalid data, default to good
      return 'good';
    } else if (costPerCalorie < 0.005) {  // Increased from 0.002
      return 'excellent';
    } else if (costPerCalorie < 0.008) {  // Increased from 0.003
      return 'good';
    } else if (costPerCalorie < 0.012) {  // Increased from 0.004
      return 'fair';
    } else {
      return 'expensive';
    }
  }

  Color _getEfficiencyColor(String efficiency) {
    switch (efficiency.toLowerCase()) {
      case 'excellent':
        return Colors.green[600]!;
      case 'good':
        return Colors.blue[600]!;
      case 'fair':
        return Colors.orange[600]!;
      case 'expensive':
        return Colors.red[600]!;
      default:
        return Colors.grey[600]!;
    }
  }

  IconData _getEfficiencyIcon(String efficiency) {
    switch (efficiency.toLowerCase()) {
      case 'excellent':
        return Icons.emoji_events;
      case 'good':
        return Icons.thumb_up;
      case 'fair':
        return Icons.thumbs_up_down;
      case 'expensive':
        return Icons.thumb_down;
      default:
        return Icons.help;
    }
  }

  String _getEfficiencyLabel(String efficiency) {
    switch (efficiency.toLowerCase()) {
      case 'excellent':
        return 'Excellent Value';
      case 'good':
        return 'Good Value';
      case 'fair':
        return 'Fair Value';
      case 'expensive':
        return 'Expensive';
      default:
        return efficiency;
    }
  }

  String _getEfficiencyDescription(String efficiency) {
    switch (efficiency.toLowerCase()) {
      case 'excellent':
        return 'Great cost-effective meal planning!';
      case 'good':
        return 'Well-balanced cost and nutrition';
      case 'fair':
        return 'Reasonable value for your meals';
      case 'expensive':
        return 'Consider budget-friendly alternatives';
      default:
        return 'Cost efficiency analysis';
    }
  }

  String _getEfficiencyTip(String efficiency) {
    switch (efficiency.toLowerCase()) {
      case 'excellent':
        return 'Your meal plan offers excellent value! You\'re getting great nutrition at a low cost per calorie.';
      case 'good':
        return 'Good value meal plan. Consider bulk buying ingredients to save even more.';
      case 'fair':
        return 'Try incorporating more budget-friendly protein sources like legumes and seasonal vegetables.';
      case 'expensive':
        return 'Consider replacing expensive ingredients with more affordable alternatives while maintaining nutrition quality.';
      default:
        return 'Monitor your spending to optimize meal plan value.';
    }
  }
} 