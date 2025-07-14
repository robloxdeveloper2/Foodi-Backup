"""
User API Schemas
Pydantic models for request/response validation
"""

import re
from typing import Optional, List, Dict, Any
from pydantic import BaseModel, EmailStr, field_validator, Field
from datetime import datetime
from enum import Enum

# Enums for better validation
class CookingExperienceLevel(str, Enum):
    BEGINNER = "beginner"
    INTERMEDIATE = "intermediate" 
    ADVANCED = "advanced"

class WeightGoal(str, Enum):
    LOSE = "lose"
    MAINTAIN = "maintain"
    GAIN = "gain"

class DietaryProgram(str, Enum):
    NONE = "none"
    KETO = "keto"
    PALEO = "paleo"
    MEDITERRANEAN = "mediterranean"
    INTERMITTENT_FASTING = "intermittent_fasting"
    LOW_CARB = "low_carb"
    WHOLE30 = "whole30"

class BudgetPeriod(str, Enum):
    WEEKLY = "weekly"
    MONTHLY = "monthly"

class Currency(str, Enum):
    USD = "USD"
    EUR = "EUR"
    GBP = "GBP"
    CAD = "CAD"

class UserRegistrationRequest(BaseModel):
    """Schema for user registration request"""
    
    username: str = Field(..., min_length=3, max_length=30, description="Username (3-30 characters)")
    email: EmailStr = Field(..., description="Valid email address")
    password: str = Field(..., min_length=8, max_length=128, description="Password (min 8 characters)")
    first_name: Optional[str] = Field(None, max_length=100, description="First name")
    last_name: Optional[str] = Field(None, max_length=100, description="Last name")
    
    @field_validator('username')
    @classmethod
    def validate_username(cls, v):
        """Validate username format"""
        if not re.match(r'^[a-zA-Z0-9_-]+$', v):
            raise ValueError('Username can only contain letters, numbers, underscores, and hyphens')
        return v.lower()
    
    @field_validator('password')
    @classmethod
    def validate_password(cls, v):
        """Validate password security requirements"""
        if len(v) < 8:
            raise ValueError('Password must be at least 8 characters long')
        
        if not re.search(r'[A-Z]', v):
            raise ValueError('Password must contain at least one uppercase letter')
        
        if not re.search(r'[0-9]', v):
            raise ValueError('Password must contain at least one number')
        
        # Optional: Check for special characters (uncomment if required)
        # if not re.search(r'[!@#$%^&*(),.?":{}|<>]', v):
        #     raise ValueError('Password must contain at least one special character')
        
        return v

class UserLoginRequest(BaseModel):
    """Schema for user login request"""
    
    email: EmailStr = Field(..., description="User email address")
    password: str = Field(..., description="User password")

class SocialLoginRequest(BaseModel):
    """Schema for social login request"""
    
    provider: str = Field(..., description="Social login provider (google, apple)")
    access_token: str = Field(..., description="Social provider access token")
    email: Optional[EmailStr] = Field(None, description="User email from social provider")
    first_name: Optional[str] = Field(None, max_length=100, description="First name from social provider")
    last_name: Optional[str] = Field(None, max_length=100, description="Last name from social provider")
    
    @field_validator('provider')
    @classmethod
    def validate_provider(cls, v):
        """Validate social login provider"""
        allowed_providers = ['google', 'apple']
        if v.lower() not in allowed_providers:
            raise ValueError(f'Provider must be one of: {", ".join(allowed_providers)}')
        return v.lower()

class UserProfileUpdateRequest(BaseModel):
    """Schema for user profile update request"""
    
    first_name: Optional[str] = Field(None, max_length=100, description="First name")
    last_name: Optional[str] = Field(None, max_length=100, description="Last name")
    dietary_restrictions: Optional[List[str]] = Field(None, description="List of dietary restrictions")
    cooking_experience_level: Optional[str] = Field(None, description="Cooking experience level")
    nutritional_goals: Optional[Dict[str, Any]] = Field(None, description="Nutritional goals")
    budget_info: Optional[Dict[str, Any]] = Field(None, description="Budget information")
    
    @field_validator('cooking_experience_level')
    @classmethod
    def validate_cooking_experience(cls, v):
        """Validate cooking experience level"""
        if v is not None:
            allowed_levels = ['beginner', 'intermediate', 'advanced']
            if v.lower() not in allowed_levels:
                raise ValueError(f'Cooking experience level must be one of: {", ".join(allowed_levels)}')
            return v.lower()
        return v
    
    @field_validator('dietary_restrictions')
    @classmethod
    def validate_dietary_restrictions(cls, v):
        """Validate dietary restrictions list"""
        if v is not None:
            # Common dietary restrictions for validation
            allowed_restrictions = [
                'vegetarian', 'vegan', 'gluten-free', 'dairy-free', 'nut-free',
                'egg-free', 'soy-free', 'shellfish-free', 'kosher', 'halal',
                'keto', 'paleo', 'low-carb', 'low-fat', 'low-sodium'
            ]
            
            for restriction in v:
                if restriction.lower() not in allowed_restrictions:
                    raise ValueError(f'Invalid dietary restriction: {restriction}')
            
            return [r.lower() for r in v]
        return v

