"""
Grocery List API Endpoints
Handles HTTP requests for grocery list operations
"""

import logging
from typing import Dict, Any
from flask import Blueprint, request, jsonify, g
from flask_jwt_extended import jwt_required, get_jwt_identity
from pydantic import ValidationError

from api.schemas.grocery_list_schemas import (
    GroceryListGenerationRequest,
    GroceryListUpdateRequest,
    CustomItemRequest,
    ItemQuantityUpdateRequest
)
from services.grocery_list_service import GroceryListService
from data_access.repositories.grocery_list_repository import GroceryListRepository
from data_access.repositories.meal_plan_repository import MealPlanRepository
from data_access.repositories.recipe_repository import RecipeRepository

logger = logging.getLogger(__name__)

# Create blueprint
grocery_lists_bp = Blueprint('grocery_lists', __name__)

# Initialize repositories and service
grocery_list_repo = GroceryListRepository()
meal_plan_repo = MealPlanRepository()
recipe_repo = RecipeRepository()
grocery_list_service = GroceryListService(grocery_list_repo, meal_plan_repo, recipe_repo)


@grocery_lists_bp.route('/meal-plans/<meal_plan_id>/grocery-list', methods=['POST'])
@jwt_required()
def generate_grocery_list_from_meal_plan(meal_plan_id: str):
    """
    Generate a grocery list from a meal plan
    
    POST /api/v1/meal-plans/{id}/grocery-list
    """
    try:
        user_id = get_jwt_identity()
        
        # Parse and validate request
        request_data = request.get_json()
        if not request_data:
            request_data = {}
        
        try:
            generation_request = GroceryListGenerationRequest(**request_data)
        except ValidationError as e:
            logger.warning(f"Invalid request data for grocery list generation: {e}")
            return jsonify({
                'error': 'Invalid request data',
                'details': e.errors()
            }), 400
        
        # Generate grocery list
        grocery_list = grocery_list_service.generate_from_meal_plan(
            meal_plan_id=meal_plan_id,
            user_id=user_id,
            list_name=generation_request.list_name
        )
        
        # Get full grocery list with items
        full_list_data = grocery_list_service.get_grocery_list(str(grocery_list.id), user_id)
        
        logger.info(f"Generated grocery list {grocery_list.id} from meal plan {meal_plan_id} for user {user_id}")
        
        return jsonify({
            'success': True,
            'message': 'Grocery list generated successfully',
            'data': full_list_data
        }), 201
        
    except ValueError as e:
        logger.warning(f"ValueError in grocery list generation: {e}")
        return jsonify({
            'error': 'Invalid request',
            'message': str(e)
        }), 400
        
    except Exception as e:
        logger.error(f"Unexpected error in grocery list generation: {e}")
        return jsonify({
            'error': 'Internal server error',
            'message': 'Failed to generate grocery list'
        }), 500


@grocery_lists_bp.route('/grocery-lists/<list_id>', methods=['GET'])
@jwt_required()
def get_grocery_list(list_id: str):
    """
    Get a grocery list with all items
    
    GET /api/v1/grocery-lists/{id}
    """
    try:
        user_id = get_jwt_identity()
        
        grocery_list_data = grocery_list_service.get_grocery_list(list_id, user_id)
        
        if not grocery_list_data:
            return jsonify({
                'error': 'Not found',
                'message': 'Grocery list not found or access denied'
            }), 404
        
        return jsonify({
            'success': True,
            'data': grocery_list_data
        }), 200
        
    except Exception as e:
        logger.error(f"Error retrieving grocery list {list_id}: {e}")
        return jsonify({
            'error': 'Internal server error',
            'message': 'Failed to retrieve grocery list'
        }), 500


@grocery_lists_bp.route('/grocery-lists/<list_id>', methods=['PUT'])
@jwt_required()
def update_grocery_list(list_id: str):
    """
    Update a grocery list
    
    PUT /api/v1/grocery-lists/{id}
    """
    try:
        user_id = get_jwt_identity()
        
        # Parse and validate request
        request_data = request.get_json()
        if not request_data:
            return jsonify({
                'error': 'Invalid request',
                'message': 'Request body is required'
            }), 400
        
        try:
            update_request = GroceryListUpdateRequest(**request_data)
        except ValidationError as e:
            logger.warning(f"Invalid update data for grocery list {list_id}: {e}")
            return jsonify({
                'error': 'Invalid request data',
                'details': e.errors()
            }), 400
        
        # Update grocery list
        updated_list = grocery_list_service.update_grocery_list(
            list_id=list_id,
            user_id=user_id,
            updates=update_request.dict(exclude_unset=True)
        )
        
        if not updated_list:
            return jsonify({
                'error': 'Not found',
                'message': 'Grocery list not found or access denied'
            }), 404
        
        return jsonify({
            'success': True,
            'message': 'Grocery list updated successfully',
            'data': updated_list.to_dict()
        }), 200
        
    except Exception as e:
        logger.error(f"Error updating grocery list {list_id}: {e}")
        return jsonify({
            'error': 'Internal server error',
            'message': 'Failed to update grocery list'
        }), 500


