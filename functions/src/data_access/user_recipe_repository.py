"""
User Recipe Repository - Data Access Layer
Handles database operations for user recipes and categories
"""

from typing import List, Optional, Dict, Any, Tuple
from sqlalchemy import and_, or_, func, desc, asc
from sqlalchemy.orm import Session, joinedload
from sqlalchemy.exc import IntegrityError

from core.models.user_recipe import UserRecipe
from core.models.user_recipe_category import UserRecipeCategory, UserRecipeCategoryAssignment
from core.models.recipe import Recipe
from data_access.database import db


class UserRecipeRepository:
    """Repository for User Recipe operations"""
    
    def __init__(self, session: Session = None):
        """Initialize repository with database session"""
        self.session = session or db.session
    
    # Recipe Collection Operations
    
    def get_user_recipes(self, user_id: str, filters: Optional[Dict[str, Any]] = None, 
                        page: int = 1, page_size: int = 20, 
                        sort_by: str = 'created_at', sort_order: str = 'desc') -> Tuple[List[UserRecipe], int]:
        """Get user's recipe collection with filtering, pagination, and sorting"""
        query = self.session.query(UserRecipe).filter(UserRecipe.user_id == user_id)
        
        # Apply filters
        if filters:
            query = self._apply_recipe_filters(query, filters)
        
        # Get total count before pagination
        total_count = query.count()
        
        # Apply sorting
        query = self._apply_sorting(query, sort_by, sort_order)
        
        # Apply pagination
        offset = (page - 1) * page_size
        recipes = query.offset(offset).limit(page_size).options(
            joinedload(UserRecipe.category_assignments).joinedload(UserRecipeCategoryAssignment.category)
        ).all()
        
        return recipes, total_count
    
    def get_user_recipe_by_id(self, user_recipe_id: str, user_id: str) -> Optional[UserRecipe]:
        """Get a specific user recipe by ID (ensuring user ownership)"""
        return self.session.query(UserRecipe).filter(
            and_(
                UserRecipe.id == user_recipe_id,
                UserRecipe.user_id == user_id
            )
        ).options(
            joinedload(UserRecipe.category_assignments).joinedload(UserRecipeCategoryAssignment.category),
            joinedload(UserRecipe.original_recipe)
        ).first()
    
    def check_recipe_favorited(self, user_id: str, recipe_id: int) -> bool:
        """Check if a catalog recipe is already favorited by user"""
        return self.session.query(UserRecipe).filter(
            and_(
                UserRecipe.user_id == user_id,
                UserRecipe.recipe_id == recipe_id
            )
        ).first() is not None
    
    def get_favorited_user_recipe(self, user_id: str, recipe_id: int) -> Optional[UserRecipe]:
        """Get favorited user recipe by original recipe ID"""
        return self.session.query(UserRecipe).filter(
            and_(
                UserRecipe.user_id == user_id,
                UserRecipe.recipe_id == recipe_id
            )
        ).first()
    
    def create_user_recipe(self, user_recipe: UserRecipe) -> UserRecipe:
        """Create a new user recipe"""
        try:
            self.session.add(user_recipe)
            self.session.commit()
            self.session.refresh(user_recipe)
            return user_recipe
        except IntegrityError as e:
            self.session.rollback()
            raise ValueError(f"Failed to create user recipe: {str(e)}")
    
    def update_user_recipe(self, user_recipe: UserRecipe) -> UserRecipe:
        """Update an existing user recipe"""
        try:
            self.session.commit()
            self.session.refresh(user_recipe)
            return user_recipe
        except IntegrityError as e:
            self.session.rollback()
            raise ValueError(f"Failed to update user recipe: {str(e)}")
    
    def delete_user_recipe(self, user_recipe_id: str, user_id: str) -> bool:
        """Delete a user recipe (ensuring user ownership)"""
        user_recipe = self.session.query(UserRecipe).filter(
            and_(
                UserRecipe.id == user_recipe_id,
                UserRecipe.user_id == user_id
            )
        ).first()
        
        if not user_recipe:
            return False
        
        try:
            self.session.delete(user_recipe)
            self.session.commit()
            return True
        except Exception as e:
            self.session.rollback()
            raise ValueError(f"Failed to delete user recipe: {str(e)}")
    
    def get_user_recipe_stats(self, user_id: str) -> Dict[str, Any]:
        """Get statistics about user's recipe collection"""
        total_recipes = self.session.query(UserRecipe).filter(UserRecipe.user_id == user_id).count()
        custom_recipes = self.session.query(UserRecipe).filter(
            and_(UserRecipe.user_id == user_id, UserRecipe.is_custom == True)
        ).count()
        favorited_recipes = self.session.query(UserRecipe).filter(
            and_(UserRecipe.user_id == user_id, UserRecipe.is_custom == False)
        ).count()
        
        # Get cuisine type distribution
        cuisine_stats = self.session.query(
            UserRecipe.cuisine_type,
            func.count(UserRecipe.id).label('count')
        ).filter(
            and_(UserRecipe.user_id == user_id, UserRecipe.cuisine_type.isnot(None))
        ).group_by(UserRecipe.cuisine_type).all()
        
        # Get meal type distribution
        meal_stats = self.session.query(
            UserRecipe.meal_type,
            func.count(UserRecipe.id).label('count')
        ).filter(
            and_(UserRecipe.user_id == user_id, UserRecipe.meal_type.isnot(None))
        ).group_by(UserRecipe.meal_type).all()
        
        return {
            'total_recipes': total_recipes,
            'custom_recipes': custom_recipes,
            'favorited_recipes': favorited_recipes,
            'cuisine_distribution': {stat.cuisine_type: stat.count for stat in cuisine_stats},
            'meal_distribution': {stat.meal_type: stat.count for stat in meal_stats}
        }
    
    # Category Operations
    
    def get_user_categories(self, user_id: str, include_recipe_count: bool = True) -> List[UserRecipeCategory]:
        """Get all categories for a user"""
        query = self.session.query(UserRecipeCategory).filter(UserRecipeCategory.user_id == user_id)
        
        if include_recipe_count:
            query = query.options(joinedload(UserRecipeCategory.recipe_assignments))
        
        return query.order_by(UserRecipeCategory.name).all()
    
    def get_category_by_id(self, category_id: str, user_id: str) -> Optional[UserRecipeCategory]:
        """Get a specific category by ID (ensuring user ownership)"""
        return self.session.query(UserRecipeCategory).filter(
            and_(
                UserRecipeCategory.id == category_id,
                UserRecipeCategory.user_id == user_id
            )
        ).options(
            joinedload(UserRecipeCategory.recipe_assignments).joinedload(UserRecipeCategoryAssignment.user_recipe)
        ).first()
    
    def get_category_by_name(self, user_id: str, name: str) -> Optional[UserRecipeCategory]:
        """Get category by name for a user"""
        return self.session.query(UserRecipeCategory).filter(
            and_(
                UserRecipeCategory.user_id == user_id,
                UserRecipeCategory.name == name.strip()
            )
        ).first()
    
    def create_category(self, category: UserRecipeCategory) -> UserRecipeCategory:
        """Create a new category"""
        try:
            self.session.add(category)
            self.session.commit()
            self.session.refresh(category)
            return category
        except IntegrityError as e:
            self.session.rollback()
            if "unique_user_category_name" in str(e):
                raise ValueError(f"Category name '{category.name}' already exists for this user")
            raise ValueError(f"Failed to create category: {str(e)}")
    
    def update_category(self, category: UserRecipeCategory) -> UserRecipeCategory:
        """Update an existing category"""
        try:
            self.session.commit()
            self.session.refresh(category)
            return category
        except IntegrityError as e:
            self.session.rollback()
            if "unique_user_category_name" in str(e):
                raise ValueError(f"Category name '{category.name}' already exists for this user")
            raise ValueError(f"Failed to update category: {str(e)}")
    
    def delete_category(self, category_id: str, user_id: str) -> bool:
        """Delete a category (ensuring user ownership)"""
        category = self.session.query(UserRecipeCategory).filter(
            and_(
                UserRecipeCategory.id == category_id,
                UserRecipeCategory.user_id == user_id
            )
        ).first()
        
        if not category:
            return False
        
        try:
            self.session.delete(category)
            self.session.commit()
            return True
        except Exception as e:
            self.session.rollback()
            raise ValueError(f"Failed to delete category: {str(e)}")
    
    # Category Assignment Operations
    
    def assign_categories_to_recipe(self, user_recipe_id: str, category_ids: List[str], 
                                   user_id: str) -> bool:
        """Assign multiple categories to a recipe"""
        # Verify user owns the recipe
        user_recipe = self.get_user_recipe_by_id(user_recipe_id, user_id)
        if not user_recipe:
            return False
        
        try:
            # Remove existing assignments
            self.session.query(UserRecipeCategoryAssignment).filter(
                UserRecipeCategoryAssignment.user_recipe_id == user_recipe_id
            ).delete()
            
            # Add new assignments
            for category_id in category_ids:
                # Verify user owns the category
                category = self.get_category_by_id(category_id, user_id)
                if category:
                    assignment = UserRecipeCategoryAssignment(
                        user_recipe_id=user_recipe_id,
                        category_id=category_id
                    )
                    self.session.add(assignment)
            
            self.session.commit()
            return True
        except Exception as e:
            self.session.rollback()
            raise ValueError(f"Failed to assign categories: {str(e)}")
    
    def get_recipes_by_category(self, category_id: str, user_id: str, 
                               page: int = 1, page_size: int = 20) -> Tuple[List[UserRecipe], int]:
        """Get all recipes in a specific category"""
        # Verify user owns the category
        category = self.get_category_by_id(category_id, user_id)
        if not category:
            return [], 0
        
        query = self.session.query(UserRecipe).join(
            UserRecipeCategoryAssignment,
            UserRecipe.id == UserRecipeCategoryAssignment.user_recipe_id
        ).filter(
            and_(
                UserRecipeCategoryAssignment.category_id == category_id,
                UserRecipe.user_id == user_id
            )
        )
        
        total_count = query.count()
        
        offset = (page - 1) * page_size
        recipes = query.order_by(desc(UserRecipe.created_at)).offset(offset).limit(page_size).all()
        
        return recipes, total_count
    
    # Helper Methods
    
    def _apply_recipe_filters(self, query, filters: Dict[str, Any]):
        """Apply filters to recipe query"""
        
        # Search query - search in name, description, and ingredients
        if 'search' in filters and filters['search']:
            search_text = f"%{filters['search']}%"
            query = query.filter(
                or_(
                    UserRecipe.name.ilike(search_text),
                    UserRecipe.description.ilike(search_text),
                    UserRecipe.ingredients.astext.ilike(search_text)
                )
            )
        
        # Recipe type filter (custom vs favorited)
        if 'recipe_type' in filters:
            if filters['recipe_type'] == 'custom':
                query = query.filter(UserRecipe.is_custom == True)
            elif filters['recipe_type'] == 'favorited':
                query = query.filter(UserRecipe.is_custom == False)
        
        # Cuisine type filter
        if 'cuisine_type' in filters and filters['cuisine_type']:
            query = query.filter(UserRecipe.cuisine_type == filters['cuisine_type'])
        
        # Meal type filter
        if 'meal_type' in filters and filters['meal_type']:
            query = query.filter(UserRecipe.meal_type == filters['meal_type'])
        
        # Difficulty level filter
        if 'difficulty_level' in filters and filters['difficulty_level']:
            query = query.filter(UserRecipe.difficulty_level == filters['difficulty_level'])
        
        # Cooking time filter (max minutes)
        if 'max_total_time' in filters and filters['max_total_time']:
            max_time = filters['max_total_time']
            query = query.filter(
                (UserRecipe.prep_time_minutes + UserRecipe.cook_time_minutes) <= max_time
            )
        
        # Category filter
        if 'category_id' in filters and filters['category_id']:
            query = query.join(
                UserRecipeCategoryAssignment,
                UserRecipe.id == UserRecipeCategoryAssignment.user_recipe_id
            ).filter(UserRecipeCategoryAssignment.category_id == filters['category_id'])
        
        # Public/private filter (for custom recipes)
        if 'is_public' in filters:
            query = query.filter(UserRecipe.is_public == filters['is_public'])
        
        return query
    
    def _apply_sorting(self, query, sort_by: str, sort_order: str):
        """Apply sorting to recipe query"""
        sort_column = getattr(UserRecipe, sort_by, UserRecipe.created_at)
        
        if sort_order.lower() == 'desc':
            return query.order_by(desc(sort_column))
        else:
            return query.order_by(asc(sort_column))


class UserRecipeCategoryRepository:
    """Repository for User Recipe Category operations"""
    
    def __init__(self, session: Session = None):
        """Initialize repository with database session"""
        self.session = session or db.session
    
    def create_default_categories_for_user(self, user_id: str) -> List[UserRecipeCategory]:
        """Create default categories for a new user"""
        try:
            categories = UserRecipeCategory.create_default_categories(user_id)
            
            for category in categories:
                self.session.add(category)
            
            self.session.commit()
            
            # Refresh all categories to get their IDs
            for category in categories:
                self.session.refresh(category)
            
            return categories
        except Exception as e:
            self.session.rollback()
            raise ValueError(f"Failed to create default categories: {str(e)}")
    
    def bulk_assign_categories(self, assignments: List[Tuple[str, str]]) -> bool:
        """Bulk assign categories to recipes [(user_recipe_id, category_id), ...]"""
        try:
            for user_recipe_id, category_id in assignments:
                assignment = UserRecipeCategoryAssignment(
                    user_recipe_id=user_recipe_id,
                    category_id=category_id
                )
                self.session.add(assignment)
            
            self.session.commit()
            return True
        except Exception as e:
            self.session.rollback()
            raise ValueError(f"Failed to bulk assign categories: {str(e)}") 