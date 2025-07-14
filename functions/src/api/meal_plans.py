"""
Meal Plan API Endpoints
Handles meal plan generation, retrieval, and management
"""

import logging
from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address
from pydantic import ValidationError as PydanticValidationError

from api.schemas.meal_plan_schemas import (
    MealPlanGenerationRequest, MealPlanResponse, MealPlanListResponse,
    MealPlanRegenerateRequest, MealPlanStatsResponse, NutritionalAnalysisResponse,
    WeeklyTrendsRequest, WeeklyTrendsResponse
)
from services.meal_planning_service import MealPlanningService, MealPlanGenerationRequest as ServiceRequest
from services.nutritional_analysis_service import NutritionalAnalysisService
from data_access.meal_plan_repository import MealPlanRepository
from data_access.recipe_repository import RecipeRepository
from core.exceptions import AppError, ValidationError

logger = logging.getLogger(__name__)

# Create Blueprint
meal_plans_bp = Blueprint('meal_plans', __name__)

# Initialize services
meal_planning_service = MealPlanningService()
nutritional_analysis_service = NutritionalAnalysisService()
meal_plan_repository = MealPlanRepository()
recipe_repository = RecipeRepository()

# Rate limiting decorator
limiter = Limiter(
    key_func=get_remote_address,
    default_limits=["200 per day", "50 per hour"]
)

@meal_plans_bp.route('/generate', methods=['POST'])
@jwt_required()
@limiter.limit("10 per hour")
def generate_meal_plan():
    """
    Generate a new meal plan for the authenticated user
    
    Expected JSON body:
    {
        "duration_days": 1-7,
        "plan_date": "YYYY-MM-DD (optional)",
        "budget_usd": float (optional),
        "include_snacks": boolean (optional),
        "force_regenerate": boolean (optional)
    }
    """
    try:
        # Get authenticated user
        user_id = get_jwt_identity()
        
        # Get JSON data
        data = request.get_json()
        if not data:
            return jsonify({
                'success': False,
                'error': {
                    'code': 'ValidationError',
                    'message': 'Request body must be valid JSON'
                }
            }), 400
        
        # Validate request data
        try:
            request_data = MealPlanGenerationRequest(**data)
        except PydanticValidationError as e:
            return jsonify({
                'success': False,
                'error': {
                    'code': 'ValidationError',
                    'message': 'Validation failed',
                    'details': e.errors()
                }
            }), 400
        
        # Create service request
        service_request = ServiceRequest(
            user_id=user_id,
            duration_days=request_data.duration_days,
            plan_date=request_data.plan_date,
            budget_usd=request_data.budget_usd,
            include_snacks=request_data.include_snacks,
            force_regenerate=request_data.force_regenerate
        )
        
        # Generate meal plan
        meal_plan = meal_planning_service.generate_meal_plan(service_request)
        
        # Create response
        response_data = MealPlanResponse(
            success=True,
            message="Meal plan generated successfully",
            meal_plan={
                'id': str(meal_plan.id),
                'user_id': meal_plan.user_id,
                'plan_date': meal_plan.plan_date.isoformat(),
                'duration_days': meal_plan.duration_days,
                'meals': meal_plan.meals,
                'total_nutrition_summary': meal_plan.total_nutrition_summary,
                'daily_nutrition_breakdown': meal_plan.daily_nutrition_breakdown,
                'estimated_total_cost_usd': meal_plan.estimated_total_cost_usd / 100.0 if meal_plan.estimated_total_cost_usd else 0,
                'budget_target_usd': meal_plan.budget_target_usd / 100.0 if meal_plan.budget_target_usd else None,
                'is_within_budget': meal_plan.is_within_budget,
                'dietary_restrictions_used': meal_plan.dietary_restrictions_used,
                'algorithm_version': meal_plan.algorithm_version,
                'created_at': meal_plan.created_at.isoformat()
            }
        )
        
        logger.info(f"Meal plan generated successfully for user {user_id}: {meal_plan.id}")
        
        return jsonify(response_data.dict()), 201
        
    except AppError as e:
        # Custom application errors are handled by error handlers
        raise
    except Exception as e:
        logger.error(f"Unexpected error in meal plan generation: {str(e)}")
        return jsonify({
            'success': False,
            'error': {
                'code': 'InternalServerError',
                'message': 'An unexpected error occurred'
            }
        }), 500

