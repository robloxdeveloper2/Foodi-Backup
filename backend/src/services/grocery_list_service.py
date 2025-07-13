"""
Grocery List Service
Handles grocery list generation from meal plans and list management
"""

import logging
import re
from typing import List, Dict, Any, Optional, Tuple
from datetime import datetime

from core.models.grocery_list import GroceryList, GroceryListItem
from core.models.meal_plan import MealPlan
from core.models.recipe import Recipe
from data_access.repositories.grocery_list_repository import GroceryListRepository
from data_access.repositories.meal_plan_repository import MealPlanRepository
from data_access.repositories.recipe_repository import RecipeRepository

logger = logging.getLogger(__name__)

class GroceryListService:
    """Service for grocery list generation and management"""
    
    # Grocery category mappings for organization
    GROCERY_CATEGORIES = {
        'produce': ['vegetables', 'fruits', 'herbs', 'lettuce', 'spinach', 'tomatoes', 'onions', 'garlic', 
                   'carrots', 'bell peppers', 'broccoli', 'avocado', 'cucumber', 'mushrooms', 'cilantro',
                   'parsley', 'basil', 'mint', 'apples', 'bananas', 'berries', 'lemons', 'limes'],
        'meat_seafood': ['chicken', 'beef', 'pork', 'fish', 'seafood', 'turkey', 'lamb', 'salmon', 
                        'tuna', 'shrimp', 'ground beef', 'chicken breast', 'bacon', 'sausage'],
        'dairy': ['milk', 'cheese', 'yogurt', 'butter', 'cream', 'eggs', 'cottage cheese', 'sour cream',
                 'mozzarella', 'cheddar', 'parmesan', 'greek yogurt', 'heavy cream'],
        'pantry': ['flour', 'sugar', 'oil', 'vinegar', 'spices', 'salt', 'pepper', 'olive oil', 
                  'vegetable oil', 'rice', 'pasta', 'quinoa', 'oats', 'baking powder', 'vanilla',
                  'cinnamon', 'paprika', 'cumin', 'garlic powder', 'onion powder', 'soy sauce',
                  'honey', 'maple syrup', 'coconut oil', 'sesame oil'],
        'frozen': ['frozen vegetables', 'frozen fruits', 'ice cream', 'frozen berries', 'frozen peas',
                  'frozen corn', 'frozen spinach'],
        'bakery': ['bread', 'rolls', 'pastry', 'bagels', 'tortillas', 'pita bread', 'naan'],
        'beverages': ['water', 'juice', 'coffee', 'tea', 'soda', 'wine', 'beer', 'coconut water'],
        'canned_goods': ['canned tomatoes', 'tomato paste', 'coconut milk', 'canned beans', 
                        'canned corn', 'chicken broth', 'vegetable broth', 'tomato sauce'],
        'condiments': ['ketchup', 'mustard', 'mayonnaise', 'hot sauce', 'bbq sauce', 'ranch',
                      'salsa', 'hummus', 'pesto'],
        'snacks': ['nuts', 'crackers', 'chips', 'pretzels', 'granola bars', 'trail mix'],
        'other': []  # fallback category
    }
    
    # Base cost estimates (in cents) for common ingredients
    BASE_COSTS = {
        'chicken breast': 699,  # per lb
        'ground beef': 499,     # per lb  
        'salmon': 899,          # per lb
        'milk': 349,            # per gallon
        'eggs': 299,            # per dozen
        'cheese': 399,          # per lb
        'bread': 249,           # per loaf
        'rice': 199,            # per lb
        'pasta': 99,            # per lb
        'olive oil': 699,       # per bottle
        'onions': 149,          # per lb
        'tomatoes': 299,        # per lb
        'lettuce': 199,         # per head
        'avocado': 150,         # each
        'bananas': 68,          # per lb
        'apples': 199,          # per lb
        'carrots': 99,          # per lb
        'bell peppers': 299,    # per lb
        'broccoli': 249,        # per lb
        'spinach': 199,         # per bag
        'garlic': 99,           # per head
        'ginger': 399,          # per lb
        'butter': 399,          # per lb
        'flour': 199,           # per lb
        'sugar': 99,            # per lb
        'salt': 99,             # per container
        'pepper': 299,          # per container
    }
    
    def __init__(self, grocery_list_repository: GroceryListRepository,
                 meal_plan_repository: MealPlanRepository,
                 recipe_repository: RecipeRepository):
        """Initialize the grocery list service"""
        self.grocery_list_repo = grocery_list_repository
        self.meal_plan_repo = meal_plan_repository
        self.recipe_repo = recipe_repository
    
    def generate_from_meal_plan(self, meal_plan_id: str, user_id: str, 
                               list_name: Optional[str] = None) -> GroceryList:
        """
        Generate a grocery list from a meal plan
        
        Args:
            meal_plan_id: ID of the meal plan to generate from
            user_id: ID of the user requesting the list
            list_name: Optional name for the grocery list
            
        Returns:
            Generated GroceryList object
            
        Raises:
            ValueError: If meal plan not found or invalid
        """
        logger.info(f"Generating grocery list from meal plan {meal_plan_id} for user {user_id}")
        
        # 1. Get the meal plan
        meal_plan = self.meal_plan_repo.get_by_id(meal_plan_id)
        if not meal_plan:
            raise ValueError(f"Meal plan {meal_plan_id} not found")
        
        if str(meal_plan.user_id) != user_id:
            raise ValueError(f"Meal plan {meal_plan_id} does not belong to user {user_id}")
        
        # 2. Extract all recipes from meal plan
        recipes = self._get_meal_plan_recipes(meal_plan)
        
        # 3. Aggregate ingredients from all recipes
        ingredient_map = self._aggregate_ingredients(recipes)
        
        # 4. Organize by grocery categories
        categorized_items = self._categorize_ingredients(ingredient_map)
        
        # 5. Calculate total cost
        total_cost = self._calculate_total_cost(categorized_items)
        
        # 6. Create grocery list record
        if not list_name:
            list_name = f"Grocery List - {meal_plan.plan_date.strftime('%m/%d/%Y')}"
        
        grocery_list = GroceryList(
            user_id=user_id,
            name=list_name,
            meal_plan_id=meal_plan_id,
            total_estimated_cost=total_cost
        )
        
        # Save grocery list first to get ID
        saved_list = self.grocery_list_repo.create(grocery_list)
        
        # 7. Create grocery list items
        for item_data in categorized_items:
            item = GroceryListItem(
                grocery_list_id=str(saved_list.id),
                ingredient_name=item_data['name'],
                quantity=item_data['quantity'],
                unit=item_data['unit'],
                category=item_data['category'],
                estimated_cost=item_data['cost'],
                is_custom=False
            )
            self.grocery_list_repo.add_item(item)
        
        logger.info(f"Generated grocery list {saved_list.id} with {len(categorized_items)} items")
        
        return saved_list
    
    def get_grocery_list(self, list_id: str, user_id: str) -> Optional[Dict[str, Any]]:
        """
        Get a grocery list with all items
        
        Args:
            list_id: ID of the grocery list
            user_id: ID of the user requesting the list
            
        Returns:
            Dictionary with grocery list and items, or None if not found
        """
        grocery_list = self.grocery_list_repo.get_by_id(list_id)
        if not grocery_list or str(grocery_list.user_id) != user_id:
            return None
        
        items = self.grocery_list_repo.get_items_by_list_id(list_id)
        
        # Group items by category
        items_by_category = {}
        for item in items:
            category = item.category or 'other'
            if category not in items_by_category:
                items_by_category[category] = []
            items_by_category[category].append(item.to_dict())
        
        return {
            'grocery_list': grocery_list.to_dict(),
            'items_by_category': items_by_category,
            'total_items': len(items)
        }
    
    def update_grocery_list(self, list_id: str, user_id: str, 
                           updates: Dict[str, Any]) -> Optional[GroceryList]:
        """
        Update a grocery list
        
        Args:
            list_id: ID of the grocery list
            user_id: ID of the user
            updates: Dictionary of fields to update
            
        Returns:
            Updated GroceryList object or None if not found
        """
        grocery_list = self.grocery_list_repo.get_by_id(list_id)
        if not grocery_list or str(grocery_list.user_id) != user_id:
            return None
        
        return self.grocery_list_repo.update(list_id, updates)
    
    def add_custom_item(self, list_id: str, user_id: str, item_data: Dict[str, Any]) -> Optional[GroceryListItem]:
        """
        Add a custom item to a grocery list
        
        Args:
            list_id: ID of the grocery list
            user_id: ID of the user
            item_data: Dictionary with item details
            
        Returns:
            Created GroceryListItem or None if list not found
        """
        grocery_list = self.grocery_list_repo.get_by_id(list_id)
        if not grocery_list or str(grocery_list.user_id) != user_id:
            return None
        
        # Categorize the custom item
        category = self._categorize_ingredient(item_data.get('ingredient_name', ''))
        estimated_cost = self._estimate_ingredient_cost(
            item_data.get('ingredient_name', ''),
            item_data.get('quantity', '1'),
            item_data.get('unit', '')
        )
        
        item = GroceryListItem(
            grocery_list_id=list_id,
            ingredient_name=item_data.get('ingredient_name', ''),
            quantity=item_data.get('quantity', '1'),
            unit=item_data.get('unit'),
            category=category,
            estimated_cost=estimated_cost,
            is_custom=True
        )
        
        created_item = self.grocery_list_repo.add_item(item)
        
        # Update total cost of grocery list
        self._recalculate_list_total(list_id)
        
        return created_item
    
    def toggle_item_checked(self, item_id: str, user_id: str) -> Optional[GroceryListItem]:
        """Toggle the checked status of a grocery list item"""
        item = self.grocery_list_repo.get_item_by_id(item_id)
        if not item:
            return None
        
        # Verify user owns the grocery list
        grocery_list = self.grocery_list_repo.get_by_id(str(item.grocery_list_id))
        if not grocery_list or str(grocery_list.user_id) != user_id:
            return None
        
        return self.grocery_list_repo.toggle_item_checked(item_id)
    
    def update_item_quantity(self, item_id: str, user_id: str, 
                           new_quantity: str, new_unit: Optional[str] = None) -> Optional[GroceryListItem]:
        """Update the quantity and unit of a grocery list item"""
        item = self.grocery_list_repo.get_item_by_id(item_id)
        if not item:
            return None
        
        # Verify user owns the grocery list
        grocery_list = self.grocery_list_repo.get_by_id(str(item.grocery_list_id))
        if not grocery_list or str(grocery_list.user_id) != user_id:
            return None
        
        # Recalculate cost based on new quantity
        new_cost = self._estimate_ingredient_cost(item.ingredient_name, new_quantity, new_unit or item.unit)
        
        updates = {
            'quantity': new_quantity,
            'estimated_cost': new_cost
        }
        if new_unit is not None:
            updates['unit'] = new_unit
        
        updated_item = self.grocery_list_repo.update_item(item_id, updates)
        
        # Update total cost of grocery list
        self._recalculate_list_total(str(item.grocery_list_id))
        
        return updated_item
    
    def delete_item(self, item_id: str, user_id: str) -> bool:
        """Delete a grocery list item"""
        item = self.grocery_list_repo.get_item_by_id(item_id)
        if not item:
            return False
        
        # Verify user owns the grocery list
        grocery_list = self.grocery_list_repo.get_by_id(str(item.grocery_list_id))
        if not grocery_list or str(grocery_list.user_id) != user_id:
            return False
        
        success = self.grocery_list_repo.delete_item(item_id)
        
        if success:
            # Update total cost of grocery list
            self._recalculate_list_total(str(item.grocery_list_id))
        
        return success
    
    def get_user_grocery_lists(self, user_id: str) -> List[Dict[str, Any]]:
        """Get all grocery lists for a user"""
        lists = self.grocery_list_repo.get_by_user_id(user_id)
        result = []
        
        for grocery_list in lists:
            items = self.grocery_list_repo.get_items_by_list_id(str(grocery_list.id))
            list_data = grocery_list.to_dict()
            list_data['item_count'] = len(items)
            list_data['checked_count'] = len([item for item in items if item.is_checked])
            result.append(list_data)
        
        return result
    
    def _get_meal_plan_recipes(self, meal_plan: MealPlan) -> List[Recipe]:
        """Extract all recipes from a meal plan"""
        recipe_ids = []
        for meal in meal_plan.meals:
            recipe_id = meal.get('recipe_id')
            if recipe_id:
                recipe_ids.append(recipe_id)
        
        # Remove duplicates while preserving order
        unique_recipe_ids = list(dict.fromkeys(recipe_ids))
        
        recipes = []
        for recipe_id in unique_recipe_ids:
            recipe = self.recipe_repo.get_by_id(recipe_id)
            if recipe:
                recipes.append(recipe)
        
        return recipes
    
    def _aggregate_ingredients(self, recipes: List[Recipe]) -> Dict[str, Dict[str, Any]]:
        """
        Aggregate ingredients from multiple recipes, consolidating duplicates
        
        Returns:
            Dictionary mapping normalized ingredient names to consolidated ingredient data
        """
        ingredient_map = {}
        
        for recipe in recipes:
            for ingredient in recipe.ingredients:
                name = ingredient.get('name', '')
                quantity = ingredient.get('quantity', '1')
                unit = ingredient.get('unit', '')
                
                normalized_name = self._normalize_ingredient_name(name)
                
                if normalized_name in ingredient_map:
                    # Consolidate quantities
                    existing = ingredient_map[normalized_name]
                    consolidated = self._combine_quantities(existing, ingredient)
                    ingredient_map[normalized_name] = consolidated
                else:
                    ingredient_map[normalized_name] = {
                        'name': name,
                        'quantity': quantity,
                        'unit': unit,
                        'original_name': name
                    }
        
        return ingredient_map
    
    def _normalize_ingredient_name(self, name: str) -> str:
        """
        Standardize ingredient names for consolidation
        e.g., "chicken breast" and "chicken breasts" -> "chicken breast"
        """
        if not name:
            return ''
        
        normalized = name.lower().strip()
        
        # Remove plural 's' for common ingredients
        if normalized.endswith('s') and not normalized.endswith('ss'):
            # Don't remove 's' from words that end in 'ss'
            normalized = normalized.rstrip('s')
        
        # Remove common modifiers that don't affect consolidation
        normalized = re.sub(r'\b(fresh|dried|frozen|organic|raw)\b', '', normalized)
        normalized = re.sub(r'\s+', ' ', normalized).strip()
        
        return normalized
    
    def _combine_quantities(self, existing: Dict[str, Any], new_ingredient: Dict[str, Any]) -> Dict[str, Any]:
        """
        Combine quantities from two ingredients
        This is a simplified implementation - a full version would handle unit conversions
        """
        existing_qty = existing.get('quantity', '1')
        new_qty = new_ingredient.get('quantity', '1')
        existing_unit = existing.get('unit', '')
        new_unit = new_ingredient.get('unit', '')
        
        # If units match or are both empty, try to add quantities
        if existing_unit == new_unit:
            try:
                # Extract numeric values
                existing_num = float(re.findall(r'[\d.]+', str(existing_qty))[0]) if re.findall(r'[\d.]+', str(existing_qty)) else 1.0
                new_num = float(re.findall(r'[\d.]+', str(new_qty))[0]) if re.findall(r'[\d.]+', str(new_qty)) else 1.0
                
                combined_num = existing_num + new_num
                combined_qty = str(combined_num) if combined_num.is_integer() else f"{combined_num:.1f}"
                
                return {
                    'name': existing['name'],
                    'quantity': combined_qty,
                    'unit': existing_unit,
                    'original_name': existing['original_name']
                }
            except (ValueError, IndexError):
                # If we can't parse numbers, just concatenate
                pass
        
        # If units don't match or we can't parse, combine descriptively
        if existing_unit != new_unit:
            combined_qty = f"{existing_qty} {existing_unit}, {new_qty} {new_unit}".strip(', ')
        else:
            combined_qty = f"{existing_qty}, {new_qty}"
        
        return {
            'name': existing['name'],
            'quantity': combined_qty,
            'unit': '',  # Clear unit since we're combining different units
            'original_name': existing['original_name']
        }
    
    def _categorize_ingredients(self, ingredient_map: Dict[str, Dict[str, Any]]) -> List[Dict[str, Any]]:
        """Organize ingredients by grocery store categories"""
        categorized_items = []
        
        for normalized_name, ingredient_data in ingredient_map.items():
            category = self._categorize_ingredient(ingredient_data['name'])
            estimated_cost = self._estimate_ingredient_cost(
                ingredient_data['name'],
                ingredient_data['quantity'],
                ingredient_data['unit']
            )
            
            categorized_items.append({
                'name': ingredient_data['name'],
                'quantity': ingredient_data['quantity'],
                'unit': ingredient_data['unit'],
                'category': category,
                'cost': estimated_cost
            })
        
        # Sort by category, then by name
        categorized_items.sort(key=lambda x: (x['category'], x['name']))
        
        return categorized_items
    
    def _categorize_ingredient(self, ingredient_name: str) -> str:
        """Categorize an ingredient into grocery store sections"""
        name_lower = ingredient_name.lower()
        
        for category, keywords in self.GROCERY_CATEGORIES.items():
            for keyword in keywords:
                if keyword in name_lower:
                    return category
        
        return 'other'
    
    def _estimate_ingredient_cost(self, ingredient_name: str, quantity: str, unit: str) -> int:
        """
        Estimate the cost of an ingredient in cents
        This is a simplified implementation using base costs
        """
        normalized_name = self._normalize_ingredient_name(ingredient_name)
        base_cost = self.BASE_COSTS.get(normalized_name, 200)  # Default $2.00
        
        try:
            # Extract numeric quantity
            qty_match = re.findall(r'[\d.]+', str(quantity))
            if qty_match:
                qty_num = float(qty_match[0])
            else:
                qty_num = 1.0
            
            # Simple unit conversion multipliers (simplified)
            unit_multipliers = {
                'cup': 0.25,
                'cups': 0.25,
                'tbsp': 0.0625,
                'tablespoon': 0.0625,
                'tablespoons': 0.0625,
                'tsp': 0.02,
                'teaspoon': 0.02,
                'teaspoons': 0.02,
                'oz': 0.0625,
                'ounce': 0.0625,
                'ounces': 0.0625,
                'lb': 1.0,
                'lbs': 1.0,
                'pound': 1.0,
                'pounds': 1.0,
                'each': 1.0,
                'piece': 1.0,
                'pieces': 1.0,
                'clove': 0.1,
                'cloves': 0.1,
                'head': 1.0,
                'heads': 1.0,
                '': 1.0  # Default multiplier
            }
            
            unit_lower = unit.lower().strip() if unit else ''
            multiplier = unit_multipliers.get(unit_lower, 1.0)
            
            estimated_cost = int(base_cost * qty_num * multiplier)
            
            # Minimum cost of 10 cents
            return max(estimated_cost, 10)
            
        except (ValueError, TypeError):
            return base_cost
    
    def _calculate_total_cost(self, categorized_items: List[Dict[str, Any]]) -> int:
        """Calculate total estimated cost for all items"""
        return sum(item.get('cost', 0) for item in categorized_items)
    
    def _recalculate_list_total(self, list_id: str) -> None:
        """Recalculate and update the total cost of a grocery list"""
        items = self.grocery_list_repo.get_items_by_list_id(list_id)
        total_cost = sum(item.estimated_cost or 0 for item in items)
        
        self.grocery_list_repo.update(list_id, {'total_estimated_cost': total_cost}) 