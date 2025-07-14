#!/usr/bin/env python3
"""
Script to seed the database with sample recipes for testing
"""

import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from main import create_app
from data_access.database import db
from data_access.recipe_repository import RecipeRepository
from core.models.recipe import Recipe

def create_sample_recipes():
    """Create sample recipes for testing"""
    
    sample_recipes = [
        {
            "name": "Classic Chicken Stir Fry",
            "description": "Quick and healthy chicken stir fry with fresh vegetables",
            "ingredients": [
                {"name": "chicken breast", "quantity": "1 lb", "unit": "lb"},
                {"name": "broccoli", "quantity": "2", "unit": "cups"},
                {"name": "bell peppers", "quantity": "2", "unit": "pieces"},
                {"name": "soy sauce", "quantity": "3", "unit": "tbsp"},
                {"name": "garlic", "quantity": "3", "unit": "cloves"},
                {"name": "ginger", "quantity": "1", "unit": "tbsp"},
                {"name": "vegetable oil", "quantity": "2", "unit": "tbsp"}
            ],
            "instructions": "1. Cut chicken into strips. 2. Heat oil in wok. 3. Stir fry chicken until cooked. 4. Add vegetables and stir fry. 5. Add sauce and serve over rice.",
            "cuisine_type": "Asian",
            "meal_type": "dinner",
            "prep_time_minutes": 15,
            "cook_time_minutes": 15,
            "nutritional_info": {"calories": 350, "protein": 30, "carbs": 25, "fat": 12},
            "estimated_cost_usd": 800,  # $8.00 in cents
            "difficulty_level": "beginner",
            "servings": 4,
            "image_url": "https://example.com/chicken-stir-fry.jpg"
        },
        {
            "name": "Vegetarian Pasta Primavera",
            "description": "Light and fresh pasta with seasonal vegetables",
            "ingredients": [
                {"name": "pasta", "quantity": "12", "unit": "oz"},
                {"name": "zucchini", "quantity": "2", "unit": "pieces"},
                {"name": "cherry tomatoes", "quantity": "1", "unit": "cup"},
                {"name": "bell peppers", "quantity": "1", "unit": "piece"},
                {"name": "olive oil", "quantity": "3", "unit": "tbsp"},
                {"name": "garlic", "quantity": "4", "unit": "cloves"},
                {"name": "parmesan cheese", "quantity": "1/2", "unit": "cup"}
            ],
            "instructions": "1. Cook pasta according to package directions. 2. Sauté vegetables in olive oil. 3. Combine pasta with vegetables. 4. Add cheese and serve.",
            "cuisine_type": "Italian",
            "meal_type": "dinner",
            "prep_time_minutes": 10,
            "cook_time_minutes": 20,
            "nutritional_info": {"calories": 420, "protein": 15, "carbs": 65, "fat": 14},
            "estimated_cost_usd": 600,  # $6.00 in cents
            "difficulty_level": "beginner",
            "servings": 4,
            "image_url": "https://example.com/pasta-primavera.jpg"
        },
        {
            "name": "Quinoa Buddha Bowl",
            "description": "Nutritious vegan bowl with quinoa, vegetables, and tahini dressing",
            "ingredients": [
                {"name": "quinoa", "quantity": "1", "unit": "cup"},
                {"name": "chickpeas", "quantity": "1", "unit": "can"},
                {"name": "sweet potato", "quantity": "2", "unit": "pieces"},
                {"name": "spinach", "quantity": "2", "unit": "cups"},
                {"name": "avocado", "quantity": "1", "unit": "piece"},
                {"name": "tahini", "quantity": "3", "unit": "tbsp"},
                {"name": "lemon juice", "quantity": "2", "unit": "tbsp"}
            ],
            "instructions": "1. Cook quinoa. 2. Roast sweet potatoes. 3. Prepare tahini dressing. 4. Assemble bowl with all ingredients.",
            "cuisine_type": "Mediterranean",
            "meal_type": "lunch",
            "prep_time_minutes": 20,
            "cook_time_minutes": 25,
            "nutritional_info": {"calories": 480, "protein": 18, "carbs": 55, "fat": 22},
            "estimated_cost_usd": 750,  # $7.50 in cents
            "difficulty_level": "intermediate",
            "servings": 2,
            "image_url": "https://example.com/quinoa-bowl.jpg"
        },
        {
            "name": "Pancakes with Berries",
            "description": "Fluffy pancakes topped with fresh berries and maple syrup",
            "ingredients": [
                {"name": "flour", "quantity": "2", "unit": "cups"},
                {"name": "milk", "quantity": "1.5", "unit": "cups"},
                {"name": "eggs", "quantity": "2", "unit": "pieces"},
                {"name": "sugar", "quantity": "2", "unit": "tbsp"},
                {"name": "baking powder", "quantity": "2", "unit": "tsp"},
                {"name": "butter", "quantity": "3", "unit": "tbsp"},
                {"name": "mixed berries", "quantity": "1", "unit": "cup"}
            ],
            "instructions": "1. Mix dry ingredients. 2. Combine wet ingredients. 3. Mix wet and dry ingredients. 4. Cook pancakes on griddle. 5. Serve with berries.",
            "cuisine_type": "American",
            "meal_type": "breakfast",
            "prep_time_minutes": 10,
            "cook_time_minutes": 15,
            "nutritional_info": {"calories": 320, "protein": 10, "carbs": 45, "fat": 12},
            "estimated_cost_usd": 400,  # $4.00 in cents
            "difficulty_level": "beginner",
            "servings": 4,
            "image_url": "https://example.com/pancakes.jpg"
        },
        {
            "name": "Beef Tacos",
            "description": "Authentic Mexican tacos with seasoned ground beef",
            "ingredients": [
                {"name": "ground beef", "quantity": "1", "unit": "lb"},
                {"name": "taco shells", "quantity": "8", "unit": "pieces"},
                {"name": "lettuce", "quantity": "2", "unit": "cups"},
                {"name": "tomatoes", "quantity": "2", "unit": "pieces"},
                {"name": "cheese", "quantity": "1", "unit": "cup"},
                {"name": "onion", "quantity": "1", "unit": "piece"},
                {"name": "taco seasoning", "quantity": "1", "unit": "packet"}
            ],
            "instructions": "1. Brown ground beef. 2. Add taco seasoning. 3. Warm taco shells. 4. Assemble tacos with toppings.",
            "cuisine_type": "Mexican",
            "meal_type": "dinner",
            "prep_time_minutes": 10,
            "cook_time_minutes": 15,
            "nutritional_info": {"calories": 380, "protein": 25, "carbs": 20, "fat": 22},
            "estimated_cost_usd": 900,  # $9.00 in cents
            "difficulty_level": "beginner",
            "servings": 4,
            "image_url": "https://example.com/beef-tacos.jpg"
        },
        {
            "name": "Greek Salad",
            "description": "Fresh Mediterranean salad with feta cheese and olives",
            "ingredients": [
                {"name": "cucumber", "quantity": "2", "unit": "pieces"},
                {"name": "tomatoes", "quantity": "3", "unit": "pieces"},
                {"name": "red onion", "quantity": "1/2", "unit": "piece"},
                {"name": "feta cheese", "quantity": "1", "unit": "cup"},
                {"name": "olives", "quantity": "1/2", "unit": "cup"},
                {"name": "olive oil", "quantity": "3", "unit": "tbsp"},
                {"name": "lemon juice", "quantity": "2", "unit": "tbsp"}
            ],
            "instructions": "1. Chop all vegetables. 2. Combine in large bowl. 3. Add feta and olives. 4. Dress with oil and lemon.",
            "cuisine_type": "Greek",
            "meal_type": "lunch",
            "prep_time_minutes": 15,
            "cook_time_minutes": 0,
            "nutritional_info": {"calories": 280, "protein": 12, "carbs": 15, "fat": 20},
            "estimated_cost_usd": 550,  # $5.50 in cents
            "difficulty_level": "beginner",
            "servings": 2,
            "image_url": "https://example.com/greek-salad.jpg"
        }
    ]
    
    repo = RecipeRepository()
    created_recipes = []
    
    for recipe_data in sample_recipes:
        try:
            # Check if recipe already exists (simplified check)
            # Just try to create, handle duplicates in exception
            recipe = repo.create_recipe(recipe_data)
            created_recipes.append(recipe)
            print(f"Created recipe: {recipe.name}")
        except Exception as e:
            print(f"Error creating recipe {recipe_data['name']}: {str(e)}")
    
    print(f"\nTotal recipes created: {len(created_recipes)}")
    return created_recipes

if __name__ == "__main__":
    # Create Flask app and run within application context
    app = create_app()
    with app.app_context():
        create_sample_recipes() 