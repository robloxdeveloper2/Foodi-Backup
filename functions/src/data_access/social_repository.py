"""
Social Repository
Data access layer for social features
"""

import logging
from typing import Optional, List, Tuple
from sqlalchemy.exc import IntegrityError
from sqlalchemy import or_, and_, func, desc
from sqlalchemy.orm import joinedload

from core.models.user import User
from core.models.user_social_profile import UserSocialProfile
from core.models.user_connection import UserConnection
from core.models.connection_request import ConnectionRequest
from core.models.user_activity import UserActivity
from data_access.database import db

logger = logging.getLogger(__name__)

class SocialRepository:
    """Repository class for social features database operations"""
    
    # Social Profile Operations
    
    def create_social_profile(self, profile: UserSocialProfile) -> UserSocialProfile:
        """
        Create a new social profile
        
        Args:
            profile: UserSocialProfile instance to create
            
        Returns:
            Created profile instance
        """
        try:
            db.session.add(profile)
            db.session.commit()
            db.session.refresh(profile)
            logger.info(f"Social profile created for user: {profile.user_id}")
            return profile
        except IntegrityError as e:
            db.session.rollback()
            logger.error(f"Failed to create social profile: {str(e)}")
            raise
        except Exception as e:
            db.session.rollback()
            logger.error(f"Unexpected error creating social profile: {str(e)}")
            raise
    
    def get_social_profile_by_user_id(self, user_id: str) -> Optional[UserSocialProfile]:
        """
        Get social profile by user ID
        
        Args:
            user_id: User ID
            
        Returns:
            UserSocialProfile or None if not found
        """
        try:
            return db.session.query(UserSocialProfile).filter(
                UserSocialProfile.user_id == user_id
            ).first()
        except Exception as e:
            logger.error(f"Error fetching social profile for user {user_id}: {str(e)}")
            return None
    
    def update_social_profile(self, profile: UserSocialProfile) -> UserSocialProfile:
        """
        Update social profile
        
        Args:
            profile: Updated profile instance
            
        Returns:
            Updated profile instance
        """
        try:
            db.session.commit()
            db.session.refresh(profile)
            logger.info(f"Social profile updated for user: {profile.user_id}")
            return profile
        except IntegrityError as e:
            db.session.rollback()
            logger.error(f"Failed to update social profile: {str(e)}")
            raise
        except Exception as e:
            db.session.rollback()
            logger.error(f"Unexpected error updating social profile: {str(e)}")
            raise
    
    def search_social_profiles(self, query: str, page: int = 1, per_page: int = 20) -> Tuple[List[UserSocialProfile], int]:
        """
        Search for social profiles by display name
        
        Args:
            query: Search query
            page: Page number (1-based)
            per_page: Items per page
            
        Returns:
            Tuple of (profiles list, total count)
        """
        try:
            # Calculate offset
            offset = (page - 1) * per_page
            
            # Search in social profiles and users
            base_query = db.session.query(UserSocialProfile).join(User).filter(
                and_(
                    UserSocialProfile.is_public == True,
                    or_(
                        UserSocialProfile.display_name.ilike(f'%{query}%'),
                        User.username.ilike(f'%{query}%'),
                        User.first_name.ilike(f'%{query}%'),
                        User.last_name.ilike(f'%{query}%')
                    )
                )
            )
            
            # Get total count
            total_count = base_query.count()
            
            # Get paginated results
            profiles = base_query.offset(offset).limit(per_page).all()
            
            return profiles, total_count
        
        except Exception as e:
            logger.error(f"Error searching social profiles with query '{query}': {str(e)}")
            return [], 0
    
    # Connection Operations
    
    def create_connection(self, connection: UserConnection) -> UserConnection:
        """
        Create a new user connection
        
        Args:
            connection: UserConnection instance to create
            
        Returns:
            Created connection instance
        """
        try:
            db.session.add(connection)
            db.session.commit()
            db.session.refresh(connection)
            logger.info(f"Connection created: {connection.user_id_1} <-> {connection.user_id_2}")
            return connection
        except IntegrityError as e:
            db.session.rollback()
            logger.error(f"Failed to create connection: {str(e)}")
            raise
        except Exception as e:
            db.session.rollback()
            logger.error(f"Unexpected error creating connection: {str(e)}")
            raise
    
    def are_users_connected(self, user_id_1: str, user_id_2: str) -> bool:
        """
        Check if two users are connected
        
        Args:
            user_id_1: First user ID
            user_id_2: Second user ID
            
        Returns:
            True if users are connected
        """
        try:
            connection = db.session.query(UserConnection).filter(
                or_(
                    and_(UserConnection.user_id_1 == user_id_1, UserConnection.user_id_2 == user_id_2),
                    and_(UserConnection.user_id_1 == user_id_2, UserConnection.user_id_2 == user_id_1)
                )
            ).first()
            
            return connection is not None
        except Exception as e:
            logger.error(f"Error checking connection between {user_id_1} and {user_id_2}: {str(e)}")
            return False
    
    def get_user_connections_with_profiles(self, user_id: str, page: int = 1, per_page: int = 20) -> Tuple[List[UserSocialProfile], int]:
        """
        Get user's connections with their social profiles
        
        Args:
            user_id: User ID
            page: Page number (1-based)
            per_page: Items per page
            
        Returns:
            Tuple of (connected user profiles, total count)
        """
        try:
            # Calculate offset
            offset = (page - 1) * per_page
            
            # Get connected user IDs
            connections_query = db.session.query(UserConnection).filter(
                or_(
                    UserConnection.user_id_1 == user_id,
                    UserConnection.user_id_2 == user_id
                )
            )
            
            # Get total count of connections
            total_count = connections_query.count()
            
            # Get paginated connections
            connections = connections_query.offset(offset).limit(per_page).all()
            
            # Extract connected user IDs
            connected_user_ids = []
            for connection in connections:
                if str(connection.user_id_1) == str(user_id):
                    connected_user_ids.append(connection.user_id_2)
                else:
                    connected_user_ids.append(connection.user_id_1)
            
            # Get social profiles for connected users
            profiles = []
            if connected_user_ids:
                profiles = db.session.query(UserSocialProfile).filter(
                    UserSocialProfile.user_id.in_(connected_user_ids)
                ).all()
            
            return profiles, total_count
        
        except Exception as e:
            logger.error(f"Error getting connections for user {user_id}: {str(e)}")
            return [], 0
    
    # Connection Request Operations
    
    def create_connection_request(self, request: ConnectionRequest) -> ConnectionRequest:
        """
        Create a new connection request
        
        Args:
            request: ConnectionRequest instance to create
            
        Returns:
            Created request instance
        """
        try:
            db.session.add(request)
            db.session.commit()
            db.session.refresh(request)
            logger.info(f"Connection request created: {request.sender_id} -> {request.receiver_id}")
            return request
        except IntegrityError as e:
            db.session.rollback()
            logger.error(f"Failed to create connection request: {str(e)}")
            raise
        except Exception as e:
            db.session.rollback()
            logger.error(f"Unexpected error creating connection request: {str(e)}")
            raise
    
    def get_connection_request(self, sender_id: str, receiver_id: str) -> Optional[ConnectionRequest]:
        """
        Get connection request between two users
        
        Args:
            sender_id: Sender user ID
            receiver_id: Receiver user ID
            
        Returns:
            ConnectionRequest or None if not found
        """
        try:
            return db.session.query(ConnectionRequest).filter(
                and_(
                    ConnectionRequest.sender_id == sender_id,
                    ConnectionRequest.receiver_id == receiver_id
                )
            ).first()
        except Exception as e:
            logger.error(f"Error getting connection request from {sender_id} to {receiver_id}: {str(e)}")
            return None
    
    def get_connection_request_by_id(self, request_id: str) -> Optional[ConnectionRequest]:
        """
        Get connection request by ID
        
        Args:
            request_id: Request ID
            
        Returns:
            ConnectionRequest or None if not found
        """
        try:
            return db.session.query(ConnectionRequest).filter(
                ConnectionRequest.id == request_id
            ).first()
        except Exception as e:
            logger.error(f"Error getting connection request {request_id}: {str(e)}")
            return None
    
    def update_connection_request(self, request: ConnectionRequest) -> ConnectionRequest:
        """
        Update connection request
        
        Args:
            request: Updated request instance
            
        Returns:
            Updated request instance
        """
        try:
            db.session.commit()
            db.session.refresh(request)
            logger.info(f"Connection request updated: {request.id}")
            return request
        except Exception as e:
            db.session.rollback()
            logger.error(f"Unexpected error updating connection request: {str(e)}")
            raise
    
    def get_received_connection_requests(self, user_id: str) -> List[ConnectionRequest]:
        """
        Get connection requests received by a user
        
        Args:
            user_id: User ID
            
        Returns:
            List of received connection requests
        """
        try:
            return db.session.query(ConnectionRequest).options(
                joinedload(ConnectionRequest.sender).joinedload(User.social_profile)
            ).filter(
                and_(
                    ConnectionRequest.receiver_id == user_id,
                    ConnectionRequest.status == 'pending'
                )
            ).order_by(desc(ConnectionRequest.created_at)).all()
        except Exception as e:
            logger.error(f"Error getting received connection requests for {user_id}: {str(e)}")
            return []
    
    def get_sent_connection_requests(self, user_id: str) -> List[ConnectionRequest]:
        """
        Get connection requests sent by a user
        
        Args:
            user_id: User ID
            
        Returns:
            List of sent connection requests
        """
        try:
            return db.session.query(ConnectionRequest).options(
                joinedload(ConnectionRequest.receiver).joinedload(User.social_profile)
            ).filter(
                and_(
                    ConnectionRequest.sender_id == user_id,
                    ConnectionRequest.status == 'pending'
                )
            ).order_by(desc(ConnectionRequest.created_at)).all()
        except Exception as e:
            logger.error(f"Error getting sent connection requests for {user_id}: {str(e)}")
            return []
    
    # Activity Operations
    
    def create_activity(self, activity: UserActivity) -> UserActivity:
        """
        Create a new user activity
        
        Args:
            activity: UserActivity instance to create
            
        Returns:
            Created activity instance
        """
        try:
            db.session.add(activity)
            db.session.commit()
            db.session.refresh(activity)
            logger.info(f"Activity created: {activity.activity_type} for user {activity.user_id}")
            return activity
        except Exception as e:
            db.session.rollback()
            logger.error(f"Unexpected error creating activity: {str(e)}")
            raise
    
    def get_activity_feed(self, user_id: str, page: int = 1, per_page: int = 20) -> Tuple[List[UserActivity], int]:
        """
        Get activity feed for a user (their activities + friends' activities)
        
        Args:
            user_id: User ID
            page: Page number (1-based)
            per_page: Items per page
            
        Returns:
            Tuple of (activities list, total count)
        """
        try:
            # Calculate offset
            offset = (page - 1) * per_page
            
            # Get connected user IDs
            connected_users_subquery = db.session.query(UserConnection).filter(
                or_(
                    UserConnection.user_id_1 == user_id,
                    UserConnection.user_id_2 == user_id
                )
            ).subquery()
            
            # Build list of user IDs to include in feed (user + connected users)
            connected_user_ids = []
            connections = db.session.query(UserConnection).filter(
                or_(
                    UserConnection.user_id_1 == user_id,
                    UserConnection.user_id_2 == user_id
                )
            ).all()
            
            for connection in connections:
                if str(connection.user_id_1) == str(user_id):
                    connected_user_ids.append(connection.user_id_2)
                else:
                    connected_user_ids.append(connection.user_id_1)
            
            # Include the user's own ID
            all_user_ids = [user_id] + connected_user_ids
            
            # Query activities from user and connected users
            base_query = db.session.query(UserActivity).options(
                joinedload(UserActivity.user).joinedload(User.social_profile)
            ).filter(
                and_(
                    UserActivity.user_id.in_(all_user_ids),
                    or_(
                        UserActivity.privacy_level == 'public',
                        and_(
                            UserActivity.privacy_level == 'friends',
                            UserActivity.user_id.in_(all_user_ids)
                        ),
                        and_(
                            UserActivity.privacy_level == 'private',
                            UserActivity.user_id == user_id
                        )
                    )
                )
            ).order_by(desc(UserActivity.created_at))
            
            # Get total count
            total_count = base_query.count()
            
            # Get paginated results
            activities = base_query.offset(offset).limit(per_page).all()
            
            return activities, total_count
        
        except Exception as e:
            logger.error(f"Error getting activity feed for user {user_id}: {str(e)}")
            return [], 0 