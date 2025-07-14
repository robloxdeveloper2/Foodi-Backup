"""
Database Configuration and Initialization
Handles PostgreSQL and MongoDB connections
"""

from flask_sqlalchemy import SQLAlchemy
from pymongo import MongoClient
from pymongo.errors import ConnectionFailure, ServerSelectionTimeoutError
import os

# Initialize SQLAlchemy for PostgreSQL
db = SQLAlchemy()

# MongoDB client - will be initialized in app factory
mongo_client = None
mongo_db = None

def init_mongo(app):
    """Initialize MongoDB connection"""
    global mongo_client, mongo_db
    
    mongodb_uri = app.config.get('MONGODB_URI')
    print(f"DEBUG: MongoDB URI from config: {mongodb_uri}")
    
    if mongodb_uri:
        try:
            # Create client with timeout
            mongo_client = MongoClient(mongodb_uri, serverSelectionTimeoutMS=5000)
            
            # Test the connection
            mongo_client.admin.command('ping')
            print("DEBUG: MongoDB connection successful!")
            
            # Extract database name from URI or use default
            # For MongoDB Atlas URIs, the database name might not be in the path
            if '/' in mongodb_uri and not mongodb_uri.endswith('/'):
                # Check if there's a database name after the last /
                path_part = mongodb_uri.split('/')[-1]
                # If it starts with ?, it's query parameters, not a database name
                if path_part and not path_part.startswith('?'):
                    db_name = path_part.split('?')[0]  # Remove query parameters
                else:
                    db_name = 'foodi_demo'  # Default for Atlas
            else:
                db_name = 'foodi_demo'  # Default for Atlas
            
            print(f"DEBUG: Using MongoDB database: {db_name}")
            
            mongo_db = mongo_client[db_name]
            
        except (ConnectionFailure, ServerSelectionTimeoutError) as e:
            print(f"ERROR: Failed to connect to MongoDB: {e}")
            print("INFO: MongoDB connection failed, will use in-memory fallback")
            mongo_client = None
            mongo_db = None
        except Exception as e:
            print(f"ERROR: Unexpected error connecting to MongoDB: {e}")
            mongo_client = None
            mongo_db = None
    else:
        print("WARNING: No MONGODB_URI configured")
    
    return mongo_db

def get_mongo_db():
    """Get MongoDB database instance"""
    return mongo_db 