"""
User Preferences MongoDB Models
Handles flexible preference data stored in MongoDB with fallback to in-memory storage
"""

from datetime import datetime
from typing import Optional, List, Dict, Any
from pymongo import IndexModel, ASCENDING
from data_access.database import get_mongo_db

# In-memory fallback storage for when MongoDB is not available
_in_memory_preferences = {}

class UserPreferences:
    """MongoDB model for storing flexible user preference data with fallback"""
    
    COLLECTION_NAME = "user_preferences"
    
    def __init__(self):
        self.db = get_mongo_db()
        self.collection = self.db[self.COLLECTION_NAME] if self.db is not None else None
        self.use_memory_fallback = self.collection is None
        
        if self.collection is not None:
            self._ensure_indexes()
        elif not hasattr(self, '_warned_about_mongo'):
            print("INFO: MongoDB not available during initialization, using in-memory storage")
            self._warned_about_mongo = True
    
    def _ensure_indexes(self):
        """Create indexes for the collection"""
        if self.collection is not None:
            indexes = [
                IndexModel([("user_id", ASCENDING)], unique=True),
                IndexModel([("last_updated", ASCENDING)]),
            ]
            self.collection.create_indexes(indexes)
    
    def _check_mongo_connection(self):
        """Check if MongoDB connection is now available"""
        if self.use_memory_fallback:
            self.db = get_mongo_db()
            if self.db is not None:
                self.collection = self.db[self.COLLECTION_NAME]
                self.use_memory_fallback = False
                self._ensure_indexes()
                print("INFO: MongoDB connection restored, switching from in-memory storage")
                return True
        return False
    
    def create_default_preferences(self, user_id: str) -> Dict[str, Any]:
        """Create default preferences document for a new user"""
        default_doc = {
            "user_id": user_id,
            "profile_setup_completed": False,
            "onboarding_step": 0,
            "preferences": {
                "dietary_restrictions": [],
                "custom_dietary_restrictions": [],
                "allergies": [],
                "disliked_ingredients": [],
                "favorite_cuisines": [],
                "spice_tolerance": "medium",
                "meal_frequency": {
                    "breakfast": True,
                    "lunch": True,
                    "dinner": True,
                    "snacks": False
                }
            },
            # Story 2.2: Meal recommendation swiping preferences
            "swipe_preferences": {},  # {"recipe_id": "like" | "dislike"}
            "recipe_ratings": {},  # {"recipe_id": 4.5}
            "ingredient_preferences": {
                "liked": [],
                "disliked": []
            },
            "cuisine_preferences": {},  # {"Italian": 5, "Mexican": 4}
            "prep_time_preference": "moderate",  # "quick", "moderate", "elaborate"
            "swipe_sessions": [],  # Track swiping sessions for analytics
            "budget_info": {
                "period": None,
                "amount": None,
                "currency": "USD",
                "price_per_meal_min": None,
                "price_per_meal_max": None
            },
            "cooking_profile": {
                "experience_level": None,
                "cooking_frequency": None,
                "kitchen_equipment": [],
                "prep_time_preference": "medium",
                "difficulty_preference": "medium"
            },
            "nutritional_goals": {
                "weight_goal": None,
                "daily_calorie_target": None,
                "protein_target_pct": None,
                "carb_target_pct": None,
                "fat_target_pct": None,
                "dietary_program": None,
                "health_conditions": []
            },
            "ai_profile": {
                "meal_pattern_history": [],
                "preference_drift_indicators": {},
                "last_recommendation_feedback": None
            },
            "created_at": datetime.utcnow(),
            "last_updated": datetime.utcnow()
        }
        
        if self.collection is not None:
            self.collection.insert_one(default_doc)
        
        return default_doc
    
    def get_preferences(self, user_id: str) -> Optional[Dict[str, Any]]:
        """Get user preferences by user ID"""
        if self.use_memory_fallback:
            return _in_memory_preferences.get(user_id)
        
        if self.collection is None:
            return None
        
        return self.collection.find_one({"user_id": user_id})
    
    def update_preferences(self, user_id: str, updates: Dict[str, Any]) -> bool:
        """Update user preferences"""
        if self.collection is None:
            return False
        
        # Ensure last_updated is always set
        updates["last_updated"] = datetime.utcnow()
        
        result = self.collection.update_one(
            {"user_id": user_id},
            {"$set": updates},
            upsert=True
        )
        
        return result.modified_count > 0 or result.upserted_id is not None
    
    def update_profile_setup(self, user_id: str, profile_data: Dict[str, Any]) -> bool:
        """Update profile setup data from onboarding"""
        updates = {
            "profile_setup_completed": True,
            "onboarding_step": 999,  # Completed
        }
        
        # Map profile_data to MongoDB structure
        if "dietary_restrictions" in profile_data:
            updates["preferences.dietary_restrictions"] = profile_data["dietary_restrictions"]
        
        if "custom_dietary_restrictions" in profile_data:
            updates["preferences.custom_dietary_restrictions"] = profile_data["custom_dietary_restrictions"]
        
        if "allergies" in profile_data:
            updates["preferences.allergies"] = profile_data["allergies"]
        
        if "budget_period" in profile_data:
            updates["budget_info.period"] = profile_data["budget_period"]
        
        if "budget_amount" in profile_data:
            updates["budget_info.amount"] = profile_data["budget_amount"]
        
        if "currency" in profile_data:
            updates["budget_info.currency"] = profile_data["currency"]
        
        if "price_per_meal_min" in profile_data:
            updates["budget_info.price_per_meal_min"] = profile_data["price_per_meal_min"]
        
        if "price_per_meal_max" in profile_data:
            updates["budget_info.price_per_meal_max"] = profile_data["price_per_meal_max"]
        
        if "cooking_experience_level" in profile_data:
            updates["cooking_profile.experience_level"] = profile_data["cooking_experience_level"]
        
        if "cooking_frequency" in profile_data:
            updates["cooking_profile.cooking_frequency"] = profile_data["cooking_frequency"]
        
        if "kitchen_equipment" in profile_data:
            updates["cooking_profile.kitchen_equipment"] = profile_data["kitchen_equipment"]
        
        if "weight_goal" in profile_data:
            updates["nutritional_goals.weight_goal"] = profile_data["weight_goal"]
        
        if "daily_calorie_target" in profile_data:
            updates["nutritional_goals.daily_calorie_target"] = profile_data["daily_calorie_target"]
        
        if "protein_target_pct" in profile_data:
            updates["nutritional_goals.protein_target_pct"] = profile_data["protein_target_pct"]
        
        if "carb_target_pct" in profile_data:
            updates["nutritional_goals.carb_target_pct"] = profile_data["carb_target_pct"]
        
        if "fat_target_pct" in profile_data:
            updates["nutritional_goals.fat_target_pct"] = profile_data["fat_target_pct"]
        
        if "dietary_program" in profile_data:
            updates["nutritional_goals.dietary_program"] = profile_data["dietary_program"]
        
        return self.update_preferences(user_id, updates)
    
    def update_onboarding_step(self, user_id: str, step: int) -> bool:
        """Update the current onboarding step"""
        return self.update_preferences(user_id, {"onboarding_step": step})
    
    def delete_preferences(self, user_id: str) -> bool:
        """Delete user preferences (for user deletion)"""
        if self.collection is None:
            return False
        
        result = self.collection.delete_one({"user_id": user_id})
        return result.deleted_count > 0

    # Story 2.2: Methods for meal swiping and preference learning
    
    def record_swipe_feedback(self, user_id: str, recipe_id: str, action: str, context: str = "swiping_session") -> bool:
        """Record a swipe action for a recipe"""
        # Validate action
        if action not in ["like", "dislike"]:
            print(f"ERROR: Invalid action '{action}' for user {user_id}")
            return False
        
        # Check if MongoDB connection is now available
        self._check_mongo_connection()
        
        if self.use_memory_fallback:
            # Use in-memory storage
            if user_id not in _in_memory_preferences:
                _in_memory_preferences[user_id] = {
                    "user_id": user_id,
                    "swipe_preferences": {},
                    "recipe_ratings": {},
                    "ingredient_preferences": {"liked": [], "disliked": []},
                    "cuisine_preferences": {},
                    "prep_time_preference": "moderate",
                    "swipe_sessions": [],
                    "last_updated": datetime.utcnow()
                }
            
            # Update swipe preferences
            _in_memory_preferences[user_id]["swipe_preferences"][recipe_id] = action
            _in_memory_preferences[user_id]["last_updated"] = datetime.utcnow()
            
            # Add session entry
            session_entry = {
                "recipe_id": recipe_id,
                "action": action,
                "timestamp": datetime.utcnow(),
                "context": context
            }
            _in_memory_preferences[user_id]["swipe_sessions"].append(session_entry)
            
            print(f"DEBUG: Stored swipe feedback in memory for user {user_id}, recipe {recipe_id}, action {action}")
            return True
        
        # Use MongoDB
        if self.collection is None:
            print(f"ERROR: MongoDB collection is None for user {user_id}")
            return False
        
        try:
            updates = {
                f"swipe_preferences.{recipe_id}": action,
                "last_updated": datetime.utcnow()
            }
            
            # Add to swipe session history
            session_entry = {
                "recipe_id": recipe_id,
                "action": action,
                "timestamp": datetime.utcnow(),
                "context": context
            }
            
            print(f"DEBUG: Storing swipe feedback in MongoDB for user {user_id}, recipe {recipe_id}, action {action}")
            
            # Use $push to add to swipe_sessions array
            result = self.collection.update_one(
                {"user_id": user_id},
                {
                    "$set": updates,
                    "$push": {"swipe_sessions": session_entry}
                },
                upsert=True
            )
            
            print(f"DEBUG: MongoDB update result - modified: {result.modified_count}, upserted: {result.upserted_id}")
            
            return result.modified_count > 0 or result.upserted_id is not None
            
        except Exception as e:
            print(f"ERROR: MongoDB operation failed for user {user_id}: {str(e)}")
            return False
    
    def set_recipe_rating(self, user_id: str, recipe_id: str, rating: float) -> bool:
        """Set a detailed rating for a recipe (1-5 stars)"""
        if self.collection is None:
            return False
        
        # Validate rating range
        if not (1.0 <= rating <= 5.0):
            return False
        
        updates = {
            f"recipe_ratings.{recipe_id}": rating,
            "last_updated": datetime.utcnow()
        }
        
        result = self.collection.update_one(
            {"user_id": user_id},
            {"$set": updates},
            upsert=True
        )
        
        return result.modified_count > 0 or result.upserted_id is not None
    
    def update_ingredient_preferences(self, user_id: str, ingredient: str, preference: str) -> bool:
        """Update ingredient like/dislike preference"""
        if self.collection is None:
            return False
        
        # Validate preference
        if preference not in ["liked", "disliked"]:
            return False
        
        opposite_preference = "disliked" if preference == "liked" else "liked"
        
        # Remove from opposite list and add to preferred list
        result = self.collection.update_one(
            {"user_id": user_id},
            {
                "$pull": {f"ingredient_preferences.{opposite_preference}": ingredient},
                "$addToSet": {f"ingredient_preferences.{preference}": ingredient},
                "$set": {"last_updated": datetime.utcnow()}
            },
            upsert=True
        )
        
        return result.modified_count > 0 or result.upserted_id is not None
    
    def set_cuisine_preference(self, user_id: str, cuisine: str, rating: int) -> bool:
        """Set cuisine preference rating (1-5 scale)"""
        if self.collection is None:
            return False
        
        # Validate rating range
        if not (1 <= rating <= 5):
            return False
        
        updates = {
            f"cuisine_preferences.{cuisine}": rating,
            "last_updated": datetime.utcnow()
        }
        
        result = self.collection.update_one(
            {"user_id": user_id},
            {"$set": updates},
            upsert=True
        )
        
        return result.modified_count > 0 or result.upserted_id is not None
    
    def set_prep_time_preference(self, user_id: str, preference: str) -> bool:
        """Set preparation time preference"""
        if self.collection is None:
            return False
        
        # Validate preference
        if preference not in ["quick", "moderate", "elaborate"]:
            return False
        
        updates = {
            "prep_time_preference": preference,
            "last_updated": datetime.utcnow()
        }
        
        result = self.collection.update_one(
            {"user_id": user_id},
            {"$set": updates},
            upsert=True
        )
        
        return result.modified_count > 0 or result.upserted_id is not None
    
    def get_swipe_preferences(self, user_id: str) -> Dict[str, str]:
        """Get all swipe preferences for a user"""
        preferences = self.get_preferences(user_id)
        if preferences:
            return preferences.get("swipe_preferences", {})
        return {}
    
    def get_recipe_ratings(self, user_id: str) -> Dict[str, float]:
        """Get all recipe ratings for a user"""
        preferences = self.get_preferences(user_id)
        if preferences:
            return preferences.get("recipe_ratings", {})
        return {}
    
    def get_ingredient_preferences(self, user_id: str) -> Dict[str, List[str]]:
        """Get ingredient like/dislike preferences"""
        preferences = self.get_preferences(user_id)
        if preferences:
            return preferences.get("ingredient_preferences", {"liked": [], "disliked": []})
        return {"liked": [], "disliked": []}


