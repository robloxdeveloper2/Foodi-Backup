import 'package:flutter/material.dart';
import '../../models/nutritional_analysis.dart';

class NutritionInsightsCard extends StatelessWidget {
  final List<NutritionalInsight> insights;
  final String title;
  final bool showPriority;

  const NutritionInsightsCard({
    super.key,
    required this.insights,
    this.title = 'Nutritional Insights',
    this.showPriority = true,
  });

  @override
  Widget build(BuildContext context) {
    if (insights.isEmpty) {
      return const SizedBox.shrink();
    }

    // Sort insights by priority (1=high, 2=medium, 3=low)
    final sortedInsights = List<NutritionalInsight>.from(insights)
      ..sort((a, b) => a.priority.compareTo(b.priority));

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
                  Icons.lightbulb_outline,
                  color: Colors.blue[600],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const Spacer(),
                if (insights.length > 1)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Text(
                      '${insights.length} insights',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Insights List
            ...sortedInsights.asMap().entries.map((entry) {
              final index = entry.key;
              final insight = entry.value;
              final isLast = index == sortedInsights.length - 1;

              return Column(
                children: [
                  _buildInsightItem(insight),
                  if (!isLast) const SizedBox(height: 12),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightItem(NutritionalInsight insight) {
    final color = _getInsightColor(insight.type);
    final icon = _getInsightIcon(insight.type);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with type and priority
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  icon,
                  size: 16,
                  color: color,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _getInsightTypeLabel(insight.type),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (showPriority)
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: _getPriorityColor(insight.priority),
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Message
          Text(
            insight.message,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),

          const SizedBox(height: 6),

          // Suggestion
          Text(
            insight.suggestion,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
        ],
      ),
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

  String _getInsightTypeLabel(String type) {
    switch (type.toLowerCase()) {
      case 'achievement':
        return 'ACHIEVEMENT';
      case 'warning':
        return 'WARNING';
      case 'suggestion':
        return 'SUGGESTION';
      case 'info':
        return 'INFO';
      default:
        return type.toUpperCase();
    }
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 1: // High priority
        return Colors.red[600]!;
      case 2: // Medium priority
        return Colors.orange[600]!;
      case 3: // Low priority
        return Colors.green[600]!;
      default:
        return Colors.grey[600]!;
    }
  }
}

class InsightsSummaryWidget extends StatelessWidget {
  final List<NutritionalInsight> insights;

  const InsightsSummaryWidget({
    super.key,
    required this.insights,
  });

  @override
  Widget build(BuildContext context) {
    if (insights.isEmpty) {
      return const SizedBox.shrink();
    }

    final achievements = insights.where((i) => i.isAchievement).length;
    final warnings = insights.where((i) => i.isWarning).length;
    final suggestions = insights.where((i) => i.isSuggestion).length;
    final infos = insights.where((i) => i.isInfo).length;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          if (achievements > 0) ...[
            _buildSummaryItem(
              Icons.emoji_events,
              achievements.toString(),
              'Achievements',
              Colors.green[600]!,
            ),
            if (warnings > 0 || suggestions > 0 || infos > 0)
              const SizedBox(width: 16),
          ],
          if (warnings > 0) ...[
            _buildSummaryItem(
              Icons.warning_rounded,
              warnings.toString(),
              'Warnings',
              Colors.orange[600]!,
            ),
            if (suggestions > 0 || infos > 0)
              const SizedBox(width: 16),
          ],
          if (suggestions > 0) ...[
            _buildSummaryItem(
              Icons.lightbulb,
              suggestions.toString(),
              'Suggestions',
              Colors.blue[600]!,
            ),
            if (infos > 0)
              const SizedBox(width: 16),
          ],
          if (infos > 0)
            _buildSummaryItem(
              Icons.info,
              infos.toString(),
              'Info',
              Colors.grey[600]!,
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(IconData icon, String count, String label, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          count,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(width: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
} 