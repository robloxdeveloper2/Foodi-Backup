"""
User Recipe API Endpoints
Handles HTTP requests for user recipe collection management
"""

from flask import Blueprint, request, jsonify, current_app
from flask_jwt_extended import jwt_required, get_jwt_identity
from werkzeug.exceptions import BadRequest
from typing import Dict, Any
from functools import wraps

from services.user_recipe_service import UserRecipeService


# Create blueprint
user_recipes_bp = Blueprint('user_recipes', __name__, url_prefix='/api/v1/user-recipes')

# Initialize service
user_recipe_service = UserRecipeService()


# Auth decorators and utilities
def require_auth(f):
    """Decorator that requires JWT authentication"""
    @wraps(f)
    @jwt_required()
    def decorated_function(*args, **kwargs):
        return f(*args, **kwargs)
    return decorated_function


def get_current_user_id():
    """Get the current authenticated user's ID from JWT token"""
    return get_jwt_identity()


def validate_request_json(request):
    """Validate request has JSON data"""
    if not request.is_json:
        raise BadRequest("Request must be JSON")
    
    data = request.get_json()
    if not data:
        raise BadRequest("Request body cannot be empty")
    
    return data


# Response helper functions
def success_response(data, message="Success", status_code=200):
    """Create a successful response"""
    return jsonify({
        'success': True,
        'message': message,
        'data': data
    }), status_code


def error_response(message, status_code=400):
    """Create an error response"""
    return jsonify({
        'success': False,
        'error': {
            'code': f'HTTP{status_code}',
            'message': message
        }
    }), status_code


def paginated_response(data, pagination, message="Success", metadata=None):
    """Create a paginated response"""
    response = {
        'success': True,
        'message': message,
        'data': data,
        'pagination': pagination
    }
    if metadata:
        response['metadata'] = metadata
    return jsonify(response), 200


def validate_pagination_params(page, page_size, max_page_size=100):
    """Validate pagination parameters"""
    if page < 1:
        page = 1
    if page_size < 1:
        page_size = 20
    if page_size > max_page_size:
        page_size = max_page_size
    return page, page_size


# Recipe Collection Endpoints

@user_recipes_bp.route('', methods=['GET'])
@require_auth
def get_user_recipe_collection():
    """Get user's recipe collection with filtering and pagination"""
    try:
        user_id = get_current_user_id()
        
        # Parse query parameters
        page = request.args.get('page', 1, type=int)
        page_size = request.args.get('page_size', 20, type=int)
        sort_by = request.args.get('sort_by', 'created_at')
        sort_order = request.args.get('sort_order', 'desc')
        
        # Validate pagination params
        page, page_size = validate_pagination_params(page, page_size)
        
        # Build filters from query parameters
        filters = {}
        
        # Search query
        search = request.args.get('search')
        if search:
            filters['search'] = search.strip()
        
        # Recipe type filter (custom vs favorited)
        recipe_type = request.args.get('recipe_type')
        if recipe_type in ['custom', 'favorited']:
            filters['recipe_type'] = recipe_type
        
        # Classification filters
        cuisine_type = request.args.get('cuisine_type')
        if cuisine_type:
            filters['cuisine_type'] = cuisine_type
        
        meal_type = request.args.get('meal_type')
        if meal_type:
            filters['meal_type'] = meal_type
        
        difficulty_level = request.args.get('difficulty_level')
        if difficulty_level:
            filters['difficulty_level'] = difficulty_level
        
        # Time filter
        max_total_time = request.args.get('max_total_time', type=int)
        if max_total_time:
            filters['max_total_time'] = max_total_time
        
        # Category filter
        category_id = request.args.get('category_id')
        if category_id:
            filters['category_id'] = category_id
        
        # Public/private filter
        is_public = request.args.get('is_public')
        if is_public is not None:
            filters['is_public'] = is_public.lower() == 'true'
        
        # Get recipe collection
        result = user_recipe_service.get_user_recipe_collection(
            user_id=user_id,
            filters=filters,
            page=page,
            page_size=page_size,
            sort_by=sort_by,
            sort_order=sort_order
        )
        
        return paginated_response(
            data=result['recipes'],
            pagination=result['pagination'],
            message="Recipe collection retrieved successfully",
            metadata={
                'filters_applied': result.get('filters_applied', {}),
                'sort': result.get('sort', {})
            }
        )
        
    except ValueError as e:
        return error_response(str(e), 400)
    except Exception as e:
        current_app.logger.error(f"Error getting user recipe collection: {str(e)}")
        return error_response("Failed to retrieve recipe collection", 500)


