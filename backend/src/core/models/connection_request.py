"""
Connection Request Domain Model
Represents connection requests between users
"""

import uuid
from datetime import datetime
from typing import Optional, Dict, Any
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy import Column, String, DateTime, Text, ForeignKey, UniqueConstraint, CheckConstraint
from sqlalchemy.orm import relationship

from data_access.database import db

class ConnectionRequest(db.Model):
    """Connection request model for managing friend requests between users"""
    
    __tablename__ = 'connection_requests'
    
    # Primary Fields
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    sender_id = Column(UUID(as_uuid=True), ForeignKey('users.id'), nullable=False)
    receiver_id = Column(UUID(as_uuid=True), ForeignKey('users.id'), nullable=False)
    
    # Request Details
    status = Column(String(20), nullable=False, default='pending')  # pending, accepted, declined
    message = Column(Text, nullable=True)
    
    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow)
    responded_at = Column(DateTime, nullable=True)
    
    # Relationships
    sender = relationship("User", foreign_keys=[sender_id])
    receiver = relationship("User", foreign_keys=[receiver_id])
    
    # Constraints
    __table_args__ = (
        UniqueConstraint('sender_id', 'receiver_id', name='unique_connection_request'),
        CheckConstraint('sender_id != receiver_id', name='check_different_users'),
        CheckConstraint("status IN ('pending', 'accepted', 'declined')", name='check_valid_status'),
    )
    
    def __init__(self, sender_id: str, receiver_id: str, message: Optional[str] = None):
        """Initialize a new connection request"""
        self.sender_id = sender_id
        self.receiver_id = receiver_id
        self.message = message
        self.status = 'pending'
    
    def accept(self) -> None:
        """Accept the connection request"""
        if self.status != 'pending':
            raise ValueError("Can only accept pending requests")
        
        self.status = 'accepted'
        self.responded_at = datetime.utcnow()
    
    def decline(self) -> None:
        """Decline the connection request"""
        if self.status != 'pending':
            raise ValueError("Can only decline pending requests")
        
        self.status = 'declined'
        self.responded_at = datetime.utcnow()
    
    def is_pending(self) -> bool:
        """Check if the request is still pending"""
        return self.status == 'pending'
    
    def is_accepted(self) -> bool:
        """Check if the request was accepted"""
        return self.status == 'accepted'
    
    def is_declined(self) -> bool:
        """Check if the request was declined"""
        return self.status == 'declined'
    
    def to_dict(self, include_profiles: bool = False) -> Dict[str, Any]:
        """Convert connection request to dictionary for API responses"""
        request_dict = {
            'id': str(self.id),
            'sender_id': str(self.sender_id),
            'receiver_id': str(self.receiver_id),
            'status': self.status,
            'message': self.message,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'responded_at': self.responded_at.isoformat() if self.responded_at else None,
        }
        
        if include_profiles:
            if self.sender and hasattr(self.sender, 'social_profile') and self.sender.social_profile:
                request_dict['sender_profile'] = self.sender.social_profile.to_dict()
            if self.receiver and hasattr(self.receiver, 'social_profile') and self.receiver.social_profile:
                request_dict['receiver_profile'] = self.receiver.social_profile.to_dict()
        
        return request_dict
    
    def __repr__(self) -> str:
        return f'<ConnectionRequest {self.sender_id} -> {self.receiver_id} ({self.status})>' 