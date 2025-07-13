"""
Pantry API Endpoints
Flask routes for pantry item management
"""

import logging
from datetime import datetime
from flask import Blueprint, request, jsonify, g
from flask_jwt_extended import jwt_required, get_jwt_identity
from pydantic import ValidationError as PydanticValidationError

from api.schemas.pantry_schemas import (
    PantryItemCreateRequest,
    PantryItemUpdateRequest,
    PantryItemResponse,
    PantryItemListResponse,
    PantryStatsResponse
)
from services.pantry_service import PantryService
from core.exceptions import (
    AppError,
    ValidationError,
    NotFoundError,
    AuthorizationError
)

# Set up logging
logger = logging.getLogger(__name__)

# Create Blueprint
pantry_bp = Blueprint('pantry', __name__, url_prefix='/api/v1/pantry')


@pantry_bp.route('', methods=['POST'])
@jwt_required()
def create_pantry_item():
    """Create a new pantry item"""
    try:
        user_id = get_jwt_identity()
        data = request.get_json()
        
        if not data:
            return jsonify({'error': 'Request body is required'}), 400
        
        # Validate request data
        try:
            create_request = PantryItemCreateRequest(**data)
        except PydanticValidationError as e:
            return jsonify({
                'error': 'Validation failed',
                'details': e.errors()
            }), 400
        
        # Create pantry item
        pantry_service = PantryService()
        pantry_item = pantry_service.add_pantry_item(
            user_id=user_id,
            name=create_request.name,
            quantity=create_request.quantity,
            unit=create_request.unit,
            expiry_date=create_request.expiry_date,
            category=create_request.category,
            notes=create_request.notes
        )
        
        # Return response
        response_data = PantryItemResponse(**pantry_item.to_dict())
        return jsonify({
            'message': 'Pantry item created successfully',
            'data': response_data.dict()
        }), 201
        
    except ValidationError as e:
        logger.warning(f"Validation error creating pantry item: {str(e)}")
        return jsonify({'error': str(e)}), 400
    except AppError as e:
        logger.error(f"Database error creating pantry item: {str(e)}")
        return jsonify({'error': 'Failed to create pantry item'}), 500
    except Exception as e:
        logger.error(f"Unexpected error creating pantry item: {str(e)}")
        return jsonify({'error': 'An unexpected error occurred'}), 500


@pantry_bp.route('', methods=['GET'])
@jwt_required()
def get_pantry_items():
    """Get user's pantry items with pagination and filtering"""
    try:
        user_id = get_jwt_identity()
        
        # Get query parameters
        page = request.args.get('page', 1, type=int)
        page_size = request.args.get('page_size', 20, type=int)
        category = request.args.get('category')
        expired_only = request.args.get('expired_only', 'false').lower() == 'true'
        expiring_soon = request.args.get('expiring_soon', 'false').lower() == 'true'
        search = request.args.get('search')
        sort_by = request.args.get('sort_by', 'name')
        sort_order = request.args.get('sort_order', 'asc')
        
        # Validate parameters
        if page < 1:
            page = 1
        if page_size < 1 or page_size > 100:
            page_size = 20
        
        # Get pantry items
        pantry_service = PantryService()
        items, pagination_info = pantry_service.get_user_pantry(
            user_id=user_id,
            page=page,
            page_size=page_size,
            category=category,
            expired_only=expired_only,
            expiring_soon=expiring_soon,
            search=search,
            sort_by=sort_by,
            sort_order=sort_order
        )
        
        # Convert to response format
        item_responses = [PantryItemResponse(**item.to_dict()) for item in items]
        response_data = PantryItemListResponse(
            items=[item.dict() for item in item_responses],
            **pagination_info
        )
        
        return jsonify({
            'message': 'Pantry items retrieved successfully',
            'data': response_data.dict()
        }), 200
        
    except ValidationError as e:
        logger.warning(f"Validation error getting pantry items: {str(e)}")
        return jsonify({'error': str(e)}), 400
    except AppError as e:
        logger.error(f"Database error getting pantry items: {str(e)}")
        return jsonify({'error': 'Failed to retrieve pantry items'}), 500
    except Exception as e:
        logger.error(f"Unexpected error getting pantry items: {str(e)}")
        return jsonify({'error': 'An unexpected error occurred'}), 500


