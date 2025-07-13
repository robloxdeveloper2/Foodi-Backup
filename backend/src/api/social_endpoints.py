"""
Social Endpoints
API endpoints for user social profiles, connections, and activity feeds
"""

import logging
from flask import Blueprint, request, jsonify, current_app
from flask_jwt_extended import jwt_required, get_jwt_identity
from marshmallow import Schema, fields, ValidationError

from services.social_service import SocialService
from api.schemas.social_schemas import (
    UserProfileResponseSchema, UserProfileUpdateSchema,
    ConnectionRequestResponseSchema, SearchUsersResponseSchema,
    ActivityFeedResponseSchema, ConnectionsResponseSchema
)

logger = logging.getLogger(__name__)

# Create blueprint for social endpoints
social_bp = Blueprint('social', __name__)

# Initialize schemas
user_profile_response_schema = UserProfileResponseSchema()
user_profile_update_schema = UserProfileUpdateSchema()
connection_request_response_schema = ConnectionRequestResponseSchema()
search_users_response_schema = SearchUsersResponseSchema()
activity_feed_response_schema = ActivityFeedResponseSchema()
connections_response_schema = ConnectionsResponseSchema()


@social_bp.route('/users/me/profile', methods=['GET'])
@jwt_required()
def get_my_profile():
    """Get current user's social profile"""
    try:
        user_id = get_jwt_identity()
        social_service = SocialService()
        
        profile = social_service.get_user_profile(user_id)
        if not profile:
            # Create a default profile if none exists
            profile_data = {'display_name': None}
            profile = social_service.create_user_profile(user_id, profile_data)
        
        response_data = user_profile_response_schema.dump(profile.to_dict())
        return jsonify(response_data), 200
        
    except Exception as e:
        logger.error(f"Error getting profile for user {user_id}: {str(e)}")
        return jsonify({'error': 'Failed to get profile'}), 500


@social_bp.route('/users/me/profile', methods=['PUT'])
@jwt_required()
def update_my_profile():
    """Update current user's social profile"""
    try:
        user_id = get_jwt_identity()
        
        # Validate request data
        try:
            profile_data = user_profile_update_schema.load(request.get_json())
        except ValidationError as e:
            return jsonify({'error': 'Invalid input', 'details': e.messages}), 400
        
        social_service = SocialService()
        
        # Check if profile exists, create if not
        existing_profile = social_service.get_user_profile(user_id)
        if not existing_profile:
            updated_profile = social_service.create_user_profile(user_id, profile_data)
        else:
            updated_profile = social_service.update_user_profile(user_id, profile_data)
        
        response_data = user_profile_response_schema.dump(updated_profile.to_dict())
        return jsonify(response_data), 200
        
    except Exception as e:
        logger.error(f"Error updating profile for user {user_id}: {str(e)}")
        return jsonify({'error': 'Failed to update profile'}), 500


@social_bp.route('/users/search', methods=['GET'])
@jwt_required()
def search_users():
    """Search for users by name or username"""
    try:
        query = request.args.get('q', '').strip()
        page = request.args.get('page', 1, type=int)
        limit = min(request.args.get('limit', 20, type=int), 50)
        
        if len(query) < 2:
            return jsonify({'users': [], 'total_count': 0, 'page': page, 'total_pages': 0}), 200
        
        social_service = SocialService()
        result = social_service.search_users(query, page, limit)
        
        # Convert profiles to dict format
        users_data = []
        for profile in result.items:
            profile_dict = profile.to_dict(include_user=True)
            # Add connection status information
            profile_dict['is_current_user'] = False
            profile_dict['is_connected'] = False
            profile_dict['has_request_pending'] = False
            users_data.append(profile_dict)
        
        response_data = {
            'users': users_data,
            'total_count': result.total_count,
            'page': result.page,
            'total_pages': result.total_pages
        }
        
        return jsonify(response_data), 200
        
    except Exception as e:
        logger.error(f"Error searching users with query '{query}': {str(e)}")
        return jsonify({'error': 'Failed to search users'}), 500


@social_bp.route('/users/<user_id>/connection-request', methods=['POST'])
@jwt_required()
def send_connection_request(user_id: str):
    """Send a connection request to another user"""
    try:
        sender_id = get_jwt_identity()
        
        if sender_id == user_id:
            return jsonify({'error': 'Cannot connect to yourself'}), 400
        
        # Get optional message from request body
        data = request.get_json() or {}
        message = data.get('message')
        
        social_service = SocialService()
        connection_request = social_service.send_connection_request(sender_id, user_id, message)
        
        response_data = connection_request_response_schema.dump(connection_request.to_dict())
        return jsonify(response_data), 201
        
    except ValueError as e:
        return jsonify({'error': str(e)}), 400
    except Exception as e:
        logger.error(f"Error sending connection request from {sender_id} to {user_id}: {str(e)}")
        return jsonify({'error': 'Failed to send connection request'}), 500


