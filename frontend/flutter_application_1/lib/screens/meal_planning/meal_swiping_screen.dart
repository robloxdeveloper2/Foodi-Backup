import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/meal_swiping_provider.dart';
import '../../services/preference_learning_service.dart';
import '../../widgets/meal_swiping/swipeable_meal_card.dart';
import '../../widgets/meal_swiping/meal_detail_modal.dart';
import '../../widgets/meal_swiping/preference_progress_indicator.dart';
import '../../widgets/meal_swiping/swipe_action_buttons.dart';
import '../../widgets/meal_swiping/session_summary_card.dart';

class MealSwipingScreen extends StatefulWidget {
  const MealSwipingScreen({super.key});

  @override
  State<MealSwipingScreen> createState() => _MealSwipingScreenState();
}

class _MealSwipingScreenState extends State<MealSwipingScreen> {
  late MealSwipingProvider _swipingProvider;

  @override
  void initState() {
    super.initState();
    _swipingProvider = MealSwipingProvider(PreferenceLearningService());
    
    // Load initial suggestions
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _swipingProvider.loadMealSuggestions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _swipingProvider,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text(
            'Discover Meals',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
          actions: [
            Consumer<MealSwipingProvider>(
              builder: (context, provider, child) {
                return IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: provider.isLoading ? null : () {
                    provider.loadMealSuggestions();
                  },
                  tooltip: 'Refresh suggestions',
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () => _showHelpDialog(context),
              tooltip: 'How to use',
            ),
          ],
        ),
        body: Consumer<MealSwipingProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Loading meal suggestions...',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            if (provider.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Oops! Something went wrong',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        provider.error!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        provider.clearError();
                        provider.loadMealSuggestions();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try Again'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (provider.suggestions.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.restaurant_menu,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No meal suggestions available',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Try refreshing or check back later',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (!provider.hasMoreSuggestions) {
              return _buildSessionComplete(context, provider);
            }

            return Column(
              children: [
                // Progress indicator
                PreferenceProgressIndicator(
                  progress: provider.sessionProgress,
                  current: provider.swipedCount,
                  total: provider.suggestions.length,
                ),
                
                // Main swiping area
                Expanded(
                  child: Stack(
                    children: [
                      // Background cards for depth effect
                      if (provider.currentIndex + 1 < provider.suggestions.length)
                        Positioned.fill(
                          child: Transform.scale(
                            scale: 0.95,
                            child: Transform.translate(
                              offset: const Offset(0, 10),
                              child: SwipeableMealCard(
                                suggestion: provider.suggestions[provider.currentIndex + 1],
                                isBackground: true,
                                onSwipe: (direction) {},
                                onTap: () {},
                              ),
                            ),
                          ),
                        ),
                      
                      // Current card
                      if (provider.currentSuggestion != null)
                        Positioned.fill(
                          child: SwipeableMealCard(
                            suggestion: provider.currentSuggestion!,
                            isBackground: false,
                            onSwipe: (direction) {
                              if (direction == SwipeDirection.left) {
                                provider.swipeLeft();
                              } else if (direction == SwipeDirection.right) {
                                provider.swipeRight();
                              }
                            },
                            onTap: () => _showMealDetails(context, provider.currentSuggestion!),
                          ),
                        ),
                      
                      // Loading overlay
                      if (provider.isSubmittingFeedback)
                        Positioned.fill(
                          child: Container(
                            color: Colors.black26,
                            child: const Center(
                              child: CircularProgressIndicator(
                                backgroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                
                // Action buttons
                SwipeActionButtons(
                  onDislike: provider.isSubmittingFeedback ? null : () => provider.swipeLeft(),
                  onLike: provider.isSubmittingFeedback ? null : () => provider.swipeRight(),
                  onInfo: () => _showMealDetails(context, provider.currentSuggestion!),
                ),
                
                const SizedBox(height: 16),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSessionComplete(BuildContext context, MealSwipingProvider provider) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.celebration,
              size: 80,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 24),
            const Text(
              'Session Complete!',
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Great job! You\'ve helped us learn your preferences.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),
            
            // Session summary
            SessionSummaryCard(summary: provider.sessionSummary),
            
            const SizedBox(height: 32),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Back to Menu'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => provider.loadMealSuggestions(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('New Session'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showMealDetails(BuildContext context, suggestion) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MealDetailModal(
        suggestion: suggestion,
        onRate: (rating) {
          _swipingProvider.setRecipeRating(suggestion.id, rating);
        },
        onIngredientPreference: (ingredient, preference) {
          _swipingProvider.updateIngredientPreference(ingredient, preference);
        },
        onCuisinePreference: (cuisine, rating) {
          _swipingProvider.setCuisinePreference(cuisine, rating);
        },
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('How to Use'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('🍽️ Swipe right or tap ❤️ if you like the meal'),
            SizedBox(height: 8),
            Text('👎 Swipe left or tap ✖️ if you don\'t like it'),
            SizedBox(height: 8),
            Text('ℹ️ Tap the info button for more details and rating'),
            SizedBox(height: 8),
            Text('📊 Your preferences help us recommend better meals!'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _swipingProvider.dispose();
    super.dispose();
  }
} 