@meal_plans_bp.route('/<plan_id>', methods=['GET'])
@jwt_required()
def get_meal_plan(plan_id: str):
    """Get a specific meal plan by ID"""
    try:
        user_id = get_jwt_identity()
        
        # Get meal plan
        meal_plan = meal_plan_repository.get_meal_plan_by_id(plan_id, user_id)
        if not meal_plan:
            return jsonify({
                'success': False,
                'error': {
                    'code': 'NotFoundError',
                    'message': 'Meal plan not found'
                }
            }), 404
        
        # Create response
        response_data = MealPlanResponse(
            success=True,
            message="Meal plan retrieved successfully",
            meal_plan={
                'id': str(meal_plan.id),
                'user_id': meal_plan.user_id,
                'plan_date': meal_plan.plan_date.isoformat(),
                'duration_days': meal_plan.duration_days,
                'meals': meal_plan.meals,
                'total_nutrition_summary': meal_plan.total_nutrition_summary,
                'daily_nutrition_breakdown': meal_plan.daily_nutrition_breakdown,
                'estimated_total_cost_usd': meal_plan.estimated_total_cost_usd / 100.0 if meal_plan.estimated_total_cost_usd else 0,
                'budget_target_usd': meal_plan.budget_target_usd / 100.0 if meal_plan.budget_target_usd else None,
                'is_within_budget': meal_plan.is_within_budget,
                'dietary_restrictions_used': meal_plan.dietary_restrictions_used,
                'algorithm_version': meal_plan.algorithm_version,
                'user_rating': meal_plan.user_rating,
                'user_feedback': meal_plan.user_feedback,
                'created_at': meal_plan.created_at.isoformat(),
                'updated_at': meal_plan.updated_at.isoformat() if meal_plan.updated_at else None
            }
        )
        
        logger.debug(f"Meal plan retrieved: {plan_id}")
        return jsonify(response_data.dict()), 200
        
    except Exception as e:
        logger.error(f"Error retrieving meal plan {plan_id}: {str(e)}")
        return jsonify({
            'success': False,
            'error': {
                'code': 'InternalServerError',
                'message': 'An unexpected error occurred'
            }
        }), 500

@meal_plans_bp.route('/user', methods=['GET'])
@jwt_required()
def get_user_meal_plans():
    """Get all meal plans for the authenticated user"""
    try:
        user_id = get_jwt_identity()
        
        # Get query parameters
        limit = request.args.get('limit', 10, type=int)
        offset = request.args.get('offset', 0, type=int)
        
        # Get meal plans
        meal_plans = meal_plan_repository.get_user_meal_plans(
            user_id=user_id,
            limit=limit,
            offset=offset
        )
        
        # Convert to response format
        meal_plans_data = []
        for meal_plan in meal_plans:
            meal_plans_data.append({
                'id': str(meal_plan.id),
                'plan_date': meal_plan.plan_date.isoformat(),
                'duration_days': meal_plan.duration_days,
                'meals_count': len(meal_plan.meals),
                'estimated_total_cost_usd': meal_plan.estimated_total_cost_usd / 100.0 if meal_plan.estimated_total_cost_usd else 0,
                'is_within_budget': meal_plan.is_within_budget,
                'user_rating': meal_plan.user_rating,
                'created_at': meal_plan.created_at.isoformat()
            })
        
        # Create response
        response_data = MealPlanListResponse(
            success=True,
            message=f"Retrieved {len(meal_plans_data)} meal plans",
            meal_plans=meal_plans_data,
            total_count=len(meal_plans_data),
            limit=limit,
            offset=offset
        )
        
        logger.debug(f"Retrieved {len(meal_plans_data)} meal plans for user {user_id}")
        return jsonify(response_data.dict()), 200
        
    except Exception as e:
        logger.error(f"Error retrieving meal plans for user: {str(e)}")
        return jsonify({
            'success': False,
            'error': {
                'code': 'InternalServerError',
                'message': 'An unexpected error occurred'
            }
        }), 500

