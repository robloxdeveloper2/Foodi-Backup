import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/meal_plan.dart';

class MealPlanCalendarWidget extends StatefulWidget {
  final MealPlan mealPlan;
  final int selectedDay;
  final Function(int) onDaySelected;

  const MealPlanCalendarWidget({
    super.key,
    required this.mealPlan,
    required this.selectedDay,
    required this.onDaySelected,
  });

  @override
  State<MealPlanCalendarWidget> createState() => _MealPlanCalendarWidgetState();
}

class _MealPlanCalendarWidgetState extends State<MealPlanCalendarWidget> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: Colors.green[600],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Meal Plan Calendar',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${widget.mealPlan.durationDays} day meal plan starting ${DateFormat('MMM dd, yyyy').format(widget.mealPlan.planDate)}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            
            // Calendar Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: widget.mealPlan.durationDays > 4 ? 4 : widget.mealPlan.durationDays,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1.0,
              ),
              itemCount: widget.mealPlan.durationDays,
              itemBuilder: (context, index) {
                final day = index + 1;
                final date = widget.mealPlan.planDate.add(Duration(days: index));
                final mealsForDay = widget.mealPlan.getMealsForDay(day);
                final isSelected = widget.selectedDay == day;
                
                return GestureDetector(
                  onTap: () => widget.onDaySelected(day),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.green[600] : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? Colors.green[600]! : Colors.grey[300]!,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('E').format(date),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isSelected ? Colors.white : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Day $day',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            for (final meal in mealsForDay.take(3))
                              Container(
                                width: 6,
                                height: 6,
                                margin: const EdgeInsets.symmetric(horizontal: 1),
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.white : _getMealColor(meal.mealType),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            if (mealsForDay.length > 3)
                              Text(
                                '+',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isSelected ? Colors.white : Colors.grey[600],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 12),
            
            // Legend
            Row(
              children: [
                _buildLegendItem('Breakfast', Colors.orange[300]!),
                const SizedBox(width: 12),
                _buildLegendItem('Lunch', Colors.blue[300]!),
                const SizedBox(width: 12),
                _buildLegendItem('Dinner', Colors.purple[300]!),
                const SizedBox(width: 12),
                _buildLegendItem('Snack', Colors.green[300]!),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Color _getMealColor(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return Colors.orange[300]!;
      case 'lunch':
        return Colors.blue[300]!;
      case 'dinner':
        return Colors.purple[300]!;
      case 'snack':
        return Colors.green[300]!;
      default:
        return Colors.grey[400]!;
    }
  }
} 