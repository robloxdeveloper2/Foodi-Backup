"""
Meal Substitution Service
Implements intelligent meal substitution with nutritional and preference matching
"""

import logging
from typing import Optional, List, Dict, Any, Tuple
from dataclasses import dataclass
from datetime import datetime

from core.models.recipe import Recipe
from core.models.meal_plan import MealPlan
from core.models.user_preferences import UserPreferences
from core.exceptions import ValidationError, AppError
from data_access.database import db
from services.preference_learning_service import PreferenceLearningService
from sqlalchemy.orm.attributes import flag_modified

logger = logging.getLogger(__name__)

@dataclass
class SubstitutionRequest:
    """Request parameters for meal substitution"""
    meal_plan_id: str
    meal_id: str  # Index or identifier within the meal plan
    user_id: str
    max_alternatives: int = 5
    nutritional_tolerance: float = 0.15  # ±15% tolerance for nutritional matching

@dataclass
class SubstitutionCandidate:
    """A candidate recipe for substitution with scoring"""
    recipe: Recipe
    total_score: float
    nutritional_similarity: float
    user_preference: float
    cost_efficiency: float
    prep_time_match: float
    substitution_impact: Dict[str, Any]

@dataclass
class SubstitutionHistory:
    """Track substitution history for undo functionality"""
    meal_plan_id: str
    meal_index: int
    original_recipe_id: str
    new_recipe_id: str
    timestamp: datetime
    user_id: str