class ProfileDataProvider:
    """Provides predefined data for profile setup options"""
    
    @staticmethod
    def get_dietary_restrictions() -> List[str]:
        """Get list of available dietary restrictions"""
        return [
            'vegetarian', 'vegan', 'pescatarian', 'gluten-free', 'dairy-free', 
            'nut-free', 'egg-free', 'soy-free', 'shellfish-free', 'kosher', 'halal',
            'keto', 'paleo', 'low-carb', 'low-fat', 'low-sodium', 'sugar-free'
        ]
    
    @staticmethod
    def get_allergies() -> List[str]:
        """Get list of common food allergies"""
        return [
            'milk', 'eggs', 'fish', 'shellfish', 'tree-nuts', 'peanuts', 
            'wheat', 'soybeans', 'sesame', 'mustard', 'celery', 'lupin'
        ]
    
    @staticmethod
    def get_cooking_experience_levels() -> List[Dict[str, str]]:
        """Get cooking experience levels with descriptions"""
        return [
            {
                "value": "beginner",
                "label": "Beginner",
                "description": "I'm new to cooking and prefer simple recipes with basic techniques"
            },
            {
                "value": "intermediate", 
                "label": "Intermediate",
                "description": "I can handle moderate complexity and enjoy trying new techniques"
            },
            {
                "value": "advanced",
                "label": "Advanced", 
                "description": "I'm comfortable with complex recipes and advanced cooking methods"
            }
        ]
    
    @staticmethod
    def get_kitchen_equipment() -> List[str]:
        """Get list of common kitchen equipment"""
        return [
            'oven', 'stovetop', 'microwave', 'air-fryer', 'slow-cooker', 'pressure-cooker',
            'food-processor', 'blender', 'stand-mixer', 'grill', 'toaster', 'rice-cooker',
            'steamer', 'deep-fryer', 'sous-vide', 'dehydrator', 'bread-maker'
        ]
    
    @staticmethod
    def get_dietary_programs() -> List[Dict[str, str]]:
        """Get dietary programs with descriptions"""
        return [
            {
                "value": "none",
                "label": "None",
                "description": "No specific dietary program"
            },
            {
                "value": "keto",
                "label": "Ketogenic",
                "description": "High-fat, low-carb diet for ketosis"
            },
            {
                "value": "paleo",
                "label": "Paleo",
                "description": "Whole foods based on ancestral eating patterns"
            },
            {
                "value": "mediterranean",
                "label": "Mediterranean",
                "description": "Heart-healthy diet rich in fruits, vegetables, and olive oil"
            },
            {
                "value": "intermittent_fasting",
                "label": "Intermittent Fasting",
                "description": "Time-restricted eating patterns"
            },
            {
                "value": "low_carb",
                "label": "Low Carb",
                "description": "Reduced carbohydrate intake"
            },
            {
                "value": "whole30",
                "label": "Whole30",
                "description": "30-day whole food nutrition reset"
            }
        ]
    
    @staticmethod
    def get_currencies() -> List[str]:
        """Get supported currencies"""
        return ["USD", "EUR", "GBP", "CAD"] 