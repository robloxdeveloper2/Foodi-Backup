"""
Meal Substitution API Endpoints
Provides intelligent meal substitution functionality
"""

import logging
from flask import Blueprint, request, jsonify, g
from flask_jwt_extended import jwt_required, get_jwt_identity

from services.meal_substitution_service import MealSubstitutionService, SubstitutionRequest
from api.schemas.meal_substitution_schemas import (
    SubstitutionRequestSchema, SubstitutesResponseSchema, 
    ApplySubstitutionRequestSchema, ApplySubstitutionResponseSchema,
    UndoSubstitutionResponseSchema, SubstitutionCandidateSchema,
    SubstitutionImpactSchema, SubstitutionHistoryResponseSchema
)
from core.exceptions import ValidationError, AppError

# Create blueprint
meal_substitution_bp = Blueprint('meal_substitution', __name__, url_prefix='/api/v1')
logger = logging.getLogger(__name__)

# Initialize service
substitution_service = MealSubstitutionService()

@meal_substitution_bp.route('/meal-plans/<meal_plan_id>/substitutes/<meal_id>', methods=['GET'])
@jwt_required()
def get_meal_substitutes(meal_plan_id: str, meal_id: str):
    """
    Get substitute meal suggestions for a specific meal in a meal plan
    
    AC 2.4.2: System suggests 3-5 alternative meals using smart matching algorithm
    AC 2.4.3: Alternatives maintain similar nutritional profile (±15% calories, similar macros)
    AC 2.4.4: Substitutions respect same dietary restrictions and budget constraints
    AC 2.4.6: Algorithm prioritizes user's preferred cuisines and ingredients
    """
    try:
        user_id = get_jwt_identity()
        logger.info(f"Getting meal substitutes for user {user_id}, meal plan {meal_plan_id}, meal {meal_id}")
        
        # Parse query parameters
        args = request.args
        max_alternatives = int(args.get('max_alternatives', 5))
        nutritional_tolerance = float(args.get('nutritional_tolerance', 0.15))
        
        # Validate request parameters
        request_schema = SubstitutionRequestSchema(
            max_alternatives=max_alternatives,
            nutritional_tolerance=nutritional_tolerance
        )
        
        # Create substitution request
        substitution_request = SubstitutionRequest(
            meal_plan_id=meal_plan_id,
            meal_id=meal_id,
            user_id=user_id,
            max_alternatives=request_schema.max_alternatives,
            nutritional_tolerance=request_schema.nutritional_tolerance
        )
        
        # Find substitutes
        candidates = substitution_service.find_substitutes(substitution_request)
        
        # Get original meal information for response
        meal_plan, original_meal = substitution_service._get_original_meal(substitution_request)
        original_recipe = substitution_service._get_recipe(original_meal['recipe_id'])
        
        # Format candidates for response
        alternatives = []
        for candidate in candidates:
            alternatives.append({
                'recipe_id': str(candidate.recipe.id),
                'recipe_name': candidate.recipe.name,
                'cuisine_type': candidate.recipe.cuisine_type,
                'prep_time_minutes': candidate.recipe.prep_time_minutes,
                'cook_time_minutes': candidate.recipe.cook_time_minutes,
                'total_time_minutes': candidate.recipe.total_time_minutes,
                'nutritional_info': candidate.recipe.nutritional_info,
                'estimated_cost_usd': candidate.recipe.cost_per_serving_usd,
                'difficulty_level': candidate.recipe.difficulty_level,
                'total_score': candidate.total_score,
                'nutritional_similarity': candidate.nutritional_similarity,
                'user_preference': candidate.user_preference,
                'cost_efficiency': candidate.cost_efficiency,
                'prep_time_match': candidate.prep_time_match,
                'substitution_impact': candidate.substitution_impact
            })
        
        response_data = {
            'meal_plan_id': meal_plan_id,
            'meal_index': int(meal_id),
            'original_recipe': original_recipe.to_dict(),
            'alternatives': alternatives,
            'total_found': len(candidates)
        }
        
        logger.info(f"Found {len(candidates)} substitutes for meal {meal_id}")
        return jsonify(response_data), 200
        
    except ValidationError as e:
        logger.warning(f"Validation error in get_meal_substitutes: {e}")
        return jsonify({'error': str(e)}), 400
    except AppError as e:
        logger.error(f"Application error in get_meal_substitutes: {e}")
        return jsonify({'error': str(e)}), 500
    except Exception as e:
        logger.error(f"Unexpected error in get_meal_substitutes: {e}")
        return jsonify({'error': 'Internal server error'}), 500

