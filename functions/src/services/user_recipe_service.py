"""
User Recipe Service - Business Logic Layer
Handles business operations for user recipes and categories
"""

import json
from datetime import datetime
from typing import List, Optional, Dict, Any, Tuple
from io import StringIO

from core.models.user_recipe import UserRecipe
from core.models.user_recipe_category import UserRecipeCategory
from core.models.recipe import Recipe
from data_access.user_recipe_repository import UserRecipeRepository, UserRecipeCategoryRepository
from data_access.recipe_repository import RecipeRepository


class UserRecipeService:
    """Service for managing user recipe collections"""
    
    def __init__(self):
        """Initialize service with repositories"""
        self.user_recipe_repo = UserRecipeRepository()
        self.category_repo = UserRecipeCategoryRepository()
        self.recipe_repo = RecipeRepository()
    
    # Recipe Collection Management
    
    def get_user_recipe_collection(self, user_id: str, filters: Optional[Dict[str, Any]] = None,
                                  page: int = 1, page_size: int = 20,
                                  sort_by: str = 'created_at', sort_order: str = 'desc') -> Dict[str, Any]:
        """Get user's recipe collection with filtering and pagination"""
        # Validate user
        if not self._validate_user_access(user_id):
            raise ValueError("Invalid user access")
        
        # Get recipes and total count
        recipes, total_count = self.user_recipe_repo.get_user_recipes(
            user_id=user_id,
            filters=filters,
            page=page,
            page_size=page_size,
            sort_by=sort_by,
            sort_order=sort_order
        )
        
        # Calculate pagination info
        total_pages = (total_count + page_size - 1) // page_size
        has_next = page < total_pages
        has_prev = page > 1
        
        return {
            'recipes': [recipe.to_dict() for recipe in recipes],
            'pagination': {
                'current_page': page,
                'page_size': page_size,
                'total_count': total_count,
                'total_pages': total_pages,
                'has_next': has_next,
                'has_prev': has_prev
            },
            'filters_applied': filters or {},
            'sort': {
                'sort_by': sort_by,
                'sort_order': sort_order
            }
        }
    
    def get_user_recipe_by_id(self, user_recipe_id: str, user_id: str) -> Optional[Dict[str, Any]]:
        """Get a specific user recipe by ID"""
        if not self._validate_user_access(user_id):
            raise ValueError("Invalid user access")
        
        user_recipe = self.user_recipe_repo.get_user_recipe_by_id(user_recipe_id, user_id)
        
        if not user_recipe:
            return None
        
        return user_recipe.to_dict()
    
    def favorite_recipe(self, user_id: str, recipe_id: str) -> Dict[str, Any]:
        """Add a catalog recipe to user's favorites"""
        if not self._validate_user_access(user_id):
            raise ValueError("Invalid user access")
        
        # Convert recipe_id from string to int (since it comes from URL)
        try:
            recipe_id_int = int(recipe_id)
        except ValueError:
            raise ValueError("Invalid recipe ID format")
        
        # Check if recipe exists in catalog
        recipe = self.recipe_repo.get_recipe_by_id(recipe_id_int)
        if not recipe:
            raise ValueError("Recipe not found in catalog")
        
        # Check if already favorited
        if self.user_recipe_repo.check_recipe_favorited(user_id, recipe_id_int):
            # Return existing favorited recipe instead of error
            existing_recipe = self.user_recipe_repo.get_favorited_user_recipe(user_id, recipe_id_int)
            if existing_recipe:
                return existing_recipe.to_dict()
            else:
                raise ValueError("Recipe is already in your collection")
        
        # Create user recipe from catalog recipe
        user_recipe = UserRecipe.from_recipe(user_id, recipe)
        
        # Save to database
        created_recipe = self.user_recipe_repo.create_user_recipe(user_recipe)
        
        return created_recipe.to_dict()
    
    def unfavorite_recipe(self, user_id: str, recipe_id: str) -> bool:
        """Remove a favorited recipe from user's collection"""
        if not self._validate_user_access(user_id):
            raise ValueError("Invalid user access")
        
        # Convert recipe_id from string to int
        try:
            recipe_id_int = int(recipe_id)
        except ValueError:
            raise ValueError("Invalid recipe ID format")
        
        # Find the favorited recipe
        user_recipe = self.user_recipe_repo.get_favorited_user_recipe(user_id, recipe_id_int)
        
        if not user_recipe:
            return False
        
        # Delete the user recipe
        return self.user_recipe_repo.delete_user_recipe(str(user_recipe.id), user_id)
    
    def check_recipe_favorited(self, user_id: str, recipe_id: str) -> bool:
        """Check if a recipe is in user's favorites"""
        if not self._validate_user_access(user_id):
            return False
        
        # Convert recipe_id from string to int
        try:
            recipe_id_int = int(recipe_id)
        except ValueError:
            return False
        
        return self.user_recipe_repo.check_recipe_favorited(user_id, recipe_id_int)
    
    # Custom Recipe Management
    
    def create_custom_recipe(self, user_id: str, recipe_data: Dict[str, Any]) -> Dict[str, Any]:
        """Create a new custom recipe"""
        if not self._validate_user_access(user_id):
            raise ValueError("Invalid user access")
        
        # Validate required fields
        self._validate_recipe_data(recipe_data)
        
        # Create user recipe
        user_recipe = UserRecipe(
            user_id=user_id,
            title=recipe_data['name'],
            description=recipe_data.get('description'),
            ingredients=recipe_data['ingredients'],
            instructions=recipe_data['instructions'],
            cuisine_type=recipe_data.get('cuisine_type'),
            prep_time_minutes=recipe_data.get('prep_time_minutes'),
            cook_time_minutes=recipe_data.get('cook_time_minutes'),
            difficulty_level=recipe_data.get('difficulty_level'),
            servings=recipe_data.get('servings', 4),
            nutritional_info=recipe_data.get('nutritional_info', {}),
            image_url=recipe_data.get('image_url'),
            is_custom=True
        )
        
        # Save to database
        created_recipe = self.user_recipe_repo.create_user_recipe(user_recipe)
        
        # Assign categories if provided
        category_ids = recipe_data.get('category_ids', [])
        if category_ids:
            self.assign_categories_to_recipe(str(created_recipe.id), category_ids, user_id)
        
        return created_recipe.to_dict()
    
    def update_custom_recipe(self, user_recipe_id: str, user_id: str, 
                           recipe_data: Dict[str, Any]) -> Dict[str, Any]:
        """Update an existing custom recipe"""
        if not self._validate_user_access(user_id):
            raise ValueError("Invalid user access")
        
        # Get existing recipe
        user_recipe = self.user_recipe_repo.get_user_recipe_by_id(user_recipe_id, user_id)
        if not user_recipe:
            raise ValueError("Recipe not found")
        
        # Only allow updating custom recipes
        if not user_recipe.is_custom:
            raise ValueError("Cannot edit favorited recipes")
        
        # Validate updated data
        self._validate_recipe_data(recipe_data, partial=True)
        
        # Update recipe fields
        user_recipe.update_fields(**recipe_data)
        
        # Save changes
        updated_recipe = self.user_recipe_repo.update_user_recipe(user_recipe)
        
        # Update categories if provided
        if 'category_ids' in recipe_data:
            self.assign_categories_to_recipe(user_recipe_id, recipe_data['category_ids'], user_id)
        
        return updated_recipe.to_dict()
    
    def delete_user_recipe(self, user_recipe_id: str, user_id: str) -> bool:
        """Delete a user recipe (custom or favorited)"""
        if not self._validate_user_access(user_id):
            raise ValueError("Invalid user access")
        
        return self.user_recipe_repo.delete_user_recipe(user_recipe_id, user_id)
    
    def scale_recipe(self, user_recipe_id: str, user_id: str, scale_factor: float) -> Dict[str, Any]:
        """Scale a recipe's ingredients and servings"""
        if not self._validate_user_access(user_id):
            raise ValueError("Invalid user access")
        
        user_recipe = self.user_recipe_repo.get_user_recipe_by_id(user_recipe_id, user_id)
        if not user_recipe:
            raise ValueError("Recipe not found")
        
        return user_recipe.scale_recipe(scale_factor)
    
    # Category Management
    
    def get_user_categories(self, user_id: str, include_recipe_count: bool = True) -> List[Dict[str, Any]]:
        """Get all categories for a user"""
        if not self._validate_user_access(user_id):
            raise ValueError("Invalid user access")
        
        categories = self.user_recipe_repo.get_user_categories(user_id, include_recipe_count)
        return [category.to_dict() for category in categories]
    
    def get_category_by_id(self, category_id: str, user_id: str) -> Optional[Dict[str, Any]]:
        """Get a specific category by ID"""
        if not self._validate_user_access(user_id):
            raise ValueError("Invalid user access")
        
        category = self.user_recipe_repo.get_category_by_id(category_id, user_id)
        return category.to_dict() if category else None
    
    def create_category(self, user_id: str, name: str, description: Optional[str] = None,
                       color: Optional[str] = None) -> Dict[str, Any]:
        """Create a new recipe category"""
        if not self._validate_user_access(user_id):
            raise ValueError("Invalid user access")
        
        # Check if category name already exists
        existing = self.user_recipe_repo.get_category_by_name(user_id, name)
        if existing:
            raise ValueError(f"Category '{name}' already exists")
        
        # Create category
        category = UserRecipeCategory(
            user_id=user_id,
            name=name,
            description=description,
            color=color
        )
        
        created_category = self.user_recipe_repo.create_category(category)
        return created_category.to_dict()
    
    def update_category(self, category_id: str, user_id: str, name: Optional[str] = None,
                       description: Optional[str] = None, color: Optional[str] = None) -> Dict[str, Any]:
        """Update an existing category"""
        if not self._validate_user_access(user_id):
            raise ValueError("Invalid user access")
        
        category = self.user_recipe_repo.get_category_by_id(category_id, user_id)
        if not category:
            raise ValueError("Category not found")
        
        # Check for name conflicts if name is being changed
        if name and name != category.name:
            existing = self.user_recipe_repo.get_category_by_name(user_id, name)
            if existing:
                raise ValueError(f"Category '{name}' already exists")
        
        # Update category
        category.update_fields(name=name, description=description, color=color)
        
        updated_category = self.user_recipe_repo.update_category(category)
        return updated_category.to_dict()
    
    def delete_category(self, category_id: str, user_id: str) -> bool:
        """Delete a category"""
        if not self._validate_user_access(user_id):
            raise ValueError("Invalid user access")
        
        return self.user_recipe_repo.delete_category(category_id, user_id)
    
    def assign_categories_to_recipe(self, user_recipe_id: str, category_ids: List[str], 
                                   user_id: str) -> bool:
        """Assign categories to a recipe"""
        if not self._validate_user_access(user_id):
            raise ValueError("Invalid user access")
        
        return self.user_recipe_repo.assign_categories_to_recipe(user_recipe_id, category_ids, user_id)
    
    def get_recipes_by_category(self, category_id: str, user_id: str, 
                               page: int = 1, page_size: int = 20) -> Dict[str, Any]:
        """Get all recipes in a specific category"""
        if not self._validate_user_access(user_id):
            raise ValueError("Invalid user access")
        
        recipes, total_count = self.user_recipe_repo.get_recipes_by_category(
            category_id, user_id, page, page_size
        )
        
        total_pages = (total_count + page_size - 1) // page_size
        
        return {
            'recipes': [recipe.to_dict() for recipe in recipes],
            'pagination': {
                'current_page': page,
                'page_size': page_size,
                'total_count': total_count,
                'total_pages': total_pages,
                'has_next': page < total_pages,
                'has_prev': page > 1
            }
        }
    
    def create_default_categories(self, user_id: str) -> List[Dict[str, Any]]:
        """Create default categories for a new user"""
        if not self._validate_user_access(user_id):
            raise ValueError("Invalid user access")
        
        categories = self.category_repo.create_default_categories_for_user(user_id)
        return [category.to_dict() for category in categories]
    
    # Statistics and Analytics
    
    def get_user_recipe_stats(self, user_id: str) -> Dict[str, Any]:
        """Get statistics about user's recipe collection"""
        if not self._validate_user_access(user_id):
            raise ValueError("Invalid user access")
        
        return self.user_recipe_repo.get_user_recipe_stats(user_id)
    
    # Export and Sharing
    
    def export_recipe(self, user_recipe_id: str, user_id: str, export_format: str = 'json') -> str:
        """Export a recipe in specified format"""
        if not self._validate_user_access(user_id):
            raise ValueError("Invalid user access")
        
        user_recipe = self.user_recipe_repo.get_user_recipe_by_id(user_recipe_id, user_id)
        if not user_recipe:
            raise ValueError("Recipe not found")
        
        if export_format.lower() == 'json':
            return self._export_recipe_json(user_recipe)
        elif export_format.lower() == 'text':
            return self._export_recipe_text(user_recipe)
        else:
            raise ValueError(f"Unsupported export format: {export_format}")
    
    def export_collection(self, user_id: str, export_format: str = 'json', 
                         category_id: Optional[str] = None) -> str:
        """Export user's entire recipe collection or specific category"""
        if not self._validate_user_access(user_id):
            raise ValueError("Invalid user access")
        
        if category_id:
            recipes, _ = self.user_recipe_repo.get_recipes_by_category(
                category_id, user_id, page=1, page_size=1000
            )
        else:
            recipes, _ = self.user_recipe_repo.get_user_recipes(
                user_id, page=1, page_size=1000
            )
        
        if export_format.lower() == 'json':
            return self._export_collection_json(recipes, user_id)
        elif export_format.lower() == 'text':
            return self._export_collection_text(recipes, user_id)
        else:
            raise ValueError(f"Unsupported export format: {export_format}")
    
    def share_recipe(self, user_recipe_id: str, user_id: str) -> Dict[str, Any]:
        """Generate shareable link for a recipe"""
        if not self._validate_user_access(user_id):
            raise ValueError("Invalid user access")
        
        user_recipe = self.user_recipe_repo.get_user_recipe_by_id(user_recipe_id, user_id)
        if not user_recipe:
            raise ValueError("Recipe not found")
        
        # For custom recipes, they need to be public to share
        if user_recipe.is_custom and not user_recipe.is_public:
            raise ValueError("Custom recipes must be made public before sharing")
        
        # Generate share data (in a real app, you might create a share token/link)
        share_data = {
            'recipe_id': str(user_recipe.id),
            'recipe_name': user_recipe.name,
            'shared_by': user_id,
            'shared_at': datetime.utcnow().isoformat(),
            'share_url': f"/shared/recipe/{user_recipe.id}",
            'is_custom': user_recipe.is_custom,
            'recipe_data': user_recipe.to_dict()
        }
        
        return share_data
    
    # Helper Methods
    
    def _validate_user_access(self, user_id: str) -> bool:
        """Validate user has access to perform operations"""
        # In a real app, verify user exists and is authenticated
        # For now, just check user_id is provided
        return user_id is not None and user_id.strip() != ""
    
    def _validate_recipe_data(self, recipe_data: Dict[str, Any], partial: bool = False) -> None:
        """Validate recipe data for creation/update"""
        required_fields = ['name', 'ingredients', 'instructions']
        
        if not partial:
            for field in required_fields:
                if field not in recipe_data or not recipe_data[field]:
                    raise ValueError(f"Required field '{field}' is missing or empty")
        
        # Validate ingredients format
        if 'ingredients' in recipe_data:
            ingredients = recipe_data['ingredients']
            if not isinstance(ingredients, list) or len(ingredients) == 0:
                raise ValueError("Ingredients must be a non-empty list")
            
            for i, ingredient in enumerate(ingredients):
                if not isinstance(ingredient, dict):
                    raise ValueError(f"Ingredient {i+1} must be an object")
                if 'name' not in ingredient or not ingredient['name']:
                    raise ValueError(f"Ingredient {i+1} must have a name")
        
        # Validate time fields
        for time_field in ['prep_time_minutes', 'cook_time_minutes', 'servings']:
            if time_field in recipe_data and recipe_data[time_field] is not None:
                try:
                    value = int(recipe_data[time_field])
                    if value < 0:
                        raise ValueError(f"{time_field} must be a non-negative integer")
                except (ValueError, TypeError):
                    raise ValueError(f"{time_field} must be a valid integer")
    
    def _export_recipe_json(self, user_recipe: UserRecipe) -> str:
        """Export recipe as JSON"""
        export_data = {
            'foodi_recipe_export': {
                'version': '1.0',
                'exported_at': datetime.utcnow().isoformat(),
                'recipe': user_recipe.to_dict()
            }
        }
        
        return json.dumps(export_data, indent=2, ensure_ascii=False)
    
    def _export_recipe_text(self, user_recipe: UserRecipe) -> str:
        """Export recipe as formatted text"""
        output = StringIO()
        
        output.write(f"# {user_recipe.name}\n\n")
        
        if user_recipe.description:
            output.write(f"{user_recipe.description}\n\n")
        
        # Recipe info
        info_lines = []
        if user_recipe.cuisine_type:
            info_lines.append(f"Cuisine: {user_recipe.cuisine_type}")
        if user_recipe.meal_type:
            info_lines.append(f"Meal Type: {user_recipe.meal_type}")
        if user_recipe.difficulty_level:
            info_lines.append(f"Difficulty: {user_recipe.difficulty_level}")
        if user_recipe.servings:
            info_lines.append(f"Servings: {user_recipe.servings}")
        if user_recipe.prep_time_minutes:
            info_lines.append(f"Prep Time: {user_recipe.prep_time_minutes} minutes")
        if user_recipe.cook_time_minutes:
            info_lines.append(f"Cook Time: {user_recipe.cook_time_minutes} minutes")
        
        if info_lines:
            output.write("## Recipe Information\n")
            for line in info_lines:
                output.write(f"- {line}\n")
            output.write("\n")
        
        # Ingredients
        output.write("## Ingredients\n")
        for ingredient in user_recipe.ingredients:
            name = ingredient.get('name', '')
            quantity = ingredient.get('quantity', '')
            unit = ingredient.get('unit', '')
            
            ingredient_line = f"- {quantity} {unit} {name}".strip()
            output.write(f"{ingredient_line}\n")
        output.write("\n")
        
        # Instructions
        output.write("## Instructions\n")
        instructions = user_recipe.get_instructions_list()
        for i, instruction_obj in enumerate(instructions, 1):
            instruction_text = instruction_obj.get('instruction', instruction_obj)
            if isinstance(instruction_text, dict):
                instruction_text = instruction_text.get('instruction', '')
            output.write(f"{i}. {instruction_text}\n")
        output.write("\n")
        
        # Equipment
        if user_recipe.equipment_needed:
            output.write("## Equipment Needed\n")
            for equipment in user_recipe.equipment_needed:
                output.write(f"- {equipment}\n")
            output.write("\n")
        
        # Tips
        if user_recipe.cooking_tips:
            output.write("## Cooking Tips\n")
            for tip_obj in user_recipe.cooking_tips:
                tip_text = tip_obj.get('tip', tip_obj) if isinstance(tip_obj, dict) else tip_obj
                output.write(f"- {tip_text}\n")
            output.write("\n")
        
        # Nutritional info
        if user_recipe.nutritional_info:
            output.write("## Nutritional Information\n")
            for key, value in user_recipe.nutritional_info.items():
                output.write(f"- {key.title()}: {value}\n")
            output.write("\n")
        
        output.write(f"\nExported from Foodi on {datetime.utcnow().strftime('%Y-%m-%d at %H:%M UTC')}\n")
        
        return output.getvalue()
    
    def _export_collection_json(self, recipes: List[UserRecipe], user_id: str) -> str:
        """Export recipe collection as JSON"""
        export_data = {
            'foodi_collection_export': {
                'version': '1.0',
                'exported_at': datetime.utcnow().isoformat(),
                'user_id': user_id,
                'recipe_count': len(recipes),
                'recipes': [recipe.to_dict() for recipe in recipes]
            }
        }
        
        return json.dumps(export_data, indent=2, ensure_ascii=False)
    
    def _export_collection_text(self, recipes: List[UserRecipe], user_id: str) -> str:
        """Export recipe collection as formatted text"""
        output = StringIO()
        
        output.write("# My Recipe Collection\n\n")
        output.write(f"Total Recipes: {len(recipes)}\n")
        output.write(f"Exported: {datetime.utcnow().strftime('%Y-%m-%d at %H:%M UTC')}\n\n")
        
        output.write("=" * 50 + "\n\n")
        
        for i, recipe in enumerate(recipes, 1):
            output.write(f"## Recipe {i}: {recipe.name}\n\n")
            recipe_text = self._export_recipe_text(recipe)
            # Remove the title line since we already added it
            recipe_lines = recipe_text.split('\n')[2:]  # Skip first two lines
            output.write('\n'.join(recipe_lines))
            output.write("\n" + "=" * 50 + "\n\n")
        
        return output.getvalue() 