import 'package:flutter/material.dart';
import '../../models/nutritional_analysis.dart';

class WeeklyTrendsWidget extends StatelessWidget {
  final WeeklyTrends weeklyTrends;

  const WeeklyTrendsWidget({
    super.key,
    required this.weeklyTrends,
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
                  Icons.trending_up,
                  color: Colors.purple[600],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Weekly Trends',
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
                    color: Colors.purple[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.purple[200]!),
                  ),
                  child: Text(
                    '${weeklyTrends.weeksAnalyzed} weeks',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.purple[700],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Analysis from ${_formatDate(weeklyTrends.startDate)} to ${_formatDate(weeklyTrends.endDate)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),

            // Trend Analysis Summary
            _buildTrendsSummary(),

            const SizedBox(height: 16),

            // Average Nutrition Overview
            _buildNutritionOverview(),

            const SizedBox(height: 16),

            // Insights
            if (weeklyTrends.insights.isNotEmpty) ...[
              _buildInsights(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTrendsSummary() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trend Summary',
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
                child: _buildTrendItem(
                  'Protein',
                  weeklyTrends.trends.proteinTrend,
                  Icons.trending_up,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTrendItem(
                  'Cost',
                  weeklyTrends.trends.costTrend,
                  Icons.attach_money,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildConsistencyItem(),
        ],
      ),
    );
  }

  Widget _buildTrendItem(String label, String trend, IconData icon) {
    final color = _getTrendColor(trend);
    final trendIcon = _getTrendIcon(trend);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                Row(
                  children: [
                    Icon(trendIcon, size: 12, color: color),
                    const SizedBox(width: 2),
                    Text(
                      _formatTrend(trend),
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
          ),
        ],
      ),
    );
  }

  Widget _buildConsistencyItem() {
    final consistency = weeklyTrends.trends.calorieConsistency;
    final color = consistency >= 80 ? Colors.green[600]! : 
                 consistency >= 60 ? Colors.orange[600]! : Colors.red[600]!;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.sync, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                'Calorie Consistency',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
              const Spacer(),
              Text(
                '${consistency.toStringAsFixed(0)}%',
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
            value: consistency / 100,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionOverview() {
    final trends = weeklyTrends.trends;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Average Daily Nutrition',
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
              child: _buildNutritionCard(
                'Calories',
                trends.avgCalories.toStringAsFixed(0),
                'kcal',
                Colors.blue[600]!,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildNutritionCard(
                'Protein',
                trends.avgProtein.toStringAsFixed(1),
                'g',
                Colors.red[600]!,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildNutritionCard(
                'Carbs',
                trends.avgCarbs.toStringAsFixed(1),
                'g',
                Colors.orange[600]!,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildNutritionCard(
                'Fat',
                trends.avgFat.toStringAsFixed(1),
                'g',
                Colors.yellow[700]!,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green[200]!),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.attach_money, size: 16, color: Colors.green[600]),
              const SizedBox(width: 6),
              Text(
                'Average Cost: ',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                '\$${trends.avgCost.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNutritionCard(String label, String value, String unit, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: color.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 2),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                TextSpan(
                  text: unit,
                  style: TextStyle(
                    fontSize: 10,
                    color: color.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsights() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Insights',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        ...weeklyTrends.insights.map((insight) =>
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lightbulb,
                  size: 14,
                  color: Colors.blue[600],
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    insight,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _getTrendColor(String trend) {
    switch (trend.toLowerCase()) {
      case 'increasing':
        return Colors.green[600]!;
      case 'decreasing':
        return Colors.red[600]!;
      case 'stable':
        return Colors.blue[600]!;
      default:
        return Colors.grey[600]!;
    }
  }

  IconData _getTrendIcon(String trend) {
    switch (trend.toLowerCase()) {
      case 'increasing':
        return Icons.arrow_upward;
      case 'decreasing':
        return Icons.arrow_downward;
      case 'stable':
        return Icons.remove;
      default:
        return Icons.remove;
    }
  }

  String _formatTrend(String trend) {
    switch (trend.toLowerCase()) {
      case 'increasing':
        return 'Rising';
      case 'decreasing':
        return 'Falling';
      case 'stable':
        return 'Stable';
      default:
        return trend;
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}';
  }
} 