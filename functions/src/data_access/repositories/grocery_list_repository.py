"""
Grocery List Repository
Data access layer for grocery lists and items
"""

import logging
from typing import List, Optional, Dict, Any
from sqlalchemy.exc import SQLAlchemyError

from core.models.grocery_list import GroceryList, GroceryListItem
from data_access.database import db

logger = logging.getLogger(__name__)

class GroceryListRepository:
    """Repository for grocery list data access operations"""
    
    def create(self, grocery_list: GroceryList) -> GroceryList:
        """
        Create a new grocery list
        
        Args:
            grocery_list: GroceryList object to create
            
        Returns:
            Created GroceryList object
            
        Raises:
            SQLAlchemyError: If database operation fails
        """
        try:
            db.session.add(grocery_list)
            db.session.commit()
            logger.info(f"Created grocery list {grocery_list.id} for user {grocery_list.user_id}")
            return grocery_list
        except SQLAlchemyError as e:
            db.session.rollback()
            logger.error(f"Failed to create grocery list: {e}")
            raise
    
    def get_by_id(self, list_id: str) -> Optional[GroceryList]:
        """
        Get a grocery list by ID
        
        Args:
            list_id: ID of the grocery list
            
        Returns:
            GroceryList object or None if not found
        """
        try:
            return db.session.query(GroceryList).filter_by(id=list_id, is_active=True).first()
        except SQLAlchemyError as e:
            logger.error(f"Failed to get grocery list {list_id}: {e}")
            return None
    
    def get_by_user_id(self, user_id: str) -> List[GroceryList]:
        """
        Get all grocery lists for a user
        
        Args:
            user_id: ID of the user
            
        Returns:
            List of GroceryList objects
        """
        try:
            return db.session.query(GroceryList).filter_by(
                user_id=user_id, is_active=True
            ).order_by(GroceryList.created_at.desc()).all()
        except SQLAlchemyError as e:
            logger.error(f"Failed to get grocery lists for user {user_id}: {e}")
            return []
    
    def get_by_meal_plan_id(self, meal_plan_id: str) -> List[GroceryList]:
        """
        Get all grocery lists generated from a specific meal plan
        
        Args:
            meal_plan_id: ID of the meal plan
            
        Returns:
            List of GroceryList objects
        """
        try:
            return db.session.query(GroceryList).filter_by(
                meal_plan_id=meal_plan_id, is_active=True
            ).order_by(GroceryList.created_at.desc()).all()
        except SQLAlchemyError as e:
            logger.error(f"Failed to get grocery lists for meal plan {meal_plan_id}: {e}")
            return []
    
    def update(self, list_id: str, updates: Dict[str, Any]) -> Optional[GroceryList]:
        """
        Update a grocery list
        
        Args:
            list_id: ID of the grocery list
            updates: Dictionary of fields to update
            
        Returns:
            Updated GroceryList object or None if not found
        """
        try:
            grocery_list = self.get_by_id(list_id)
            if not grocery_list:
                return None
            
            for key, value in updates.items():
                if hasattr(grocery_list, key):
                    setattr(grocery_list, key, value)
            
            db.session.commit()
            logger.info(f"Updated grocery list {list_id}")
            return grocery_list
        except SQLAlchemyError as e:
            db.session.rollback()
            logger.error(f"Failed to update grocery list {list_id}: {e}")
            return None
    
    def delete(self, list_id: str) -> bool:
        """
        Soft delete a grocery list (mark as inactive)
        
        Args:
            list_id: ID of the grocery list to delete
            
        Returns:
            True if successful, False otherwise
        """
        try:
            grocery_list = self.get_by_id(list_id)
            if not grocery_list:
                return False
            
            grocery_list.is_active = False
            db.session.commit()
            logger.info(f"Soft deleted grocery list {list_id}")
            return True
        except SQLAlchemyError as e:
            db.session.rollback()
            logger.error(f"Failed to delete grocery list {list_id}: {e}")
            return False
    
    # Grocery List Item Operations
    
    def add_item(self, item: GroceryListItem) -> GroceryListItem:
        """
        Add an item to a grocery list
        
        Args:
            item: GroceryListItem object to add
            
        Returns:
            Created GroceryListItem object
            
        Raises:
            SQLAlchemyError: If database operation fails
        """
        try:
            db.session.add(item)
            db.session.commit()
            logger.info(f"Added item {item.id} to grocery list {item.grocery_list_id}")
            return item
        except SQLAlchemyError as e:
            db.session.rollback()
            logger.error(f"Failed to add item to grocery list: {e}")
            raise
    
    def get_item_by_id(self, item_id: str) -> Optional[GroceryListItem]:
        """
        Get a grocery list item by ID
        
        Args:
            item_id: ID of the grocery list item
            
        Returns:
            GroceryListItem object or None if not found
        """
        try:
            return db.session.query(GroceryListItem).filter_by(id=item_id).first()
        except SQLAlchemyError as e:
            logger.error(f"Failed to get grocery list item {item_id}: {e}")
            return None
    
    def get_items_by_list_id(self, list_id: str) -> List[GroceryListItem]:
        """
        Get all items for a grocery list
        
        Args:
            list_id: ID of the grocery list
            
        Returns:
            List of GroceryListItem objects
        """
        try:
            return db.session.query(GroceryListItem).filter_by(
                grocery_list_id=list_id
            ).order_by(GroceryListItem.category, GroceryListItem.ingredient_name).all()
        except SQLAlchemyError as e:
            logger.error(f"Failed to get items for grocery list {list_id}: {e}")
            return []
    
    def get_items_by_category(self, list_id: str, category: str) -> List[GroceryListItem]:
        """
        Get all items in a specific category for a grocery list
        
        Args:
            list_id: ID of the grocery list
            category: Category to filter by
            
        Returns:
            List of GroceryListItem objects
        """
        try:
            return db.session.query(GroceryListItem).filter_by(
                grocery_list_id=list_id, category=category
            ).order_by(GroceryListItem.ingredient_name).all()
        except SQLAlchemyError as e:
            logger.error(f"Failed to get items by category for grocery list {list_id}: {e}")
            return []
    
    def update_item(self, item_id: str, updates: Dict[str, Any]) -> Optional[GroceryListItem]:
        """
        Update a grocery list item
        
        Args:
            item_id: ID of the grocery list item
            updates: Dictionary of fields to update
            
        Returns:
            Updated GroceryListItem object or None if not found
        """
        try:
            item = self.get_item_by_id(item_id)
            if not item:
                return None
            
            for key, value in updates.items():
                if hasattr(item, key):
                    setattr(item, key, value)
            
            db.session.commit()
            logger.info(f"Updated grocery list item {item_id}")
            return item
        except SQLAlchemyError as e:
            db.session.rollback()
            logger.error(f"Failed to update grocery list item {item_id}: {e}")
            return None
    
    def toggle_item_checked(self, item_id: str) -> Optional[GroceryListItem]:
        """
        Toggle the checked status of a grocery list item
        
        Args:
            item_id: ID of the grocery list item
            
        Returns:
            Updated GroceryListItem object or None if not found
        """
        try:
            item = self.get_item_by_id(item_id)
            if not item:
                return None
            
            item.is_checked = not item.is_checked
            db.session.commit()
            logger.info(f"Toggled checked status for item {item_id} to {item.is_checked}")
            return item
        except SQLAlchemyError as e:
            db.session.rollback()
            logger.error(f"Failed to toggle item checked status {item_id}: {e}")
            return None
    
    def delete_item(self, item_id: str) -> bool:
        """
        Delete a grocery list item
        
        Args:
            item_id: ID of the grocery list item to delete
            
        Returns:
            True if successful, False otherwise
        """
        try:
            item = self.get_item_by_id(item_id)
            if not item:
                return False
            
            db.session.delete(item)
            db.session.commit()
            logger.info(f"Deleted grocery list item {item_id}")
            return True
        except SQLAlchemyError as e:
            db.session.rollback()
            logger.error(f"Failed to delete grocery list item {item_id}: {e}")
            return False
    
    def get_checked_items_count(self, list_id: str) -> int:
        """
        Get count of checked items in a grocery list
        
        Args:
            list_id: ID of the grocery list
            
        Returns:
            Number of checked items
        """
        try:
            return db.session.query(GroceryListItem).filter_by(
                grocery_list_id=list_id, is_checked=True
            ).count()
        except SQLAlchemyError as e:
            logger.error(f"Failed to get checked items count for list {list_id}: {e}")
            return 0
    
    def get_unchecked_items_count(self, list_id: str) -> int:
        """
        Get count of unchecked items in a grocery list
        
        Args:
            list_id: ID of the grocery list
            
        Returns:
            Number of unchecked items
        """
        try:
            return db.session.query(GroceryListItem).filter_by(
                grocery_list_id=list_id, is_checked=False
            ).count()
        except SQLAlchemyError as e:
            logger.error(f"Failed to get unchecked items count for list {list_id}: {e}")
            return 0
    
    def get_items_by_custom_status(self, list_id: str, is_custom: bool) -> List[GroceryListItem]:
        """
        Get items by custom status (user-added vs recipe-derived)
        
        Args:
            list_id: ID of the grocery list
            is_custom: True for user-added items, False for recipe-derived
            
        Returns:
            List of GroceryListItem objects
        """
        try:
            return db.session.query(GroceryListItem).filter_by(
                grocery_list_id=list_id, is_custom=is_custom
            ).order_by(GroceryListItem.ingredient_name).all()
        except SQLAlchemyError as e:
            logger.error(f"Failed to get custom items for list {list_id}: {e}")
            return []
    
    def get_list_statistics(self, list_id: str) -> Dict[str, Any]:
        """
        Get comprehensive statistics for a grocery list
        
        Args:
            list_id: ID of the grocery list
            
        Returns:
            Dictionary with list statistics
        """
        try:
            items = self.get_items_by_list_id(list_id)
            
            total_items = len(items)
            checked_items = len([item for item in items if item.is_checked])
            unchecked_items = total_items - checked_items
            custom_items = len([item for item in items if item.is_custom])
            recipe_items = total_items - custom_items
            
            # Group by category
            categories = {}
            for item in items:
                category = item.category or 'other'
                if category not in categories:
                    categories[category] = 0
                categories[category] += 1
            
            total_cost = sum(item.estimated_cost or 0 for item in items)
            
            return {
                'total_items': total_items,
                'checked_items': checked_items,
                'unchecked_items': unchecked_items,
                'custom_items': custom_items,
                'recipe_items': recipe_items,
                'completion_percentage': (checked_items / total_items * 100) if total_items > 0 else 0,
                'categories': categories,
                'total_estimated_cost_cents': total_cost,
                'total_estimated_cost_usd': total_cost / 100.0 if total_cost else 0
            }
        except SQLAlchemyError as e:
            logger.error(f"Failed to get statistics for list {list_id}: {e}")
            return {}
    
    def bulk_update_items(self, item_updates: List[Dict[str, Any]]) -> bool:
        """
        Bulk update multiple grocery list items
        
        Args:
            item_updates: List of dictionaries with item_id and updates
            
        Returns:
            True if successful, False otherwise
        """
        try:
            for update_data in item_updates:
                item_id = update_data.get('item_id')
                updates = update_data.get('updates', {})
                
                if item_id and updates:
                    item = self.get_item_by_id(item_id)
                    if item:
                        for key, value in updates.items():
                            if hasattr(item, key):
                                setattr(item, key, value)
            
            db.session.commit()
            logger.info(f"Bulk updated {len(item_updates)} grocery list items")
            return True
        except SQLAlchemyError as e:
            db.session.rollback()
            logger.error(f"Failed to bulk update items: {e}")
            return False 