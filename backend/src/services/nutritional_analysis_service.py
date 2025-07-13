"""
Nutritional Analysis Service
Provides comprehensive nutritional analysis for meal plans including:
- Daily nutritional summaries
- Goal adherence tracking
- Nutritional insights and recommendations
- Weekly trends analysis
- Cost tracking and budget analysis
"""

import logging
from datetime import datetime, timedelta
from typing import Dict, List, Any, Optional, Tuple
from dataclasses import dataclass

from data_access.meal_plan_repository import MealPlanRepository
from data_access.user_repository import UserRepository

logger = logging.getLogger(__name__)

@dataclass
class NutritionalInsight:
    """Represents a nutritional insight with type, message, and suggestion"""
    type: str  # 'achievement', 'warning', 'suggestion', 'info'
    message: str
    suggestion: str
    priority: int = 1  # 1=high, 2=medium, 3=low

@dataclass
class DailyNutritionAnalysis:
    """Analysis results for a single day"""
    date: str
    calories: float
    protein: float
    carbs: float
    fat: float
    fiber: float
    sodium: float
    goal_adherence: Dict[str, float]  # percentage of goal met for each macro
    insights: List[NutritionalInsight]
    cost_usd: float

@dataclass
class WeeklyTrends:
    """Weekly nutritional trends and patterns"""
    avg_calories: float
    avg_protein: float
    avg_carbs: float
    avg_fat: float
    avg_cost: float
    calorie_consistency: float  # variance measure
    protein_trend: str  # 'increasing', 'decreasing', 'stable'
    cost_trend: str
    best_day: str  # day with best goal adherence
    improvement_areas: List[str]

