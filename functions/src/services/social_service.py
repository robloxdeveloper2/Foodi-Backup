"""
Social Service
Business logic for user social profiles, connections, and activity feeds
"""

import logging
from typing import Optional, List, Dict, Any, Tuple
from dataclasses import dataclass
from sqlalchemy.exc import IntegrityError

from core.models.user import User
from core.models.user_social_profile import UserSocialProfile
from core.models.user_connection import UserConnection
from core.models.connection_request import ConnectionRequest
from core.models.user_activity import UserActivity
from data_access.social_repository import SocialRepository
from data_access.database import db

logger = logging.getLogger(__name__)

@dataclass
class PaginatedResult:
    """Generic paginated result container"""
    items: List[Any]
    total_count: int
    page: int
    per_page: int
    total_pages: int

class SocialService:
    """Service class for social features business logic"""
    
    def __init__(self):
        self.repository = SocialRepository()
    
    def get_user_profile(self, user_id: str) -> Optional[UserSocialProfile]:
        """
        Get user's social profile
        
        Args:
            user_id: User ID
            
        Returns:
            UserSocialProfile or None if not found
        """
        try:
            return self.repository.get_social_profile_by_user_id(user_id)
        except Exception as e:
            logger.error(f"Error getting user profile for {user_id}: {str(e)}")
            raise
    
    def create_user_profile(self, user_id: str, profile_data: Dict[str, Any]) -> UserSocialProfile:
        """
        Create a new social profile for user
        
        Args:
            user_id: User ID
            profile_data: Profile information
            
        Returns:
            Created UserSocialProfile
            
        Raises:
            ValueError: If profile already exists or invalid data
        """
        try:
            # Check if profile already exists
            existing_profile = self.repository.get_social_profile_by_user_id(user_id)
            if existing_profile:
                raise ValueError("Social profile already exists for this user")
            
            # Create new profile
            profile = UserSocialProfile(
                user_id=user_id,
                display_name=profile_data.get('display_name')
            )
            
            # Set optional fields
            if 'bio' in profile_data:
                profile.bio = profile_data['bio']
            if 'cooking_level' in profile_data:
                profile.cooking_level = profile_data['cooking_level']
            if 'favorite_cuisines' in profile_data:
                profile.favorite_cuisines_list = profile_data['favorite_cuisines']
            if 'cooking_goals' in profile_data:
                profile.cooking_goals_list = profile_data['cooking_goals']
            if 'dietary_preferences' in profile_data:
                profile.dietary_preferences_list = profile_data['dietary_preferences']
            if 'location' in profile_data:
                profile.location = profile_data['location']
            if 'website_url' in profile_data:
                profile.website_url = profile_data['website_url']
            if 'is_public' in profile_data:
                profile.is_public = profile_data['is_public']
            if 'allow_friend_requests' in profile_data:
                profile.allow_friend_requests = profile_data['allow_friend_requests']
            
            return self.repository.create_social_profile(profile)
        
        except Exception as e:
            logger.error(f"Error creating user profile for {user_id}: {str(e)}")
            raise
    
    def update_user_profile(self, user_id: str, profile_data: Dict[str, Any]) -> UserSocialProfile:
        """
        Update user's social profile
        
        Args:
            user_id: User ID
            profile_data: Updated profile information
            
        Returns:
            Updated UserSocialProfile
            
        Raises:
            ValueError: If profile not found
        """
        try:
            profile = self.repository.get_social_profile_by_user_id(user_id)
            if not profile:
                raise ValueError("Social profile not found")
            
            # Update fields if provided
            if 'display_name' in profile_data:
                profile.display_name = profile_data['display_name']
            if 'bio' in profile_data:
                profile.bio = profile_data['bio']
            if 'cooking_level' in profile_data:
                profile.cooking_level = profile_data['cooking_level']
            if 'favorite_cuisines' in profile_data:
                profile.favorite_cuisines_list = profile_data['favorite_cuisines']
            if 'cooking_goals' in profile_data:
                profile.cooking_goals_list = profile_data['cooking_goals']
            if 'dietary_preferences' in profile_data:
                profile.dietary_preferences_list = profile_data['dietary_preferences']
            if 'location' in profile_data:
                profile.location = profile_data['location']
            if 'website_url' in profile_data:
                profile.website_url = profile_data['website_url']
            if 'profile_picture_url' in profile_data:
                profile.profile_picture_url = profile_data['profile_picture_url']
            if 'cover_photo_url' in profile_data:
                profile.cover_photo_url = profile_data['cover_photo_url']
            if 'is_public' in profile_data:
                profile.is_public = profile_data['is_public']
            if 'allow_friend_requests' in profile_data:
                profile.allow_friend_requests = profile_data['allow_friend_requests']
            
            return self.repository.update_social_profile(profile)
        
        except Exception as e:
            logger.error(f"Error updating user profile for {user_id}: {str(e)}")
            raise
    
    def search_users(self, query: str, page: int = 1, per_page: int = 20) -> PaginatedResult:
        """
        Search for users by display name or username
        
        Args:
            query: Search query
            page: Page number (1-based)
            per_page: Items per page
            
        Returns:
            PaginatedResult with matching profiles
        """
        try:
            profiles, total_count = self.repository.search_social_profiles(query, page, per_page)
            total_pages = (total_count + per_page - 1) // per_page
            
            return PaginatedResult(
                items=profiles,
                total_count=total_count,
                page=page,
                per_page=per_page,
                total_pages=total_pages
            )
        
        except Exception as e:
            logger.error(f"Error searching users with query '{query}': {str(e)}")
            raise
    
    def send_connection_request(self, sender_id: str, receiver_id: str, 
                              message: Optional[str] = None) -> ConnectionRequest:
        """
        Send a connection request to another user
        
        Args:
            sender_id: ID of user sending the request
            receiver_id: ID of user receiving the request
            message: Optional message with the request
            
        Returns:
            Created ConnectionRequest
            
        Raises:
            ValueError: If invalid request (self-request, already connected, etc.)
        """
        try:
            if sender_id == receiver_id:
                raise ValueError("Cannot send connection request to yourself")
            
            # Check if users are already connected
            if self.repository.are_users_connected(sender_id, receiver_id):
                raise ValueError("Users are already connected")
            
            # Check if there's already a pending request
            existing_request = self.repository.get_connection_request(sender_id, receiver_id)
            if existing_request and existing_request.is_pending():
                raise ValueError("Connection request already pending")
            
            # Check if receiver allows friend requests
            receiver_profile = self.repository.get_social_profile_by_user_id(receiver_id)
            if receiver_profile and not receiver_profile.allow_friend_requests:
                raise ValueError("User does not accept friend requests")
            
            request = ConnectionRequest(sender_id, receiver_id, message)
            return self.repository.create_connection_request(request)
        
        except Exception as e:
            logger.error(f"Error sending connection request from {sender_id} to {receiver_id}: {str(e)}")
            raise
    
    def respond_to_connection_request(self, request_id: str, user_id: str, action: str) -> bool:
        """
        Respond to a connection request (accept or decline)
        
        Args:
            request_id: ID of the connection request
            user_id: ID of user responding (must be the receiver)
            action: 'accept' or 'decline'
            
        Returns:
            True if successful
            
        Raises:
            ValueError: If invalid request or action
        """
        try:
            if action not in ['accept', 'decline']:
                raise ValueError("Action must be 'accept' or 'decline'")
            
            request = self.repository.get_connection_request_by_id(request_id)
            if not request:
                raise ValueError("Connection request not found")
            
            if str(request.receiver_id) != str(user_id):
                raise ValueError("Only the receiver can respond to this request")
            
            if not request.is_pending():
                raise ValueError("Connection request is no longer pending")
            
            if action == 'accept':
                request.accept()
                # Create the connection
                connection = UserConnection(request.sender_id, request.receiver_id)
                self.repository.create_connection(connection)
                
                # Create activity for both users
                self._create_connection_activity(request.sender_id, request.receiver_id)
            else:
                request.decline()
            
            self.repository.update_connection_request(request)
            return True
        
        except Exception as e:
            logger.error(f"Error responding to connection request {request_id}: {str(e)}")
            raise
    
    def get_connection_requests(self, user_id: str, request_type: str = 'received') -> List[ConnectionRequest]:
        """
        Get connection requests for a user
        
        Args:
            user_id: User ID
            request_type: 'received' or 'sent'
            
        Returns:
            List of ConnectionRequest objects
        """
        try:
            if request_type == 'received':
                return self.repository.get_received_connection_requests(user_id)
            elif request_type == 'sent':
                return self.repository.get_sent_connection_requests(user_id)
            else:
                raise ValueError("request_type must be 'received' or 'sent'")
        
        except Exception as e:
            logger.error(f"Error getting {request_type} connection requests for {user_id}: {str(e)}")
            raise
    
    def get_user_connections(self, user_id: str, page: int = 1, per_page: int = 20) -> PaginatedResult:
        """
        Get user's connections (friends)
        
        Args:
            user_id: User ID
            page: Page number (1-based)
            per_page: Items per page
            
        Returns:
            PaginatedResult with connected user profiles
        """
        try:
            profiles, total_count = self.repository.get_user_connections_with_profiles(
                user_id, page, per_page
            )
            total_pages = (total_count + per_page - 1) // per_page
            
            return PaginatedResult(
                items=profiles,
                total_count=total_count,
                page=page,
                per_page=per_page,
                total_pages=total_pages
            )
        
        except Exception as e:
            logger.error(f"Error getting connections for user {user_id}: {str(e)}")
            raise
    
    def get_activity_feed(self, user_id: str, page: int = 1, per_page: int = 20) -> PaginatedResult:
        """
        Get activity feed for a user (includes their activities and friends' activities)
        
        Args:
            user_id: User ID
            page: Page number (1-based)
            per_page: Items per page
            
        Returns:
            PaginatedResult with activity items
        """
        try:
            activities, total_count = self.repository.get_activity_feed(user_id, page, per_page)
            total_pages = (total_count + per_page - 1) // per_page
            
            return PaginatedResult(
                items=activities,
                total_count=total_count,
                page=page,
                per_page=per_page,
                total_pages=total_pages
            )
        
        except Exception as e:
            logger.error(f"Error getting activity feed for user {user_id}: {str(e)}")
            raise
    
    def create_activity(self, user_id: str, activity_type: str, activity_data: Dict[str, Any],
                       privacy_level: str = 'friends') -> UserActivity:
        """
        Create a new user activity
        
        Args:
            user_id: User ID
            activity_type: Type of activity
            activity_data: Activity data
            privacy_level: Privacy level ('public', 'friends', 'private')
            
        Returns:
            Created UserActivity
        """
        try:
            activity = UserActivity(user_id, activity_type, activity_data, privacy_level)
            return self.repository.create_activity(activity)
        
        except Exception as e:
            logger.error(f"Error creating activity for user {user_id}: {str(e)}")
            raise
    
    def _create_connection_activity(self, user_id_1: str, user_id_2: str) -> None:
        """Create activities for new connection"""
        try:
            # Get user profiles for activity data
            profile_1 = self.repository.get_social_profile_by_user_id(user_id_1)
            profile_2 = self.repository.get_social_profile_by_user_id(user_id_2)
            
            # Create activity for user 1
            activity_data_1 = {
                'connected_user_id': str(user_id_2),
                'connected_user_name': profile_2.display_name if profile_2 else 'Unknown User'
            }
            self.create_activity(user_id_1, 'new_connection', activity_data_1, 'friends')
            
            # Create activity for user 2
            activity_data_2 = {
                'connected_user_id': str(user_id_1),
                'connected_user_name': profile_1.display_name if profile_1 else 'Unknown User'
            }
            self.create_activity(user_id_2, 'new_connection', activity_data_2, 'friends')
            
        except Exception as e:
            logger.warning(f"Error creating connection activities: {str(e)}")
            # Don't raise - connection was successful even if activity creation failed 