@social_bp.route('/users/me/connection-requests', methods=['GET'])
@jwt_required()
def get_connection_requests():
    """Get pending connection requests for current user"""
    try:
        user_id = get_jwt_identity()
        request_type = request.args.get('type', 'received')  # 'received' or 'sent'
        
        if request_type not in ['received', 'sent']:
            return jsonify({'error': 'Invalid request type. Must be "received" or "sent"'}), 400
        
        social_service = SocialService()
        requests = social_service.get_connection_requests(user_id, request_type)
        
        requests_data = []
        for req in requests:
            req_dict = req.to_dict(include_profiles=True)
            requests_data.append(req_dict)
        
        return jsonify({'requests': requests_data}), 200
        
    except Exception as e:
        logger.error(f"Error getting {request_type} connection requests for {user_id}: {str(e)}")
        return jsonify({'error': 'Failed to get connection requests'}), 500


@social_bp.route('/connection-requests/<request_id>/respond', methods=['POST'])
@jwt_required()
def respond_to_connection_request(request_id: str):
    """Accept or decline a connection request"""
    try:
        user_id = get_jwt_identity()
        data = request.get_json()
        
        if not data or 'action' not in data:
            return jsonify({'error': 'Missing action in request body'}), 400
        
        action = data.get('action')  # 'accept' or 'decline'
        
        if action not in ['accept', 'decline']:
            return jsonify({'error': 'Invalid action. Must be "accept" or "decline"'}), 400
        
        social_service = SocialService()
        success = social_service.respond_to_connection_request(request_id, user_id, action)
        
        if success:
            return jsonify({'success': True, 'action': action}), 200
        else:
            return jsonify({'error': 'Failed to process request'}), 500
        
    except ValueError as e:
        return jsonify({'error': str(e)}), 400
    except Exception as e:
        logger.error(f"Error responding to connection request {request_id}: {str(e)}")
        return jsonify({'error': 'Failed to respond to connection request'}), 500


@social_bp.route('/users/me/connections', methods=['GET'])
@jwt_required()
def get_my_connections():
    """Get current user's connections (friends)"""
    try:
        user_id = get_jwt_identity()
        page = request.args.get('page', 1, type=int)
        limit = min(request.args.get('limit', 20, type=int), 50)
        
        social_service = SocialService()
        result = social_service.get_user_connections(user_id, page, limit)
        
        # Convert profiles to dict format
        connections_data = []
        for profile in result.items:
            profile_dict = profile.to_dict(include_user=True)
            # Mark as connected
            profile_dict['is_current_user'] = False
            profile_dict['is_connected'] = True
            profile_dict['has_request_pending'] = False
            connections_data.append(profile_dict)
        
        response_data = {
            'connections': connections_data,
            'total_count': result.total_count,
            'page': result.page,
            'total_pages': result.total_pages
        }
        
        return jsonify(response_data), 200
        
    except Exception as e:
        logger.error(f"Error getting connections for user {user_id}: {str(e)}")
        return jsonify({'error': 'Failed to get connections'}), 500


@social_bp.route('/users/me/activity-feed', methods=['GET'])
@jwt_required()
def get_activity_feed():
    """Get activity feed for current user"""
    try:
        user_id = get_jwt_identity()
        page = request.args.get('page', 1, type=int)
        limit = min(request.args.get('limit', 20, type=int), 50)
        
        social_service = SocialService()
        result = social_service.get_activity_feed(user_id, page, limit)
        
        # Convert activities to dict format
        activities_data = []
        for activity in result.items:
            activity_dict = activity.to_dict(include_user=True)
            activities_data.append(activity_dict)
        
        response_data = {
            'activities': activities_data,
            'total_count': result.total_count,
            'page': result.page,
            'total_pages': result.total_pages
        }
        
        return jsonify(response_data), 200
        
    except Exception as e:
        logger.error(f"Error getting activity feed for user {user_id}: {str(e)}")
        return jsonify({'error': 'Failed to get activity feed'}), 500


@social_bp.route('/users/<user_id>/profile', methods=['GET'])
@jwt_required()
def get_user_profile(user_id: str):
    """Get another user's social profile"""
    try:
        current_user_id = get_jwt_identity()
        social_service = SocialService()
        
        profile = social_service.get_user_profile(user_id)
        if not profile:
            return jsonify({'error': 'Profile not found'}), 404
        
        # Check if profile is public or if users are connected
        if not profile.is_public and current_user_id != user_id:
            # Check if users are connected
            repository = social_service.repository
            are_connected = repository.are_users_connected(current_user_id, user_id)
            if not are_connected:
                return jsonify({'error': 'Profile is private'}), 403
        
        profile_dict = profile.to_dict(include_user=True)
        
        # Add connection status information
        profile_dict['is_current_user'] = (current_user_id == user_id)
        profile_dict['is_connected'] = False
        profile_dict['has_request_pending'] = False
        
        if current_user_id != user_id:
            repository = social_service.repository
            profile_dict['is_connected'] = repository.are_users_connected(current_user_id, user_id)
            
            # Check for pending connection request
            pending_request = repository.get_connection_request(current_user_id, user_id)
            profile_dict['has_request_pending'] = (pending_request is not None and pending_request.is_pending())
        
        response_data = user_profile_response_schema.dump(profile_dict)
        return jsonify(response_data), 200
        
    except Exception as e:
        logger.error(f"Error getting profile for user {user_id}: {str(e)}")
        return jsonify({'error': 'Failed to get profile'}), 500 