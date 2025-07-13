"""
Preference Learning Service for Story 2.2
Handles meal recommendation swiping interface and preference learning
"""

import logging
import random
from typing import List, Dict, Any, Optional
from datetime import datetime

from core.models.user_preferences import UserPreferences
from core.models.recipe import Recipe
from data_access.recipe_repository import RecipeRepository
from data_access.user_repository import UserRepository
from core.exceptions import UserNotFoundError, ValidationError

logger = logging.getLogger(__name__)


class PreferenceLearningService:
    """Service for handling meal recommendation swiping and preference learning"""
    
    def __init__(self):
        self.user_preferences = UserPreferences()
        self.recipe_repository = RecipeRepository()
        self.user_repository = UserRepository()
    
    def get_meal_suggestions(self, user_id: str, session_length: int = 20) -> List[Dict[str, Any]]:
        """Get meal suggestions for swiping interface"""
        try:
            # Verify user exists
            user = self.user_repository.get_user_by_id(user_id)
            if not user:
                raise UserNotFoundError(f"User {user_id} not found")
            
            # Get user preferences to apply initial filtering
            user_prefs = self.user_preferences.get_preferences(user_id)
            dietary_restrictions = []
            if user_prefs and 'preferences' in user_prefs:
                dietary_restrictions = user_prefs['preferences'].get('dietary_restrictions', [])
            
            # Get all active recipes
            all_recipes = self.recipe_repository.get_all_active_recipes()
            
            # Filter by dietary restrictions
            filtered_recipes = [
                recipe for recipe in all_recipes 
                if recipe.matches_dietary_restrictions(dietary_restrictions)
            ]
            
            # Get recipes user hasn't swiped on yet
            swipe_prefs = self.user_preferences.get_swipe_preferences(user_id)
            unrated_recipes = [
                recipe for recipe in filtered_recipes 
                if str(recipe.id) not in swipe_prefs
            ]
            
            # If we don't have enough unrated recipes, include some already rated ones
            if len(unrated_recipes) < session_length:
                rated_recipes = [
                    recipe for recipe in filtered_recipes 
                    if str(recipe.id) in swipe_prefs
                ]
                # Shuffle and add some rated recipes
                random.shuffle(rated_recipes)
                unrated_recipes.extend(rated_recipes[:session_length - len(unrated_recipes)])
            
            # Apply slight bias toward user's known preferences
            if user_prefs:
                unrated_recipes = self._apply_preference_bias(unrated_recipes, user_prefs)
            
            # Shuffle for variety and take the requested number
            random.shuffle(unrated_recipes)
            selected_recipes = unrated_recipes[:session_length]
            
            # Convert to API format
            suggestions = []
            for recipe in selected_recipes:
                recipe_dict = recipe.to_dict()
                # Add any previous swipe/rating data
                recipe_dict['previous_swipe'] = swipe_prefs.get(str(recipe.id))
                recipe_dict['user_rating'] = self.user_preferences.get_recipe_ratings(user_id).get(str(recipe.id))
                suggestions.append(recipe_dict)
            
            logger.info(f"Generated {len(suggestions)} meal suggestions for user {user_id}")
            return suggestions
            
        except Exception as e:
            logger.error(f"Error generating meal suggestions for user {user_id}: {str(e)}")
            raise
    
    def record_swipe_feedback(self, user_id: str, recipe_id: str, action: str) -> Dict[str, Any]:
        """Record swipe feedback and update user preferences"""
        try:
            # Verify user exists
            user = self.user_repository.get_user_by_id(user_id)
            if not user:
                raise UserNotFoundError(f"User {user_id} not found")
            
            # Validate action
            if action not in ["like", "dislike"]:
                raise ValidationError("Action must be 'like' or 'dislike'")
            
            # Verify recipe exists
            recipe = self.recipe_repository.get_recipe_by_id(recipe_id)
            if not recipe:
                raise ValidationError(f"Recipe {recipe_id} not found")
            
            # Record the swipe
            logger.info(f"Recording swipe feedback for user {user_id}, recipe {recipe_id}, action {action}")
            success = self.user_preferences.record_swipe_feedback(user_id, recipe_id, action)
            
            if not success:
                logger.error(f"Failed to record swipe feedback in MongoDB for user {user_id}")
                raise Exception("Failed to record swipe feedback in database")
            
            # Update preference weights (for future algorithm improvements)
            self._update_preference_weights(user_id, recipe_id, action, recipe)
            
            result = {
                "user_id": user_id,
                "recipe_id": recipe_id,
                "action": action,
                "timestamp": datetime.utcnow().isoformat(),
                "context": "swiping_session",
                "feedback_recorded": True
            }
            
            logger.info(f"Successfully recorded swipe feedback: user {user_id} {action}d recipe {recipe_id}")
            return result
            
        except (UserNotFoundError, ValidationError) as e:
            logger.error(f"Validation error recording swipe feedback: {str(e)}")
            raise
        except Exception as e:
            logger.error(f"Error recording swipe feedback: {str(e)}")
            raise Exception("Failed to record swipe feedback")
    
    def set_recipe_rating(self, user_id: str, recipe_id: str, rating: float) -> Dict[str, Any]:
        """Set detailed recipe rating (1-5 stars)"""
        try:
            # Verify user exists
            user = self.user_repository.get_user_by_id(user_id)
            if not user:
                raise UserNotFoundError(f"User {user_id} not found")
            
            # Validate rating
            if not (1.0 <= rating <= 5.0):
                raise ValidationError("Rating must be between 1.0 and 5.0")
            
            # Verify recipe exists
            recipe = self.recipe_repository.get_recipe_by_id(recipe_id)
            if not recipe:
                raise ValidationError(f"Recipe {recipe_id} not found")
            
            # Set the rating
            success = self.user_preferences.set_recipe_rating(user_id, recipe_id, rating)
            
            if not success:
                raise Exception("Failed to set recipe rating")
            
            result = {
                "user_id": user_id,
                "recipe_id": recipe_id,
                "rating": rating,
                "timestamp": datetime.utcnow().isoformat(),
                "rating_recorded": True
            }
            
            logger.info(f"Set recipe rating: user {user_id} rated recipe {recipe_id} as {rating} stars")
            return result
            
        except Exception as e:
            logger.error(f"Error setting recipe rating: {str(e)}")
            raise
    
    def update_ingredient_preference(self, user_id: str, ingredient: str, preference: str) -> Dict[str, Any]:
        """Update ingredient like/dislike preference"""
        try:
            # Verify user exists
            user = self.user_repository.get_user_by_id(user_id)
            if not user:
                raise UserNotFoundError(f"User {user_id} not found")
            
            # Validate preference
            if preference not in ["liked", "disliked"]:
                raise ValidationError("Preference must be 'liked' or 'disliked'")
            
            # Update the preference
            success = self.user_preferences.update_ingredient_preferences(user_id, ingredient, preference)
            
            if not success:
                raise Exception("Failed to update ingredient preference")
            
            result = {
                "user_id": user_id,
                "ingredient": ingredient,
                "preference": preference,
                "timestamp": datetime.utcnow().isoformat(),
                "preference_updated": True
            }
            
            logger.info(f"Updated ingredient preference: user {user_id} {preference} {ingredient}")
            return result
            
        except Exception as e:
            logger.error(f"Error updating ingredient preference: {str(e)}")
            raise
    
    def set_cuisine_preference(self, user_id: str, cuisine: str, rating: int) -> Dict[str, Any]:
        """Set cuisine preference rating (1-5 scale)"""
        try:
            # Verify user exists
            user = self.user_repository.get_user_by_id(user_id)
            if not user:
                raise UserNotFoundError(f"User {user_id} not found")
            
            # Validate rating
            if not (1 <= rating <= 5):
                raise ValidationError("Rating must be between 1 and 5")
            
            # Set the preference
            success = self.user_preferences.set_cuisine_preference(user_id, cuisine, rating)
            
            if not success:
                raise Exception("Failed to set cuisine preference")
            
            result = {
                "user_id": user_id,
                "cuisine": cuisine,
                "rating": rating,
                "timestamp": datetime.utcnow().isoformat(),
                "preference_updated": True
            }
            
            logger.info(f"Set cuisine preference: user {user_id} rated {cuisine} cuisine as {rating}")
            return result
            
        except Exception as e:
            logger.error(f"Error setting cuisine preference: {str(e)}")
            raise
    
    def calculate_preference_score(self, user_id: str, recipe: Recipe) -> float:
        """Calculate preference score for a recipe based on user's swipe and rating history"""
        try:
            user_prefs = self.user_preferences.get_preferences(user_id)
            if not user_prefs:
                return 0.5  # Neutral score for new users
            
            score = 0.0
            factors = []
            
            # 1. Swipe feedback weight (60% as per story spec)
            swipe_prefs = user_prefs.get("swipe_preferences", {})
            recipe_id_str = str(recipe.id)
            if recipe_id_str in swipe_prefs:
                swipe_score = 1.0 if swipe_prefs[recipe_id_str] == "like" else 0.0
                factors.append(("swipe", swipe_score, 0.6))
            
            # 2. Detailed ratings weight (40% as per story spec)
            recipe_ratings = user_prefs.get("recipe_ratings", {})
            if recipe_id_str in recipe_ratings:
                # Convert 1-5 rating to 0-1 score
                rating_score = (recipe_ratings[recipe_id_str] - 1) / 4
                factors.append(("rating", rating_score, 0.4))
            
            # 3. Ingredient preferences boost/penalty
            ingredient_prefs = user_prefs.get("ingredient_preferences", {"liked": [], "disliked": []})
            ingredient_score = self._calculate_ingredient_score(recipe, ingredient_prefs)
            if ingredient_score != 0.5:  # Only apply if there's a preference signal
                factors.append(("ingredients", ingredient_score, 0.2))
            
            # 4. Cuisine preference
            cuisine_prefs = user_prefs.get("cuisine_preferences", {})
            if recipe.cuisine_type and recipe.cuisine_type in cuisine_prefs:
                # Convert 1-5 rating to 0-1 score
                cuisine_score = (cuisine_prefs[recipe.cuisine_type] - 1) / 4
                factors.append(("cuisine", cuisine_score, 0.2))
            
            # 5. Prep time preference
            prep_time_pref = user_prefs.get("prep_time_preference", "moderate")
            prep_time_score = self._calculate_prep_time_score(recipe, prep_time_pref)
            factors.append(("prep_time", prep_time_score, 0.1))
            
            # Calculate weighted average
            if factors:
                total_weight = sum(factor[2] for factor in factors)
                weighted_sum = sum(factor[1] * factor[2] for factor in factors)
                score = weighted_sum / total_weight
            else:
                score = 0.5  # Neutral score
            
            return max(0.0, min(1.0, score))  # Clamp to [0, 1]
            
        except Exception as e:
            logger.error(f"Error calculating preference score: {str(e)}")
            return 0.5
    
    def _apply_preference_bias(self, recipes: List[Recipe], user_prefs: Dict[str, Any]) -> List[Recipe]:
        """Apply slight bias toward user's known preferences"""
        # Sort by calculated preference score
        scored_recipes = [
            (recipe, self.calculate_preference_score(user_prefs["user_id"], recipe))
            for recipe in recipes
        ]
        
        # Sort by score (higher scores first) but maintain some randomness
        scored_recipes.sort(key=lambda x: x[1] + random.uniform(-0.1, 0.1), reverse=True)
        
        return [recipe for recipe, _ in scored_recipes]
    
    def _update_preference_weights(self, user_id: str, recipe_id: str, action: str, recipe: Recipe):
        """Update preference weights based on swipe feedback (for future ML improvements)"""
        # This is a placeholder for future ML model training
        # For now, we just log the interaction for analytics
        logger.info(f"Preference weight update: user {user_id}, recipe {recipe_id}, "
                   f"action {action}, cuisine {recipe.cuisine_type}, "
                   f"prep_time {recipe.prep_time_minutes}")
    
    def _calculate_ingredient_score(self, recipe: Recipe, ingredient_prefs: Dict[str, List[str]]) -> float:
        """Calculate score based on ingredient preferences"""
        liked_ingredients = ingredient_prefs.get("liked", [])
        disliked_ingredients = ingredient_prefs.get("disliked", [])
        
        if not liked_ingredients and not disliked_ingredients:
            return 0.5  # Neutral
        
        recipe_ingredients = [ing.get("name", "").lower() for ing in recipe.ingredients if isinstance(ing, dict)]
        recipe_text = " ".join(recipe_ingredients).lower()
        
        score = 0.5
        matches = 0
        
        # Boost for liked ingredients
        for liked in liked_ingredients:
            if liked.lower() in recipe_text:
                score += 0.1
                matches += 1
        
        # Penalty for disliked ingredients
        for disliked in disliked_ingredients:
            if disliked.lower() in recipe_text:
                score -= 0.2
                matches += 1
        
        # Only return adjusted score if there were ingredient matches
        return max(0.0, min(1.0, score)) if matches > 0 else 0.5
    
    def _calculate_prep_time_score(self, recipe: Recipe, prep_time_pref: str) -> float:
        """Calculate score based on prep time preference"""
        if not recipe.prep_time_minutes:
            return 0.5  # Neutral for unknown prep time
        
        prep_time = recipe.prep_time_minutes
        
        if prep_time_pref == "quick":
            # Prefer recipes under 20 minutes
            if prep_time <= 15:
                return 1.0
            elif prep_time <= 30:
                return 0.7
            else:
                return 0.3
        elif prep_time_pref == "elaborate":
            # Prefer recipes over 45 minutes
            if prep_time >= 60:
                return 1.0
            elif prep_time >= 30:
                return 0.7
            else:
                return 0.3
        else:  # moderate
            # Prefer recipes 20-45 minutes
            if 20 <= prep_time <= 45:
                return 1.0
            elif 15 <= prep_time <= 60:
                return 0.7
            else:
                return 0.4 