class MealSubstitutionService:
    """Service for intelligent meal substitution"""
    
    # Scoring weights for substitution algorithm
    SCORING_WEIGHTS = {
        'nutritional_similarity': 0.4,  # 40% - Most important for maintaining goals
        'user_preference': 0.3,         # 30% - Based on cuisine preferences and ingredient likes/dislikes
        'cost_efficiency': 0.2,         # 20% - Similar cost per serving
        'prep_time_match': 0.1          # 10% - Similar cooking complexity and time
    }
    
    def __init__(self):
        try:
            self.user_preferences_model = UserPreferences()
        except Exception as e:
            logger.warning(f"MongoDB not available, proceeding without user preferences: {e}")
            self.user_preferences_model = None
        
        try:
            self.preference_service = PreferenceLearningService()
        except Exception as e:
            logger.warning(f"Could not initialize preference learning service: {e}")
            self.preference_service = None
    
    def find_substitutes(self, request: SubstitutionRequest) -> List[SubstitutionCandidate]:
        """
        Find substitute meals using smart matching algorithm
        
        Algorithm:
        1. Analyze nutritional profile of meal to replace
        2. Filter recipes by same meal type and dietary restrictions  
        3. Score alternatives by nutritional similarity
        4. Return top alternatives sorted by score
        """
        logger.info(f"Finding substitutes for meal plan {request.meal_plan_id}, meal {request.meal_id}")
        
        # Step 1: Get original meal plan and meal
        meal_plan, original_meal = self._get_original_meal(request)
        original_recipe = self._get_recipe(original_meal['recipe_id'])
        
        # Step 2: Get user profile for filtering and scoring
        user_profile = self._get_user_preferences(request.user_id)
        
        # Step 3: Analyze nutritional profile of original meal
        target_nutrition = self._analyze_meal_nutrition(original_recipe)
        
        # Step 4: Filter candidate recipes
        candidates = self._filter_recipes(
            meal_type=original_meal['meal_type'],
            user_profile=user_profile,
            exclude_recipe_id=original_meal['recipe_id']
        )
        
        if not candidates:
            logger.warning("No candidate recipes found for substitution")
            return []
        
        # Step 5: Score alternatives by nutritional similarity and preferences
        scored_candidates = []
        for candidate in candidates:
            score_result = self._calculate_substitution_score(
                candidate, target_nutrition, user_profile, original_recipe
            )
            
            # Calculate substitution impact on daily goals
            impact = self._calculate_substitution_impact(
                original_recipe, candidate, meal_plan, request.user_id
            )
            
            # Only include candidates within nutritional tolerance
            if self._within_nutritional_tolerance(original_recipe, candidate, request.nutritional_tolerance):
                scored_candidates.append(SubstitutionCandidate(
                    recipe=candidate,
                    total_score=score_result['total_score'],
                    nutritional_similarity=score_result['nutritional_similarity'],
                    user_preference=score_result['user_preference'],
                    cost_efficiency=score_result['cost_efficiency'],
                    prep_time_match=score_result['prep_time_match'],
                    substitution_impact=impact
                ))
        
        # Step 6: Return top alternatives
        sorted_candidates = sorted(scored_candidates, key=lambda x: x.total_score, reverse=True)
        return sorted_candidates[:request.max_alternatives]
    
    def apply_substitution(self, meal_plan_id: str, meal_index: int, new_recipe_id: str, user_id: str) -> MealPlan:
        """
        Apply a meal substitution and update the meal plan
        """
        logger.info(f"Applying substitution for meal plan {meal_plan_id}, meal {meal_index}")
        
        # Get meal plan
        meal_plan = db.session.query(MealPlan).filter_by(id=meal_plan_id, user_id=user_id).first()
        if not meal_plan:
            raise ValidationError("Meal plan not found")
        
        # Validate meal index
        if meal_index < 0 or meal_index >= len(meal_plan.meals):
            raise ValidationError("Invalid meal index")
        
        # Store original recipe for undo functionality
        original_recipe_id = meal_plan.meals[meal_index]['recipe_id']
        
        # Validate new recipe exists
        new_recipe = self._get_recipe(new_recipe_id)
        if not new_recipe:
            raise ValidationError("New recipe not found")
        
        # Record substitution history (for undo)
        self._record_substitution_history(
            meal_plan_id, meal_index, original_recipe_id, new_recipe_id, user_id
        )
        
        # Update meal plan
        meal_plan.meals[meal_index]['recipe_id'] = new_recipe_id
        meal_plan.meals[meal_index]['recipe_name'] = new_recipe.name  # Also update name for consistency
        
        # Mark the JSON column as modified so SQLAlchemy will save the changes
        flag_modified(meal_plan, 'meals')
        
        meal_plan.updated_at = datetime.utcnow()
        
        # Recalculate nutritional summaries
        self._recalculate_meal_plan_nutrition(meal_plan)
        
        # Save changes
        db.session.commit()
        
        logger.info(f"Substitution applied successfully: {original_recipe_id} -> {new_recipe_id}")
        return meal_plan
    
    def undo_substitution(self, meal_plan_id: str, user_id: str) -> MealPlan:
        """
        Undo the most recent substitution in a meal plan
        """
        logger.info(f"Undoing substitution for meal plan {meal_plan_id}")
        
        # Find most recent substitution
        history = self._get_recent_substitution_history(meal_plan_id, user_id)
        if not history:
            raise ValidationError("No recent substitution to undo")
        
        # Get meal plan
        meal_plan = db.session.query(MealPlan).filter_by(id=meal_plan_id, user_id=user_id).first()
        if not meal_plan:
            raise ValidationError("Meal plan not found")
        
        # Validate meal index
        if history.meal_index < 0 or history.meal_index >= len(meal_plan.meals):
            raise ValidationError("Invalid meal index in substitution history")
        
        # Restore original recipe
        meal_plan.meals[history.meal_index]['recipe_id'] = history.original_recipe_id
        meal_plan.meals[history.meal_index]['recipe_name'] = self._get_recipe(history.original_recipe_id).name  # Also update name for consistency
        
        # Mark the JSON column as modified so SQLAlchemy will save the changes
        flag_modified(meal_plan, 'meals')
        
        meal_plan.updated_at = datetime.utcnow()
        
        # Recalculate nutritional summaries
        self._recalculate_meal_plan_nutrition(meal_plan)
        
        # Remove from history
        self._remove_substitution_history(history)
        
        # Save changes
        db.session.commit()
        
        logger.info(f"Substitution undone successfully: {history.new_recipe_id} -> {history.original_recipe_id}")
        return meal_plan
    
    def _get_original_meal(self, request: SubstitutionRequest) -> Tuple[MealPlan, Dict[str, Any]]:
        """Get the original meal plan and specific meal"""
        meal_plan = db.session.query(MealPlan).filter_by(id=request.meal_plan_id, user_id=request.user_id).first()
        if not meal_plan:
            raise ValidationError("Meal plan not found")
        
        # Find meal by index (meal_id is treated as index)
        try:
            meal_index = int(request.meal_id)
            if meal_index < 0 or meal_index >= len(meal_plan.meals):
                raise ValidationError("Invalid meal index")
            original_meal = meal_plan.meals[meal_index]
        except (ValueError, IndexError):
            raise ValidationError("Invalid meal identifier")
        
        return meal_plan, original_meal
    
    def _get_recipe(self, recipe_id: str) -> Recipe:
        """Get recipe from database"""
        recipe = db.session.query(Recipe).filter_by(id=recipe_id, is_active=True).first()
        if not recipe:
            raise ValidationError("Recipe not found")
        return recipe
    
    def _get_user_preferences(self, user_id: str) -> Optional[Dict[str, Any]]:
        """Get user preferences from MongoDB"""
        if self.user_preferences_model is None:
            return None
        
        try:
            preferences = self.user_preferences_model.get_preferences(user_id)
            return preferences
        except Exception as e:
            logger.warning(f"Failed to get user preferences: {e}")
            return None
    
    def _analyze_meal_nutrition(self, recipe: Recipe) -> Dict[str, Any]:
        """Analyze nutritional profile of a meal to replace"""
        if not recipe.nutritional_info:
            return {
                'calories': 0,
                'protein': 0,
                'carbs': 0,
                'fat': 0,
                'prep_time': recipe.prep_time_minutes or 0,
                'cost_per_serving': recipe.cost_per_serving_usd or 0.0
            }
        
        return {
            'calories': recipe.nutritional_info.get('calories', 0),
            'protein': recipe.nutritional_info.get('protein', 0),
            'carbs': recipe.nutritional_info.get('carbs', 0),
            'fat': recipe.nutritional_info.get('fat', 0),
            'prep_time': recipe.prep_time_minutes or 0,
            'cost_per_serving': recipe.cost_per_serving_usd or 0.0
        }
    
    def _filter_recipes(self, meal_type: str, user_profile: Optional[Dict[str, Any]], 
                       exclude_recipe_id: str) -> List[Recipe]:
        """Filter recipes by same meal type and dietary restrictions"""
        query = db.session.query(Recipe).filter_by(meal_type=meal_type, is_active=True)
        
        # Exclude the original recipe
        query = query.filter(Recipe.id != exclude_recipe_id)
        
        candidates = query.all()
        
        # Apply dietary restrictions if available
        if user_profile and 'dietary_restrictions' in user_profile:
            dietary_restrictions = user_profile['dietary_restrictions']
            candidates = [r for r in candidates if r.matches_dietary_restrictions(dietary_restrictions)]
        
        return candidates
    
    def _calculate_substitution_score(self, candidate: Recipe, target_nutrition: Dict[str, Any],
                                    user_profile: Optional[Dict[str, Any]], original_recipe: Recipe) -> Dict[str, float]:
        """Calculate substitution score for a candidate recipe"""
        
        # Nutritional similarity score (40%)
        nutritional_similarity = self._nutrition_similarity_score(candidate, target_nutrition)
        
        # User preference score (30%)
        user_preference = self._user_preference_score(candidate, user_profile)
        
        # Cost efficiency score (20%)
        cost_efficiency = self._cost_efficiency_score(candidate, target_nutrition)
        
        # Preparation time match (10%)
        prep_time_match = self._prep_time_similarity(candidate, target_nutrition)
        
        # Calculate weighted total
        total_score = (
            nutritional_similarity * self.SCORING_WEIGHTS['nutritional_similarity'] +
            user_preference * self.SCORING_WEIGHTS['user_preference'] +
            cost_efficiency * self.SCORING_WEIGHTS['cost_efficiency'] +
            prep_time_match * self.SCORING_WEIGHTS['prep_time_match']
        )
        
        return {
            'total_score': total_score,
            'nutritional_similarity': nutritional_similarity,
            'user_preference': user_preference,
            'cost_efficiency': cost_efficiency,
            'prep_time_match': prep_time_match
        }
    
    def _nutrition_similarity_score(self, candidate: Recipe, target_nutrition: Dict[str, Any]) -> float:
        """Calculate nutritional similarity score (0-1)"""
        if not candidate.nutritional_info:
            return 0.5  # Neutral score for missing data
        
        target_calories = target_nutrition.get('calories', 0)
        candidate_calories = candidate.nutritional_info.get('calories', 0)
        
        if target_calories == 0 and candidate_calories == 0:
            return 1.0
        if target_calories == 0 or candidate_calories == 0:
            return 0.0
        
        # Calculate calorie similarity
        calorie_ratio = min(candidate_calories, target_calories) / max(candidate_calories, target_calories)
        
        # Calculate macro similarity
        target_protein = target_nutrition.get('protein', 0)
        target_carbs = target_nutrition.get('carbs', 0)
        target_fat = target_nutrition.get('fat', 0)
        
        candidate_protein = candidate.nutritional_info.get('protein', 0)
        candidate_carbs = candidate.nutritional_info.get('carbs', 0)
        candidate_fat = candidate.nutritional_info.get('fat', 0)
        
        macro_similarity = 0.5  # Default if no macro data
        if target_protein + target_carbs + target_fat > 0:
            protein_ratio = min(candidate_protein, target_protein) / max(candidate_protein, target_protein) if target_protein > 0 else 1.0
            carb_ratio = min(candidate_carbs, target_carbs) / max(candidate_carbs, target_carbs) if target_carbs > 0 else 1.0
            fat_ratio = min(candidate_fat, target_fat) / max(candidate_fat, target_fat) if target_fat > 0 else 1.0
            
            macro_similarity = (protein_ratio + carb_ratio + fat_ratio) / 3
        
        return (calorie_ratio * 0.6 + macro_similarity * 0.4)
    
    def _user_preference_score(self, candidate: Recipe, user_profile: Optional[Dict[str, Any]]) -> float:
        """Calculate user preference score based on cuisine preferences and ingredient likes/dislikes"""
        if not user_profile:
            return 0.5  # Neutral score
        
        score = 0.5  # Base score
        
        # Cuisine preference bonus/penalty
        if 'cuisine_preferences' in user_profile and candidate.cuisine_type:
            cuisine_prefs = user_profile['cuisine_preferences']
            if candidate.cuisine_type in cuisine_prefs:
                cuisine_rating = cuisine_prefs[candidate.cuisine_type]
                score += (cuisine_rating - 3) * 0.1  # Scale 1-5 rating to ±0.2 adjustment
        
        # Ingredient preferences
        if 'ingredient_preferences' in user_profile:
            ingredient_prefs = user_profile['ingredient_preferences']
            liked_ingredients = ingredient_prefs.get('liked', [])
            disliked_ingredients = ingredient_prefs.get('disliked', [])
            
            recipe_text = f"{candidate.name} {str(candidate.ingredients)}".lower()
            
            # Bonus for liked ingredients
            for ingredient in liked_ingredients:
                if ingredient.lower() in recipe_text:
                    score += 0.1
            
            # Penalty for disliked ingredients
            for ingredient in disliked_ingredients:
                if ingredient.lower() in recipe_text:
                    score -= 0.2
        
        # Use preference learning service if available
        if self.preference_service:
            try:
                pref_score = self.preference_service.get_recipe_preference_score(
                    user_profile.get('user_id', ''), str(candidate.id)
                )
                if pref_score is not None:
                    score = (score + pref_score) / 2  # Average with preference learning score
            except Exception as e:
                logger.warning(f"Could not get preference score: {e}")
        
        return max(0.0, min(1.0, score))  # Clamp to 0-1 range
    
    def _cost_efficiency_score(self, candidate: Recipe, target_nutrition: Dict[str, Any]) -> float:
        """Calculate cost efficiency score - similar cost per serving"""
        target_cost = target_nutrition.get('cost_per_serving', 0.0)
        candidate_cost = candidate.cost_per_serving_usd or 0.0
        
        if target_cost == 0 and candidate_cost == 0:
            return 1.0
        if target_cost == 0 or candidate_cost == 0:
            return 0.5
        
        # Calculate cost similarity
        cost_ratio = min(candidate_cost, target_cost) / max(candidate_cost, target_cost)
        return cost_ratio
    
    def _prep_time_similarity(self, candidate: Recipe, target_nutrition: Dict[str, Any]) -> float:
        """Calculate preparation time similarity"""
        target_time = target_nutrition.get('prep_time', 0)
        candidate_time = candidate.total_time_minutes or 0
        
        if target_time == 0 and candidate_time == 0:
            return 1.0
        if target_time == 0 or candidate_time == 0:
            return 0.5
        
        # Calculate time similarity with tolerance
        time_diff = abs(candidate_time - target_time)
        max_diff = max(target_time, candidate_time)
        
        similarity = max(0, 1 - (time_diff / max_diff))
        return similarity
    
    def _within_nutritional_tolerance(self, original: Recipe, candidate: Recipe, tolerance: float) -> bool:
        """Check if candidate is within nutritional tolerance of original"""
        if not original.nutritional_info or not candidate.nutritional_info:
            return True  # Allow if no nutritional data
        
        original_calories = original.nutritional_info.get('calories', 0)
        candidate_calories = candidate.nutritional_info.get('calories', 0)
        
        if original_calories == 0:
            return True
        
        calorie_diff = abs(candidate_calories - original_calories) / original_calories
        return calorie_diff <= tolerance
    
    def _calculate_substitution_impact(self, original_meal: Recipe, substitute_meal: Recipe, 
                                     meal_plan: MealPlan, user_id: str) -> Dict[str, Any]:
        """Calculate the impact of substitution on daily/weekly nutritional goals"""
        
        # Calculate nutritional changes
        original_nutrition = original_meal.nutritional_info or {}
        substitute_nutrition = substitute_meal.nutritional_info or {}
        
        calorie_change = substitute_nutrition.get('calories', 0) - original_nutrition.get('calories', 0)
        protein_change = substitute_nutrition.get('protein', 0) - original_nutrition.get('protein', 0)
        carb_change = substitute_nutrition.get('carbs', 0) - original_nutrition.get('carbs', 0)
        fat_change = substitute_nutrition.get('fat', 0) - original_nutrition.get('fat', 0)
        
        # Calculate cost change
        cost_change = (substitute_meal.cost_per_serving_usd or 0.0) - (original_meal.cost_per_serving_usd or 0.0)
        
        # Calculate new daily totals
        current_nutrition = meal_plan.total_nutrition_summary or {}
        new_daily_totals = {
            'calories': current_nutrition.get('calories', 0) + calorie_change,
            'protein': current_nutrition.get('protein', 0) + protein_change,
            'carbs': current_nutrition.get('carbs', 0) + carb_change,
            'fat': current_nutrition.get('fat', 0) + fat_change
        }
        
        # Determine impact level
        impact_level = 'minimal'  # minimal, moderate, significant
        if abs(calorie_change) > 200:  # More than 200 calorie change
            impact_level = 'significant'
        elif abs(calorie_change) > 100:  # More than 100 calorie change
            impact_level = 'moderate'
        
        return {
            'changes': {
                'calories': calorie_change,
                'protein': protein_change,
                'carbs': carb_change,
                'fat': fat_change,
                'cost': cost_change
            },
            'new_totals': new_daily_totals,
            'impact_level': impact_level,
            'cost_change_usd': cost_change
        }
    
    def _recalculate_meal_plan_nutrition(self, meal_plan: MealPlan):
        """Recalculate nutritional summaries after substitution"""
        total_nutrition = {'calories': 0, 'protein': 0, 'carbs': 0, 'fat': 0}
        total_cost = 0
        
        for meal in meal_plan.meals:
            recipe = self._get_recipe(meal['recipe_id'])
            if recipe.nutritional_info:
                total_nutrition['calories'] += recipe.nutritional_info.get('calories', 0)
                total_nutrition['protein'] += recipe.nutritional_info.get('protein', 0)
                total_nutrition['carbs'] += recipe.nutritional_info.get('carbs', 0)
                total_nutrition['fat'] += recipe.nutritional_info.get('fat', 0)
            
            if recipe.estimated_cost_usd:
                total_cost += recipe.estimated_cost_usd
        
        meal_plan.total_nutrition_summary = total_nutrition
        meal_plan.estimated_total_cost_usd = total_cost
    
    def _record_substitution_history(self, meal_plan_id: str, meal_index: int, 
                                   original_recipe_id: str, new_recipe_id: str, user_id: str):
        """Record substitution history for undo functionality"""
        # For simplicity, we'll store this in the meal plan's generation_parameters
        # In a production system, you might want a separate table for this
        meal_plan = db.session.query(MealPlan).filter_by(id=meal_plan_id).first()
        if meal_plan:
            if not meal_plan.generation_parameters:
                meal_plan.generation_parameters = {}
            
            if 'substitution_history' not in meal_plan.generation_parameters:
                meal_plan.generation_parameters['substitution_history'] = []
            
            meal_plan.generation_parameters['substitution_history'].append({
                'meal_index': meal_index,
                'original_recipe_id': original_recipe_id,
                'new_recipe_id': new_recipe_id,
                'timestamp': datetime.utcnow().isoformat(),
                'user_id': user_id
            })
    
    def _get_recent_substitution_history(self, meal_plan_id: str, user_id: str) -> Optional[SubstitutionHistory]:
        """Get the most recent substitution history"""
        meal_plan = db.session.query(MealPlan).filter_by(id=meal_plan_id, user_id=user_id).first()
        if not meal_plan or not meal_plan.generation_parameters:
            return None
        
        history = meal_plan.generation_parameters.get('substitution_history', [])
        if not history:
            return None
        
        # Get most recent substitution
        recent = history[-1]
        return SubstitutionHistory(
            meal_plan_id=meal_plan_id,
            meal_index=recent['meal_index'],
            original_recipe_id=recent['original_recipe_id'],
            new_recipe_id=recent['new_recipe_id'],
            timestamp=datetime.fromisoformat(recent['timestamp']),
            user_id=recent['user_id']
        )
    
    def _remove_substitution_history(self, history: SubstitutionHistory):
        """Remove substitution from history after undo"""
        meal_plan = db.session.query(MealPlan).filter_by(id=history.meal_plan_id).first()
        if meal_plan and meal_plan.generation_parameters:
            substitutions = meal_plan.generation_parameters.get('substitution_history', [])
            # Remove the most recent substitution
            if substitutions:
                substitutions.pop()
                meal_plan.generation_parameters['substitution_history'] = substitutions 