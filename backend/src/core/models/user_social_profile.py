"""
User Social Profile Domain Model
Represents a user's social profile and cooking-related information
"""

import uuid
import json
from datetime import datetime
from typing import Optional, List, Dict, Any
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy import Column, String, DateTime, Boolean, Text, ForeignKey
from sqlalchemy.types import JSON
from sqlalchemy.orm import relationship

from data_access.database import db

class UserSocialProfile(db.Model):
    """User social profile model for storing cooking and social information"""
    
    __tablename__ = 'user_social_profiles'
    
    # Primary Fields
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey('users.id'), nullable=False, unique=True)
    
    # Social Profile Information
    display_name = Column(String(100), nullable=True)
    bio = Column(Text, nullable=True)
    profile_picture_url = Column(String(500), nullable=True)
    cover_photo_url = Column(String(500), nullable=True)
    
    # Cooking Information
    cooking_level = Column(String(50), nullable=True)  # beginner, intermediate, advanced, expert
    favorite_cuisines = Column(Text, nullable=True, default='[]')  # JSON array as text
    cooking_goals = Column(Text, nullable=True, default='[]')  # JSON array as text
    dietary_preferences = Column(Text, nullable=True, default='[]')  # JSON array as text
    
    # Location and Contact
    location = Column(String(100), nullable=True)
    website_url = Column(String(500), nullable=True)
    
    # Privacy Settings
    is_public = Column(Boolean, default=True)
    allow_friend_requests = Column(Boolean, default=True)
    
    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    user = relationship("User", backref="social_profile")
    
    def __init__(self, user_id: str, display_name: Optional[str] = None):
        """Initialize a new user social profile"""
        self.user_id = user_id
        self.display_name = display_name
    
    @property
    def favorite_cuisines_list(self) -> List[str]:
        """Get favorite cuisines as a list"""
        if not self.favorite_cuisines:
            return []
        try:
            return json.loads(self.favorite_cuisines)
        except (json.JSONDecodeError, TypeError):
            return []
    
    @favorite_cuisines_list.setter
    def favorite_cuisines_list(self, value: List[str]) -> None:
        """Set favorite cuisines from a list"""
        if value is None:
            self.favorite_cuisines = '[]'
        else:
            self.favorite_cuisines = json.dumps(value)
    
    @property
    def cooking_goals_list(self) -> List[str]:
        """Get cooking goals as a list"""
        if not self.cooking_goals:
            return []
        try:
            return json.loads(self.cooking_goals)
        except (json.JSONDecodeError, TypeError):
            return []
    
    @cooking_goals_list.setter
    def cooking_goals_list(self, value: List[str]) -> None:
        """Set cooking goals from a list"""
        if value is None:
            self.cooking_goals = '[]'
        else:
            self.cooking_goals = json.dumps(value)
    
    @property
    def dietary_preferences_list(self) -> List[str]:
        """Get dietary preferences as a list"""
        if not self.dietary_preferences:
            return []
        try:
            return json.loads(self.dietary_preferences)
        except (json.JSONDecodeError, TypeError):
            return []
    
    @dietary_preferences_list.setter
    def dietary_preferences_list(self, value: List[str]) -> None:
        """Set dietary preferences from a list"""
        if value is None:
            self.dietary_preferences = '[]'
        else:
            self.dietary_preferences = json.dumps(value)
    
    def to_dict(self, include_user: bool = False) -> Dict[str, Any]:
        """Convert social profile to dictionary for API responses"""
        profile_dict = {
            'id': str(self.id),
            'user_id': str(self.user_id),
            'display_name': self.display_name,
            'bio': self.bio,
            'profile_picture_url': self.profile_picture_url,
            'cover_photo_url': self.cover_photo_url,
            'cooking_level': self.cooking_level,
            'favorite_cuisines': self.favorite_cuisines_list,
            'cooking_goals': self.cooking_goals_list,
            'dietary_preferences': self.dietary_preferences_list,
            'location': self.location,
            'website_url': self.website_url,
            'is_public': self.is_public,
            'allow_friend_requests': self.allow_friend_requests,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None,
        }
        
        if include_user and self.user:
            profile_dict['user'] = {
                'username': self.user.username,
                'email': self.user.email,
                'first_name': self.user.first_name,
                'last_name': self.user.last_name,
            }
        
        return profile_dict
    
    def __repr__(self) -> str:
        return f'<UserSocialProfile {self.display_name} for user {self.user_id}>' 