@user_recipes_bp.route('/<user_recipe_id>', methods=['GET'])
@require_auth
def get_user_recipe(user_recipe_id: str):
    """Get a specific user recipe by ID"""
    try:
        user_id = get_current_user_id()
        
        recipe = user_recipe_service.get_user_recipe_by_id(user_recipe_id, user_id)
        
        if not recipe:
            return error_response("Recipe not found", 404)
        
        return success_response(recipe, "Recipe retrieved successfully")
        
    except ValueError as e:
        return error_response(str(e), 400)
    except Exception as e:
        current_app.logger.error(f"Error getting user recipe: {str(e)}")
        return error_response("Failed to retrieve recipe", 500)


@user_recipes_bp.route('/favorite/<recipe_id>', methods=['POST'])
@require_auth
def favorite_recipe(recipe_id: str):
    """Add a catalog recipe to user's favorites"""
    try:
        user_id = get_current_user_id()
        
        user_recipe = user_recipe_service.favorite_recipe(user_id, recipe_id)
        
        return success_response(
            user_recipe, 
            "Recipe added to favorites successfully", 
            status_code=201
        )
        
    except ValueError as e:
        return error_response(str(e), 400)
    except Exception as e:
        current_app.logger.error(f"Error favoriting recipe: {str(e)}")
        return error_response("Failed to favorite recipe", 500)


@user_recipes_bp.route('/favorite/<recipe_id>', methods=['DELETE'])
@require_auth
def unfavorite_recipe(recipe_id: str):
    """Remove a favorited recipe from user's collection"""
    try:
        user_id = get_current_user_id()
        
        success = user_recipe_service.unfavorite_recipe(user_id, recipe_id)
        
        if not success:
            return error_response("Recipe not found in favorites", 404)
        
        return success_response(
            {"recipe_id": recipe_id, "favorited": False},
            "Recipe removed from favorites successfully"
        )
        
    except ValueError as e:
        return error_response(str(e), 400)
    except Exception as e:
        current_app.logger.error(f"Error unfavoriting recipe: {str(e)}")
        return error_response("Failed to unfavorite recipe", 500)


@user_recipes_bp.route('/favorite-status/<recipe_id>', methods=['GET'])
@require_auth
def check_recipe_favorited(recipe_id: str):
    """Check if a recipe is in user's favorites"""
    try:
        user_id = get_current_user_id()
        
        is_favorited = user_recipe_service.check_recipe_favorited(user_id, recipe_id)
        
        return success_response(
            {"recipe_id": recipe_id, "favorited": is_favorited},
            "Favorite status retrieved successfully"
        )
        
    except Exception as e:
        current_app.logger.error(f"Error checking favorite status: {str(e)}")
        return error_response("Failed to check favorite status", 500)


# Custom Recipe Endpoints

@user_recipes_bp.route('/custom', methods=['POST'])
@require_auth
def create_custom_recipe():
    """Create a new custom recipe"""
    try:
        user_id = get_current_user_id()
        
        # Validate request data
        data = validate_request_json(request)
        
        # Create custom recipe
        user_recipe = user_recipe_service.create_custom_recipe(user_id, data)
        
        return success_response(
            user_recipe,
            "Custom recipe created successfully",
            status_code=201
        )
        
    except ValueError as e:
        return error_response(str(e), 400)
    except Exception as e:
        current_app.logger.error(f"Error creating custom recipe: {str(e)}")
        return error_response("Failed to create custom recipe", 500)