@pantry_bp.route('/<item_id>', methods=['GET'])
@jwt_required()
def get_pantry_item(item_id):
    """Get a specific pantry item"""
    try:
        user_id = get_jwt_identity()
        
        # Get pantry item
        pantry_service = PantryService()
        pantry_item = pantry_service.get_pantry_item(item_id, user_id)
        
        # Return response
        response_data = PantryItemResponse(**pantry_item.to_dict())
        return jsonify({
            'message': 'Pantry item retrieved successfully',
            'data': response_data.dict()
        }), 200
        
    except NotFoundError as e:
        logger.warning(f"Pantry item not found: {str(e)}")
        return jsonify({'error': 'Pantry item not found'}), 404
    except ValidationError as e:
        logger.warning(f"Validation error getting pantry item: {str(e)}")
        return jsonify({'error': str(e)}), 400
    except AppError as e:
        logger.error(f"Database error getting pantry item: {str(e)}")
        return jsonify({'error': 'Failed to retrieve pantry item'}), 500
    except Exception as e:
        logger.error(f"Unexpected error getting pantry item: {str(e)}")
        return jsonify({'error': 'An unexpected error occurred'}), 500


@pantry_bp.route('/<item_id>', methods=['PUT'])
@jwt_required()
def update_pantry_item(item_id):
    """Update a pantry item"""
    try:
        user_id = get_jwt_identity()
        data = request.get_json()
        
        if not data:
            return jsonify({'error': 'Request body is required'}), 400
        
        # Validate request data
        try:
            update_request = PantryItemUpdateRequest(**data)
        except PydanticValidationError as e:
            return jsonify({
                'error': 'Validation failed',
                'details': e.errors()
            }), 400
        
        # Prepare updates (only include non-None fields)
        updates = {}
        for field, value in update_request.dict().items():
            if value is not None:
                updates[field] = value
        
        if not updates:
            return jsonify({'error': 'No valid fields to update'}), 400
        
        # Update pantry item
        pantry_service = PantryService()
        pantry_item = pantry_service.update_pantry_item(item_id, user_id, **updates)
        
        # Return response
        response_data = PantryItemResponse(**pantry_item.to_dict())
        return jsonify({
            'message': 'Pantry item updated successfully',
            'data': response_data.dict()
        }), 200
        
    except NotFoundError as e:
        logger.warning(f"Pantry item not found for update: {str(e)}")
        return jsonify({'error': 'Pantry item not found'}), 404
    except ValidationError as e:
        logger.warning(f"Validation error updating pantry item: {str(e)}")
        return jsonify({'error': str(e)}), 400
    except AppError as e:
        logger.error(f"Database error updating pantry item: {str(e)}")
        return jsonify({'error': 'Failed to update pantry item'}), 500
    except Exception as e:
        logger.error(f"Unexpected error updating pantry item: {str(e)}")
        return jsonify({'error': 'An unexpected error occurred'}), 500


