"""
Recipe Domain Model
Represents a food recipe with nutritional information
"""

import uuid
from datetime import datetime
from typing import Optional, List, Dict, Any
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy import Column, String, DateTime, Integer, Text
from sqlalchemy.types import JSON

from data_access.database import db

class Recipe(db.Model):
    """Recipe model for storing recipe data"""
    
    __tablename__ = 'recipes'
    
    # Primary Fields
    id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String(255), nullable=False)
    description = Column(Text, nullable=True)
    
    # Recipe Content - stored as JSON for flexibility
    ingredients = Column(JSON, nullable=False)  # [{"name": "flour", "quantity": "1 cup", "unit": "cup", "substitutions": ["whole wheat flour", "almond flour"]}]
    instructions = Column(Text, nullable=False)  # Legacy: Step-by-step instructions as text
    detailed_instructions = Column(JSON, nullable=True)  # [{"step": 1, "instruction": "...", "duration_minutes": 5, "tips": "..."}]
    
    # Enhanced Recipe Information
    cooking_tips = Column(JSON, nullable=True)  # [{"tip": "For best results...", "category": "technique"}]
    equipment_needed = Column(JSON, nullable=True)  # ["large pot", "whisk", "measuring cups"]
    
    # Classification
    cuisine_type = Column(String(50), nullable=True)  # Italian, Mexican, etc.
    meal_type = Column(String(50), nullable=True)  # breakfast, lunch, dinner, snack
    
    # Timing Information
    prep_time_minutes = Column(Integer, nullable=True)
    cook_time_minutes = Column(Integer, nullable=True)
    
    # Nutritional Information - stored as JSON
    nutritional_info = Column(JSON, nullable=True)  # {"calories": 300, "protein": 20, "fat": 10, "carbs": 40, "fiber": 5, "sugar": 8, "sodium": 200}
    
    # Cost and Difficulty
    estimated_cost_usd = Column(Integer, nullable=True)  # Cost in cents
    difficulty_level = Column(String(20), nullable=True)  # easy, medium, hard
    
    # Source Information
    source_url = Column(String(500), nullable=True)
    image_url = Column(String(500), nullable=True)
    
    # Metadata
    servings = Column(Integer, default=1)
    is_active = Column(db.Boolean, default=True)
    
    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    def __init__(self, name: str, ingredients: List[Dict[str, Any]], instructions: str,
                 description: Optional[str] = None, cuisine_type: Optional[str] = None,
                 meal_type: Optional[str] = None, prep_time_minutes: Optional[int] = None,
                 cook_time_minutes: Optional[int] = None, nutritional_info: Optional[Dict[str, Any]] = None,
                 estimated_cost_usd: Optional[int] = None, difficulty_level: Optional[str] = None,
                 source_url: Optional[str] = None, image_url: Optional[str] = None,
                 servings: int = 1, detailed_instructions: Optional[List[Dict[str, Any]]] = None,
                 cooking_tips: Optional[List[Dict[str, Any]]] = None,
                 equipment_needed: Optional[List[str]] = None):
        """Initialize a new recipe"""
        self.name = name
        self.description = description
        self.ingredients = ingredients
        self.instructions = instructions
        self.detailed_instructions = detailed_instructions or []
        self.cooking_tips = cooking_tips or []
        self.equipment_needed = equipment_needed or []
        self.cuisine_type = cuisine_type
        self.meal_type = meal_type
        self.prep_time_minutes = prep_time_minutes
        self.cook_time_minutes = cook_time_minutes
        self.nutritional_info = nutritional_info or {}
        self.estimated_cost_usd = estimated_cost_usd
        self.difficulty_level = difficulty_level
        self.source_url = source_url
        self.image_url = image_url
        self.servings = servings
    
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
    def cost_per_serving_usd(self) -> Optional[float]:
        """Get cost per serving in USD"""
        if self.estimated_cost_usd:
            return (self.estimated_cost_usd / 100.0) / self.servings  # Convert cents to dollars
        return None
    
    def get_instructions_list(self) -> List[Dict[str, Any]]:
        """Get step-by-step instructions as a list"""
        if self.detailed_instructions:
            return self.detailed_instructions
        
        # Fallback: convert legacy text instructions to steps
        if self.instructions:
            lines = [line.strip() for line in self.instructions.split('\n') if line.strip()]
            return [
                {
                    "step": i + 1,
                    "instruction": line,
                    "duration_minutes": None,
                    "tips": None
                }
                for i, line in enumerate(lines)
            ]
        
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
            'nutritional_info': scaled_nutrition,
            'estimated_cost_usd': int(self.estimated_cost_usd * scale_factor) if self.estimated_cost_usd else None
        }
    
    def matches_dietary_restrictions(self, restrictions: List[str]) -> bool:
        """Check if recipe matches dietary restrictions"""
        if not restrictions:
            return True
        
        # This is a simple implementation - in a real system you'd have 
        # more sophisticated ingredient analysis
        recipe_text = f"{self.name} {self.description or ''} {str(self.ingredients)}".lower()
        
        restriction_keywords = {
            'vegan': ['meat', 'chicken', 'beef', 'pork', 'fish', 'dairy', 'milk', 'cheese', 'egg'],
            'vegetarian': ['meat', 'chicken', 'beef', 'pork', 'fish'],
            'gluten-free': ['wheat', 'flour', 'bread', 'pasta', 'gluten'],
            'dairy-free': ['milk', 'cheese', 'butter', 'cream', 'dairy'],
            'nut-free': ['nuts', 'almond', 'peanut', 'walnut', 'cashew'],
        }
        
        for restriction in restrictions:
            restriction_lower = restriction.lower()
            if restriction_lower in restriction_keywords:
                forbidden_words = restriction_keywords[restriction_lower]
                if any(word in recipe_text for word in forbidden_words):
                    return False
        
        return True
    
    def calculate_nutrition_score(self, target_calories: Optional[int] = None,
                                target_protein_pct: Optional[float] = None,
                                target_carb_pct: Optional[float] = None,
                                target_fat_pct: Optional[float] = None) -> float:
        """Calculate nutritional alignment score (0-1)"""
        if not self.nutritional_info:
            return 0.5  # Neutral score for missing data
        
        score = 0.0
        factors = 0
        
        calories = self.nutritional_info.get('calories', 0)
        protein = self.nutritional_info.get('protein', 0)
        carbs = self.nutritional_info.get('carbs', 0)
        fat = self.nutritional_info.get('fat', 0)
        
        # Calorie alignment
        if target_calories and calories > 0:
            calorie_diff = abs(calories - target_calories) / target_calories
            score += max(0, 1 - calorie_diff)
            factors += 1
        
        # Macro alignment (simplified)
        total_macros = protein + carbs + fat
        if total_macros > 0:
            if target_protein_pct:
                protein_pct = protein / total_macros
                protein_diff = abs(protein_pct - target_protein_pct / 100)
                score += max(0, 1 - protein_diff)
                factors += 1
            
            if target_carb_pct:
                carb_pct = carbs / total_macros
                carb_diff = abs(carb_pct - target_carb_pct / 100)
                score += max(0, 1 - carb_diff)
                factors += 1
            
            if target_fat_pct:
                fat_pct = fat / total_macros
                fat_diff = abs(fat_pct - target_fat_pct / 100)
                score += max(0, 1 - fat_diff)
                factors += 1
        
        return score / factors if factors > 0 else 0.5
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert recipe to dictionary for API responses"""
        return {
            'id': str(self.id),
            'name': self.name,
            'description': self.description,
            'ingredients': self.ingredients,
            'instructions': self.instructions,
            'detailed_instructions': self.get_instructions_list(),
            'cooking_tips': self.cooking_tips or [],
            'equipment_needed': self.equipment_needed or [],
            'cuisine_type': self.cuisine_type,
            'meal_type': self.meal_type,
            'prep_time_minutes': self.prep_time_minutes,
            'cook_time_minutes': self.cook_time_minutes,
            'total_time_minutes': self.total_time_minutes,
            'nutritional_info': self.nutritional_info,
            'estimated_cost_usd': self.estimated_cost_usd,
            'cost_per_serving_usd': self.cost_per_serving_usd,
            'difficulty_level': self.difficulty_level,
            'source_url': self.source_url,
            'image_url': self.image_url,
            'servings': self.servings,
            'calories_per_serving': self.calories_per_serving,
            'is_active': self.is_active,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None,
        }
    
    def __repr__(self) -> str:
        return f'<Recipe {self.name} ({self.meal_type})>' 