@user_recipes_bp.route('/<user_recipe_id>', methods=['PUT'])
@require_auth
def update_custom_recipe(user_recipe_id: str):
    """Update an existing custom recipe"""
    try:
        user_id = get_current_user_id()
        
        # Validate request data
        data = validate_request_json(request)
        
        # Update custom recipe
        user_recipe = user_recipe_service.update_custom_recipe(user_recipe_id, user_id, data)
        
        return success_response(user_recipe, "Recipe updated successfully")
        
    except ValueError as e:
        return error_response(str(e), 400)
    except Exception as e:
        current_app.logger.error(f"Error updating custom recipe: {str(e)}")
        return error_response("Failed to update recipe", 500)


@user_recipes_bp.route('/<user_recipe_id>', methods=['DELETE'])
@require_auth
def delete_user_recipe(user_recipe_id: str):
    """Delete a user recipe (custom or favorited)"""
    try:
        user_id = get_current_user_id()
        
        success = user_recipe_service.delete_user_recipe(user_recipe_id, user_id)
        
        if not success:
            return error_response("Recipe not found", 404)
        
        return success_response(
            {"recipe_id": user_recipe_id, "deleted": True},
            "Recipe deleted successfully"
        )
        
    except ValueError as e:
        return error_response(str(e), 400)
    except Exception as e:
        current_app.logger.error(f"Error deleting user recipe: {str(e)}")
        return error_response("Failed to delete recipe", 500)


@user_recipes_bp.route('/<user_recipe_id>/scale', methods=['POST'])
@require_auth
def scale_recipe(user_recipe_id: str):
    """Scale a recipe's ingredients and servings"""
    try:
        user_id = get_current_user_id()
        
        # Validate request data
        data = validate_request_json(request)
        
        if 'scale_factor' not in data:
            return error_response("scale_factor is required", 400)
        
        scale_factor = float(data['scale_factor'])
        
        if scale_factor <= 0:
            return error_response("scale_factor must be positive", 400)
        
        # Scale recipe
        scaled_data = user_recipe_service.scale_recipe(user_recipe_id, user_id, scale_factor)
        
        return success_response(
            scaled_data,
            f"Recipe scaled by factor of {scale_factor} successfully"
        )
        
    except ValueError as e:
        return error_response(str(e), 400)
    except Exception as e:
        current_app.logger.error(f"Error scaling recipe: {str(e)}")
        return error_response("Failed to scale recipe", 500)


# Category Management Endpoints

@user_recipes_bp.route('/categories', methods=['GET'])
@require_auth
def get_user_categories():
    """Get all categories for a user"""
    try:
        user_id = get_current_user_id()
        
        include_recipe_count = request.args.get('include_recipe_count', 'true').lower() == 'true'
        
        categories = user_recipe_service.get_user_categories(user_id, include_recipe_count)
        
        return success_response(categories, "Categories retrieved successfully")
        
    except ValueError as e:
        return error_response(str(e), 400)
    except Exception as e:
        current_app.logger.error(f"Error getting user categories: {str(e)}")
        return error_response("Failed to retrieve categories", 500)


@user_recipes_bp.route('/categories', methods=['POST'])
@require_auth
def create_category():
    """Create a new recipe category"""
    try:
        user_id = get_current_user_id()
        
        # Validate request data
        data = validate_request_json(request)
        
        if 'name' not in data:
            return error_response("Category name is required", 400)
        
        name = data['name']
        description = data.get('description')
        color = data.get('color')
        
        # Create category
        category = user_recipe_service.create_category(user_id, name, description, color)
        
        return success_response(
            category,
            "Category created successfully",
            status_code=201
        )
        
    except ValueError as e:
        return error_response(str(e), 400)
    except Exception as e:
        current_app.logger.error(f"Error creating category: {str(e)}")
        return error_response("Failed to create category", 500)


