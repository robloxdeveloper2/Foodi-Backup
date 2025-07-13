import 'package:flutter/material.dart';
import '../models/meal_substitution.dart';

class SubstituteMealCard extends StatelessWidget {
  final SubstitutionCandidate candidate;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onSelect;

  const SubstituteMealCard({
    Key? key,
    required this.candidate,
    required this.isSelected,
    required this.onTap,
    required this.onSelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 8 : 2,
      color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with name and score
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          candidate.recipeName,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (candidate.cuisineType != null)
                          Text(
                            candidate.cuisineType!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Score badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getScoreColor(candidate.scoreGrade),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      candidate.scoreGrade,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12),

              // Nutritional info
              Row(
                children: [
                  _buildNutritionChip('${candidate.calories.toInt()} cal', Icons.local_fire_department),
                  SizedBox(width: 8),
                  _buildNutritionChip('${candidate.protein.toInt()}g protein', Icons.fitness_center),
                  SizedBox(width: 8),
                  if (candidate.estimatedCostUsd != null)
                    _buildNutritionChip('\$${candidate.estimatedCostUsd!.toStringAsFixed(2)}', Icons.attach_money),
                ],
              ),

              SizedBox(height: 12),

              // Time and difficulty
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.grey[700]),
                  SizedBox(width: 4),
                  Text(
                    candidate.timeDisplay,
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (candidate.difficultyLevel != null) ...[
                    SizedBox(width: 16),
                    Icon(Icons.bar_chart, size: 16, color: Colors.grey[700]),
                    SizedBox(width: 4),
                    Text(
                      candidate.difficultyLevel!.capitalize(),
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),

              SizedBox(height: 12),

              // Scoring breakdown
              Row(
                children: [
                  Expanded(
                    child: _buildScoreBar('Nutrition', candidate.nutritionalSimilarity),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: _buildScoreBar('Preference', candidate.userPreference),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: _buildScoreBar('Cost', candidate.costEfficiency),
                  ),
                ],
              ),

              SizedBox(height: 12),

              // Impact indicator
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _getImpactColor(candidate.substitutionImpact.impactLevel).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _getImpactColor(candidate.substitutionImpact.impactLevel),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getImpactIcon(candidate.substitutionImpact.impactLevel),
                      size: 16,
                      color: _getImpactColor(candidate.substitutionImpact.impactLevel),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        candidate.substitutionImpact.impactDescription,
                        style: TextStyle(
                          fontSize: 12,
                          color: _getImpactColor(candidate.substitutionImpact.impactLevel),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (candidate.substitutionImpact.calorieChange != 0)
                      Text(
                        '${candidate.substitutionImpact.calorieChange > 0 ? '+' : ''}${candidate.substitutionImpact.calorieChange.toInt()} cal',
                        style: TextStyle(
                          fontSize: 12,
                          color: _getImpactColor(candidate.substitutionImpact.impactLevel),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),

              if (isSelected) ...[
                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onSelect,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Select This Substitute'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNutritionChip(String text, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[700]),
          SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[800],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreBar(String label, double score) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[800],
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2),
        Container(
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: score,
            child: Container(
              decoration: BoxDecoration(
                color: _getScoreColor(score >= 0.8 ? 'A' : score >= 0.6 ? 'B' : score >= 0.4 ? 'C' : 'D'),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getScoreColor(String grade) {
    switch (grade) {
      case 'A':
        return Colors.green;
      case 'B':
        return Colors.blue;
      case 'C':
        return Colors.orange;
      case 'D':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getImpactColor(String impactLevel) {
    switch (impactLevel) {
      case 'significant':
        return Colors.red;
      case 'moderate':
        return Colors.orange;
      case 'minimal':
      default:
        return Colors.green;
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

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
} 