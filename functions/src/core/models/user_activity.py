"""
User Activity Domain Model
Represents user activities for the social activity feed
"""

import uuid
import json
from datetime import datetime
from typing import Dict, Any
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy import Column, String, DateTime, ForeignKey, Text
from sqlalchemy.types import JSON
from sqlalchemy.orm import relationship

from data_access.database import db

class UserActivity(db.Model):
    """User activity model for tracking activities in the social feed"""
    
    __tablename__ = 'user_activities'
    
    # Primary Fields
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey('users.id'), nullable=False)
    
    # Activity Information
    activity_type = Column(String(50), nullable=False)  # recipe_created, meal_plan_generated, recipe_shared, etc.
    activity_data = Column(Text, nullable=False)  # JSON data stored as text for compatibility
    privacy_level = Column(String(20), default='friends')  # public, friends, private
    
    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Relationships
    user = relationship("User", backref="activities")
    
    def __init__(self, user_id: str, activity_type: str, activity_data: Dict[str, Any], 
                 privacy_level: str = 'friends'):
        """Initialize a new user activity"""
        self.user_id = user_id
        self.activity_type = activity_type
        self.activity_data = json.dumps(activity_data)
        self.privacy_level = privacy_level
    
    @property
    def activity_data_dict(self) -> Dict[str, Any]:
        """Get activity data as a dictionary"""
        if not self.activity_data:
            return {}
        try:
            return json.loads(self.activity_data)
        except (json.JSONDecodeError, TypeError):
            return {}
    
    @activity_data_dict.setter
    def activity_data_dict(self, value: Dict[str, Any]) -> None:
        """Set activity data from a dictionary"""
        if value is None:
            self.activity_data = '{}'
        else:
            self.activity_data = json.dumps(value)
    
    def is_visible_to_user(self, viewing_user_id: str, is_connected: bool = False) -> bool:
        """Check if this activity is visible to the viewing user"""
        if str(self.user_id) == str(viewing_user_id):
            return True  # Users can always see their own activities
        
        if self.privacy_level == 'public':
            return True
        elif self.privacy_level == 'friends':
            return is_connected  # Only visible to connected users
        else:  # private
            return False
    
    def to_dict(self, include_user: bool = False) -> Dict[str, Any]:
        """Convert activity to dictionary for API responses"""
        activity_dict = {
            'id': str(self.id),
            'user_id': str(self.user_id),
            'activity_type': self.activity_type,
            'activity_data': self.activity_data_dict,
            'privacy_level': self.privacy_level,
            'created_at': self.created_at.isoformat() if self.created_at else None,
        }
        
        if include_user and self.user:
            if hasattr(self.user, 'social_profile') and self.user.social_profile:
                activity_dict['user_profile'] = self.user.social_profile.to_dict()
            else:
                activity_dict['user_profile'] = {
                    'user_id': str(self.user.id),
                    'display_name': self.user.username,
                    'profile_picture_url': None,
                }
        
        return activity_dict
    
    def __repr__(self) -> str:
        return f'<UserActivity {self.activity_type} by {self.user_id}>' 