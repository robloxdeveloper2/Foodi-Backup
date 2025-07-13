"""
Recipe Repository
Data access layer for Recipe model operations
"""

import logging
from typing import Optional, List, Dict, Any
from sqlalchemy.orm import Session
from sqlalchemy import and_, or_

from core.models.recipe import Recipe
from core.exceptions import ValidationError
from data_access.database import db

logger = logging.getLogger(__name__)

class RecipeRepository:
    """Repository for Recipe data access operations"""
    
    def __init__(self, session: Optional[Session] = None):
        """Initialize repository with optional session"""
        self.session = session or db.session
    
    def create_recipe(self, recipe_data: Dict[str, Any]) -> Recipe:
        """Create a new recipe"""
        try:
            recipe = Recipe(
                name=recipe_data['name'],
                ingredients=recipe_data['ingredients'],
                instructions=recipe_data['instructions'],
                description=recipe_data.get('description'),
                cuisine_type=recipe_data.get('cuisine_type'),
                meal_type=recipe_data.get('meal_type'),
                prep_time_minutes=recipe_data.get('prep_time_minutes'),
                cook_time_minutes=recipe_data.get('cook_time_minutes'),
                nutritional_info=recipe_data.get('nutritional_info'),
                estimated_cost_usd=recipe_data.get('estimated_cost_usd'),
                difficulty_level=recipe_data.get('difficulty_level'),
                source_url=recipe_data.get('source_url'),
                image_url=recipe_data.get('image_url'),
                servings=recipe_data.get('servings', 1)
            )
            
            self.session.add(recipe)
            self.session.commit()
            
            logger.info(f"Recipe created successfully: {recipe.id}")
            return recipe
            
        except Exception as e:
            self.session.rollback()
            logger.error(f"Error creating recipe: {str(e)}")
            raise ValidationError(f"Failed to create recipe: {str(e)}")
    
    def get_by_id(self, recipe_id: str) -> Optional[Recipe]:
        """Get recipe by ID"""
        try:
            recipe = self.session.query(Recipe).filter_by(id=recipe_id, is_active=True).first()
            if recipe:
                logger.debug(f"Recipe found: {recipe_id}")
            else:
                logger.debug(f"Recipe not found: {recipe_id}")
            return recipe
            
        except Exception as e:
            logger.error(f"Error getting recipe {recipe_id}: {str(e)}")
            raise ValidationError(f"Failed to get recipe: {str(e)}")
    
    def get_recipe_by_id(self, recipe_id: str) -> Optional[Recipe]:
        """Get recipe by ID (alias for compatibility)"""
        return self.get_by_id(recipe_id)
    
    def get_recipes_by_meal_type(self, meal_type: str, limit: Optional[int] = None) -> List[Recipe]:
        """Get recipes by meal type"""
        try:
            query = self.session.query(Recipe).filter(
                and_(Recipe.meal_type == meal_type, Recipe.is_active == True)
            )
            
            if limit:
                query = query.limit(limit)
            
            recipes = query.all()
            logger.debug(f"Found {len(recipes)} recipes for meal type: {meal_type}")
            return recipes
            
        except Exception as e:
            logger.error(f"Error getting recipes by meal type {meal_type}: {str(e)}")
            raise ValidationError(f"Failed to get recipes: {str(e)}")
    
    def get_recipes_by_dietary_restrictions(self, dietary_restrictions: List[str]) -> List[Recipe]:
        """Get recipes that match dietary restrictions"""
        try:
            recipes = self.session.query(Recipe).filter(Recipe.is_active == True).all()
            
            # Filter in Python using the model's method
            filtered_recipes = [
                recipe for recipe in recipes 
                if recipe.matches_dietary_restrictions(dietary_restrictions)
            ]
            
            logger.debug(f"Found {len(filtered_recipes)} recipes matching dietary restrictions: {dietary_restrictions}")
            return filtered_recipes
            
        except Exception as e:
            logger.error(f"Error filtering recipes by dietary restrictions: {str(e)}")
            raise ValidationError(f"Failed to filter recipes: {str(e)}")
    
    def get_recipes_by_cuisine(self, cuisine_type: str, limit: Optional[int] = None) -> List[Recipe]:
        """Get recipes by cuisine type"""
        try:
            query = self.session.query(Recipe).filter(
                and_(Recipe.cuisine_type.ilike(f"%{cuisine_type}%"), Recipe.is_active == True)
            )
            
            if limit:
                query = query.limit(limit)
            
            recipes = query.all()
            logger.debug(f"Found {len(recipes)} recipes for cuisine: {cuisine_type}")
            return recipes
            
        except Exception as e:
            logger.error(f"Error getting recipes by cuisine {cuisine_type}: {str(e)}")
            raise ValidationError(f"Failed to get recipes: {str(e)}")
    
    def get_recipes_by_budget_range(self, min_cost_usd: Optional[float] = None, 
                                   max_cost_usd: Optional[float] = None) -> List[Recipe]:
        """Get recipes within budget range"""
        try:
            query = self.session.query(Recipe).filter(Recipe.is_active == True)
            
            if min_cost_usd is not None:
                min_cost_cents = int(min_cost_usd * 100)
                query = query.filter(Recipe.estimated_cost_usd >= min_cost_cents)
            
            if max_cost_usd is not None:
                max_cost_cents = int(max_cost_usd * 100)
                query = query.filter(Recipe.estimated_cost_usd <= max_cost_cents)
            
            recipes = query.all()
            logger.debug(f"Found {len(recipes)} recipes in budget range: ${min_cost_usd}-${max_cost_usd}")
            return recipes
            
        except Exception as e:
            logger.error(f"Error getting recipes by budget range: {str(e)}")
            raise ValidationError(f"Failed to get recipes: {str(e)}")
    
    def get_recipes_by_difficulty(self, difficulty_level: str) -> List[Recipe]:
        """Get recipes by difficulty level"""
        try:
            recipes = self.session.query(Recipe).filter(
                and_(Recipe.difficulty_level == difficulty_level, Recipe.is_active == True)
            ).all()
            
            logger.debug(f"Found {len(recipes)} recipes for difficulty: {difficulty_level}")
            return recipes
            
        except Exception as e:
            logger.error(f"Error getting recipes by difficulty {difficulty_level}: {str(e)}")
            raise ValidationError(f"Failed to get recipes: {str(e)}")
    
    def search_recipes(self, search_term: str, filters: Optional[Dict[str, Any]] = None) -> List[Recipe]:
        """Search recipes by name, description, or ingredients"""
        try:
            query = self.session.query(Recipe).filter(Recipe.is_active == True)
            
            # Text search in name and description
            search_filter = or_(
                Recipe.name.ilike(f"%{search_term}%"),
                Recipe.description.ilike(f"%{search_term}%")
            )
            query = query.filter(search_filter)
            
            # Apply additional filters if provided
            if filters:
                if 'meal_type' in filters:
                    query = query.filter(Recipe.meal_type == filters['meal_type'])
                
                if 'cuisine_type' in filters:
                    query = query.filter(Recipe.cuisine_type.ilike(f"%{filters['cuisine_type']}%"))
                
                if 'difficulty_level' in filters:
                    query = query.filter(Recipe.difficulty_level == filters['difficulty_level'])
                
                if 'max_prep_time' in filters:
                    query = query.filter(Recipe.prep_time_minutes <= filters['max_prep_time'])
                
                if 'max_cost_usd' in filters:
                    max_cost_cents = int(filters['max_cost_usd'] * 100)
                    query = query.filter(Recipe.estimated_cost_usd <= max_cost_cents)
            
            recipes = query.all()
            
            # Additional filtering for dietary restrictions (if specified)
            if filters and 'dietary_restrictions' in filters:
                recipes = [
                    recipe for recipe in recipes 
                    if recipe.matches_dietary_restrictions(filters['dietary_restrictions'])
                ]
            
            logger.debug(f"Found {len(recipes)} recipes matching search: {search_term}")
            return recipes
            
        except Exception as e:
            logger.error(f"Error searching recipes: {str(e)}")
            raise ValidationError(f"Failed to search recipes: {str(e)}")
    
    def get_all_active_recipes(self, limit: Optional[int] = None, offset: Optional[int] = None) -> List[Recipe]:
        """Get all active recipes with optional pagination"""
        try:
            query = self.session.query(Recipe).filter(Recipe.is_active == True)
            
            if offset:
                query = query.offset(offset)
            
            if limit:
                query = query.limit(limit)
            
            recipes = query.all()
            logger.debug(f"Found {len(recipes)} active recipes")
            return recipes
            
        except Exception as e:
            logger.error(f"Error getting all recipes: {str(e)}")
            raise ValidationError(f"Failed to get recipes: {str(e)}")
    
    def update_recipe(self, recipe_id: str, update_data: Dict[str, Any]) -> Recipe:
        """Update an existing recipe"""
        try:
            recipe = self.get_recipe_by_id(recipe_id)
            if not recipe:
                raise ValidationError(f"Recipe not found: {recipe_id}")
            
            # Update fields
            for field, value in update_data.items():
                if hasattr(recipe, field):
                    setattr(recipe, field, value)
            
            self.session.commit()
            logger.info(f"Recipe updated successfully: {recipe_id}")
            return recipe
            
        except Exception as e:
            self.session.rollback()
            logger.error(f"Error updating recipe {recipe_id}: {str(e)}")
            raise ValidationError(f"Failed to update recipe: {str(e)}")
    
    def delete_recipe(self, recipe_id: str) -> bool:
        """Soft delete a recipe (mark as inactive)"""
        try:
            recipe = self.get_recipe_by_id(recipe_id)
            if not recipe:
                logger.warning(f"Recipe not found for deletion: {recipe_id}")
                return False
            
            recipe.is_active = False
            self.session.commit()
            
            logger.info(f"Recipe soft deleted successfully: {recipe_id}")
            return True
            
        except Exception as e:
            self.session.rollback()
            logger.error(f"Error deleting recipe {recipe_id}: {str(e)}")
            raise ValidationError(f"Failed to delete recipe: {str(e)}")
    
    def get_recipe_count(self) -> int:
        """Get total count of active recipes"""
        try:
            count = self.session.query(Recipe).filter(Recipe.is_active == True).count()
            logger.debug(f"Total active recipes: {count}")
            return count
            
        except Exception as e:
            logger.error(f"Error getting recipe count: {str(e)}")
            return 0
    
    def get_recipe_statistics(self) -> Dict[str, Any]:
        """Get comprehensive recipe statistics"""
        try:
            recipes = self.session.query(Recipe).filter(Recipe.is_active == True).all()
            
            total_recipes = len(recipes)
            
            # Count by meal type
            meal_type_counts = {}
            for recipe in recipes:
                meal_type = recipe.meal_type or 'unknown'
                meal_type_counts[meal_type] = meal_type_counts.get(meal_type, 0) + 1
            
            # Count by cuisine
            cuisine_counts = {}
            for recipe in recipes:
                cuisine = recipe.cuisine_type or 'unknown'
                cuisine_counts[cuisine] = cuisine_counts.get(cuisine, 0) + 1
            
            # Cost analysis
            recipes_with_cost = [r for r in recipes if r.estimated_cost_usd]
            avg_cost = sum([r.cost_usd for r in recipes_with_cost]) / len(recipes_with_cost) if recipes_with_cost else 0
            
            # Time analysis
            recipes_with_prep_time = [r for r in recipes if r.prep_time_minutes]
            avg_prep_time = sum([r.prep_time_minutes for r in recipes_with_prep_time]) / len(recipes_with_prep_time) if recipes_with_prep_time else 0
            
            stats = {
                'total_recipes': total_recipes,
                'meal_type_distribution': meal_type_counts,
                'cuisine_distribution': cuisine_counts,
                'average_cost_usd': avg_cost,
                'average_prep_time_minutes': avg_prep_time,
                'recipes_with_cost': len(recipes_with_cost),
                'recipes_with_prep_time': len(recipes_with_prep_time)
            }
            
            logger.debug(f"Recipe statistics calculated: {stats}")
            return stats
            
        except Exception as e:
            logger.error(f"Error getting recipe statistics: {str(e)}")
            return {}
    
    def bulk_create_recipes(self, recipes_data: List[Dict[str, Any]]) -> List[Recipe]:
        """Bulk create multiple recipes"""
        try:
            created_recipes = []
            
            for recipe_data in recipes_data:
                recipe = Recipe(
                    name=recipe_data['name'],
                    ingredients=recipe_data['ingredients'],
                    instructions=recipe_data['instructions'],
                    description=recipe_data.get('description'),
                    cuisine_type=recipe_data.get('cuisine_type'),
                    meal_type=recipe_data.get('meal_type'),
                    prep_time_minutes=recipe_data.get('prep_time_minutes'),
                    cook_time_minutes=recipe_data.get('cook_time_minutes'),
                    nutritional_info=recipe_data.get('nutritional_info'),
                    estimated_cost_usd=recipe_data.get('estimated_cost_usd'),
                    difficulty_level=recipe_data.get('difficulty_level'),
                    source_url=recipe_data.get('source_url'),
                    image_url=recipe_data.get('image_url'),
                    servings=recipe_data.get('servings', 1)
                )
                created_recipes.append(recipe)
                self.session.add(recipe)
            
            self.session.commit()
            logger.info(f"Bulk created {len(created_recipes)} recipes successfully")
            return created_recipes
            
        except Exception as e:
            self.session.rollback()
            logger.error(f"Error bulk creating recipes: {str(e)}")
            raise ValidationError(f"Failed to bulk create recipes: {str(e)}") 