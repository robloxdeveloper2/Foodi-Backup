"""
Pantry Service
Business logic layer for pantry management
"""

import logging
from datetime import date
from typing import List, Optional, Dict, Any, Tuple
from sqlalchemy.orm import Session

from core.models.pantry_item import PantryItem
from data_access.pantry_repository import PantryRepository
from core.exceptions import (
    AppError, 
    ValidationError, 
    NotFoundError, 
    AuthorizationError
)

# Set up logging
logger = logging.getLogger(__name__)


class PantryService:
    """Service for pantry management business logic"""
    
    def __init__(self, db_session: Optional[Session] = None):
        """Initialize service with repository"""
        self.pantry_repo = PantryRepository(db_session)
    
    def add_pantry_item(self, user_id: str, name: str, quantity: float, 
                       unit: str = 'units', expiry_date: Optional[date] = None,
                       category: Optional[str] = None, notes: Optional[str] = None) -> PantryItem:
        """Add a new item to user's pantry"""
        try:
            # Additional business logic validation
            if quantity <= 0:
                raise ValidationError("Quantity must be greater than 0")
            
            if not name or not name.strip():
                raise ValidationError("Item name is required")
            
            # Check for duplicate items (same name and unit for user)
            existing_items, _ = self.pantry_repo.get_user_pantry_items(
                user_id=user_id,
                search=name.strip(),
                page_size=100  # Check reasonable amount
            )
            
            # Check if exact match exists
            name_normalized = name.strip().lower()
            unit_normalized = unit.lower()
            
            for item in existing_items:
                if (item.name.lower() == name_normalized and 
                    item.unit.lower() == unit_normalized):
                    logger.warning(f"Duplicate pantry item detected for user {user_id}: {name} ({unit})")
                    # For MVP, we'll allow duplicates but log a warning
                    # In the future, we might want to merge quantities
                    break
            
            # Create the pantry item
            pantry_item = self.pantry_repo.create_pantry_item(
                user_id=user_id,
                name=name,
                quantity=quantity,
                unit=unit,
                expiry_date=expiry_date,
                category=category,
                notes=notes
            )
            
            logger.info(f"Created pantry item {pantry_item.id} for user {user_id}")
            return pantry_item
            
        except Exception as e:
            logger.error(f"Error adding pantry item for user {user_id}: {str(e)}")
            raise
    
    def get_pantry_item(self, item_id: str, user_id: str) -> PantryItem:
        """Get a specific pantry item for a user"""
        try:
            pantry_item = self.pantry_repo.get_pantry_item_by_id(item_id, user_id)
            if not pantry_item:
                raise NotFoundError("Pantry item not found")
            
            return pantry_item
            
        except Exception as e:
            logger.error(f"Error getting pantry item {item_id} for user {user_id}: {str(e)}")
            raise
    
    def get_user_pantry(self, user_id: str, page: int = 1, page_size: int = 20,
                       category: Optional[str] = None, expired_only: bool = False,
                       expiring_soon: bool = False, search: Optional[str] = None,
                       sort_by: str = 'name', sort_order: str = 'asc') -> Tuple[List[PantryItem], Dict[str, Any]]:
        """Get user's pantry items with pagination and filtering"""
        try:
            # Validate pagination parameters
            if page < 1:
                page = 1
            if page_size < 1 or page_size > 100:
                page_size = 20
            
            # Get pantry items
            items, total = self.pantry_repo.get_user_pantry_items(
                user_id=user_id,
                page=page,
                page_size=page_size,
                category=category,
                expired_only=expired_only,
                expiring_soon=expiring_soon,
                search=search,
                sort_by=sort_by,
                sort_order=sort_order
            )
            
            # Calculate pagination info
            total_pages = (total + page_size - 1) // page_size
            has_next = page < total_pages
            has_prev = page > 1
            
            pagination_info = {
                'total': total,
                'page': page,
                'page_size': page_size,
                'total_pages': total_pages,
                'has_next': has_next,
                'has_prev': has_prev
            }
            
            logger.info(f"Retrieved {len(items)} pantry items for user {user_id} (page {page})")
            return items, pagination_info
            
        except Exception as e:
            logger.error(f"Error getting pantry items for user {user_id}: {str(e)}")
            raise
    
    def update_pantry_item(self, item_id: str, user_id: str, **updates) -> PantryItem:
        """Update a pantry item"""
        try:
            # Validate updates
            if 'quantity' in updates and updates['quantity'] <= 0:
                raise ValidationError("Quantity must be greater than 0")
            
            if 'name' in updates and (not updates['name'] or not updates['name'].strip()):
                raise ValidationError("Item name is required")
            
            # Update the item
            pantry_item = self.pantry_repo.update_pantry_item(item_id, user_id, **updates)
            if not pantry_item:
                raise NotFoundError("Pantry item not found")
            
            logger.info(f"Updated pantry item {item_id} for user {user_id}")
            return pantry_item
            
        except Exception as e:
            logger.error(f"Error updating pantry item {item_id} for user {user_id}: {str(e)}")
            raise
    
    def delete_pantry_item(self, item_id: str, user_id: str) -> bool:
        """Delete a pantry item"""
        try:
            success = self.pantry_repo.delete_pantry_item(item_id, user_id)
            if not success:
                raise NotFoundError("Pantry item not found")
            
            logger.info(f"Deleted pantry item {item_id} for user {user_id}")
            return success
            
        except Exception as e:
            logger.error(f"Error deleting pantry item {item_id} for user {user_id}: {str(e)}")
            raise
    
    def get_pantry_statistics(self, user_id: str) -> Dict[str, Any]:
        """Get pantry statistics for a user"""
        try:
            stats = self.pantry_repo.get_pantry_stats(user_id)
            
            # Add additional business logic calculations
            stats['health_score'] = self._calculate_pantry_health_score(stats)
            stats['recommendations'] = self._generate_pantry_recommendations(stats)
            
            logger.info(f"Generated pantry statistics for user {user_id}")
            return stats
            
        except Exception as e:
            logger.error(f"Error getting pantry statistics for user {user_id}: {str(e)}")
            raise
    
    def cleanup_expired_items(self, user_id: str) -> int:
        """Remove all expired items from user's pantry"""
        try:
            deleted_count = self.pantry_repo.bulk_delete_expired_items(user_id)
            
            logger.info(f"Cleaned up {deleted_count} expired items for user {user_id}")
            return deleted_count
            
        except Exception as e:
            logger.error(f"Error cleaning up expired items for user {user_id}: {str(e)}")
            raise
    
    def get_expiring_items(self, user_id: str, days_ahead: int = 3) -> List[PantryItem]:
        """Get items expiring within specified days"""
        try:
            items, _ = self.pantry_repo.get_user_pantry_items(
                user_id=user_id,
                expiring_soon=True,
                page_size=100,  # Get all expiring items
                sort_by='expiry_date',
                sort_order='asc'
            )
            
            # Filter by specific days ahead
            filtered_items = []
            for item in items:
                if item.days_until_expiry is not None and item.days_until_expiry <= days_ahead:
                    filtered_items.append(item)
            
            logger.info(f"Found {len(filtered_items)} items expiring within {days_ahead} days for user {user_id}")
            return filtered_items
            
        except Exception as e:
            logger.error(f"Error getting expiring items for user {user_id}: {str(e)}")
            raise
    
    def _calculate_pantry_health_score(self, stats: Dict[str, Any]) -> int:
        """Calculate a health score for the pantry (0-100)"""
        total_items = stats.get('total_items', 0)
        if total_items == 0:
            return 100  # Empty pantry is technically "healthy"
        
        expired_items = stats.get('expired_items', 0)
        expiring_soon_items = stats.get('expiring_soon_items', 0)
        
        # Calculate score based on expired/expiring items
        problem_items = expired_items + (expiring_soon_items * 0.5)  # Weight expiring items less
        health_ratio = max(0, (total_items - problem_items) / total_items)
        
        return int(health_ratio * 100)
    
    def _generate_pantry_recommendations(self, stats: Dict[str, Any]) -> List[str]:
        """Generate recommendations based on pantry statistics"""
        recommendations = []
        
        expired_items = stats.get('expired_items', 0)
        expiring_soon_items = stats.get('expiring_soon_items', 0)
        total_items = stats.get('total_items', 0)
        
        if expired_items > 0:
            recommendations.append(f"You have {expired_items} expired item(s). Consider removing them from your pantry.")
        
        if expiring_soon_items > 0:
            recommendations.append(f"You have {expiring_soon_items} item(s) expiring soon. Plan meals to use them first.")
        
        if total_items == 0:
            recommendations.append("Your pantry is empty. Add some items to start tracking your inventory.")
        
        if total_items > 50:
            recommendations.append("You have a well-stocked pantry! Consider organizing by category for easier meal planning.")
        
        categories = stats.get('categories', {})
        if len(categories) > 5:
            recommendations.append("Great variety in your pantry categories! This gives you flexibility for meal planning.")
        
        return recommendations 