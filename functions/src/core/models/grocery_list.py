"""
GroceryList Domain Model
Represents a grocery list generated from meal plans
"""

import uuid
from datetime import datetime
from typing import Optional, List, Dict, Any
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy import Column, String, DateTime, Boolean, ForeignKey, Integer
from sqlalchemy.types import JSON
from decimal import Decimal

from data_access.database import db

class GroceryList(db.Model):
    """GroceryList model for storing user grocery lists"""
    
    __tablename__ = 'grocery_lists'
    
    # Primary Fields
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey('users.id'), nullable=False)
    meal_plan_id = Column(UUID(as_uuid=True), ForeignKey('meal_plans.id'), nullable=True)
    
    # List Configuration
    name = Column(String(255), nullable=False)
    
    # Cost Information
    total_estimated_cost = Column(Integer, nullable=True)  # Cost in cents
    
    # Status
    is_active = Column(Boolean, default=True)
    
    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    def __init__(self, user_id: str, name: str, meal_plan_id: Optional[str] = None,
                 total_estimated_cost: Optional[int] = None):
        """Initialize a new grocery list"""
        self.user_id = user_id
        self.name = name
        self.meal_plan_id = meal_plan_id
        self.total_estimated_cost = total_estimated_cost
    
    @property
    def total_cost_usd(self) -> Optional[float]:
        """Get total cost in USD"""
        if self.total_estimated_cost:
            return self.total_estimated_cost / 100.0
        return None
    
    def update_total_cost(self, cost_cents: int) -> None:
        """Update the total estimated cost"""
        self.total_estimated_cost = cost_cents
        self.updated_at = datetime.utcnow()
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert grocery list to dictionary for API responses"""
        return {
            'id': str(self.id),
            'user_id': str(self.user_id),
            'meal_plan_id': str(self.meal_plan_id) if self.meal_plan_id else None,
            'name': self.name,
            'total_estimated_cost': self.total_estimated_cost,
            'total_cost_usd': self.total_cost_usd,
            'is_active': self.is_active,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None,
        }
    
    def __repr__(self) -> str:
        return f'<GroceryList {self.name} for user {self.user_id}>'


class GroceryListItem(db.Model):
    """GroceryListItem model for individual items in grocery lists"""
    
    __tablename__ = 'grocery_list_items'
    
    # Primary Fields
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    grocery_list_id = Column(UUID(as_uuid=True), ForeignKey('grocery_lists.id'), nullable=False)
    
    # Item Information
    ingredient_name = Column(String(255), nullable=False)
    quantity = Column(String(100), nullable=False)
    unit = Column(String(50), nullable=True)
    category = Column(String(100), nullable=True)  # produce, dairy, meat, pantry, etc.
    
    # Cost Information
    estimated_cost = Column(Integer, nullable=True)  # Cost in cents
    
    # Status
    is_checked = Column(Boolean, default=False)
    is_custom = Column(Boolean, default=False)  # user-added vs recipe-derived
    
    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow)
    
    def __init__(self, grocery_list_id: str, ingredient_name: str, quantity: str,
                 unit: Optional[str] = None, category: Optional[str] = None,
                 estimated_cost: Optional[int] = None, is_custom: bool = False):
        """Initialize a new grocery list item"""
        self.grocery_list_id = grocery_list_id
        self.ingredient_name = ingredient_name
        self.quantity = quantity
        self.unit = unit
        self.category = category
        self.estimated_cost = estimated_cost
        self.is_custom = is_custom
    
    @property
    def cost_usd(self) -> Optional[float]:
        """Get cost in USD"""
        if self.estimated_cost:
            return self.estimated_cost / 100.0
        return None
    
    def toggle_checked(self) -> None:
        """Toggle the checked status of the item"""
        self.is_checked = not self.is_checked
    
    def update_quantity(self, new_quantity: str, new_unit: Optional[str] = None) -> None:
        """Update the quantity and optionally unit of the item"""
        self.quantity = new_quantity
        if new_unit is not None:
            self.unit = new_unit
    
    def update_cost(self, cost_cents: int) -> None:
        """Update the estimated cost"""
        self.estimated_cost = cost_cents
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert grocery list item to dictionary for API responses"""
        return {
            'id': str(self.id),
            'grocery_list_id': str(self.grocery_list_id),
            'ingredient_name': self.ingredient_name,
            'quantity': self.quantity,
            'unit': self.unit,
            'category': self.category,
            'estimated_cost': self.estimated_cost,
            'cost_usd': self.cost_usd,
            'is_checked': self.is_checked,
            'is_custom': self.is_custom,
            'created_at': self.created_at.isoformat() if self.created_at else None,
        }
    
    def __repr__(self) -> str:
        return f'<GroceryListItem {self.ingredient_name} ({self.quantity} {self.unit or ""})>' 