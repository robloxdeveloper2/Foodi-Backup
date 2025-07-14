#!/usr/bin/env python3
"""
SQL Generation Script
Story 3.3: Personal Recipe Collection

Generates SQL DDL statements for the user recipe models.
"""

import sys
import os
from pathlib import Path

# Add the backend/src directory to Python path so we can import our modules
backend_src_dir = Path(__file__).parent.parent.parent
sys.path.insert(0, str(backend_src_dir))

# Import Flask-SQLAlchemy database instance
from data_access.database import db

# Now we can import our models
from core.models.user_recipe import UserRecipe
from core.models.user_recipe_category import UserRecipeCategory, UserRecipeCategoryAssignment
from core.models.recipe import Recipe
from core.models.user import User
from core.models.tutorial import Tutorial, TutorialProgress

def generate_create_table_sql():
    """Generate CREATE TABLE statements for all models."""
    
    # Import SQLAlchemy components
    from sqlalchemy import create_engine
    from sqlalchemy.schema import CreateTable
    
    # Create a mock PostgreSQL engine for SQL generation (no actual database connection)
    engine = create_engine('postgresql://user:pass@localhost/db', echo=False)
    
    # Get all model classes
    models = [User, Recipe, UserRecipe, UserRecipeCategory, UserRecipeCategoryAssignment, Tutorial, TutorialProgress]
    
    print("-- SQL DDL for Foodi Application Models")
    print("-- Generated automatically from Flask-SQLAlchemy models")
    print("-- Includes User Recipe Models (Story 3.3) and Tutorial Models (Story 3.4)")
    print()
    
    # Generate UUID extension
    print("-- Enable UUID extension")
    print("CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\";")
    print()
    
    for model in models:
        # Generate CREATE TABLE statement
        create_table = CreateTable(model.__table__)
        sql = str(create_table.compile(engine))
        print(f"-- Table: {model.__tablename__}")
        print(sql)
        print()

if __name__ == "__main__":
    generate_create_table_sql() 
