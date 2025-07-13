"""
API Schemas for Preference Learning (Story 2.2)
Pydantic models for request/response validation
"""

from typing import Optional, List, Dict, Any
from pydantic import BaseModel, Field, validator


class MealSuggestionsRequest(BaseModel):
    """Request schema for getting meal suggestions for swiping"""
    session_length: Optional[int] = Field(default=20, ge=1, le=50, description="Number of meal suggestions to return")


class MealSuggestionsResponse(BaseModel):
    """Response schema for meal suggestions"""
    suggestions: List[Dict[str, Any]] = Field(description="List of meal suggestions with recipe data")
    session_length: int = Field(description="Number of suggestions returned")
    user_id: str = Field(description="User ID for the session")


class SwipeFeedbackRequest(BaseModel):
    """Request schema for recording swipe feedback"""
    recipe_id: str = Field(description="UUID of the recipe being rated")
    action: str = Field(description="Swipe action: 'like' or 'dislike'")
    
    @validator('action')
    def validate_action(cls, v):
        if v not in ['like', 'dislike']:
            raise ValueError("Action must be 'like' or 'dislike'")
        return v


class SwipeFeedbackResponse(BaseModel):
    """Response schema for swipe feedback"""
    user_id: str = Field(description="User ID")
    recipe_id: str = Field(description="Recipe ID")
    action: str = Field(description="Recorded action")
    timestamp: str = Field(description="ISO timestamp of the action")
    context: str = Field(description="Context of the feedback")
    feedback_recorded: bool = Field(description="Whether feedback was successfully recorded")


class RecipeRatingRequest(BaseModel):
    """Request schema for setting recipe rating"""
    recipe_id: str = Field(description="UUID of the recipe being rated")
    rating: float = Field(ge=1.0, le=5.0, description="Rating from 1.0 to 5.0 stars")


class RecipeRatingResponse(BaseModel):
    """Response schema for recipe rating"""
    user_id: str = Field(description="User ID")
    recipe_id: str = Field(description="Recipe ID")
    rating: float = Field(description="Recorded rating")
    timestamp: str = Field(description="ISO timestamp of the rating")
    rating_recorded: bool = Field(description="Whether rating was successfully recorded")


class IngredientPreferenceRequest(BaseModel):
    """Request schema for updating ingredient preferences"""
    ingredient: str = Field(min_length=1, max_length=100, description="Name of the ingredient")
    preference: str = Field(description="Preference: 'liked' or 'disliked'")
    
    @validator('preference')
    def validate_preference(cls, v):
        if v not in ['liked', 'disliked']:
            raise ValueError("Preference must be 'liked' or 'disliked'")
        return v


class IngredientPreferenceResponse(BaseModel):
    """Response schema for ingredient preference update"""
    user_id: str = Field(description="User ID")
    ingredient: str = Field(description="Ingredient name")
    preference: str = Field(description="Recorded preference")
    timestamp: str = Field(description="ISO timestamp of the update")
    preference_updated: bool = Field(description="Whether preference was successfully updated")


class CuisinePreferenceRequest(BaseModel):
    """Request schema for setting cuisine preferences"""
    cuisine: str = Field(min_length=1, max_length=50, description="Name of the cuisine")
    rating: int = Field(ge=1, le=5, description="Rating from 1 to 5")


class CuisinePreferenceResponse(BaseModel):
    """Response schema for cuisine preference"""
    user_id: str = Field(description="User ID")
    cuisine: str = Field(description="Cuisine name")
    rating: int = Field(description="Recorded rating")
    timestamp: str = Field(description="ISO timestamp of the update")
    preference_updated: bool = Field(description="Whether preference was successfully updated")


class PreferenceStatsResponse(BaseModel):
    """Response schema for user preference statistics"""
    user_id: str = Field(description="User ID")
    total_swipes: int = Field(description="Total number of swipes")
    likes_count: int = Field(description="Number of likes")
    dislikes_count: int = Field(description="Number of dislikes")
    total_ratings: int = Field(description="Number of detailed ratings")
    average_rating: Optional[float] = Field(description="Average rating given")
    preferred_cuisines: List[Dict[str, Any]] = Field(description="Top preferred cuisines")
    liked_ingredients: List[str] = Field(description="Liked ingredients")
    disliked_ingredients: List[str] = Field(description="Disliked ingredients")
    prep_time_preference: str = Field(description="Preparation time preference")


class ErrorResponse(BaseModel):
    """Standard error response schema"""
    error: str = Field(description="Error type")
    message: str = Field(description="Human-readable error message")
    details: Optional[Dict[str, Any]] = Field(description="Additional error details")
    timestamp: str = Field(description="ISO timestamp of the error") 