class UserResponse(BaseModel):
    """Schema for user response"""
    
    id: str = Field(..., description="User ID")
    username: str = Field(..., description="Username")
    email: str = Field(..., description="Email address")
    first_name: Optional[str] = Field(None, description="First name")
    last_name: Optional[str] = Field(None, description="Last name")
    dietary_restrictions: List[str] = Field(default=[], description="Dietary restrictions")
    cooking_experience_level: Optional[str] = Field(None, description="Cooking experience level")
    nutritional_goals: Dict[str, Any] = Field(default={}, description="Nutritional goals")
    budget_info: Dict[str, Any] = Field(default={}, description="Budget information")
    email_verified: bool = Field(..., description="Email verification status")
    is_active: bool = Field(..., description="Account active status")
    created_at: str = Field(..., description="Account creation timestamp")
    updated_at: str = Field(..., description="Last update timestamp")
    last_login: Optional[str] = Field(None, description="Last login timestamp")

class AuthResponse(BaseModel):
    """Schema for authentication response"""
    
    success: bool = Field(..., description="Authentication success status")
    message: str = Field(..., description="Response message")
    user: Optional[UserResponse] = Field(None, description="User information")
    access_token: Optional[str] = Field(None, description="JWT access token")
    token_type: str = Field(default="Bearer", description="Token type")
    expires_in: Optional[int] = Field(None, description="Token expiration in seconds")

class EmailVerificationRequest(BaseModel):
    """Schema for email verification request"""
    
    token: str = Field(..., description="Email verification token")

class PasswordResetRequest(BaseModel):
    """Schema for password reset request"""
    
    email: EmailStr = Field(..., description="User email address")

class PasswordChangeRequest(BaseModel):
    """Schema for password change request"""
    
    current_password: str = Field(..., description="Current password")
    new_password: str = Field(..., min_length=8, max_length=128, description="New password")
    
    @field_validator('new_password')
    @classmethod
    def validate_new_password(cls, v):
        """Validate new password security requirements"""
        if len(v) < 8:
            raise ValueError('Password must be at least 8 characters long')
        
        if not re.search(r'[A-Z]', v):
            raise ValueError('Password must contain at least one uppercase letter')
        
        if not re.search(r'[0-9]', v):
            raise ValueError('Password must contain at least one number')
        
        return v