@user_recipes_bp.route('/categories/<category_id>', methods=['GET'])
@require_auth
def get_category(category_id: str):
    """Get a specific category by ID"""
    try:
        user_id = get_current_user_id()
        
        category = user_recipe_service.get_category_by_id(category_id, user_id)
        
        if not category:
            return error_response("Category not found", 404)
        
        return success_response(category, "Category retrieved successfully")
        
    except ValueError as e:
        return error_response(str(e), 400)
    except Exception as e:
        current_app.logger.error(f"Error getting category: {str(e)}")
        return error_response("Failed to retrieve category", 500)


@user_recipes_bp.route('/categories/<category_id>', methods=['PUT'])
@require_auth
def update_category(category_id: str):
    """Update an existing category"""
    try:
        user_id = get_current_user_id()
        
        # Validate request data
        data = validate_request_json(request)
        
        name = data.get('name')
        description = data.get('description')
        color = data.get('color')
        
        # Update category
        category = user_recipe_service.update_category(
            category_id, user_id, name, description, color
        )
        
        return success_response(category, "Category updated successfully")
        
    except ValueError as e:
        return error_response(str(e), 400)
    except Exception as e:
        current_app.logger.error(f"Error updating category: {str(e)}")
        return error_response("Failed to update category", 500)


@user_recipes_bp.route('/categories/<category_id>', methods=['DELETE'])
@require_auth
def delete_category(category_id: str):
    """Delete a category"""
    try:
        user_id = get_current_user_id()
        
        success = user_recipe_service.delete_category(category_id, user_id)
        
        if not success:
            return error_response("Category not found", 404)
        
        return success_response(
            {"category_id": category_id, "deleted": True},
            "Category deleted successfully"
        )
        
    except ValueError as e:
        return error_response(str(e), 400)
    except Exception as e:
        current_app.logger.error(f"Error deleting category: {str(e)}")
        return error_response("Failed to delete category", 500)


@user_recipes_bp.route('/<user_recipe_id>/categories', methods=['POST'])
@require_auth
def assign_categories_to_recipe(user_recipe_id: str):
    """Assign categories to a recipe"""
    try:
        user_id = get_current_user_id()
        
        # Validate request data
        data = validate_request_json(request)
        
        if 'category_ids' not in data or not isinstance(data['category_ids'], list):
            return error_response("category_ids must be a list", 400)
        
        category_ids = data['category_ids']
        
        # Assign categories
        success = user_recipe_service.assign_categories_to_recipe(
            user_recipe_id, category_ids, user_id
        )
        
        if not success:
            return error_response("Recipe not found", 404)
        
        return success_response(
            {"recipe_id": user_recipe_id, "category_ids": category_ids},
            "Categories assigned successfully"
        )
        
    except ValueError as e:
        return error_response(str(e), 400)
    except Exception as e:
        current_app.logger.error(f"Error assigning categories: {str(e)}")
        return error_response("Failed to assign categories", 500)


@user_recipes_bp.route('/categories/<category_id>/recipes', methods=['GET'])
@require_auth
def get_recipes_by_category(category_id: str):
    """Get all recipes in a specific category"""
    try:
        user_id = get_current_user_id()
        
        # Parse pagination parameters
        page = request.args.get('page', 1, type=int)
        page_size = request.args.get('page_size', 20, type=int)
        
        # Validate pagination params
        page, page_size = validate_pagination_params(page, page_size)
        
        # Get recipes by category
        result = user_recipe_service.get_recipes_by_category(
            category_id, user_id, page, page_size
        )
        
        return paginated_response(
            data=result['recipes'],
            pagination=result['pagination'],
            message="Category recipes retrieved successfully"
        )
        
    except ValueError as e:
        return error_response(str(e), 400)
    except Exception as e:
        current_app.logger.error(f"Error getting recipes by category: {str(e)}")
        return error_response("Failed to retrieve category recipes", 500)


@user_recipes_bp.route('/categories/defaults', methods=['POST'])
@require_auth
def create_default_categories():
    """Create default categories for a user"""
    try:
        user_id = get_current_user_id()
        
        categories = user_recipe_service.create_default_categories(user_id)
        
        return success_response(
            categories,
            "Default categories created successfully",
            status_code=201
        )
        
    except ValueError as e:
        return error_response(str(e), 400)
    except Exception as e:
        current_app.logger.error(f"Error creating default categories: {str(e)}")
        return error_response("Failed to create default categories", 500)


