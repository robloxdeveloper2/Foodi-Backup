"""
User Recipe Domain Model
Represents a recipe in a user's personal collection (favorited or custom)
"""

import uuid
from datetime import datetime
from typing import Optional, List, Dict, Any
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy import Column, String, DateTime, Integer, Text, Boolean, ForeignKey
from sqlalchemy.types import JSON
from sqlalchemy.orm import relationship

from data_access.database import db

class UserRecipe(db.Model):
    """User Recipe model for storing user's personal recipe collection"""
    
    __tablename__ = 'user_recipes'
    
    # Primary Fields
    id = Column(Integer, primary_key=True, nullable=False)
    user_id = Column(UUID(as_uuid=True), ForeignKey('users.id'), nullable=False)
    recipe_id = Column(Integer, ForeignKey('recipes.id'), nullable=True)  # NULL for custom recipes
    
    # Recipe Content
    title = Column(String(255), nullable=False)
    description = Column(Text, nullable=True)
    
    # Recipe Data - stored as JSON for flexibility (following recipe.py pattern)
    ingredients = Column(JSON, nullable=False)  # [{"name": "flour", "quantity": "1 cup", "unit": "cup", "substitutions": []}]
    instructions = Column(Text, nullable=False)  # Step-by-step instructions as text array
    
    # Classification
    cuisine_type = Column(String(100), nullable=True)  # Italian, Mexican, etc.
    
    # Timing Information
    prep_time_minutes = Column(Integer, nullable=True)
    cook_time_minutes = Column(Integer, nullable=True)
    
    # Recipe Details
    difficulty_level = Column(String(20), nullable=True)  # easy, medium, hard
    servings = Column(Integer, default=4)
    
    # Nutritional Information - stored as JSON
    nutritional_info = Column(JSON, nullable=True)  # {"calories": 300, "protein": 20, "fat": 10, "carbs": 40}
    
    # User Recipe Specific Fields
    image_url = Column(String(500), nullable=True)
    is_custom = Column(Boolean, default=False)  # True for user-created recipes, False for favorited catalog recipes
    is_favorite = Column(Boolean, default=False)  # Whether user has favorited this recipe

    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    user = relationship("User", back_populates="user_recipes")
    original_recipe = relationship("Recipe", foreign_keys=[recipe_id])
    category_assignments = relationship("UserRecipeCategoryAssignment", back_populates="user_recipe", cascade="all, delete-orphan")
    
    def __init__(self, user_id: str, title: str, ingredients: List[Dict[str, Any]], 
                 instructions: str, recipe_id: Optional[int] = None,
                 description: Optional[str] = None, cuisine_type: Optional[str] = None,
                 prep_time_minutes: Optional[int] = None,
                 cook_time_minutes: Optional[int] = None, difficulty_level: Optional[str] = None,
                 servings: int = 4, nutritional_info: Optional[Dict[str, Any]] = None,
                 image_url: Optional[str] = None, is_custom: bool = False):
        """Initialize a new user recipe"""
        self.user_id = user_id
        self.recipe_id = recipe_id
        self.title = title
        self.description = description
        self.ingredients = ingredients
        self.instructions = instructions
        self.cuisine_type = cuisine_type
        self.prep_time_minutes = prep_time_minutes
        self.cook_time_minutes = cook_time_minutes
        self.difficulty_level = difficulty_level
        self.servings = servings
        self.nutritional_info = nutritional_info or {}
        self.image_url = image_url
        self.is_custom = is_custom
    
    @property
    def total_time_minutes(self) -> Optional[int]:
        """Calculate total time (prep + cook)"""
        if self.prep_time_minutes is not None and self.cook_time_minutes is not None:
            return self.prep_time_minutes + self.cook_time_minutes
        return None
    
    @property
    def calories_per_serving(self) -> Optional[float]:
        """Get calories per serving"""
        if self.nutritional_info and 'calories' in self.nutritional_info:
            return self.nutritional_info['calories'] / self.servings
        return None
    
    @property
    def is_favorited(self) -> bool:
        """Check if this is a favorited recipe from catalog"""
        return self.recipe_id is not None
    
    @classmethod
    def from_recipe(cls, user_id: str, recipe: 'Recipe') -> 'UserRecipe':
        """Create a UserRecipe from a catalog Recipe (for favoriting)"""
        return cls(
            user_id=user_id,
            recipe_id=recipe.id,
            title=recipe.name,
            description=recipe.description,
            ingredients=recipe.ingredients,
            instructions=recipe.instructions,
            cuisine_type=recipe.cuisine_type,
            prep_time_minutes=recipe.prep_time_minutes,
            cook_time_minutes=recipe.cook_time_minutes,
            difficulty_level=recipe.difficulty_level,
            servings=recipe.servings,
            nutritional_info=recipe.nutritional_info,
            image_url=recipe.image_url,
            is_custom=False
        )
    
    def update_fields(self, **kwargs) -> None:
        """Update recipe fields from keyword arguments"""
        allowed_fields = {
            'title', 'description', 'ingredients', 'instructions',
            'cuisine_type', 'prep_time_minutes', 'cook_time_minutes', 'difficulty_level', 
            'servings', 'nutritional_info', 'image_url'
        }
        
        for field, value in kwargs.items():
            if field in allowed_fields and hasattr(self, field):
                setattr(self, field, value)
        
        self.updated_at = datetime.utcnow()
    
    def get_instructions_list(self) -> List[str]:
        """Get step-by-step instructions as a list"""
        # Convert text instructions to steps
        if self.instructions:
            lines = [line.strip() for line in self.instructions.split('\n') if line.strip()]
            return lines
        
        return []
    
    def scale_recipe(self, scale_factor: float) -> Dict[str, Any]:
        """Scale recipe ingredients and portions"""
        if scale_factor <= 0:
            raise ValueError("Scale factor must be positive")
        
        scaled_ingredients = []
        for ingredient in self.ingredients:
            scaled_ingredient = ingredient.copy()
            
            # Try to scale quantities that are numeric
            quantity = ingredient.get('quantity', '')
            try:
                # Extract numeric portion from quantity string
                import re
                numeric_match = re.search(r'(\d+(?:\.\d+)?)', str(quantity))
                if numeric_match:
                    original_num = float(numeric_match.group(1))
                    scaled_num = original_num * scale_factor
                    
                    # Format the scaled number nicely
                    if scaled_num == int(scaled_num):
                        scaled_num_str = str(int(scaled_num))
                    else:
                        scaled_num_str = f"{scaled_num:.2f}".rstrip('0').rstrip('.')
                    
                    scaled_ingredient['quantity'] = quantity.replace(
                        numeric_match.group(1), 
                        scaled_num_str
                    )
            except (ValueError, AttributeError):
                # If we can't scale it, keep original
                pass
            
            scaled_ingredients.append(scaled_ingredient)
        
        # Scale nutritional info
        scaled_nutrition = {}
        if self.nutritional_info:
            for key, value in self.nutritional_info.items():
                if isinstance(value, (int, float)):
                    scaled_nutrition[key] = value * scale_factor
                else:
                    scaled_nutrition[key] = value
        
        return {
            'servings': int(self.servings * scale_factor),
            'ingredients': scaled_ingredients,
            'nutritional_info': scaled_nutrition
        }
    
    def get_categories(self) -> List['UserRecipeCategory']:
        """Get all categories assigned to this recipe"""
        from .user_recipe_category import UserRecipeCategory
        return [assignment.category for assignment in self.category_assignments]
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary for JSON serialization"""
        return {
            'id': self.id,
            'user_id': self.user_id,
            'recipe_id': self.recipe_id,
            'title': self.title,
            'description': self.description,
            'ingredients': self.ingredients,
            'instructions': self.instructions,
            'cuisine_type': self.cuisine_type,
            'prep_time_minutes': self.prep_time_minutes,
            'cook_time_minutes': self.cook_time_minutes,
            'difficulty_level': self.difficulty_level,
            'servings': self.servings,
            'nutritional_info': self.nutritional_info,
            'image_url': self.image_url,
            'is_custom': self.is_custom,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None
        }
    
    def __repr__(self) -> str:
        return f"<UserRecipe(id={self.id}, user_id={self.user_id}, name='{self.title}', is_custom={self.is_custom})>" 