class ProfileSetupRequest(BaseModel):
    """Schema for comprehensive profile setup during onboarding"""
    
    # Dietary Restrictions (AC 1)
    dietary_restrictions: Optional[List[str]] = Field(
        default=[],
        description="List of dietary restrictions and preferences"
    )
    custom_dietary_restrictions: Optional[List[str]] = Field(
        default=[],
        description="Custom dietary restrictions not in predefined list"
    )
    allergies: Optional[List[str]] = Field(
        default=[],
        description="Food allergies"
    )
    
    # Budget Information (AC 2)
    budget_period: Optional[BudgetPeriod] = Field(None, description="Budget period (weekly/monthly)")
    budget_amount: Optional[float] = Field(None, gt=0, description="Budget amount")
    currency: Optional[Currency] = Field(Currency.USD, description="Preferred currency")
    price_per_meal_min: Optional[float] = Field(None, ge=0, description="Minimum price per meal")
    price_per_meal_max: Optional[float] = Field(None, gt=0, description="Maximum price per meal")
    
    # Cooking Experience (AC 3)
    cooking_experience_level: Optional[CookingExperienceLevel] = Field(
        None, 
        description="Cooking experience level"
    )
    cooking_frequency: Optional[str] = Field(None, description="How often user cooks")
    kitchen_equipment: Optional[List[str]] = Field(
        default=[],
        description="Available kitchen equipment"
    )
    
    # Nutritional Goals (AC 4)
    weight_goal: Optional[WeightGoal] = Field(None, description="Weight management goal")
    daily_calorie_target: Optional[int] = Field(None, gt=0, le=5000, description="Daily caloric target")
    protein_target_pct: Optional[float] = Field(None, ge=10, le=50, description="Protein percentage target")
    carb_target_pct: Optional[float] = Field(None, ge=10, le=70, description="Carbohydrate percentage target")
    fat_target_pct: Optional[float] = Field(None, ge=15, le=50, description="Fat percentage target")
    dietary_program: Optional[DietaryProgram] = Field(None, description="Specific dietary program")
    
    @field_validator('price_per_meal_max')
    @classmethod
    def validate_price_range(cls, v):
        """Validate price range is logical"""
        if v is not None and v <= 0:
            raise ValueError('Maximum price per meal must be greater than 0')
        return v
    
    @field_validator('protein_target_pct', 'carb_target_pct', 'fat_target_pct')
    @classmethod
    def validate_macro_percentages(cls, v):
        """Validate that macro percentages are in valid range"""
        if v is not None:
            if v < 0 or v > 100:
                raise ValueError('Macro percentage must be between 0 and 100')
        return v
    
    @field_validator('dietary_restrictions')
    @classmethod
    def validate_dietary_restrictions(cls, v):
        """Validate dietary restrictions list"""
        if v is not None:
            # Predefined dietary restrictions
            allowed_restrictions = [
                'vegetarian', 'vegan', 'pescatarian', 'gluten-free', 'dairy-free', 
                'nut-free', 'egg-free', 'soy-free', 'shellfish-free', 'kosher', 'halal',
                'keto', 'paleo', 'low-carb', 'low-fat', 'low-sodium', 'sugar-free'
            ]
            
            for restriction in v:
                if restriction.lower() not in allowed_restrictions:
                    raise ValueError(f'Invalid dietary restriction: {restriction}. Use custom_dietary_restrictions for custom values.')
            
            return [r.lower() for r in v]
        return v
    
    @field_validator('allergies')
    @classmethod
    def validate_allergies(cls, v):
        """Validate allergies list"""
        if v is not None:
            # Common food allergies
            allowed_allergies = [
                'milk', 'eggs', 'fish', 'shellfish', 'tree-nuts', 'peanuts', 
                'wheat', 'soybeans', 'sesame', 'mustard', 'celery', 'lupin'
            ]
            
            for allergy in v:
                if allergy.lower() not in allowed_allergies:
                    raise ValueError(f'Invalid allergy: {allergy}')
            
            return [a.lower() for a in v]
        return v
    
    @field_validator('kitchen_equipment')
    @classmethod
    def validate_kitchen_equipment(cls, v):
        """Validate kitchen equipment list"""
        if v is not None:
            # Common kitchen equipment
            allowed_equipment = [
                'oven', 'stovetop', 'microwave', 'air-fryer', 'slow-cooker', 'pressure-cooker',
                'food-processor', 'blender', 'stand-mixer', 'grill', 'toaster', 'rice-cooker',
                'steamer', 'deep-fryer', 'sous-vide', 'dehydrator', 'bread-maker'
            ]
            
            for equipment in v:
                if equipment.lower() not in allowed_equipment:
                    raise ValueError(f'Invalid kitchen equipment: {equipment}')
            
            return [e.lower() for e in v]
        return v

class ProfileDataResponse(BaseModel):
    """Schema for returning predefined profile data options"""
    
    dietary_restrictions: List[str] = Field(..., description="Available dietary restrictions")
    allergies: List[str] = Field(..., description="Common food allergies")
    cooking_experience_levels: List[Dict[str, str]] = Field(..., description="Experience levels with descriptions")
    kitchen_equipment: List[str] = Field(..., description="Available kitchen equipment")
    dietary_programs: List[Dict[str, str]] = Field(..., description="Available dietary programs")
    currencies: List[str] = Field(..., description="Supported currencies")

class ProfileChangeHistoryResponse(BaseModel):
    """Schema for profile change history"""
    
    id: str = Field(..., description="Change record ID")
    user_id: str = Field(..., description="User ID")
    field_changed: str = Field(..., description="Field that was changed")
    old_value: Optional[str] = Field(None, description="Previous value")
    new_value: Optional[str] = Field(None, description="New value")
    change_type: str = Field(..., description="Type of change (update, create, delete)")
    timestamp: str = Field(..., description="When the change occurred")
    source: str = Field(default="manual", description="Source of change (manual, api, bulk)")

