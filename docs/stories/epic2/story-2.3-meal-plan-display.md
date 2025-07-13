# Story 2.3: Smart Meal Plan Display and Nutritional Tracking

**Status: InProgress**

## User Story
**As a** user with a generated meal plan  
**I want** to view my meal plan with smart nutritional analysis and helpful recommendations  
**So that** I can understand the health impact of my planned meals

## Acceptance Criteria
- [ ] **AC 2.3.1**: Meal plan displays in organized calendar/list view
- [ ] **AC 2.3.2**: Each meal shows recipe name, prep time, estimated cost, and nutrition preview
- [ ] **AC 2.3.3**: Daily nutritional dashboard shows calories, protein, carbs, fat with goal progress
- [ ] **AC 2.3.4**: System highlights nutritional achievements ("High protein day!", "Within calorie target")
- [ ] **AC 2.3.5**: Algorithm detects nutritional gaps and suggests adjustments
- [ ] **AC 2.3.6**: User can view weekly nutritional trends and patterns
- [ ] **AC 2.3.7**: Cost tracking shows daily/weekly spending vs. budget

## Technical Implementation Notes

### Algorithmic Approach
- **API Endpoints**: 
  - `GET /api/v1/meal-plans/{id}/analysis`
  - `GET /api/v1/meal-plans/{id}`
  - `GET /api/v1/meal-plans/user/{userId}`

### Analysis Algorithms
```python
# Nutritional Analysis:
# 1. Sum daily macros from all planned meals
# 2. Compare against user's nutritional goals
# 3. Identify deficiencies (low protein, high sodium, etc.)
# 4. Generate contextual recommendations
# 5. Calculate weekly averages and trends
```

### Analysis Logic
```python
class NutritionalAnalyzer:
    def analyze_meal_plan(self, meal_plan, user_goals):
        # Calculate daily totals
        daily_nutrition = self.sum_daily_nutrition(meal_plan)
        
        # Compare to goals
        goal_adherence = self.calculate_goal_adherence(daily_nutrition, user_goals)
        
        # Detect patterns and gaps
        insights = self.generate_insights(daily_nutrition, goal_adherence)
        
        # Create recommendations
        recommendations = self.suggest_improvements(insights)
        
        return {
            'daily_totals': daily_nutrition,
            'goal_progress': goal_adherence,
            'insights': insights,
            'recommendations': recommendations
        }
```

### Frontend Implementation
- **Screens**:
  - `lib/features/meal_planning/presentation/screens/meal_plan_view_screen.dart`
  - `lib/features/meal_planning/presentation/screens/nutritional_analysis_screen.dart`

- **Widgets**:
  - `meal_plan_calendar_widget.dart`
  - `meal_card_widget.dart`
  - `nutritional_dashboard_widget.dart`
  - `daily_nutrition_summary_widget.dart`
  - `weekly_trends_widget.dart`
  - `cost_tracking_widget.dart`
  - `nutrition_insights_card.dart`

### State Management
- **Provider**: `MealPlanDisplayState` using Riverpod
- **Actions**:
  - `loadMealPlan(mealPlanId)`
  - `analyzeNutrition(mealPlan)`
  - `toggleMealCompletion(mealId)`
  - `viewWeeklyTrends()`

### Nutritional Insights Algorithm
```python
def generate_nutritional_insights(daily_nutrition, user_goals):
    insights = []
    
    # Calorie analysis
    if daily_nutrition['calories'] > user_goals['calories'] * 1.1:
        insights.append({
            'type': 'warning',
            'message': 'Calories exceed daily target by 10%',
            'suggestion': 'Consider lighter snacks or smaller portions'
        })
    elif daily_nutrition['calories'] < user_goals['calories'] * 0.9:
        insights.append({
            'type': 'info',
            'message': 'Calories below target',
            'suggestion': 'Add a healthy snack to meet energy needs'
        })
    
    # Protein analysis
    if daily_nutrition['protein'] < user_goals['protein'] * 0.8:
        insights.append({
            'type': 'suggestion',
            'message': 'Low protein intake detected',
            'suggestion': 'Consider adding lean protein sources'
        })
    
    return insights
```

## Definition of Done
- [ ] Meal plan viewing screen implemented and responsive
- [ ] Nutritional analysis algorithms implemented and accurate
- [ ] Dashboard displays comprehensive meal plan insights
- [ ] Cost tracking accurately reflects meal plan expenses
- [ ] Navigation between meal plan days functional
- [ ] Weekly trends calculation and display working
- [ ] Recommendations are helpful and actionable
- [ ] Unit tests cover analysis algorithms
- [ ] Widget tests verify UI components
- [ ] Integration tests verify data flow

## Dependencies
- Generated meal plans from Story 2.1
- Recipe nutritional data
- User goals and preferences from Epic 1
- Cost estimation data

## Estimated Effort
**Story Points**: 6

## Priority
**High** - Essential for users to interact with their meal plans

## User Experience Notes
- Display should be intuitive and visually appealing
- Use charts/graphs for nutritional data where helpful
- Provide actionable insights, not just raw data
- Allow easy navigation between different views (daily/weekly)
- Highlight positive achievements to encourage users 