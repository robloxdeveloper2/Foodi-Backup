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
    
    def get_by_id(self, plan_id: str, user_id: Optional[str] = None) -> Optional[MealPlan]:
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
    
    def get_meal_plan_by_id(self, plan_id: str, user_id: Optional[str] = None) -> Optional[MealPlan]:
        """Get meal plan by ID, optionally filtered by user (alias for compatibility)"""
        return self.get_by_id(plan_id, user_id)
    
    def get_user_meal_plans(self, user_id: str, limit: Optional[int] = None, 
                           offset: Optional[int] = None, include_inactive: bool = False) -> List[MealPlan]:
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
                logger.warning(f"Meal plan not found for deletion: {plan_id}")
                return False
            
            meal_plan.is_active = False
            meal_plan.updated_at = datetime.utcnow()
            self.session.commit()
            
            logger.info(f"Meal plan soft deleted successfully: {plan_id}")
            return True
            
        except Exception as e:
            self.session.rollback()
            logger.error(f"Error deleting meal plan {plan_id}: {str(e)}")
            raise ValidationError(f"Failed to delete meal plan: {str(e)}")
    
    def get_meal_plan_statistics(self, user_id: Optional[str] = None) -> Dict[str, Any]:
        """Get comprehensive meal plan statistics"""
        try:
            query = self.session.query(MealPlan).filter(MealPlan.is_active == True)
            
            if user_id:
                query = query.filter(MealPlan.user_id == user_id)
            
            meal_plans = query.all()
            
            total_plans = len(meal_plans)
            total_cost = sum([plan.estimated_total_cost_usd or 0 for plan in meal_plans])
            avg_cost = total_cost / total_plans if total_plans > 0 else 0
            
            # Calculate budget compliance
            within_budget = len([plan for plan in meal_plans if plan.is_within_budget])
            budget_compliance = (within_budget / total_plans * 100) if total_plans > 0 else 0
            
            # Nutrition analysis
            total_calories = sum([plan.total_nutrition_summary.get('calories', 0) 
                                for plan in meal_plans if plan.total_nutrition_summary])
            avg_calories = total_calories / total_plans if total_plans > 0 else 0
            
            # User feedback analysis
            rated_plans = [plan for plan in meal_plans if plan.user_rating]
            avg_rating = sum([plan.user_rating for plan in rated_plans]) / len(rated_plans) if rated_plans else 0
            
            stats = {
                'total_meal_plans': total_plans,
                'total_cost_usd': total_cost,
                'average_cost_per_plan': avg_cost,
                'budget_compliance_percentage': budget_compliance,
                'average_calories_per_plan': avg_calories,
                'average_user_rating': avg_rating,
                'total_rated_plans': len(rated_plans)
            }
            
            if user_id:
                logger.debug(f"Meal plan statistics for user {user_id}: {stats}")
            else:
                logger.debug(f"Global meal plan statistics: {stats}")
            
            return stats
            
        except Exception as e:
            logger.error(f"Error getting meal plan statistics: {str(e)}")
            raise ValidationError(f"Failed to get statistics: {str(e)}")
    
    def get_popular_recipes(self, user_id: Optional[str] = None, limit: int = 10) -> List[Dict[str, Any]]:
        """Get most popular recipes from meal plans"""
        try:
            query = self.session.query(MealPlan).filter(MealPlan.is_active == True)
            
            if user_id:
                query = query.filter(MealPlan.user_id == user_id)
            
            meal_plans = query.all()
            
            # Count recipe occurrences
            recipe_counts = {}
            for plan in meal_plans:
                for meal in plan.meals:
                    recipe_id = meal.get('recipe_id')
                    if recipe_id:
                        if recipe_id not in recipe_counts:
                            recipe_counts[recipe_id] = 0
                        recipe_counts[recipe_id] += 1
            
            # Sort by popularity and limit
            popular_recipes = sorted(recipe_counts.items(), key=lambda x: x[1], reverse=True)[:limit]
            
            result = [
                {
                    'recipe_id': recipe_id,
                    'usage_count': count,
                    'popularity_score': count / len(meal_plans) if meal_plans else 0
                }
                for recipe_id, count in popular_recipes
            ]
            
            logger.debug(f"Found {len(result)} popular recipes")
            return result
            
        except Exception as e:
            logger.error(f"Error getting popular recipes: {str(e)}")
            raise ValidationError(f"Failed to get popular recipes: {str(e)}")
    
    def check_for_existing_plan(self, user_id: str, plan_date: date, duration_days: int) -> Optional[MealPlan]:
        """Check if a meal plan already exists for the given date range"""
        try:
            end_date = plan_date + timedelta(days=duration_days - 1)
            
            existing_plan = self.session.query(MealPlan).filter(
                and_(
                    MealPlan.user_id == user_id,
                    MealPlan.is_active == True,
                    # Check for overlap
                    MealPlan.plan_date <= end_date,
                    # Using the calculated end_date property
                    # Note: This might need adjustment based on your exact end_date calculation
                )
            ).first()
            
            if existing_plan:
                logger.debug(f"Existing meal plan found for user {user_id} overlapping with {plan_date}")
            
            return existing_plan
            
        except Exception as e:
            logger.error(f"Error checking for existing meal plan: {str(e)}")
            raise ValidationError(f"Failed to check for existing plan: {str(e)}")
    
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
            
            # Analyze nutrition trends
            nutrition_data = []
            for plan in meal_plans:
                if plan.total_nutrition_summary:
                    nutrition_data.append({
                        'date': plan.plan_date.isoformat(),
                        'calories': plan.total_nutrition_summary.get('calories', 0),
                        'protein': plan.total_nutrition_summary.get('protein', 0),
                        'carbs': plan.total_nutrition_summary.get('carbs', 0),
                        'fat': plan.total_nutrition_summary.get('fat', 0)
                    })
            
            # Calculate averages
            if nutrition_data:
                avg_calories = sum([d['calories'] for d in nutrition_data]) / len(nutrition_data)
                avg_protein = sum([d['protein'] for d in nutrition_data]) / len(nutrition_data)
                avg_carbs = sum([d['carbs'] for d in nutrition_data]) / len(nutrition_data)
                avg_fat = sum([d['fat'] for d in nutrition_data]) / len(nutrition_data)
            else:
                avg_calories = avg_protein = avg_carbs = avg_fat = 0
            
            trends = {
                'daily_nutrition': nutrition_data,
                'averages': {
                    'calories': avg_calories,
                    'protein': avg_protein,
                    'carbs': avg_carbs,
                    'fat': avg_fat
                },
                'total_days': len(nutrition_data),
                'date_range': {
                    'start': cutoff_date.isoformat(),
                    'end': date.today().isoformat()
                }
            }
            
            logger.debug(f"Nutrition trends calculated for user {user_id}: {days} days")
            return trends
            
        except Exception as e:
            logger.error(f"Error getting nutrition trends for user {user_id}: {str(e)}")
            raise ValidationError(f"Failed to get nutrition trends: {str(e)}") 