@grocery_lists_bp.route('/grocery-lists/<list_id>/items', methods=['POST'])
@jwt_required()
def add_custom_item(list_id: str):
    """
    Add a custom item to a grocery list
    
    POST /api/v1/grocery-lists/{id}/items
    """
    try:
        user_id = get_jwt_identity()
        
        # Parse and validate request
        request_data = request.get_json()
        if not request_data:
            return jsonify({
                'error': 'Invalid request',
                'message': 'Request body is required'
            }), 400
        
        try:
            item_request = CustomItemRequest(**request_data)
        except ValidationError as e:
            logger.warning(f"Invalid custom item data for list {list_id}: {e}")
            return jsonify({
                'error': 'Invalid request data',
                'details': e.errors()
            }), 400
        
        # Add custom item
        created_item = grocery_list_service.add_custom_item(
            list_id=list_id,
            user_id=user_id,
            item_data=item_request.dict()
        )
        
        if not created_item:
            return jsonify({
                'error': 'Not found',
                'message': 'Grocery list not found or access denied'
            }), 404
        
        return jsonify({
            'success': True,
            'message': 'Custom item added successfully',
            'data': created_item.to_dict()
        }), 201
        
    except Exception as e:
        logger.error(f"Error adding custom item to list {list_id}: {e}")
        return jsonify({
            'error': 'Internal server error',
            'message': 'Failed to add custom item'
        }), 500


@grocery_lists_bp.route('/grocery-lists/items/<item_id>/toggle', methods=['PATCH'])
@jwt_required()
def toggle_item_checked(item_id: str):
    """
    Toggle the checked status of a grocery list item
    
    PATCH /api/v1/grocery-lists/items/{id}/toggle
    """
    try:
        user_id = get_jwt_identity()
        
        updated_item = grocery_list_service.toggle_item_checked(item_id, user_id)
        
        if not updated_item:
            return jsonify({
                'error': 'Not found',
                'message': 'Item not found or access denied'
            }), 404
        
        return jsonify({
            'success': True,
            'message': 'Item status updated successfully',
            'data': updated_item.to_dict()
        }), 200
        
    except Exception as e:
        logger.error(f"Error toggling item {item_id}: {e}")
        return jsonify({
            'error': 'Internal server error',
            'message': 'Failed to update item status'
        }), 500


@grocery_lists_bp.route('/grocery-lists/items/<item_id>/quantity', methods=['PATCH'])
@jwt_required()
def update_item_quantity(item_id: str):
    """
    Update the quantity of a grocery list item
    
    PATCH /api/v1/grocery-lists/items/{id}/quantity
    """
    try:
        user_id = get_jwt_identity()
        
        # Parse and validate request
        request_data = request.get_json()
        if not request_data:
            return jsonify({
                'error': 'Invalid request',
                'message': 'Request body is required'
            }), 400
        
        try:
            quantity_request = ItemQuantityUpdateRequest(**request_data)
        except ValidationError as e:
            logger.warning(f"Invalid quantity update data for item {item_id}: {e}")
            return jsonify({
                'error': 'Invalid request data',
                'details': e.errors()
            }), 400
        
        # Update item quantity
        updated_item = grocery_list_service.update_item_quantity(
            item_id=item_id,
            user_id=user_id,
            new_quantity=quantity_request.quantity,
            new_unit=quantity_request.unit
        )
        
        if not updated_item:
            return jsonify({
                'error': 'Not found',
                'message': 'Item not found or access denied'
            }), 404
        
        return jsonify({
            'success': True,
            'message': 'Item quantity updated successfully',
            'data': updated_item.to_dict()
        }), 200
        
    except Exception as e:
        logger.error(f"Error updating item quantity {item_id}: {e}")
        return jsonify({
            'error': 'Internal server error',
            'message': 'Failed to update item quantity'
        }), 500


