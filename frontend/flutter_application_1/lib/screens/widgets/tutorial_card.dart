import 'package:flutter/material.dart';

import '../../models/tutorial_models.dart';

class TutorialCard extends StatelessWidget {
  final Tutorial tutorial;
  final VoidCallback onTap;
  final bool showFeaturedBadge;
  final bool showBeginnerBadge;

  const TutorialCard({
    super.key,
    required this.tutorial,
    required this.onTap,
    this.showFeaturedBadge = false,
    this.showBeginnerBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with badges
              Row(
                children: [
                  Expanded(
                    child: Text(
                      tutorial.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (showFeaturedBadge || tutorial.isFeatured)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'FEATURED',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  if (showBeginnerBadge || tutorial.isBeginnerFriendly)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'BEGINNER',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Description
              Text(
                tutorial.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 12),
              
              // Category and difficulty
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _formatCategory(tutorial.category),
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getDifficultyColor(tutorial.difficultyLevel).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      tutorial.difficultyLevel.toUpperCase(),
                      style: TextStyle(
                        color: _getDifficultyColor(tutorial.difficultyLevel),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Stats row
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${tutorial.estimatedDurationMinutes} min',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.list_alt,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${tutorial.stepCount} steps',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  if (tutorial.averageRating != null && tutorial.averageRating! > 0) ...[
                    Icon(
                      Icons.star,
                      size: 16,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      tutorial.averageRating!.toStringAsFixed(1),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
              
              // Completion rate bar
              if (tutorial.completionRate > 0) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: tutorial.completionRate / 100,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${tutorial.completionRate.toInt()}% complete',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatCategory(String category) {
    return category.split('_').map((word) => 
      word[0].toUpperCase() + word.substring(1)
    ).join(' ');
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
} 