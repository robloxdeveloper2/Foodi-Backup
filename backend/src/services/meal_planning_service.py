"""
Meal Planning Service
Implements algorithm-based meal plan generation with scoring system
"""

import logging
from datetime import date, datetime, timedelta
from typing import Optional, List, Dict, Any, Tuple
import random
from dataclasses import dataclass

from core.models.user import User
from core.models.user_preferences import UserPreferences
from core.models.recipe import Recipe
from core.models.meal_plan import MealPlan
from core.exceptions import ValidationError, AppError
from data_access.database import db
from services.preference_learning_service import PreferenceLearningService

logger = logging.getLogger(__name__)

@dataclass
class MealPlanGenerationRequest:
    """Request parameters for meal plan generation"""
    user_id: str
    duration_days: int = 1  # 1-7 days
    plan_date: Optional[date] = None  # Default to today
    budget_usd: Optional[float] = None  # Override user's budget setting
    include_snacks: bool = False
    force_regenerate: bool = False  # Regenerate even if recent plan exists
    
    def __post_init__(self):
        if not 1 <= self.duration_days <= 7:
            raise ValidationError("Duration must be between 1 and 7 days")
        
        if self.plan_date is None:
            self.plan_date = date.today()

@dataclass
class RecipeScore:
    """Scoring result for a recipe"""
    recipe: Recipe
    total_score: float
    cost_score: float
    nutrition_score: float
    variety_score: float
    difficulty_score: float
    preference_score: float = 0.0  # New field for preference learning