@meal_substitution_bp.route('/meal-plans/<meal_plan_id>/substitute', methods=['PUT'])
@jwt_required()
def apply_meal_substitution(meal_plan_id: str):
    """
    Apply a meal substitution to a meal plan
    
    AC 2.4.7: User can preview and confirm substitution before applying
    AC 2.4.5: System shows impact of substitution on daily/weekly nutritional goals
    """
    try:
        user_id = get_jwt_identity()
        logger.info(f"Applying meal substitution for user {user_id}, meal plan {meal_plan_id}")
        
        # Parse request body
        data = request.get_json()
        if not data:
            raise ValidationError("Request body is required")
        
        # Validate request schema
        request_schema = ApplySubstitutionRequestSchema(**data)
        
        # Extract parameters
        meal_index = data.get('meal_index')
        new_recipe_id = request_schema.new_recipe_id
        
        if meal_index is None:
            raise ValidationError("meal_index is required")
        
        # Apply substitution
        updated_meal_plan = substitution_service.apply_substitution(
            meal_plan_id=meal_plan_id,
            meal_index=int(meal_index),
            new_recipe_id=new_recipe_id,
            user_id=user_id
        )
        
        # Get the substitution details for response
        substitution_applied = {
            'meal_index': meal_index,
            'new_recipe_id': new_recipe_id,
            'meal_plan_id': meal_plan_id,
            'timestamp': updated_meal_plan.updated_at.isoformat()
        }
        
        response_data = {
            'success': True,
            'message': 'Meal substitution applied successfully',
            'meal_plan': updated_meal_plan.to_dict(),
            'substitution_applied': substitution_applied
        }
        
        logger.info(f"Meal substitution applied successfully for meal plan {meal_plan_id}")
        return jsonify(response_data), 200
        
    except ValidationError as e:
        logger.warning(f"Validation error in apply_meal_substitution: {e}")
        return jsonify({'error': str(e)}), 400
    except AppError as e:
        logger.error(f"Application error in apply_meal_substitution: {e}")
        return jsonify({'error': str(e)}), 500
    except Exception as e:
        logger.error(f"Unexpected error in apply_meal_substitution: {e}")
        return jsonify({'error': 'Internal server error'}), 500

@meal_substitution_bp.route('/meal-plans/<meal_plan_id>/undo-substitution', methods=['POST'])
@jwt_required()
def undo_meal_substitution(meal_plan_id: str):
    """
    Undo the most recent meal substitution in a meal plan
    
    AC 2.4.8: User can undo recent substitutions
    """
    try:
        user_id = get_jwt_identity()
        logger.info(f"Undoing meal substitution for user {user_id}, meal plan {meal_plan_id}")
        
        # Get substitution history before undo
        history = substitution_service._get_recent_substitution_history(meal_plan_id, user_id)
        if not history:
            raise ValidationError("No recent substitution to undo")
        
        # Apply undo
        updated_meal_plan = substitution_service.undo_substitution(
            meal_plan_id=meal_plan_id,
            user_id=user_id
        )
        
        # Prepare response with undone substitution details
        substitution_undone = {
            'meal_index': history.meal_index,
            'original_recipe_id': history.original_recipe_id,
            'new_recipe_id': history.new_recipe_id,
            'substitution_timestamp': history.timestamp.isoformat(),
            'undo_timestamp': updated_meal_plan.updated_at.isoformat()
        }
        
        response_data = {
            'success': True,
            'message': 'Meal substitution undone successfully',
            'meal_plan': updated_meal_plan.to_dict(),
            'substitution_undone': substitution_undone
        }
        
        logger.info(f"Meal substitution undone successfully for meal plan {meal_plan_id}")
        return jsonify(response_data), 200
        
    except ValidationError as e:
        logger.warning(f"Validation error in undo_meal_substitution: {e}")
        return jsonify({'error': str(e)}), 400
    except AppError as e:
        logger.error(f"Application error in undo_meal_substitution: {e}")
        return jsonify({'error': str(e)}), 500
    except Exception as e:
        logger.error(f"Unexpected error in undo_meal_substitution: {e}")
        return jsonify({'error': 'Internal server error'}), 500