class EnhancedProfileUpdateRequest(BaseModel):
    """Enhanced schema for profile updates with more granular control"""
    
    # Basic Information
    first_name: Optional[str] = Field(None, max_length=100, description="First name")
    last_name: Optional[str] = Field(None, max_length=100, description="Last name")
    
    # Dietary Information (granular updates)
    dietary_restrictions: Optional[List[str]] = Field(None, description="Update dietary restrictions list")
    add_dietary_restrictions: Optional[List[str]] = Field(None, description="Add to existing dietary restrictions")
    remove_dietary_restrictions: Optional[List[str]] = Field(None, description="Remove from dietary restrictions")
    custom_dietary_restrictions: Optional[List[str]] = Field(None, description="Custom dietary restrictions")
    allergies: Optional[List[str]] = Field(None, description="Food allergies")
    
    # Cooking Information
    cooking_experience_level: Optional[CookingExperienceLevel] = Field(None, description="Cooking experience level")
    cooking_frequency: Optional[str] = Field(None, description="How often user cooks")
    kitchen_equipment: Optional[List[str]] = Field(None, description="Available kitchen equipment")
    add_kitchen_equipment: Optional[List[str]] = Field(None, description="Add to existing kitchen equipment")
    remove_kitchen_equipment: Optional[List[str]] = Field(None, description="Remove from kitchen equipment")
    
    # Budget Information
    budget_period: Optional[BudgetPeriod] = Field(None, description="Budget period")
    budget_amount: Optional[float] = Field(None, gt=0, description="Budget amount")
    currency: Optional[Currency] = Field(None, description="Preferred currency")
    price_per_meal_min: Optional[float] = Field(None, ge=0, description="Minimum price per meal")
    price_per_meal_max: Optional[float] = Field(None, gt=0, description="Maximum price per meal")
    
    # Nutritional Goals
    weight_goal: Optional[WeightGoal] = Field(None, description="Weight management goal")
    daily_calorie_target: Optional[int] = Field(None, gt=0, le=5000, description="Daily caloric target")
    protein_target_pct: Optional[float] = Field(None, ge=10, le=50, description="Protein percentage target")
    carb_target_pct: Optional[float] = Field(None, ge=10, le=70, description="Carbohydrate percentage target")
    fat_target_pct: Optional[float] = Field(None, ge=15, le=50, description="Fat percentage target")
    dietary_program: Optional[DietaryProgram] = Field(None, description="Specific dietary program")
    
    # Metadata
    update_source: Optional[str] = Field(default="manual", description="Source of the update")
    
    @field_validator('price_per_meal_max')
    @classmethod
    def validate_price_range(cls, v):
        """Validate price range is logical"""
        if v is not None and v <= 0:
            raise ValueError('Maximum price per meal must be greater than 0')
        return v
    
    @field_validator('protein_target_pct', 'carb_target_pct', 'fat_target_pct')
    @classmethod
    def validate_macro_percentages(cls, v):
        """Validate that macro percentages are in valid range"""
        if v is not None:
            if v < 0 or v > 100:
                raise ValueError('Macro percentage must be between 0 and 100')
        return v

class ProfileSectionUpdateRequest(BaseModel):
    """Schema for updating specific profile sections"""
    
    section: str = Field(..., description="Profile section to update (dietary, budget, cooking, nutritional)")
    data: Dict[str, Any] = Field(..., description="Section-specific data to update")
    update_source: Optional[str] = Field(default="manual", description="Source of the update")
    
    @field_validator('section')
    @classmethod
    def validate_section(cls, v):
        """Validate profile section"""
        allowed_sections = ['dietary', 'budget', 'cooking', 'nutritional', 'personal']
        if v.lower() not in allowed_sections:
            raise ValueError(f'Section must be one of: {", ".join(allowed_sections)}')
        return v.lower()

class DetailedProfileResponse(BaseModel):
    """Enhanced user profile response with more detailed information"""
    
    # Basic User Info
    id: str = Field(..., description="User ID")
    username: str = Field(..., description="Username")
    email: str = Field(..., description="Email address")
    first_name: Optional[str] = Field(None, description="First name")
    last_name: Optional[str] = Field(None, description="Last name")
    
    # Profile Status
    profile_completion_percentage: int = Field(..., description="Profile completion percentage")
    onboarding_completed: bool = Field(..., description="Whether onboarding is complete")
    last_profile_update: Optional[str] = Field(None, description="Last profile update timestamp")
    
    # Dietary Information
    dietary_restrictions: List[str] = Field(default=[], description="Dietary restrictions")
    custom_dietary_restrictions: List[str] = Field(default=[], description="Custom dietary restrictions")
    allergies: List[str] = Field(default=[], description="Food allergies")
    
    # Cooking Information
    cooking_experience_level: Optional[str] = Field(None, description="Cooking experience level")
    cooking_frequency: Optional[str] = Field(None, description="How often user cooks")
    kitchen_equipment: List[str] = Field(default=[], description="Available kitchen equipment")
    
    # Budget Information
    budget_info: Dict[str, Any] = Field(default={}, description="Budget information")
    
    # Nutritional Goals
    nutritional_goals: Dict[str, Any] = Field(default={}, description="Nutritional goals")
    
    # Account Information
    email_verified: bool = Field(..., description="Email verification status")
    is_active: bool = Field(..., description="Account active status")
    created_at: str = Field(..., description="Account creation timestamp")
    updated_at: str = Field(..., description="Last update timestamp")
    last_login: Optional[str] = Field(None, description="Last login timestamp") 