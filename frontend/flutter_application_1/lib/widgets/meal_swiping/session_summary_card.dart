import 'package:flutter/material.dart';

class SessionSummaryCard extends StatelessWidget {
  final Map<String, int> summary;

  const SessionSummaryCard({
    super.key,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Session Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _SummaryItem(
                  icon: Icons.favorite,
                  color: Colors.green,
                  label: 'Liked',
                  value: summary['likes'] ?? 0,
                ),
                _SummaryItem(
                  icon: Icons.close,
                  color: Colors.red,
                  label: 'Passed',
                  value: summary['dislikes'] ?? 0,
                ),
                _SummaryItem(
                  icon: Icons.star,
                  color: Colors.orange,
                  label: 'Rated',
                  value: summary['ratings'] ?? 0,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Total: ${summary['total_swiped'] ?? 0} meals reviewed',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final int value;

  const _SummaryItem({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
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