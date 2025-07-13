"""
Pantry Item Repository
Data access layer for pantry items
"""

import uuid
from datetime import date
from typing import List, Optional, Dict, Any, Tuple
from sqlalchemy import and_, or_, desc, asc, func
from sqlalchemy.orm import Session
from sqlalchemy.exc import SQLAlchemyError

from core.models.pantry_item import PantryItem
from data_access.database import db
from core.exceptions import (
    AppError, 
    ValidationError, 
    NotFoundError
)


class PantryRepository:
    """Repository for pantry item data operations"""
    
    def __init__(self, db_session: Optional[Session] = None):
        """Initialize repository with optional database session"""
        self.db_session = db_session or db.session
    
    def create_pantry_item(self, user_id: str, name: str, quantity: float, 
                          unit: str = 'units', expiry_date: Optional[date] = None,
                          category: Optional[str] = None, notes: Optional[str] = None) -> PantryItem:
        """Create a new pantry item"""
        try:
            # Validate user_id format
            try:
                uuid.UUID(user_id)
            except ValueError:
                raise ValidationError("Invalid user ID format")
            
            # Create new pantry item
            pantry_item = PantryItem(
                user_id=user_id,
                name=name,
                quantity=quantity,
                unit=unit,
                expiry_date=expiry_date,
                category=category,
                notes=notes
            )
            
            self.db_session.add(pantry_item)
            self.db_session.commit()
            self.db_session.refresh(pantry_item)
            
            return pantry_item
            
        except SQLAlchemyError as e:
            self.db_session.rollback()
            raise AppError(f"Failed to create pantry item: {str(e)}", status_code=500)
        except Exception as e:
            self.db_session.rollback()
            raise AppError(f"Unexpected error creating pantry item: {str(e)}", status_code=500)
    
    def get_pantry_item_by_id(self, item_id: str, user_id: str) -> Optional[PantryItem]:
        """Get a pantry item by ID for a specific user"""
        try:
            # Validate IDs format
            try:
                uuid.UUID(item_id)
                uuid.UUID(user_id)
            except ValueError:
                raise ValidationError("Invalid ID format")
            
            return self.db_session.query(PantryItem).filter(
                and_(
                    PantryItem.id == item_id,
                    PantryItem.user_id == user_id
                )
            ).first()
            
        except SQLAlchemyError as e:
            raise AppError(f"Failed to get pantry item: {str(e)}", status_code=500)
    
    def get_user_pantry_items(self, user_id: str, page: int = 1, page_size: int = 20,
                             category: Optional[str] = None, expired_only: bool = False,
                             expiring_soon: bool = False, search: Optional[str] = None,
                             sort_by: str = 'name', sort_order: str = 'asc') -> Tuple[List[PantryItem], int]:
        """Get paginated pantry items for a user with filtering and sorting"""
        try:
            # Validate user_id format
            try:
                uuid.UUID(user_id)
            except ValueError:
                raise ValidationError("Invalid user ID format")
            
            # Base query
            query = self.db_session.query(PantryItem).filter(
                PantryItem.user_id == user_id
            )
            
            # Apply filters
            if category:
                query = query.filter(PantryItem.category == category.lower())
            
            if expired_only:
                query = query.filter(PantryItem.expiry_date < date.today())
            elif expiring_soon:
                # Items expiring within 3 days
                from datetime import timedelta
                soon_date = date.today() + timedelta(days=3)
                query = query.filter(
                    and_(
                        PantryItem.expiry_date.isnot(None),
                        PantryItem.expiry_date <= soon_date,
                        PantryItem.expiry_date >= date.today()
                    )
                )
            
            if search:
                search_term = f"%{search.lower()}%"
                query = query.filter(
                    or_(
                        func.lower(PantryItem.name).like(search_term),
                        func.lower(PantryItem.notes).like(search_term)
                    )
                )
            
            # Apply sorting
            sort_column = getattr(PantryItem, sort_by, PantryItem.name)
            if sort_order.lower() == 'desc':
                query = query.order_by(desc(sort_column))
            else:
                query = query.order_by(asc(sort_column))
            
            # Get total count
            total = query.count()
            
            # Apply pagination
            offset = (page - 1) * page_size
            items = query.offset(offset).limit(page_size).all()
            
            return items, total
            
        except SQLAlchemyError as e:
            raise AppError(f"Failed to get pantry items: {str(e)}", status_code=500)
    
    def update_pantry_item(self, item_id: str, user_id: str, **updates) -> Optional[PantryItem]:
        """Update a pantry item"""
        try:
            # Get existing item
            pantry_item = self.get_pantry_item_by_id(item_id, user_id)
            if not pantry_item:
                raise NotFoundError("Pantry item not found")
            
            # Update fields
            pantry_item.update_item(**updates)
            
            self.db_session.commit()
            self.db_session.refresh(pantry_item)
            
            return pantry_item
            
        except SQLAlchemyError as e:
            self.db_session.rollback()
            raise AppError(f"Failed to update pantry item: {str(e)}", status_code=500)
        except Exception as e:
            self.db_session.rollback()
            raise
    
    def delete_pantry_item(self, item_id: str, user_id: str) -> bool:
        """Delete a pantry item"""
        try:
            # Get existing item
            pantry_item = self.get_pantry_item_by_id(item_id, user_id)
            if not pantry_item:
                raise NotFoundError("Pantry item not found")
            
            self.db_session.delete(pantry_item)
            self.db_session.commit()
            
            return True
            
        except SQLAlchemyError as e:
            self.db_session.rollback()
            raise AppError(f"Failed to delete pantry item: {str(e)}", status_code=500)
        except Exception as e:
            self.db_session.rollback()
            raise
    
    def get_pantry_stats(self, user_id: str) -> Dict[str, Any]:
        """Get pantry statistics for a user"""
        try:
            # Validate user_id format
            try:
                uuid.UUID(user_id)
            except ValueError:
                raise ValidationError("Invalid user ID format")
            
            # Get all items for user
            items = self.db_session.query(PantryItem).filter(
                PantryItem.user_id == user_id
            ).all()
            
            # Calculate statistics
            total_items = len(items)
            expired_items = sum(1 for item in items if item.is_expired)
            expiring_soon_items = sum(1 for item in items if item.is_expiring_soon)
            
            # Category breakdown
            categories = {}
            for item in items:
                category = item.category or 'uncategorized'
                categories[category] = categories.get(category, 0) + 1
            
            # Unit breakdown
            units = {}
            for item in items:
                unit = item.unit
                units[unit] = units.get(unit, 0) + 1
            
            return {
                'total_items': total_items,
                'expired_items': expired_items,
                'expiring_soon_items': expiring_soon_items,
                'categories': categories,
                'units': units
            }
            
        except SQLAlchemyError as e:
            raise AppError(f"Failed to get pantry stats: {str(e)}", status_code=500)
    
    def bulk_delete_expired_items(self, user_id: str) -> int:
        """Delete all expired items for a user"""
        try:
            # Validate user_id format
            try:
                uuid.UUID(user_id)
            except ValueError:
                raise ValidationError("Invalid user ID format")
            
            # Delete expired items
            deleted_count = self.db_session.query(PantryItem).filter(
                and_(
                    PantryItem.user_id == user_id,
                    PantryItem.expiry_date < date.today()
                )
            ).delete(synchronize_session=False)
            
            self.db_session.commit()
            
            return deleted_count
            
        except SQLAlchemyError as e:
            self.db_session.rollback()
            raise AppError(f"Failed to delete expired items: {str(e)}", status_code=500)
        except Exception as e:
            self.db_session.rollback()
            raise 