class MealPlanningService:
    """Service for generating algorithmic meal plans"""
    
    ALGORITHM_VERSION = "v1.0.0"
    
    # Meal type calorie distribution (typical percentages)
    MEAL_CALORIE_DISTRIBUTION = {
        'breakfast': 0.25,
        'lunch': 0.35, 
        'dinner': 0.35,
        'snack': 0.05
    }
    
    # Updated scoring weights to include preference learning
    SCORING_WEIGHTS = {
        'cost_efficiency': 0.25,    # Reduced from 0.30
        'nutritional_fit': 0.30,    # Reduced from 0.35 
        'variety': 0.15,            # Reduced from 0.20
        'difficulty_match': 0.10,   # Reduced from 0.15
        'user_preferences': 0.20    # New - from preference learning
    }
    
    def __init__(self):
        try:
            self.user_preferences_model = UserPreferences()
        except Exception as e:
            logger.warning(f"MongoDB not available, proceeding without user preferences: {e}")
            self.user_preferences_model = None
        
        # Initialize preference learning service
        try:
            self.preference_service = PreferenceLearningService()
        except Exception as e:
            logger.warning(f"Could not initialize preference learning service: {e}")
            self.preference_service = None
        
    def generate_meal_plan(self, request: MealPlanGenerationRequest) -> MealPlan:
        """
        Generate a meal plan using the constraint satisfaction algorithm
        
        Main Algorithm:
        1. Filter recipes by dietary restrictions
        2. Calculate daily calorie target based on user goals
        3. Score recipes by: cost efficiency, nutritional fit, cuisine variety
        4. Use constraint satisfaction to select optimal combination
        5. Ensure meal type distribution (breakfast/lunch/dinner)
        6. Apply variety rules (no repeated recipes in same week)
        """
        logger.info(f"Starting meal plan generation for user {request.user_id}, {request.duration_days} days")
        
        # Step 1: Load user data and preferences
        user = self._get_user(request.user_id)
        user_preferences = self._get_user_preferences(request.user_id)
        
        # Step 2: Calculate nutritional targets
        nutritional_targets = self._calculate_nutritional_targets(user, user_preferences)
        nutritional_targets['user_id'] = request.user_id  # Add user_id for preference scoring
        
        # Step 3: Determine budget constraints
        budget_constraint = self._determine_budget_constraint(request, user_preferences)
        
        # Step 4: Filter and score recipes
        candidate_recipes = self._get_candidate_recipes(user, user_preferences)
        
        # If no candidate recipes found, abort
        if not candidate_recipes:
            logger.error("No candidate recipes found - cannot generate meal plan")
            raise ValidationError("No recipes available for meal plan generation")
        
        scored_recipes = self._score_recipes(
            candidate_recipes, 
            nutritional_targets, 
            budget_constraint,
            user_preferences
        )
        
        # Step 5: Generate meal plan using constraint satisfaction
        selected_meals = self._select_optimal_meals(
            scored_recipes,
            request.duration_days,
            nutritional_targets,
            budget_constraint,
            request.include_snacks,
            candidate_recipes  # Pass candidate recipes for fallback
        )
        
        # Step 6: Calculate nutritional summaries and costs
        nutrition_summary, cost_summary = self._calculate_plan_summaries(selected_meals, candidate_recipes)
        
        # Step 7: Create and save meal plan
        meal_plan = self._create_meal_plan(
            request, user, selected_meals, nutrition_summary, cost_summary,
            user_preferences.get_preferences(request.user_id) if user_preferences else {}
        )
        
        logger.info(f"Meal plan generated successfully: {meal_plan.id}")
        return meal_plan
    
    def regenerate_meal_plan(self, user_id: str, plan_id: str) -> MealPlan:
        """Regenerate an existing meal plan with slight variations"""
        original_plan = db.session.query(MealPlan).filter_by(id=plan_id, user_id=user_id).first()
        if not original_plan:
            raise ValidationError("Original meal plan not found")
        
        # Create new request based on original plan
        request = MealPlanGenerationRequest(
            user_id=user_id,
            duration_days=original_plan.duration_days,
            plan_date=original_plan.plan_date,
            budget_usd=original_plan.budget_target_usd / 100.0 if original_plan.budget_target_usd else None,
            include_snacks=any(meal.get('meal_type') == 'snack' for meal in original_plan.meals),
            force_regenerate=True
        )
        
        return self.generate_meal_plan(request)
    
    def _get_user(self, user_id: str) -> User:
        """Get user from database"""
        user = db.session.query(User).filter_by(id=user_id).first()
        if not user:
            raise ValidationError("User not found")
        return user
    
    def _get_user_preferences(self, user_id: str) -> Optional[Dict[str, Any]]:
        """Get user preferences from MongoDB"""
        if self.user_preferences_model is None:
            return None
        if hasattr(self.user_preferences_model, 'collection') and self.user_preferences_model.collection is None:
            return None
        try:
            preferences = self.user_preferences_model.get_preferences(user_id)
            # Add user_id to preferences for use in scoring
            if preferences:
                preferences['user_id'] = user_id
            return preferences
        except Exception as e:
            logger.warning(f"Failed to get user preferences: {e}")
            return None
    
    def _calculate_nutritional_targets(self, user: User, preferences: Optional[Dict[str, Any]]) -> Dict[str, Any]:
        """Calculate daily nutritional targets based on user goals"""
        targets = {
            'daily_calories': 2000,  # Default
            'protein_pct': 20,
            'carb_pct': 50, 
            'fat_pct': 30
        }
        
        # Use user's nutritional goals if available
        if user.nutritional_goals:
            targets.update({
                'daily_calories': user.nutritional_goals.get('daily_calorie_target', targets['daily_calories']),
                'protein_pct': user.nutritional_goals.get('protein_target_pct', targets['protein_pct']),
                'carb_pct': user.nutritional_goals.get('carb_target_pct', targets['carb_pct']),
                'fat_pct': user.nutritional_goals.get('fat_target_pct', targets['fat_pct'])
            })
        
        # Use MongoDB preferences if available
        if preferences and 'nutritional_goals' in preferences:
            mongo_goals = preferences['nutritional_goals']
            targets.update({
                'daily_calories': mongo_goals.get('daily_calorie_target', targets['daily_calories']),
                'protein_pct': mongo_goals.get('protein_target_pct', targets['protein_pct']),
                'carb_pct': mongo_goals.get('carb_target_pct', targets['carb_pct']),
                'fat_pct': mongo_goals.get('fat_target_pct', targets['fat_pct'])
            })
        
        return targets
    
    def _determine_budget_constraint(self, request: MealPlanGenerationRequest, 
                                   preferences: Optional[Dict[str, Any]]) -> Optional[float]:
        """Determine budget constraint in USD per day"""
        if request.budget_usd:
            return request.budget_usd / request.duration_days
        
        if preferences and 'budget_info' in preferences:
            budget_info = preferences['budget_info']
            if budget_info.get('amount') and budget_info.get('period'):
                amount = budget_info['amount']
                period = budget_info['period']
                
                # Convert to daily budget
                if period == 'weekly':
                    return amount / 7
                elif period == 'monthly':
                    return amount / 30
                elif period == 'daily':
                    return amount
        
        return None  # No budget constraint
    
    def _get_candidate_recipes(self, user: User, preferences: Optional[Dict[str, Any]]) -> List[Recipe]:
        """Get recipes that match user's dietary restrictions"""
        # Use the repository instead of direct DB queries for consistency
        from data_access.recipe_repository import RecipeRepository
        
        # Create repository with current session
        recipe_repo = RecipeRepository(session=db.session)
        
        # Get dietary restrictions from multiple sources
        dietary_restrictions = set()
        
        # From User model
        if user.dietary_restrictions_list:
            dietary_restrictions.update(user.dietary_restrictions_list)
        
        # From MongoDB preferences
        if preferences and 'preferences' in preferences:
            prefs = preferences['preferences']
            if 'dietary_restrictions' in prefs:
                dietary_restrictions.update(prefs['dietary_restrictions'])
        
        # Debug: Check database connection
        try:
            recipe_count = recipe_repo.get_recipe_count()
            logger.info(f"Recipe count check: {recipe_count} recipes in database")
        except Exception as e:
            logger.error(f"Failed to get recipe count: {e}")
        
        # Get all active recipes using the repository
        all_recipes = recipe_repo.get_all_active_recipes()
        logger.info(f"Repository returned {len(all_recipes)} total recipes")
        
        if len(all_recipes) == 0:
            logger.error("No recipes found - this suggests a database issue")
            # Try direct database query as fallback
            try:
                direct_count = db.session.query(Recipe).filter(Recipe.is_active == True).count()
                logger.info(f"Direct DB query count: {direct_count}")
                
                if direct_count > 0:
                    direct_recipes = db.session.query(Recipe).filter(Recipe.is_active == True).all()
                    logger.info(f"Direct DB query returned {len(direct_recipes)} recipes")
                    all_recipes = direct_recipes
                else:
                    logger.error("Direct DB query also found 0 recipes")
            except Exception as e:
                logger.error(f"Direct DB query failed: {e}")
        
        # Filter by dietary restrictions
        if dietary_restrictions:
            filtered_recipes = [
                recipe for recipe in all_recipes 
                if recipe.matches_dietary_restrictions(list(dietary_restrictions))
            ]
            logger.info(f"After dietary filtering: {len(filtered_recipes)} recipes (restrictions: {list(dietary_restrictions)})")
        else:
            filtered_recipes = all_recipes
            logger.info(f"No dietary restrictions, using all {len(filtered_recipes)} recipes")
        
        logger.info(f"Found {len(filtered_recipes)} candidate recipes after dietary filtering")
        return filtered_recipes
    
    def _score_recipes(self, recipes: List[Recipe], nutritional_targets: Dict[str, Any],
                      budget_constraint: Optional[float], preferences: Optional[Dict[str, Any]]) -> List[RecipeScore]:
        """Score recipes based on multiple factors including preference learning"""
        scored_recipes = []
        
        # Get user_id from preferences for preference learning
        user_id = None
        if preferences and 'user_id' in preferences:
            user_id = preferences['user_id']
        
        for recipe in recipes:
            # Calculate individual scores
            cost_score = self._calculate_cost_score(recipe, budget_constraint)
            nutrition_score = self._calculate_nutrition_score(recipe, nutritional_targets)
            variety_score = self._calculate_variety_score(recipe, preferences)
            difficulty_score = self._calculate_difficulty_score(recipe, preferences)
            preference_score = self._calculate_preference_score(recipe, user_id)
            
            # Calculate weighted total score including preference learning
            total_score = (
                cost_score * self.SCORING_WEIGHTS['cost_efficiency'] +
                nutrition_score * self.SCORING_WEIGHTS['nutritional_fit'] +
                variety_score * self.SCORING_WEIGHTS['variety'] +
                difficulty_score * self.SCORING_WEIGHTS['difficulty_match'] +
                preference_score * self.SCORING_WEIGHTS['user_preferences']
            )
            
            scored_recipes.append(RecipeScore(
                recipe=recipe,
                total_score=total_score,
                cost_score=cost_score,
                nutrition_score=nutrition_score,
                variety_score=variety_score,
                difficulty_score=difficulty_score,
                preference_score=preference_score
            ))
        
        # Sort by total score (highest first)
        scored_recipes.sort(key=lambda x: x.total_score, reverse=True)
        
        return scored_recipes
    
    def _calculate_cost_score(self, recipe: Recipe, budget_constraint: Optional[float]) -> float:
        """Calculate cost efficiency score (0-1)"""
        if not recipe.cost_per_serving_usd:
            return 0.5  # Neutral score for missing cost data
        
        if not budget_constraint:
            return 0.8  # Good score when no budget constraint
        
        # Score based on how well the recipe fits within budget
        cost_ratio = recipe.cost_per_serving_usd / budget_constraint
        
        if cost_ratio <= 0.5:
            return 1.0  # Excellent - very affordable
        elif cost_ratio <= 1.0:
            return 0.8  # Good - within budget
        elif cost_ratio <= 1.5:
            return 0.4  # Fair - slightly over budget
        else:
            return 0.1  # Poor - significantly over budget
    
    def _calculate_nutrition_score(self, recipe: Recipe, targets: Dict[str, Any]) -> float:
        """Calculate nutritional alignment score"""
        meal_calorie_target = targets['daily_calories'] * self.MEAL_CALORIE_DISTRIBUTION.get(recipe.meal_type, 0.33)
        
        return recipe.calculate_nutrition_score(
            target_calories=meal_calorie_target,
            target_protein_pct=targets['protein_pct'],
            target_carb_pct=targets['carb_pct'],
            target_fat_pct=targets['fat_pct']
        )
    
    def _calculate_variety_score(self, recipe: Recipe, preferences: Optional[Dict[str, Any]]) -> float:
        """Calculate variety/cuisine preference score"""
        base_score = 0.5
        
        if not preferences or 'preferences' not in preferences:
            return base_score
        
        user_prefs = preferences['preferences']
        
        # Bonus for favorite cuisines
        favorite_cuisines = user_prefs.get('favorite_cuisines', [])
        if recipe.cuisine_type and recipe.cuisine_type.lower() in [c.lower() for c in favorite_cuisines]:
            base_score += 0.3
        
        # Penalty for disliked ingredients (simple check)
        disliked_ingredients = user_prefs.get('disliked_ingredients', [])
        if disliked_ingredients and recipe.ingredients:
            recipe_text = str(recipe.ingredients).lower()
            if any(ingredient.lower() in recipe_text for ingredient in disliked_ingredients):
                base_score -= 0.2
        
        return max(0.0, min(1.0, base_score))
    
    def _calculate_difficulty_score(self, recipe: Recipe, preferences: Optional[Dict[str, Any]]) -> float:
        """Calculate difficulty match score based on user's cooking experience"""
        if not preferences or 'cooking_profile' not in preferences:
            return 0.5  # Neutral score
        
        cooking_profile = preferences['cooking_profile']
        user_experience = cooking_profile.get('experience_level', 'intermediate')
        
        recipe_difficulty = recipe.difficulty_level or 'medium'
        
        # Score based on experience vs difficulty match
        difficulty_map = {'easy': 1, 'medium': 2, 'hard': 3}
        experience_map = {'beginner': 1, 'intermediate': 2, 'advanced': 3}
        
        recipe_level = difficulty_map.get(recipe_difficulty.lower(), 2)
        user_level = experience_map.get(user_experience.lower(), 2)
        
        # Perfect match gets highest score
        if recipe_level == user_level:
            return 1.0
        elif abs(recipe_level - user_level) == 1:
            return 0.7
        else:
            return 0.3
    
    def _calculate_preference_score(self, recipe: Recipe, user_id: Optional[str]) -> float:
        """Calculate preference score based on user's swipe history and ratings"""
        if not user_id or not self.preference_service:
            return 0.5  # Neutral score when no preference data available
        
        try:
            preference_score = self.preference_service.calculate_preference_score(
                user_id=user_id,
                recipe=recipe
            )
            
            # Convert to 0-1 scale if needed
            if preference_score > 1:
                preference_score = preference_score / 100.0
            
            # Ensure score is in valid range
            return max(0.0, min(1.0, preference_score))
            
        except Exception as e:
            logger.warning(f"Could not calculate preference score for recipe {recipe.id}: {e}")
            return 0.5  # Neutral score on error
    
    def _select_optimal_meals(self, scored_recipes: List[RecipeScore], duration_days: int,
                             nutritional_targets: Dict[str, Any], budget_constraint: Optional[float],
                             include_snacks: bool, candidate_recipes: List[Recipe]) -> List[Dict[str, Any]]:
        """Use constraint satisfaction to select optimal meal combination"""
        selected_meals = []
        used_recipes = set()  # Track used recipes for variety
        
        meal_types = ['breakfast', 'lunch', 'dinner']
        if include_snacks:
            meal_types.append('snack')
        
        logger.info(f"Starting meal selection for {duration_days} days with {len(scored_recipes)} scored recipes")
        logger.info(f"Meal types to select: {meal_types}")
        
        # If no scored recipes, try to get recipes directly (fallback)
        if not scored_recipes:
            logger.warning("No scored recipes available, trying direct recipe access")
            
            # Get user_id for preference scoring in fallback
            user_id = None
            if nutritional_targets and 'user_id' in nutritional_targets:
                user_id = nutritional_targets['user_id']
            
            # Create basic scores for fallback
            scored_recipes = []
            for recipe in candidate_recipes:
                preference_score = self._calculate_preference_score(recipe, user_id)
                scored_recipes.append(RecipeScore(
                    recipe=recipe,
                    total_score=preference_score,  # Use preference score as primary fallback
                    cost_score=0.5,
                    nutrition_score=0.5,
                    variety_score=0.5,
                    difficulty_score=0.5,
                    preference_score=preference_score
                ))
        
        for day in range(1, duration_days + 1):
            for meal_type in meal_types:
                # Get candidates for this meal type
                candidates = [
                    score for score in scored_recipes 
                    if score.recipe.meal_type == meal_type
                ]
                
                logger.info(f"Day {day}, {meal_type}: Found {len(candidates)} candidates")
                
                if not candidates:
                    logger.warning(f"No recipes found for meal type: {meal_type}")
                    continue
                
                # Apply variety constraint (prefer unused recipes)
                preferred_candidates = [c for c in candidates if c.recipe.id not in used_recipes]
                if preferred_candidates:
                    candidates = preferred_candidates
                    logger.info(f"Day {day}, {meal_type}: Using {len(preferred_candidates)} unused recipes")
                else:
                    logger.info(f"Day {day}, {meal_type}: All recipes already used, reusing from {len(candidates)} candidates")
                
                # Simple selection: just pick the first (highest scored) available recipe
                selected_score = candidates[0]
                logger.info(f"Day {day}, {meal_type}: Selected: {selected_score.recipe.name} "
                           f"(total: {selected_score.total_score:.3f}, "
                           f"preference: {selected_score.preference_score:.3f}, "
                           f"nutrition: {selected_score.nutrition_score:.3f}, "
                           f"cost: {selected_score.cost_score:.3f})")
                
                # Calculate cost with fallback
                recipe_cost = selected_score.recipe.cost_per_serving_usd
                if recipe_cost is None or recipe_cost == 0:
                    # Fallback cost based on meal type
                    fallback_costs = {
                        'breakfast': 3.50,
                        'lunch': 5.00,
                        'dinner': 7.50,
                        'snack': 2.00
                    }
                    recipe_cost = fallback_costs.get(meal_type, 5.00)
                    logger.info(f"Using fallback cost ${recipe_cost:.2f} for {meal_type} recipe {selected_score.recipe.name}")
                else:
                    logger.info(f"Using actual cost ${recipe_cost:.2f} for {meal_type} recipe {selected_score.recipe.name}")

                selected_meals.append({
                    'day': day,
                    'meal_type': meal_type,
                    'recipe_id': str(selected_score.recipe.id),
                    'recipe_name': selected_score.recipe.name,
                    'score': selected_score.total_score,
                    'estimated_cost_usd': recipe_cost
                })
                
                used_recipes.add(selected_score.recipe.id)
        
        logger.info(f"Selected {len(selected_meals)} total meals")
        return selected_meals
    
    def _calculate_plan_summaries(self, selected_meals: List[Dict[str, Any]], 
                                 recipes: List[Recipe]) -> Tuple[Dict[str, Any], Dict[str, Any]]:
        """Calculate nutritional and cost summaries for the meal plan"""
        # Create recipe lookup
        recipe_lookup = {str(recipe.id): recipe for recipe in recipes}
        
        total_nutrition = {'calories': 0, 'protein': 0, 'carbs': 0, 'fat': 0}
        total_cost = 0
        daily_breakdown = {}
        
        for meal in selected_meals:
            recipe_id = meal['recipe_id']
            day = meal['day']
            
            recipe = recipe_lookup.get(recipe_id)
            if not recipe:
                continue
            
            # Add to totals
            if recipe.nutritional_info:
                for nutrient in total_nutrition:
                    total_nutrition[nutrient] += recipe.nutritional_info.get(nutrient, 0)
            
            if recipe.estimated_cost_usd:
                total_cost += recipe.estimated_cost_usd
            
            # Track daily breakdown
            if day not in daily_breakdown:
                daily_breakdown[day] = {'calories': 0, 'protein': 0, 'carbs': 0, 'fat': 0, 'cost': 0}
            
            if recipe.nutritional_info:
                for nutrient in ['calories', 'protein', 'carbs', 'fat']:
                    daily_breakdown[day][nutrient] += recipe.nutritional_info.get(nutrient, 0)
            
            if recipe.estimated_cost_usd:
                daily_breakdown[day]['cost'] += recipe.estimated_cost_usd
        
        nutrition_summary = total_nutrition
        cost_summary = {
            'total_cost_cents': total_cost,
            'total_cost_usd': total_cost / 100.0 if total_cost else 0,
            'daily_breakdown': daily_breakdown
        }
        
        return nutrition_summary, cost_summary
    
    def _create_meal_plan(self, request: MealPlanGenerationRequest, user: User,
                         selected_meals: List[Dict[str, Any]], nutrition_summary: Dict[str, Any],
                         cost_summary: Dict[str, Any], user_preferences: Dict[str, Any]) -> MealPlan:
        """Create and save the meal plan"""
        # Determine dietary restrictions used
        dietary_restrictions = set()
        if user.dietary_restrictions_list:
            dietary_restrictions.update(user.dietary_restrictions_list)
        if user_preferences and 'preferences' in user_preferences:
            prefs = user_preferences['preferences']
            if 'dietary_restrictions' in prefs:
                dietary_restrictions.update(prefs['dietary_restrictions'])
        
        # Calculate budget target
        budget_target_cents = None
        if request.budget_usd:
            budget_target_cents = int(request.budget_usd * 100)
        
        meal_plan = MealPlan(
            user_id=request.user_id,
            plan_date=request.plan_date,
            duration_days=request.duration_days,
            meals=selected_meals,
            total_nutrition_summary=nutrition_summary,
            daily_nutrition_breakdown=cost_summary['daily_breakdown'],
            generated_by_ai=True,
            generation_parameters={
                'algorithm_version': self.ALGORITHM_VERSION,
                'include_snacks': request.include_snacks,
                'budget_constraint': request.budget_usd,
                'generation_timestamp': datetime.utcnow().isoformat()
            },
            algorithm_version=self.ALGORITHM_VERSION,
            estimated_total_cost_usd=cost_summary['total_cost_cents'],
            budget_target_usd=budget_target_cents,
            dietary_restrictions_used=list(dietary_restrictions)
        )
        
        # Save to database
        db.session.add(meal_plan)
        db.session.commit()
        
        return meal_plan 