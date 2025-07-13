"""
Preference Learning API Endpoints for Story 2.2
Handles meal recommendation swiping and preference collection
"""

import logging
from datetime import datetime
from flask import Blueprint, request, jsonify, g
from flask_jwt_extended import jwt_required, get_jwt_identity

from services.preference_learning_service import PreferenceLearningService
from api.schemas.preference_schemas import (
    MealSuggestionsRequest, MealSuggestionsResponse,
    SwipeFeedbackRequest, SwipeFeedbackResponse,
    RecipeRatingRequest, RecipeRatingResponse,
    IngredientPreferenceRequest, IngredientPreferenceResponse,
    CuisinePreferenceRequest, CuisinePreferenceResponse,
    PreferenceStatsResponse, ErrorResponse
)
from core.exceptions import UserNotFoundError, ValidationError
from pydantic import ValidationError as PydanticValidationError

logger = logging.getLogger(__name__)

# Create Blueprint
preferences_bp = Blueprint('preferences', __name__, url_prefix='/api/v1')

# Initialize service
preference_service = PreferenceLearningService()


def create_error_response(error_type: str, message: str, details=None, status_code=400):
    """Create standardized error response"""
    error_response = ErrorResponse(
        error=error_type,
        message=message,
        details=details,
        timestamp=datetime.utcnow().isoformat()
    )
    return jsonify(error_response.dict()), status_code


@preferences_bp.route('/recommendations/meals', methods=['GET'])
@jwt_required()
def get_meal_suggestions():
    """Get meal suggestions for swiping interface (AC 2.2.6)"""
    try:
        user_id = get_jwt_identity()
        
        # Parse query parameters
        session_length = request.args.get('session_length', 20, type=int)
        
        # Validate request
        try:
            request_data = MealSuggestionsRequest(session_length=session_length)
        except PydanticValidationError as e:
            return create_error_response(
                "validation_error",
                "Invalid request parameters",
                {"validation_errors": e.errors()},
                400
            )
        
        # Get meal suggestions
        suggestions = preference_service.get_meal_suggestions(
            user_id, 
            request_data.session_length
        )
        
        # Create response
        response = MealSuggestionsResponse(
            suggestions=suggestions,
            session_length=len(suggestions),
            user_id=user_id
        )
        
        logger.info(f"Returned {len(suggestions)} meal suggestions for user {user_id}")
        return jsonify(response.dict()), 200
        
    except UserNotFoundError as e:
        return create_error_response("user_not_found", str(e), status_code=404)
    except Exception as e:
        logger.error(f"Error getting meal suggestions: {str(e)}")
        return create_error_response(
            "internal_error",
            "Failed to get meal suggestions",
            status_code=500
        )


@preferences_bp.route('/user-preferences/meal-feedback', methods=['POST'])
@jwt_required()
def record_meal_feedback():
    """Record swipe feedback for meals (AC 2.2.3, 2.2.5)"""
    try:
        user_id = get_jwt_identity()
        
        # Validate request
        try:
            request_data = SwipeFeedbackRequest(**request.get_json())
        except PydanticValidationError as e:
            return create_error_response(
                "validation_error",
                "Invalid request data",
                {"validation_errors": e.errors()},
                400
            )
        
        # Record swipe feedback
        result = preference_service.record_swipe_feedback(
            user_id,
            request_data.recipe_id,
            request_data.action
        )
        
        # Create response
        response = SwipeFeedbackResponse(**result)
        
        logger.info(f"Recorded swipe feedback for user {user_id}: {request_data.action} on recipe {request_data.recipe_id}")
        return jsonify(response.dict()), 201
        
    except UserNotFoundError as e:
        return create_error_response("user_not_found", str(e), status_code=404)
    except ValidationError as e:
        return create_error_response("validation_error", str(e), status_code=400)
    except Exception as e:
        logger.error(f"Error recording meal feedback: {str(e)}")
        return create_error_response(
            "internal_error",
            "Failed to record meal feedback",
            status_code=500
        )


@preferences_bp.route('/user-preferences/recipe-ratings', methods=['POST'])
@jwt_required()
def set_recipe_rating():
    """Set detailed recipe rating (AC 2.2.7)"""
    try:
        user_id = get_jwt_identity()
        
        # Validate request
        try:
            request_data = RecipeRatingRequest(**request.get_json())
        except PydanticValidationError as e:
            return create_error_response(
                "validation_error",
                "Invalid request data",
                {"validation_errors": e.errors()},
                400
            )
        
        # Set recipe rating
        result = preference_service.set_recipe_rating(
            user_id,
            request_data.recipe_id,
            request_data.rating
        )
        
        # Create response
        response = RecipeRatingResponse(**result)
        
        logger.info(f"Set recipe rating for user {user_id}: {request_data.rating} stars for recipe {request_data.recipe_id}")
        return jsonify(response.dict()), 201
        
    except UserNotFoundError as e:
        return create_error_response("user_not_found", str(e), status_code=404)
    except ValidationError as e:
        return create_error_response("validation_error", str(e), status_code=400)
    except Exception as e:
        logger.error(f"Error setting recipe rating: {str(e)}")
        return create_error_response(
            "internal_error",
            "Failed to set recipe rating",
            status_code=500
        )


