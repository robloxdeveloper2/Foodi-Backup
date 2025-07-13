import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/tutorial_provider.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';

class TutorialDetailScreen extends StatefulWidget {
  final int tutorialId;

  const TutorialDetailScreen({
    super.key,
    required this.tutorialId,
  });

  @override
  State<TutorialDetailScreen> createState() => _TutorialDetailScreenState();
}

class _TutorialDetailScreenState extends State<TutorialDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TutorialProvider>().loadTutorialDetails(widget.tutorialId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tutorial Details'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Consumer<TutorialProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingTutorialDetails) {
            return const LoadingWidget(message: 'Loading tutorial...');
          }

          if (provider.error != null && provider.selectedTutorial == null) {
            return CustomErrorWidget(
              message: provider.error!,
              onRetry: () => provider.loadTutorialDetails(widget.tutorialId),
            );
          }

          final tutorial = provider.selectedTutorial;
          if (tutorial == null) {
            return const Center(
              child: Text('Tutorial not found'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tutorial title
                Text(
                  tutorial.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Tutorial description
                Text(
                  tutorial.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),

                // Tutorial info
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tutorial Information',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow('Category', _formatCategory(tutorial.category)),
                        _buildInfoRow('Difficulty', tutorial.difficultyLevel.toUpperCase()),
                        _buildInfoRow('Duration', '${tutorial.estimatedDurationMinutes} minutes'),
                        _buildInfoRow('Steps', '${tutorial.stepCount} steps'),
                        if (tutorial.averageRating != null && tutorial.averageRating! > 0)
                          _buildInfoRow('Rating', '${tutorial.averageRating!.toStringAsFixed(1)} ⭐'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Learning objectives
                if (tutorial.learningObjectives.isNotEmpty) ...[
                  Text(
                    'What You\'ll Learn',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...tutorial.learningObjectives.map((objective) => 
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green, size: 20),
                          const SizedBox(width: 8),
                          Expanded(child: Text(objective)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Equipment needed
                if (tutorial.equipmentNeeded.isNotEmpty) ...[
                  Text(
                    'Equipment Needed',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...tutorial.equipmentNeeded.map((equipment) => 
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.kitchen, color: Colors.blue, size: 20),
                          const SizedBox(width: 8),
                          Expanded(child: Text(equipment)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Start tutorial button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: provider.isUpdatingProgress ? null : () {
                      _startTutorial(provider);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: provider.isUpdatingProgress
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            provider.isTutorialStarted(tutorial.id) 
                                ? 'Continue Tutorial' 
                                : 'Start Tutorial',
                            style: const TextStyle(fontSize: 16),
                          ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Progress indicator if started
                if (provider.isTutorialStarted(tutorial.id)) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Progress',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          LinearProgressIndicator(
                            value: provider.getTutorialCompletionPercentage(tutorial.id) / 100,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${provider.getTutorialCompletionPercentage(tutorial.id).toInt()}% Complete',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCategory(String category) {
    return category.split('_').map((word) => 
      word[0].toUpperCase() + word.substring(1)
    ).join(' ');
  }

  void _startTutorial(TutorialProvider provider) async {
    final success = await provider.startTutorial(widget.tutorialId);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tutorial started! You can now track your progress.'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to start tutorial. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
} 