# Statistics and Analytics Endpoints

@user_recipes_bp.route('/stats', methods=['GET'])
@require_auth
def get_user_recipe_stats():
    """Get statistics about user's recipe collection"""
    try:
        user_id = get_current_user_id()
        
        stats = user_recipe_service.get_user_recipe_stats(user_id)
        
        return success_response(stats, "Recipe statistics retrieved successfully")
        
    except ValueError as e:
        return error_response(str(e), 400)
    except Exception as e:
        current_app.logger.error(f"Error getting recipe stats: {str(e)}")
        return error_response("Failed to retrieve recipe statistics", 500)


# Export and Sharing Endpoints

@user_recipes_bp.route('/<user_recipe_id>/export', methods=['GET'])
@require_auth
def export_recipe(user_recipe_id: str):
    """Export a recipe in specified format"""
    try:
        user_id = get_current_user_id()
        
        export_format = request.args.get('format', 'json').lower()
        
        if export_format not in ['json', 'text']:
            return error_response("Unsupported export format. Use 'json' or 'text'", 400)
        
        # Export recipe
        exported_data = user_recipe_service.export_recipe(
            user_recipe_id, user_id, export_format
        )
        
        # Set appropriate content type
        content_type = 'application/json' if export_format == 'json' else 'text/plain'
        
        return success_response(
            {"export_data": exported_data, "format": export_format},
            f"Recipe exported as {export_format} successfully",
            headers={'Content-Type': content_type}
        )
        
    except ValueError as e:
        return error_response(str(e), 400)
    except Exception as e:
        current_app.logger.error(f"Error exporting recipe: {str(e)}")
        return error_response("Failed to export recipe", 500)


@user_recipes_bp.route('/export', methods=['GET'])
@require_auth
def export_collection():
    """Export user's entire recipe collection or specific category"""
    try:
        user_id = get_current_user_id()
        
        export_format = request.args.get('format', 'json').lower()
        category_id = request.args.get('category_id')
        
        if export_format not in ['json', 'text']:
            return error_response("Unsupported export format. Use 'json' or 'text'", 400)
        
        # Export collection
        exported_data = user_recipe_service.export_collection(
            user_id, export_format, category_id
        )
        
        # Set appropriate content type
        content_type = 'application/json' if export_format == 'json' else 'text/plain'
        
        return success_response(
            {"export_data": exported_data, "format": export_format, "category_id": category_id},
            f"Recipe collection exported as {export_format} successfully",
            headers={'Content-Type': content_type}
        )
        
    except ValueError as e:
        return error_response(str(e), 400)
    except Exception as e:
        current_app.logger.error(f"Error exporting collection: {str(e)}")
        return error_response("Failed to export recipe collection", 500)


@user_recipes_bp.route('/<user_recipe_id>/share', methods=['POST'])
@require_auth
def share_recipe(user_recipe_id: str):
    """Generate shareable link for a recipe"""
    try:
        user_id = get_current_user_id()
        
        share_data = user_recipe_service.share_recipe(user_recipe_id, user_id)
        
        return success_response(share_data, "Recipe share link generated successfully")
        
    except ValueError as e:
        return error_response(str(e), 400)
    except Exception as e:
        current_app.logger.error(f"Error sharing recipe: {str(e)}")
        return error_response("Failed to generate share link", 500)


# Error Handlers

@user_recipes_bp.errorhandler(BadRequest)
def handle_bad_request(error):
    """Handle bad request errors"""
    return error_response("Invalid request data", 400)


@user_recipes_bp.errorhandler(404)
def handle_not_found(error):
    """Handle not found errors"""
    return error_response("Resource not found", 404)


@user_recipes_bp.errorhandler(500)
def handle_internal_error(error):
    """Handle internal server errors"""
    current_app.logger.error(f"Internal server error: {str(error)}")
    return error_response("Internal server error", 500) 