@preferences_bp.route('/user-preferences/ingredients', methods=['POST'])
@jwt_required()
def update_ingredient_preference():
    """Update ingredient like/dislike preferences (AC 2.2.8)"""
    try:
        user_id = get_jwt_identity()
        
        # Validate request
        try:
            request_data = IngredientPreferenceRequest(**request.get_json())
        except PydanticValidationError as e:
            return create_error_response(
                "validation_error",
                "Invalid request data",
                {"validation_errors": e.errors()},
                400
            )
        
        # Update ingredient preference
        result = preference_service.update_ingredient_preference(
            user_id,
            request_data.ingredient,
            request_data.preference
        )
        
        # Create response
        response = IngredientPreferenceResponse(**result)
        
        logger.info(f"Updated ingredient preference for user {user_id}: {request_data.preference} {request_data.ingredient}")
        return jsonify(response.dict()), 201
        
    except UserNotFoundError as e:
        return create_error_response("user_not_found", str(e), status_code=404)
    except ValidationError as e:
        return create_error_response("validation_error", str(e), status_code=400)
    except Exception as e:
        logger.error(f"Error updating ingredient preference: {str(e)}")
        return create_error_response(
            "internal_error",
            "Failed to update ingredient preference",
            status_code=500
        )


@preferences_bp.route('/user-preferences/cuisines', methods=['POST'])
@jwt_required()
def set_cuisine_preference():
    """Set cuisine preference rating (AC 2.2.9)"""
    try:
        user_id = get_jwt_identity()
        
        # Validate request
        try:
            request_data = CuisinePreferenceRequest(**request.get_json())
        except PydanticValidationError as e:
            return create_error_response(
                "validation_error",
                "Invalid request data",
                {"validation_errors": e.errors()},
                400
            )
        
        # Set cuisine preference
        result = preference_service.set_cuisine_preference(
            user_id,
            request_data.cuisine,
            request_data.rating
        )
        
        # Create response
        response = CuisinePreferenceResponse(**result)
        
        logger.info(f"Set cuisine preference for user {user_id}: {request_data.rating} rating for {request_data.cuisine}")
        return jsonify(response.dict()), 201
        
    except UserNotFoundError as e:
        return create_error_response("user_not_found", str(e), status_code=404)
    except ValidationError as e:
        return create_error_response("validation_error", str(e), status_code=400)
    except Exception as e:
        logger.error(f"Error setting cuisine preference: {str(e)}")
        return create_error_response(
            "internal_error",
            "Failed to set cuisine preference",
            status_code=500
        )


@preferences_bp.route('/user-preferences/stats', methods=['GET'])
@jwt_required()
def get_preference_stats():
    """Get user preference statistics for analytics"""
    try:
        user_id = get_jwt_identity()
        
        # Get user preferences from MongoDB
        from core.models.user_preferences import UserPreferences
        user_prefs_model = UserPreferences()
        user_prefs = user_prefs_model.get_preferences(user_id)
        
        if not user_prefs:
            return create_error_response("user_not_found", "User preferences not found", status_code=404)
        
        # Calculate statistics
        swipe_prefs = user_prefs.get("swipe_preferences", {})
        recipe_ratings = user_prefs.get("recipe_ratings", {})
        ingredient_prefs = user_prefs.get("ingredient_preferences", {"liked": [], "disliked": []})
        cuisine_prefs = user_prefs.get("cuisine_preferences", {})
        
        likes_count = sum(1 for action in swipe_prefs.values() if action == "like")
        dislikes_count = sum(1 for action in swipe_prefs.values() if action == "dislike")
        
        average_rating = None
        if recipe_ratings:
            average_rating = sum(recipe_ratings.values()) / len(recipe_ratings)
        
        # Top cuisine preferences
        preferred_cuisines = [
            {"cuisine": cuisine, "rating": rating}
            for cuisine, rating in sorted(cuisine_prefs.items(), key=lambda x: x[1], reverse=True)
        ]
        
        # Create response
        response = PreferenceStatsResponse(
            user_id=user_id,
            total_swipes=len(swipe_prefs),
            likes_count=likes_count,
            dislikes_count=dislikes_count,
            total_ratings=len(recipe_ratings),
            average_rating=average_rating,
            preferred_cuisines=preferred_cuisines,
            liked_ingredients=ingredient_prefs.get("liked", []),
            disliked_ingredients=ingredient_prefs.get("disliked", []),
            prep_time_preference=user_prefs.get("prep_time_preference", "moderate")
        )
        
        logger.info(f"Retrieved preference stats for user {user_id}")
        return jsonify(response.dict()), 200
        
    except UserNotFoundError as e:
        return create_error_response("user_not_found", str(e), status_code=404)
    except Exception as e:
        logger.error(f"Error getting preference stats: {str(e)}")
        return create_error_response(
            "internal_error",
            "Failed to get preference statistics",
            status_code=500
        ) 