"""
PantryItem Domain Model
Represents a food item in a user's pantry/inventory
"""

import uuid
from datetime import datetime, date
from typing import Optional, Dict, Any
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy import Column, String, DateTime, Integer, Float, ForeignKey, Text, Date
from sqlalchemy.orm import relationship

from data_access.database import db

class PantryItem(db.Model):
    """PantryItem model for storing user pantry/inventory items"""
    
    __tablename__ = 'pantry_items'
    
    # Primary Fields
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey('users.id'), nullable=False, index=True)
    
    # Item Information
    name = Column(String(255), nullable=False, index=True)
    quantity = Column(Float, nullable=False, default=1.0)
    unit = Column(String(50), nullable=False, default='units')  # units, grams, kg, liters, ml, etc.
    
    # Expiry Information
    expiry_date = Column(Date, nullable=True)
    
    # Additional Information
    category = Column(String(100), nullable=True)  # produce, dairy, meat, pantry, etc.
    notes = Column(Text, nullable=True)
    
    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    user = relationship("User", backref="pantry_items")
    
    def __init__(self, user_id: str, name: str, quantity: float, unit: str = 'units',
                 expiry_date: Optional[date] = None, category: Optional[str] = None, 
                 notes: Optional[str] = None):
        """Initialize a new pantry item"""
        self.user_id = user_id
        self.name = name.strip().title()  # Normalize name
        self.quantity = quantity
        self.unit = unit.lower()
        self.expiry_date = expiry_date
        self.category = category.lower() if category else None
        self.notes = notes
    
    @property
    def is_expired(self) -> bool:
        """Check if the item is expired"""
        if not self.expiry_date:
            return False
        return self.expiry_date < date.today()
    
    @property
    def days_until_expiry(self) -> Optional[int]:
        """Get days until expiry (negative if expired)"""
        if not self.expiry_date:
            return None
        delta = self.expiry_date - date.today()
        return delta.days
    
    @property
    def is_expiring_soon(self, days_threshold: int = 3) -> bool:
        """Check if item is expiring within threshold days"""
        days_left = self.days_until_expiry
        if days_left is None:
            return False
        return 0 <= days_left <= days_threshold
    
    def update_item(self, name: Optional[str] = None, quantity: Optional[float] = None, 
                   unit: Optional[str] = None, expiry_date: Optional[date] = None,
                   category: Optional[str] = None, notes: Optional[str] = None) -> None:
        """Update pantry item details"""
        if name is not None:
            self.name = name.strip().title()
        if quantity is not None:
            self.quantity = quantity
        if unit is not None:
            self.unit = unit.lower()
        if expiry_date is not None:
            self.expiry_date = expiry_date
        if category is not None:
            self.category = category.lower() if category else None
        if notes is not None:
            self.notes = notes
        
        self.updated_at = datetime.utcnow()
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert pantry item to dictionary for API responses"""
        return {
            'id': str(self.id),
            'user_id': str(self.user_id),
            'name': self.name,
            'quantity': self.quantity,
            'unit': self.unit,
            'expiry_date': self.expiry_date.isoformat() if self.expiry_date else None,
            'category': self.category,
            'notes': self.notes,
            'is_expired': self.is_expired,
            'days_until_expiry': self.days_until_expiry,
            'is_expiring_soon': self.is_expiring_soon,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None,
        }
    
    def __repr__(self) -> str:
        return f'<PantryItem {self.name} ({self.quantity} {self.unit}) - User: {self.user_id}>' 