@meal_plans_bp.route('/<plan_id>/regenerate', methods=['PUT'])
@jwt_required()
@limiter.limit("5 per hour")
def regenerate_meal_plan(plan_id: str):
    """Regenerate an existing meal plan with variations"""
    try:
        user_id = get_jwt_identity()
        
        # Get JSON data (optional feedback)
        data = request.get_json() or {}
        
        # Validate request data if provided
        feedback_data = None
        if data:
            try:
                feedback_data = MealPlanRegenerateRequest(**data)
            except PydanticValidationError as e:
                return jsonify({
                    'success': False,
                    'error': {
                        'code': 'ValidationError',
                        'message': 'Validation failed',
                        'details': e.errors()
                    }
                }), 400
        
        # Add user feedback if provided
        if feedback_data and (feedback_data.rating or feedback_data.feedback):
            meal_plan_repository.add_user_feedback(
                plan_id=plan_id,
                user_id=user_id,
                rating=feedback_data.rating,
                feedback=feedback_data.feedback
            )
        
        # Regenerate meal plan
        new_meal_plan = meal_planning_service.regenerate_meal_plan(user_id, plan_id)
        
        # Create response
        response_data = MealPlanResponse(
            success=True,
            message="Meal plan regenerated successfully",
            meal_plan={
                'id': str(new_meal_plan.id),
                'user_id': new_meal_plan.user_id,
                'plan_date': new_meal_plan.plan_date.isoformat(),
                'duration_days': new_meal_plan.duration_days,
                'meals': new_meal_plan.meals,
                'total_nutrition_summary': new_meal_plan.total_nutrition_summary,
                'daily_nutrition_breakdown': new_meal_plan.daily_nutrition_breakdown,
                'estimated_total_cost_usd': new_meal_plan.estimated_total_cost_usd / 100.0 if new_meal_plan.estimated_total_cost_usd else 0,
                'budget_target_usd': new_meal_plan.budget_target_usd / 100.0 if new_meal_plan.budget_target_usd else None,
                'is_within_budget': new_meal_plan.is_within_budget,
                'dietary_restrictions_used': new_meal_plan.dietary_restrictions_used,
                'algorithm_version': new_meal_plan.algorithm_version,
                'created_at': new_meal_plan.created_at.isoformat()
            }
        )
        
        logger.info(f"Meal plan regenerated successfully for user {user_id}: {new_meal_plan.id}")
        
        return jsonify(response_data.dict()), 201
        
    except AppError as e:
        # Custom application errors are handled by error handlers
        raise
    except Exception as e:
        logger.error(f"Unexpected error in meal plan regeneration: {str(e)}")
        return jsonify({
            'success': False,
            'error': {
                'code': 'InternalServerError',
                'message': 'An unexpected error occurred'
            }
        }), 500

