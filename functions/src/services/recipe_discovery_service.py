"""
Recipe Discovery Service
Business logic for recipe search, filtering, and recommendations
"""

import logging
from typing import List, Dict, Any, Optional, NamedTuple
from dataclasses import dataclass
from sqlalchemy import and_, or_, desc, asc
from sqlalchemy.orm import Session
import math

from core.models.recipe import Recipe
from core.models.user import User
from data_access.recipe_repository import RecipeRepository
from data_access.user_repository import UserRepository
from core.exceptions import ValidationError
from data_access.database import db

logger = logging.getLogger(__name__)

@dataclass
class SearchResult:
    """Container for search results with pagination info"""
    recipes: List[Recipe]
    page: int
    limit: int
    total_count: int
    total_pages: int
    has_next: bool
    has_previous: bool
    filters_applied: Dict[str, Any]

class RecipeDiscoveryService:
    """Service for recipe discovery, search, and recommendations"""
    
    def __init__(self, session: Optional[Session] = None):
        """Initialize service with optional database session"""
        self.session = session or db.session
        self.recipe_repository = RecipeRepository(self.session)
        self.user_repository = UserRepository()
    
    def search_recipes(self, search_query: str = "", filters: Optional[Dict[str, Any]] = None,
                      page: int = 1, limit: int = 20, sort_by: str = "name", 
                      sort_order: str = "asc", user_id: Optional[str] = None) -> SearchResult:
        """
        Search recipes with comprehensive filtering and pagination
        
        Args:
            search_query: Text to search for in recipe names, descriptions, ingredients
            filters: Dictionary of filter criteria
            page: Page number (1-based)
            limit: Number of results per page
            sort_by: Field to sort by (name, prep_time, cost, difficulty, created_at)
            sort_order: Sort direction (asc, desc)
            user_id: User ID for personalization
            
        Returns:
            SearchResult with recipes and pagination info
        """
        try:
            filters = filters or {}
            
            # Start with base query for active recipes
            query = self.session.query(Recipe).filter(Recipe.is_active == True)
            
            # Apply text search if provided
            if search_query:
                search_terms = search_query.lower().split()
                for term in search_terms:
                    # Search in name, description, and ingredients
                    search_filter = or_(
                        Recipe.name.ilike(f"%{term}%"),
                        Recipe.description.ilike(f"%{term}%"),
                        Recipe.ingredients.cast(db.String).ilike(f"%{term}%")
                    )
                    query = query.filter(search_filter)
            
            # Apply filters
            query = self._apply_filters(query, filters)
            
            # Get total count before pagination
            total_count = query.count()
            
            # Apply sorting
            query = self._apply_sorting(query, sort_by, sort_order)
            
            # Apply pagination
            offset = (page - 1) * limit
            recipes = query.offset(offset).limit(limit).all()
            
            # Calculate pagination info
            total_pages = math.ceil(total_count / limit) if total_count > 0 else 1
            has_next = page < total_pages
            has_previous = page > 1
            
            # Apply personalization scoring if user provided
            if user_id and recipes:
                recipes = self._apply_personalization(recipes, user_id)
            
            logger.info(f"Recipe search completed: {len(recipes)} recipes found (page {page}/{total_pages})")
            
            return SearchResult(
                recipes=recipes,
                page=page,
                limit=limit,
                total_count=total_count,
                total_pages=total_pages,
                has_next=has_next,
                has_previous=has_previous,
                filters_applied=filters
            )
            
        except Exception as e:
            logger.error(f"Error in recipe search: {str(e)}")
            raise ValidationError(f"Recipe search failed: {str(e)}")
    
    def _apply_filters(self, query, filters: Dict[str, Any]):
        """Apply various filters to the recipe query"""
        
        # Meal type filter
        if 'meal_type' in filters:
            query = query.filter(Recipe.meal_type == filters['meal_type'])
        
        # Cuisine type filter
        if 'cuisine_type' in filters:
            query = query.filter(Recipe.cuisine_type.ilike(f"%{filters['cuisine_type']}%"))
        
        # Difficulty level filter
        if 'difficulty_level' in filters:
            query = query.filter(Recipe.difficulty_level == filters['difficulty_level'])
        
        # Preparation time filter
        if 'max_prep_time' in filters:
            query = query.filter(Recipe.prep_time_minutes <= filters['max_prep_time'])
        
        # Cost filters
        if 'min_cost_usd' in filters:
            min_cost_cents = int(filters['min_cost_usd'] * 100)
            query = query.filter(Recipe.estimated_cost_usd >= min_cost_cents)
        
        if 'max_cost_usd' in filters:
            max_cost_cents = int(filters['max_cost_usd'] * 100)
            query = query.filter(Recipe.estimated_cost_usd <= max_cost_cents)
        
        # Dietary restrictions - this needs to be applied after the query
        # since it requires Python logic in the Recipe model
        return query
    
    def _apply_sorting(self, query, sort_by: str, sort_order: str):
        """Apply sorting to the recipe query"""
        
        # Map sort fields to actual model attributes
        sort_mapping = {
            'name': Recipe.name,
            'prep_time': Recipe.prep_time_minutes,
            'cost': Recipe.estimated_cost_usd,
            'difficulty': Recipe.difficulty_level,
            'created_at': Recipe.created_at
        }
        
        if sort_by not in sort_mapping:
            sort_by = 'name'  # Default fallback
        
        sort_field = sort_mapping[sort_by]
        
        if sort_order == 'desc':
            query = query.order_by(desc(sort_field))
        else:
            query = query.order_by(asc(sort_field))
        
        return query
    
    def _apply_personalization(self, recipes: List[Recipe], user_id: str) -> List[Recipe]:
        """Apply personalization scoring to recipes based on user preferences"""
        try:
            # Get user and their preferences
            user = self.user_repository.get_user_by_id(user_id)
            if not user:
                return recipes
            
            # For now, just return recipes as-is
            # In future iterations, this could:
            # 1. Score recipes based on user's past preferences
            # 2. Consider user's dietary restrictions
            # 3. Factor in user's cooking skill level
            # 4. Use ML models for recommendation scoring
            
            return recipes
            
        except Exception as e:
            logger.warning(f"Personalization failed for user {user_id}: {str(e)}")
            return recipes
    
    def get_recipe_details(self, recipe_id: str, user_id: Optional[str] = None) -> Optional[Recipe]:
        """Get detailed information for a specific recipe"""
        try:
            recipe = self.recipe_repository.get_recipe_by_id(recipe_id)
            
            # Log recipe view for analytics (optional)
            if recipe and user_id:
                logger.info(f"User {user_id} viewed recipe {recipe_id}")
            
            return recipe
            
        except Exception as e:
            logger.error(f"Error getting recipe details {recipe_id}: {str(e)}")
            raise ValidationError(f"Failed to get recipe details: {str(e)}")
    
    def get_filter_options(self) -> Dict[str, List[str]]:
        """Get available filter options based on existing recipes"""
        try:
            # Query distinct values for filter options
            meal_types = self.session.query(Recipe.meal_type).distinct().filter(
                and_(Recipe.meal_type.isnot(None), Recipe.is_active == True)
            ).all()
            
            cuisine_types = self.session.query(Recipe.cuisine_type).distinct().filter(
                and_(Recipe.cuisine_type.isnot(None), Recipe.is_active == True)
            ).all()
            
            difficulty_levels = self.session.query(Recipe.difficulty_level).distinct().filter(
                and_(Recipe.difficulty_level.isnot(None), Recipe.is_active == True)
            ).all()
            
            # Convert tuples to lists and filter out None values
            meal_type_list = sorted([mt[0] for mt in meal_types if mt[0]])
            cuisine_type_list = sorted([ct[0] for ct in cuisine_types if ct[0]])
            difficulty_level_list = sorted([dl[0] for dl in difficulty_levels if dl[0]])
            
            return {
                'meal_types': meal_type_list,
                'cuisine_types': cuisine_type_list,
                'difficulty_levels': difficulty_level_list,
                'dietary_restrictions': [
                    'vegan', 'vegetarian', 'gluten-free', 'dairy-free', 'nut-free', 'keto'
                ],
                'time_ranges': [
                    {'label': '≤15 min', 'max_minutes': 15},
                    {'label': '15-30 min', 'min_minutes': 15, 'max_minutes': 30},
                    {'label': '30-60 min', 'min_minutes': 30, 'max_minutes': 60},
                    {'label': '>60 min', 'min_minutes': 60}
                ],
                'cost_ranges': [
                    {'label': 'Budget-friendly', 'max_usd': 5.00},
                    {'label': 'Moderate', 'min_usd': 5.00, 'max_usd': 15.00},
                    {'label': 'Premium', 'min_usd': 15.00}
                ]
            }
            
        except Exception as e:
            logger.error(f"Error getting filter options: {str(e)}")
            raise ValidationError(f"Failed to get filter options: {str(e)}")
    
    def get_search_suggestions(self, query: str, limit: int = 10, 
                             user_id: Optional[str] = None) -> List[str]:
        """Get search suggestions based on partial query"""
        try:
            if len(query) < 2:
                return []
            
            # Search for recipe names that start with or contain the query
            recipes = self.session.query(Recipe.name).filter(
                and_(
                    Recipe.name.ilike(f"%{query}%"),
                    Recipe.is_active == True
                )
            ).limit(limit).all()
            
            suggestions = [recipe[0] for recipe in recipes]
            
            # Add some common ingredient suggestions
            common_ingredients = [
                'chicken', 'beef', 'salmon', 'pasta', 'rice', 'vegetables',
                'garlic', 'onion', 'tomato', 'cheese', 'herbs', 'spices'
            ]
            
            ingredient_suggestions = [
                ing for ing in common_ingredients 
                if query.lower() in ing.lower() and ing not in suggestions
            ]
            
            # Combine and limit results
            all_suggestions = suggestions + ingredient_suggestions
            return all_suggestions[:limit]
            
        except Exception as e:
            logger.error(f"Error getting search suggestions: {str(e)}")
            return []
    
    def get_trending_recipes(self, limit: int = 10, user_id: Optional[str] = None) -> List[Recipe]:
        """Get trending/popular recipes"""
        try:
            # For now, return recently created recipes
            # In a real system, this would be based on view counts, ratings, etc.
            recipes = self.session.query(Recipe).filter(
                Recipe.is_active == True
            ).order_by(desc(Recipe.created_at)).limit(limit).all()
            
            return recipes
            
        except Exception as e:
            logger.error(f"Error getting trending recipes: {str(e)}")
            return []
    
    def get_personalized_recommendations(self, user_id: str, limit: int = 10) -> List[Recipe]:
        """Get personalized recipe recommendations for a user"""
        try:
            user = self.user_repository.get_user_by_id(user_id)
            if not user:
                # Fallback to trending recipes
                return self.get_trending_recipes(limit)
            
            # Get user's dietary restrictions
            dietary_restrictions = getattr(user, 'dietary_restrictions', []) or []
            
            # Start with recipes that match dietary restrictions
            query = self.session.query(Recipe).filter(Recipe.is_active == True)
            
            # For now, just filter by dietary restrictions and return recent recipes
            # In future iterations, this could use ML models, user behavior, etc.
            recipes = query.order_by(desc(Recipe.created_at)).limit(limit * 2).all()
            
            # Filter by dietary restrictions in Python
            if dietary_restrictions:
                filtered_recipes = [
                    recipe for recipe in recipes 
                    if recipe.matches_dietary_restrictions(dietary_restrictions)
                ]
                return filtered_recipes[:limit]
            
            return recipes[:limit]
            
        except Exception as e:
            logger.error(f"Error getting personalized recommendations for user {user_id}: {str(e)}")
            # Fallback to trending recipes
            return self.get_trending_recipes(limit) 