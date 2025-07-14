"""
Tutorial API Endpoints
Provides tutorial management, search, and progress tracking capabilities
"""

import logging
from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from typing import Optional, Dict, Any, List
from datetime import datetime

from services.tutorial_service import TutorialService
from core.exceptions import ValidationError, NotFoundError

logger = logging.getLogger(__name__)

tutorial_bp = Blueprint('tutorials', __name__)

@tutorial_bp.route('/tutorials', methods=['GET'])
@jwt_required()
def get_tutorials():
    """
    Get tutorials with optional filtering and pagination
    
    Query Parameters:
    - q: Search query (title, description, keywords)
    - category: Filter by category (knife_skills, cooking_methods, food_safety, etc.)
    - difficulty: Filter by difficulty (beginner, intermediate, advanced)
    - duration_max_minutes: Maximum duration in minutes
    - beginner_friendly: Filter for beginner-friendly tutorials (true/false)
    - page: Page number (default: 1)
    - limit: Results per page (default: 20, max: 50)
    """
    try:
        # Parse query parameters
        search_query = request.args.get('q', '').strip()
        category = request.args.get('category')
        difficulty = request.args.get('difficulty')
        duration_max_minutes = request.args.get('duration_max_minutes', type=int)
        beginner_friendly_str = request.args.get('beginner_friendly', '').lower()
        
        # Parse beginner_friendly boolean
        beginner_friendly = None
        if beginner_friendly_str in ['true', '1', 'yes']:
            beginner_friendly = True
        elif beginner_friendly_str in ['false', '0', 'no']:
            beginner_friendly = False
        
        # Pagination
        page = request.args.get('page', 1, type=int)
        limit = min(request.args.get('limit', 20, type=int), 50)
        
        # Validate pagination
        if page < 1:
            return jsonify({'error': 'Page must be >= 1'}), 400
        if limit < 1:
            return jsonify({'error': 'Limit must be >= 1'}), 400
        
        # Build filters dictionary
        filters = {}
        if category:
            filters['category'] = category
        if difficulty:
            filters['difficulty'] = difficulty
        if duration_max_minutes:
            filters['duration_max_minutes'] = duration_max_minutes
        if beginner_friendly is not None:
            filters['beginner_friendly'] = beginner_friendly
        
        # Get user ID for progress information
        user_id = get_jwt_identity()
        
        # Use service to search tutorials
        tutorial_service = TutorialService()
        result = tutorial_service.search_tutorials(
            search_query=search_query,
            filters=filters,
            page=page,
            limit=limit,
            user_id=user_id
        )
        
        # Convert tutorials to dict format with progress info
        tutorials_data = []
        for tutorial in result.tutorials:
            tutorial_dict = tutorial.to_dict(include_steps=False)  # Don't include full steps in list view
            
            # Add user progress if available
            if hasattr(tutorial, '_user_progress'):
                progress = tutorial._user_progress
                tutorial_dict['user_progress'] = {
                    'current_step': progress.current_step,
                    'completion_percentage': progress.completion_percentage,
                    'is_completed': progress.is_completed,
                    'time_spent_minutes': progress.time_spent_minutes,
                    'user_rating': progress.user_rating
                }
            
            tutorials_data.append(tutorial_dict)
        
        return jsonify({
            'tutorials': tutorials_data,
            'pagination': {
                'page': result.page,
                'limit': result.limit,
                'total_count': result.total_count,
                'total_pages': result.total_pages,
                'has_next': result.has_next,
                'has_previous': result.has_previous
            },
            'filters_applied': result.filters_applied,
            'search_query': search_query
        }), 200
        
    except ValidationError as e:
        logger.warning(f"Validation error in tutorial search: {str(e)}")
        return jsonify({'error': str(e)}), 400
    except Exception as e:
        logger.error(f"Error searching tutorials: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500

@tutorial_bp.route('/tutorials/<int:tutorial_id>', methods=['GET'])
@jwt_required()
def get_tutorial_details(tutorial_id: int):
    """Get detailed information for a specific tutorial"""
    try:
        user_id = get_jwt_identity()
        
        tutorial_service = TutorialService()
        tutorial = tutorial_service.get_tutorial_details(tutorial_id, user_id)
        
        if not tutorial:
            return jsonify({'error': 'Tutorial not found'}), 404
        
        # Convert to dict with full steps
        tutorial_dict = tutorial.to_dict(include_steps=True)
        
        # Add user progress if available
        if hasattr(tutorial, '_user_progress'):
            progress = tutorial._user_progress
            tutorial_dict['user_progress'] = progress.to_dict()
        
        return jsonify(tutorial_dict), 200
        
    except ValidationError as e:
        logger.warning(f"Validation error getting tutorial {tutorial_id}: {str(e)}")
        return jsonify({'error': str(e)}), 400
    except Exception as e:
        logger.error(f"Error getting tutorial {tutorial_id}: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500

@tutorial_bp.route('/tutorials/categories', methods=['GET'])
@jwt_required()
def get_tutorial_categories():
    """Get all available tutorial categories with counts"""
    try:
        tutorial_service = TutorialService()
        categories = tutorial_service.get_tutorial_categories()
        
        return jsonify({'categories': categories}), 200
        
    except Exception as e:
        logger.error(f"Error getting tutorial categories: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500

@tutorial_bp.route('/tutorials/search', methods=['GET'])
@jwt_required()
def search_tutorials():
    """
    Search tutorials by keywords and apply filters
    Same as GET /tutorials but with explicit search endpoint
    """
    return get_tutorials()

@tutorial_bp.route('/tutorials/<int:tutorial_id>/start', methods=['POST'])
@jwt_required()
def start_tutorial(tutorial_id: int):
    """Start a tutorial (create progress record)"""
    try:
        user_id = get_jwt_identity()
        
        tutorial_service = TutorialService()
        progress = tutorial_service.start_tutorial(user_id, tutorial_id)
        
        return jsonify({
            'message': 'Tutorial started successfully',
            'progress': progress.to_dict()
        }), 201
        
    except NotFoundError as e:
        logger.warning(f"Tutorial not found: {tutorial_id}")
        return jsonify({'error': str(e)}), 404
    except ValidationError as e:
        logger.warning(f"Validation error starting tutorial {tutorial_id}: {str(e)}")
        return jsonify({'error': str(e)}), 400
    except Exception as e:
        logger.error(f"Error starting tutorial {tutorial_id}: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500

@tutorial_bp.route('/tutorials/<int:tutorial_id>/complete', methods=['POST'])
@jwt_required()
def complete_tutorial_step(tutorial_id: int):
    """Mark a tutorial step as completed"""
    try:
        user_id = get_jwt_identity()
        
        # Get request data
        data = request.get_json()
        if not data or 'step_number' not in data:
            return jsonify({'error': 'step_number is required'}), 400
        
        step_number = data['step_number']
        if not isinstance(step_number, int) or step_number < 1:
            return jsonify({'error': 'step_number must be a positive integer'}), 400
        
        tutorial_service = TutorialService()
        progress = tutorial_service.mark_step_completed(user_id, tutorial_id, step_number)
        
        return jsonify({
            'message': f'Step {step_number} marked as completed',
            'progress': progress.to_dict()
        }), 200
        
    except NotFoundError as e:
        logger.warning(f"Tutorial not found: {tutorial_id}")
        return jsonify({'error': str(e)}), 404
    except ValidationError as e:
        logger.warning(f"Validation error completing step for tutorial {tutorial_id}: {str(e)}")
        return jsonify({'error': str(e)}), 400
    except Exception as e:
        logger.error(f"Error completing step for tutorial {tutorial_id}: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500

@tutorial_bp.route('/tutorials/<int:tutorial_id>/time', methods=['POST'])
@jwt_required()
def update_tutorial_time(tutorial_id: int):
    """Update time spent on tutorial"""
    try:
        user_id = get_jwt_identity()
        
        # Get request data
        data = request.get_json()
        if not data or 'minutes' not in data:
            return jsonify({'error': 'minutes is required'}), 400
        
        minutes = data['minutes']
        if not isinstance(minutes, int) or minutes < 0:
            return jsonify({'error': 'minutes must be a non-negative integer'}), 400
        
        tutorial_service = TutorialService()
        progress = tutorial_service.update_tutorial_time(user_id, tutorial_id, minutes)
        
        return jsonify({
            'message': f'Added {minutes} minutes to tutorial time',
            'progress': progress.to_dict()
        }), 200
        
    except ValidationError as e:
        logger.warning(f"Validation error updating time for tutorial {tutorial_id}: {str(e)}")
        return jsonify({'error': str(e)}), 400
    except Exception as e:
        logger.error(f"Error updating time for tutorial {tutorial_id}: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500

@tutorial_bp.route('/tutorials/<int:tutorial_id>/rate', methods=['POST'])
@jwt_required()
def rate_tutorial(tutorial_id: int):
    """Rate a tutorial"""
    try:
        user_id = get_jwt_identity()
        
        # Get request data
        data = request.get_json()
        if not data or 'rating' not in data:
            return jsonify({'error': 'rating is required'}), 400
        
        rating = data['rating']
        notes = data.get('notes')
        
        if not isinstance(rating, int) or not 1 <= rating <= 5:
            return jsonify({'error': 'rating must be an integer between 1 and 5'}), 400
        
        tutorial_service = TutorialService()
        progress = tutorial_service.rate_tutorial(user_id, tutorial_id, rating, notes)
        
        return jsonify({
            'message': f'Tutorial rated {rating} stars',
            'progress': progress.to_dict()
        }), 200
        
    except ValidationError as e:
        logger.warning(f"Validation error rating tutorial {tutorial_id}: {str(e)}")
        return jsonify({'error': str(e)}), 400
    except Exception as e:
        logger.error(f"Error rating tutorial {tutorial_id}: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500

@tutorial_bp.route('/tutorials/progress', methods=['GET'])
@jwt_required()
def get_user_progress():
    """Get user's tutorial progress summary"""
    try:
        user_id = get_jwt_identity()
        
        tutorial_service = TutorialService()
        summary = tutorial_service.get_user_progress_summary(user_id)
        
        # Convert progress objects to dictionaries
        completed_tutorials = [p.to_dict() for p in summary.completed_tutorials]
        in_progress_tutorials = [p.to_dict() for p in summary.in_progress_tutorials]
        
        return jsonify({
            'completed_count': summary.completed_count,
            'in_progress_count': summary.in_progress_count,
            'total_time_minutes': summary.total_time_minutes,
            'average_rating': summary.average_rating,
            'completed_tutorials': completed_tutorials,
            'in_progress_tutorials': in_progress_tutorials
        }), 200
        
    except Exception as e:
        logger.error(f"Error getting user progress: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500

@tutorial_bp.route('/tutorials/featured', methods=['GET'])
@jwt_required()
def get_featured_tutorials():
    """Get featured tutorials"""
    try:
        limit = min(request.args.get('limit', 10, type=int), 20)
        user_id = get_jwt_identity()
        
        tutorial_service = TutorialService()
        tutorials = tutorial_service.get_featured_tutorials(limit, user_id)
        
        # Convert to dict format with progress info
        tutorials_data = []
        for tutorial in tutorials:
            tutorial_dict = tutorial.to_dict(include_steps=False)
            
            # Add user progress if available
            if hasattr(tutorial, '_user_progress'):
                progress = tutorial._user_progress
                tutorial_dict['user_progress'] = {
                    'current_step': progress.current_step,
                    'completion_percentage': progress.completion_percentage,
                    'is_completed': progress.is_completed,
                    'time_spent_minutes': progress.time_spent_minutes,
                    'user_rating': progress.user_rating
                }
            
            tutorials_data.append(tutorial_dict)
        
        return jsonify({'tutorials': tutorials_data}), 200
        
    except Exception as e:
        logger.error(f"Error getting featured tutorials: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500

@tutorial_bp.route('/tutorials/beginner-friendly', methods=['GET'])
@jwt_required()
def get_beginner_friendly_tutorials():
    """Get beginner-friendly tutorials"""
    try:
        limit = min(request.args.get('limit', 10, type=int), 20)
        user_id = get_jwt_identity()
        
        tutorial_service = TutorialService()
        tutorials = tutorial_service.get_beginner_friendly_tutorials(limit, user_id)
        
        # Convert to dict format with progress info
        tutorials_data = []
        for tutorial in tutorials:
            tutorial_dict = tutorial.to_dict(include_steps=False)
            
            # Add user progress if available
            if hasattr(tutorial, '_user_progress'):
                progress = tutorial._user_progress
                tutorial_dict['user_progress'] = {
                    'current_step': progress.current_step,
                    'completion_percentage': progress.completion_percentage,
                    'is_completed': progress.is_completed,
                    'time_spent_minutes': progress.time_spent_minutes,
                    'user_rating': progress.user_rating
                }
            
            tutorials_data.append(tutorial_dict)
        
        return jsonify({'tutorials': tutorials_data}), 200
        
    except Exception as e:
        logger.error(f"Error getting beginner-friendly tutorials: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500

@tutorial_bp.route('/tutorials/recommendations', methods=['GET'])
@jwt_required()
def get_tutorial_recommendations():
    """Get personalized tutorial recommendations for user"""
    try:
        limit = min(request.args.get('limit', 10, type=int), 20)
        user_id = get_jwt_identity()
        
        tutorial_service = TutorialService()
        tutorials = tutorial_service.get_recommended_tutorials_for_user(user_id, limit)
        
        # Convert to dict format with progress info
        tutorials_data = []
        for tutorial in tutorials:
            tutorial_dict = tutorial.to_dict(include_steps=False)
            
            # Add user progress if available
            if hasattr(tutorial, '_user_progress'):
                progress = tutorial._user_progress
                tutorial_dict['user_progress'] = {
                    'current_step': progress.current_step,
                    'completion_percentage': progress.completion_percentage,
                    'is_completed': progress.is_completed,
                    'time_spent_minutes': progress.time_spent_minutes,
                    'user_rating': progress.user_rating
                }
            
            tutorials_data.append(tutorial_dict)
        
        return jsonify({'tutorials': tutorials_data}), 200
        
    except Exception as e:
        logger.error(f"Error getting tutorial recommendations: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500

@tutorial_bp.route('/tutorials/filters/options', methods=['GET'])
@jwt_required()
def get_filter_options():
    """Get available filter options for tutorial search"""
    try:
        tutorial_service = TutorialService()
        options = tutorial_service.get_filter_options()
        
        return jsonify(options), 200
        
    except Exception as e:
        logger.error(f"Error getting filter options: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500 