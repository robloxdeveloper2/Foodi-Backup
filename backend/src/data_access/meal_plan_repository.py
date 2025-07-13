"""
MealPlan Repository  
Data access layer for MealPlan model operations
"""

import logging
from datetime import date, datetime, timedelta
from typing import Optional, List, Dict, Any
from sqlalchemy.orm import Session
from sqlalchemy import and_, desc

from core.models.meal_plan import MealPlan
from core.exceptions import ValidationError
from data_access.database import db

logger = logging.getLogger(__name__)

class MealPlanRepository:
    """Repository for MealPlan data access operations"""
    
    def __init__(self, session: Optional[Session] = None):
        """Initialize repository with optional session"""
        self.session = session or db.session
    
    def create_meal_plan(self, meal_plan: MealPlan) -> MealPlan:
        """Create a new meal plan"""
        try:
            self.session.add(meal_plan)
            self.session.commit()
            
            logger.info(f"Meal plan created successfully: {meal_plan.id}")
            return meal_plan
            
        except Exception as e:
            self.session.rollback()
            logger.error(f"Error creating meal plan: {str(e)}")
            raise ValidationError(f"Failed to create meal plan: {str(e)}")
    
    def get_meal_plan_by_id(self, plan_id: str, user_id: Optional[str] = None) -> Optional[MealPlan]:
        """Get meal plan by ID, optionally filtered by user"""
        try:
            query = self.session.query(MealPlan).filter(
                and_(MealPlan.id == plan_id, MealPlan.is_active == True)
            )
            
            if user_id:
                query = query.filter(MealPlan.user_id == user_id)
            
            meal_plan = query.first()
            
            if meal_plan:
                logger.debug(f"Meal plan found: {plan_id}")
            else:
                logger.debug(f"Meal plan not found: {plan_id}")
            
            return meal_plan
            
        except Exception as e:
            logger.error(f"Error getting meal plan {plan_id}: {str(e)}")
            raise ValidationError(f"Failed to get meal plan: {str(e)}")
    
    def get_user_meal_plans(self, user_id: str, limit: Optional[int] = None, offset: Optional[int] = None, include_inactive: bool = False) -> List[MealPlan]:
        """Get all meal plans for a user"""
        try:
            query = self.session.query(MealPlan).filter(MealPlan.user_id == user_id)
            
            if not include_inactive:
                query = query.filter(MealPlan.is_active == True)
            
            # Order by creation date (newest first)
            query = query.order_by(desc(MealPlan.created_at))
            
            if offset:
                query = query.offset(offset)
            
            if limit:
                query = query.limit(limit)
            
            meal_plans = query.all()
            logger.debug(f"Found {len(meal_plans)} meal plans for user: {user_id}")
            return meal_plans
            
        except Exception as e:
            logger.error(f"Error getting meal plans for user {user_id}: {str(e)}")
            raise ValidationError(f"Failed to get meal plans: {str(e)}")
    
    def get_meal_plans_by_date_range(self, user_id: str, start_date: date, 
                                    end_date: date) -> List[MealPlan]:
        """Get meal plans within a date range"""
        try:
            meal_plans = self.session.query(MealPlan).filter(
                and_(
                    MealPlan.user_id == user_id,
                    MealPlan.plan_date >= start_date,
                    MealPlan.plan_date <= end_date,
                    MealPlan.is_active == True
                )
            ).order_by(MealPlan.plan_date).all()
            
            logger.debug(f"Found {len(meal_plans)} meal plans for user {user_id} between {start_date} and {end_date}")
            return meal_plans
            
        except Exception as e:
            logger.error(f"Error getting meal plans by date range: {str(e)}")
            raise ValidationError(f"Failed to get meal plans: {str(e)}")
    
    def get_current_meal_plan(self, user_id: str, target_date: Optional[date] = None) -> Optional[MealPlan]:
        """Get the current active meal plan for a user"""
        if target_date is None:
            target_date = date.today()
        
        try:
            meal_plan = self.session.query(MealPlan).filter(
                and_(
                    MealPlan.user_id == user_id,
                    MealPlan.plan_date <= target_date,
                    MealPlan.is_active == True
                )
            ).order_by(desc(MealPlan.plan_date)).first()
            
            # Check if the meal plan covers the target date
            if meal_plan and target_date <= meal_plan.end_date:
                logger.debug(f"Current meal plan found for user {user_id}: {meal_plan.id}")
                return meal_plan
            
            logger.debug(f"No current meal plan found for user {user_id} on {target_date}")
            return None
            
        except Exception as e:
            logger.error(f"Error getting current meal plan for user {user_id}: {str(e)}")
            raise ValidationError(f"Failed to get current meal plan: {str(e)}")
    
    def get_recent_meal_plans(self, user_id: str, days: int = 30) -> List[MealPlan]:
        """Get recent meal plans for a user within specified days"""
        try:
            cutoff_date = date.today() - timedelta(days=days)
            
            meal_plans = self.session.query(MealPlan).filter(
                and_(
                    MealPlan.user_id == user_id,
                    MealPlan.plan_date >= cutoff_date,
                    MealPlan.is_active == True
                )
            ).order_by(desc(MealPlan.plan_date)).all()
            
            logger.debug(f"Found {len(meal_plans)} recent meal plans for user {user_id}")
            return meal_plans
            
        except Exception as e:
            logger.error(f"Error getting recent meal plans for user {user_id}: {str(e)}")
            raise ValidationError(f"Failed to get recent meal plans: {str(e)}")
    
    def update_meal_plan(self, plan_id: str, user_id: str, update_data: Dict[str, Any]) -> MealPlan:
        """Update an existing meal plan"""
        try:
            meal_plan = self.get_meal_plan_by_id(plan_id, user_id)
            if not meal_plan:
                raise ValidationError(f"Meal plan not found: {plan_id}")
            
            # Update fields
            for field, value in update_data.items():
                if hasattr(meal_plan, field):
                    setattr(meal_plan, field, value)
            
            meal_plan.updated_at = datetime.utcnow()
            self.session.commit()
            
            logger.info(f"Meal plan updated successfully: {plan_id}")
            return meal_plan
            
        except Exception as e:
            self.session.rollback()
            logger.error(f"Error updating meal plan {plan_id}: {str(e)}")
            raise ValidationError(f"Failed to update meal plan: {str(e)}")
    
    def add_user_feedback(self, plan_id: str, user_id: str, rating: int, 
                         feedback: Optional[str] = None) -> MealPlan:
        """Add user feedback to a meal plan"""
        try:
            meal_plan = self.get_meal_plan_by_id(plan_id, user_id)
            if not meal_plan:
                raise ValidationError(f"Meal plan not found: {plan_id}")
            
            meal_plan.add_user_feedback(rating, feedback)
            self.session.commit()
            
            logger.info(f"User feedback added to meal plan {plan_id}: rating={rating}")
            return meal_plan
            
        except Exception as e:
            self.session.rollback()
            logger.error(f"Error adding feedback to meal plan {plan_id}: {str(e)}")
            raise ValidationError(f"Failed to add feedback: {str(e)}")
    
    def delete_meal_plan(self, plan_id: str, user_id: str) -> bool:
        """Soft delete a meal plan (mark as inactive)"""
        try:
            meal_plan = self.get_meal_plan_by_id(plan_id, user_id)
            if not meal_plan:
                raise ValidationError(f"Meal plan not found: {plan_id}")
            
            meal_plan.is_active = False
            meal_plan.updated_at = datetime.utcnow()
            self.session.commit()
            
            logger.info(f"Meal plan deleted successfully: {plan_id}")
            return True
            
        except Exception as e:
            self.session.rollback()
            logger.error(f"Error deleting meal plan {plan_id}: {str(e)}")
            raise ValidationError(f"Failed to delete meal plan: {str(e)}")
    
    def get_meal_plan_statistics(self, user_id: Optional[str] = None) -> Dict[str, Any]:
        """Get meal plan statistics"""
        try:
            query = self.session.query(MealPlan).filter(MealPlan.is_active == True)
            
            if user_id:
                query = query.filter(MealPlan.user_id == user_id)
            
            meal_plans = query.all()
            
            total_count = len(meal_plans)
            
            # Calculate average ratings
            rated_plans = [mp for mp in meal_plans if mp.user_rating is not None]
            avg_rating = sum(mp.user_rating for mp in rated_plans) / len(rated_plans) if rated_plans else None
            
            # Calculate budget adherence
            budget_compliant = [mp for mp in meal_plans if mp.is_within_budget]
            budget_adherence_rate = len(budget_compliant) / total_count if total_count > 0 else 0
            
            # Calculate duration distribution
            duration_distribution = {}
            for mp in meal_plans:
                duration = mp.duration_days
                duration_distribution[duration] = duration_distribution.get(duration, 0) + 1
            
            # Calculate variety scores
            variety_scores = [mp.calculate_variety_score() for mp in meal_plans]
            avg_variety_score = sum(variety_scores) / len(variety_scores) if variety_scores else 0
            
            stats = {
                'total_meal_plans': total_count,
                'average_rating': avg_rating,
                'budget_adherence_rate': budget_adherence_rate,
                'average_variety_score': avg_variety_score,
                'duration_distribution': duration_distribution,
                'rated_plans_count': len(rated_plans)
            }
            
            if user_id:
                # User-specific stats
                recent_plans = [mp for mp in meal_plans 
                               if mp.plan_date >= date.today() - timedelta(days=30)]
                stats['recent_plans_count'] = len(recent_plans)
            
            logger.debug(f"Meal plan statistics: {stats}")
            return stats
            
        except Exception as e:
            logger.error(f"Error getting meal plan statistics: {str(e)}")
            raise ValidationError(f"Failed to get meal plan statistics: {str(e)}")
    
    def get_popular_recipes(self, user_id: Optional[str] = None, limit: int = 10) -> List[Dict[str, Any]]:
        """Get most popular recipes from meal plans"""
        try:
            query = self.session.query(MealPlan).filter(MealPlan.is_active == True)
            
            if user_id:
                query = query.filter(MealPlan.user_id == user_id)
            
            meal_plans = query.all()
            
            # Count recipe usage
            recipe_counts = {}
            for meal_plan in meal_plans:
                for meal in meal_plan.meals:
                    recipe_id = meal.get('recipe_id')
                    recipe_name = meal.get('recipe_name', 'Unknown')
                    if recipe_id:
                        if recipe_id not in recipe_counts:
                            recipe_counts[recipe_id] = {
                                'recipe_id': recipe_id,
                                'recipe_name': recipe_name,
                                'usage_count': 0,
                                'meal_types': set()
                            }
                        recipe_counts[recipe_id]['usage_count'] += 1
                        recipe_counts[recipe_id]['meal_types'].add(meal.get('meal_type'))
            
            # Convert sets to lists and sort by usage
            popular_recipes = []
            for recipe_data in recipe_counts.values():
                recipe_data['meal_types'] = list(recipe_data['meal_types'])
                popular_recipes.append(recipe_data)
            
            # Sort by usage count and limit
            popular_recipes.sort(key=lambda x: x['usage_count'], reverse=True)
            popular_recipes = popular_recipes[:limit]
            
            logger.debug(f"Found {len(popular_recipes)} popular recipes")
            return popular_recipes
            
        except Exception as e:
            logger.error(f"Error getting popular recipes: {str(e)}")
            raise ValidationError(f"Failed to get popular recipes: {str(e)}")
    
    def check_for_existing_plan(self, user_id: str, plan_date: date, duration_days: int) -> Optional[MealPlan]:
        """Check if there's an existing meal plan that overlaps with the requested period"""
        try:
            end_date = plan_date + timedelta(days=duration_days - 1)
            
            # Find any meal plans that overlap with the requested period
            existing_plans = self.session.query(MealPlan).filter(
                and_(
                    MealPlan.user_id == user_id,
                    MealPlan.is_active == True,
                    # Check for overlap: plan starts before our end date and ends after our start date
                    MealPlan.plan_date <= end_date,
                    # Use SQL expression for end date calculation
                    MealPlan.plan_date + MealPlan.duration_days - 1 >= plan_date
                )
            ).all()
            
            if existing_plans:
                logger.debug(f"Found {len(existing_plans)} overlapping meal plans for user {user_id}")
                return existing_plans[0]  # Return the first overlapping plan
            
            return None
            
        except Exception as e:
            logger.error(f"Error checking for existing plans: {str(e)}")
            raise ValidationError(f"Failed to check for existing plans: {str(e)}")
    
    def get_nutrition_trends(self, user_id: str, days: int = 30) -> Dict[str, Any]:
        """Get nutrition trends for a user over time"""
        try:
            cutoff_date = date.today() - timedelta(days=days)
            
            meal_plans = self.session.query(MealPlan).filter(
                and_(
                    MealPlan.user_id == user_id,
                    MealPlan.plan_date >= cutoff_date,
                    MealPlan.is_active == True
                )
            ).order_by(MealPlan.plan_date).all()
            
            # Extract daily nutrition data
            daily_nutrition = []
            for meal_plan in meal_plans:
                if meal_plan.daily_nutrition_breakdown:
                    for day, nutrition in meal_plan.daily_nutrition_breakdown.items():
                        if isinstance(nutrition, dict) and 'calories' in nutrition:
                            daily_nutrition.append({
                                'date': (meal_plan.plan_date + timedelta(days=int(day)-1)).isoformat(),
                                'calories': nutrition.get('calories', 0),
                                'protein': nutrition.get('protein', 0),
                                'carbs': nutrition.get('carbs', 0),
                                'fat': nutrition.get('fat', 0)
                            })
            
            # Calculate averages
            if daily_nutrition:
                avg_calories = sum(day['calories'] for day in daily_nutrition) / len(daily_nutrition)
                avg_protein = sum(day['protein'] for day in daily_nutrition) / len(daily_nutrition)
                avg_carbs = sum(day['carbs'] for day in daily_nutrition) / len(daily_nutrition)
                avg_fat = sum(day['fat'] for day in daily_nutrition) / len(daily_nutrition)
            else:
                avg_calories = avg_protein = avg_carbs = avg_fat = 0
            
            trends = {
                'daily_nutrition': daily_nutrition,
                'averages': {
                    'calories': avg_calories,
                    'protein': avg_protein,
                    'carbs': avg_carbs,
                    'fat': avg_fat
                },
                'total_days': len(daily_nutrition)
            }
            
            logger.debug(f"Nutrition trends calculated for user {user_id}: {len(daily_nutrition)} days")
            return trends
            
        except Exception as e:
            logger.error(f"Error getting nutrition trends for user {user_id}: {str(e)}")
            raise ValidationError(f"Failed to get nutrition trends: {str(e)}") 