import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/tutorial_provider.dart';
import '../../models/tutorial_models.dart';

class TutorialFilterSheet extends StatefulWidget {
  const TutorialFilterSheet({super.key});

  @override
  State<TutorialFilterSheet> createState() => _TutorialFilterSheetState();
}

class _TutorialFilterSheetState extends State<TutorialFilterSheet> {
  late TutorialFilters _tempFilters;

  @override
  void initState() {
    super.initState();
    final provider = context.read<TutorialProvider>();
    _tempFilters = TutorialFilters(
      category: provider.filters.category,
      difficulty: provider.filters.difficulty,
      durationMaxMinutes: provider.filters.durationMaxMinutes,
      beginnerFriendly: provider.filters.beginnerFriendly,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Text(
                  'Filter Tutorials',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _tempFilters = const TutorialFilters();
                    });
                  },
                  child: const Text('Clear All'),
                ),
              ],
            ),
          ),
          
          // Filter content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category filter
                  _buildCategoryFilter(),
                  const SizedBox(height: 24),
                  
                  // Difficulty filter
                  _buildDifficultyFilter(),
                  const SizedBox(height: 24),
                  
                  // Duration filter
                  _buildDurationFilter(),
                  const SizedBox(height: 24),
                  
                  // Beginner friendly toggle
                  _buildBeginnerFriendlyFilter(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          
          // Action buttons
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<TutorialProvider>().updateFilters(_tempFilters);
                      Navigator.pop(context);
                    },
                    child: const Text('Apply Filters'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Consumer<TutorialProvider>(
      builder: (context, provider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Category',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // All categories option
                FilterChip(
                  label: const Text('All'),
                  selected: _tempFilters.category == null,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _tempFilters = TutorialFilters(
                          difficulty: _tempFilters.difficulty,
                          durationMaxMinutes: _tempFilters.durationMaxMinutes,
                          beginnerFriendly: _tempFilters.beginnerFriendly,
                        );
                      });
                    }
                  },
                ),
                // Category options
                ...provider.categories.map((category) => FilterChip(
                  label: Text(_formatCategoryName(category.category)),
                  selected: _tempFilters.category == category.category,
                  onSelected: (selected) {
                    setState(() {
                      _tempFilters = TutorialFilters(
                        category: selected ? category.category : null,
                        difficulty: _tempFilters.difficulty,
                        durationMaxMinutes: _tempFilters.durationMaxMinutes,
                        beginnerFriendly: _tempFilters.beginnerFriendly,
                      );
                    });
                  },
                )),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildDifficultyFilter() {
    const difficulties = ['beginner', 'intermediate', 'advanced'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Difficulty Level',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            // All difficulties option
            FilterChip(
              label: const Text('All'),
              selected: _tempFilters.difficulty == null,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _tempFilters = TutorialFilters(
                      category: _tempFilters.category,
                      durationMaxMinutes: _tempFilters.durationMaxMinutes,
                      beginnerFriendly: _tempFilters.beginnerFriendly,
                    );
                  });
                }
              },
            ),
            // Difficulty options
            ...difficulties.map((difficulty) => FilterChip(
              label: Text(difficulty[0].toUpperCase() + difficulty.substring(1)),
              selected: _tempFilters.difficulty == difficulty,
              onSelected: (selected) {
                setState(() {
                  _tempFilters = TutorialFilters(
                    category: _tempFilters.category,
                    difficulty: selected ? difficulty : null,
                    durationMaxMinutes: _tempFilters.durationMaxMinutes,
                    beginnerFriendly: _tempFilters.beginnerFriendly,
                  );
                });
              },
            )),
          ],
        ),
      ],
    );
  }

  Widget _buildDurationFilter() {
    const durations = [15, 30, 60, 120];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Maximum Duration',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            // All durations option
            FilterChip(
              label: const Text('Any'),
              selected: _tempFilters.durationMaxMinutes == null,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _tempFilters = TutorialFilters(
                      category: _tempFilters.category,
                      difficulty: _tempFilters.difficulty,
                      beginnerFriendly: _tempFilters.beginnerFriendly,
                    );
                  });
                }
              },
            ),
            // Duration options
            ...durations.map((duration) => FilterChip(
              label: Text('${duration}m'),
              selected: _tempFilters.durationMaxMinutes == duration,
              onSelected: (selected) {
                setState(() {
                  _tempFilters = TutorialFilters(
                    category: _tempFilters.category,
                    difficulty: _tempFilters.difficulty,
                    durationMaxMinutes: selected ? duration : null,
                    beginnerFriendly: _tempFilters.beginnerFriendly,
                  );
                });
              },
            )),
          ],
        ),
      ],
    );
  }

  Widget _buildBeginnerFriendlyFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Beginner Friendly',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),  
        ),
        const SizedBox(height: 12),
        SwitchListTile(
          title: const Text('Show only beginner-friendly tutorials'),
          subtitle: const Text('Tutorials marked as suitable for beginners'),
          value: _tempFilters.beginnerFriendly ?? false,
          onChanged: (value) {
            setState(() {
              _tempFilters = TutorialFilters(
                category: _tempFilters.category,
                difficulty: _tempFilters.difficulty,
                durationMaxMinutes: _tempFilters.durationMaxMinutes,
                beginnerFriendly: value ? true : null,
              );
            });
          },
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  String _formatCategoryName(String category) {
    switch (category) {
      case 'knife_skills':
        return 'Knife Skills';
      case 'food_safety':
        return 'Food Safety';
      case 'cooking_methods':
        return 'Cooking Methods';
      case 'baking_basics':
        return 'Baking Basics';
      case 'kitchen_basics':
        return 'Kitchen Basics';
      default:
        return category.split('_').map((word) => 
          word[0].toUpperCase() + word.substring(1)
        ).join(' ');
    }
  }
} 