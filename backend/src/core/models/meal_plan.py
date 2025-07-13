"""
MealPlan Domain Model
Represents a generated meal plan for a user
"""

import uuid
from datetime import datetime, date
from typing import Optional, List, Dict, Any
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy import Column, String, DateTime, Date, Boolean, ForeignKey
from sqlalchemy.types import JSON

from data_access.database import db

class MealPlan(db.Model):
    """MealPlan model for storing generated meal plans"""
    
    __tablename__ = 'meal_plans'
    
    # Primary Fields
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey('users.id'), nullable=False)
    
    # Plan Configuration
    plan_date = Column(Date, nullable=False)  # Start date of the plan
    duration_days = Column(db.Integer, default=1)  # Number of days (1-7)
    
    # Meal Data - stored as JSON for flexibility
    meals = Column(JSON, nullable=False)  # [{"meal_type": "breakfast", "recipe_id": "xyz", "day": 1}]
    
    # Nutritional Summary
    total_nutrition_summary = Column(JSON, nullable=True)  # {"calories": 2000, "protein": 100, "carbs": 250, "fat": 65}
    daily_nutrition_breakdown = Column(JSON, nullable=True)  # Per-day nutrition breakdown
    
    # Generation Metadata
    generated_by_ai = Column(Boolean, default=True)
    generation_parameters = Column(JSON, nullable=True)  # Parameters used for generation
    algorithm_version = Column(String(50), nullable=True)  # Version of algorithm used
    
    # Budget and Preferences
    estimated_total_cost_usd = Column(db.Integer, nullable=True)  # Total cost in cents
    budget_target_usd = Column(db.Integer, nullable=True)  # Target budget in cents
    dietary_restrictions_used = Column(JSON, nullable=True)  # Restrictions applied during generation
    
    # Status and Feedback
    is_active = Column(Boolean, default=True)
    user_rating = Column(db.Integer, nullable=True)  # 1-5 rating from user
    user_feedback = Column(String(1000), nullable=True)  # Optional feedback text
    
    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    def __init__(self, user_id: str, plan_date: date, meals: List[Dict[str, Any]],
                 duration_days: int = 1, total_nutrition_summary: Optional[Dict[str, Any]] = None,
                 daily_nutrition_breakdown: Optional[Dict[str, Any]] = None,
                 generated_by_ai: bool = True, generation_parameters: Optional[Dict[str, Any]] = None,
                 algorithm_version: Optional[str] = None, estimated_total_cost_usd: Optional[int] = None,
                 budget_target_usd: Optional[int] = None, dietary_restrictions_used: Optional[List[str]] = None):
        """Initialize a new meal plan"""
        self.user_id = user_id
        self.plan_date = plan_date
        self.duration_days = duration_days
        self.meals = meals
        self.total_nutrition_summary = total_nutrition_summary or {}
        self.daily_nutrition_breakdown = daily_nutrition_breakdown or {}
        self.generated_by_ai = generated_by_ai
        self.generation_parameters = generation_parameters or {}
        self.algorithm_version = algorithm_version
        self.estimated_total_cost_usd = estimated_total_cost_usd
        self.budget_target_usd = budget_target_usd
        self.dietary_restrictions_used = dietary_restrictions_used or []
    
    @property
    def end_date(self) -> date:
        """Calculate the end date of the meal plan"""
        from datetime import timedelta
        return self.plan_date + timedelta(days=self.duration_days - 1)
    
    @property
    def cost_per_day_usd(self) -> Optional[float]:
        """Calculate average cost per day in USD"""
        if self.estimated_total_cost_usd and self.duration_days > 0:
            return (self.estimated_total_cost_usd / 100.0) / self.duration_days
        return None
    
    @property
    def calories_per_day(self) -> Optional[float]:
        """Calculate average calories per day"""
        if self.total_nutrition_summary and 'calories' in self.total_nutrition_summary:
            return self.total_nutrition_summary['calories'] / self.duration_days
        return None
    
    @property
    def is_within_budget(self) -> Optional[bool]:
        """Check if meal plan is within budget (±10% tolerance)"""
        if not self.estimated_total_cost_usd or not self.budget_target_usd:
            return None
        
        tolerance = 0.10
        budget_min = self.budget_target_usd * (1 - tolerance)
        budget_max = self.budget_target_usd * (1 + tolerance)
        
        return budget_min <= self.estimated_total_cost_usd <= budget_max
    
    def get_meals_by_day(self, day: int) -> List[Dict[str, Any]]:
        """Get all meals for a specific day"""
        return [meal for meal in self.meals if meal.get('day') == day]
    
    def get_meals_by_type(self, meal_type: str) -> List[Dict[str, Any]]:
        """Get all meals of a specific type across all days"""
        return [meal for meal in self.meals if meal.get('meal_type') == meal_type]
    
    def get_unique_recipes(self) -> List[str]:
        """Get list of unique recipe IDs used in this meal plan"""
        return list(set(meal.get('recipe_id') for meal in self.meals if meal.get('recipe_id')))
    
    def calculate_variety_score(self) -> float:
        """Calculate variety score based on unique recipes vs total meals"""
        if not self.meals:
            return 0.0
        
        unique_recipes = len(self.get_unique_recipes())
        total_meals = len(self.meals)
        
        return unique_recipes / total_meals if total_meals > 0 else 0.0
    
    def add_user_feedback(self, rating: int, feedback: Optional[str] = None) -> None:
        """Add user rating and feedback"""
        if not 1 <= rating <= 5:
            raise ValueError("Rating must be between 1 and 5")
        
        self.user_rating = rating
        self.user_feedback = feedback
        self.updated_at = datetime.utcnow()
    
    def validate_meal_plan_structure(self) -> bool:
        """Validate that the meal plan has proper structure"""
        if not self.meals:
            return False
        
        required_meal_fields = ['meal_type', 'recipe_id', 'day']
        valid_meal_types = ['breakfast', 'lunch', 'dinner', 'snack']
        
        for meal in self.meals:
            # Check required fields
            if not all(field in meal for field in required_meal_fields):
                return False
            
            # Check valid meal type
            if meal['meal_type'] not in valid_meal_types:
                return False
            
            # Check valid day range
            if not 1 <= meal['day'] <= self.duration_days:
                return False
        
        return True
    
    def to_dict(self, include_detailed_nutrition: bool = False) -> Dict[str, Any]:
        """Convert meal plan to dictionary for API responses"""
        result = {
            'id': str(self.id),
            'user_id': str(self.user_id),
            'plan_date': self.plan_date.isoformat(),
            'end_date': self.end_date.isoformat(),
            'duration_days': self.duration_days,
            'meals': self.meals,
            'total_nutrition_summary': self.total_nutrition_summary,
            'generated_by_ai': self.generated_by_ai,
            'algorithm_version': self.algorithm_version,
            'estimated_total_cost_usd': self.estimated_total_cost_usd,
            'cost_per_day_usd': self.cost_per_day_usd,
            'budget_target_usd': self.budget_target_usd,
            'is_within_budget': self.is_within_budget,
            'calories_per_day': self.calories_per_day,
            'dietary_restrictions_used': self.dietary_restrictions_used,
            'variety_score': self.calculate_variety_score(),
            'is_active': self.is_active,
            'user_rating': self.user_rating,
            'user_feedback': self.user_feedback,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None,
        }
        
        if include_detailed_nutrition:
            result['daily_nutrition_breakdown'] = self.daily_nutrition_breakdown
            result['generation_parameters'] = self.generation_parameters
        
        return result
    
    def __repr__(self) -> str:
        return f'<MealPlan {self.id} for user {self.user_id} ({self.plan_date} - {self.duration_days} days)>' 