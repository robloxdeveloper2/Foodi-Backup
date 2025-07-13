import 'package:flutter/material.dart';

class PreferenceProgressIndicator extends StatelessWidget {
  final double progress;
  final int current;
  final int total;

  const PreferenceProgressIndicator({
    super.key,
    required this.progress,
    required this.current,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Discovering your taste',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              Text(
                '$current / $total',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor,
            ),
            minHeight: 6,
          ),
        ],
      ),
    );
  }
} 