class NutritionalAnalysisService:
    """Service for analyzing meal plan nutrition and generating insights"""
    
    def __init__(self):
        self.meal_plan_repository = MealPlanRepository()
        self.user_repository = UserRepository()
    
    def analyze_meal_plan(self, meal_plan_id: str, user_id: str) -> Dict[str, Any]:
        """
        Comprehensive analysis of a meal plan
        
        Args:
            meal_plan_id: ID of the meal plan to analyze
            user_id: ID of the user (for goal comparison)
            
        Returns:
            Dictionary containing complete nutritional analysis
        """
        try:
            # Get meal plan
            meal_plan = self.meal_plan_repository.get_meal_plan_by_id(meal_plan_id, user_id)
            if not meal_plan:
                raise ValueError(f"Meal plan {meal_plan_id} not found")
            
            # Get user goals
            user_goals = self._get_user_nutritional_goals(user_id)
            
            # Analyze daily nutrition
            daily_analyses = self._analyze_daily_nutrition(meal_plan, user_goals)
            
            # Calculate overall insights
            overall_insights = self._generate_overall_insights(daily_analyses, user_goals)
            
            # Calculate cost analysis
            cost_analysis = self._analyze_cost_tracking(meal_plan, user_goals)
            
            # Generate recommendations
            recommendations = self._generate_recommendations(daily_analyses, overall_insights)
            
            return {
                'meal_plan_id': meal_plan_id,
                'analysis_date': datetime.utcnow().isoformat(),
                'daily_analyses': [self._daily_analysis_to_dict(da) for da in daily_analyses],
                'overall_summary': {
                    'avg_daily_calories': sum(da.calories for da in daily_analyses) / len(daily_analyses),
                    'avg_daily_protein': sum(da.protein for da in daily_analyses) / len(daily_analyses),
                    'avg_daily_carbs': sum(da.carbs for da in daily_analyses) / len(daily_analyses),
                    'avg_daily_fat': sum(da.fat for da in daily_analyses) / len(daily_analyses),
                    'total_cost': sum(da.cost_usd for da in daily_analyses),
                    'avg_goal_adherence': self._calculate_avg_goal_adherence(daily_analyses)
                },
                'insights': [self._insight_to_dict(insight) for insight in overall_insights],
                'cost_analysis': cost_analysis,
                'recommendations': recommendations,
                'nutritional_achievements': self._identify_achievements(daily_analyses, user_goals)
            }
            
        except Exception as e:
            logger.error(f"Error analyzing meal plan {meal_plan_id}: {str(e)}")
            raise
    
    def get_weekly_trends(self, user_id: str, weeks: int = 4) -> Dict[str, Any]:
        """
        Analyze weekly nutritional trends for a user
        
        Args:
            user_id: ID of the user
            weeks: Number of weeks to analyze (default 4)
            
        Returns:
            Weekly trends analysis
        """
        try:
            # Get recent meal plans
            end_date = datetime.utcnow().date()
            start_date = end_date - timedelta(weeks=weeks)
            
            meal_plans = self.meal_plan_repository.get_meal_plans_by_date_range(
                user_id, start_date, end_date
            )
            
            if not meal_plans:
                return {
                    'message': 'No meal plans found for trend analysis',
                    'weeks_analyzed': 0,
                    'trends': None
                }
            
            # Analyze trends
            weekly_data = self._calculate_weekly_data(meal_plans)
            trends = self._analyze_trends(weekly_data)
            
            return {
                'weeks_analyzed': weeks,
                'start_date': start_date.isoformat(),
                'end_date': end_date.isoformat(),
                'weekly_data': weekly_data,
                'trends': self._trends_to_dict(trends),
                'insights': self._generate_trend_insights(trends)
            }
            
        except Exception as e:
            logger.error(f"Error analyzing weekly trends for user {user_id}: {str(e)}")
            raise
    
    def _get_user_nutritional_goals(self, user_id: str) -> Dict[str, float]:
        """Get user's nutritional goals from their profile"""
        try:
            user = self.user_repository.get_user_by_id(user_id)
            if not user:
                # Default goals if no user found
                return {
                    'calories': 2000,
                    'protein': 150,  # grams
                    'carbs': 250,    # grams
                    'fat': 67,       # grams
                    'fiber': 25,     # grams
                    'sodium': 2300   # mg
                }
            
            # Get nutritional goals from user model
            nutritional_goals = user.nutritional_goals or {}
            budget_info = user.budget_info or {}
            
            # Calculate goals based on user profile
            # This is a simplified calculation - in production, you'd use more sophisticated formulas
            base_calories = nutritional_goals.get('daily_calorie_target') or budget_info.get('daily_calorie_target') or 2000
            
            return {
                'calories': base_calories,
                'protein': nutritional_goals.get('protein_target', base_calories * 0.3 / 4),  # 30% of calories from protein
                'carbs': nutritional_goals.get('carbs_target', base_calories * 0.4 / 4),    # 40% of calories from carbs
                'fat': nutritional_goals.get('fat_target', base_calories * 0.3 / 9),      # 30% of calories from fat
                'fiber': nutritional_goals.get('fiber_target', 25),  # Standard recommendation
                'sodium': nutritional_goals.get('sodium_target', 2300)  # Standard recommendation
            }
            
        except Exception as e:
            logger.error(f"Error getting nutritional goals for user {user_id}: {str(e)}")
            # Return default goals on error
            return {
                'calories': 2000,
                'protein': 150,
                'carbs': 250,
                'fat': 67,
                'fiber': 25,
                'sodium': 2300
            }
    
    def _analyze_daily_nutrition(self, meal_plan, user_goals: Dict[str, float]) -> List[DailyNutritionAnalysis]:
        """Analyze nutrition for each day in the meal plan"""
        daily_analyses = []
        
        # Get daily nutrition breakdown from meal plan
        daily_breakdown = meal_plan.daily_nutrition_breakdown or {}
        
        for day_key, day_nutrition in daily_breakdown.items():
            # Calculate goal adherence
            goal_adherence = {}
            for nutrient, value in day_nutrition.items():
                if nutrient in user_goals:
                    goal_adherence[nutrient] = (value / user_goals[nutrient]) * 100
            
            # Generate daily insights
            insights = self._generate_daily_insights(day_nutrition, user_goals)
            
            # Calculate daily cost (simplified - divide total cost by days)
            daily_cost = (meal_plan.estimated_total_cost_usd or 0) / 100.0 / meal_plan.duration_days
            
            daily_analysis = DailyNutritionAnalysis(
                date=day_key,
                calories=day_nutrition.get('calories', 0),
                protein=day_nutrition.get('protein', 0),
                carbs=day_nutrition.get('carbs', 0),
                fat=day_nutrition.get('fat', 0),
                fiber=day_nutrition.get('fiber', 0),
                sodium=day_nutrition.get('sodium', 0),
                goal_adherence=goal_adherence,
                insights=insights,
                cost_usd=daily_cost
            )
            
            daily_analyses.append(daily_analysis)
        
        return daily_analyses
    
    def _generate_daily_insights(self, day_nutrition: Dict[str, float], user_goals: Dict[str, float]) -> List[NutritionalInsight]:
        """Generate insights for a single day's nutrition"""
        insights = []
        
        # Calorie analysis
        calories = day_nutrition.get('calories', 0)
        calorie_goal = user_goals.get('calories', 2000)
        
        if calories > calorie_goal * 1.1:
            insights.append(NutritionalInsight(
                type='warning',
                message=f'Calories exceed daily target by {((calories/calorie_goal - 1) * 100):.0f}%',
                suggestion='Consider lighter snacks or smaller portions',
                priority=1
            ))
        elif calories < calorie_goal * 0.9:
            insights.append(NutritionalInsight(
                type='info',
                message=f'Calories below target by {((1 - calories/calorie_goal) * 100):.0f}%',
                suggestion='Add a healthy snack to meet energy needs',
                priority=2
            ))
        else:
            insights.append(NutritionalInsight(
                type='achievement',
                message='Calories within target range!',
                suggestion='Great job maintaining calorie balance',
                priority=3
            ))
        
        # Protein analysis
        protein = day_nutrition.get('protein', 0)
        protein_goal = user_goals.get('protein', 150)
        
        if protein < protein_goal * 0.8:
            insights.append(NutritionalInsight(
                type='suggestion',
                message='Low protein intake detected',
                suggestion='Consider adding lean protein sources like chicken, fish, or legumes',
                priority=1
            ))
        elif protein > protein_goal * 1.2:
            insights.append(NutritionalInsight(
                type='achievement',
                message='High protein day!',
                suggestion='Excellent for muscle maintenance and satiety',
                priority=3
            ))
        
        # Sodium analysis
        sodium = day_nutrition.get('sodium', 0)
        sodium_goal = user_goals.get('sodium', 2300)
        
        if sodium > sodium_goal:
            insights.append(NutritionalInsight(
                type='warning',
                message='Sodium intake above recommended limit',
                suggestion='Choose lower-sodium alternatives and limit processed foods',
                priority=1
            ))
        
        return insights
    
    def _generate_overall_insights(self, daily_analyses: List[DailyNutritionAnalysis], user_goals: Dict[str, float]) -> List[NutritionalInsight]:
        """Generate overall insights across all days"""
        insights = []
        
        if not daily_analyses:
            return insights
        
        # Calculate averages
        avg_calories = sum(da.calories for da in daily_analyses) / len(daily_analyses)
        avg_protein = sum(da.protein for da in daily_analyses) / len(daily_analyses)
        
        # Overall calorie consistency
        calorie_variance = sum((da.calories - avg_calories) ** 2 for da in daily_analyses) / len(daily_analyses)
        calorie_std = calorie_variance ** 0.5
        
        if calorie_std < avg_calories * 0.1:  # Less than 10% variance
            insights.append(NutritionalInsight(
                type='achievement',
                message='Excellent calorie consistency across days!',
                suggestion='Your meal plan provides steady energy levels',
                priority=3
            ))
        
        # Protein adequacy across plan
        protein_goal = user_goals.get('protein', 150)
        if avg_protein >= protein_goal * 0.9:
            insights.append(NutritionalInsight(
                type='achievement',
                message='Protein goals well met throughout the plan',
                suggestion='Great for muscle maintenance and recovery',
                priority=3
            ))
        
        return insights
    
    def _analyze_cost_tracking(self, meal_plan, user_goals: Dict[str, float]) -> Dict[str, Any]:
        """Analyze cost efficiency and budget adherence"""
        total_cost = (meal_plan.estimated_total_cost_usd or 0) / 100.0
        daily_cost = total_cost / meal_plan.duration_days
        budget_target = (meal_plan.budget_target_usd or 0) / 100.0
        
        # Calculate cost per calorie
        total_calories = sum(
            day_nutrition.get('calories', 0) 
            for day_nutrition in (meal_plan.daily_nutrition_breakdown or {}).values()
        )
        cost_per_calorie = total_cost / total_calories if total_calories > 0 else 0
        
        # Budget analysis
        budget_adherence = 'within_budget' if meal_plan.is_within_budget else 'over_budget'
        budget_variance = ((total_cost / budget_target) - 1) * 100 if budget_target > 0 else 0
        
        return {
            'total_cost_usd': total_cost,
            'daily_average_cost_usd': daily_cost,
            'budget_target_usd': budget_target,
            'budget_adherence': budget_adherence,
            'budget_variance_percent': budget_variance,
            'cost_per_calorie': cost_per_calorie,
            'cost_efficiency_rating': self._calculate_cost_efficiency_rating(cost_per_calorie)
        }
    
    def _calculate_cost_efficiency_rating(self, cost_per_calorie: float) -> str:
        """Rate cost efficiency based on cost per calorie"""
        if cost_per_calorie < 0.002:  # Less than $0.002 per calorie
            return 'excellent'
        elif cost_per_calorie < 0.004:
            return 'good'
        elif cost_per_calorie < 0.006:
            return 'fair'
        else:
            return 'expensive'
    
    def _generate_recommendations(self, daily_analyses: List[DailyNutritionAnalysis], overall_insights: List[NutritionalInsight]) -> List[str]:
        """Generate actionable recommendations based on analysis"""
        recommendations = []
        
        # Analyze patterns across days
        high_priority_insights = [insight for da in daily_analyses for insight in da.insights if insight.priority == 1]
        
        # Group similar insights
        insight_counts = {}
        for insight in high_priority_insights:
            key = insight.type + '_' + insight.message.split()[0].lower()
            insight_counts[key] = insight_counts.get(key, 0) + 1
        
        # Generate recommendations based on frequent issues
        if insight_counts.get('warning_calories', 0) >= len(daily_analyses) * 0.5:
            recommendations.append("Consider reducing portion sizes or choosing lower-calorie alternatives")
        
        if insight_counts.get('suggestion_low', 0) >= len(daily_analyses) * 0.5:
            recommendations.append("Add more protein-rich foods like lean meats, fish, eggs, or legumes")
        
        if insight_counts.get('warning_sodium', 0) >= len(daily_analyses) * 0.3:
            recommendations.append("Reduce sodium by choosing fresh ingredients over processed foods")
        
        # Add positive reinforcement
        achievement_count = sum(1 for da in daily_analyses for insight in da.insights if insight.type == 'achievement')
        if achievement_count >= len(daily_analyses):
            recommendations.append("Excellent work! Your meal plan is well-balanced and meets your goals")
        
        return recommendations
    
    def _identify_achievements(self, daily_analyses: List[DailyNutritionAnalysis], user_goals: Dict[str, float]) -> List[str]:
        """Identify nutritional achievements to highlight"""
        achievements = []
        
        # Check for consistent goal adherence
        calorie_goal_days = sum(1 for da in daily_analyses 
                               if 90 <= da.goal_adherence.get('calories', 0) <= 110)
        
        if calorie_goal_days == len(daily_analyses):
            achievements.append("Perfect calorie balance all days!")
        elif calorie_goal_days >= len(daily_analyses) * 0.8:
            achievements.append("Great calorie consistency!")
        
        # Check protein achievements
        protein_goal_days = sum(1 for da in daily_analyses 
                               if da.goal_adherence.get('protein', 0) >= 90)
        
        if protein_goal_days >= len(daily_analyses) * 0.8:
            achievements.append("Excellent protein intake!")
        
        # Check for high-fiber days
        high_fiber_days = sum(1 for da in daily_analyses if da.fiber >= 25)
        if high_fiber_days >= len(daily_analyses) * 0.5:
            achievements.append("Great fiber intake for digestive health!")
        
        return achievements
    
    def _calculate_weekly_data(self, meal_plans) -> List[Dict[str, Any]]:
        """Calculate weekly aggregated nutrition data"""
        # This is a simplified implementation
        # In a real system, you'd group by actual weeks
        weekly_data = []
        
        for meal_plan in meal_plans:
            week_data = {
                'week_start': meal_plan.plan_date.isoformat(),
                'avg_calories': 0,
                'avg_protein': 0,
                'avg_carbs': 0,
                'avg_fat': 0,
                'total_cost': (meal_plan.estimated_total_cost_usd or 0) / 100.0
            }
            
            # Calculate averages from daily breakdown
            if meal_plan.daily_nutrition_breakdown:
                daily_values = list(meal_plan.daily_nutrition_breakdown.values())
                if daily_values:
                    week_data['avg_calories'] = sum(d.get('calories', 0) for d in daily_values) / len(daily_values)
                    week_data['avg_protein'] = sum(d.get('protein', 0) for d in daily_values) / len(daily_values)
                    week_data['avg_carbs'] = sum(d.get('carbs', 0) for d in daily_values) / len(daily_values)
                    week_data['avg_fat'] = sum(d.get('fat', 0) for d in daily_values) / len(daily_values)
            
            weekly_data.append(week_data)
        
        return weekly_data
    
    def _analyze_trends(self, weekly_data: List[Dict[str, Any]]) -> WeeklyTrends:
        """Analyze trends from weekly data"""
        if len(weekly_data) < 2:
            # Not enough data for trend analysis
            return WeeklyTrends(
                avg_calories=weekly_data[0]['avg_calories'] if weekly_data else 0,
                avg_protein=weekly_data[0]['avg_protein'] if weekly_data else 0,
                avg_carbs=weekly_data[0]['avg_carbs'] if weekly_data else 0,
                avg_fat=weekly_data[0]['avg_fat'] if weekly_data else 0,
                avg_cost=weekly_data[0]['total_cost'] if weekly_data else 0,
                calorie_consistency=0,
                protein_trend='stable',
                cost_trend='stable',
                best_day='N/A',
                improvement_areas=[]
            )
        
        # Calculate averages
        avg_calories = sum(w['avg_calories'] for w in weekly_data) / len(weekly_data)
        avg_protein = sum(w['avg_protein'] for w in weekly_data) / len(weekly_data)
        avg_carbs = sum(w['avg_carbs'] for w in weekly_data) / len(weekly_data)
        avg_fat = sum(w['avg_fat'] for w in weekly_data) / len(weekly_data)
        avg_cost = sum(w['total_cost'] for w in weekly_data) / len(weekly_data)
        
        # Calculate consistency (lower variance = higher consistency)
        calorie_variance = sum((w['avg_calories'] - avg_calories) ** 2 for w in weekly_data) / len(weekly_data)
        calorie_consistency = max(0, 100 - (calorie_variance ** 0.5) / avg_calories * 100)
        
        # Determine trends
        protein_trend = self._determine_trend([w['avg_protein'] for w in weekly_data])
        cost_trend = self._determine_trend([w['total_cost'] for w in weekly_data])
        
        # Find best week (highest protein, lowest cost, closest to calorie target)
        best_week_idx = 0
        best_score = 0
        for i, week in enumerate(weekly_data):
            # Simple scoring: high protein, reasonable calories, low cost
            score = week['avg_protein'] - abs(week['avg_calories'] - 2000) * 0.01 - week['total_cost']
            if score > best_score:
                best_score = score
                best_week_idx = i
        
        best_day = weekly_data[best_week_idx]['week_start']
        
        # Identify improvement areas
        improvement_areas = []
        if avg_protein < 100:
            improvement_areas.append('protein_intake')
        if calorie_consistency < 70:
            improvement_areas.append('calorie_consistency')
        if avg_cost > 50:  # Arbitrary threshold
            improvement_areas.append('cost_management')
        
        return WeeklyTrends(
            avg_calories=avg_calories,
            avg_protein=avg_protein,
            avg_carbs=avg_carbs,
            avg_fat=avg_fat,
            avg_cost=avg_cost,
            calorie_consistency=calorie_consistency,
            protein_trend=protein_trend,
            cost_trend=cost_trend,
            best_day=best_day,
            improvement_areas=improvement_areas
        )
    
    def _determine_trend(self, values: List[float]) -> str:
        """Determine if values show increasing, decreasing, or stable trend"""
        if len(values) < 2:
            return 'stable'
        
        # Simple linear trend analysis
        first_half = sum(values[:len(values)//2]) / (len(values)//2)
        second_half = sum(values[len(values)//2:]) / (len(values) - len(values)//2)
        
        change_percent = ((second_half - first_half) / first_half) * 100 if first_half > 0 else 0
        
        if change_percent > 5:
            return 'increasing'
        elif change_percent < -5:
            return 'decreasing'
        else:
            return 'stable'
    
    def _generate_trend_insights(self, trends: WeeklyTrends) -> List[str]:
        """Generate insights from trend analysis"""
        insights = []
        
        if trends.protein_trend == 'increasing':
            insights.append("Your protein intake is improving over time!")
        elif trends.protein_trend == 'decreasing':
            insights.append("Consider focusing on protein-rich foods to maintain intake")
        
        if trends.cost_trend == 'decreasing':
            insights.append("Great job managing food costs efficiently!")
        elif trends.cost_trend == 'increasing':
            insights.append("Food costs are trending up - consider budget-friendly alternatives")
        
        if trends.calorie_consistency > 80:
            insights.append("Excellent consistency in your eating patterns!")
        elif trends.calorie_consistency < 60:
            insights.append("Try to maintain more consistent daily calorie intake")
        
        return insights
    
    def _calculate_avg_goal_adherence(self, daily_analyses: List[DailyNutritionAnalysis]) -> Dict[str, float]:
        """Calculate average goal adherence across all days"""
        if not daily_analyses:
            return {}
        
        avg_adherence = {}
        nutrients = ['calories', 'protein', 'carbs', 'fat']
        
        for nutrient in nutrients:
            total_adherence = sum(da.goal_adherence.get(nutrient, 0) for da in daily_analyses)
            avg_adherence[nutrient] = total_adherence / len(daily_analyses)
        
        return avg_adherence
    
    # Helper methods to convert dataclasses to dictionaries
    def _daily_analysis_to_dict(self, analysis: DailyNutritionAnalysis) -> Dict[str, Any]:
        """Convert DailyNutritionAnalysis to dictionary"""
        return {
            'date': analysis.date,
            'calories': analysis.calories,
            'protein': analysis.protein,
            'carbs': analysis.carbs,
            'fat': analysis.fat,
            'fiber': analysis.fiber,
            'sodium': analysis.sodium,
            'goal_adherence': analysis.goal_adherence,
            'insights': [self._insight_to_dict(insight) for insight in analysis.insights],
            'cost_usd': analysis.cost_usd
        }
    
    def _insight_to_dict(self, insight: NutritionalInsight) -> Dict[str, Any]:
        """Convert NutritionalInsight to dictionary"""
        return {
            'type': insight.type,
            'message': insight.message,
            'suggestion': insight.suggestion,
            'priority': insight.priority
        }
    
    def _trends_to_dict(self, trends: WeeklyTrends) -> Dict[str, Any]:
        """Convert WeeklyTrends to dictionary"""
        return {
            'avg_calories': trends.avg_calories,
            'avg_protein': trends.avg_protein,
            'avg_carbs': trends.avg_carbs,
            'avg_fat': trends.avg_fat,
            'avg_cost': trends.avg_cost,
            'calorie_consistency': trends.calorie_consistency,
            'protein_trend': trends.protein_trend,
            'cost_trend': trends.cost_trend,
            'best_day': trends.best_day,
            'improvement_areas': trends.improvement_areas
        } 