import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/recipe_discovery_provider.dart';
import '../../models/recipe_models.dart';

class RecipeFilterSheet extends StatefulWidget {
  const RecipeFilterSheet({Key? key}) : super(key: key);

  @override
  State<RecipeFilterSheet> createState() => _RecipeFilterSheetState();
}

class _RecipeFilterSheetState extends State<RecipeFilterSheet> {
  late RecipeFilters _tempFilters;

  @override
  void initState() {
    super.initState();
    final provider = context.read<RecipeDiscoveryProvider>();
    _tempFilters = RecipeFilters(
      mealType: provider.filters.mealType,
      cuisineType: provider.filters.cuisineType,
      dietaryRestrictions: List.from(provider.filters.dietaryRestrictions),
      difficultyLevel: provider.filters.difficultyLevel,
      maxPrepTime: provider.filters.maxPrepTime,
      minCostUsd: provider.filters.minCostUsd,
      maxCostUsd: provider.filters.maxCostUsd,
    );
  }

  void _applyFilters() {
    context.read<RecipeDiscoveryProvider>().updateFilters(_tempFilters);
    Navigator.pop(context);
  }

  void _clearFilters() {
    setState(() {
      _tempFilters = RecipeFilters();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
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
          
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text(
                  'Filter Recipes',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _clearFilters,
                  child: const Text('Clear All'),
                ),
              ],
            ),
          ),
          
          // Filter content
          Expanded(
            child: Consumer<RecipeDiscoveryProvider>(
              builder: (context, provider, child) {
                final filterOptions = provider.filterOptions;
                
                if (filterOptions == null) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Meal Type
                      _buildFilterSection(
                        'Meal Type',
                        _buildChipSelector(
                          filterOptions.mealTypes,
                          _tempFilters.mealType,
                          (value) => setState(() {
                            _tempFilters = _tempFilters.copyWith(
                              mealType: value == _tempFilters.mealType ? null : value,
                              clearMealType: value == _tempFilters.mealType,
                            );
                          }),
                        ),
                      ),
                      
                      // Cuisine Type
                      _buildFilterSection(
                        'Cuisine Type',
                        _buildChipSelector(
                          filterOptions.cuisineTypes,
                          _tempFilters.cuisineType,
                          (value) => setState(() {
                            _tempFilters = _tempFilters.copyWith(
                              cuisineType: value == _tempFilters.cuisineType ? null : value,
                              clearCuisineType: value == _tempFilters.cuisineType,
                            );
                          }),
                        ),
                      ),
                      
                      // Dietary Restrictions
                      _buildFilterSection(
                        'Dietary Restrictions',
                        _buildMultiChipSelector(
                          filterOptions.dietaryRestrictions,
                          _tempFilters.dietaryRestrictions,
                          (value) => setState(() {
                            final restrictions = List<String>.from(_tempFilters.dietaryRestrictions);
                            if (restrictions.contains(value)) {
                              restrictions.remove(value);
                            } else {
                              restrictions.add(value);
                            }
                            _tempFilters = _tempFilters.copyWith(dietaryRestrictions: restrictions);
                          }),
                        ),
                      ),
                      
                      // Difficulty Level
                      _buildFilterSection(
                        'Difficulty Level',
                        _buildChipSelector(
                          filterOptions.difficultyLevels,
                          _tempFilters.difficultyLevel,
                          (value) => setState(() {
                            _tempFilters = _tempFilters.copyWith(
                              difficultyLevel: value == _tempFilters.difficultyLevel ? null : value,
                              clearDifficultyLevel: value == _tempFilters.difficultyLevel,
                            );
                          }),
                        ),
                      ),
                      
                      // Cooking Time
                      _buildFilterSection(
                        'Maximum Cooking Time',
                        _buildTimeSlider(),
                      ),
                      
                      // Cost Range
                      _buildFilterSection(
                        'Cost Range',
                        _buildCostSlider(),
                      ),
                      
                      const SizedBox(height: 100), // Extra space for apply button
                    ],
                  ),
                );
              },
            ),
          ),
          
          // Apply button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Apply Filters',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        content,
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildChipSelector(
    List<String> options,
    String? selectedValue,
    Function(String) onSelected,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = selectedValue == option;
        return FilterChip(
          label: Text(option),
          selected: isSelected,
          onSelected: (_) => onSelected(option),
          backgroundColor: Colors.grey[100],
          selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
          checkmarkColor: Theme.of(context).primaryColor,
        );
      }).toList(),
    );
  }

  Widget _buildMultiChipSelector(
    List<String> options,
    List<String> selectedValues,
    Function(String) onToggle,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = selectedValues.contains(option);
        return FilterChip(
          label: Text(option),
          selected: isSelected,
          onSelected: (_) => onToggle(option),
          backgroundColor: Colors.grey[100],
          selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
          checkmarkColor: Theme.of(context).primaryColor,
        );
      }).toList(),
    );
  }

  Widget _buildTimeSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _tempFilters.maxPrepTime != null
              ? '${_tempFilters.maxPrepTime} minutes or less'
              : 'Any duration',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        Slider(
          value: (_tempFilters.maxPrepTime ?? 120).toDouble(),
          min: 15,
          max: 120,
          divisions: 7,
          label: _tempFilters.maxPrepTime != null
              ? '${_tempFilters.maxPrepTime}min'
              : 'Any',
          onChanged: (value) {
            setState(() {
              _tempFilters = _tempFilters.copyWith(
                maxPrepTime: value.round(),
              );
            });
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('15min', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            Text('2h+', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          ],
        ),
      ],
    );
  }

  Widget _buildCostSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _tempFilters.maxCostUsd != null
              ? 'Up to \$${_tempFilters.maxCostUsd!.toStringAsFixed(0)} per serving'
              : 'Any cost',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        Slider(
          value: (_tempFilters.maxCostUsd ?? 20).toDouble(),
          min: 1,
          max: 20,
          divisions: 19,
          label: _tempFilters.maxCostUsd != null
              ? '\$${_tempFilters.maxCostUsd!.toStringAsFixed(0)}'
              : 'Any',
          onChanged: (value) {
            setState(() {
              _tempFilters = _tempFilters.copyWith(
                maxCostUsd: value,
              );
            });
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('\$1', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            Text('\$20+', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          ],
        ),
      ],
    );
  }
} 