import 'package:flutter/material.dart';

import '../../models/meal_suggestion.dart';

class MealDetailModal extends StatefulWidget {
  final MealSuggestion suggestion;
  final Function(double) onRate;
  final Function(String, String) onIngredientPreference;
  final Function(String, int) onCuisinePreference;

  const MealDetailModal({
    super.key,
    required this.suggestion,
    required this.onRate,
    required this.onIngredientPreference,
    required this.onCuisinePreference,
  });

  @override
  State<MealDetailModal> createState() => _MealDetailModalState();
}

class _MealDetailModalState extends State<MealDetailModal> {
  double _currentRating = 3.0;
  bool _hasRated = false;

  @override
  void initState() {
    super.initState();
    if (widget.suggestion.userRating != null) {
      _currentRating = widget.suggestion.userRating!;
      _hasRated = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with image
                      _buildHeader(),
                      const SizedBox(height: 20),
                      
                      // Rating section
                      _buildRatingSection(),
                      const SizedBox(height: 20),
                      
                      // Recipe details
                      _buildRecipeDetails(),
                      const SizedBox(height: 20),
                      
                      // Ingredients
                      _buildIngredientsSection(),
                      const SizedBox(height: 20),
                      
                      // Instructions
                      _buildInstructionsSection(),
                      const SizedBox(height: 20),
                      
                      // Cuisine preference
                      if (widget.suggestion.cuisineType != null)
                        _buildCuisinePreferenceSection(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[200],
          ),
          child: widget.suggestion.imageUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    widget.suggestion.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
                  ),
                )
              : _buildPlaceholderImage(),
        ),
        const SizedBox(height: 16),
        
        // Title and subtitle
        Text(
          widget.suggestion.name,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (widget.suggestion.description != null) ...[
          const SizedBox(height: 8),
          Text(
            widget.suggestion.description!,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [Colors.green[300]!, Colors.green[500]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.restaurant_menu,
          size: 60,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildRatingSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rate this recipe',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _currentRating,
                    min: 1.0,
                    max: 5.0,
                    divisions: 8,
                    label: _currentRating.toStringAsFixed(1),
                    onChanged: (value) {
                      setState(() {
                        _currentRating = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < _currentRating ? Icons.star : Icons.star_border,
                      color: Colors.orange,
                      size: 24,
                    );
                  }),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.onRate(_currentRating);
                  setState(() {
                    _hasRated = true;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Rating saved!')),
                  );
                },
                child: Text(_hasRated ? 'Update Rating' : 'Save Rating'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeDetails() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recipe Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    Icons.access_time,
                    'Time',
                    widget.suggestion.displayTime,
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    Icons.local_fire_department,
                    'Calories',
                    widget.suggestion.displayCalories,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    Icons.attach_money,
                    'Cost',
                    widget.suggestion.displayCost,
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    Icons.bar_chart,
                    'Difficulty',
                    widget.suggestion.displayDifficulty,
                  ),
                ),
              ],
            ),
            if (widget.suggestion.cuisineType != null) ...[
              const SizedBox(height: 12),
              _buildDetailItem(
                Icons.public,
                'Cuisine',
                widget.suggestion.cuisineType!,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIngredientsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ingredients',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...widget.suggestion.ingredients.map((ingredient) {
              final name = ingredient['name'] ?? '';
              final quantity = ingredient['quantity'] ?? '';
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text('• $quantity $name'),
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, size: 16, color: Colors.grey[600]),
                      onSelected: (preference) {
                        widget.onIngredientPreference(name, preference);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Marked $name as $preference')),
                        );
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'liked',
                          child: Row(
                            children: [
                              Icon(Icons.thumb_up, color: Colors.green),
                              SizedBox(width: 8),
                              Text('Like'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'disliked',
                          child: Row(
                            children: [
                              Icon(Icons.thumb_down, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Dislike'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Instructions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.suggestion.instructions,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCuisinePreferenceSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How much do you like ${widget.suggestion.cuisineType} cuisine?',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(5, (index) {
                final rating = index + 1;
                return GestureDetector(
                  onTap: () {
                    widget.onCuisinePreference(widget.suggestion.cuisineType!, rating);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Rated ${widget.suggestion.cuisineType} cuisine: $rating stars'),
                      ),
                    );
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.orange.withOpacity(0.1),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: Center(
                      child: Text(
                        rating.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
} 