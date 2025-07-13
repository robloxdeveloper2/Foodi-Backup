"""
Foodi Backend Application
Main entry point for the Flask application
"""

import os
import logging
from datetime import timedelta
from flask import Flask
from flask_cors import CORS
from flask_jwt_extended import JWTManager
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address
from dotenv import load_dotenv

# Load environment variables FIRST, before importing config
load_dotenv()

# Debug environment variables
print("DEBUG: Environment variables loaded")
print(f"DEBUG: MONGODB_URI = {os.getenv('MONGODB_URI', 'NOT SET')}")
print(f"DEBUG: DATABASE_URL = {os.getenv('DATABASE_URL', 'NOT SET')}")

from config.app_config import Config
from data_access.database import db, init_mongo
from api.users import users_bp
from api.meal_plans import meal_plans_bp
from api.preferences import preferences_bp
from api.meal_substitution import meal_substitution_bp
from api.grocery_lists import grocery_lists_bp
from api.social_endpoints import social_bp
from api.recipes import recipe_bp
from api.user_recipes import user_recipes_bp
from api.tutorials import tutorial_bp
from api.pantry import pantry_bp
from core.exceptions import register_error_handlers

# Import models to register them with SQLAlchemy
from core.models.user import User
from core.models.recipe import Recipe
from core.models.meal_plan import MealPlan
from core.models.grocery_list import GroceryList, GroceryListItem
from core.models.user_social_profile import UserSocialProfile
from core.models.user_connection import UserConnection
from core.models.connection_request import ConnectionRequest
from core.models.user_activity import UserActivity
from core.models.user_recipe import UserRecipe
from core.models.user_recipe_category import UserRecipeCategory
from core.models.tutorial import Tutorial, TutorialProgress
from core.models.pantry_item import PantryItem

def create_app(config_class=Config):
    """Create and configure the Flask application"""
    app = Flask(__name__)
    app.config.from_object(config_class)
    
    # Configure logging
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s %(levelname)s %(name)s %(message)s'
    )
    
    # Initialize extensions
    db.init_app(app)
    init_mongo(app)
    
    # Initialize JWT
    jwt = JWTManager(app)
    app.config['JWT_ACCESS_TOKEN_EXPIRES'] = timedelta(
        seconds=int(os.getenv('JWT_ACCESS_TOKEN_EXPIRES', 3600))
    )
    
    # Initialize CORS
    CORS(app, resources={
        r"/api/*": {
            "origins": [os.getenv('FRONTEND_URL', 'http://localhost:3000')],
            "methods": ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
            "allow_headers": ["Content-Type", "Authorization"]
        }
    })
    
    # Initialize rate limiting
    limiter = Limiter(
        app=app,
        key_func=get_remote_address,
        default_limits=["200 per day", "50 per hour"],
        storage_uri=os.getenv('RATE_LIMIT_STORAGE_URL', 'memory://')
    )
    
    # Register blueprints
    app.register_blueprint(users_bp, url_prefix='/api/v1/users')
    app.register_blueprint(meal_plans_bp, url_prefix='/api/v1/meal-plans')
    app.register_blueprint(preferences_bp, url_prefix='/api/v1/preferences')
    app.register_blueprint(meal_substitution_bp, url_prefix='/api/v1')
    app.register_blueprint(grocery_lists_bp, url_prefix='/api/v1')
    app.register_blueprint(social_bp, url_prefix='/api/v1/social')
    app.register_blueprint(recipe_bp, url_prefix='/api/v1')
    app.register_blueprint(user_recipes_bp)
    app.register_blueprint(tutorial_bp, url_prefix='/api/v1')
    app.register_blueprint(pantry_bp)
    
    # Register error handlers
    register_error_handlers(app)
    
    # Create database tables
    with app.app_context():
        db.create_all()
    
    return app

if __name__ == '__main__':
    app = create_app()
    port = int(os.getenv('PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=True) 