"""
Data Seeding Script
Populates the database with sample recipes for testing meal planning functionality
"""

import logging
from typing import List, Dict, Any
from data_access.database import db
from data_access.recipe_repository import RecipeRepository

logger = logging.getLogger(__name__)

def get_sample_recipes() -> List[Dict[str, Any]]:
    """Get sample recipe data for seeding"""
    return [
        # Breakfast Recipes
        {
            "name": "Classic Oatmeal with Berries",
            "description": "Healthy oatmeal topped with fresh berries and honey",
            "ingredients": [
                {"name": "rolled oats", "quantity": "1/2", "unit": "cup"},
                {"name": "milk", "quantity": "1", "unit": "cup"},
                {"name": "mixed berries", "quantity": "1/4", "unit": "cup"},
                {"name": "honey", "quantity": "1", "unit": "tbsp"}
            ],
            "instructions": "1. Cook oats with milk for 5 minutes\n2. Top with berries and honey\n3. Serve warm",
            "cuisine_type": "American",
            "meal_type": "breakfast",
            "prep_time_minutes": 5,
            "cook_time_minutes": 5,
            "nutritional_info": {
                "calories": 280,
                "protein": 10,
                "carbs": 45,
                "fat": 6
            },
            "estimated_cost_usd": 250,  # $2.50
            "difficulty_level": "easy",
            "servings": 1
        },
        {
            "name": "Veggie Scrambled Eggs",
            "description": "Fluffy scrambled eggs with colorful vegetables",
            "ingredients": [
                {"name": "eggs", "quantity": "2", "unit": "large"},
                {"name": "bell pepper", "quantity": "1/4", "unit": "cup diced"},
                {"name": "onion", "quantity": "2", "unit": "tbsp diced"},
                {"name": "spinach", "quantity": "1", "unit": "cup"},
                {"name": "olive oil", "quantity": "1", "unit": "tsp"}
            ],
            "instructions": "1. Heat oil in pan\n2. Sauté vegetables\n3. Add beaten eggs and scramble\n4. Serve hot",
            "cuisine_type": "American",
            "meal_type": "breakfast",
            "prep_time_minutes": 10,
            "cook_time_minutes": 8,
            "nutritional_info": {
                "calories": 220,
                "protein": 15,
                "carbs": 8,
                "fat": 14
            },
            "estimated_cost_usd": 200,  # $2.00
            "difficulty_level": "easy",
            "servings": 1
        },
        {
            "name": "Avocado Toast",
            "description": "Whole grain toast topped with mashed avocado and seasonings",
            "ingredients": [
                {"name": "whole grain bread", "quantity": "2", "unit": "slices"},
                {"name": "avocado", "quantity": "1", "unit": "medium"},
                {"name": "lemon juice", "quantity": "1", "unit": "tsp"},
                {"name": "salt", "quantity": "1/4", "unit": "tsp"},
                {"name": "pepper", "quantity": "1/8", "unit": "tsp"}
            ],
            "instructions": "1. Toast bread\n2. Mash avocado with lemon juice\n3. Spread on toast\n4. Season with salt and pepper",
            "cuisine_type": "Modern",
            "meal_type": "breakfast",
            "prep_time_minutes": 5,
            "cook_time_minutes": 2,
            "nutritional_info": {
                "calories": 320,
                "protein": 8,
                "carbs": 35,
                "fat": 18
            },
            "estimated_cost_usd": 350,  # $3.50
            "difficulty_level": "easy",
            "servings": 1
        },
        
        # Lunch Recipes
        {
            "name": "Grilled Chicken Salad",
            "description": "Fresh mixed greens with grilled chicken breast and vegetables",
            "ingredients": [
                {"name": "chicken breast", "quantity": "4", "unit": "oz"},
                {"name": "mixed greens", "quantity": "2", "unit": "cups"},
                {"name": "cherry tomatoes", "quantity": "1/2", "unit": "cup"},
                {"name": "cucumber", "quantity": "1/4", "unit": "cup sliced"},
                {"name": "olive oil", "quantity": "1", "unit": "tbsp"},
                {"name": "balsamic vinegar", "quantity": "1", "unit": "tbsp"}
            ],
            "instructions": "1. Grill chicken until cooked through\n2. Slice chicken\n3. Combine greens and vegetables\n4. Top with chicken and dressing",
            "cuisine_type": "Mediterranean",
            "meal_type": "lunch",
            "prep_time_minutes": 10,
            "cook_time_minutes": 12,
            "nutritional_info": {
                "calories": 350,
                "protein": 28,
                "carbs": 12,
                "fat": 20
            },
            "estimated_cost_usd": 450,  # $4.50
            "difficulty_level": "medium",
            "servings": 1
        },
        {
            "name": "Quinoa Buddha Bowl",
            "description": "Nutritious bowl with quinoa, roasted vegetables, and tahini dressing",
            "ingredients": [
                {"name": "quinoa", "quantity": "1/2", "unit": "cup"},
                {"name": "sweet potato", "quantity": "1/2", "unit": "cup cubed"},
                {"name": "broccoli", "quantity": "1/2", "unit": "cup"},
                {"name": "chickpeas", "quantity": "1/4", "unit": "cup"},
                {"name": "tahini", "quantity": "2", "unit": "tbsp"},
                {"name": "lemon juice", "quantity": "1", "unit": "tbsp"}
            ],
            "instructions": "1. Cook quinoa\n2. Roast vegetables\n3. Combine in bowl\n4. Drizzle with tahini dressing",
            "cuisine_type": "Middle Eastern",
            "meal_type": "lunch",
            "prep_time_minutes": 15,
            "cook_time_minutes": 25,
            "nutritional_info": {
                "calories": 420,
                "protein": 16,
                "carbs": 55,
                "fat": 15
            },
            "estimated_cost_usd": 400,  # $4.00
            "difficulty_level": "medium",
            "servings": 1
        },
        {
            "name": "Turkey and Hummus Wrap",
            "description": "Whole wheat wrap filled with turkey, hummus, and fresh vegetables",
            "ingredients": [
                {"name": "whole wheat tortilla", "quantity": "1", "unit": "large"},
                {"name": "turkey slices", "quantity": "3", "unit": "oz"},
                {"name": "hummus", "quantity": "2", "unit": "tbsp"},
                {"name": "lettuce", "quantity": "1", "unit": "cup shredded"},
                {"name": "tomato", "quantity": "1/4", "unit": "cup sliced"},
                {"name": "cucumber", "quantity": "1/4", "unit": "cup sliced"}
            ],
            "instructions": "1. Spread hummus on tortilla\n2. Add turkey and vegetables\n3. Roll tightly\n4. Cut in half and serve",
            "cuisine_type": "Mediterranean",
            "meal_type": "lunch",
            "prep_time_minutes": 8,
            "cook_time_minutes": 0,
            "nutritional_info": {
                "calories": 380,
                "protein": 22,
                "carbs": 45,
                "fat": 12
            },
            "estimated_cost_usd": 350,  # $3.50
            "difficulty_level": "easy",
            "servings": 1
        },
        
        # Dinner Recipes
        {
            "name": "Baked Salmon with Vegetables",
            "description": "Herb-crusted salmon with roasted seasonal vegetables",
            "ingredients": [
                {"name": "salmon fillet", "quantity": "6", "unit": "oz"},
                {"name": "asparagus", "quantity": "1", "unit": "cup"},
                {"name": "bell peppers", "quantity": "1/2", "unit": "cup sliced"},
                {"name": "olive oil", "quantity": "2", "unit": "tbsp"},
                {"name": "herbs", "quantity": "1", "unit": "tsp dried"},
                {"name": "lemon", "quantity": "1/2", "unit": "medium"}
            ],
            "instructions": "1. Preheat oven to 400°F\n2. Season salmon with herbs\n3. Toss vegetables with oil\n4. Bake together for 15-20 minutes",
            "cuisine_type": "Mediterranean",
            "meal_type": "dinner",
            "prep_time_minutes": 10,
            "cook_time_minutes": 20,
            "nutritional_info": {
                "calories": 450,
                "protein": 35,
                "carbs": 15,
                "fat": 28
            },
            "estimated_cost_usd": 800,  # $8.00
            "difficulty_level": "medium",
            "servings": 1
        },
        {
            "name": "Vegetarian Stir Fry",
            "description": "Colorful stir-fried vegetables with tofu in savory sauce",
            "ingredients": [
                {"name": "firm tofu", "quantity": "4", "unit": "oz"},
                {"name": "broccoli", "quantity": "1", "unit": "cup"},
                {"name": "carrots", "quantity": "1/2", "unit": "cup sliced"},
                {"name": "snap peas", "quantity": "1/2", "unit": "cup"},
                {"name": "soy sauce", "quantity": "2", "unit": "tbsp"},
                {"name": "garlic", "quantity": "2", "unit": "cloves"},
                {"name": "ginger", "quantity": "1", "unit": "tsp"}
            ],
            "instructions": "1. Press and cube tofu\n2. Stir-fry tofu until golden\n3. Add vegetables and sauce\n4. Cook until tender-crisp",
            "cuisine_type": "Asian",
            "meal_type": "dinner",
            "prep_time_minutes": 15,
            "cook_time_minutes": 12,
            "nutritional_info": {
                "calories": 320,
                "protein": 18,
                "carbs": 25,
                "fat": 16
            },
            "estimated_cost_usd": 300,  # $3.00
            "difficulty_level": "medium",
            "servings": 1
        },
        {
            "name": "Chicken and Rice Bowl",
            "description": "Seasoned chicken breast over brown rice with steamed vegetables",
            "ingredients": [
                {"name": "chicken breast", "quantity": "5", "unit": "oz"},
                {"name": "brown rice", "quantity": "1/2", "unit": "cup"},
                {"name": "green beans", "quantity": "1/2", "unit": "cup"},
                {"name": "carrots", "quantity": "1/4", "unit": "cup diced"},
                {"name": "soy sauce", "quantity": "1", "unit": "tbsp"},
                {"name": "sesame oil", "quantity": "1", "unit": "tsp"}
            ],
            "instructions": "1. Cook rice according to package\n2. Season and cook chicken\n3. Steam vegetables\n4. Combine in bowl with sauce",
            "cuisine_type": "Asian",
            "meal_type": "dinner",
            "prep_time_minutes": 10,
            "cook_time_minutes": 25,
            "nutritional_info": {
                "calories": 480,
                "protein": 32,
                "carbs": 55,
                "fat": 12
            },
            "estimated_cost_usd": 500,  # $5.00
            "difficulty_level": "easy",
            "servings": 1
        },
        
        # Snack Recipes
        {
            "name": "Greek Yogurt with Nuts",
            "description": "Protein-rich Greek yogurt topped with mixed nuts and honey",
            "ingredients": [
                {"name": "Greek yogurt", "quantity": "1/2", "unit": "cup"},
                {"name": "mixed nuts", "quantity": "2", "unit": "tbsp"},
                {"name": "honey", "quantity": "1", "unit": "tsp"}
            ],
            "instructions": "1. Place yogurt in bowl\n2. Top with nuts and honey\n3. Mix and enjoy",
            "cuisine_type": "Mediterranean",
            "meal_type": "snack",
            "prep_time_minutes": 2,
            "cook_time_minutes": 0,
            "nutritional_info": {
                "calories": 180,
                "protein": 12,
                "carbs": 15,
                "fat": 8
            },
            "estimated_cost_usd": 150,  # $1.50
            "difficulty_level": "easy",
            "servings": 1
        },
        {
            "name": "Apple with Peanut Butter",
            "description": "Fresh apple slices with natural peanut butter",
            "ingredients": [
                {"name": "apple", "quantity": "1", "unit": "medium"},
                {"name": "natural peanut butter", "quantity": "2", "unit": "tbsp"}
            ],
            "instructions": "1. Slice apple\n2. Serve with peanut butter for dipping",
            "cuisine_type": "American",
            "meal_type": "snack",
            "prep_time_minutes": 3,
            "cook_time_minutes": 0,
            "nutritional_info": {
                "calories": 270,
                "protein": 8,
                "carbs": 30,
                "fat": 16
            },
            "estimated_cost_usd": 120,  # $1.20
            "difficulty_level": "easy",
            "servings": 1
        }
    ]

