"""
Recipe Discovery API Endpoints
Provides search, filtering, and browsing capabilities for recipe catalog
"""

import logging
from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from typing import Optional, Dict, Any, List
from datetime import datetime

from services.recipe_discovery_service import RecipeDiscoveryService
from core.exceptions import ValidationError

logger = logging.getLogger(__name__)

recipe_bp = Blueprint('recipes', __name__)

@recipe_bp.route('/recipes/search', methods=['GET'])
@jwt_required()
def search_recipes():
    """
    Search and filter recipes with pagination
    
    Query Parameters:
    - q: Search query (name, description, ingredients)
    - meal_type: Filter by meal type (breakfast, lunch, dinner, snack, dessert)
    - cuisine_type: Filter by cuisine (Italian, Asian, Mexican, etc.)
    - dietary_restrictions: Comma-separated list (vegan, vegetarian, gluten-free, etc.)
    - difficulty_level: Filter by difficulty (beginner, intermediate, advanced)
    - max_prep_time: Maximum preparation time in minutes
    - min_cost_usd: Minimum cost in USD
    - max_cost_usd: Maximum cost in USD
    - page: Page number (default: 1)
    - limit: Results per page (default: 20, max: 50)
    - sort_by: Sort field (name, prep_time, cost, difficulty)
    - sort_order: Sort order (asc, desc)
    """
    try:
        # Parse query parameters
        search_query = request.args.get('q', '').strip()
        meal_type = request.args.get('meal_type')
        cuisine_type = request.args.get('cuisine_type')
        dietary_restrictions_str = request.args.get('dietary_restrictions', '')
        dietary_restrictions = [dr.strip() for dr in dietary_restrictions_str.split(',') if dr.strip()]
        difficulty_level = request.args.get('difficulty_level')
        
        # Time and cost filters
        max_prep_time = request.args.get('max_prep_time', type=int)
        min_cost_usd = request.args.get('min_cost_usd', type=float)
        max_cost_usd = request.args.get('max_cost_usd', type=float)
        
        # Pagination
        page = request.args.get('page', 1, type=int)
        limit = min(request.args.get('limit', 20, type=int), 50)
        
        # Sorting
        sort_by = request.args.get('sort_by', 'name')
        sort_order = request.args.get('sort_order', 'asc')
        
        # Validate pagination
        if page < 1:
            return jsonify({'error': 'Page must be >= 1'}), 400
        if limit < 1:
            return jsonify({'error': 'Limit must be >= 1'}), 400
        
        # Validate sort parameters
        valid_sort_fields = ['name', 'prep_time', 'cost', 'difficulty', 'created_at']
        if sort_by not in valid_sort_fields:
            return jsonify({'error': f'Invalid sort_by. Must be one of: {valid_sort_fields}'}), 400
        
        if sort_order not in ['asc', 'desc']:
            return jsonify({'error': 'Invalid sort_order. Must be asc or desc'}), 400
        
        # Build filters dictionary
        filters = {}
        if meal_type:
            filters['meal_type'] = meal_type
        if cuisine_type:
            filters['cuisine_type'] = cuisine_type
        if dietary_restrictions:
            filters['dietary_restrictions'] = dietary_restrictions
        if difficulty_level:
            filters['difficulty_level'] = difficulty_level
        if max_prep_time:
            filters['max_prep_time'] = max_prep_time
        if min_cost_usd is not None:
            filters['min_cost_usd'] = min_cost_usd
        if max_cost_usd is not None:
            filters['max_cost_usd'] = max_cost_usd
        
        # Get user ID for potential personalization
        user_id = get_jwt_identity()
        
        # Use service to search recipes
        recipe_service = RecipeDiscoveryService()
        result = recipe_service.search_recipes(
            search_query=search_query,
            filters=filters,
            page=page,
            limit=limit,
            sort_by=sort_by,
            sort_order=sort_order,
            user_id=user_id
        )
        
        return jsonify({
            'recipes': [recipe.to_dict() for recipe in result.recipes],
            'pagination': {
                'page': result.page,
                'limit': result.limit,
                'total_count': result.total_count,
                'total_pages': result.total_pages,
                'has_next': result.has_next,
                'has_previous': result.has_previous
            },
            'filters_applied': result.filters_applied,
            'search_query': search_query,
            'sort': {
                'sort_by': sort_by,
                'sort_order': sort_order
            }
        }), 200
        
    except ValidationError as e:
        logger.warning(f"Validation error in recipe search: {str(e)}")
        return jsonify({'error': str(e)}), 400
    except Exception as e:
        logger.error(f"Error searching recipes: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500

@recipe_bp.route('/recipes/<recipe_id>', methods=['GET'])
def get_recipe_details(recipe_id: str):
    """Get detailed information for a specific recipe"""
    try:
        # Get user ID if authenticated, otherwise None for public access
        user_id = None
        try:
            user_id = get_jwt_identity()
        except:
            pass  # Not authenticated, continue with public access
        
        recipe_service = RecipeDiscoveryService()
        recipe = recipe_service.get_recipe_details(recipe_id, user_id)
        
        if not recipe:
            return jsonify({'error': 'Recipe not found'}), 404
        
        return jsonify(recipe.to_dict()), 200
        
    except ValidationError as e:
        logger.warning(f"Validation error getting recipe {recipe_id}: {str(e)}")
        return jsonify({'error': str(e)}), 400
    except Exception as e:
        logger.error(f"Error getting recipe {recipe_id}: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500

@recipe_bp.route('/recipes/filters/options', methods=['GET'])
@jwt_required()
def get_filter_options():
    """Get available filter options for the recipe catalog"""
    try:
        recipe_service = RecipeDiscoveryService()
        options = recipe_service.get_filter_options()
        
        return jsonify(options), 200
        
    except Exception as e:
        logger.error(f"Error getting filter options: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500

@recipe_bp.route('/recipes/suggestions', methods=['GET'])
@jwt_required()
def get_search_suggestions():
    """Get search suggestions based on partial query"""
    try:
        query = request.args.get('q', '').strip()
        limit = min(request.args.get('limit', 10, type=int), 20)
        
        if len(query) < 2:
            return jsonify({'suggestions': []}), 200
        
        user_id = get_jwt_identity()
        recipe_service = RecipeDiscoveryService()
        suggestions = recipe_service.get_search_suggestions(query, limit, user_id)
        
        return jsonify({'suggestions': suggestions}), 200
        
    except Exception as e:
        logger.error(f"Error getting search suggestions: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500

@recipe_bp.route('/recipes/trending', methods=['GET'])
@jwt_required()
def get_trending_recipes():
    """Get trending/popular recipes"""
    try:
        limit = min(request.args.get('limit', 10, type=int), 20)
        user_id = get_jwt_identity()
        
        recipe_service = RecipeDiscoveryService()
        trending_recipes = recipe_service.get_trending_recipes(limit, user_id)
        
        return jsonify({
            'trending_recipes': [recipe.to_dict() for recipe in trending_recipes]
        }), 200
        
    except Exception as e:
        logger.error(f"Error getting trending recipes: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500

@recipe_bp.route('/recipes/personalized', methods=['GET'])
@jwt_required()
def get_personalized_recommendations():
    """Get personalized recipe recommendations for the user"""
    try:
        limit = min(request.args.get('limit', 10, type=int), 20)
        user_id = get_jwt_identity()
        
        recipe_service = RecipeDiscoveryService()
        recommendations = recipe_service.get_personalized_recommendations(user_id, limit)
        
        return jsonify({
            'recommended_recipes': [recipe.to_dict() for recipe in recommendations]
        }), 200
        
    except Exception as e:
        logger.error(f"Error getting personalized recommendations: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500

@recipe_bp.route('/recipes/<recipe_id>/scale', methods=['POST'])
@jwt_required()
def scale_recipe(recipe_id: str):
    """Scale a recipe by a given factor
    
    Request Body:
    - scale_factor: float - The scaling factor (e.g., 2.0 for double, 0.5 for half)
    """
    try:
        user_id = get_jwt_identity()
        data = request.get_json()
        
        if not data or 'scale_factor' not in data:
            return jsonify({'error': 'scale_factor is required'}), 400
        
        scale_factor = data['scale_factor']
        
        if not isinstance(scale_factor, (int, float)) or scale_factor <= 0:
            return jsonify({'error': 'scale_factor must be a positive number'}), 400
        
        # Get the recipe
        recipe_service = RecipeDiscoveryService()
        recipe = recipe_service.get_recipe_details(recipe_id, user_id)
        
        if not recipe:
            return jsonify({'error': 'Recipe not found'}), 404
        
        # Scale the recipe
        scaled_data = recipe.scale_recipe(scale_factor)
        
        # Return the scaled recipe data along with original recipe info
        return jsonify({
            'recipe_id': recipe_id,
            'original_servings': recipe.servings,
            'scale_factor': scale_factor,
            'scaled_data': scaled_data
        }), 200
        
    except ValueError as e:
        logger.warning(f"Validation error scaling recipe {recipe_id}: {str(e)}")
        return jsonify({'error': str(e)}), 400
    except Exception as e:
        logger.error(f"Error scaling recipe {recipe_id}: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500 