@meal_plans_bp.route('/stats', methods=['GET'])
@jwt_required()
def get_meal_plan_stats():
    """Get meal plan statistics for the authenticated user"""
    try:
        user_id = get_jwt_identity()
        
        # Get statistics
        stats = meal_plan_repository.get_meal_plan_statistics(user_id)
        popular_recipes = meal_plan_repository.get_popular_recipes(user_id, limit=5)
        nutrition_trends = meal_plan_repository.get_nutrition_trends(user_id, days=30)
        
        # Create response
        response_data = MealPlanStatsResponse(
            success=True,
            message="Statistics retrieved successfully",
            stats={
                'meal_plan_stats': stats,
                'popular_recipes': popular_recipes,
                'nutrition_trends': nutrition_trends
            }
        )
        
        logger.debug(f"Meal plan statistics retrieved for user {user_id}")
        return jsonify(response_data.dict()), 200
        
    except Exception as e:
        logger.error(f"Error retrieving meal plan statistics: {str(e)}")
        return jsonify({
            'success': False,
            'error': {
                'code': 'InternalServerError',
                'message': 'An unexpected error occurred'
            }
        }), 500

@meal_plans_bp.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint for meal plans service"""
    try:
        # Check database connectivity
        recipe_count = recipe_repository.get_recipe_count()
        
        return jsonify({
            'success': True,
            'message': 'Meal plans service is healthy',
            'data': {
                'service': 'meal_plans',
                'status': 'healthy',
                'recipe_count': recipe_count
            }
        }), 200
        
    except Exception as e:
        logger.error(f"Health check failed: {str(e)}")
        return jsonify({
            'success': False,
            'error': {
                'code': 'ServiceUnavailable',
                'message': 'Meal plans service is unhealthy'
            }
        }), 503

@meal_plans_bp.route('/<plan_id>/analysis', methods=['GET'])
@jwt_required()
def get_meal_plan_analysis(plan_id: str):
    """
    Get comprehensive nutritional analysis for a specific meal plan
    
    Returns detailed nutritional insights, goal adherence, cost analysis,
    and personalized recommendations based on user goals.
    """
    try:
        user_id = get_jwt_identity()
        
        # Perform nutritional analysis
        analysis = nutritional_analysis_service.analyze_meal_plan(plan_id, user_id)
        
        # Create response
        response_data = NutritionalAnalysisResponse(
            success=True,
            message="Nutritional analysis completed successfully",
            analysis=analysis
        )
        
        logger.debug(f"Nutritional analysis completed for meal plan {plan_id}")
        return jsonify(response_data.dict()), 200
        
    except ValueError as e:
        return jsonify({
            'success': False,
            'error': {
                'code': 'NotFoundError',
                'message': str(e)
            }
        }), 404
    except Exception as e:
        logger.error(f"Error analyzing meal plan {plan_id}: {str(e)}")
        return jsonify({
            'success': False,
            'error': {
                'code': 'InternalServerError',
                'message': 'An unexpected error occurred during analysis'
            }
        }), 500

@meal_plans_bp.route('/trends', methods=['GET'])
@jwt_required()
def get_weekly_trends():
    """
    Get weekly nutritional trends and patterns for the authenticated user
    
    Query parameters:
    - weeks: Number of weeks to analyze (default: 4, max: 12)
    """
    try:
        user_id = get_jwt_identity()
        
        # Get query parameters
        weeks = request.args.get('weeks', 4, type=int)
        
        # Validate weeks parameter
        if weeks < 1 or weeks > 12:
            return jsonify({
                'success': False,
                'error': {
                    'code': 'ValidationError',
                    'message': 'Weeks parameter must be between 1 and 12'
                }
            }), 400
        
        # Get weekly trends analysis
        trends = nutritional_analysis_service.get_weekly_trends(user_id, weeks)
        
        # Create response
        response_data = WeeklyTrendsResponse(
            success=True,
            message=f"Weekly trends analysis completed for {weeks} weeks",
            trends=trends
        )
        
        logger.debug(f"Weekly trends analysis completed for user {user_id}")
        return jsonify(response_data.dict()), 200
        
    except Exception as e:
        logger.error(f"Error analyzing weekly trends for user {user_id}: {str(e)}")
        return jsonify({
            'success': False,
            'error': {
                'code': 'InternalServerError',
                'message': 'An unexpected error occurred during trends analysis'
            }
        }), 500 