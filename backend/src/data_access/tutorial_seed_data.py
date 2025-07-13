"""
Tutorial Seed Data
Sample tutorials for testing and development
"""

import logging
from typing import List, Dict, Any
from data_access.tutorial_repository import TutorialRepository
from core.exceptions import ValidationError

logger = logging.getLogger(__name__)

def create_sample_tutorials() -> List[Dict[str, Any]]:
    """Create sample tutorial data"""
    
    tutorials = [
        {
            "title": "Basic Knife Skills: The Foundation of Cooking",
            "description": "Learn the fundamental knife skills every cook needs to know. This tutorial covers proper knife grip, cutting techniques, and safety practices that will make your cooking more efficient and enjoyable.",
            "category": "knife_skills",
            "subcategory": "basic_cuts",
            "difficulty_level": "beginner",
            "estimated_duration_minutes": 25,
            "skill_level_required": "none",
            "is_beginner_friendly": True,
            "is_featured": True,
            "thumbnail_url": "https://example.com/thumbnails/knife-skills.jpg",
            "video_url": "https://example.com/videos/knife-skills.mp4",
            "learning_objectives": [
                "Learn proper knife grip and posture",
                "Master basic cuts: dice, julienne, chop",
                "Understand knife safety fundamentals",
                "Practice efficient cutting techniques"
            ],
            "prerequisites": [],
            "equipment_needed": [
                "Chef's knife (8-10 inch)",
                "Cutting board",
                "Kitchen towel",
                "Practice vegetables (onions, carrots, celery)"
            ],
            "tags": ["essential", "basics", "safety", "technique"],
            "keywords": ["knife", "cutting", "dicing", "safety", "grip", "basic"],
            "steps": [
                {
                    "step": 1,
                    "title": "Knife Selection and Setup",
                    "description": "Choose the right knife and prepare your workspace for safe cutting practice.",
                    "image_url": "https://example.com/steps/knife-setup.jpg",
                    "duration_minutes": 3,
                    "tips": "A sharp knife is safer than a dull one - it requires less pressure and is more predictable."
                },
                {
                    "step": 2,
                    "title": "Proper Knife Grip",
                    "description": "Learn the pinch grip - the foundation of all knife work. Hold the blade between thumb and index finger.",
                    "image_url": "https://example.com/steps/knife-grip.jpg",
                    "duration_minutes": 5,
                    "tips": "Your knuckles should guide the blade - curl your fingertips under and use knuckles as a fence."
                },
                {
                    "step": 3,
                    "title": "Basic Dicing Technique",
                    "description": "Practice dicing an onion using proper knife technique and safety practices.",
                    "image_url": "https://example.com/steps/dicing.jpg",
                    "duration_minutes": 8,
                    "tips": "Keep the tip of the knife on the cutting board and rock the blade for controlled cuts."
                },
                {
                    "step": 4,
                    "title": "Julienne and Chop Cuts",
                    "description": "Learn to create uniform julienne strips and practice rough chopping techniques.",
                    "image_url": "https://example.com/steps/julienne.jpg",
                    "duration_minutes": 7,
                    "tips": "Consistency in size ensures even cooking - take your time to develop muscle memory."
                },
                {
                    "step": 5,
                    "title": "Safety and Cleanup",
                    "description": "Review safety practices and proper knife care and storage.",
                    "image_url": "https://example.com/steps/cleanup.jpg",
                    "duration_minutes": 2,
                    "tips": "Always hand wash knives immediately and store them safely in a knife block or magnetic strip."
                }
            ]
        },
        {
            "title": "Food Safety Fundamentals",
            "description": "Essential food safety practices every home cook must know to prevent foodborne illness and ensure safe meal preparation.",
            "category": "food_safety",
            "subcategory": "basics",
            "difficulty_level": "beginner",
            "estimated_duration_minutes": 20,
            "skill_level_required": "none",
            "is_beginner_friendly": True,
            "is_featured": True,
            "thumbnail_url": "https://example.com/thumbnails/food-safety.jpg",
            "learning_objectives": [
                "Understand temperature danger zones",
                "Learn proper hand washing techniques",
                "Practice safe food storage methods",
                "Recognize signs of food spoilage"
            ],
            "prerequisites": [],
            "equipment_needed": [
                "Food thermometer",
                "Soap and water",
                "Clean towels",
                "Storage containers"
            ],
            "tags": ["essential", "safety", "health", "basics"],
            "keywords": ["safety", "temperature", "hygiene", "storage", "contamination"],
            "steps": [
                {
                    "step": 1,
                    "title": "Hand Washing Mastery",
                    "description": "Learn the proper 20-second hand washing technique that eliminates harmful bacteria.",
                    "duration_minutes": 4,
                    "tips": "Sing 'Happy Birthday' twice to time your hand washing correctly."
                },
                {
                    "step": 2,
                    "title": "Temperature Control",
                    "description": "Understand safe cooking temperatures and the danger zone (40-140°F).",
                    "duration_minutes": 6,
                    "tips": "Use a food thermometer - visual cues alone aren't reliable for safety."
                },
                {
                    "step": 3,
                    "title": "Cross-Contamination Prevention",
                    "description": "Learn to separate raw and cooked foods and use different cutting boards.",
                    "duration_minutes": 5,
                    "tips": "Use separate cutting boards for raw meat and vegetables to prevent cross-contamination."
                },
                {
                    "step": 4,
                    "title": "Proper Food Storage",
                    "description": "Practice safe refrigerator organization and storage techniques.",
                    "duration_minutes": 5,
                    "tips": "Store raw meat on the bottom shelf to prevent drips onto other foods."
                }
            ]
        },
        {
            "title": "Sautéing Techniques: Building Flavor",
            "description": "Master the art of sautéing to build complex flavors in your dishes. Learn heat control, timing, and ingredient sequencing.",
            "category": "cooking_methods",
            "subcategory": "sauteing",
            "difficulty_level": "intermediate",
            "estimated_duration_minutes": 30,
            "skill_level_required": "basic",
            "is_beginner_friendly": False,
            "is_featured": True,
            "thumbnail_url": "https://example.com/thumbnails/sauteing.jpg",
            "learning_objectives": [
                "Understand heat control for sautéing",
                "Learn proper pan selection and preparation",
                "Master ingredient timing and sequencing",
                "Develop flavor through proper technique"
            ],
            "prerequisites": ["Basic knife skills", "Understanding of cooking basics"],
            "equipment_needed": [
                "Large sauté pan or skillet",
                "Wooden spoon or spatula",
                "Various oils and fats",
                "Practice ingredients (onions, garlic, vegetables)"
            ],
            "tags": ["technique", "flavor", "intermediate", "heat"],
            "keywords": ["sauté", "pan", "heat", "flavor", "technique", "timing"],
            "steps": [
                {
                    "step": 1,
                    "title": "Pan Selection and Heating",
                    "description": "Choose the right pan and heat it properly for effective sautéing.",
                    "duration_minutes": 5,
                    "tips": "A properly heated pan will make water droplets dance and evaporate quickly."
                },
                {
                    "step": 2,
                    "title": "Oil and Fat Management",
                    "description": "Learn when and how much fat to use for different ingredients.",
                    "duration_minutes": 7,
                    "tips": "The oil should shimmer but not smoke - this indicates the right temperature."
                },
                {
                    "step": 3,
                    "title": "Ingredient Sequencing",
                    "description": "Practice adding ingredients in the correct order for optimal flavor development.",
                    "duration_minutes": 10,
                    "tips": "Start with aromatics like onions and garlic, then add harder vegetables before softer ones."
                },
                {
                    "step": 4,
                    "title": "Movement and Timing",
                    "description": "Learn the sautéing motion and how to time your cooking for perfect results.",
                    "duration_minutes": 8,
                    "tips": "Keep ingredients moving to prevent burning, but don't over-stir which can reduce browning."
                }
            ]
        },
        {
            "title": "Bread Baking Basics: Your First Loaf",
            "description": "Discover the joy of bread baking with this comprehensive guide to making your first homemade loaf. Learn about yeast, kneading, and the magic of fermentation.",
            "category": "baking_basics",
            "subcategory": "bread",
            "difficulty_level": "intermediate",
            "estimated_duration_minutes": 45,
            "skill_level_required": "basic",
            "is_beginner_friendly": False,
            "is_featured": False,
            "thumbnail_url": "https://example.com/thumbnails/bread-baking.jpg",
            "learning_objectives": [
                "Understand how yeast works",
                "Learn proper kneading techniques",
                "Master proofing and fermentation",
                "Recognize properly baked bread"
            ],
            "prerequisites": ["Basic kitchen skills", "Understanding of measurements"],
            "equipment_needed": [
                "Large mixing bowl",
                "Kitchen scale",
                "Clean kitchen towel",
                "Loaf pan",
                "Bread ingredients"
            ],
            "tags": ["baking", "bread", "yeast", "technique"],
            "keywords": ["bread", "yeast", "kneading", "proofing", "baking", "fermentation"],
            "steps": [
                {
                    "step": 1,
                    "title": "Understanding Ingredients",
                    "description": "Learn about flour, yeast, salt, and water - the four essential bread ingredients.",
                    "duration_minutes": 8,
                    "tips": "Use bread flour for better gluten development and structure."
                },
                {
                    "step": 2,
                    "title": "Mixing and Initial Kneading",
                    "description": "Combine ingredients and begin developing gluten through kneading.",
                    "duration_minutes": 12,
                    "tips": "The dough should become smooth and elastic - this takes about 8-10 minutes of kneading."
                },
                {
                    "step": 3,
                    "title": "First Rise (Bulk Fermentation)",
                    "description": "Allow the dough to rise and develop flavor through fermentation.",
                    "duration_minutes": 8,
                    "tips": "The dough should double in size - this usually takes 1-2 hours depending on temperature."
                },
                {
                    "step": 4,
                    "title": "Shaping and Second Rise",
                    "description": "Shape your loaf and allow for final proofing before baking.",
                    "duration_minutes": 10,
                    "tips": "Shape gently to maintain air bubbles created during fermentation."
                },
                {
                    "step": 5,
                    "title": "Baking and Cooling",
                    "description": "Bake your bread and learn how to tell when it's perfectly done.",
                    "duration_minutes": 7,
                    "tips": "The bread is done when it sounds hollow when tapped on the bottom."
                }
            ]
        },
        {
            "title": "Kitchen Tool Mastery: Essential Equipment",
            "description": "Get familiar with essential kitchen tools and learn how to use them effectively. From measuring cups to thermometers, master your kitchen arsenal.",
            "category": "kitchen_basics",
            "subcategory": "equipment",
            "difficulty_level": "beginner",
            "estimated_duration_minutes": 15,
            "skill_level_required": "none",
            "is_beginner_friendly": True,
            "is_featured": False,
            "thumbnail_url": "https://example.com/thumbnails/kitchen-tools.jpg",
            "learning_objectives": [
                "Identify essential kitchen tools",
                "Learn proper tool usage and care",
                "Understand when to use specific tools",
                "Practice tool maintenance"
            ],
            "prerequisites": [],
            "equipment_needed": [
                "Various kitchen tools",
                "Measuring cups and spoons",
                "Kitchen scale",
                "Thermometer"
            ],
            "tags": ["basics", "tools", "equipment", "maintenance"],
            "keywords": ["tools", "equipment", "measuring", "thermometer", "maintenance"],
            "steps": [
                {
                    "step": 1,
                    "title": "Measuring Tools",
                    "description": "Learn the difference between liquid and dry measuring tools and how to measure accurately.",
                    "duration_minutes": 5,
                    "tips": "Level dry ingredients with a knife for accurate measurements."
                },
                {
                    "step": 2,
                    "title": "Cutting and Prep Tools",
                    "description": "Familiarize yourself with various knives, peelers, and cutting implements.",
                    "duration_minutes": 5,
                    "tips": "Different knives have specific purposes - use the right tool for each job."
                },
                {
                    "step": 3,
                    "title": "Heat and Temperature Tools",
                    "description": "Learn to use thermometers, timers, and heat-resistant tools safely.",
                    "duration_minutes": 5,
                    "tips": "A good thermometer is essential for food safety and consistent results."
                }
            ]
        }
    ]
    
    return tutorials

def seed_tutorials():
    """Seed the database with sample tutorials"""
    try:
        tutorial_repository = TutorialRepository()
        sample_tutorials = create_sample_tutorials()
        
        created_count = 0
        for tutorial_data in sample_tutorials:
            try:
                tutorial = tutorial_repository.create_tutorial(tutorial_data)
                created_count += 1
                logger.info(f"Created tutorial: {tutorial.title}")
            except Exception as e:
                logger.error(f"Failed to create tutorial '{tutorial_data['title']}': {str(e)}")
        
        logger.info(f"Successfully created {created_count} sample tutorials")
        return created_count
        
    except Exception as e:
        logger.error(f"Error seeding tutorials: {str(e)}")
        raise ValidationError(f"Failed to seed tutorials: {str(e)}")

if __name__ == "__main__":
    # Run this script to seed tutorials
    seed_tutorials() 