def seed_recipes() -> bool:
    """Seed the database with sample recipes"""
    try:
        repository = RecipeRepository()
        
        # Check if recipes already exist
        existing_count = repository.get_recipe_count()
        if existing_count > 0:
            logger.info(f"Recipes already exist ({existing_count} found). Skipping seed operation.")
            return True
        
        # Get sample data and create recipes
        sample_recipes = get_sample_recipes()
        created_recipes = repository.bulk_create_recipes(sample_recipes)
        
        logger.info(f"Successfully seeded {len(created_recipes)} recipes")
        
        # Log statistics
        stats = repository.get_recipe_statistics()
        logger.info(f"Recipe statistics after seeding: {stats}")
        
        return True
        
    except Exception as e:
        logger.error(f"Error seeding recipes: {str(e)}")
        return False

def seed_all_data() -> bool:
    """Seed all sample data"""
    logger.info("Starting data seeding process...")
    
    success = True
    
    # Seed recipes
    if not seed_recipes():
        success = False
        logger.error("Failed to seed recipes")
    
    if success:
        logger.info("Data seeding completed successfully")
    else:
        logger.error("Data seeding completed with errors")
    
    return success

if __name__ == "__main__":
    # Configure logging for standalone execution
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s %(levelname)s %(name)s %(message)s'
    )
    
    from main import create_app
    
    # Create app context for database operations
    app = create_app()
    with app.app_context():
        seed_all_data() 