@meal_substitution_bp.route('/meal-plans/<meal_plan_id>/substitution-history', methods=['GET'])
@jwt_required()
def get_substitution_history(meal_plan_id: str):
    """
    Get the substitution history for a meal plan
    """
    try:
        user_id = get_jwt_identity()
        logger.info(f"Getting substitution history for user {user_id}, meal plan {meal_plan_id}")
        
        # Get meal plan
        from data_access.database import db
        from core.models.meal_plan import MealPlan
        
        meal_plan = db.session.query(MealPlan).filter_by(id=meal_plan_id, user_id=user_id).first()
        if not meal_plan:
            raise ValidationError("Meal plan not found")
        
        # Get substitution history
        substitution_history = []
        can_undo = False
        
        if meal_plan.generation_parameters and 'substitution_history' in meal_plan.generation_parameters:
            history_items = meal_plan.generation_parameters['substitution_history']
            substitution_history = history_items
            can_undo = len(history_items) > 0
        
        response_data = {
            'meal_plan_id': meal_plan_id,
            'substitution_history': substitution_history,
            'can_undo': can_undo
        }
        
        return jsonify(response_data), 200
        
    except ValidationError as e:
        logger.warning(f"Validation error in get_substitution_history: {e}")
        return jsonify({'error': str(e)}), 400
    except AppError as e:
        logger.error(f"Application error in get_substitution_history: {e}")
        return jsonify({'error': str(e)}), 500
    except Exception as e:
        logger.error(f"Unexpected error in get_substitution_history: {e}")
        return jsonify({'error': 'Internal server error'}), 500

@meal_substitution_bp.route('/meal-plans/<meal_plan_id>/substitution-preview', methods=['POST'])
@jwt_required()
def preview_meal_substitution(meal_plan_id: str):
    """
    Preview the impact of a meal substitution without applying it
    
    AC 2.4.7: User can preview and confirm substitution before applying
    AC 2.4.5: System shows impact of substitution on daily/weekly nutritional goals
    """
    try:
        user_id = get_jwt_identity()
        logger.info(f"Previewing meal substitution for user {user_id}, meal plan {meal_plan_id}")
        
        # Parse request body
        data = request.get_json()
        if not data:
            raise ValidationError("Request body is required")
        
        meal_index = data.get('meal_index')
        new_recipe_id = data.get('new_recipe_id')
        
        if meal_index is None or not new_recipe_id:
            raise ValidationError("meal_index and new_recipe_id are required")
        
        # Get meal plan and validate access
        from data_access.database import db
        from core.models.meal_plan import MealPlan
        
        meal_plan = db.session.query(MealPlan).filter_by(id=meal_plan_id, user_id=user_id).first()
        if not meal_plan:
            raise ValidationError("Meal plan not found")
        
        # Validate meal index
        if meal_index < 0 or meal_index >= len(meal_plan.meals):
            raise ValidationError("Invalid meal index")
        
        # Get recipes
        original_recipe = substitution_service._get_recipe(meal_plan.meals[meal_index]['recipe_id'])
        new_recipe = substitution_service._get_recipe(new_recipe_id)
        
        # Calculate substitution impact
        impact = substitution_service._calculate_substitution_impact(
            original_recipe, new_recipe, meal_plan, user_id
        )
        
        response_data = {
            'meal_plan_id': meal_plan_id,
            'meal_index': meal_index,
            'original_recipe': original_recipe.to_dict(),
            'new_recipe': new_recipe.to_dict(),
            'substitution_impact': impact,
            'preview_only': True
        }
        
        logger.info(f"Substitution preview calculated for meal plan {meal_plan_id}")
        return jsonify(response_data), 200
        
    except ValidationError as e:
        logger.warning(f"Validation error in preview_meal_substitution: {e}")
        return jsonify({'error': str(e)}), 400
    except AppError as e:
        logger.error(f"Application error in preview_meal_substitution: {e}")
        return jsonify({'error': str(e)}), 500
    except Exception as e:
        logger.error(f"Unexpected error in preview_meal_substitution: {e}")
        return jsonify({'error': 'Internal server error'}), 500 