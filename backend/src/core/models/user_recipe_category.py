"""
User Recipe Category Domain Model
Represents custom categories for organizing user's personal recipe collection
"""

import uuid
import re
from datetime import datetime
from typing import Optional, List, Dict, Any
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy import Column, String, DateTime, Text, ForeignKey, UniqueConstraint
from sqlalchemy.orm import relationship

from data_access.database import db

class UserRecipeCategory(db.Model):
    """User Recipe Category model for custom recipe organization"""
    
    __tablename__ = 'user_recipe_categories'
    
    # Primary Fields
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey('users.id'), nullable=False)
    
    # Category Information
    name = Column(String(100), nullable=False)
    description = Column(Text, nullable=True)
    color = Column(String(7), nullable=True)  # Hex color code (e.g., "#FF5733")
    
    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Relationships
    user = relationship("User", back_populates="recipe_categories")
    recipe_assignments = relationship("UserRecipeCategoryAssignment", back_populates="category", cascade="all, delete-orphan")
    
    # Unique constraint: user can't have duplicate category names
    __table_args__ = (
        UniqueConstraint('user_id', 'name', name='unique_user_category_name'),
    )
    
    def __init__(self, user_id: str, name: str, description: Optional[str] = None, 
                 color: Optional[str] = None):
        """Initialize a new user recipe category"""
        self.user_id = user_id
        self.name = name.strip()
        self.description = description.strip() if description else None
        self.color = self._validate_color(color) if color else None
    
    @staticmethod
    def _validate_color(color: str) -> str:
        """Validate and normalize hex color code"""
        if not color:
            return None
        
        color = color.strip()
        
        # Add # if missing
        if not color.startswith('#'):
            color = '#' + color
        
        # Validate hex color format
        if not re.match(r'^#[0-9A-Fa-f]{6}$', color):
            raise ValueError(f"Invalid hex color format: {color}. Expected format: #RRGGBB")
        
        return color.upper()
    
    def update_color(self, color: Optional[str]) -> None:
        """Update category color with validation"""
        self.color = self._validate_color(color) if color else None
    
    def update_fields(self, name: Optional[str] = None, description: Optional[str] = None, 
                     color: Optional[str] = None) -> None:
        """Update category fields"""
        if name is not None:
            self.name = name.strip()
        
        if description is not None:
            self.description = description.strip() if description else None
        
        if color is not None:
            self.color = self._validate_color(color) if color else None
    
    def get_recipe_count(self) -> int:
        """Get the number of recipes assigned to this category"""
        return len(self.recipe_assignments)
    
    def get_recipes(self) -> List['UserRecipe']:
        """Get all recipes assigned to this category"""
        from .user_recipe import UserRecipe
        return [assignment.user_recipe for assignment in self.recipe_assignments]
    
    def assign_recipe(self, user_recipe: 'UserRecipe') -> None:
        """Assign a recipe to this category"""
        from .user_recipe_category_assignment import UserRecipeCategoryAssignment
        
        # Check if already assigned
        existing = next(
            (assignment for assignment in self.recipe_assignments 
             if assignment.user_recipe_id == user_recipe.id), 
            None
        )
        
        if not existing:
            assignment = UserRecipeCategoryAssignment(
                user_recipe_id=str(user_recipe.id),
                category_id=str(self.id)
            )
            self.recipe_assignments.append(assignment)
    
    def unassign_recipe(self, user_recipe: 'UserRecipe') -> bool:
        """Remove a recipe from this category"""
        assignment = next(
            (assignment for assignment in self.recipe_assignments 
             if assignment.user_recipe_id == user_recipe.id), 
            None
        )
        
        if assignment:
            self.recipe_assignments.remove(assignment)
            return True
        
        return False
    
    @classmethod
    def get_default_categories(cls) -> List[Dict[str, str]]:
        """Get list of suggested default categories"""
        return [
            {"name": "Favorites", "description": "My favorite recipes", "color": "#FF6B6B"},
            {"name": "Quick & Easy", "description": "Fast meals under 30 minutes", "color": "#4ECDC4"},
            {"name": "Healthy", "description": "Nutritious and wholesome meals", "color": "#45B7D1"},
            {"name": "Comfort Food", "description": "Hearty and satisfying dishes", "color": "#FFA07A"},
            {"name": "Desserts", "description": "Sweet treats and desserts", "color": "#DDA0DD"},
            {"name": "Family Recipes", "description": "Traditional family recipes", "color": "#98D8C8"},
            {"name": "Special Occasions", "description": "Holiday and celebration meals", "color": "#F7DC6F"},
            {"name": "Meal Prep", "description": "Make-ahead and batch cooking", "color": "#85C1E9"},
        ]
    
    @classmethod
    def create_default_categories(cls, user_id: str) -> List['UserRecipeCategory']:
        """Create default categories for a new user"""
        categories = []
        for cat_data in cls.get_default_categories():
            category = cls(
                user_id=user_id,
                name=cat_data["name"],
                description=cat_data["description"],
                color=cat_data["color"]
            )
            categories.append(category)
        
        return categories
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary for API responses"""
        return {
            'id': str(self.id),
            'user_id': str(self.user_id),
            'name': self.name,
            'description': self.description,
            'color': self.color,
            'recipe_count': self.get_recipe_count(),
            'created_at': self.created_at.isoformat() if self.created_at else None,
        }
    
    def to_dict_with_recipes(self) -> Dict[str, Any]:
        """Convert to dictionary including assigned recipes"""
        base_dict = self.to_dict()
        base_dict['recipes'] = [recipe.to_dict() for recipe in self.get_recipes()]
        return base_dict
    
    def __repr__(self) -> str:
        return f"<UserRecipeCategory(id={self.id}, user_id={self.user_id}, name='{self.name}', color='{self.color}')>"


class UserRecipeCategoryAssignment(db.Model):
    """Association table for user recipes and categories (many-to-many)"""
    
    __tablename__ = 'user_recipe_category_assignments'
    
    # Composite Primary Key
    user_recipe_id = Column(UUID(as_uuid=True), ForeignKey('user_recipes.id', ondelete='CASCADE'), primary_key=True)
    category_id = Column(UUID(as_uuid=True), ForeignKey('user_recipe_categories.id', ondelete='CASCADE'), primary_key=True)
    
    # Relationships
    user_recipe = relationship("UserRecipe", back_populates="category_assignments")
    category = relationship("UserRecipeCategory", back_populates="recipe_assignments")
    
    def __init__(self, user_recipe_id: str, category_id: str):
        """Initialize category assignment"""
        self.user_recipe_id = user_recipe_id
        self.category_id = category_id
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary for API responses"""
        return {
            'user_recipe_id': str(self.user_recipe_id),
            'category_id': str(self.category_id),
            'user_recipe': self.user_recipe.to_dict() if self.user_recipe else None,
            'category': self.category.to_dict() if self.category else None,
        }
    
    def __repr__(self) -> str:
        return f"<UserRecipeCategoryAssignment(user_recipe_id={self.user_recipe_id}, category_id={self.category_id})>" 