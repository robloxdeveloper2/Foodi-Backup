"""
User Repository
Data access layer for User operations
"""

import logging
from typing import Optional, List
from sqlalchemy.exc import IntegrityError
from sqlalchemy import or_

from core.models.user import User
from data_access.database import db

logger = logging.getLogger(__name__)

class UserRepository:
    """Repository class for User database operations"""
    
    def create_user(self, user: User) -> User:
        """
        Create a new user in the database
        
        Args:
            user: User instance to create
            
        Returns:
            Created user instance
            
        Raises:
            IntegrityError: If user creation fails due to constraints
        """
        try:
            db.session.add(user)
            db.session.commit()
            db.session.refresh(user)
            logger.info(f"User created successfully: {user.id}")
            return user
        except IntegrityError as e:
            db.session.rollback()
            logger.error(f"Failed to create user: {str(e)}")
            raise
        except Exception as e:
            db.session.rollback()
            logger.error(f"Unexpected error creating user: {str(e)}")
            raise
    
    def get_user_by_id(self, user_id: str) -> Optional[User]:
        """
        Get user by ID
        
        Args:
            user_id: User ID
            
        Returns:
            User instance or None if not found
        """
        try:
            return db.session.query(User).filter(User.id == user_id).first()
        except Exception as e:
            logger.error(f"Error fetching user by ID {user_id}: {str(e)}")
            return None
    
    def get_user_by_email(self, email: str) -> Optional[User]:
        """
        Get user by email address
        
        Args:
            email: User email address
            
        Returns:
            User instance or None if not found
        """
        try:
            return db.session.query(User).filter(User.email == email.lower()).first()
        except Exception as e:
            logger.error(f"Error fetching user by email {email}: {str(e)}")
            return None
    
    def get_user_by_username(self, username: str) -> Optional[User]:
        """
        Get user by username
        
        Args:
            username: Username
            
        Returns:
            User instance or None if not found
        """
        try:
            return db.session.query(User).filter(User.username == username.lower()).first()
        except Exception as e:
            logger.error(f"Error fetching user by username {username}: {str(e)}")
            return None
    
    def get_user_by_social_id(self, provider: str, social_id: str) -> Optional[User]:
        """
        Get user by social provider ID
        
        Args:
            provider: Social provider (google, apple)
            social_id: Social provider user ID
            
        Returns:
            User instance or None if not found
        """
        try:
            if provider == 'google':
                return db.session.query(User).filter(User.google_id == social_id).first()
            elif provider == 'apple':
                return db.session.query(User).filter(User.apple_id == social_id).first()
            else:
                logger.warning(f"Unknown social provider: {provider}")
                return None
        except Exception as e:
            logger.error(f"Error fetching user by social ID {provider}:{social_id}: {str(e)}")
            return None
    
    def get_user_by_verification_token(self, token: str) -> Optional[User]:
        """
        Get user by email verification token
        
        Args:
            token: Email verification token
            
        Returns:
            User instance or None if not found
        """
        try:
            return db.session.query(User).filter(User.email_verification_token == token).first()
        except Exception as e:
            logger.error(f"Error fetching user by verification token: {str(e)}")
            return None
    
    def update_user(self, user: User) -> User:
        """
        Update user in the database
        
        Args:
            user: User instance to update
            
        Returns:
            Updated user instance
            
        Raises:
            IntegrityError: If update fails due to constraints
        """
        try:
            db.session.commit()
            db.session.refresh(user)
            logger.info(f"User updated successfully: {user.id}")
            return user
        except IntegrityError as e:
            db.session.rollback()
            logger.error(f"Failed to update user {user.id}: {str(e)}")
            raise
        except Exception as e:
            db.session.rollback()
            logger.error(f"Unexpected error updating user {user.id}: {str(e)}")
            raise
    
    def delete_user(self, user_id: str) -> bool:
        """
        Delete user from database (soft delete by setting is_active=False)
        
        Args:
            user_id: User ID to delete
            
        Returns:
            True if deletion successful, False otherwise
        """
        try:
            user = self.get_user_by_id(user_id)
            if user:
                user.is_active = False
                db.session.commit()
                logger.info(f"User soft deleted: {user_id}")
                return True
            else:
                logger.warning(f"User not found for deletion: {user_id}")
                return False
        except Exception as e:
            db.session.rollback()
            logger.error(f"Error deleting user {user_id}: {str(e)}")
            return False
    
    def get_users_by_filter(self, limit: int = 100, offset: int = 0, 
                           is_active: Optional[bool] = None,
                           email_verified: Optional[bool] = None) -> List[User]:
        """
        Get users with optional filters
        
        Args:
            limit: Maximum number of users to return
            offset: Number of users to skip
            is_active: Filter by active status
            email_verified: Filter by email verification status
            
        Returns:
            List of User instances
        """
        try:
            query = db.session.query(User)
            
            if is_active is not None:
                query = query.filter(User.is_active == is_active)
            
            if email_verified is not None:
                query = query.filter(User.email_verified == email_verified)
            
            return query.offset(offset).limit(limit).all()
        except Exception as e:
            logger.error(f"Error fetching users with filters: {str(e)}")
            return []
    
    def count_users(self, is_active: Optional[bool] = None) -> int:
        """
        Count users with optional filter
        
        Args:
            is_active: Filter by active status
            
        Returns:
            Number of users
        """
        try:
            query = db.session.query(User)
            
            if is_active is not None:
                query = query.filter(User.is_active == is_active)
            
            return query.count()
        except Exception as e:
            logger.error(f"Error counting users: {str(e)}")
            return 0
    
    def search_users(self, search_term: str, limit: int = 50) -> List[User]:
        """
        Search users by username, email, or name
        
        Args:
            search_term: Search term
            limit: Maximum number of results
            
        Returns:
            List of matching User instances
        """
        try:
            search_pattern = f"%{search_term.lower()}%"
            
            return db.session.query(User).filter(
                or_(
                    User.username.ilike(search_pattern),
                    User.email.ilike(search_pattern),
                    User.first_name.ilike(search_pattern),
                    User.last_name.ilike(search_pattern)
                )
            ).filter(User.is_active == True).limit(limit).all()
        except Exception as e:
            logger.error(f"Error searching users: {str(e)}")
            return [] 