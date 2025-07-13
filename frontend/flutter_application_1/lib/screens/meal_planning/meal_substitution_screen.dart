import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/meal_plan.dart';
import '../../models/meal_substitution.dart';
import '../../providers/meal_substitution_provider.dart';
import '../../providers/meal_planning_provider.dart';
import '../../widgets/substitute_meal_card.dart';
import '../../widgets/unified_substitution_confirmation.dart';

class MealSubstitutionScreen extends StatefulWidget {
  final MealPlan mealPlan;
  final int mealIndex;

  const MealSubstitutionScreen({
    Key? key,
    required this.mealPlan,
    required this.mealIndex,
  }) : super(key: key);

  @override
  State<MealSubstitutionScreen> createState() => _MealSubstitutionScreenState();
}

class _MealSubstitutionScreenState extends State<MealSubstitutionScreen> {
  SubstitutionCandidate? _selectedCandidate;
  bool _showConfirmation = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSubstitutes();
    });
  }

  Future<void> _loadSubstitutes() async {
    final provider = Provider.of<MealSubstitutionProvider>(context, listen: false);
    await provider.loadSubstituteOptions(
      mealPlanId: widget.mealPlan.id,
      mealIndex: widget.mealIndex,
    );
  }

  Future<void> _previewSubstitution(SubstitutionCandidate candidate) async {
    final provider = Provider.of<MealSubstitutionProvider>(context, listen: false);
    
    setState(() {
      _selectedCandidate = candidate;
      _showConfirmation = true;
    });

    await provider.previewSubstitution(
      mealPlanId: widget.mealPlan.id,
      mealIndex: widget.mealIndex,
      newRecipeId: candidate.recipeId,
    );
  }

  Future<void> _confirmSubstitution() async {
    if (_selectedCandidate == null) return;

    await _applySubstitution();
  }

  Future<void> _applySubstitution() async {
    if (_selectedCandidate == null) return;

    final substitutionProvider = Provider.of<MealSubstitutionProvider>(context, listen: false);
    final mealPlanProvider = Provider.of<MealPlanningProvider>(context, listen: false);

    final updatedMealPlan = await substitutionProvider.applySubstitution(
      mealPlanId: widget.mealPlan.id,
      mealIndex: widget.mealIndex,
      newRecipeId: _selectedCandidate!.recipeId,
    );

    if (updatedMealPlan != null) {
      // Update the meal planning provider with the new meal plan
      mealPlanProvider.updateCurrentMealPlan(updatedMealPlan);
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Meal substituted successfully!'),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'Undo',
            textColor: Colors.white,
            onPressed: _undoSubstitution,
          ),
        ),
      );

      // Navigate back
      Navigator.of(context).pop(updatedMealPlan);
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to apply substitution'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _undoSubstitution() async {
    final substitutionProvider = Provider.of<MealSubstitutionProvider>(context, listen: false);
    final mealPlanProvider = Provider.of<MealPlanningProvider>(context, listen: false);

    final updatedMealPlan = await substitutionProvider.undoSubstitution(
      mealPlanId: widget.mealPlan.id,
    );

    if (updatedMealPlan != null) {
      mealPlanProvider.updateCurrentMealPlan(updatedMealPlan);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Substitution undone successfully!'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Substitute Meal'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          Consumer<MealSubstitutionProvider>(
            builder: (context, provider, child) {
              if (provider.canUndo) {
                return IconButton(
                  icon: Icon(Icons.undo),
                  onPressed: _undoSubstitution,
                  tooltip: 'Undo last substitution',
                );
              }
              return SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<MealSubstitutionProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Finding substitute options...'),
                ],
              ),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'Error loading substitutes',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  SizedBox(height: 8),
                  Text(
                    provider.error!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[800]),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadSubstitutes,
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (!provider.hasSubstitutes) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No substitutes found',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'We couldn\'t find any suitable alternatives for this meal.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[800]),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Original meal info
              Container(
                padding: EdgeInsets.all(16),
                color: Colors.grey[50],
                child: Row(
                  children: [
                    Icon(Icons.restaurant, color: Theme.of(context).primaryColor),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Original Meal',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[800],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            provider.currentSubstitutes!.originalRecipeName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[900],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Substitutes list
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: provider.currentSubstitutes!.alternatives.length,
                  itemBuilder: (context, index) {
                    final candidate = provider.currentSubstitutes!.alternatives[index];
                    final isSelected = _selectedCandidate?.recipeId == candidate.recipeId;

                    return Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: SubstituteMealCard(
                        candidate: candidate,
                        isSelected: isSelected,
                        onTap: () => _previewSubstitution(candidate),
                        onSelect: () => _previewSubstitution(candidate),
                      ),
                    );
                  },
                ),
              ),

              // Unified confirmation section
              if (_showConfirmation && _selectedCandidate != null)
                UnifiedSubstitutionConfirmation(
                  candidate: _selectedCandidate!,
                  originalMeal: widget.mealPlan.meals[widget.mealIndex].toJson(),
                  impactData: provider.getNutritionalImpactSummary(),
                  onConfirm: _confirmSubstitution,
                  onCancel: () {
                    setState(() {
                      _selectedCandidate = null;
                      _showConfirmation = false;
                    });
                  },
                  isLoading: provider.isApplying,
                ),
            ],
          );
        },
      ),
    );
  }
} 