@pantry_bp.route('/<item_id>', methods=['DELETE'])
@jwt_required()
def delete_pantry_item(item_id):
    """Delete a pantry item"""
    try:
        user_id = get_jwt_identity()
        
        # Delete pantry item
        pantry_service = PantryService()
        success = pantry_service.delete_pantry_item(item_id, user_id)
        
        return jsonify({
            'message': 'Pantry item deleted successfully'
        }), 200
        
    except NotFoundError as e:
        logger.warning(f"Pantry item not found for deletion: {str(e)}")
        return jsonify({'error': 'Pantry item not found'}), 404
    except ValidationError as e:
        logger.warning(f"Validation error deleting pantry item: {str(e)}")
        return jsonify({'error': str(e)}), 400
    except AppError as e:
        logger.error(f"Database error deleting pantry item: {str(e)}")
        return jsonify({'error': 'Failed to delete pantry item'}), 500
    except Exception as e:
        logger.error(f"Unexpected error deleting pantry item: {str(e)}")
        return jsonify({'error': 'An unexpected error occurred'}), 500


@pantry_bp.route('/stats', methods=['GET'])
@jwt_required()
def get_pantry_stats():
    """Get pantry statistics for the user"""
    try:
        user_id = get_jwt_identity()
        
        # Get pantry statistics
        pantry_service = PantryService()
        stats = pantry_service.get_pantry_statistics(user_id)
        
        # Return response
        response_data = PantryStatsResponse(**stats)
        return jsonify({
            'message': 'Pantry statistics retrieved successfully',
            'data': response_data.dict()
        }), 200
        
    except AppError as e:
        logger.error(f"Database error getting pantry stats: {str(e)}")
        return jsonify({'error': 'Failed to retrieve pantry statistics'}), 500
    except Exception as e:
        logger.error(f"Unexpected error getting pantry stats: {str(e)}")
        return jsonify({'error': 'An unexpected error occurred'}), 500


@pantry_bp.route('/cleanup', methods=['POST'])
@jwt_required()
def cleanup_expired_items():
    """Remove all expired items from user's pantry"""
    try:
        user_id = get_jwt_identity()
        
        # Cleanup expired items
        pantry_service = PantryService()
        deleted_count = pantry_service.cleanup_expired_items(user_id)
        
        return jsonify({
            'message': f'Successfully removed {deleted_count} expired item(s)',
            'deleted_count': deleted_count
        }), 200
        
    except AppError as e:
        logger.error(f"Database error cleaning up expired items: {str(e)}")
        return jsonify({'error': 'Failed to cleanup expired items'}), 500
    except Exception as e:
        logger.error(f"Unexpected error cleaning up expired items: {str(e)}")
        return jsonify({'error': 'An unexpected error occurred'}), 500


@pantry_bp.route('/expiring', methods=['GET'])
@jwt_required()
def get_expiring_items():
    """Get items expiring within specified days"""
    try:
        user_id = get_jwt_identity()
        days_ahead = request.args.get('days', 3, type=int)
        
        # Validate days parameter
        if days_ahead < 0 or days_ahead > 30:
            days_ahead = 3
        
        # Get expiring items
        pantry_service = PantryService()
        items = pantry_service.get_expiring_items(user_id, days_ahead)
        
        # Convert to response format
        item_responses = [PantryItemResponse(**item.to_dict()) for item in items]
        
        return jsonify({
            'message': f'Items expiring within {days_ahead} days retrieved successfully',
            'data': {
                'items': [item.dict() for item in item_responses],
                'count': len(item_responses),
                'days_ahead': days_ahead
            }
        }), 200
        
    except AppError as e:
        logger.error(f"Database error getting expiring items: {str(e)}")
        return jsonify({'error': 'Failed to retrieve expiring items'}), 500
    except Exception as e:
        logger.error(f"Unexpected error getting expiring items: {str(e)}")
        return jsonify({'error': 'An unexpected error occurred'}), 500


# Error handlers
@pantry_bp.errorhandler(404)
def not_found(error):
    return jsonify({'error': 'Endpoint not found'}), 404


@pantry_bp.errorhandler(405)
def method_not_allowed(error):
    return jsonify({'error': 'Method not allowed'}), 405


@pantry_bp.errorhandler(500)
def internal_error(error):
    logger.error(f"Internal server error in pantry API: {str(error)}")
    return jsonify({'error': 'Internal server error'}), 500 