@grocery_lists_bp.route('/grocery-lists/items/<item_id>', methods=['DELETE'])
@jwt_required()
def delete_item(item_id: str):
    """
    Delete a grocery list item
    
    DELETE /api/v1/grocery-lists/items/{id}
    """
    try:
        user_id = get_jwt_identity()
        
        success = grocery_list_service.delete_item(item_id, user_id)
        
        if not success:
            return jsonify({
                'error': 'Not found',
                'message': 'Item not found or access denied'
            }), 404
        
        return jsonify({
            'success': True,
            'message': 'Item deleted successfully'
        }), 200
        
    except Exception as e:
        logger.error(f"Error deleting item {item_id}: {e}")
        return jsonify({
            'error': 'Internal server error',
            'message': 'Failed to delete item'
        }), 500


@grocery_lists_bp.route('/grocery-lists', methods=['GET'])
@jwt_required()
def get_user_grocery_lists():
    """
    Get all grocery lists for the authenticated user
    
    GET /api/v1/grocery-lists
    """
    try:
        user_id = get_jwt_identity()
        
        grocery_lists = grocery_list_service.get_user_grocery_lists(user_id)
        
        return jsonify({
            'success': True,
            'data': {
                'grocery_lists': grocery_lists,
                'total_count': len(grocery_lists)
            }
        }), 200
        
    except Exception as e:
        logger.error(f"Error retrieving grocery lists for user: {e}")
        return jsonify({
            'error': 'Internal server error',
            'message': 'Failed to retrieve grocery lists'
        }), 500


@grocery_lists_bp.route('/grocery-lists/<list_id>/statistics', methods=['GET'])
@jwt_required()
def get_grocery_list_statistics(list_id: str):
    """
    Get statistics for a grocery list
    
    GET /api/v1/grocery-lists/{id}/statistics
    """
    try:
        user_id = get_jwt_identity()
        
        # Verify user owns the list
        grocery_list_data = grocery_list_service.get_grocery_list(list_id, user_id)
        if not grocery_list_data:
            return jsonify({
                'error': 'Not found',
                'message': 'Grocery list not found or access denied'
            }), 404
        
        # Get statistics
        statistics = grocery_list_repo.get_list_statistics(list_id)
        
        return jsonify({
            'success': True,
            'data': statistics
        }), 200
        
    except Exception as e:
        logger.error(f"Error retrieving statistics for grocery list {list_id}: {e}")
        return jsonify({
            'error': 'Internal server error',
            'message': 'Failed to retrieve grocery list statistics'
        }), 500


@grocery_lists_bp.route('/grocery-lists/<list_id>', methods=['DELETE'])
@jwt_required()
def delete_grocery_list(list_id: str):
    """
    Delete a grocery list (soft delete)
    
    DELETE /api/v1/grocery-lists/{id}
    """
    try:
        user_id = get_jwt_identity()
        
        # Verify user owns the list and soft delete
        grocery_list_data = grocery_list_service.get_grocery_list(list_id, user_id)
        if not grocery_list_data:
            return jsonify({
                'error': 'Not found',
                'message': 'Grocery list not found or access denied'
            }), 404
        
        success = grocery_list_repo.delete(list_id)
        
        if not success:
            return jsonify({
                'error': 'Internal server error',
                'message': 'Failed to delete grocery list'
            }), 500
        
        return jsonify({
            'success': True,
            'message': 'Grocery list deleted successfully'
        }), 200
        
    except Exception as e:
        logger.error(f"Error deleting grocery list {list_id}: {e}")
        return jsonify({
            'error': 'Internal server error',
            'message': 'Failed to delete grocery list'
        }), 500


# Error handlers for the blueprint
@grocery_lists_bp.errorhandler(400)
def bad_request(error):
    """Handle bad request errors"""
    return jsonify({
        'error': 'Bad request',
        'message': 'The request could not be understood or was missing required parameters'
    }), 400


@grocery_lists_bp.errorhandler(401)
def unauthorized(error):
    """Handle unauthorized errors"""
    return jsonify({
        'error': 'Unauthorized',
        'message': 'Authentication required'
    }), 401


@grocery_lists_bp.errorhandler(403)
def forbidden(error):
    """Handle forbidden errors"""
    return jsonify({
        'error': 'Forbidden',
        'message': 'Insufficient permissions'
    }), 403


@grocery_lists_bp.errorhandler(404)
def not_found(error):
    """Handle not found errors"""
    return jsonify({
        'error': 'Not found',
        'message': 'The requested resource was not found'
    }), 404


@grocery_lists_bp.errorhandler(500)
def internal_error(error):
    """Handle internal server errors"""
    return jsonify({
        'error': 'Internal server error',
        'message': 'An unexpected error occurred'
    }), 500 