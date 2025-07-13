"""
User Connection Domain Model
Represents connections/friendships between users
"""

import uuid
from datetime import datetime
from typing import Dict, Any
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy import Column, DateTime, ForeignKey, UniqueConstraint, CheckConstraint
from sqlalchemy.orm import relationship

from data_access.database import db

class UserConnection(db.Model):
    """User connection model for managing friendships between users"""
    
    __tablename__ = 'user_connections'
    
    # Primary Fields
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id_1 = Column(UUID(as_uuid=True), ForeignKey('users.id'), nullable=False)
    user_id_2 = Column(UUID(as_uuid=True), ForeignKey('users.id'), nullable=False)
    
    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Relationships
    user1 = relationship("User", foreign_keys=[user_id_1])
    user2 = relationship("User", foreign_keys=[user_id_2])
    
    # Constraints
    __table_args__ = (
        UniqueConstraint('user_id_1', 'user_id_2', name='unique_user_connection'),
        CheckConstraint('user_id_1 != user_id_2', name='check_different_users'),
    )
    
    def __init__(self, user_id_1: str, user_id_2: str):
        """Initialize a new user connection"""
        # Ensure consistent ordering to avoid duplicate connections
        if str(user_id_1) < str(user_id_2):
            self.user_id_1 = user_id_1
            self.user_id_2 = user_id_2
        else:
            self.user_id_1 = user_id_2
            self.user_id_2 = user_id_1
    
    def get_other_user_id(self, user_id: str) -> str:
        """Get the other user's ID in this connection"""
        if str(self.user_id_1) == str(user_id):
            return str(self.user_id_2)
        elif str(self.user_id_2) == str(user_id):
            return str(self.user_id_1)
        else:
            raise ValueError("User ID not found in this connection")
    
    def involves_user(self, user_id: str) -> bool:
        """Check if the connection involves the specified user"""
        return str(self.user_id_1) == str(user_id) or str(self.user_id_2) == str(user_id)
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert connection to dictionary for API responses"""
        return {
            'id': str(self.id),
            'user_id_1': str(self.user_id_1),
            'user_id_2': str(self.user_id_2),
            'created_at': self.created_at.isoformat() if self.created_at else None,
        }
    
    def __repr__(self) -> str:
        return f'<UserConnection {self.user_id_1} <-> {self.user_id_2}>' 