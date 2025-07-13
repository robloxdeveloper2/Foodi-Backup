"""
Pydantic schemas for meal substitution API endpoints
"""

from typing import Optional, List, Dict, Any
from pydantic import BaseModel, Field

class SubstitutionRequestSchema(BaseModel):
    """Request schema for finding meal substitutes"""
    max_alternatives: Optional[int] = Field(default=5, ge=1, le=10, description="Maximum number of alternatives to return")
    nutritional_tolerance: Optional[float] = Field(default=0.15, ge=0.05, le=0.30, description="±% tolerance for nutritional matching")

class SubstitutionImpactSchema(BaseModel):
    """Schema for substitution impact data"""
    changes: Dict[str, float] = Field(description="Nutritional and cost changes")
    new_totals: Dict[str, float] = Field(description="New daily totals after substitution")
    impact_level: str = Field(description="Impact level: minimal, moderate, significant")
    cost_change_usd: float = Field(description="Cost change in USD")

class SubstitutionCandidateSchema(BaseModel):
    """Schema for a substitution candidate recipe"""
    recipe_id: str = Field(description="Recipe ID")
    recipe_name: str = Field(description="Recipe name")
    cuisine_type: Optional[str] = Field(description="Cuisine type")
    prep_time_minutes: Optional[int] = Field(description="Preparation time in minutes")
    cook_time_minutes: Optional[int] = Field(description="Cooking time in minutes")
    total_time_minutes: Optional[int] = Field(description="Total time in minutes")
    nutritional_info: Optional[Dict[str, Any]] = Field(description="Nutritional information")
    estimated_cost_usd: Optional[float] = Field(description="Estimated cost in USD")
    difficulty_level: Optional[str] = Field(description="Difficulty level")
    
    # Scoring information
    total_score: float = Field(description="Total substitution score (0-1)")
    nutritional_similarity: float = Field(description="Nutritional similarity score (0-1)")
    user_preference: float = Field(description="User preference score (0-1)")
    cost_efficiency: float = Field(description="Cost efficiency score (0-1)")
    prep_time_match: float = Field(description="Prep time match score (0-1)")
    
    # Impact information
    substitution_impact: SubstitutionImpactSchema = Field(description="Impact of this substitution")

class SubstitutesResponseSchema(BaseModel):
    """Response schema for substitute suggestions"""
    meal_plan_id: str = Field(description="Meal plan ID")
    meal_index: int = Field(description="Index of the meal being substituted")
    original_recipe: Dict[str, Any] = Field(description="Original recipe information")
    alternatives: List[SubstitutionCandidateSchema] = Field(description="List of substitute candidates")
    total_found: int = Field(description="Total number of candidates found")

class ApplySubstitutionRequestSchema(BaseModel):
    """Request schema for applying a substitution"""
    new_recipe_id: str = Field(description="ID of the new recipe to substitute")

class ApplySubstitutionResponseSchema(BaseModel):
    """Response schema for applying a substitution"""
    success: bool = Field(description="Whether substitution was successful")
    message: str = Field(description="Success or error message")
    meal_plan: Dict[str, Any] = Field(description="Updated meal plan")
    substitution_applied: Dict[str, Any] = Field(description="Details of the substitution applied")

class UndoSubstitutionResponseSchema(BaseModel):
    """Response schema for undoing a substitution"""
    success: bool = Field(description="Whether undo was successful")
    message: str = Field(description="Success or error message")
    meal_plan: Dict[str, Any] = Field(description="Updated meal plan")
    substitution_undone: Dict[str, Any] = Field(description="Details of the substitution undone")

class SubstitutionHistoryItemSchema(BaseModel):
    """Schema for a substitution history item"""
    meal_index: int = Field(description="Index of the meal that was substituted")
    original_recipe_id: str = Field(description="ID of the original recipe")
    new_recipe_id: str = Field(description="ID of the new recipe")
    timestamp: str = Field(description="When the substitution was made")
    user_id: str = Field(description="User who made the substitution")

class SubstitutionHistoryResponseSchema(BaseModel):
    """Response schema for substitution history"""
    meal_plan_id: str = Field(description="Meal plan ID")
    substitution_history: List[SubstitutionHistoryItemSchema] = Field(description="List of substitutions made")
    can_undo: bool = Field(description="Whether there are substitutions that can be undone") 