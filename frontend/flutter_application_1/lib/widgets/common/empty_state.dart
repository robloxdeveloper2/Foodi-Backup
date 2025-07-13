import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;
  
  const EmptyState({
    Key? key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
} 