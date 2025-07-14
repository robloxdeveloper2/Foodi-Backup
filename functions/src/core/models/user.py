"""
User Domain Model
Represents a Foodi user account and profile information
"""

import uuid
import json
from datetime import datetime
from typing import Optional, List, Dict, Any
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy import Column, String, DateTime, Boolean, Text
from sqlalchemy.types import JSON
from sqlalchemy.orm import relationship
import bcrypt

from data_access.database import db

class User(db.Model):
    """User model for storing user account and profile information"""
    
    __tablename__ = 'users'
    
    # Primary Fields
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    username = Column(String(255), nullable=False, unique=True)
    email = Column(String(255), nullable=False, unique=True, index=True)
    password_hash = Column(String(255), nullable=True)  # Nullable for social login users
    
    # Profile Information
    first_name = Column(String(100), nullable=True)
    last_name = Column(String(100), nullable=True)
    
    # Food Preferences and Restrictions - Changed to TEXT for SQLite compatibility
    dietary_restrictions = Column(Text, nullable=True, default='[]')
    cooking_experience_level = Column(String(50), nullable=True)  # beginner, intermediate, advanced
    nutritional_goals = Column(JSON, nullable=True)
    budget_info = Column(JSON, nullable=True)
    
    # Authentication and Verification
    email_verified = Column(Boolean, default=False)
    email_verification_token = Column(String(255), nullable=True)
    
    # Social Login Information
    google_id = Column(String(255), nullable=True, unique=True)
    apple_id = Column(String(255), nullable=True, unique=True)
    
    # Account Status
    is_active = Column(Boolean, default=True)
    
    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    last_login = Column(DateTime, nullable=True)
    
    # Relationships
    user_recipes = relationship("UserRecipe", back_populates="user")
    recipe_categories = relationship("UserRecipeCategory", back_populates="user")
    
    def __init__(self, username: str, email: str, password: Optional[str] = None, 
                 first_name: Optional[str] = None, last_name: Optional[str] = None,
                 google_id: Optional[str] = None, apple_id: Optional[str] = None):
        """Initialize a new user"""
        self.username = username
        self.email = email.lower()  # Store email in lowercase
        self.first_name = first_name
        self.last_name = last_name
        self.google_id = google_id
        self.apple_id = apple_id
        
        if password:
            self.set_password(password)
    
    @property
    def dietary_restrictions_list(self) -> List[str]:
        """Get dietary restrictions as a list"""
        if not self.dietary_restrictions:
            return []
        try:
            return json.loads(self.dietary_restrictions)
        except (json.JSONDecodeError, TypeError):
            return []
    
    @dietary_restrictions_list.setter
    def dietary_restrictions_list(self, value: List[str]) -> None:
        """Set dietary restrictions from a list"""
        if value is None:
            self.dietary_restrictions = '[]'
        else:
            self.dietary_restrictions = json.dumps(value)
    
    def set_password(self, password: str) -> None:
        """Hash and set the user's password"""
        if not password:
            raise ValueError("Password cannot be empty")
        
        salt = bcrypt.gensalt()
        self.password_hash = bcrypt.hashpw(password.encode('utf-8'), salt).decode('utf-8')
    
    def check_password(self, password: str) -> bool:
        """Check if the provided password matches the user's password"""
        if not self.password_hash or not password:
            return False
        
        return bcrypt.checkpw(
            password.encode('utf-8'), 
            self.password_hash.encode('utf-8')
        )
    
    def generate_verification_token(self) -> str:
        """Generate a new email verification token"""
        token = str(uuid.uuid4())
        self.email_verification_token = token
        return token
    
    def verify_email(self, token: str) -> bool:
        """Verify email with the provided token"""
        if self.email_verification_token == token:
            self.email_verified = True
            self.email_verification_token = None
            return True
        return False
    
    def update_last_login(self) -> None:
        """Update the last login timestamp"""
        self.last_login = datetime.utcnow()
    
    def to_dict(self, include_sensitive: bool = False) -> Dict[str, Any]:
        """Convert user to dictionary for API responses"""
        user_dict = {
            'id': str(self.id),
            'username': self.username,
            'email': self.email,
            'first_name': self.first_name,
            'last_name': self.last_name,
            'dietary_restrictions': self.dietary_restrictions_list,
            'cooking_experience_level': self.cooking_experience_level,
            'nutritional_goals': self.nutritional_goals or {},
            'budget_info': self.budget_info or {},
            'email_verified': self.email_verified,
            'is_active': self.is_active,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None,
            'last_login': self.last_login.isoformat() if self.last_login else None,
        }
        
        if include_sensitive:
            user_dict.update({
                'email_verification_token': self.email_verification_token,
                'google_id': self.google_id,
                'apple_id': self.apple_id,
            })
        
        return user_dict
    
    def __repr__(self) -> str:
        return f'<User {self.username} ({self.email})>' 