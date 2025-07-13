import 'package:flutter/material.dart';
import '../models/meal_substitution.dart';

class UnifiedSubstitutionConfirmation extends StatelessWidget {
  final SubstitutionCandidate candidate;
  final Map<String, dynamic> originalMeal;
  final Map<String, dynamic>? impactData;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final bool isLoading;

  const UnifiedSubstitutionConfirmation({
    Key? key,
    required this.candidate,
    required this.originalMeal,
    required this.impactData,
    required this.onConfirm,
    required this.onCancel,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7, // Limit to 70% of screen height
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with close button - Fixed at top
          Container(
            padding: EdgeInsets.fromLTRB(20, 16, 8, 0),
            child: Row(
              children: [
                Icon(
                  Icons.swap_horiz,
                  color: Theme.of(context).primaryColor,
                  size: 28,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Confirm Meal Substitution',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[900],
                    ),
                  ),
                ),
                IconButton(
                  onPressed: isLoading ? null : onCancel,
                  icon: Icon(Icons.close, color: Colors.grey[700]),
                  tooltip: 'Cancel',
                ),
              ],
            ),
          ),

          // Scrollable content
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meal comparison section
                  Text(
                    'Meal Comparison',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[900],
                    ),
                  ),
                  SizedBox(height: 12),

                  // Original meal
                  Container(
                    margin: EdgeInsets.only(bottom: 8),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.remove_circle, color: Colors.red[600], size: 24),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Current Meal',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.red[800],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                originalMeal['name'] as String? ?? 'Unknown Recipe',
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

                  // Arrow indicator
                  Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.grey[700],
                        size: 32,
                      ),
                    ),
                  ),

                  // New meal
                  Container(
                    margin: EdgeInsets.only(bottom: 20),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.add_circle, color: Colors.green[600], size: 24),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'New Meal',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.green[800],
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Spacer(),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: _getScoreColor(candidate.scoreGrade),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          'Score ${candidate.scoreGrade}',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    candidate.recipeName,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[900],
                                    ),
                                  ),
                                  if (candidate.cuisineType != null) ...[
                                    SizedBox(height: 4),
                                    Text(
                                      candidate.cuisineType!,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Impact assessment
                  if (impactData != null) ...[
                    Text(
                      'Impact Assessment',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[900],
                      ),
                    ),
                    SizedBox(height: 12),
                    _buildImpactSection(context),
                    SizedBox(height: 20),
                  ],

                  // Nutritional comparison
                  _buildNutritionalComparison(context),

                  SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Action buttons - Fixed at bottom
          Container(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey[200]!, width: 1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isLoading ? null : onCancel,
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.grey[400]!),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      elevation: 2,
                    ),
                    child: isLoading
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Applying...',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            'Confirm Substitution',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImpactSection(BuildContext context) {
    final calorieChange = _safeToDouble(impactData!['calorie_change']) ?? 0.0;
    final proteinChange = _safeToDouble(impactData!['protein_change']) ?? 0.0;
    final carbChange = _safeToDouble(impactData!['carb_change']) ?? 0.0;
    final fatChange = _safeToDouble(impactData!['fat_change']) ?? 0.0;
    final costChange = _safeToDouble(impactData!['cost_change']) ?? 0.0;
    final impactLevel = impactData!['impact_level'] as String? ?? 'minimal';

    return Column(
      children: [
        // Impact level indicator
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _getImpactColor(impactLevel).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _getImpactColor(impactLevel),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Icon(
                _getImpactIcon(impactLevel),
                size: 24,
                color: _getImpactColor(impactLevel),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  impactData!['impact_description'] as String? ?? 
                      '${impactLevel.toUpperCase()} nutritional impact',
                  style: TextStyle(
                    color: _getImpactColor(impactLevel),
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 16),

        // Changes grid
        Row(
          children: [
            Expanded(
              child: _buildChangeItem(
                'Calories',
                calorieChange,
                'cal',
                Icons.local_fire_department,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildChangeItem(
                'Protein',
                proteinChange,
                'g',
                Icons.fitness_center,
              ),
            ),
          ],
        ),
        
        SizedBox(height: 12),
        
        Row(
          children: [
            Expanded(
              child: _buildChangeItem(
                'Carbs',
                carbChange,
                'g',
                Icons.grain,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildChangeItem(
                'Cost',
                costChange,
                '',
                Icons.attach_money,
                isPrice: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChangeItem(String label, double change, String unit, IconData icon, {bool isPrice = false}) {
    final isPositive = change > 0;
    final isZero = change.abs() < 0.01;
    
    Color changeColor = isZero 
        ? Colors.grey[700]!
        : isPositive 
            ? Colors.red[600]!
            : Colors.green[600]!;

    String changeText;
    if (isPrice) {
      changeText = isZero 
          ? '\$0.00' 
          : '${isPositive ? '+' : ''}\$${change.abs().toStringAsFixed(2)}';
    } else {
      changeText = isZero 
          ? '0$unit' 
          : '${isPositive ? '+' : ''}${change.toInt()}$unit';
    }

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: Colors.grey[700]),
          SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[800],
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4),
          Text(
            changeText,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: changeColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionalComparison(BuildContext context) {
    final originalNutrition = originalMeal['nutritional_info'] as Map<String, dynamic>?;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nutritional Comparison',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[900],
          ),
        ),
        SizedBox(height: 12),
        
        Row(
          children: [
            Expanded(
              child: _buildNutritionComparison(
                'Calories',
                _safeToDouble(originalNutrition?['calories']) ?? 0.0,
                candidate.calories,
                'kcal',
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildNutritionComparison(
                'Protein',
                _safeToDouble(originalNutrition?['protein']) ?? 0.0,
                candidate.protein,
                'g',
              ),
            ),
          ],
        ),
        
        SizedBox(height: 12),
        
        Row(
          children: [
            Expanded(
              child: _buildNutritionComparison(
                'Carbs',
                _safeToDouble(originalNutrition?['carbs']) ?? 0.0,
                candidate.carbs,
                'g',
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildNutritionComparison(
                'Fat',
                _safeToDouble(originalNutrition?['fat']) ?? 0.0,
                candidate.fat,
                'g',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNutritionComparison(String label, double original, double substitute, String unit) {
    final difference = substitute - original;
    final isPositive = difference > 0;
    final isZero = difference.abs() < 0.01;

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[800],
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6),
          Text(
            '${original.toInt()} → ${substitute.toInt()}$unit',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[900],
            ),
          ),
          if (!isZero) ...[
            SizedBox(height: 4),
            Text(
              '(${isPositive ? '+' : ''}${difference.toInt()}$unit)',
              style: TextStyle(
                fontSize: 12,
                color: isPositive ? Colors.red[600] : Colors.green[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  double _safeToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Color _getScoreColor(String grade) {
    switch (grade) {
      case 'A':
        return Colors.green[600]!;
      case 'B':
        return Colors.blue[600]!;
      case 'C':
        return Colors.orange[600]!;
      case 'D':
        return Colors.red[600]!;
      default:
        return Colors.grey[600]!;
    }
  }

  Color _getImpactColor(String impactLevel) {
    switch (impactLevel) {
      case 'significant':
        return Colors.red[600]!;
      case 'moderate':
        return Colors.orange[600]!;
      case 'minimal':
      default:
        return Colors.green[600]!;
    }
  }

  IconData _getImpactIcon(String impactLevel) {
    switch (impactLevel) {
      case 'significant':
        return Icons.warning;
      case 'moderate':
        return Icons.info;
      case 'minimal':
      default:
        return Icons.check_circle;
    }
  }
} 