"""
Meal Plan API Request and Response Schemas
Pydantic models for validating API data
"""

from datetime import date
from typing import Optional, List, Dict, Any
from pydantic import BaseModel, Field, validator

class MealPlanGenerationRequest(BaseModel):
    """Request schema for meal plan generation"""
    duration_days: int = Field(..., ge=1, le=7, description="Number of days for the meal plan (1-7)")
    plan_date: Optional[date] = Field(None, description="Start date for the meal plan (defaults to today)")
    budget_usd: Optional[float] = Field(None, ge=0, description="Budget constraint in USD")
    include_snacks: bool = Field(False, description="Whether to include snacks in the meal plan")
    force_regenerate: bool = Field(False, description="Force regeneration even if recent plan exists")

class MealPlanRegenerateRequest(BaseModel):
    """Request schema for meal plan regeneration with feedback"""
    rating: Optional[int] = Field(None, ge=1, le=5, description="User rating for the previous meal plan (1-5)")
    feedback: Optional[str] = Field(None, max_length=1000, description="User feedback text")

class MealPlanResponse(BaseModel):
    """Response schema for meal plan operations"""
    success: bool
    message: str
    meal_plan: Optional[Dict[str, Any]] = None

class MealPlanListResponse(BaseModel):
    """Response schema for meal plan list operations"""
    success: bool
    message: str
    meal_plans: List[Dict[str, Any]]
    total_count: int
    limit: int
    offset: int

class MealPlanStatsResponse(BaseModel):
    """Response schema for meal plan statistics"""
    success: bool
    message: str
    stats: Dict[str, Any]

# New schemas for nutritional analysis
class NutritionalAnalysisResponse(BaseModel):
    """Response schema for nutritional analysis"""
    success: bool
    message: str
    analysis: Dict[str, Any]

class WeeklyTrendsRequest(BaseModel):
    """Request schema for weekly trends analysis"""
    weeks: int = Field(4, ge=1, le=12, description="Number of weeks to analyze (1-12)")

class WeeklyTrendsResponse(BaseModel):
    """Response schema for weekly trends analysis"""
    success: bool
    message: str
    trends: Dict[str, Any]

# Recipe schemas for potential future use
class RecipeResponse(BaseModel):
    """Response schema for recipe operations"""
    success: bool
    message: str
    recipe: Optional[Dict[str, Any]] = None

class RecipeListResponse(BaseModel):
    """Response schema for recipe list operations"""
    success: bool
    message: str
    recipes: List[Dict[str, Any]]
    total_count: int
    limit: int
    offset: int 